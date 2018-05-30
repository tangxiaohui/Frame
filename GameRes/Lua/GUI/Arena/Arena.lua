local BaseNodeClass = require "Framework.Base.UIScene"
local utility = require "Utils.Utility"
local TweenUtility = require "Utils.TweenUtility"
local net = require "Network.Net"
local messageGuids = require "Framework.Business.MessageGuids"
local messageManager = require "Network.MessageManager"
require "Const"
require "LUT.StringTable"
require "Game.Role"
local BattleUtility = require "Utils.BattleUtility"
require "Game.Role"

-- 最大购买次数ID
local maxCostCount = 15
local ResetChallengeCost = 50
----------------------------------------------------------------------

local ArenaCls = Class(BaseNodeClass)

function ArenaCls:Ctor()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function ArenaCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/Arena', function(go)
		self:BindComponent(go)
	end)
end

function ArenaCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

local function PlayGameSound(self, id)
	local audioManager = self:GetAudioManager()
	audioManager:FadeInBGM(id)
end

function ArenaCls:OnResume()
	-- 界面显示时调用
	ArenaCls.base.OnResume(self)

	require "Utils.GameAnalysisUtils".RecordLocalAction(kTrackingId_ArenaView)

	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	PlayGameSound(self,1005)
	self:RedDotStateQuery()
	self:OnArenaQueryRequest(1)
	self:RefeshFormation()
	self:RefreshCurrencyView()
	self:ScheduleUpdate(self.Update)
    self:RegisterEvent(messageGuids.ModuleRedDotChanged, self.RedDotStateUpdated)

	-- self:OnArenaHistoryRequest()
end

function ArenaCls:OnPause()
	-- 界面隐藏时调用
	ArenaCls.base.OnPause(self)
	self:UnregisterEvent(messageGuids.ModuleRedDotChanged, self.RedDotStateUpdated)

	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
	self:HideCardFormation()
end

function ArenaCls:OnEnter()
	-- Node Enter时调用
	ArenaCls.base.OnEnter(self)
end

function ArenaCls:OnExit()
	-- Node Exit时调用
	ArenaCls.base.OnExit(self)
end

function ArenaCls:Update()
	--self:Countdown()
end


