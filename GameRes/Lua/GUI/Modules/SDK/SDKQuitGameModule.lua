
local BaseNodeClass =  require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"

local SDKQuitGameModule = Class(BaseNodeClass)

-- ### 表示这个窗口只能同时弹出1个
windowUtility.SetMutex(SDKQuitGameModule, true)

function SDKQuitGameModule:GetRootHangingPoint()
    return self:GetUIManager():GetOverlayLayer()
end

-----------------------------------------------------------------------
--- 私有函数
-----------------------------------------------------------------------
local function InitControls(self)
    local transform = self:GetUnityTransform()
    
    self.tweenObjectTrans = transform:Find('Base')

    -- 确认按钮
    self.ConfirmButton = transform:Find("Base/ConfirmButton"):GetComponent(typeof(UnityEngine.UI.Button))

    -- 取消按钮
    self.CloseButton = transform:Find("Base/CloseButton"):GetComponent(typeof(UnityEngine.UI.Button))
end

local function OnConfirmButtonClicked(self)
    UnityEngine.Application.Quit()
end

local function OnCloseButtonClicked(self)
    self:Close(true)
end

local function RegisterEvents(self)
    -- 注册 ConfirmButton 事件
    self.__event_confirmbutton_onButtonClicked__ = UnityEngine.Events.UnityAction(OnConfirmButtonClicked, self)
    self.ConfirmButton.onClick:AddListener(self.__event_confirmbutton_onButtonClicked__)

    -- 注册 CloseButton 事件
    self.__event_closebutton_onButtonClicked__ = UnityEngine.Events.UnityAction(OnCloseButtonClicked, self)
    self.CloseButton.onClick:AddListener(self.__event_closebutton_onButtonClicked__)
end

local function UnregisterEvents(self)
    -- 取消 ConfirmButton 事件
    if self.__event_confirmbutton_onButtonClicked__ then
        self.ConfirmButton.onClick:RemoveListener(self.__event_confirmbutton_onButtonClicked__)
        self.__event_confirmbutton_onButtonClicked__ = nil
    end

    -- 取消 CloseButton 事件
    if self.__event_closebutton_onButtonClicked__ then
        self.CloseButton.onClick:RemoveListener(self.__event_closebutton_onButtonClicked__)
        self.__event_closebutton_onButtonClicked__ = nil
    end
end

-----------------------------------------------------------------------
--- 事件
-----------------------------------------------------------------------
function SDKQuitGameModule:OnInit()
    -- 加载界面(只走一次)
    utility.LoadNewGameObjectAsync("UI/Prefabs/SDKQuitGame", function(go)
        self:BindComponent(go)
    end)
end

function SDKQuitGameModule:OnComponentReady()
    -- 界面加载完毕 初始化函数(只走一次)
    InitControls(self)
end

function SDKQuitGameModule:OnResume()
    SDKQuitGameModule.base.OnResume(self)
    RegisterEvents(self)

    self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)
        transform.localScale = Vector3(s, s, s)
    end)
end

function SDKQuitGameModule:OnPause()
    SDKQuitGameModule.base.OnPause(self)
    UnregisterEvents(self)
end

-----------------------------------------------------------------------
--- 动画
-----------------------------------------------------------------------
function SDKQuitGameModule:IsTransition()
    return true
end

-- ## 在这里执行 淡出函数! (immediately 值只针对 WindowNode 及其子类)
function SDKQuitGameModule:OnExitTransitionDidStart(immediately)
    SDKQuitGameModule.base.OnExitTransitionDidStart(self, immediately)
    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans
            local TweenUtility = require "Utils.TweenUtility"
            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

return SDKQuitGameModule
