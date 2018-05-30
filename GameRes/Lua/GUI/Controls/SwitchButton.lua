local BaseNodeClass = require "Framework.Base.Node"
local utility = require "Utils.Utility"
require "System.LuaDelegate"

-- 具有开和关两种状态 --

local SwitchButton = Class(BaseNodeClass)

local function InitControls(self)
    local transform = self:GetUnityTransform()
    
    self.imageOn = transform:Find("On/Icon"):GetComponent(typeof(UnityEngine.UI.Image))     -- On图片
    self.imageOff = transform:Find("Off/Icon"):GetComponent(typeof(UnityEngine.UI.Image))   -- Off图片
    self.background = transform:GetComponent(typeof(UnityEngine.UI.Image))  -- 底图
    self.button = transform:GetComponent(typeof(UnityEngine.UI.Button)) -- 按钮
end

function SwitchButton:Ctor(transform)
    self.callbackOnStateChanged = LuaDelegate.New()
    self.isOn = false
    self.isResume = false
    self:BindComponent(transform.gameObject, false)
    InitControls(self)
end

local function OnButtonClicked(self)
    self:SetOn(not self:IsOn())
end

local function RegisterEvents(self)
    -- debug_print("@RegisterEvents")
    self.__event_buttonClicked__ = UnityEngine.Events.UnityAction(OnButtonClicked, self)
    self.button.onClick:AddListener(self.__event_buttonClicked__)
end

local function UnregisterEvents(self)
    -- debug_print("@UnregisterEvents")
    if self.__event_buttonClicked__ then
        self.button.onClick:RemoveListener(self.__event_buttonClicked__)
        self.__event_buttonClicked__ = nil
    end
end


local function GetBackgroundMaterial(self)
    if self.isOn then
        return nil
    end
    return utility.GetGrayMaterial(true)
end

local function RefreshView(self)
    if self.isResume then
        self.background.material = GetBackgroundMaterial(self)
        -- 左侧是On控件, 在开的状态时, 显示左侧的On文字 和 右侧图片.
        self.imageOn.enabled = not self.isOn
        self.imageOff.enabled = self.isOn
    end
end

local function Dispatch(self)
    self.callbackOnStateChanged:Invoke(self.isOn)
end

local function OnStateChanged(self)
    RefreshView(self)
    Dispatch(self)
end

function SwitchButton:SetOn(isOn)
    if self.isOn ~= isOn then
        self.isOn = isOn
        OnStateChanged(self)
    end
end

function SwitchButton:IsOn()
    return self.isOn
end

function SwitchButton:SetCallbackOnStateChanged(t, f)
    self.callbackOnStateChanged:Set(t, f)
end

-- event for node
function SwitchButton:OnResume()
    -- SwitchButton.base.OnResume(self)
    self.isResume = true
    RefreshView(self)
    RegisterEvents(self)
end

function SwitchButton:OnPause()
    -- SwitchButton.base.OnPause(self)
    self.isResume = false
    UnregisterEvents(self)
end

return SwitchButton
