local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"
require "Const"

local ReportInfoCls = Class(BaseNodeClass)
windowUtility.SetMutex(ReportInfoCls, true)

function ReportInfoCls:Ctor()
end

function ReportInfoCls:OnWillShow(reportType,data)
	self.reportType = reportType
	self.data = data
end

function  ReportInfoCls:OnInit()
	utility.LoadNewGameObjectAsync("UI/Prefabs/BattleReport",function(go)
		self:BindComponent(go)
	end)
end

function ReportInfoCls:OnComponentReady()
	self:InitControls()
	self:LoadReportItemInfo()
end

function ReportInfoCls:OnResume()
	ReportInfoCls.base.OnResume(self)
	self:FadeIn(function(self, t)
        local transform = self.base

        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
end

function ReportInfoCls:OnPause()
	ReportInfoCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function ReportInfoCls:OnEnter()
	ReportInfoCls.base.OnEnter(self)
end

function ReportInfoCls:OnExit()
	ReportInfoCls.base.OnExit(self)
end

function ReportInfoCls:InitControls()
	local transform = self:GetUnityTransform()
	self.base = transform:Find("Base")
	self.returnButton = transform:Find("Base/CrossButton"):GetComponent(typeof(UnityEngine.UI.Button))
	--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))
	-- self.reportInfo = transform:Find("ReportInfo")
	self.reportPoint = transform:Find("Base/Scroll View/Viewport/Content")
	self.myGame = utility:GetGame()
end

----------------------------------------------------------------------------
--动画处理--
----------------------------------------------------------------------------
function ReportInfoCls:IsTransition()
    return true
end

-- ## 在这里执行 淡出函数! (immediately 值只针对 WindowNode 及其子类)
function ReportInfoCls:OnExitTransitionDidStart(immediately)
    ReportInfoCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.base

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function ReportInfoCls:RegisterControlEvents()
	self.__event_button_onReturnButtonClicked__ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked, self)
	self.returnButton.onClick:AddListener(self.__event_button_onReturnButtonClicked__)

	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)
end

function ReportInfoCls:UnregisterControlEvents()
	if self.__event_button_onReturnButtonClicked__ then
		self.returnButton.onClick:RemoveListener(self.__event_button_onReturnButtonClicked__)
		self.__event_button_onReturnButtonClicked__ = nil
	end
	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end
end

function ReportInfoCls:RegisterNetworkEvents()
	self.myGame:RegisterMsgHandler(net.FightRecordMessage, self, self.OnFightRecordResponse)
	self.myGame:RegisterMsgHandler(net.S2CGHPointFightOverResult, self, self.GHPointFightOverResult)
	self.myGame:RegisterMsgHandler(net.S2CArenaFightOverResult, self, self.ArenaFightOverResult)
	-- self.myGame:RegisterMsgHandler(net.S2CGHPointFightOverResult, self, self.GHPointFightOverResult)
end

function ReportInfoCls:UnregisterNetworkEvents()
	self.myGame:UnRegisterMsgHandler(net.FightRecordMessage, self, self.OnFightRecordResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CGHPointFightOverResult, self, self.GHPointFightOverResult)
	self.myGame:UnRegisterMsgHandler(net.S2CArenaFightOverResult, self, self.ArenaFightOverResult)
end

function ReportInfoCls:ArenaFightOverResult(msg)
	self.type = kReportArena
	self.msg = msg
end

function ReportInfoCls:GHPointFightOverResult(msg)
	self.msg = msg
	self.type = kReportGuildPointFighe
end

function ReportInfoCls:OnFightRecordResponse(msg)
	print("回放是否为空",type(msg))
	local dataCacheMgr = require "Utils.Utility".GetGame():GetDataCacheManager()
    local UserDataType = require "Framework.UserDataType"
    local playerData = dataCacheMgr:GetData(UserDataType.PlayerData)
    if msg.sourcePlayerUID == playerData:GetUid() then
    	msg.isWin = true
    else
    	msg.isWin = false
    end
	-- local battleParams = require "LocalData.Battle.BattleParams".New()
	-- battleParams:SetBattleResultResponsePrototype(net.S2CGHPointFightOverResult)
	-- battleParams:SetBattleResultViewClassName("GUI.GuildPoint.GuildPointFightResult",self.msg)
	self:OnReturnButtonClicked()
	if self.type == kReportGuildPointFighe then
		utility.StartReplay(msg,self.msg,"GUI.GuildPoint.GuildPointFightResult")
	elseif self.type == kReportArena then
		utility.StartReplay(msg,self.msg,"GUI.Arena.ArenaBattleResult")
	elseif self.type == kReportElventTree then
		utility.StartReplay(msg,self.msg,"GUI.Arena.ArenaBattleResult")
	end
end

function ReportInfoCls:OnReturnButtonClicked()
	self:Close(true)
end

function ReportInfoCls:LoadReportItemInfo()
	self.node = {}
	for i=1,#self.data do
	 	reportInfoItemCls = require "GUI.GuildPoint.ReportInfoItem".New(self.reportPoint,self.reportType,self.data[i])
	 	self.node[i] = reportInfoItemCls
	 	self:AddChild(reportInfoItemCls)
	 end 
end

return ReportInfoCls