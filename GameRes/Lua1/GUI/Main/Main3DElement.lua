--
-- User: fenghao
-- Date: 12/06/2017
-- Time: 4:05 PM
--

local UINodeClass = require "Framework.Base.UINode"

local Main3DElement = Class(UINodeClass)

local utility = require "Utils.Utility"

local function InitControls(self)
    print("对象名: ", self.sceneElementTransform.name)
    self.sceneElementButton = self.sceneElementTransform:GetComponent(typeof(ScreenElementButton))
    self.bubbleButton = self.bubbleTransform:GetComponent(typeof(UnityEngine.UI.Button))
    self.bubbleCanvasGroup = self.bubbleTransform:GetComponent(typeof(UnityEngine.CanvasGroup))
end

function Main3DElement:Ctor(sceneElementTransform, bubbleTransform, offset, startRatio, endRatio, messageGuid)
    self.messageGuid = messageGuid
    self.sceneElementTransform = sceneElementTransform
    self.bubbleTransform = bubbleTransform
    self.bubbleObject = self.bubbleTransform.gameObject
    self.offset = offset
    self.startRatio = startRatio
    self.endRatio = endRatio
    self:BindComponent(self.bubbleTransform.gameObject, false)
    InitControls(self)
end

-- 点击事件处理 --
local function OnSceneElementClicked(self)
    print(self.messageGuid)
    self:DispatchEvent(self.messageGuid, nil)
end

function Main3DElement:OnResume()
    Main3DElement.base.OnResume(self)

    -- 注册 sceneElementButton 事件
    self.__event_sceneElementButtonClicked__ = UnityEngine.Events.UnityAction(OnSceneElementClicked, self)
    self.sceneElementButton.onClick:AddListener(self.__event_sceneElementButtonClicked__)

    -- 注册 bubbleButton 事件
    self.bubbleButton.onClick:AddListener(self.__event_sceneElementButtonClicked__)
end

function Main3DElement:OnPause()
    Main3DElement.base.OnPause(self)

    if self.__event_sceneElementButtonClicked__ then
        -- 取消注册 sceneElementButton 事件
        self.sceneElementButton.onClick:RemoveListener(self.__event_sceneElementButtonClicked__)

        -- 取消注册 bubbleButton 事件
        self.bubbleButton.onClick:RemoveListener(self.__event_sceneElementButtonClicked__)

        self.__event_sceneElementButtonClicked__ = nil
    end
end

function Main3DElement:Update(camera, ratio)

    local t

    if self.startRatio == self.endRatio then
        t = 1
    else
        t = utility.NormValue(ratio, self.startRatio, self.endRatio)
        t = math.abs(t-0.5)*2   -->  \/
        t = 1 - t               -->  /\
    end

    local visible = t > 0

    self.bubbleCanvasGroup.alpha = t
    self.bubbleCanvasGroup.interactable = visible
    self.bubbleCanvasGroup.blocksRaycasts = visible
    if not visible then
        return
    end

    local screenPoint = camera:WorldToScreenPoint(self.sceneElementTransform.position)
    local uiCamera = self:GetUIManager():GetMainUICanvas():GetCamera()
    local _, worldPosition = UnityEngine.RectTransformUtility.ScreenPointToWorldPointInRectangle(self.bubbleTransform, screenPoint, uiCamera, nil)
    self.bubbleTransform.position = worldPosition
    local pos = self.bubbleTransform.anchoredPosition
    pos.x = pos.x + self.offset.x
    pos.y = pos.y + self.offset.y
    self.bubbleTransform.anchoredPosition = pos
end

return Main3DElement