--
-- User: fenghao
-- Date: 5/29/17
-- Time: 2:03 PM
--

local BaseNodeClass = require "GUI.BattleResults.BaseBattleResultModule"
local utility = require "Utils.Utility"

local ProtectFightingResultModule = Class(BaseNodeClass)

function ProtectFightingResultModule:Ctor()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function ProtectFightingResultModule:OnInit()
    -- 加载界面(只走一次)
    utility.LoadNewGameObjectAsync('UI/Prefabs/ProtectFightingResultModule', function(go)
        self:BindComponent(go)
    end)
end

function ProtectFightingResultModule:OnComponentReady()
    -- 界面加载完毕 初始化函数(只走一次)
    self:InitControls()
end

local function SetControls(self)
    local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)

    self.lvLabel.text = userData:GetLevel()

    -- # 当前经验值
    local currentExp = userData:GetExp()
    local maxExp = utility.GetLevelIntervalExp(userData:GetLevel())

    self.expLabel.text = string.format("%d/%d", currentExp, maxExp)

    -- # 当前经验条
    self.expSlider.fillAmount = utility.Clamp01(currentExp / maxExp)
end

function ProtectFightingResultModule:OnResume()
    ProtectFightingResultModule.base.OnResume(self)

    self:RegisterControlEvents()


    self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans

        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)

    SetControls(self)
end

function ProtectFightingResultModule:OnPause()
    ProtectFightingResultModule.base.OnPause(self)

    self:UnregisterControlEvents()
end

function ProtectFightingResultModule:IsTransition()
    return true
end

function ProtectFightingResultModule:OnExitTransitionDidStart(immediately)
    ProtectFightingResultModule.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function ProtectFightingResultModule:RegisterControlEvents()
    -- 注册 Button 的事件
    self.__event_button_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnButtonClicked, self)
    self.Button.onClick:AddListener(self.__event_button_onButtonClicked__)

        -- 注册 BackgroundButton 的事件
    self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnButtonClicked,self)
    self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)
end

function ProtectFightingResultModule:UnregisterControlEvents()
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


-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function ProtectFightingResultModule:InitControls()
    local transform = self:GetUnityTransform()
    self.tweenObjectTrans = transform:Find('TweenObject')

    -- 胜利
    self.winTrans = transform:Find('TweenObject/Win')
--    self.winObject = self.winTrans.gameObject
    self.lvLabel = self.winTrans:Find("Lv/FightingSettlementLvLabel"):GetComponent(typeof(UnityEngine.UI.Text))
    self.expLabel = self.winTrans:Find("FightingSettlementExpSlider/NumLabel"):GetComponent(typeof(UnityEngine.UI.Text))
    self.expSlider = self.winTrans:Find("FightingSettlementExpSlider/Mask/FillFrame"):GetComponent(typeof(UnityEngine.UI.Image))
    --背景按钮
    self.BackgroundButton = transform:Find('Background'):GetComponent(typeof(UnityEngine.UI.Button))
    -- 关闭按钮
    self.Button = transform:Find('TweenObject/CloseButton'):GetComponent(typeof(UnityEngine.UI.Button))
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function ProtectFightingResultModule:OnButtonClicked()
    print("ProtectFightingResultModule::OnButtonClicked > 1")
    self:Close(true)
    self:DispatchCloseEvent()
end

return ProtectFightingResultModule