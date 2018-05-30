
-----------------------------------------------------------------------
--- 测试对话框!!
-----------------------------------------------------------------------
local WindowNodeClass = require "Framework.Base.WindowNode"
local windowUtility = require "Framework.Window.WindowUtility"
local utility = require "Utils.Utility"

local TestDialog = Class(WindowNodeClass)

-- ### 表示这个窗口只能同时弹出1个
windowUtility.SetMutex(TestDialog, true)

-- ### 这种对话框最多同时弹n个
--windowUtility.SetMutex(TestDialog, 2)

-- ### 这种对话框最多同时弹n个
--windowUtility.SetMutex(TestDialog, function() return 2 end)

-- ### 不写SetMutex或ResetMutex 表示 这种对话框不限制弹出数量
--windowUtility.ResetMutex(TestDialog)

function TestDialog:Ctor()
end

function TestDialog:OnInit()
    -- 加载 登录界面
    utility.LoadNewGameObjectAsync('UI/Prefabs/TestDialog', function(go)
        self:BindComponent(go)
        --        self:DoSomething()
    end)
end

function TestDialog:OnWillShow(text)
    self.msgText = text
end

-- 可以指定层!
--function TestDialog:GetRootHangingPoint()
--    return self:GetUIManager():GetModuleLayer()
--end

function TestDialog:OnExit()
    TestDialog.base.OnExit(self)
    self:UnregisterControlEvents()
end

function TestDialog:InitControls()
    local transform = self:GetUnityTransform()
    self.tweenObjectTrans = transform:Find("TweenObject")

    self.testButton = transform:Find("TweenObject/Button"):GetComponent(typeof(UnityEngine.UI.Button))
    self.ButtonText = transform:Find("TweenObject/Button/Text"):GetComponent(typeof(UnityEngine.UI.Text))
end

function TestDialog:RegisterControlEvents()
    self.__event_button_onEnterButtonClicked__ = UnityEngine.Events.UnityAction(self.OnEnterButtonClicked, self)
    self.testButton.onClick:AddListener(self.__event_button_onEnterButtonClicked__)
end

function TestDialog:UnregisterControlEvents()
    if self.__event_button_onEnterButtonClicked__ then
        self.testButton.onClick:RemoveListener(self.__event_button_onEnterButtonClicked__)
        self.__event_button_onEnterButtonClicked__ = nil
    end
end

-----------------------------------------------------------------------
--- 动画相关
-----------------------------------------------------------------------
-- ## 关闭对话框测试
function TestDialog:OnEnterButtonClicked()
    self:Hide()
end

-- ## 打开时 有动画
function TestDialog:IsEnterTransition()
    return true
end

-- ## 关闭时 有动画
function TestDialog:IsExitTransition()
    return true
end

-- 设置 淡入或淡出的 时间(默认为 0.3, 0.25)
--function TestDialog:GetFadeInTotalTime()
--    return 0.3
--end
--
--function TestDialog:GetFadeOutTotalTime()
--    return 0.25
--end

-- ## 在里面注册Update函数 和 调用FadeIn函数
function TestDialog:OnComponentReady()
    self:InitControls()
end

function TestDialog:OnPause()
    TestDialog.base.OnPause(self)
end
function TestDialog:OnResume()
    TestDialog.base.OnResume(self)

--  层次修改测试!!
--    local transform = self:GetUnityTransform()
--    transform:SetAsLastSibling()

    self:RegisterControlEvents()

--    self.ButtonText.text = self.msgText

    self.ButtonText.text = "dasdasdassdaddsasdasdsadsadasdsadasdsasdsadadassdadada"
    print('height', self.ButtonText.preferredHeight)

    --
--    -- # 这里注册即可!!
--    self:ScheduleUpdate(self.Update)

    self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans

--        print('fade t = ',t)
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
end

-- ## 在这里执行 淡出函数! (immediately 值只针对 WindowNode 及其子类)
function TestDialog:OnExitTransitionDidStart(immediately)
    TestDialog.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

return TestDialog

