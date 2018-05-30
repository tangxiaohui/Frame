--
-- User: fbmly
-- Date: 5/5/17
-- Time: 3:30 PM
--

local BaseNodeClass = require "Framework.Base.Node"
require "System.LuaDelegate"

local ToggleNode = Class(BaseNodeClass)

local function Dispatch(self)
    self.callback:Invoke(self)
end

function ToggleNode:Ctor(transform, group, tag)
    self:BindComponent(transform.gameObject, false)
    self:InitControls()

    -- 初始化状态参数 --
    self.toggleGroup = group
    self.toggleTag = tag
    self.callback = LuaDelegate.New()
    self.selected = false
end

function ToggleNode:InitControls()
    local transform = self:GetUnityTransform()
    self.mainButton = transform:GetComponent(typeof(UnityEngine.UI.Button))
end

local function OnMainButtonClicked(self)
    self:SetSelect(true)
end

function ToggleNode:OnResume()
    ToggleNode.base.OnResume(self)

    -- 注册按钮事件
    self.__event_button_mainButtonClicked__ = UnityEngine.Events.UnityAction(OnMainButtonClicked, self)
    self.mainButton.onClick:AddListener(self.__event_button_mainButtonClicked__)
end

function ToggleNode:OnPause()
    ToggleNode.base.OnPause(self)

    -- 取消注册按钮事件
    if self.__event_button_mainButtonClicked__ then
        self.mainButton.onClick:RemoveListener(self.__event_button_mainButtonClicked__)
        self.__event_button_mainButtonClicked__ = nil
    end
end

function ToggleNode:SetCallback(table, func)
    self.callback:Set(table, func)
end

function ToggleNode:SetSelect(isSelect)
    if self.selected ~= isSelect then
        self.selected = isSelect
        Dispatch(self)
        return true
    end
    return false
end

function ToggleNode:IsSelected()
    return self.selected
end

function ToggleNode:Dispatch()
    Dispatch(self)
end

function ToggleNode:GetGroup()
    return self.toggleGroup
end

function ToggleNode:GetTag()
    return self.toggleTag
end

return ToggleNode