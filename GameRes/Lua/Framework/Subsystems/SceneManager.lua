require "Framework.GameSubSystem"
require "Collection.DataStack"

local SceneManager = Class(GameSubSystem)

function SceneManager:Ctor()
    self.sceneStack = DataStack.New()
    self.runningScene = nil
    self.nextScene = nil
    self.sendCleanupToScene = false
    self.logicLocked = false
end

-----------------------------------------------------------------------
--- 获取函数
-----------------------------------------------------------------------
function SceneManager:GetRunningScene()
    return self.runningScene
end

function SceneManager:IsSwitching()
    return self.nextScene ~= nil
end

function SceneManager:IsLocked()
    return self:IsSwitching() or self.logicLocked
end

function SceneManager:SetLogicLock()
    self.logicLocked = true
end

function SceneManager:ResetLogicLock()
    self.logicLocked = false
end

-----------------------------------------------------------------------
--- 私有函数
-----------------------------------------------------------------------
local function CleanupNodeImmediately(node, cleanup)
    if node ~= nil then
        if node:IsRunning() then
            node:OnExitTransitionDidStart()
            node:OnExit()
        end
        if cleanup then
            node:OnCleanup()
        end
    end
end

local function SetNextScene(self)
    local runningIsTransition = self.runningScene ~= nil and self.runningScene:IsTransition() == true
    local newIsTransition = self.nextScene ~= nil and self.nextScene:IsTransition() == true

    if not newIsTransition then
        CleanupNodeImmediately(self.runningScene, self.sendCleanupToScene)
    end

    self.sendCleanupToScene = false

    self.runningScene = self.nextScene
    self.nextScene = nil

    if self.runningScene ~= nil and (not runningIsTransition) then
        self.runningScene:OnEnter()
        self.runningScene:OnEnterTransitionDidFinish()
    end
end

-----------------------------------------------------------------------
--- 实现 GameSubSystem 接口
-----------------------------------------------------------------------
function SceneManager:GetGuid()
    return require "Framework.SubsystemGUID".SceneManager
end

function SceneManager:Startup()
end

function SceneManager:Shutdown()
    while(self.sceneStack:Count() > 0)
    do
        local scene = self.sceneStack:Pop()
        CleanupNodeImmediately(scene, true)
    end
end

function SceneManager:Restart()
end

function SceneManager:Update()
    if self.nextScene ~= nil then
        SetNextScene(self)
    end
end

-----------------------------------------------------------------------
--- 场景操作
-----------------------------------------------------------------------
function SceneManager:RunWithScene(scene)
    if scene == nil then error("scene should not be nil") end
    if self.runningScene ~= nil then error("runningScene should be nil") end
    if self.nextScene ~= nil then error("nextScene should be nil") end

    self:PushScene(scene)
end

function SceneManager:ReplaceScene(scene)
    if scene == nil then error("scene should not be nil") end

    if self.runningScene == nil and self.nextScene == nil then
        self:RunWithScene(scene)
        return
    end

    if self.nextScene == scene then
        return
    end

    CleanupNodeImmediately(self.nextScene, true)
    self.nextScene = nil

    self.sendCleanupToScene = true

    if self.sceneStack:Count() > 0 then
        self.sceneStack:Pop()
        self.sceneStack:Push(scene)
    end

    self.nextScene = scene
end

function SceneManager:PushScene(scene)
    if scene == nil then error("scene should not be nil") end

    self.sendCleanupToScene = self.sendCleanupToScene or false
    self.sceneStack:Push(scene)
    self.nextScene = scene
end

function SceneManager:PopScene()
    if self.runningScene == nil then error("running scene should not nil") end

    local count = self.sceneStack:Count()

    if count > 1 then
        self.sceneStack:Pop()
        self.sendCleanupToScene = true
        self.nextScene = self.sceneStack:Peek()
    end
end

function SceneManager:ClearAllScenesExceptWorkingScenes()
    self.sceneStack:Remove(function(scene)
        local toRemove = self.runningScene ~= scene and self.nextScene ~= scene
        if toRemove then
            CleanupNodeImmediately(scene, true)
        end
        return toRemove
    end)
end

function SceneManager:PopToRootScene()
    self:PopToSceneStackLevel(1)
end

function SceneManager:PopToSceneStackLevel(level)
    if self.runningScene == nil then error("A running Scene is needed") end

    local count = self.sceneStack:Count()
    if level <= 0 or level >= count then return end

    if self.sceneStack:Peek() == self.runningScene then
        self.sceneStack:Pop()
        count = count - 1
    end

    while(count > level)
    do
        local current = self.sceneStack:Peek()
        CleanupNodeImmediately(current, true)
        self.sceneStack:Pop()
        count = count - 1
    end

    self.nextScene = self.sceneStack:Peek()
    self.sendCleanupToScene = true
end

function SceneManager:GetStackCount()
    return self.sceneStack:Count()
end

return SceneManager