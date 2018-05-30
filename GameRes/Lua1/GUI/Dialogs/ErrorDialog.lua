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

local ErrorDialog = Class(WindowNodeClass)

-- ### 表示这个窗口只能同时弹出1个
 windowUtility.SetMutex(ErrorDialog, true)

function ErrorDialog:OnInit()
    -- 加载 登录界面
    utility.LoadNewGameObjectAsync('UI/Prefabs/ErrorDialog', function(go)
        self:BindComponent(go)
    end)
end

function ErrorDialog:GetRootHangingPoint()
    return self:GetUIManager():GetDialogLayer()
end

function ErrorDialog:OnWillShow(text,table,callBack)
    self.msgText = text
    print(callBack,text,type(table))
    if callBack ~=nil then
        self.callBack=LuaDelegate.New()
        self.callBack:Set(table, callBack)
    end
   
end

function ErrorDialog:OnComponentReady()
    local transform = self:GetUnityTransform()
    self.tweenObjectTrans = transform:Find("TweenObject")


    self.Button = transform:Find('TweenObject/Button'):GetComponent(typeof(UnityEngine.UI.Button))
    self.Text = transform:Find('TweenObject/Text'):GetComponent(typeof(UnityEngine.UI.Text))

    --背景按钮
    self.BackgroundButton = transform:Find('Background'):GetComponent(typeof(UnityEngine.UI.Button))
end

function ErrorDialog:OnResume()
    ErrorDialog.base.OnResume(self)
    -- 设置文字
    self.Text.text = self.msgText
--    print('OnResume')
    self:RegisterControlEvents()
    self:BringToFront()

    -- # 这里注册即可!!
--    self:ScheduleUpdate(self.Update)

    self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans

        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)

    
end

function ErrorDialog:OnPause()
    ErrorDialog.base.OnPause(self)
--    print('OnPause')
    self:UnregisterControlEvents()
end

function ErrorDialog:RegisterControlEvents()
    -- 注册 Button 的事件
    self.__event_button_onButtonClicked__ = UnityEngine.Events.UnityAction(function() self:OnButtonClicked() end)
    self.Button.onClick:AddListener(self.__event_button_onButtonClicked__)

    -- 注册 BackgroundButton 的事件
    self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(function() self:OnReturnButtonClicked() end)
    self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

--    self:UnregisterControlEvents()
end

function ErrorDialog:UnregisterControlEvents()
    -- 取消注册 Button 的事件
    if self.__event_button_onButtonClicked__ then
        self.Button.onClick:RemoveListener(self.__event_button_onButtonClicked__)
        self.__event_button_onButtonClicked__ = nil
    end
    -- 取消注册 BackgroundButton 的事件
    if self.__event_backgroundButton_onButtonClicked__ then
        self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
        self.__event_backgroundButton_onButtonClicked__ = nil
    end
end

function ErrorDialog:OnButtonClicked()
    print('OnButtonClicked!')
    if  self.callBack ~=nil then
        self.callBack:Invoke(self)
    end
    self:Close(true)
end

function ErrorDialog:OnReturnButtonClicked()
    self:Close()
end

-----------------------------------------------------------------------
--- 动画相关
-----------------------------------------------------------------------
function ErrorDialog:IsTransition()
    return true
end

-- ## 在这里执行 淡出函数! (immediately 值只针对 WindowNode 及其子类)
function ErrorDialog:OnExitTransitionDidStart(immediately)
    ErrorDialog.base.OnExitTransitionDidStart(self, immediately)

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
--function ErrorDialog:Update()
--    self:OnAnimationUpdate()
--end

return ErrorDialog