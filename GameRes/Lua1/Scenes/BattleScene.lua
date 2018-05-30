local SceneCls = require "Framework.Base.Scene"
local utility = require "Utils.Utility"
local BattleUtility = require "Utils.BattleUtility"

local BattleScene = Class(SceneCls)

local function UnitTest(self)
    local BattleUnitPreloadSet = require "Battle.Res.BattleUnitPreloadSet"
    local preloadSet = BattleUnitPreloadSet.New() -- 实例化对象
    for i = 1, #self.leftTeams do
        preloadSet:Union(self.leftTeams[i], self.rightTeam)
    end
    debug_print("@@@@>>>>>>>>>")
    preloadSet:Foreach(function(id, count)
        debug_print("@ id", id, "count", count)
    end)
    debug_print("@@@@<<<<<<<<<")
end

function BattleScene:Ctor(battleParams, leftTeams, rightTeam, firstFightConfig)
    print("BattleScene >>> Enter >>>")
    self.battleParams = battleParams
    self.leftTeams = leftTeams
    self.rightTeam = rightTeam
    self.firstFightConfig = firstFightConfig

    if rightTeam == nil then
        self.rightTeam = BattleUtility.CreateBattleTeamByLineup(self.battleParams:GetBattleType())
    end
end

local function InitBattleNode(self)
    local BattleNodeClass = require "Battle.BattleNode"
    self:AddChild(BattleNodeClass.New(
        self.battleParams,
        self.leftTeams,
        self.rightTeam,
        self.firstFightConfig,
        self
    ))
end

local function GetMapName(self)
    return require "StaticData.Scene":GetData(
        self.battleParams:GetSceneID()
    ):GetMapName()
end

function BattleScene:GetBattleUnitPreloadSet()
    local BattleUnitPreloadSet = require "Battle.Res.BattleUnitPreloadSet"
    local preloadSet = BattleUnitPreloadSet.New()
    for i = 1, #self.leftTeams do
        preloadSet:Union(self.leftTeams[i], self.rightTeam)
    end
    return preloadSet:GetArrayReadonly()
end

-- 加载战斗场景 & 资源!
local function LoadBattleScene(self)
    local ProgressBarUtils = require "Utils.ProgressBarUtils"

    ProgressBarUtils.Display("正在突破次元壁","正在加载场景资源...", 0)

    -- @ 1. 加载场景
    local operation = utility.LoadBattleSceneAsync(GetMapName(self))
    repeat
        coroutine.step()
    until(operation.isDone and operation.progress >= 1)

    -- @ 2. 加载人物资源

    -- 获取人物资源数组([{id, count}])
    local array = self:GetBattleUnitPreloadSet()

    -- passedCount初值为1代表场景加载完毕
    -- additionallyFakeCount是伪进度, 当实际资源加载完毕后, 后面可以有一个停顿时间.
    local passedCount = 1
    local additionallyFakeCount = 5
    local totalCount = #array + 1 + additionallyFakeCount
    ProgressBarUtils.Display("正在突破次元壁","正在加载场景资源...", passedCount / totalCount)
    ----
    for i = 1, #array do
        local unit = array[i]
        local resPathMgr = require "StaticData.ResPath"
        local prefabName = resPathMgr:GetData(unit:GetId()):GetPath()
        ---->>>
        local maxInstances = unit:GetCount()
        self:GetGame():GetPoolManager():CreatePool(
            BattleUtility.GetBattleUnitPoolName(unit:GetId()),
            utility.LoadResourceSync(prefabName, typeof(UnityEngine.GameObject)),
            maxInstances,
            kPoolTag_Battle,
            ResCtrl.SpawnPool.LimitMode.Normal
        ):PreloadInstances(maxInstances)
        ----<<<<
        passedCount = passedCount + 1
        ProgressBarUtils.Display("正在突破次元壁","正在加载场景资源...", passedCount / totalCount)
        coroutine.step(1)
    end

    ----
    for i = passedCount, totalCount do
        ProgressBarUtils.Display("正在突破次元壁","正在加载场景资源...", i / totalCount)
        coroutine.wait(0.5)
    end

    ProgressBarUtils.Clear()

    InitBattleNode(self)
end

-- function BattleScene:DestroyAllBattleResources()
--     -- 释放池&实例
--     self:GetGame():GetPoolManager():DestroyPoolsByTag(kPoolTag_Battle)

--     -- 释放预制体
--     -- 获取人物资源数组([{id, count}])
--     local array = self:GetBattleUnitPreloadSet()
--     for i = 1, #array do
--         local unit = array[i]
--         local resPathMgr = require "StaticData.ResPath"
--         local prefabName = resPathMgr:GetData(unit:GetId()):GetPath()
--         utility.UnloadResource(prefabName, typeof(UnityEngine.GameObject))
--         debug_print("@@ 释放资源 @@", id, prefabName)
--     end
-- end

function BattleScene:OnEnter()
    BattleScene.base.OnEnter(self)

    -- 设置当前阶段为战斗
    local GamePhase = require "Game.GamePhase"
    self:GetGame():SetGamePhase(GamePhase.Battle)

    -- 首先将战斗UI显示 并且 关闭MainUI的UI模式 --
    self.uiManager = self:GetGame():GetUIManager()
    self.uiManager:GetBattleUICanvas():ShowRoot()
    self.uiManager:GetMainUICanvas():SetUIMode(false)

    self:GetAudioManager():SaveBGM()
    self:GetAudioManager():FadeOutBGM(2)

    self:StartCoroutine(LoadBattleScene)
end

function BattleScene:OnExit()
    BattleScene.base.OnExit(self)

    self:GetAudioManager():ReplayBGM()
	
    -- 设置当前阶段为大厅 --
    local GamePhase = require "Game.GamePhase"
    self:GetGame():SetGamePhase(GamePhase.Lobby)

    -- 关闭战斗UI 并且 打开MainUI的UI模式 --
    self.uiManager:GetBattleUICanvas():HideRoot()
    self.uiManager:GetMainUICanvas():SetUIMode(true)
end

function BattleScene:OnCleanup()
    if not BattleScene.base.OnCleanup(self) then
        self:ForceCollectionGarbage()
    end
end

function BattleScene:GetRootHangingPoint()
    return nil
end

return BattleScene
