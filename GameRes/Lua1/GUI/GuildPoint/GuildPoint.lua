local BaseNodeClass = require "Framework.Base.UIScene"
local utility = require "Utils.Utility"
local net = require "Network.Net"
require "LUT.StringTable"
require "Const"
local BattleUtility = require "Utils.BattleUtility"

local GuildPointCls = Class(BaseNodeClass)

function GuildPointCls:Ctor()
	
end

local windState = 1 --风组
local fireState = 2 --火组
local waterState = 3 --水组
local soilState = 4 --土组
local guildState = 5 --军团
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function GuildPointCls:OnInit()
	--加载界面
	utility.LoadNewGameObjectAsync("UI/Prefabs/GuildPointFight",function(go)
		self:BindComponent(go)
	end)
end

function GuildPointCls:OnComponentReady()
	--界面加载完成
	self:InitControls()
end

function GuildPointCls:OnResume()
	--界面显示时调用
	GuildPointCls.base.OnResume(self)
	require "Utils.GameAnalysisUtils".EnterScene("军团积分战界面")
	require "Utils.GameAnalysisUtils".RecordLocalAction(kTrackingId_GuildPointView)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:GHPointQueryRequest()
	self:GHPointMilestoneQueryRequest()
	-- self:OnRankGroupButton1Clicked()
	self:ScheduleUpdate(self.Update)
end

function GuildPointCls:OnPause()
	GuildPointCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function GuildPointCls:OnEnter()
	GuildPointCls.base.OnEnter(self)
end

function GuildPointCls:OnExit()
	GuildPointCls.base.OnExit(self)
end

function GuildPointCls:Update()
	self:UpdateTime()
end

-------------------------------------------------------------------
--- 控件相关
-------------------------------------------------------------------

