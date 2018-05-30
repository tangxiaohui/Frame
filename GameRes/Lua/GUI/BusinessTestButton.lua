
local BaseNodeClass = require "Framework.Base.Node"
--local utility = require "Utils.Utility"
require "System.LuaDelegate"

local BusinessTestButton = Class(BaseNodeClass)

function BusinessTestButton:Ctor(title, prefab, parentTransform)
    self.title = title
    self.callback = LuaDelegate.New()
    self.parentTransform = parentTransform
    local go = UnityEngine.Object.Instantiate(prefab)
    self:BindComponent(go, false)
end

function BusinessTestButton:SetCallback(table, func)
    self.callback:Set(table, func)
end

function BusinessTestButton:OnComponentReady()
    self:LinkComponent(self.parentTransform)

    self:InitControls()
end

function BusinessTestButton:InitControls()
    local transform = self:GetUnityTransform()

    self.Button = transform:GetComponent(typeof(UnityEngine.UI.Button))
    self.Text = transform:Find("Text"):GetComponent(typeof(UnityEngine.UI.Text))
    self.Text.text = self.title
end

function BusinessTestButton:OnResume()
    BusinessTestButton.base.OnResume(self)

    self:RegisterControlEvents()
end

function BusinessTestButton:OnPause()
    BusinessTestButton.base.OnPause(self)
    self:UnregisterControlEvents()
end

function BusinessTestButton:RegisterControlEvents()
    -- 注册 Button 的事件
    self.__event_button_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnButtonClicked, self)
    self.Button.onClick:AddListener(self.__event_button_onButtonClicked__)
end

function BusinessTestButton:UnregisterControlEvents()
    -- 取消注册 Button 的事件
    if self.__event_button_onButtonClicked__ then
        self.Button.onClick:RemoveListener(self.__event_button_onButtonClicked__)
        self.__event_button_onButtonClicked__ = nil
    end
end

function BusinessTestButton:OnButtonClicked()
    self.callback:Invoke()
end

return BusinessTestButton
