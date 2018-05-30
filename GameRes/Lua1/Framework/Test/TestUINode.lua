local UINodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"

local TestUINode = Class(UINodeClass)

local function LoadPrefabInternal(prefabName)
    local Object = UnityEngine.Object
    local gameObject = Object.Instantiate(utility.LoadResourceSync(prefabName, typeof(UnityEngine.GameObject)))
    local canvasGroup = gameObject:GetComponent(typeof(UnityEngine.CanvasGroup))
    if canvasGroup == nil then
        gameObject:AddComponent(typeof(UnityEngine.CanvasGroup))
    end
    return gameObject
end

function TestUINode:Ctor()
end

function TestUINode:OnEnter()
    TestUINode.base.OnEnter(self)

    -- 创建绑定
    local gameObject = LoadPrefabInternal("Prefabs/TestPanel")
    self:BindComponent(gameObject)

    local label = self:GetUnityTransform():Find("Label"):GetComponent(typeof(UnityEngine.UI.Text))
    label.text = "Hello World!"
    self.labelCtl = label
    self.tempNumber = nil

    -- 注册
    -- self:ScheduleLateUpdate(self.Update1)

end

function TestUINode:OnExit()
    TestUINode.base.OnExit(self)
    self.tempNumber = nil
end


function TestUINode:Update1()
    print('Update1--- frame count', UnityEngine.Time.frameCount)
    local tempNumber = self.tempNumber or 0
    self.labelCtl.text = tostring(tempNumber)
    tempNumber = tempNumber + 1
    self.tempNumber = tempNumber

    if tempNumber > 1000 then
        local myGame = require "Utils.Utility".GetGame()
        local sceneManager = myGame:GetSceneManager()
        sceneManager:ReplaceScene(self:GetParent())
    end
end

return TestUINode