-- 控件绑定
function GuildPointCls:InitControls()
	local transform = self:GetUnityTransform()

	self.returnButton = transform:Find("ReturnButton"):GetComponent(typeof(UnityEngine.UI.Button))
	--分组控制按钮
	self.rankGroupButton = {} --分组按钮
	self.rankGroupOn = {} --状态开
	self.rankGroupOff = {} --状态关
	self.rank = transform:Find("Rank/Tags")
	for i=1,5 do
		self.rankGroupButton[i] = self.rank:Find("Tag"..i):GetComponent(typeof(UnityEngine.UI.Button))
		self.rankGroupOn[i] = self.rank:Find("Tag"..i.."/On")
		self.rankGroupOff[i] = self.rank:Find("Tag"..i.."/Off")
	end
	self.childPoint = transform:Find("Rank/Scroll View/Viewport/Content")

	--挑战
	self.challenge = transform:Find("Rival")
	self.challengeTimes = self.challenge:Find("Times/ChallengeTimes"):GetComponent(typeof(UnityEngine.UI.Text))
	self.challengeButton = self.challenge:Find("Times/Button"):GetComponent(typeof(UnityEngine.UI.Button))
	self.ReserveTimes = self.challenge:Find("ReserveTimes")
	self.timesReserveTime = self.challenge:Find("ReserveTimeLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.LastingTimes = self.challenge:Find("LastingTimes")
	self.refreshReserveTime = self.challenge:Find("LastingTimeLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.reportButton = transform:Find("Layout/ReportButton"):GetComponent(typeof(UnityEngine.UI.Button)) --战报
	self.rankButton = transform:Find("Layout/RankButton"):GetComponent(typeof(UnityEngine.UI.Button))
	self.buyButton = transform:Find("Layout/BuyButton"):GetComponent(typeof(UnityEngine.UI.Button))
	self.instructiontButton = transform:Find("Rival/InstructiontButton"):GetComponent(typeof(UnityEngine.UI.Button))
	self.formationButton = transform:Find("Layout/FormationButton"):GetComponent(typeof(UnityEngine.UI.Button))

	--挑战目标
	self.rivalItem = {}
	self.roleLv = {}
	self.roleName = {}
	self.roleGuildName = {}
	self.rolePoint = {}
	self.roleHeader = {}
	self.roleSameGroup = {}
	self.roleDiffGroup = {}
	self.roleChallengeButton = {}
	for i=1,3 do
		self.rivalItem[i] = self.challenge:Find("RivalItem"..i)
		self.roleLv[i] = self.rivalItem[i]:Find("LvLabel"):GetComponent(typeof(UnityEngine.UI.Text))
		self.roleName[i] = self.rivalItem[i]:Find("NameLabel"):GetComponent(typeof(UnityEngine.UI.Text))
		self.roleGuildName[i] = self.rivalItem[i]:Find("GuildNameLabel"):GetComponent(typeof(UnityEngine.UI.Text))
		self.rolePoint[i] = self.rivalItem[i]:Find("PointLabel"):GetComponent(typeof(UnityEngine.UI.Text))
		self.roleHeader[i] =self.rivalItem[i]:Find("Head/Base/PersonalInformationHeadIcon"):GetComponent(typeof(UnityEngine.UI.Image))
		self.roleSameGroup[i] =self.rivalItem[i]:Find("Group/Same")
		self.roleDiffGroup[i] = self.rivalItem[i]:Find("Group/Different")
		self.roleChallengeButton[i] = self.rivalItem[i]:Find("FightButton"):GetComponent(typeof(UnityEngine.UI.Button))
	end

	--刷新
	self.refreshButton = self.challenge:Find("ChangeButton"):GetComponent(typeof(UnityEngine.UI.Button))
	self.refreshImage = self.refreshButton:GetComponent(typeof(UnityEngine.UI.Image))
	self.refreshFree = self.challenge:Find("ChangeButton/FreeText"):GetComponent(typeof(UnityEngine.UI.Text))
	self.refreshDiamonds = self.challenge:Find("ChangeButton/DiamondsRefresh")
	self.refreshDiamondImage = self.refreshDiamonds:Find("Image"):GetComponent(typeof(UnityEngine.UI.Image))
	self.refreshDiamondText = self.refreshDiamonds:Find("Text"):GetComponent(typeof(UnityEngine.UI.Text))

	--里程碑
	self.milestone = transform:Find("Milestone")
	self.milestoneFill = self.milestone:Find("Base/Fill"):GetComponent(typeof(UnityEngine.RectTransform))
	self.fillRectTransform = self.milestoneFill:GetComponent(typeof(UnityEngine.RectTransform))
	self.milestoneBox = {}
	self.milestoneImage = {}
	self.milestoneLabel = {}
	for i=1,3 do
		self.milestoneBox[i] = self.milestone:Find("Box"..i):GetComponent(typeof(UnityEngine.UI.Button))
		self.milestoneImage[i] = self.milestoneBox[i].transform:GetComponent(typeof(UnityEngine.UI.Image))
		self.milestoneLabel[i] = self.milestoneBox[i].transform:Find("Stone"):GetComponent(typeof(UnityEngine.UI.Text))
	end
	self.pos = self.milestoneFill.transform.localPosition
	self.width = self.fillRectTransform.sizeDelta

	self.myGame = utility:GetGame()
	self.GrayMaterial = utility.GetGrayMaterial()
	
	self.lastTime = 0
	self.CDlastTime = 0
end

function GuildPointCls:RegisterControlEvents()
	--注册退出事件
	self._event_button_onReturnButtonClicked_ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked,self)
	self.returnButton.onClick:AddListener(self._event_button_onReturnButtonClicked_)

	--注册分组事件
	self._event_button_onRankGroupButtonClicked_ = {}
	self.OnRankGroupButtonClicked = {}
	self.OnRankGroupButtonClicked[1] = self.OnRankGroupButton1Clicked
	self.OnRankGroupButtonClicked[2] = self.OnRankGroupButton2Clicked
	self.OnRankGroupButtonClicked[3] = self.OnRankGroupButton3Clicked
	self.OnRankGroupButtonClicked[4] = self.OnRankGroupButton4Clicked
	self.OnRankGroupButtonClicked[5] = self.OnRankGroupButton5Clicked
	for i=1,#self.OnRankGroupButtonClicked do
		self._event_button_onRankGroupButtonClicked_[i] = UnityEngine.Events.UnityAction(self.OnRankGroupButtonClicked[i],self)
		self.rankGroupButton[i].onClick:AddListener(self._event_button_onRankGroupButtonClicked_[i])
	end

	--注册挑战事件
	self._event_button_onRoleChallengeButtonClicked_ = {}
	self.OnRoleChallengeButtonClicked = {}
	self.OnRoleChallengeButtonClicked[1] = self.OnRoleChallengeButton1Clicked
	self.OnRoleChallengeButtonClicked[2] = self.OnRoleChallengeButton2Clicked
	self.OnRoleChallengeButtonClicked[3] = self.OnRoleChallengeButton3Clicked
	for i=1,#self.OnRoleChallengeButtonClicked do
		self._event_button_onRoleChallengeButtonClicked_[i] = UnityEngine.Events.UnityAction(self.OnRoleChallengeButtonClicked[i],self)
		self.roleChallengeButton[i].onClick:AddListener(self._event_button_onRoleChallengeButtonClicked_[i])
	end

	--注册里程碑事件
	self._event_button_onMilestoneBoxClicked_ = {}
	self.OnMileStoneButtonClicked = {}
	self.OnMileStoneButtonClicked[1] = self.OnMileStoneButton1Clicked
	self.OnMileStoneButtonClicked[2] = self.OnMileStoneButton2Clicked
	self.OnMileStoneButtonClicked[3] = self.OnMileStoneButton3Clicked
	for i=1,#self.OnRoleChallengeButtonClicked do
		self._event_button_onMilestoneBoxClicked_[i] = UnityEngine.Events.UnityAction(self.OnMileStoneButtonClicked[i],self)
		self.milestoneBox[i].onClick:AddListener(self._event_button_onMilestoneBoxClicked_[i])
	end

	--注册刷新对手事件
	self._event_button_onRefreshButtonClicked_ = UnityEngine.Events.UnityAction(self.OnRefreshButtonClicked,self)
	self.refreshButton.onClick:AddListener(self._event_button_onRefreshButtonClicked_)

	--注册添加挑战次数事件
	self._event_button_onChallengeButtonClicked_ = UnityEngine.Events.UnityAction(self.OnChallengeButtonClicked,self)
	self.challengeButton.onClick:AddListener(self._event_button_onChallengeButtonClicked_)

	--注册战报事件
	self._event_button_onReportButtonClicked_ = UnityEngine.Events.UnityAction(self.OnReportButtonClicked,self)
	self.reportButton.onClick:AddListener(self._event_button_onReportButtonClicked_)

	--注册排行榜事件
	self._event_button_onRankButtonClicked_ = UnityEngine.Events.UnityAction(self.OnRankButtonClicked,self)
	self.rankButton.onClick:AddListener(self._event_button_onRankButtonClicked_)

	--注册商店事件
	self._event_button_onBuyButtonClicked_ = UnityEngine.Events.UnityAction(self.OnBuyButtonClicked,self)
	self.buyButton.onClick:AddListener(self._event_button_onBuyButtonClicked_)

	--注册阵容事件
	self._event_button_onFormationButtonClicked_ = UnityEngine.Events.UnityAction(self.OnFormationButtonClicked,self)
	self.formationButton.onClick:AddListener(self._event_button_onFormationButtonClicked_)

	--注册说明事件
	self._event_button_onInstructiontButtonClicked_ = UnityEngine.Events.UnityAction(self.OnInstructiontButtonClicked,self)
	self.instructiontButton.onClick:AddListener(self._event_button_onInstructiontButtonClicked_)
end

function GuildPointCls:UnregisterControlEvents()
	--取消注册退出事件
	if self._event_button_onReturnButtonClicked_ then
		self.returnButton.onClick:RemoveListener(self._event_button_onReturnButtonClicked_)
		self._event_button_onReturnButtonClicked_ = nil
	end

	--取消注册分组事件
	for i=1,#self._event_button_onRankGroupButtonClicked_ do
		if self._event_button_onRankGroupButtonClicked_[i] then
			self.rankGroupButton[i].onClick:RemoveListener(self._event_button_onRankGroupButtonClicked_[i])
			self._event_button_onRankGroupButtonClicked_[i] = nil
		end
	end

	--取消注册挑战事件
	for i=1,#self._event_button_onRoleChallengeButtonClicked_ do
		if self._event_button_onRoleChallengeButtonClicked_[i] then
			self.roleChallengeButton[i].onClick:RemoveListener(self._event_button_onRoleChallengeButtonClicked_[i])
			self._event_button_onRoleChallengeButtonClicked_[i] = nil
		end
	end

	--取消注册里程碑事件
	for i=1,#self._event_button_onMilestoneBoxClicked_ do
		if self._event_button_onMilestoneBoxClicked_[i] then
			self.milestoneBox[i].onClick:RemoveListener(self._event_button_onMilestoneBoxClicked_[i])
			self._event_button_onMilestoneBoxClicked_[i] = nil
		end
	end

	--取消注册刷新对手事件
	if self._event_button_onRefreshButtonClicked_ then
		self.refreshButton.onClick:RemoveListener(self._event_button_onRefreshButtonClicked_)
		self._event_button_onRefreshButtonClicked_ = nil
	end

	--取消注册添加挑战次数事件
	if self._event_button_onChallengeButtonClicked_ then
		self.challengeButton.onClick:RemoveListener(self._event_button_onChallengeButtonClicked_)
		self._event_button_onChallengeButtonClicked_ = nil
	end

	--取消注册战报事件
	if self._event_button_onReportButtonClicked_ then
		self.reportButton.onClick:RemoveListener(self._event_button_onReportButtonClicked_)
		self._event_button_onReportButtonClicked_ = nil
	end

	--取消注册排行榜事件
	if self._event_button_onRankButtonClicked_ then
		self.rankButton.onClick:RemoveListener(self._event_button_onRankButtonClicked_)
		self._event_button_onRankButtonClicked_ = nil
	end

	--取消注册商店事件
	if self._event_button_onBuyButtonClicked_ then
		self.buyButton.onClick:RemoveListener(self._event_button_onBuyButtonClicked_)
		self._event_button_onBuyButtonClicked_ = nil
	end

	--取消注册阵容事件
	if self._event_button_onFormationButtonClicked_ then
		self.formationButton.onClick:RemoveListener(self._event_button_onFormationButtonClicked_)
		self._event_button_onFormationButtonClicked_ = nil
	end

	--取消注册说明事件
	if self._event_button_onInstructiontButtonClicked_ then
		self.instructiontButton.onClick:RemoveListener(self._event_button_onInstructiontButtonClicked_)
		self._event_button_onInstructiontButtonClicked_ = nil
	end
end

function GuildPointCls:RegisterNetworkEvents()
	self.myGame:RegisterMsgHandler(net.S2CGHPointQueryResult,self,self.GHPointQueryResult)
	self.myGame:RegisterMsgHandler(net.S2CGHPointGroupResult,self,self.GHPointGroupResult)
	self.myGame:RegisterMsgHandler(net.S2CGHPointBuyChallengeResult,self,self.GHPointBuyChallengeResult)
	self.myGame:RegisterMsgHandler(net.S2CGHPointClearCDResult,self,self.GHPointClearCDResult)
	self.myGame:RegisterMsgHandler(net.S2CGHPointMilestoneQueryResult,self,self.GHPointMilestoneQueryResult)
	self.myGame:RegisterMsgHandler(net.S2CGHPointHistoryResult,self,self.GHPointHistoryResult)
end

function GuildPointCls:UnregisterNetworkEvents()
	self.myGame:UnRegisterMsgHandler(net.S2CGHPointQueryResult,self,self.GHPointQueryResult)
	self.myGame:UnRegisterMsgHandler(net.S2CGHPointGroupResult,self,self.GHPointGroupResult)
	self.myGame:UnRegisterMsgHandler(net.S2CGHPointBuyChallengeResult,self,self.GHPointBuyChallengeResult)
	self.myGame:UnRegisterMsgHandler(net.S2CGHPointClearCDResult,self,self.GHPointClearCDResult)
	self.myGame:UnRegisterMsgHandler(net.S2CGHPointMilestoneQueryResult,self,self.GHPointMilestoneQueryResult)
	self.myGame:UnRegisterMsgHandler(net.S2CGHPointHistoryResult,self,self.GHPointHistoryResult)
end

function GuildPointCls:GHPointQueryRequest()
	self.myGame:SendNetworkMessage( require "Network/ServerService".GHPointQueryRequest())
end

--分组
function GuildPointCls:GHPointGroupRequest(groupId)
	self.myGame:SendNetworkMessage( require"Network/ServerService".GHPointGroupRequest(groupId))
end

--战报
function GuildPointCls:GHPointHistoryRequest()
	self.myGame:SendNetworkMessage( require "Network/ServerService".GHPointHistoryRequest())
end

--购买挑战次数
function GuildPointCls:GHPointBuyChallengeRequest()
	self.myGame:SendNetworkMessage( require "Network/ServerService".GHPointBuyChallengeRequest())
end

--刷新挑战对手
function GuildPointCls:GHPointClearCDRequest()
	self.myGame:SendNetworkMessage( require "Network/ServerService".GHPointClearCDRequest())
end

--里程碑
function GuildPointCls:GHPointMilestoneQueryRequest()
	self.myGame:SendNetworkMessage( require "Network/ServerService".GHPointMilestoneQueryRequest())
end

function GuildPointCls:GHPointMilestoneQueryResult(msg)
	self:LoadMilestone(msg)
	self:SetMilestone(msg.wincount)
end

function GuildPointCls:GHPointQueryResult(msg)
	self.msg = msg
	self:RefreshRivalItem(msg)
end

function GuildPointCls:GHPointGroupResult(msg)
	self:LoadRankItem(msg)
end

function GuildPointCls:GHPointHistoryResult(msg)
	self:OpenReportPanel(msg)
end

function GuildPointCls:GHPointClearCDResult(msg)
	self.CDlastTime = 0
	self:GHPointQueryRequest()
end


function GuildPointCls:GHPointBuyChallengeResult(msg)
	self.lastTime =0
	self.reserveCDTime = msg.reserveTime
	self.challengeTimes.text = msg.challengeRemain.."/"..msg.challengeTotal
	self.challenge = msg.challengeRemain
end

function GuildPointCls:LoadMilestone(data)
	self.id = data.tableid
	self.state = data.status
	if self.state ~= nil then 
		self:GetMilestoneState(self.id,self.state)
	end
end

function GuildPointCls:GetMilestoneState(id,data)
	local MileStone = require "StaticData.PointFightMileStone"
	local keys = MileStone:GetKeys()
	for i=0,(keys.Length - 1) do
		self.milestoneImage[i+1].material = self.GrayMaterial
	end
	for i=1,#id do
		if data[i] == 1 then
			self.milestoneImage[i].material = utility.GetCommonMaterial()
		end
	end
end

--走S2CGHPointQueryResult协议
function GuildPointCls:RefreshRivalItem(data)
	self.refreshCDTime = data.refreshCDTime --按钮刷新时间
	self.reserveCDTime = data.reserveCDTime --次数恢复时间
	self.isFreeRefresh = data.isFreeRefresh
	self.data = data 
	self.playerGroup = data.playerGroup
	if self.playerGroup == 1 then
		self:OnRankGroupButton1Clicked()
	elseif self.playerGroup == 2 then
		self:OnRankGroupButton2Clicked()
	elseif self.playerGroup == 3 then
		self:OnRankGroupButton3Clicked()
	elseif self.playerGroup == 4 then
		self:OnRankGroupButton4Clicked()
	elseif self.playerGroup == 5 then
		self:OnRankGroupButton5Clicked()
	end
	self.challenge = data.challengeTimes
	self.challengeTotal = data.challengeTotal
	self.challengeTimes.text = data.challengeTimes.."/"..data.challengeTotal
	local player = data.ghPointMember
	for i=1,#player do
		self.roleLv[i].text = "Lv."..player[i].ghPointGroup.playerLv
		self.rolePoint[i].text = player[i].ghPointGroup.point
		self.roleName[i].text = player[i].ghPointGroup.name
		self.roleGuildName[i].text = player[i].ghPointGroup.guildName
		-- 设置玩家头像
		if player[i].ghPointGroup.playerHead ~= 0 then
			utility.LoadRoleHeadIcon(player[i].ghPointGroup.playerHead,self.roleHeader[i])
		end
		-- debug_print(player[i].isSameGroup)
		if player[i].isSameGroup then
			self.roleSameGroup[i].gameObject:SetActive(true)
			self.roleDiffGroup[i].gameObject:SetActive(false)
		else
			self.roleSameGroup[i].gameObject:SetActive(false)
			self.roleDiffGroup[i].gameObject:SetActive(true)
		end
	end
	if self.isFreeRefresh == 1 then
		self.refreshFree.gameObject:SetActive(true)
		self.refreshDiamonds.gameObject:SetActive(false)
	else
		self.refreshFree.gameObject:SetActive(false)
		self.refreshDiamonds.gameObject:SetActive(true)
	end
	
end

function GuildPointCls:SetCDRefresh()
	-- if tonumber(self.refreshCDTime) > 0 then
	-- 	self:SetMaterial(self.GrayMaterial)
	-- else
	-- 	self:SetMaterial(nil)
	-- end
end

function GuildPointCls:SetMaterial(GrayMaterial)
	self.refreshImage.material = GrayMaterial
	self.refreshDiamondImage.material = GrayMaterial
	
end

function GuildPointCls:SetMilestone(dekaronTimes)
	if dekaronTimes ~= nil then
		-- debug_print("Milestone:"..dekaronTimes)
		local data = dekaronTimes/require "StaticData.PointFightMileStone":GetData(3):GetWins()
		if data >= 1 then
			data = 1
		end
		local width = self.width.x * data
		local posX = self.pos.x + width/2 - self.width.x/2
		self.milestoneFill.localPosition = Vector2(posX,self.pos.y)
		self.fillRectTransform.sizeDelta = Vector2(width,self.width.y)
		for i=1,#self.milestoneLabel do
			local milestoneData = require "StaticData.PointFightMileStone":GetData(i)
			self.milestoneLabel[i].text = dekaronTimes.."/"..milestoneData:GetWins()
		end
	end
end

function GuildPointCls:OnReturnButtonClicked()
	local sceneManager = utility:GetGame():GetSceneManager()
	sceneManager:PopScene()
end

function GuildPointCls:OnRankGroupButton1Clicked()
	self:ShowGroupOn(windState)
end

function GuildPointCls:OnRankGroupButton2Clicked()
	self:ShowGroupOn(fireState)
end

function GuildPointCls:OnRankGroupButton3Clicked()
	self:ShowGroupOn(waterState)
end

function GuildPointCls:OnRankGroupButton4Clicked()
	self:ShowGroupOn(soilState)
end

function GuildPointCls:OnRankGroupButton5Clicked()
	self:ShowGroupOn(guildState)

end

function  GuildPointCls:OnRefreshButtonClicked()
	if self.isFreeRefresh then
		self:RefreshRequest()
	else
		local diamonds = require "StaticData.SystemConfig.SystemConfig":GetData(8):GetParameNum()[0]
		local str = string.format(PointFight[0],diamonds)
		self:ShowDialogPanel(str,self.RefreshRequest)
	end
end

--挑战次数
function GuildPointCls:OnChallengeButtonClicked()
	if self.data.challengeTimes < self.data.challengeTotal  then
		local diamonds = require "StaticData.SystemConfig.SystemConfig":GetData(9):GetParameNum()[0]
		local str = string.format(PointFight[1],diamonds)
		self:ShowDialogPanel(str,self.AddTimesRequest)
	else
		local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
        local windowManager = utility.GetGame():GetWindowManager()
        local hintStr = string.format("挑战次数已满")
        windowManager:Show(ErrorDialogClass, hintStr)
	end
end

--战报
function GuildPointCls:OnReportButtonClicked()
	self:GHPointHistoryRequest()
end

function GuildPointCls:OpenReportPanel(data)
	local windowManager = utility.GetGame():GetWindowManager()
	windowManager:Show(require "GUI.GuildPoint.ReportInfo",kReportGuildPointFighe,data.history)
end

--排行榜
function GuildPointCls:OnRankButtonClicked()
	local windowManager = self.myGame:GetWindowManager()
    windowManager:Show(require "GUI.Arena.ArenaRank",kGuildFightRank)
end

--商店
function GuildPointCls:OnBuyButtonClicked()
	local windowManager = utility.GetGame():GetWindowManager()
	windowManager:Show(require "GUI.Shop.Shop",KShopType_GuildPoint)
end

function GuildPointCls:OnInstructiontButtonClicked()
	local str = utility.GetDescriptionStr(kSystemBasis_GuildPointID)
	local windowManager = self.myGame:GetWindowManager()
    windowManager:Show(require "GUI.CommonDescriptionModule",str)
end

function GuildPointCls:OnFormationButtonClicked()
	print("阵容")
	local sceneManager = self:GetGame():GetSceneManager()

    local FormationCls = require "GUI.Formation.Formation".New(kLineup_GuildPointDefence,self.SetConfirmMethod,self)
    sceneManager:PushScene(FormationCls)
end

function GuildPointCls:SetConfirmMethod()
end

--挑战对手
function GuildPointCls:OnRoleChallengeButton1Clicked()
	self:ChallengeButtonEvent(1)
end

function GuildPointCls:OnRoleChallengeButton2Clicked()
	self:ChallengeButtonEvent(2)
end

function GuildPointCls:OnRoleChallengeButton3Clicked()
	self:ChallengeButtonEvent(3)
end

--里程碑
function GuildPointCls:OnMileStoneButton1Clicked()
	self:OpenMileStone(1)
end

function GuildPointCls:OnMileStoneButton2Clicked()
	self:OpenMileStone(2)
end

function GuildPointCls:OnMileStoneButton3Clicked()
	self:OpenMileStone(3)
end

function GuildPointCls:OpenMileStone(index)
	if self.state[index] ~= nil then
		if self.state[index] == 1 then
			local windowManager = utility.GetGame():GetWindowManager()
			windowManager:Show(require "GUI.GuildPoint.GuildMilestone",index)
		end
	end
end

function  GuildPointCls:ShowDialogPanel(str,func)
	local windowManager = self:GetGame():GetWindowManager()
	local ConfirmDialogClass = require "GUI.Dialogs.ConfirmDialog"
	windowManager:Show(ConfirmDialogClass,str,self,func)
end

--刷新协议
function GuildPointCls:RefreshRequest()
	if tonumber(self.refreshCDTime) > 0 then
		local str =  "未到刷新时间"

		local windowManager = utility:GetGame():GetWindowManager()
   		local ConfirmDialogClass = require "GUI.Dialogs.ErrorDialog"
		windowManager:Show(ConfirmDialogClass, str)
	else
		self:GHPointClearCDRequest()
	end
end

--添加挑战次数
function GuildPointCls:AddTimesRequest()
	self:GHPointBuyChallengeRequest()
end

function GuildPointCls:ShowGroupOn(index)
	self:HideAllGroupOn()
	self.rankGroupOn[index].gameObject:SetActive(true)
	self.rankGroupOff[index].gameObject:SetActive(false)
	for i=1,#self.rankGroupButton do
		self.rankGroupButton[i].transform:SetAsFirstSibling()
	end
	-- self.rankGroupButton[index].transform:SetAsFirstSibling()
	self.rankGroupButton[index].transform:SetAsLastSibling()
	self:GHPointGroupRequest(index)
end

function GuildPointCls:HideAllGroupOn()
	for i=1,5 do
		self.rankGroupOn[i].gameObject:SetActive(false)
		self.rankGroupOff[i].gameObject:SetActive(true)
	end
end

--走S2CGHPointGroupResult协议
function GuildPointCls:LoadRankItem(data)
	local groupTtable = {}
	local isInRank = false
	local isGuild = false
	if data.groupId == guildState then
		isGuild = true
		for i=1,#data.guildRank do
				groupTtable[i] = {}
				groupTtable[i] = data.guildRank[i]
		end
		for i=1,#data.guildRank do
			if data.playerGuild.rank == data.guildRank[i].rank then
				isInRank = true
				break
			end
		end
		if not isInRank then
			if data.playerGuild.rank ~= 0 then
				groupTtable[#groupTtable + 1] = data.playerGuild
			end
		end
		
		-- debug_print("groupTtable",#groupTtable)
	else
		isGuild = false
		if #data.groupRank ~= 0 then
			
			for i=1,#data.groupRank do
				groupTtable[i] = {}
				groupTtable[i] = data.groupRank[i]
			end
			if self.playerGroup == data.groupId then
				for i=1,#data.groupRank do
					if data.playerRank.rank == data.groupRank[i].rank then
						isInRank = true
						break
					end
				end
			end
		end
		if not isInRank and self.playerGroup == data.groupId and data.playerRank.rank ~= 0 then
			groupTtable[#groupTtable + 1] = data.playerRank
		end
	end
	self:SortTable(groupTtable)
	self:ShowRankItem(groupTtable,isGuild)
end


function GuildPointCls:ShowRankItem(itemTable,isGuild)
	self:RemoveAll()
	self.node = {}
	for i=1,#itemTable do
		local guildPointItem = require "GUI.GuildPoint.GuildPoinGroupItem".New(self.childPoint,itemTable[i],isGuild)
		self.node[i] = guildPointItem
		self:AddChild(guildPointItem)
	end
end

function GuildPointCls:RemoveAll()
	if self.node ~= nil then
		for i=1,#self.node do
			self:RemoveChild(self.node[i],true)
		end
	end
end

local function ComparisonPlayerIsNPC(uid)
	-- 查看对手是否为npc
	local StringUtility = require "Utils.StringUtility"
	local array = StringUtility.CreateArray(uid)
	local str = string.format("%s%s%s",array[1],array[2],array[3])
	return str == "npc"
end

function GuildPointCls:ChallengeButtonEvent(id)
	-- 挑战按钮事件
	if self.challenge < 1 then
		local str =  CommonStringTable[5]

		local windowManager = utility:GetGame():GetWindowManager()
   		local ConfirmDialogClass = require "GUI.Dialogs.ErrorDialog"
		windowManager:Show(ConfirmDialogClass, str)
		return
	end
	-- local isCan = self:RetrievalCanChallenge()
	-- if isCan then
	-- 	return
	-- end
	self.isSeam = self.data.ghPointMember[id].isSameGroup
	self.challengeTeam = self.data.ghPointMember[id].items
	self.challengeUID = self.data.ghPointMember[id].ghPointGroup.playerUID
	-- local isNpc = ComparisonPlayerIsNPC(self.challengeUID)
	-- if isNpc then
	-- 	self.challengeUID = tonumber(string.sub(self.challengeUID,5))
	-- 	print(self.challengeUID)
	-- end
	local windowManager = self.myGame:GetWindowManager()
   	windowManager:Show(require "GUI.Formation.ArenaEnemyFormation",nil,self.data.ghPointMember[id].items,self.data.ghPointMember[id].power,self.SelectCardInArenaFight,self)
end

function GuildPointCls:GetFoeTeam()
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

function GuildPointCls:SelectCardInArenaFight()
	-- 挑战选择阵容
	print("挑战选择阵容！！！")
 	local LocalDataType = require "LocalData.LocalDataType" 
    local ServerService = require "Network.ServerService"
    print(type(self.challengeUID))
    local foeTeams = self:GetFoeTeam()

    local battleParams = require "LocalData.Battle.BattleParams".New()
	battleParams:SetSceneID(2)
	battleParams:SetScriptID(nil)
	battleParams:SetBattleType(kLineup_GuildPointAttack)
	battleParams:SetBattleOverLocalDataName(LocalDataType.GuildPointResult)
	battleParams:SetBattleStartProtocol(ServerService.GHPointFightQueryRequest(self.challengeUID,self.isSeam))
	battleParams:SetBattleResultResponsePrototype(net.S2CGHPointFightOverResult)
	battleParams:SetBattleResultViewClassName("GUI.GuildPoint.GuildPointFightResult")
	battleParams:SetMaxBattleRounds(30)
	battleParams:SetBattleResultWhenReachMaxRounds(false)
	battleParams:SetPVPMode(true)
	battleParams:SetSkillRestricted(false)
	battleParams:SetUnlimitedRage(false)
	
	utility.StartBattle(battleParams, foeTeams, nil)
end

function GuildPointCls:RetrievalCanChallenge()
	-- 检查是否可以挑战
	local isCan = true
	if self.data.challengeTimes < 1 then
		isCan = false
		local str =  CommonStringTable[5]

		local windowManager = utility:GetGame():GetWindowManager()
   		local ConfirmDialogClass = require "GUI.Dialogs.ErrorDialog"
		windowManager:Show(ConfirmDialogClass, str)

	else
		isCan = false
	end

	return isCan

end

function  GuildPointCls:UpdateTime()
	if self.reserveCDTime ~= nil then
		if tonumber(self.reserveCDTime) <= 0 then
			-- self:GHPointQueryRequest()
			self.ReserveTimes.gameObject:SetActive(false)
			self.timesReserveTime.gameObject:SetActive(false)
			if self.challenge < self.challengeTotal then
				self:GHPointQueryRequest()
			end
		else
			self.ReserveTimes.gameObject:SetActive(true)
			self.timesReserveTime.gameObject:SetActive(true)
		--	self.countTime=self.countTime-Time.deltaTime
			if os.time() - self.lastTime >= 1 then
				self.lastTime = os.time()
				self.reserveCDTime = self.reserveCDTime - 1
			end
			self.timesReserveTime.text = utility.ConvertTime(self.reserveCDTime)
		end	
	end
	-- print(tonumber(self.reserveCDTime))
	if self.refreshCDTime ~= nil then
		if tonumber(self.refreshCDTime) <= 0 then
			self.LastingTimes.gameObject:SetActive(false)
			self.refreshReserveTime.gameObject:SetActive(false)
			self:SetMaterial(utility.GetCommonMaterial())
			self.refreshFree.material = utility.GetCommonMaterial("Text")
			self.refreshDiamondText.material = utility.GetCommonMaterial("Text")
		else
			self.LastingTimes.gameObject:SetActive(true)
			self.refreshReserveTime.gameObject:SetActive(true)
		--	self.countTime=self.countTime-Time.deltaTime
			if os.time() - self.CDlastTime >= 1 then
				self.CDlastTime = os.time()
				self.refreshCDTime = self.refreshCDTime - 1
				self:SetMaterial(self.GrayMaterial)
				self.refreshFree.material = utility.GetGrayMaterial("Text")
				self.refreshDiamondText.material = utility.GetGrayMaterial("Text")
			end
			self.refreshReserveTime.text = utility.ConvertTime(self.refreshCDTime)
		end	
	end
end

function GuildPointCls:SortTable(tables)
    table.sort(tables, function(key1, key2)
    	if key2 ~= nil then
       		return key1.rank < key2.rank
       	end
    end)

    return tables
end

return GuildPointCls