
local WindowNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local messageGuids = require "Framework.Business.MessageGuids"
local net = require "Network.Net"

local BattleExitFightModule = Class(WindowNodeClass)

-- # 设置为唯一 # --
windowUtility.SetMutex(BattleExitFightModule, true)

function BattleExitFightModule:Ctor()
    self.coExitProtocolTimeout = nil
end

-- 指定为Module层!
function BattleExitFightModule:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
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

    -- 显示文本
    self.InfoLabel = transform:Find("Base/InfoLabel"):GetComponent(typeof(UnityEngine.UI.Text))
end


-- 停止超时
local function StopProtocolTimeout(self)
    if self.coExitProtocolTimeout ~= nil then
        self:StopCoroutine(self.coExitProtocolTimeout)
        self.coExitProtocolTimeout = nil
    end
end

-- 超时处理逻辑
local function OnProtocolTimeout(self)
    self.InfoLabel.text = "退出战斗失败, 请点击按钮重试"
    self.ConfirmButton.interactable = true
    self.CloseButton.interactable = true
end

local function _CoProtocolTimeout(self)
    local s = UnityEngine.Time.realtimeSinceStartup
    while(true)
    do
        coroutine.step()
        local t = UnityEngine.Time.realtimeSinceStartup - s
        if t >= 50 then
            break
        end
    end
    StopProtocolTimeout(self)
    OnProtocolTimeout(self)
end

local function StartProtocolTimout(self)
    StopProtocolTimeout(self)
    self.coExitProtocolTimeout = self:StartCoroutine(_CoProtocolTimeout)
end

-- 发送协议
local function SendNetworkProtocol(self)
    local ServerService = require "Network.ServerService"
    self:GetGame():SendNetworkMessage(ServerService.FightSignOutQueryRequest())
    self.InfoLabel.text = "正在退出战斗..."
    self.ConfirmButton.interactable = false
    self.CloseButton.interactable = false
    StartProtocolTimout(self)
end

local function OnConfirmButtonClicked(self)
    debug_print("确定!")
    SendNetworkProtocol(self)
end

local function OnCloseButtonClicked(self)
    self:Close(true)
end

local function OnFightSignOutQueryResponse(self)
    debug_print(">>>>>>>>>>>>>>>>>>>>>>>>>>> OnFightSignOutQueryResponse")
    StopProtocolTimeout(self)
    -- 关闭界面, 发送event.
    self:DispatchEventReversely(messageGuids.BattleExitFight, nil)
    self:Close(true)
end

local function RegisterEvents(self)
    -- 注册 ConfirmButton 事件
    self.__event_confirmbutton_onButtonClicked__ = UnityEngine.Events.UnityAction(OnConfirmButtonClicked, self)
    self.ConfirmButton.onClick:AddListener(self.__event_confirmbutton_onButtonClicked__)

    -- 注册 CloseButton 事件
    self.__event_closebutton_onButtonClicked__ = UnityEngine.Events.UnityAction(OnCloseButtonClicked, self)
    self.CloseButton.onClick:AddListener(self.__event_closebutton_onButtonClicked__)

    self:GetGame():RegisterMsgHandler(net.S2CFightSignOutQueryResult, self, OnFightSignOutQueryResponse)
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

    self:GetGame():UnRegisterMsgHandler(net.S2CFightSignOutQueryResult, self, OnFightSignOutQueryResponse)
end


-----------------------------------------------------------------------
--- 事件
-----------------------------------------------------------------------

function BattleExitFightModule:OnInit()
    -- 加载界面(只走一次)
    utility.LoadNewGameObjectAsync("UI/Prefabs/BattleExitFight", function(go)
		self:BindComponent(go)
	end)
end

function BattleExitFightModule:OnComponentReady()
    -- 界面加载完毕 初始化函数(只走一次)
    InitControls(self)
end

function BattleExitFightModule:OnResume()
    BattleExitFightModule.base.OnResume(self)
    RegisterEvents(self)

    self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)
        transform.localScale = Vector3(s, s, s)
    end)
end

function BattleExitFightModule:OnPause()
    BattleExitFightModule.base.OnPause(self)
    UnregisterEvents(self)
end

-----------------------------------------------------------------------
--- 动画
-----------------------------------------------------------------------
function BattleExitFightModule:IsTransition()
    return true
end

function BattleExitFightModule:OnExitTransitionDidStart(immediately)
    BattleExitFightModule.base.OnExitTransitionDidStart(self, immediately)
    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans
            local TweenUtility = require "Utils.TweenUtility"
            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

return BattleExitFightModule
