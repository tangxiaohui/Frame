--
-- User: fenghao
-- Date: 26/06/2017
-- Time: 12:26 AM
--

local NodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
local messageGuids = require "Framework.Business.MessageGuids"

local BattleSkillBubbleNode = Class(NodeClass)

local function InitControls(self)
    local transform = self:GetUnityTransform()
    self.label = transform:Find("Label"):GetComponent(typeof(UnityEngine.UI.Text))
end

function BattleSkillBubbleNode:Ctor(transform)
    self:BindComponent(transform.gameObject, false)
    InitControls(self)

end

local function DelayHideBubble(self)
    coroutine.wait(0.5)
    self:InactiveComponent()
end

local function GetCurrentCamera(unit)
    local battlefield = unit:GetBattlefield()
    local worldCameraObject = battlefield:GetCurrentCamera()
    if worldCameraObject ~= nil then
        return worldCameraObject:GetComponent(typeof(UnityEngine.Camera))
    end
    return nil
end

local function Reposition(self, unit)
    local gameObject = unit:GetGameObject()
    local worldCamera = GetCurrentCamera(unit)
    local transform = gameObject.transform:Find("Dummy002")

    if worldCamera == nil or transform == nil then
        return false
    end

    local screenPoint = worldCamera:WorldToScreenPoint(transform.position)
    local uiCamera = self:GetUIManager():GetMainUICanvas():GetCamera()

    local bubbleTransform = self:GetUnityTransform()

    local _, worldPosition = UnityEngine.RectTransformUtility.ScreenPointToWorldPointInRectangle(bubbleTransform, screenPoint, uiCamera, nil)

    bubbleTransform.position = worldPosition
    local pos = bubbleTransform.localPosition
    pos.z = 0
    bubbleTransform.localPosition = pos
    return true
end

local function OnBattleShowSkillBubble(self, unit, text)
    if Reposition(self, unit) then
        self.label.text = text
        self:ActiveComponent()
        self:StartCoroutine(DelayHideBubble)
    end
end

function BattleSkillBubbleNode:OnResume()
    self:RegisterEvent(messageGuids.BattleShowSkillBubble, OnBattleShowSkillBubble, nil)
end

function BattleSkillBubbleNode:OnPause()
    self:UnregisterEvent(messageGuids.BattleShowSkillBubble, OnBattleShowSkillBubble, nil)
end

return BattleSkillBubbleNode
