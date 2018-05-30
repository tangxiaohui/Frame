--
-- User: fbmly
-- Date: 3/25/17
-- Time: 3:52 PM
--

-----------------------------------------------------------------------
--- 错误信息对话框!
-----------------------------------------------------------------------

local WindowNodeClass = require "Framework.Base.WindowNode"
local windowUtility = require "Framework.Window.WindowUtility"
local utility = require "Utils.Utility"
require "System.LuaDelegate"

local ConfirmBuyDialog = Class(WindowNodeClass)

-- ### 表示这个窗口只能同时弹出1个
windowUtility.SetMutex(ConfirmBuyDialog, true)

function ConfirmBuyDialog:Ctor()
    self.confirmCallback = LuaDelegate.New()
    self.cancelCallback = LuaDelegate.New()
end

function ConfirmBuyDialog:OnInit()
    -- 加载 登录界面
    utility.LoadNewGameObjectAsync('UI/Prefabs/ConfirmDialong', function(go)
        self:BindComponent(go)
    end)
end

function ConfirmBuyDialog:GetRootHangingPoint()
    return self:GetUIManager():GetDialogLayer()
end

function ConfirmBuyDialog:OnWillShow(text, table, confirmFunc, cancelFunc ,args)
    self.msgText = text
    print(type(table))
    utility.ASSERT(type(table) == "table","参数 table 必须是 table 类型!")
    utility.ASSERT(type(confirmFunc) == "function","参数 confirmFunc 必须是 function 类型!")
    self.confirmCallback:Set(table, confirmFunc)

    -- cancel 是可选的 --
    self.cancelCallback:Clear()
    if type(cancelFunc) == "function" then
        self.cancelCallback:Add(table, cancelFunc)
    end
    self.args = args
end

function ConfirmBuyDialog:OnComponentReady()
    local transform = self:GetUnityTransform()
    self.tweenObjectTrans = transform:Find("TweenObject")


    self.Button = transform:Find('TweenObject/Button'):GetComponent(typeof(UnityEngine.UI.Button))
    self.ConfirmButton =  transform:Find('TweenObject/ConfirmButton'):GetComponent(typeof(UnityEngine.UI.Button))
    self.Text = transform:Find('TweenObject/Text'):GetComponent(typeof(UnityEngine.UI.Text))

    --背景按钮
    self.BackgroundButton = transform:Find('Background'):GetComponent(typeof(UnityEngine.UI.Button))
end

function ConfirmBuyDialog:OnResume()
    ConfirmBuyDialog.base.OnResume(self)
    -- 设置文字
    self.Text.text = self.msgText
--    print('OnResume')
    self:RegisterControlEvents()
    self:GetUnityTransform():SetAsLastSibling()

    -- # 这里注册即可!!
--    self:ScheduleUpdate(self.Update)

    self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans

        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
end

function ConfirmBuyDialog:OnPause()
    ConfirmBuyDialog.base.OnPause(self)
--    print('OnPause')
    self:UnregisterControlEvents()
end

function ConfirmBuyDialog:RegisterControlEvents()
    -- 注册 Button 的事件
    self.__event_button_onButtonClicked__ = UnityEngine.Events.UnityAction(function() self:OnButtonClicked() end)
    self.Button.onClick:AddListener(self.__event_button_onButtonClicked__)

    self.__event_button_onConfirmButtonClicked__ = UnityEngine.Events.UnityAction(function() self:OnConfirmButtonClicked() end)
    self.ConfirmButton.onClick:AddListener(self.__event_button_onConfirmButtonClicked__)

    -- 注册 BackgroundButton 的事件
    self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnButtonClicked,self)
    self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

--    self:UnregisterControlEvents()
end

function ConfirmBuyDialog:UnregisterControlEvents()
    -- 取消注册 Button 的事件
    if self.__event_button_onButtonClicked__ then
        self.Button.onClick:RemoveListener(self.__event_button_onButtonClicked__)
        self.__event_button_onButtonClicked__ = nil
    end

    if self.__event_button_onConfirmButtonClicked__ then
        self.ConfirmButton.onClick:RemoveListener(self.__event_button_onConfirmButtonClicked__)
        self.__event_button_onConfirmButtonClicked__ = nil
    end

    -- 取消注册 BackgroundButton 的事件
    if self.__event_backgroundButton_onButtonClicked__ then
       self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
       self.__event_backgroundButton_onButtonClicked__ = nil
    end
end

function ConfirmBuyDialog:OnButtonClicked()
    self.cancelCallback:Invoke()
    self:Hide(true)
end

function ConfirmBuyDialog:OnConfirmButtonClicked()
    self.confirmCallback:Invoke(self.args)
    self:Hide(true)
end

-----------------------------------------------------------------------
--- 动画相关
-----------------------------------------------------------------------
function ConfirmBuyDialog:IsTransition()
    return true
end

-- ## 在这里执行 淡出函数! (immediately 值只针对 WindowNode 及其子类)
function ConfirmBuyDialog:OnExitTransitionDidStart(immediately)
    ConfirmBuyDialog.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

---- ## 调用基类的函数 可以执行 淡入淡出操作!
--function ConfirmDialong:Update()
--    self:OnAnimationUpdate()
--end

return ConfirmBuyDialog