-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function ArenaCls:InitControls()
	local transform = self:GetUnityTransform()

	self.ArenaReturnButton = transform:Find('ArenaReturnButton'):GetComponent(typeof(UnityEngine.UI.Button))
	--self.Target01Base = transform:Find('Target/Target01/Target01Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ArenaTarget01ChallengeButton = transform:Find('Target/Target01/ArenaTarget01ChallengeButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ArenaTarget02ChallengeButton = transform:Find('Target/Target02/ArenaTarget02ChallengeButton'):GetComponent(typeof(UnityEngine.UI.Button))		
	self.ArenaTarget03ChallengeButton = transform:Find('Target/Target03/ArenaTarget03ChallengeButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ArenaMyRecordDescriptionButton = transform:Find('ButtonList/ArenaMyRecordDescriptionButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ArenaMyRecordReportButton = transform:Find('ButtonList/ArenaMyRecordReportButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ArenaMyRecordRankingButton = transform:Find('MyRecord/Buttons/ArenaMyRecordRankingButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ArenaFormationButton = transform:Find('ButtonList/ArenaFormationButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ArenaShopButton = transform:Find('ButtonList/ArenaShopButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ArenaRefreshButton = transform:Find('ButtonList/ArenaRefreshButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ArenaMileStoneButton = transform:Find('ButtonList/ArenaMileStoneButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ArenaMileStoneButtonRedDot = transform:Find('ButtonList/ArenaMileStoneButton/Image')
	self.ArenaMileStoneButtonRedDot.gameObject:SetActive(false)
	self.ArenaFreeRefresh = self.ArenaRefreshButton.transform:Find("Text"):GetComponent(typeof(UnityEngine.UI.Text))
	self.ArenaRefreshDiaObj = self.ArenaRefreshButton.transform:Find("DiamText").gameObject
	self.ArenaRefreshDiaNum = self.ArenaRefreshDiaObj.transform:Find("Text (1)"):GetComponent(typeof(UnityEngine.UI.Text))
	-------------------------------------------------------------------------------------
	self.StrengthNumLabelMine = transform:Find('MyRecord/Strength/StrengthNumLabelMine'):GetComponent(typeof(UnityEngine.UI.Text))
	self.RankingNumLabelMine = transform:Find('MyRecord/MyRecordRanking/RankingNumLabelMine'):GetComponent(typeof(UnityEngine.UI.Text))
	self.MeritoriousNumLabel = transform:Find('MyRecord/CurrencyMeritorious/MeritoriousNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ArenaRestTimesLabel = transform:Find('Target/RestTimes/ArenaRestTimesLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.MyRecordRankingLabel = transform:Find('MyRecord/MyRecordTitle/MyRecordRankingLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.LayoutFront = transform:Find("Formation/LayoutFront")
	self.LayoutBack = transform:Find("Formation/LayoutBack")

	--- 刷新次数显示
	self.RefeshHintLabel = transform:Find('Target/RestTimes (1)/ArenaRestTimesLabel'):GetComponent(typeof(UnityEngine.UI.Text))

	self.ResetChallengeButton = transform:Find('ButtonList/ResetChallengeButton'):GetComponent(typeof(UnityEngine.UI.Button))
	-- 倒计时
	-- self.RestTimeTrans = transform:Find('Target/RestTimes/RestTimeLabel').gameObject
	-- self.RestTimeLabel = transform:Find('Target/RestTimes/RestTimeLabel/RestTime'):GetComponent(typeof(UnityEngine.UI.Text))
	-- self.RestTimeCostLabel = transform:Find('Target/RestTimes/RestTimeLabel/CostCount'):GetComponent(typeof(UnityEngine.UI.Text))

	-- 对手等级列表
	self.ArenaTarget01LvNumLabel = transform:Find('Target/Target01/Target01Lv/ArenaTarget01LvNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ArenaTarget02LvNumLabel = transform:Find('Target/Target02/Target02Lv/ArenaTarget02LvNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ArenaTarget03LvNumLabel = transform:Find('Target/Target03/Target03Lv/ArenaTarget03LvNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.targetLvNums = {self.ArenaTarget01LvNumLabel,self.ArenaTarget02LvNumLabel,self.ArenaTarget03LvNumLabel}

	-- 对手名字列表
	self.ArenaTarget01NameLabel = transform:Find('Target/Target01/ArenaTarget01NameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ArenaTarget02NameLabel = transform:Find('Target/Target02/ArenaTarget02NameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ArenaTarget03NameLabel = transform:Find('Target/Target03/ArenaTarget03NameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.targetNames = {self.ArenaTarget01NameLabel,self.ArenaTarget02NameLabel,self.ArenaTarget03NameLabel}

	-- 对手rank列表
	self.ArenaTarget01RankingNumLabel = transform:Find('Target/Target01/Target01Ranking/ArenaTarget01RankingNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ArenaTarget02RankingNumLabel = transform:Find('Target/Target02/Target02Ranking/ArenaTarget02RankingNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ArenaTarget03RankingNumLabel = transform:Find('Target/Target03/Target03Ranking/ArenaTarget03RankingNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.rankNums = {self.ArenaTarget01RankingNumLabel,self.ArenaTarget02RankingNumLabel,self.ArenaTarget03RankingNumLabel}

	-- 对手rank文字列表
	self.ArenaTarget01RankingLabel = transform:Find('Target/Target01/Target01Title/ArenaTarget01RankingLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ArenaTarget02RankingLabel = transform:Find('Target/Target02/Target02Title/ArenaTarget02RankingLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ArenaTarget03RankingLabel = transform:Find('Target/Target03/Target03Title/ArenaTarget03RankingLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.rankLabels = {self.ArenaTarget01RankingLabel,self.ArenaTarget02RankingLabel,self.ArenaTarget03RankingLabel}

	-- 对手战斗力列表
	self.ArenaTarget01StrengthNumLabel = transform:Find('Target/Target01/Target01Strength/ArenaTarget01StrengthNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ArenaTarget02StrengthNumLabel = transform:Find('Target/Target02/Target02Strength/ArenaTarget02StrengthNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ArenaTarget03StrengthNumLabel = transform:Find('Target/Target03/Target03Strength/ArenaTarget03StrengthNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.strengthNums = {self.ArenaTarget01StrengthNumLabel,self.ArenaTarget02StrengthNumLabel,self.ArenaTarget03StrengthNumLabel} 

	-- 对手头像列表
	self.ArenaTarget01HeadIcon = transform:Find('Target/Target01/Target01Head/Mask/ArenaTarget01HeadIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ArenaTarget02HeadIcon = transform:Find('Target/Target02/Target02Head/Mask/ArenaTarget02HeadIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ArenaTarget03HeadIcon = transform:Find('Target/Target03/Target03Head/Mask/ArenaTarget03HeadIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.headIcons = {self.ArenaTarget01HeadIcon , self.ArenaTarget02HeadIcon , self.ArenaTarget03HeadIcon}

	-- 对手列表
	self.targetObj01 = transform:Find('Target/Target01').gameObject
	self.targetObj02 = transform:Find('Target/Target02').gameObject
	self.targetObj03 = transform:Find('Target/Target03').gameObject
	self.targetObjTable = {self.targetObj01,self.targetObj02,self.targetObj03}
	--self.targetObj01:SetActive(true)
	--self.targetObj02:SetActive(true)
	--self.targetObj03:SetActive(true)
	self.RefeshHintObj = transform:Find('Target/RestTimes (1)').gameObject
	self.TopHintObj = transform:Find('No1Notice').gameObject
	--屏蔽战报按钮
	--self.ArenaMyRecordReportButton.gameObject:SetActive(false)

	-- 购买次数按钮
	self.BuyChallengeButton = transform:Find('ButtonList/BuyChallengeButton'):GetComponent(typeof(UnityEngine.UI.Button))

	-- 防守阵容区域
	self.defenseFormationButton = transform:Find('ButtonList/DefenseButton'):GetComponent(typeof(UnityEngine.UI.Button))

	-- 阵容提示
	--self.FormationHintLabel = transform:Find('Formation/FormationHintLabel').gameObject

	self.myGame = utility:GetGame()
	

	self.formations = {}
	--self.arenaDefenceFormation = {}

	-- 挑战队伍卡牌数量
	self.currAcceptRoleCount = 0

	--self:IntiFormationView()
end

function ArenaCls:RegisterControlEvents()
	-- 注册 ArenaReturnButton 的事件
	self.__event_button_onArenaReturnButtonClicked__ = UnityEngine.Events.UnityAction(self.OnArenaReturnButtonClicked, self)
	self.ArenaReturnButton.onClick:AddListener(self.__event_button_onArenaReturnButtonClicked__)

	-- 注册 ArenaTarget01ChallengeButton 的事件
	self.__event_button_onArenaTarget01ChallengeButtonClicked__ = UnityEngine.Events.UnityAction(self.OnArenaTarget01ChallengeButtonClicked, self)
	self.ArenaTarget01ChallengeButton.onClick:AddListener(self.__event_button_onArenaTarget01ChallengeButtonClicked__)

	-- 注册 ArenaTarget02ChallengeButton 的事件
	self.__event_button_onArenaTarget02ChallengeButtonClicked__ = UnityEngine.Events.UnityAction(self.OnArenaTarget02ChallengeButtonClicked, self)
	self.ArenaTarget02ChallengeButton.onClick:AddListener(self.__event_button_onArenaTarget02ChallengeButtonClicked__)

	-- 注册 ArenaTarget03ChallengeButton 的事件
	self.__event_button_onArenaTarget03ChallengeButtonClicked__ = UnityEngine.Events.UnityAction(self.OnArenaTarget03ChallengeButtonClicked, self)
	self.ArenaTarget03ChallengeButton.onClick:AddListener(self.__event_button_onArenaTarget03ChallengeButtonClicked__)

	-- 注册 ArenaMyRecordDescriptionButton 的事件
	self.__event_button_onArenaMyRecordDescriptionButtonClicked__ = UnityEngine.Events.UnityAction(self.OnArenaMyRecordDescriptionButtonClicked, self)
	self.ArenaMyRecordDescriptionButton.onClick:AddListener(self.__event_button_onArenaMyRecordDescriptionButtonClicked__)

	-- 注册 ArenaMyRecordReportButton 的事件
	self.__event_button_onArenaMyRecordReportButtonClicked__ = UnityEngine.Events.UnityAction(self.OnArenaMyRecordReportButtonClicked, self)
	self.ArenaMyRecordReportButton.onClick:AddListener(self.__event_button_onArenaMyRecordReportButtonClicked__)

	-- 注册 ArenaMyRecordRankingButton 的事件
	self.__event_button_onArenaMyRecordRankingButtonClicked__ = UnityEngine.Events.UnityAction(self.OnArenaMyRecordRankingButtonClicked, self)
	self.ArenaMyRecordRankingButton.onClick:AddListener(self.__event_button_onArenaMyRecordRankingButtonClicked__)

	-- 注册 ArenaFormationButton 的事件
	self.__event_button_onArenaFormationButtonClicked__ = UnityEngine.Events.UnityAction(self.OnArenaFormationButtonClicked, self)
	self.ArenaFormationButton.onClick:AddListener(self.__event_button_onArenaFormationButtonClicked__)

	-- 注册 ArenaShopButton 的事件
	self.__event_button_onArenaShopButtonClicked__ = UnityEngine.Events.UnityAction(self.OnArenaShopButtonClicked, self)
	self.ArenaShopButton.onClick:AddListener(self.__event_button_onArenaShopButtonClicked__)

	-- 注册 ArenaRefreshButton 的事件
	self.__event_button_onArenaRefreshButtonClicked__ = UnityEngine.Events.UnityAction(self.OnArenaRefreshButtonClicked, self)
	self.ArenaRefreshButton.onClick:AddListener(self.__event_button_onArenaRefreshButtonClicked__)


	-- 注册 重置挑战 的事件
	self.__event_button_onResetChallengeButtonClicked__ = UnityEngine.Events.UnityAction(self.OnResetChallengeButtonClicked, self)
	self.ResetChallengeButton.onClick:AddListener(self.__event_button_onResetChallengeButtonClicked__)

	-- 注册 购买次数按钮 的事件
	self.__event_button_onBuyChallengeButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBuyChallengeButtonClicked, self)
	self.BuyChallengeButton.onClick:AddListener(self.__event_button_onBuyChallengeButtonClicked__)

	-- 注册 里程碑 的事件
	self.__event_button_onArenaMileStoneButtonClicked__ = UnityEngine.Events.UnityAction(self.OnArenaMileStoneButtonClicked, self)
	self.ArenaMileStoneButton.onClick:AddListener(self.__event_button_onArenaMileStoneButtonClicked__)

	-- 注册 防守阵容区域按钮 的事件
	self.__event_button_ondefenseFormationButtonClicked__ = UnityEngine.Events.UnityAction(self.OndefenseFormationButtonClicked, self)
	self.defenseFormationButton.onClick:AddListener(self.__event_button_ondefenseFormationButtonClicked__)

	
end

function ArenaCls:UnregisterControlEvents()

	-- 取消注册 ArenaReturnButton 的事件
	if self.__event_button_onArenaReturnButtonClicked__ then
		self.ArenaReturnButton.onClick:RemoveListener(self.__event_button_onArenaReturnButtonClicked__)
		self.__event_button_onArenaReturnButtonClicked__ = nil
	end

	-- 取消注册 ArenaTarget01ChallengeButton 的事件
	if self.__event_button_onArenaTarget01ChallengeButtonClicked__ then
		self.ArenaTarget01ChallengeButton.onClick:RemoveListener(self.__event_button_onArenaTarget01ChallengeButtonClicked__)
		self.__event_button_onArenaTarget01ChallengeButtonClicked__ = nil
	end

	-- 取消注册 ArenaTarget02ChallengeButton 的事件
	if self.__event_button_onArenaTarget02ChallengeButtonClicked__ then
		self.ArenaTarget02ChallengeButton.onClick:RemoveListener(self.__event_button_onArenaTarget02ChallengeButtonClicked__)
		self.__event_button_onArenaTarget02ChallengeButtonClicked__ = nil
	end

	-- 取消注册 ArenaTarget03ChallengeButton 的事件
	if self.__event_button_onArenaTarget03ChallengeButtonClicked__ then
		self.ArenaTarget03ChallengeButton.onClick:RemoveListener(self.__event_button_onArenaTarget03ChallengeButtonClicked__)
		self.__event_button_onArenaTarget03ChallengeButtonClicked__ = nil
	end

	-- 取消注册 ArenaMyRecordDescriptionButton 的事件
	if self.__event_button_onArenaMyRecordDescriptionButtonClicked__ then
		self.ArenaMyRecordDescriptionButton.onClick:RemoveListener(self.__event_button_onArenaMyRecordDescriptionButtonClicked__)
		self.__event_button_onArenaMyRecordDescriptionButtonClicked__ = nil
	end

	-- 取消注册 ArenaMyRecordReportButton 的事件
	if self.__event_button_onArenaMyRecordReportButtonClicked__ then
		self.ArenaMyRecordReportButton.onClick:RemoveListener(self.__event_button_onArenaMyRecordReportButtonClicked__)
		self.__event_button_onArenaMyRecordReportButtonClicked__ = nil
	end

	-- 取消注册 ArenaMyRecordRankingButton 的事件
	if self.__event_button_onArenaMyRecordRankingButtonClicked__ then
		self.ArenaMyRecordRankingButton.onClick:RemoveListener(self.__event_button_onArenaMyRecordRankingButtonClicked__)
		self.__event_button_onArenaMyRecordRankingButtonClicked__ = nil
	end

	-- 取消注册 ArenaFormationButton 的事件
	if self.__event_button_onArenaFormationButtonClicked__ then
		self.ArenaFormationButton.onClick:RemoveListener(self.__event_button_onArenaFormationButtonClicked__)
		self.__event_button_onArenaFormationButtonClicked__ = nil
	end

	-- 取消注册 ArenaShopButton 的事件
	if self.__event_button_onArenaShopButtonClicked__ then
		self.ArenaShopButton.onClick:RemoveListener(self.__event_button_onArenaShopButtonClicked__)
		self.__event_button_onArenaShopButtonClicked__ = nil
	end

	-- 取消注册 ArenaRefreshButton 的事件
	if self.__event_button_onArenaRefreshButtonClicked__ then
		self.ArenaRefreshButton.onClick:RemoveListener(self.__event_button_onArenaRefreshButtonClicked__)
		self.__event_button_onArenaRefreshButtonClicked__ = nil
	end

	-- 取消注册 重置挑战 的事件
	if self.__event_button_onResetChallengeButtonClicked__ then
		self.ResetChallengeButton.onClick:RemoveListener(self.__event_button_onResetChallengeButtonClicked__)
		self.__event_button_onResetChallengeButtonClicked__ = nil
	end

	-- 取消注册 购买次数按钮 的事件
	if self.__event_button_onBuyChallengeButtonClicked__ then
		self.BuyChallengeButton.onClick:RemoveListener(self.__event_button_onBuyChallengeButtonClicked__)
		self.__event_button_onBuyChallengeButtonClicked__ = nil
	end


	-- 取消注册 里程碑 的事件
	if self.__event_button_onArenaMileStoneButtonClicked__ then
		self.ArenaMileStoneButton.onClick:RemoveListener(self.__event_button_onArenaMileStoneButtonClicked__)
		self.__event_button_onArenaMileStoneButtonClicked__ = nil
	end

	-- 取消注册 防守阵容区域按钮 的事件
	if self.__event_button_ondefenseFormationButtonClicked__ then
		self.defenseFormationButton.onClick:RemoveListener(self.__event_button_ondefenseFormationButtonClicked__)
		self.__event_button_ondefenseFormationButtonClicked__ = nil
	end
end
----------------------------------------------------------------------
------------------网络事件注册----------------------------------------
function ArenaCls:RegisterNetworkEvents()
	-- 注册 竞技场Query 请求 Response
	self.myGame:RegisterMsgHandler(net.S2CArenaQueryResult, self, self.OnArenaQueryResponse)
	self.myGame:RegisterMsgHandler(net.S2CLoadPlayerResult, self, self.OnLoadPlayerResponse)
	self.myGame:RegisterMsgHandler(net.S2CArenaBuyChallengeResult, self, self.OnArenaBuyChallengeResponse)
	self.myGame:RegisterMsgHandler(net.S2CArenaClearCDResult, self, self.OnArenaClearCDResponse)
	self.myGame:RegisterMsgHandler(net.S2CCheckPlayerCardWithEquipResult, self, self.OnCheckPlayerCardWithEquipResult)
	self.myGame:RegisterMsgHandler(net.S2CArenaHistoryResult, self, self.OnArenaHistoryResponse)
	self.myGame:RegisterMsgHandler(net.FightRecordMessage, self, self.OnFightRecordResponse)
	self.myGame:RegisterMsgHandler(net.S2CArenaRefreshResultMessage, self, self.OnArenaRefreshResponse)	
end

function ArenaCls:UnregisterNetworkEvents()
	-- 取消注册 竞技场Query 请求 Response
	self.myGame:UnRegisterMsgHandler(net.S2CArenaQueryResult, self, self.OnArenaQueryResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CLoadPlayerResult, self, self.OnLoadPlayerResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CArenaBuyChallengeResult, self, self.OnArenaBuyChallengeResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CArenaClearCDResult, self, self.OnArenaClearCDResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CCheckPlayerCardWithEquipResult, self, self.OnCheckPlayerCardWithEquipResult)
	self.myGame:UnRegisterMsgHandler(net.S2CArenaHistoryResult, self, self.OnArenaHistoryResponse)
	self.myGame:UnRegisterMsgHandler(net.FightRecordMessage, self, self.OnFightRecordResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CArenaRefreshResultMessage, self, self.OnArenaRefreshResponse)
end
-----------------------------------------------------------------------
function ArenaCls:OnArenaQueryRequest(const)
	-- 竞技场Query 请求
	-- const == 100 刷新请求
	self.myGame:SendNetworkMessage( require"Network/ServerService".ArenaQueryRequest(const))
end

function ArenaCls:OnArenaBuyChallengeRequest()
	-- 竞技场购买挑战 请求
	self.myGame:SendNetworkMessage( require"Network/ServerService".ArenaBuyChallengeRequest())
end


function ArenaCls:ArenaClearCDRequest()
	-- 竞技场清除CD 请求
	self.myGame:SendNetworkMessage( require"Network/ServerService".ArenaClearCDRequest())
end

function ArenaCls:OnCheckPlayerCardWithEquipRequest(playerUID,cardID)
	-- 查看卡牌装备
	self.myGame:SendNetworkMessage( require"Network/ServerService".OnCheckPlayerCardWithEquipRequest(playerUID,cardID))
end

function ArenaCls:OnArenaRefreshRequest(needType)
	self.myGame:SendNetworkMessage( require"Network/ServerService".ArenaRefreshRequest(needType))
end

function ArenaCls:OnArenaHistoryRequest()
	self.myGame:SendNetworkMessage( require"Network/ServerService".OnArenaHistoryRequest())
end

function ArenaCls:OnFightHistoryQuery(historyKey)
	self.myGame:SendNetworkMessage( require"Network/ServerService".OnFightHistoryQuery(historyKey))
end

function ArenaCls:OnArenaQueryResponse(msg)
	self.msg = msg
	self:InitView(msg)
	self:SetRefreshButton(msg)
end

function ArenaCls:SetRefreshButton(msg)
	self.flushTimes = msg.flushTimes
	self.refreshDiaTimes = msg.flushTid

	local data = require "StaticData.Arena.ArenaRefreshTimes":GetKeys()
	if self.refreshDiaTimes < 0 or self.refreshDiaTimes > data.Length then

		self:SetRefreshButtonState(true)
		self.ArenaFreeRefresh.text = "次数用尽"
		self.ArenaRefreshButton.enabled = false
		self.ArenaRefreshButton.targetGraphic.material = utility.GetGrayMaterial()

		return
	end


	if msg.flushTimes > 0 then
		self:SetRefreshButtonState(true)
	elseif self.refreshDiaTimes ~= nil and self.refreshDiaTimes ~= 0 then
		local data = require "StaticData.Arena.ArenaRefreshTimes":GetData(self.refreshDiaTimes)
		self.ArenaRefreshDiaNum.text = data:GetCost()
		self:SetRefreshButtonState(false)
	end
end

function ArenaCls:SetRefreshButtonState(isFree)
	self.ArenaFreeRefresh.gameObject:SetActive(isFree)
	self.ArenaRefreshDiaObj:SetActive(not isFree)
end

function ArenaCls:OnLoadPlayerResponse(_)
    self:RefreshCurrencyView()
end

function ArenaCls:OnArenaBuyChallengeResponse(msg)	
	self.challengeRemain = msg.challengeRemain
	self.challengeTotal = msg.challengeTotal	
	self.alreadyBuy = msg.alreadyBuy

	-- 设置剩余次数
	self.challengeRemain = msg.challengeRemain
	self.challengeTotal = msg.challengeTotal
	self.ArenaRestTimesLabel.text = string.format("%d%s%d",self.challengeRemain,"/",self.challengeTotal)
	-- self:DisposeResetButtonEvent()
end

function ArenaCls:OnArenaClearCDResponse(msg)
	--self:UpdateCountdownView()
end

---临时 构建装备列表
local function SetEquipList(role,equipTable)
	require "Collection.OrderedDictionary"
	local dict = OrderedDictionary.New()
	for i = 1 ,#equipTable do

		local equip = equipTable[i]
		local uid = string.format("%s%s",equip.id,i)
		local fakeEquipData = require "Data.EquipBag.EquipData".New()
        fakeEquipData:UpdateData{
        equipUID = uid,
        equipID = equip.id,
        level = equip.level,
        pos = equip.pos,
        bindCardUID = "",
        onWhichCard = "",
        exp = 0,
        color = equip.color,
        stoneID = {equip.gemId},
        stoneUID = ""
        }
        dict:Add(uid,fakeEquipData)
	end
	role:SetEquipDataList(dict)
end

function ArenaCls:OnCheckPlayerCardWithEquipResult(msg)
	-- 卡牌装备查询
	self.currAcceptRoleCount = self.currAcceptRoleCount + 1

	local role = Role.New()
	role:Update(msg.card)
	SetEquipList(role,msg.equips)
	local rolePos = msg.card.pos[kLineup_ArenaDefence + 1]
	self.EnemyTeamTable[#self.EnemyTeamTable + 1] = BattleUtility.CreateBattleUnitParameter(role,rolePos)
	

	if self.currAcceptRoleCount == self.maxAcceptRoleCount then
		local windowManager = self.myGame:GetWindowManager()
   		windowManager:Show(require "GUI.Formation.ArenaEnemyFormation",nil,self.msg.playerSimpleInfo[self.selectedEnemyId].items,self.zhanli,self.SelectCardInArenaFight,self)
   		self.currAcceptRoleCount = 0
	end
end

function ArenaCls:OnArenaHistoryResponse(msg)
	-- 竞技场战报查询
	self.recordHistory = msg.history
	debug_print("竞技场战报查询结果 >>>>>>>>>")

	for i = 1 ,#msg.history do
		print("竞技场战报查询",msg.history[i].playerName)
	end
	
	local windowManager = utility.GetGame():GetWindowManager()
	windowManager:Show(require "GUI.GuildPoint.ReportInfo",kReportArena,msg.history)

-- 	optional int64 timestamp = 1;//时间戳
--   optional string playerUID = 2;//对方的uid
--   optional string playerName = 3;//对方的名字
--   optional int32 rank = 4;//你的挑战后排名
--   optional bool ending = 5;//true为你赢了,false是你输了
--   optional bool state = 6;//true挑战别人,false被人挑战
--   optional int32 rankState = 7;//为0表示你的排名没变,>0表示你的排名上升了多少,<0表示你的排名下降了多少
--   optional int32 playerLevel = 8;//对方的等级
--   optional int32 playerRank = 9;//对方的排名
--   optional string historyKey = 10;//战斗录像，为空字符串则表示服务器未记录
--   optional int32 headCardID = 11;//对方头像id
--   optional int32 headCardColor = 12;//对方头像颜色
--   optional string gonghuiName = 13;
-- history
end

function ArenaCls:OnFightRecordResponse(msg)
	print("回放是否为空",type(msg))
	utility.StartReplay(msg)
end

function ArenaCls:OnArenaRefreshResponse(msg)
	self.needBuyRefeshi = msg.flushTimes <= 0
	self.RefeshHintLabel.text = string.format("%s%s%s",msg.flushTimes,"/",msg.flushTimesTotal)
	self.msg = msg
	local arenaTitleData = require "StaticData.Arena.ArenaTitleData"
	self:RefreshTargetView(msg,arenaTitleData)
	self:DisposeEnemyPanel(self.rank)
	self:SetRefreshButton(msg)
end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function ArenaCls:OnArenaReturnButtonClicked()
	--ArenaReturnButton控件的点击事件处理
	local sceneManager = self.myGame:GetSceneManager()
    sceneManager:PopScene()
end

function ArenaCls:GetFoeTeam()
	-- 获取敌人
	local teamArgs = {}

   	for i=1,#self.challengeTeam do
   		teamArgs[i] = {}
   	 	teamArgs[i].cardID = self.challengeTeam[i].cardID
   	 	teamArgs[i].cardColor = self.challengeTeam[i].cardColor
   	 	teamArgs[i].cardLevel = self.challengeTeam[i].cardLevel
   	 	teamArgs[i].cardPos = self.challengeTeam[i].cardPos
   	 	teamArgs[i].cardStage = self.challengeTeam[i].cardStage 	
   	 end 

   	local teamTable = {}
    for i=1,#teamArgs do
    	teamTable[#teamTable + 1] = BattleUtility.CreateStaticBattleUnitParameter(teamArgs[i].cardID,teamArgs[i].cardColor,teamArgs[i].cardLevel,teamArgs[i].cardStage,nil,teamArgs[i].cardPos)
    end  

    local foeTeams = BattleUtility.CreateBattleTeams(teamTable)
    return foeTeams
end


function ArenaCls:SelectCardInArenaFight()
	-- 挑战选择阵容
	print("挑战选择阵容！！！")
 	local LocalDataType = require "LocalData.LocalDataType" 
    local ServerService = require "Network.ServerService"

    local foeTeams 
    if self.challengePlayerIsNpc then
    	foeTeams = self:GetFoeTeam()
    else
    	print(#self.EnemyTeamTable,"队伍数量")
		foeTeams = BattleUtility.CreateBattleTeams(self.EnemyTeamTable)
    end


    local battleParams = require "LocalData.Battle.BattleParams".New()
	battleParams:SetSceneID(2)
	battleParams:SetScriptID(nil)
	battleParams:SetBattleType(kLineup_ArenaAttack)
	battleParams:SetBattleOverLocalDataName(LocalDataType.ArenaBattleResult)
	battleParams:SetBattleStartProtocol(ServerService.ArenaStartFightRequest(self.challengeUID))
	battleParams:SetBattleResultResponsePrototype(net.S2CArenaFightOverResult)
	battleParams:SetBattleResultViewClassName("GUI.Arena.ArenaBattleResult")
	battleParams:SetMaxBattleRounds(30)
	battleParams:SetBattleResultWhenReachMaxRounds(false)
	battleParams:SetPVPMode(true)
	battleParams:SetSkillRestricted(false)
	battleParams:SetUnlimitedRage(false)
	battleParams:DisableManuallyOperation()

	utility.StartBattle(battleParams, foeTeams, nil)

    -- local battleStartParams = require "LocalData.BattleStartParams".New()
    -- battleStartParams:DisableManuallyOperation()
    -- battleStartParams:SetBattleResultLocalDataName(LocalDataType.ArenaBattleResult)
    -- battleStartParams:SetBattleRecordProtocol(ServerService.ArenaStartFightRequest(self.challengeUID))
    -- battleStartParams:SetBattleResultResponse(net.S2CArenaFightOverResult)
    -- --battleStartParams:SetBattleResultViewHANDLE(require "GUI.Modules.BattleResultModule")
    -- battleStartParams:SetBattleResultViewHANDLEClassName("GUI.Arena.ArenaFightResult")
    -- utility.StartBattle(kLineup_ArenaAttack, battleStartParams, foeTeams)
end

local function ComparisonPlayerIsNPC(uid)
	-- 查看对手是否为npc
	local StringUtility = require "Utils.StringUtility"
	local array = StringUtility.CreateArray(uid)
	local str = string.format("%s%s%s",array[1],array[2],array[3])
	return str == "npc"
end

local function CheckFormationCount(self)
	local UserDataType = require "Framework.UserDataType"
	local cardBagData = self:GetCachedData(UserDataType.CardBagData)
	
	local ArenaDefenceCount = cardBagData:GetTroopCount(kLineup_ArenaDefence)
	if ArenaDefenceCount == 0 then
		utility.ShowErrorDialog("防守阵容不能为空，请先设置防守阵容")
		return false
	end
	return true
end

function ArenaCls:ChallengeButtonEvent(id)
	-- 挑战按钮事件
	local isCan = self:RetrievalCanChallenge()
	if not isCan then
		return
	end

	if not CheckFormationCount(self) then
		return
	end

	self.challengeTeam = self.msg.playerSimpleInfo[id].items
	self.challengeUID = self.msg.playerSimpleInfo[id].playerUID
	local zhanli = self.msg.playerSimpleInfo[id].zhanli
	self.zhanli = zhanli
	local isNpc = ComparisonPlayerIsNPC(self.msg.playerSimpleInfo[id].playerUID)
	self.challengePlayerIsNpc = isNpc
	if isNpc then
		local windowManager = self.myGame:GetWindowManager()
   		windowManager:Show(require "GUI.Formation.ArenaEnemyFormation",nil,self.msg.playerSimpleInfo[id].items,zhanli,self.SelectCardInArenaFight,self)
	else
		-- 队伍数量
		self.currAcceptRoleCount = 0
		self.maxAcceptRoleCount = #self.challengeTeam
		self.EnemyTeamTable = {}
		self.selectedEnemyId = id
		for i = 1,self.maxAcceptRoleCount do
			self:OnCheckPlayerCardWithEquipRequest(self.challengeUID,self.challengeTeam[i].cardID)
		end
	end
end

function ArenaCls:OnArenaTarget01ChallengeButtonClicked()
	self:ChallengeButtonEvent(1)
end

function ArenaCls:OnArenaTarget02ChallengeButtonClicked()
	self:ChallengeButtonEvent(2)
end

function ArenaCls:OnArenaTarget03ChallengeButtonClicked()
	self:ChallengeButtonEvent(3)
end


function ArenaCls:RetrievalCanChallenge()
	-- 检查是否可以挑战
	local isCan = true

	if self.challengeRemain < 1 then
		isCan = false
		local str =  CommonStringTable[5]

		local windowManager = utility:GetGame():GetWindowManager()
   		local ConfirmDialogClass = require "GUI.Dialogs.ErrorDialog"
		windowManager:Show(ConfirmDialogClass, str)

	elseif self.cdTime > 0 then
		isCan = false
		self:OnResetChallengeButtonClicked()

	end

	return isCan
end

function ArenaCls:OnArrowRightButtonClicked()
	--阵容右按钮控件的点击事件处理
	if (not self.formationLeftShow) or self.arenaDefenceCount < 4 then
		return
	end

	-- 隐藏前4个
	for i=1,4 do
		self.formations[i]:OnShow(false)
	end

	self.formationLeftShow = false
	--self.ArrowLeftButton.interactable = true
	--self.ArrowRightButton.interactable = false	
end

function ArenaCls:OnArrowLeftButtonClicked()
	--阵容左按钮控件的点击事件处理
	if self.formationLeftShow then
		return
	end

	-- 恢复前4个
	for i=1,4 do
		self.formations[i]:OnShow(true)
	end

	self.formationLeftShow = true
end


function ArenaCls:OnArenaMyRecordDescriptionButtonClicked()
	--说明按钮的点击事件处理
	local str = utility.GetDescriptionStr(KSystemBasis_ArenaID)
	local windowManager = self.myGame:GetWindowManager()
    windowManager:Show(require "GUI.CommonDescriptionModule",str)
end

function ArenaCls:OnArenaMyRecordReportButtonClicked()
	--ArenaMyRecordReportButton控件的点击事件处理
	self:OnArenaHistoryRequest()
	--local key = self.recordHistory[1].historyKey
	--print("发送历史请求的key ",key)
	--self:OnFightHistoryQuery(key)



end
function ArenaCls:RedDotStateUpdated(moduleId,moduleState)
    -- 红点更新处理

    local S2CGuideRedResult = require "Network.PB.S2CGuideRedResult"
	local UserDataType = require "Framework.UserDataType"

	if moduleId == S2CGuideRedResult.arena_award then
        -- 
        self.ArenaMileStoneButtonRedDot.gameObject:SetActive(moduleState == 1)
    end

end

function ArenaCls:RedDotStateQuery()
    -- 查询红点提示
    local S2CGuideRedResult = require "Network.PB.S2CGuideRedResult"
    local UserDataType = require "Framework.UserDataType"
    local RedDotData = self:GetCachedData(UserDataType.RedDotData)

    if RedDotData ~= nil then
        local arena_award = RedDotData:GetModuleRedState(S2CGuideRedResult.arena_award)
        self.ArenaMileStoneButtonRedDot.gameObject:SetActive(arena_award == 1)

    end
end

function ArenaCls:OnArenaMyRecordRankingButtonClicked()
	--ArenaMyRecordRankingButton控件的点击事件处理
	local windowManager = self.myGame:GetWindowManager()
    windowManager:Show(require "GUI.Arena.ArenaRank",kArenaRank)
end

function ArenaCls:SetConfirmMethod()
	-- 设置防守阵容确定事件
	--local sceneManager = self.myGame:GetSceneManager()
  --  sceneManager:PopScene()
end


function ArenaCls:OnArenaFormationButtonClicked()
	--竞技场阵容控件的点击事件处理
	local sceneManager = self:GetGame():GetSceneManager()

    local FormationCls = require "GUI.Formation.Formation".New(kLineup_ArenaDefence,self.SetConfirmMethod,self)
    sceneManager:PushScene(FormationCls)
end

function ArenaCls:OndefenseFormationButtonClicked()
	self:OnArenaFormationButtonClicked()
end

function ArenaCls:OnArenaShopButtonClicked()
	--竞技场商店button控件的点击事件处理
	local windowManager = self.myGame:GetWindowManager()
   	windowManager:Show(require "GUI.Shop.Shop",KShopType_Arena)
end

function ArenaCls:OnRefreshRequest()
	if self.needBuyRefeshi then
		needType = 2
	else
		needType = 1
	end
	self:OnArenaRefreshRequest(needType)
end

function ArenaCls:OnArenaRefreshButtonClicked()
	-- 刷新控件的点击事件处理

	local data = require "StaticData.Arena.ArenaRefreshTimes":GetKeys()

	local windowManager = utility:GetGame():GetWindowManager()
	if self.flushTimes > 0 then
		self:OnRefreshRequest()
	elseif self.refreshDiaTimes ~= nil and self.refreshDiaTimes ~= 0 then
		if self.refreshDiaTimes < 0 or self.refreshDiaTimes > data.Length then

			self.ArenaFreeRefresh.text = "次数用尽"
			self.ArenaRefreshButton.enabled = false
			self.ArenaRefreshButton.targetGraphic.material = utility.GetGrayMaterial()
			
			return
		end

		local data = require "StaticData.Arena.ArenaRefreshTimes":GetData(self.refreshDiaTimes)
		local str = string.format("是否花费%s钻石刷新",data:GetCost())
		local ConfirmDialogClass = require "GUI.Dialogs.ConfirmDialog"
		windowManager:Show(ConfirmDialogClass, str,self, self.OnRefreshRequest)
	end
end

function ArenaCls:OnResetChallengeButtonClicked()
	-- 刷新挑战按钮的界面
	local windowManager = utility:GetGame():GetWindowManager()

	local str = CommonStringTable[4]
	str = string.format(str,ResetChallengeCost)

    local ConfirmDialogClass = require "GUI.Dialogs.ConfirmDialog"
	windowManager:Show(ConfirmDialogClass, str,self, self.ArenaClearCDRequest)
	--self:ArenaClearCDRequest()
end

function ArenaCls:OnBuyChallengeButtonClicked()

	-- local ArenaTimesData = require "StaticData.Arena.ArenaTimes"
	-- 		hzj_print("GetKeys",ArenaTimesData:GetKeys().Length)

	-- 购买次数
	local windowManager = utility:GetGame():GetWindowManager()
	if self.challengeRemain < self.challengeTotal then
		local UserDataType = require "Framework.UserDataType"
    	local userData = self:GetCachedData(UserDataType.PlayerData)
    	local vip = userData:GetVip()
		--可以购买次数

		local vipData = require"StaticData.Vip.Vip"	
		local allCanBuyNum = vipData:GetData(vip):GetArenachallengetimes()
		---判断是否还可以购买
		if allCanBuyNum > self.alreadyBuy then
			local ArenaTimesData = require "StaticData.Arena.ArenaTimes"
			hzj_print("GetKeys",ArenaTimesData:GetKeys().Length)
			--消耗表最大
			local maxCost = ArenaTimesData:GetKeys().Length
			local data

			if self.alreadyBuy>= maxCost then
				data = require "StaticData.Arena.ArenaTimes":GetData(maxCost)
			else
				data = require "StaticData.Arena.ArenaTimes":GetData(self.alreadyBuy + 1)

			end


		
			local cost = data:GetCost()
			local str = string.format(CommonStringTable[11],cost,allCanBuyNum-self.alreadyBuy)
    		local ConfirmDialogClass = require "GUI.Dialogs.ConfirmDialog"
			windowManager:Show(ConfirmDialogClass, str,self, self.OnArenaBuyChallengeRequest)
		else
			local str = string.format("需要达到VIP%s才能购买",vipLimit)
			windowManager:Show(require "GUI.Dialogs.ErrorDialog","提升VIP等级才能购买更多的挑战次数")
		end




		
		-- local vipLimit = data:GetVipLimit()
		
		-- if userData:GetVip() >= vipLimit then
		-- 	local cost = data:GetCost()
		-- 	local str = string.format(CommonStringTable[11],cost,1)
  --   		local ConfirmDialogClass = require "GUI.Dialogs.ConfirmDialog"
		-- 	windowManager:Show(ConfirmDialogClass, str,self, self.OnArenaBuyChallengeRequest)
		-- else
		-- 	local str = "今日购买次数已用完！"--string.format("需要达到VIP%s才能购买",vipLimit)
		-- 	windowManager:Show(require "GUI.Dialogs.ErrorDialog",str)
		-- end



	-- local alreadyBuy = math.min(self.alreadyBuy+1,maxCostCount)

	-- local StaticData = require "StaticData.Arena.ArenaTimes":GetData(alreadyBuy)
	-- local cost = StaticData:GetCost()
	-- local str = CommonStringTable[11]
	-- str = string.format(str,cost)
 --    local ConfirmDialogClass = require "GUI.Dialogs.ConfirmDialog"
	-- windowManager:Show(ConfirmDialogClass, str,self, self.OnArenaBuyChallengeRequest)
		-- self:OnArenaBuyChallengeRequest()
	else
		windowManager:Show(require "GUI.Dialogs.ErrorDialog","当前挑战次数已为最大！")
	end
end

function ArenaCls:OnArenaMileStoneButtonClicked()
	-- 里程碑
	local windowManager = self.myGame:GetWindowManager()
	windowManager:Show(require "GUI.Arena.ArenaMileStone")
	
end

-----------------------------------------------------------------------
function ArenaCls:RefreshCurrencyView()
    -- 设置货币刷新
    local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    
    -- self.TheMainTiLiLabel.text = string.format("%d/%d", userData:GetVigor(), userData:GetMaxVigor())
    -- self.TheMainMoneyLabel.text = userData:GetCoin()
    -- self.TheMainDiamondLabel.text = userData:GetDiamond()
    
    self.MeritoriousNumLabel.text = userData:GetShengwang()
end


function ArenaCls:InitView(msg)
	-- 初始化界面
	local arenaTitleData = require "StaticData.Arena.ArenaTitleData"
	self:RefreshTargetView(msg,arenaTitleData)
	
	self.needBuyRefeshi = msg.flushTimes <= 0
	-- 设置刷新次数
	self.RefeshHintLabel.text = string.format("%s%s%s",msg.flushTimes,"/",msg.flushTimesTotal)

	-- 设置自己 排名
	self.RankingNumLabelMine.text = msg.playerSimpleInfoOfSelf.rank
	-- 设置自己功勋币
	
	-- 设置自己军衔
	self.MyRecordRankingLabel.text = arenaTitleData:GetData(msg.playerSimpleInfoOfSelf.junxian):GetName()
	
	-- 设置对手列表
	self:DisposeEnemyPanel(msg.playerSimpleInfoOfSelf.rank)
	self.rank = msg.playerSimpleInfoOfSelf.rank

	-- 设置剩余次数
	self.challengeRemain = msg.challengeRemain
	self.challengeTotal = msg.challengeTotal
	self.ArenaRestTimesLabel.text = string.format("%d%s%d",self.challengeRemain,"/",self.challengeTotal)


	--- 设置倒计时
	self.cdTime = msg.cdTime / 1000
	
	self.alreadyBuy = msg.alreadyBuy
	-- self:DisposeResetButtonEvent()
end
---------------------------------------------------------------------
function ArenaCls:DisposeEnemyPanel(rank)
	-- 设置对手列表
	for i = 1,#self.targetObjTable do
		--local active = rank > i
		self.targetObjTable[i]:SetActive(true)
	end

	-- if rank == 1 then
	-- 	self.ArenaRefreshButton.gameObject:SetActive(false)
	-- 	self.RefeshHintObj:SetActive(false)
	-- 	self.TopHintObj:SetActive(true)
	-- else
	-- 	self.ArenaRefreshButton.gameObject:SetActive(true)
	-- 	self.RefeshHintObj:SetActive(false)
	-- 	self.TopHintObj:SetActive(false)
	-- end
	
end


function ArenaCls:DisposeResetButtonEvent()
	--  处理 刷新 重置 购买 按钮
	if self.challengeRemain > 0 then

		if self.cdTime > 0 then
			-- 重置 倒计时
			self.ArenaRefreshButton.gameObject:SetActive(false)
			self.BuyChallengeButton.gameObject:SetActive(false)
			self.ResetChallengeButton.gameObject:SetActive(true)
			self.RestTimeTrans:SetActive(true)
		else
			-- 刷新 无倒计时
			self.BuyChallengeButton.gameObject:SetActive(false)
			self.RestTimeTrans:SetActive(false)
			self.ResetChallengeButton.gameObject:SetActive(false)		
			self.ArenaRefreshButton.gameObject:SetActive(true)
		end
	else
		-- 购买次数
		self.ArenaRefreshButton.gameObject:SetActive(false)		
		self.RestTimeTrans:SetActive(false)
		self.ResetChallengeButton.gameObject:SetActive(false)
		self.BuyChallengeButton.gameObject:SetActive(true)
	end

end


---------------------------------------------------------------------
function ArenaCls:ResetChallenge()
	if self.cdTime > 0 then
		self.ArenaRefreshButton.gameObject:SetActive(false)
		self.ResetChallengeButton.gameObject:SetActive(true)		
		--self.RestTimeTrans:SetActive(true)
		--self:Countdown()
	end
end

function ArenaCls:Countdown()
	-- 挑战时间倒计时
	if self.RestTimeTrans.activeSelf then
		
		if self.cdTime == nil then
			return true
		end
		
		self.cdTime = self.cdTime - UnityEngine.Time.deltaTime
		
		if self.cdTime < 0 then
			self.cdTime = 0
			self:UpdateCountdownView()
		end

		self.RestTimeLabel.text = utility.ConvertTime(self.cdTime)
	end
end

function ArenaCls:UpdateCountdownView()
	-- 倒计时显示设置 清空倒计时
	self.cdTime = 0
	self.RestTimeTrans:SetActive(false)
	self.ResetChallengeButton.gameObject:SetActive(false)
	self.ArenaRefreshButton.gameObject:SetActive(true)
end

function ArenaCls:RefreshTargetView(msg,arenaTitleData)
	-- 刷新目标显示
	local targetInfo = msg.playerSimpleInfo
	debug_print("@@@",#targetInfo)
	for i=1,#targetInfo do
		 debug_print("@@@2",targetInfo[i].playerName)
		self.targetLvNums[i].text = targetInfo[i].level
		self.targetNames[i].text = targetInfo[i].playerName
		self.rankNums[i].text = targetInfo[i].rank
		self.strengthNums[i].text = targetInfo[i].zhanli
		self.rankLabels[i].text = arenaTitleData:GetData(targetInfo[i].junxian):GetName()

		-- 设置玩家头像
		utility.LoadPlayerHeadIcon(targetInfo[i].headCardID,self.headIcons[i])
	end
	
end

function ArenaCls:RefeshFormation()
	-- 刷新防守上阵阵容
	print('刷新防守上阵阵容')
	self.formations = {}
	local roleNodeCls = require "GUI.Arena.FormationItem"
	local emptyNodeCls = require "GUI.Arena.EmptyFormationNode"
	local node
	local layout

	local UserDataType = require "Framework.UserDataType"
   
    local cardBagData = self:GetCachedData(UserDataType.CardBagData)
    local arenaDefence = cardBagData:GetTroopByLineup(kLineup_ArenaDefence)

    -- 上阵阵容
  --	local arenaDefenceFormation = {}

  	local power = 0
    local count = 0
    for i=1,#arenaDefence do
    	
    	if i < 4 then
    		layout = self.LayoutFront
    	else
    		layout = self.LayoutBack
    	end

    	if arenaDefence[i] ~= 0 then
    		local uid = arenaDefence[i]
    		local data = cardBagData:GetRoleByUid(uid)
    		power = power + data:GetPower()
    		count = count + 1
    		node = roleNodeCls.New(layout,i,true)
    		node:ResetView(data)
    	else
    		node = emptyNodeCls.New(layout)
    	end
    	self:AddChild(node)
    	self.formations[#self.formations + 1] = node
    end
    print("阵容长度",#self.formations)
    
    --self.arenaDefenceFormation = arenaDefenceFormation
	--self.arenaDefenceCount = count
	--self.FormationHintLabel:SetActive(count==0)

	
	-- for i=1,self.arenaDefenceCount do
	-- 	local data = cardBagData:GetRoleByUid(self.arenaDefenceFormation[i])
	-- 	self:AddChild(self.formations[i])
	-- 	self.formations[i]:ResetView(data)

	-- 	power = power + data:GetPower()
	-- end

	self.StrengthNumLabelMine.text = power
	--self.formationLeftShow = true
end

function ArenaCls:HideCardFormation()
	-- 隐藏竞技场卡牌阵容
	for i=1,6 do
		self:RemoveChild(self.formations[i],true)
	end
end


return ArenaCls