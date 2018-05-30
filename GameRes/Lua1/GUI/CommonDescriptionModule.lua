--
-- User: fenghao
-- Date: 5/29/17
-- Time: 12:58 PM
--

local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"

local CommonDescriptionModule = Class(BaseNodeClass)

function CommonDescriptionModule:Ctor()
    self.content = nil
end

function CommonDescriptionModule:OnWillShow(content)
    self.content = content
end

-- 子可以重载挂点!!
function CommonDescriptionModule:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end


-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function CommonDescriptionModule:OnInit()
    -- 加载界面(只走一次)
    utility.LoadNewGameObjectAsync('UI/Prefabs/CommonDescriptionDialog', function(go)
        self:BindComponent(go)
    end)
end

function CommonDescriptionModule:OnComponentReady()
    -- 界面加载完毕 初始化函数(只走一次)
    self:InitControls()
end

local function DelaySetScrollView(self)
    coroutine.step(2)
    self.ScrollView.verticalNormalizedPosition = 1
end

local function SetControls(self)
    if type(self.content) == "string" then
        self.ContentLabel.text = self.content
    else
        self.ContentLabel.text = ""
    end

    self:StartCoroutine(DelaySetScrollView)
end

local function ResetControls(self)
    self.ContentLabel.text = ""
end

function CommonDescriptionModule:OnResume()
    CommonDescriptionModule.base.OnResume(self)
    self:RegisterControlEvents()
    SetControls(self)

    self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)
        transform.localScale = Vector3(s, s, s)
    end)
end

function CommonDescriptionModule:OnExitTransitionDidStart(immediately)
    CommonDescriptionModule.base.OnExitTransitionDidStart(self, immediately)
    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans
            local TweenUtility = require "Utils.TweenUtility"
            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function CommonDescriptionModule:IsTransition()
    return true
end

function CommonDescriptionModule:OnPause()
    CommonDescriptionModule.base.OnPause(self)
    self:UnregisterControlEvents()
    ResetControls(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function CommonDescriptionModule:InitControls()
    local transform = self:GetUnityTransform()
    self.tweenObjectTrans = transform:Find("TweenObject")
    self.DescriptionButton = transform:Find("TweenObject/DescriptionButton"):GetComponent(typeof(UnityEngine.UI.Button))
    self.ScrollView = transform:Find("TweenObject/Scroll View"):GetComponent(typeof(UnityEngine.UI.ScrollRect))
    self.ContentLabel = transform:Find("TweenObject/Scroll View/Viewport/Content/Label"):GetComponent(typeof(UnityEngine.UI.Text))
    --背景按钮
    self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))
end

function CommonDescriptionModule:RegisterControlEvents()
    -- 注册 DescriptionButton 的事件
    self.__event_button_onDescriptionButtonClicked__ = UnityEngine.Events.UnityAction(self.OnDescriptionButtonClicked, self)
    self.DescriptionButton.onClick:AddListener(self.__event_button_onDescriptionButtonClicked__)
        -- 注册 BackgroundButton 的事件
    self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnDescriptionButtonClicked,self)
    self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)
end

function CommonDescriptionModule:UnregisterControlEvents()
    -- 取消注册 DescriptionButton 的事件
    if self.__event_button_onDescriptionButtonClicked__ then
        self.DescriptionButton.onClick:RemoveListener(self.__event_button_onDescriptionButtonClicked__)
        self.__event_button_onDescriptionButtonClicked__ = nil
    end
        -- 取消注册 BackgroundButton 的事件
    if self.__event_backgroundButton_onButtonClicked__ then
       self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
       self.__event_backgroundButton_onButtonClicked__ = nil
    end

end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function CommonDescriptionModule:OnDescriptionButtonClicked()
    --DescriptionButton控件的点击事件处理
    self:Close(false)
end

return CommonDescriptionModule

