local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"
require "Const"
require "LUT.StringTable"

local ReportInfoItemCls = Class(BaseNodeClass)

function ReportInfoItemCls:Ctor(parent,reportType,data)
	self.parent = parent
	self.reportType = reportType
	self.data = data
end


function  ReportInfoItemCls:OnInit()
	utility.LoadNewGameObjectAsync("UI/Prefabs/BattleReportItem",function(go)
		self:BindComponent(go)
	end)
end

function ReportInfoItemCls:OnComponentReady()
	self:InitControls()
	self:LinkComponent(self.parent)
end

function ReportInfoItemCls:OnResume()
	ReportInfoItemCls.base.OnResume(self)
	self:RegisterControlEvents()
	-- self:RegisterNetworkEvents()
	self:ShowReportPanel()
end

function ReportInfoItemCls:OnPause()
	ReportInfoItemCls.base.OnPause(self)
	self:UnregisterControlEvents()
	-- self:UnregisterNetworkEvents()
end

function ReportInfoItemCls:OnEnter()
	ReportInfoItemCls.base.OnEnter(self)
end

function ReportInfoItemCls:OnExit()
	ReportInfoItemCls.base.OnExit(self)
end

function ReportInfoItemCls:InitControls()
	local transform = self:GetUnityTransform()

	self.reportInfo = transform:Find("ReportInfo")
	self.fight = self.reportInfo:Find("Fight")
	self.elvebTree = self.reportInfo:Find("ElvenTree")
	-- self.arena = self.fight:Find("Arena")
	-- self.guildPointFight = self.fight:Find("GuildPointFight")
	--胜负
	self.winFlag = self.reportInfo:Find("WinFlag")
	self.loseFlag = self.reportInfo:Find("LoseFlag")

	self.giftButton = transform:Find("GiftButton"):GetComponent(typeof(UnityEngine.UI.Button))
	self.reviewButton = transform:Find("ReviewButton"):GetComponent(typeof(UnityEngine.UI.Button))
	self.reviewButton.gameObject:SetActive(false)
	--信息
	self.headIcon = transform:Find("Head/Base/PersonalInformationHeadIcon"):GetComponent(typeof(UnityEngine.UI.Image))
	self.roleLv = transform:Find("LevelNumLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.roleName = transform:Find("NameLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	--精灵树
	self.timeLabel = self.elvebTree:Find("TimeLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.itemNameLabel = self.elvebTree:Find("ItemNameLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	--竞技场与公会积分战
	self.notice = self.fight:Find("Notice"):GetComponent(typeof(UnityEngine.UI.Text))
	self.arrowUp = self.fight:Find("Arrowup") --上升
	self.arrowDown = self.fight:Find("Arrowdown") --下降
	self.rankNum = self.fight:Find("RankNum"):GetComponent(typeof(UnityEngine.UI.Text))

	self.myGame = utility:GetGame()
end

function ReportInfoItemCls:RegisterControlEvents()
	--注册送礼物事件
	self.__event_button_onGiftButtonClicked__ = UnityEngine.Events.UnityAction(self.OnGiftButtonClicked, self)
	self.giftButton.onClick:AddListener(self.__event_button_onGiftButtonClicked__)

	--注册回放事件
	self.__event_button_onReviewButtonClicked__ = UnityEngine.Events.UnityAction(self.OnReviewButtonClicked, self)
	self.reviewButton.onClick:AddListener(self.__event_button_onReviewButtonClicked__)
end

function ReportInfoItemCls:UnregisterControlEvents()
	--取消注册送礼物事件
	if self.__event_button_onGiftButtonClicked__ then
		self.giftButton.onClick:RemoveListener(self.__event_button_onGiftButtonClicked__)
		self.__event_button_onGiftButtonClicked__ = nil
	end

	--取消注册送礼物事件
	if self.__event_button_onReviewButtonClicked__ then
		self.reviewButton.onClick:RemoveListener(self.__event_button_onReviewButtonClicked__)
		self.__event_button_onReviewButtonClicked__ = nil
	end
end

function ReportInfoItemCls:OnFightHistoryQuery(historyKey,type)
	self.myGame:SendNetworkMessage( require"Network/ServerService".OnFightHistoryQuery(historyKey,type))
end

--送礼物
function ReportInfoItemCls:OnGiftButtonClicked()
	-- body
end

--回放
function ReportInfoItemCls:OnReviewButtonClicked()
	local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
    local windowManager = utility.GetGame():GetWindowManager()

    local hintStr = string.format("哎呀，好像出错了！")
    windowManager:Show(ErrorDialogClass, hintStr)
	-- self:OnFightHistoryQuery(self.data.historyKey,self.reportType)
end

function ReportInfoItemCls:ShowReportPanel()
	-- print("服务器时间戳: ", self:GetLocakTime("%d:%H:%M",self:GetTimeManager():GetServerTimestamp()))
	if self.reportType == kReportElventTree then
		self:SetObjectActive(self.elvebTree)
	else
		self:SetObjectActive(self.fight)
	end
	self:SetPanel()
	self:ShowReportItem(self.reportType)
end

function ReportInfoItemCls:SetPanel()
	local data = self.data
	self.roleName.text = data.playerName
	self.roleLv.text = data.playerLevel
	-- if data.score ~= nil then
	-- 	if data.score > 0 then
	-- 		self:SetWinActive(true)
	-- 	else
	-- 		self:SetWinActive(false)
	-- 	end
	-- elseif data.state ~= nil then
	-- 	if data.state then
	-- 		self:SetWinActive(true)
	-- 	else
	-- 		self:SetWinActive(false)
	-- 	end
	-- end

	if data.ending ~= nil then
		if data.ending then
			self:SetWinActive(true)
		else
			self:SetWinActive(false)
		end
	end


	-- 设置玩家头像
	if data.headCardID ~= 0 and data.headCardID ~= nil then	
		utility.LoadRoleHeadIcon(data.headCardID,self.headIcon)
	end
end

function  ReportInfoItemCls:SetWinActive(isWin)
	self.winFlag.gameObject:SetActive(isWin)
	self.loseFlag.gameObject:SetActive(not isWin)
end

function ReportInfoItemCls:ShowReportItem(reportType)
	if reportType == kReportElventTree then
		self:ShowElventTree()
	else
		self:ShowOthers(reportType)
	end
end

--精灵树
function ReportInfoItemCls:ShowElventTree()
	local  time = tonumber(self.data.timeStamp)
	local serverTime = self:GetTimeManager():GetServerTimestamp()
	local lastTime = serverTime - time
	-- local times = self:GetLocakTime("%d:%H:%M",lastTime)
	-- local timesTable = utility.Split(times,":")
	-- local str = ""
	-- for i = 1,#timesTable do
	-- end
	-- if timesTable[1] ~= 0 then
	-- 	local curTime = math.ceil(tonumber(timesTable[1]))
	-- 	str = string.format(PointFight[2],curTime)
	-- elseif timesTable[2] ~= 0 then
	-- 	local curTime = math.ceil(tonumber(timesTable[2]))
	-- 	str = string.format(PointFight[3],curTime)
	-- elseif timesTable[3] ~= 0 then
	-- 	local curTime = math.ceil(tonumber(timesTable[3]))
	-- 	str = string.format(PointFight[4],curTime)
	-- end
	str = self:ConvertTime(lastTime/1000)
	-- debug_print(str)
	self.timeLabel.text = str
	local item = require "StaticData.FactoryItem":GetData(self.data.repairBoxID)
	local color = item:GetColor()
	local propUtility = require "Utils.PropUtility"
	local unityColor = propUtility.GetRGBColorValue(color)
	self.itemNameLabel.color = unityColor
end

function ReportInfoItemCls:ConvertTime(time)
	local lastTime = utility.ConvertTime(time)
	local timesTable = utility.Split(lastTime,":")
	local str = ""
	local curTime = 0
	for i=1,#timesTable do
		-- debug_print(timesTable[i])
	end
	if tonumber(timesTable[1]) ~= 0 then
		if tonumber(timesTable[1]) >= 24 then
			curTime = math.ceil(tonumber(timesTable[1]/24))
			str = string.format(PointFight[2],curTime)
			debug_print(str)
		else
			curTime = (tonumber(timesTable[1]))
			str = string.format(PointFight[3],curTime)
		end
	elseif tonumber(timesTable[2]) ~= 0 then
		curTime = (tonumber(timesTable[2]))
		str = string.format(PointFight[4],curTime)
	end
	return str
end

--公会积分战 竞技场
function ReportInfoItemCls:ShowOthers(reportType)
	if reportType == kReportGuildPointFighe then
		self.state = self.data.score
	else
		self.state = self.data.rankState
	end
	local isUp = false
	if self.state == 0 then
		self.fight.gameObject:SetActive(false)
	else
		self.fight.gameObject:SetActive(true)
		if self.state > 0 then
			if reportType == kReportGuildPointFighe then
				self.notice.text = PointFight[5]
			else
				self.notice.text = PointFight[7]
			end
			isUp = true
		elseif self.state < 0 then
			if reportType == kReportGuildPointFighe then
				self.notice.text = PointFight[6]
			else
				self.notice.text = PointFight[8]
			end
			isUp = false
		end
	end
	
	self:SetRankState(isUp)
end


function ReportInfoItemCls:SetRankState(isUp)
	self.arrowUp.gameObject:SetActive(isUp)
	self.arrowDown.gameObject:SetActive(not isUp)
	if isUp then
		self.rankNum.color = UnityEngine.Color(0.0313725, 0.901960, 0.294117, 1)
	else
		self.rankNum.color = UnityEngine.Color(1,0,0,1)
	end
	self.rankNum.text = math.abs(self.state)
end

function ReportInfoItemCls:GetLocakTime(format,time)
	return os.date(format, time/1000)
end

function ReportInfoItemCls:SetObjectActive(obj)
	self:HideAllObject()
	obj.gameObject:SetActive(true)
end

function ReportInfoItemCls:HideAllObject()
	self.elvebTree.gameObject:SetActive(false)
	-- self.arena.gameObject:SetActive(false)
	-- self.guildPointFight.gameObject:SetActive(false)
	self.fight.gameObject:SetActive(false)
end

return ReportInfoItemCls