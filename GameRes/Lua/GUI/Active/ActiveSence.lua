local BaseNodeClass = require "Framework.Base.UIScene"
local utility = require "Utils.Utility"
local net = require "Network.Net"
require "Collection.OrderedDictionary"
require "LUT.StringTable"

local ActiveCls = Class(BaseNodeClass)

local gameTool = require "Utils.GameTools"
local AtlasesLoader = require "Utils.AtlasesLoader"
local messageGuids = require "Framework.Business.MessageGuids"
local gametool = require "Utils.GameTools"
local rate = 12
local delaultAngle = 360 / rate
local lastPosY = 1651

local targetRotation

function ActiveCls:Ctor(idtables,msg,operationActicity)
	self.idtables = idtables
	self.data = msg
	self.operationActicity=operationActicity

end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function ActiveCls:OnInit()
	--加载界面
	utility.LoadNewGameObjectAsync("UI/Prefabs/Active",function(go)
		self:BindComponent(go)
	end)
end

function ActiveCls:OnComponentReady()
	--界面加载完成
	self:InitControls()
end

function ActiveCls:OnResume()
	--界面显示时调用
	ActiveCls.base.OnResume(self)
	require "Utils.GameAnalysisUtils".EnterScene("活动界面")
	require "Utils.GameAnalysisUtils".RecordLocalAction(kTrackingId_ActivityView)
	self:RegisterControlEvents()
	self:RegisterNetworkEvenrs()
	self:RegisterEvent(messageGuids.ModuleRedDotChanged, self.RedDotStateUpdated)
	-- self:ShowProgressCharge()
	self.serverPanelActicity={}
	self:Show()
end

function ActiveCls:OnPause()
	ActiveCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
	self:UnregisterEvent(messageGuids.CardRedDotChanged, self.RedDotStateUpdated)
	-- self:RemoveAll()
end

function ActiveCls:OnEnter()
	ActiveCls.base.OnEnter(self)
	self:SetRedDot()
	self:RedDotStateQuery()
end

function ActiveCls:OnExit()
	ActiveCls.base.OnExit(self)
end

function ActiveCls:Update()
	self:WheelTimeCountdown()
	self:WheelRotate()
	self:LuckyCatMoveOut()
end

-------------------------------------------------------------------
--- 控件相关
-------------------------------------------------------------------

-- 控件绑定
function ActiveCls:InitControls()
	local transform = self:GetUnityTransform()
	self:ScheduleUpdate(self.Update)
	self.ActiveReturnButton = transform:Find("ReturnButton"):GetComponent(typeof(UnityEngine.UI.Button))
	self.button = transform:Find("Button/Button/Viewport/Content")
	self.BigTitleName = transform:Find("ActiveInfo/IllustBase/Text"):GetComponent(typeof(UnityEngine.UI.Text))

	-- 累计消费按钮
	-- self.AccumulatedButton = self.button:Find("AccumulatedButton"):GetComponent(typeof(UnityEngine.UI.Button))、
	self.desc = transform:Find("DescriptionBase")
	self.nameLabel = self.desc:Find("TitleBase/TitleLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.descLabel = self.desc:Find("DescriptionLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.noticeLabel = self.desc:Find("NoticeLabel"):GetComponent(typeof(UnityEngine.UI.Text))

	self.lastTimeLabel = transform:Find("ActiveInfo/IllustBase/LasttimeLabel"):GetComponent(typeof(UnityEngine.UI.Text))

	self.ListPoint = transform:Find("ActiveInfo/Box/Scroll View/Viewport/Content")
	self.myGame = utility:GetGame()

	--七天登陆
	self.DaysIllustBase = transform:Find("ActiveInfo/7DaysIllustBase").gameObject
	self.DaysastTimeLabel = transform:Find("ActiveInfo/7DaysIllustBase/LasttimeLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.Active7Title = self.DaysIllustBase.transform:Find("7DayActiveTitle").gameObject
	--8日
	self.Active8Title = self.DaysIllustBase.transform:Find("8DayActiveTitle").gameObject
	--充值
	self.IllustBase = transform:Find("ActiveInfo/IllustBase").gameObject
	--战力排行
	self.PowerIllustBase = transform:Find("ActiveInfo/PowerIllustBase").gameObject
	self.PowerLaseTimeLabel = transform:Find("ActiveInfo/PowerIllustBase/LasttimeLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	--等级排行
	self.LevelIllustBase = transform:Find("ActiveInfo/LevelIllustBase").gameObject
	self.LevelLaseTimeLabel = transform:Find("ActiveInfo/LevelIllustBase/LasttimeLabel"):GetComponent(typeof(UnityEngine.UI.Text))


	--限时兑换
	self.ActiveInfo = transform:Find("ActiveInfo").gameObject
	self.ExchangeInfo = transform:Find("ExchangeInfo").gameObject
	self.exchangeTimeLabel = self.ExchangeInfo.transform:Find("ExchangeIllustBase/LasttimeLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.exchangeTImes = self.ExchangeInfo.transform:Find("Refresh/Notice"):GetComponent(typeof(UnityEngine.UI.Text))
	self.refreshTimes = self.ExchangeInfo.transform:Find("Refresh/Freshtime"):GetComponent(typeof(UnityEngine.UI.Text))
	self.refreshButton = self.ExchangeInfo.transform:Find("Refresh/FreshButton"):GetComponent(typeof(UnityEngine.UI.Button))
	self.refreshDysLabel = self.refreshButton.transform:Find("Label"):GetComponent(typeof(UnityEngine.UI.Text))
	self.exchangeButtons = {}
	self.exchangeButtonOn = {}
	for i=1,3 do
		self.exchangeButtons[i] = self.ExchangeInfo.transform:Find("ExchangeBox/Buttons/Tag"..i.."/Off"):GetComponent(typeof(UnityEngine.UI.Button))
		self.exchangeButtonOn[i] = self.ExchangeInfo.transform:Find("ExchangeBox/Buttons/Tag"..i.."/On").gameObject
	end
	self.exchangePoint = self.ExchangeInfo.transform:Find("ExchangeBox/Scroll View/Viewport/Content")

	----------转转乐----------------------------------------------------------------------------------------------------------------
	self.Lottery = transform:Find("Lottery")
	self.wheelBack = self.Lottery:Find("Wheel/Back")
	self.wheelItem = {}
	self.wheelItemIcon = {}
	self.wheelItemFrame = {}
	self.wheelItemNum = {}
	self.DebrisIcon = {}
	self.DebrisCorner = {}
	for i=1,12 do
		self.wheelItem[i] =  self.Lottery:Find("Wheel/Back/Item"..i.."/ItemBox")
		self.wheelItemIcon[i] = self.wheelItem[i]:Find("Icon"):GetComponent(typeof(UnityEngine.UI.Image))
		self.wheelItemFrame[i] = self.wheelItem[i]:Find("Frame"):GetComponent(typeof(UnityEngine.UI.Image))
		self.wheelItemNum[i] = self.wheelItem[i]:Find("ItemNumLabel"):GetComponent(typeof(UnityEngine.UI.Text))
		self.DebrisIcon[i] = self.wheelItem[i]:Find("DebrisIcon").gameObject
		self.DebrisCorner[i] = self.wheelItem[i]:Find("DebrisCorner").gameObject
	end
	--转一次
	self.oneTimeButton = self.Lottery:Find("Onetime/Button"):GetComponent(typeof(UnityEngine.UI.Button))
	self.ontTimeIcon = self.Lottery:Find("Onetime/Icon").gameObject
	self.oneTimeNum = self.Lottery:Find("Onetime/PriceLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	--转十次
	self.tenTimeButton = self.Lottery:Find("Tentime/Button"):GetComponent(typeof(UnityEngine.UI.Button))
	self.tenTimeNum = self.Lottery:Find("Tentime/PriceLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	--积分
	self.pointNum = self.Lottery:Find("Point/Box/PointLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.pointButton = self.Lottery:Find("Point/Button"):GetComponent(typeof(UnityEngine.UI.Button))
	--免费时间
	self.freeTime = self.Lottery:Find("FreeTime/FreeTimeLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.freeObj = self.Lottery:Find("FreeTime").gameObject
	--转转乐活动时间
	self.timeLabel = self.Lottery:Find("TimeLabel"):GetComponent(typeof(UnityEngine.UI.Text))

	self.animtor = self.Lottery:Find("Wheel/Light"):GetComponent(typeof(UnityEngine.Animator))
	self.isRotate = false
	self.rotateZ = self.wheelBack.eulerAngles.z
	-- self.itemCount = 11
	self.passedTime = 0
	self.wheelItemsDict = OrderedDictionary.New()
	--------------------------------------------------------------------------------------------------------------------------------
	----------招財貓----------------------------------------------------------------------------------------------------------------
	self.luckyCat = transform:Find("Zhaocaimao")
	self.luckyCatButton = self.luckyCat:Find("Choujiang/Choujiangbtn"):GetComponent(typeof(UnityEngine.UI.Button))
	self.ScrollView = {}
	self.luckyCatTime = {}
	self.luckyCatPos = {}
	self.luckyCatPasstime = {}
	self.luckyCatDiffTime = {}
	self.endPosY = {}
	self.posY = {}
	for i=1,5 do
		self.ScrollView[i] = self.luckyCat:Find("Choujiang/Border/DiamondNum/CoinFrame/Viewpoint/Scroll View"..i)
		self.luckyCatTime[i] = 3 + i*0.5
		self.luckyCatPos[i] = self.ScrollView[i].localPosition
		self.luckyCatPasstime[i] = 0
		self.luckyCatDiffTime[i] = 0
		self.posY[i] = 0
	end
	self.luckyCatAnim = self.luckyCat:Find("Choujiang/Border/Dengall"):GetComponent(typeof(UnityEngine.Animator))
	self.luckyCatMove = false
	self.luckyCatRecordPoint = self.luckyCat:Find("Jilu/Jilupanel/Border/Scroll View/Viewport/Content")
	--剩餘次數
	self.luckyCatTimes = self.luckyCat:Find("Choujiang/Border/ShengyuNum/Num"):GetComponent(typeof(UnityEngine.UI.Text))
	--活動時間天數
	self.luckyCatDays = self.luckyCat:Find("Base/Timeframe/Daytext"):GetComponent(typeof(UnityEngine.UI.Text))
	--活動時間分鐘數
	self.luckyCatHours = self.luckyCat:Find("Base/Timeframe/Jishitext"):GetComponent(typeof(UnityEngine.UI.Text))
	--當前消耗鑽石
	self.luckyCatCost = self.luckyCat:Find("Choujiang/Border/Acquire/AcquireNum"):GetComponent(typeof(UnityEngine.UI.Text))
	--累計獲得鑽石數
	self.luckyCatCumuGet = self.luckyCat:Find("Choujiang/Border/LeijiAcquire/Num"):GetComponent(typeof(UnityEngine.UI.Text))
	--累計花費鑽石數
	self.luckyCatCumuCost = self.luckyCat:Find("Choujiang/Border/Xiaohao/XiaohaoNum"):GetComponent(typeof(UnityEngine.UI.Text))
	--vip
	self.luckyCatVipText = self.luckyCat:Find("Choujiang/Border/VIP/VipText"):GetComponent(typeof(UnityEngine.UI.Text))
	self.luckyCatNode = {}
	self.recordNum = 0
	--------------------------------------------------------------------------------------------------------------------------------
	----------連續充值--------------------------------------------------------------------------------------------------------------
	self.ContinueTotal = transform:Find("ContinueTotal")
	self.totalDesc = self.ContinueTotal:Find("Top/Topbg/Blackbg/Title"):GetComponent(typeof(UnityEngine.UI.Text))
	self.totalLastTime = self.ContinueTotal:Find("Top/Topbg/LastTime"):GetComponent(typeof(UnityEngine.UI.Text))
	self.totalChargeButton = self.ContinueTotal:Find("Top/Topbg/ChongzhiButton"):GetComponent(typeof(UnityEngine.UI.Button))
	self.totalDiaNum = {}
	self.totalFinshedDays = {}
	self.totalPoint = {}
	self.totalItem = {}
	self.totalItemDesc = {}
	self.totalItemNot = {}
	self.totalItemFinshed = {}
	self.totalItemDone = {}
	for i=1,3 do
		self.totalDiaNum[i] = self.ContinueTotal:Find("Bottom/BottomLeft/Type"..i.."/TypeDiamondNumText"):GetComponent(typeof(UnityEngine.UI.Text))
		self.totalFinshedDays[i] = self.ContinueTotal:Find("Bottom/BottomLeft/Type"..i.."/TypeFinishText"):GetComponent(typeof(UnityEngine.UI.Text))
		self.totalItem[i] = self.ContinueTotal:Find("Bottom/BottomRight/Type"..i)
		self.totalPoint[i] = self.totalItem[i]:Find("Award/ItemType")
		self.totalItemDesc[i] = self.totalItem[i]:Find("Blackbg/Text"):GetComponent(typeof(UnityEngine.UI.Text))
		self.totalItemNot[i] = self.totalItem[i]:Find("Award/All/Off").gameObject
		self.totalItemFinshed[i] = self.totalItem[i]:Find("Award/All/On"):GetComponent(typeof(UnityEngine.UI.Button))
		self.totalItemDone[i] = self.totalItem[i]:Find("Award/All/Down").gameObject

	end
	self.totalBox = {}
	self.totalBoxFinshed = {}
	self.totalBoxDone = {}
	self.totalBoxButton = {}
	for i=1,9 do
		self.totalBox[i] = self.ContinueTotal:Find("Bottom/BottomMiddle/Box/GoldBox"..i)
		self.totalBoxFinshed[i] = self.totalBox[i]:Find("Finshed"):GetComponent(typeof(UnityEngine.UI.Image))
		self.totalBoxDone[i] = self.totalBox[i]:Find("Done").gameObject
		self.totalBoxButton[i] = self.totalBox[i]:Find("Finshed"):GetComponent(typeof(UnityEngine.UI.Button))
	end
	--------------------------------------------------------------------------------------------------------------------------------
	----------单笔連續充值----------------------------------------------------------------------------------------------------------
	self.DailyContinue = transform:Find("DailyContinue")
	self.dailyDesc = self.DailyContinue:Find("TextLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.dailyDescNotice = self.DailyContinue:Find("RightBase/Talk/TalkLable"):GetComponent(typeof(UnityEngine.UI.Text))
	--條目
	self.dailyTitle = self.DailyContinue:Find("LeftBase/Award/NoticeLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.dailyAwardPoint = self.DailyContinue:Find("LeftBase/Award/AwardLayout")
	self.dailyPoint = self.DailyContinue:Find("GiftBase/NormalAwardLayout")
	self.dailyLastTime = self.DailyContinue:Find("LeftBase/Time/LastTime"):GetComponent(typeof(UnityEngine.UI.Text))
	self.dailyChargeNum = self.DailyContinue:Find("RightBase/ChargeBase/ChargeLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.dailyGetButton = self.DailyContinue:Find("LeftBase/GetButton"):GetComponent(typeof(UnityEngine.UI.Button))
	self.dailyChargeButton = self.DailyContinue:Find("RightBase/ChargeButton"):GetComponent(typeof(UnityEngine.UI.Button))
	self.dailyDoneItem = self.dailyGetButton.transform:Find("Done").gameObject
	self.dailyFinshedItem = self.dailyGetButton.transform:Find("Text").gameObject
	self.dailyFill = self.DailyContinue:Find("GiftBase/Progress/Base/Fill"):GetComponent(typeof(UnityEngine.UI.Image))
	--------------------------------------------------------------------------------------------------------------------------------
	----------逐額充值--------------------------------------------------------------------------------------------------------------
	self.ProgressCharge = transform:Find("ProgressCharge")
	self.progressPoint = self.ProgressCharge:Find("Top/Layout")
	self.progressRecordPoint = self.ProgressCharge:Find("TextBase/Scroll View/Viewport/Content")
	self.progressRankPoint = self.ProgressCharge:Find("Right/ShowRank")
	self.progressFill = self.ProgressCharge:Find("Top/Progress/Bar/Fill"):GetComponent(typeof(UnityEngine.UI.Image))
	self.progressDesc = self.ProgressCharge:Find("Top/Title/Notice"):GetComponent(typeof(UnityEngine.UI.Text))
	self.progressAwardText = self.ProgressCharge:Find("Right/AwardLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.progressAwardIcon = self.ProgressCharge:Find("Right/Icon"):GetComponent(typeof(UnityEngine.UI.Image))
	self.progressButton = self.ProgressCharge:Find("Right/Button"):GetComponent(typeof(UnityEngine.UI.Button))
	self.progressButtonText = self.progressButton.transform:Find("Text"):GetComponent(typeof(UnityEngine.UI.Text))
	--------------------------------------------------------------------------------------------------------------------------------
	self.buttonId = nil
	self.operationActicityLayout =transform:Find("Layout")



end

function ActiveCls:RegisterControlEvents()
	--注册退出事件
	self._event_button_onActiveReturnClicked_ = UnityEngine.Events.UnityAction(self.OnActiveReturnClicked,self)
	self.ActiveReturnButton.onClick:AddListener(self._event_button_onActiveReturnClicked_)

	self._event_button_onexchangeButtonClicked_ = {}
	self.OnExchangeButtonClicked = {}
	self.OnExchangeButtonClicked[1] = self.OnExchangeButton1Clicked
	self.OnExchangeButtonClicked[2] = self.OnExchangeButton2Clicked
	self.OnExchangeButtonClicked[3] = self.OnExchangeButton3Clicked
	for i=1,#self.OnExchangeButtonClicked do
		self._event_button_onexchangeButtonClicked_[i] = UnityEngine.Events.UnityAction(self.OnExchangeButtonClicked[i],self)
		self.exchangeButtons[i].onClick:AddListener(self._event_button_onexchangeButtonClicked_[i])
	end

	self._event_button_ontotalBoxFinshButtonClicked_ = {}
	self.OnTotalFinshBoxButtonClicked = {}
	self.OnTotalFinshBoxButtonClicked[1] = self.OnTotalFinshBoxButton1Clicked
	self.OnTotalFinshBoxButtonClicked[2] = self.OnTotalFinshBoxButton2Clicked
	self.OnTotalFinshBoxButtonClicked[3] = self.OnTotalFinshBoxButton3Clicked
	self.OnTotalFinshBoxButtonClicked[4] = self.OnTotalFinshBoxButton4Clicked
	self.OnTotalFinshBoxButtonClicked[5] = self.OnTotalFinshBoxButton5Clicked
	self.OnTotalFinshBoxButtonClicked[6] = self.OnTotalFinshBoxButton6Clicked
	self.OnTotalFinshBoxButtonClicked[7] = self.OnTotalFinshBoxButton7Clicked
	self.OnTotalFinshBoxButtonClicked[8] = self.OnTotalFinshBoxButton8Clicked
	self.OnTotalFinshBoxButtonClicked[9] = self.OnTotalFinshBoxButton9Clicked
	for i=1,#self.OnTotalFinshBoxButtonClicked do
		self._event_button_ontotalBoxFinshButtonClicked_[i] = UnityEngine.Events.UnityAction(self.OnTotalFinshBoxButtonClicked[i],self)
		self.totalBoxButton[i].onClick:AddListener(self._event_button_ontotalBoxFinshButtonClicked_[i])
	end

	self._event_button_ontotalFinshButtonClicked_ = {}
	self.OnTotalFinshButtonClicked = {}
	self.OnTotalFinshButtonClicked[1] = self.OnTotalFinshButton1Clicked
	self.OnTotalFinshButtonClicked[2] = self.OnTotalFinshButton2Clicked
	self.OnTotalFinshButtonClicked[3] = self.OnTotalFinshButton3Clicked
	for i=1,#self.OnTotalFinshButtonClicked do
		self._event_button_ontotalFinshButtonClicked_[i] = UnityEngine.Events.UnityAction(self.OnTotalFinshButtonClicked[i],self)
		self.totalItemFinshed[i].onClick:AddListener(self._event_button_ontotalFinshButtonClicked_[i])
	end

	self._event_button_onRefreshButtonClicked_ = UnityEngine.Events.UnityAction(self.OnRefreshButtonClicked,self)
	self.refreshButton.onClick:AddListener(self._event_button_onRefreshButtonClicked_)

	self._event_button_onOneTimeButtonClicked_ = UnityEngine.Events.UnityAction(self.OnOneTimeButtonClicked,self)
	self.oneTimeButton.onClick:AddListener(self._event_button_onOneTimeButtonClicked_)

	self._event_button_onTenTimeButtonClicked_ = UnityEngine.Events.UnityAction(self.OnTenTimeButtonClicked,self)
	self.tenTimeButton.onClick:AddListener(self._event_button_onTenTimeButtonClicked_)

	self._event_button_onLuckyCatButtonClicked_ = UnityEngine.Events.UnityAction(self.OnLuckyCatButtonClicked,self)
	self.luckyCatButton.onClick:AddListener(self._event_button_onLuckyCatButtonClicked_)

	self._event_button_ontotalChargeButtonClicked_ = UnityEngine.Events.UnityAction(self.OnTotalChargeButtonClicked,self)
	self.totalChargeButton.onClick:AddListener(self._event_button_ontotalChargeButtonClicked_)

	self._event_button_onDailyChargeButtonClicked_ = UnityEngine.Events.UnityAction(self.OnDailyChargeButtonClicked,self)
	self.dailyChargeButton.onClick:AddListener(self._event_button_onDailyChargeButtonClicked_)

	--self._event_button_onDailyGetButtonClicked_ = UnityEngine.Events.UnityAction(self.OnDailyGetButtonClicked,self)
	--self.dailyGetButton.onClick:AddListener(self._event_button_onDailyGetButtonClicked_)

	self._event_button_onDailyGetButtonClicked_ = UnityEngine.Events.UnityAction(self.OnDailyGetButtonClicked,self)
	self.dailyGetButton.onClick:AddListener(self._event_button_onDailyGetButtonClicked_)

	self._event_button_onProgressButtonClicked_ = UnityEngine.Events.UnityAction(self.OnProgressButtonClicked,self)
	self.progressButton.onClick:AddListener(self._event_button_onProgressButtonClicked_)

	self._event_button_onPointButtonClicked_ = UnityEngine.Events.UnityAction(self.OnPointButtonClicked,self)
	self.pointButton.onClick:AddListener(self._event_button_onPointButtonClicked_)

end

function ActiveCls:UnregisterControlEvents()
	--取消注册退出事件
	if self._event_button_onActiveReturnClicked_ then
		self.ActiveReturnButton.onClick:RemoveListener(self._event_button_onActiveReturnClicked_)
		self._event_button_onActiveReturnClicked_ = nil
	end

	if self._event_button_ontotalChargeButtonClicked_ then
		self.totalChargeButton.onClick:RemoveListener(self._event_button_ontotalChargeButtonClicked_)
		self._event_button_ontotalChargeButtonClicked_ = nil
	end

	for i=1,#self._event_button_onexchangeButtonClicked_ do
		if self._event_button_onexchangeButtonClicked_[i] then
			self.exchangeButtons[i].onClick:RemoveListener(self._event_button_onexchangeButtonClicked_[i])
			self._event_button_onexchangeButtonClicked_[i] = nil
		end
	end

	for i=1,#self._event_button_ontotalBoxFinshButtonClicked_ do
		if self._event_button_ontotalBoxFinshButtonClicked_[i] then
			self.totalBoxButton[i].onClick:RemoveListener(self._event_button_ontotalBoxFinshButtonClicked_[i])
			self._event_button_ontotalBoxFinshButtonClicked_[i] = nil
		end
	end	

	for i=1,#self._event_button_ontotalFinshButtonClicked_ do
		if self._event_button_ontotalFinshButtonClicked_[i] then
			self.totalItemFinshed[i].onClick:RemoveListener(self._event_button_ontotalFinshButtonClicked_[i])
			self._event_button_ontotalFinshButtonClicked_[i] = nil
		end
	end	

	if self._event_button_onRefreshButtonClicked_ then
		self.refreshButton.onClick:RemoveListener(self._event_button_onRefreshButtonClicked_)
		self._event_button_onRefreshButtonClicked_ = nil
	end

	if self._event_button_onOneTimeButtonClicked_ then
		self.oneTimeButton.onClick:RemoveListener(self._event_button_onOneTimeButtonClicked_)
		self._event_button_onOneTimeButtonClicked_ = nil
	end

	if self._event_button_onTenTimeButtonClicked_ then
		self.tenTimeButton.onClick:RemoveListener(self._event_button_onTenTimeButtonClicked_)
		self._event_button_onTenTimeButtonClicked_ = nil
	end

	if self._event_button_onLuckyCatButtonClicked_ then
		self.luckyCatButton.onClick:RemoveListener(self._event_button_onLuckyCatButtonClicked_)
		self._event_button_onLuckyCatButtonClicked_ = nil
	end

	if self._event_button_onDailyGetButtonClicked_ then
		self.dailyGetButton.onClick:RemoveListener(self._event_button_onDailyGetButtonClicked_)
		self._event_button_onDailyGetButtonClicked_ = nil
	end

	if self._event_button_onDailyChargeButtonClicked_ then
		self.dailyChargeButton.onClick:RemoveListener(self._event_button_onDailyChargeButtonClicked_)
		self._event_button_onDailyChargeButtonClicked_ = nil
	end

	if self._event_button_onProgressButtonClicked_   then
		self.progressButton.onClick:RemoveListener(self._event_button_onProgressButtonClicked_  )
		self._event_button_onProgressButtonClicked_   = nil
	end

	if self._event_button_onPointButtonClicked_ then
		self.pointButton.onClick:RemoveListener(self._event_button_onPointButtonClicked_)
		self._event_button_onPointButtonClicked_ = nil
	end
end

function ActiveCls:RegisterNetworkEvenrs()
	self.myGame:RegisterMsgHandler(net.ActivityQueryResult,self,self.OnActivityQueryResult)
	self.myGame:RegisterMsgHandler(net.ActivityGetAwardResult,self,self.OnActivityGetAwardResult)
	self.myGame:RegisterMsgHandler(net.S2CActivityTimeLimitExchangeResult,self,self.ActivityTimeLimitExchangeResult)
	self.myGame:RegisterMsgHandler(net.S2CZhaoCaiCatActivityQueryResult,self,self.ZhaoCaiCatActivityQueryResult)
	self.myGame:RegisterMsgHandler(net.S2CZhaoCaiCatActivityChouJiangResult,self,self.ZhaoCaiCatActivityChouJiangResult)
	self.myGame:RegisterMsgHandler(net.S2CZhaoCaiCatActivityChouJiangRecordResult,self,self.ZhaoCaiCatActivityChouJiangRecordResult)
	self.myGame:RegisterMsgHandler(net.S2CConRecActivityAwaQueryResult,self,self.ConRecActivityAwaQueryResult)
	self.myGame:RegisterMsgHandler(net.S2CConRecActivityQueryResult,self,self.ConRecActivityQueryResult)
	self.myGame:RegisterMsgHandler(net.S2CSinglContiRecharActivityQueryResult,self,self.SinglContiRecharActivityQueryResult)
	self.myGame:RegisterMsgHandler(net.S2CSinglContiRecharActivityAwaQueryResult,self,self.SinglContiRecharActivityAwaQueryResult)
	self.myGame:RegisterMsgHandler(net.S2CDailyRechargeActivitySuccessFushResult,self,self.DailyRechargeActivitySuccessFushResult)
	self.myGame:RegisterMsgHandler(net.S2CDailyRechargeActivityQueryResult,self,self.DailyRechargeActivityQueryResult)
	self.myGame:RegisterMsgHandler(net.S2CDailyRechargeActivityAwardQueryResult,self,self.DailyRechargeActivityAwardQueryResult)
	self.myGame:RegisterMsgHandler(net.S2CDailyRechargeActivityRecordResult,self,self.DailyRechargeActivityRecordResult)
	self.myGame:RegisterMsgHandler(net.S2CHappyTurnMusicQueryResult,self,self.HappyTurnMusicQueryResult)
	self.myGame:RegisterMsgHandler(net.S2CHappyTurnMusicResult,self,self.HappyTurnMusicResult)
	self.myGame:RegisterMsgHandler(net.S2CLoadPlayerResult, self, self.OnLoadPlayerResponse)

end

function ActiveCls:UnregisterNetworkEvents()
	self.myGame:UnRegisterMsgHandler(net.S2CLoadPlayerResult, self, self.OnLoadPlayerResponse)
	self.myGame:UnRegisterMsgHandler(net.ActivityQueryResult,self,self.OnActivityQueryResult)
	self.myGame:UnRegisterMsgHandler(net.ActivityGetAwardResult,self,self.OnActivityGetAwardResult)
	self.myGame:UnRegisterMsgHandler(net.S2CActivityTimeLimitExchangeResult,self,self.ActivityTimeLimitExchangeResult)
	self.myGame:UnRegisterMsgHandler(net.S2CZhaoCaiCatActivityQueryResult,self,self.ZhaoCaiCatActivityQueryResult)
	self.myGame:UnRegisterMsgHandler(net.S2CZhaoCaiCatActivityChouJiangResult,self,self.ZhaoCaiCatActivityChouJiangResult)
	self.myGame:UnRegisterMsgHandler(net.S2CZhaoCaiCatActivityChouJiangRecordResult,self,self.ZhaoCaiCatActivityChouJiangRecordResult)
	self.myGame:UnRegisterMsgHandler(net.S2CConRecActivityAwaQueryResult,self,self.ConRecActivityAwaQueryResult)
	self.myGame:UnRegisterMsgHandler(net.S2CConRecActivityQueryResult,self,self.ConRecActivityQueryResult)
	self.myGame:UnRegisterMsgHandler(net.S2CSinglContiRecharActivityQueryResult,self,self.SinglContiRecharActivityQueryResult)
	self.myGame:UnRegisterMsgHandler(net.S2CSinglContiRecharActivityAwaQueryResult,self,self.SinglContiRecharActivityAwaQueryResult)
	self.myGame:UnRegisterMsgHandler(net.S2CDailyRechargeActivitySuccessFushResult,self,self.DailyRechargeActivitySuccessFushResult)
	self.myGame:UnRegisterMsgHandler(net.S2CDailyRechargeActivityQueryResult,self,self.DailyRechargeActivityQueryResult)
	self.myGame:UnRegisterMsgHandler(net.S2CDailyRechargeActivityAwardQueryResult,self,self.DailyRechargeActivityAwardQueryResult)
	self.myGame:UnRegisterMsgHandler(net.S2CDailyRechargeActivityRecordResult,self,self.DailyRechargeActivityRecordResult)
	self.myGame:UnRegisterMsgHandler(net.S2CHappyTurnMusicQueryResult,self,self.HappyTurnMusicQueryResult)
	self.myGame:UnRegisterMsgHandler(net.S2CHappyTurnMusicResult,self,self.HappyTurnMusicResult)
end

--轉轉樂
function ActiveCls:HappyTurnMusicQueryResult(msg)
	--self:ShowPanel(20)
	self:ShowPanel(self.buttonId)
	self:LoadWheelTime(msg)
end

--轉轉樂點擊
function ActiveCls:HappyTurnMusicResult(msg)
	local data = msg.happyTurnMusicTenAwa
	if msg.turnMusicAwaId ~= 0 then
		self.itemCount = msg.turnMusicAwaId
	else
		self.itemCount = data[#data].turnMusicTenAwaId
	end
	self.animtor:Play("click")
	self.passedTime = 0
	local endRotation = delaultAngle * self.itemCount - self.rotateZ
	self.endEulerAnglesZ = math.random(endRotation-14,endRotation + 14)
	-- -- self.itemCount=math.random(0,11)
	self.isRotate = true
	self.turnMusicAwaId = msg.turnMusicAwaId
	self.happyTurnMusicTenAwa = msg.happyTurnMusicTenAwa
	self:ResetWheelPoint()
	self:HappyTurnMusicQueryRequest()
end

function ActiveCls:SetItems(msg)
	self.wheelItemsDict:Clear()
	if #msg ~= 0 then
		local item = {}
		local itemNum = 0
		for i=1,#msg do
			local data = require "StaticData.Activity.ActivityCircle":GetData(msg[i].turnMusicTenAwaId)
			itemNum = data:GetAwardItemNumber()
			if not self.wheelItemsDict:Contains(data:Getinfo()) then
				self.wheelItemsDict:Add(data:Getinfo(),itemNum)
			else
				itemNum = self.wheelItemsDict:GetEntryByKey(data:Getinfo())

				itemNum = itemNum + data:GetAwardItemNumber()
				self.wheelItemsDict:Remove(data:Getinfo())
				self.wheelItemsDict:Add(data:Getinfo(),itemNum)
			end
		end
		
		for i=1,self.wheelItemsDict:Count() do
			item[i] = {}
			item[i].itemID = self.wheelItemsDict:GetKeyFromIndex(i)
			item[i].itemNum = self.wheelItemsDict:GetEntryByIndex(i)
		end
		self:ShowWheelTenAward(item)
	end
end

function ActiveCls:SetWheelItem(id)
	local data = require "StaticData.Activity.ActivityCircle":GetData(id)
	local item = {}
	item[1] = {}
	item[1].id = data:Getinfo()
	item[1].count = data:GetAwardItemNumber()
	local _,data,_,_,itype = gametool.GetItemDataById(data:Getinfo())
	local color = gametool.GetItemColorByType(itype,data)
	item[1].color = color
	local windowManager = self:GetGame():GetWindowManager()
    local AwardCls = require "GUI.Task.GetAwardItem"
    windowManager:Show(AwardCls,item)
end

function ActiveCls:ShowWheelTenAward(item)
	local windowManager = utility:GetGame():GetWindowManager()
    windowManager:Show(require "GUI.Tower.TowerSweepAward",item,2)
end

--逐額充值
function ActiveCls:DailyRechargeActivitySuccessFushResult(msg)
	debug_print("@@@@ ActiveCls:DailyRechargeActivitySuccessFushResult @@@@")
	local windowManager = self:GetGame():GetWindowManager()
    windowManager:Show(require "GUI.Active.ProgressChargeAward",msg.critId,msg.daiRecItemAward)
    self:DailyRechargeActivityQueryRequest(29)
end

function ActiveCls:DailyRechargeActivityQueryResult(msg)
	-- self:ShowPanel(29)
	self:ShowPanel(self.buttonId)

	self:ShowProgressChargePanel(msg)
end

function ActiveCls:DailyRechargeActivityAwardQueryResult(msg)
	local table = {}
	for i=1,#msg.daiRecItemAward do
		table[i] = {}
		table[i].itemID = msg.daiRecItemAward[i].itemAwardId
		table[i].itemNum = msg.daiRecItemAward[i].itemAwardNum
	end
	self:GetItems(table)
	self:DailyRechargeActivityQueryRequest(29)
end

function ActiveCls:DailyRechargeActivityRecordResult(msg)
	self:LoadProgressRecord(msg.dailyRechargeAwardRecord)
end

function  ActiveCls:OnActivityGetAwardResult(msg)
	--debug_print("收到回复", msg.status, msg.activityId)
	if msg.status then
		self:OnActivityQueryRequest(msg.tid)
		local data = require "StaticData.Activity.Activity":GetData(msg.tid)
		local type = data:GetActivetgrandype()
		local id
		local activeData
		if type == 1 or type == 2 then
			activeData = require "StaticData.Activity.ActivityConsumption":GetData(msg.activityId)
		elseif type == 7 then
			activeData = require "StaticData.Activity.NewServerLevel":GetData(msg.activityId)
		elseif type == 8 then
			activeData = require "StaticData.Activity.NewServerPower":GetData(msg.activityId)
		elseif type == 5 then 
			activeData = require "StaticData.Activity.NewServerLogin":GetData(msg.activityId)
		elseif type == 17 then
			activeData = require "StaticData.Activity.NewPlayerLogin":GetData(msg.activityId)
		elseif type == 12 then
			activeData = require "StaticData.Activity.ExchangeIndex":GetData(msg.activityId)
		end
		self:ShowAwardPanel(activeData,type)
		-- self:LoadItem()
	end
end
--活动请求回复协议
function  ActiveCls:OnActivityQueryResult(msg)
	 debug_print(msg.activityId,"OnActivityQueryResult")
	if msg.activityId ~= nil then
		self.tableStatus = {}
		for i=1,#msg.consumeActivityList do
			-- print("状态:",msg.consumeActivityList[i].id)
			self.tableStatus[#self.tableStatus + 1] = msg.consumeActivityList[i]
		end
		self:ShowPanel(msg.activityId)
		local activityData = require "StaticData.Activity.Activity":GetData(msg.activityId)
		local type = activityData:GetActivetgrandype()
		-- self:LoadAwardItem(msg.activityId,type)
		self:GetActiveTime(msg.activityId,msg.nowTime)
		-- local activityData = require "StaticData.Activity.Activity":GetData(msg.activityId)
		-- local keys = require "StaticData.Activity.ActivityConsumption":GetKeys()
	else
		-- self:HideAllChild()
	end
end
--限时兑换协议回复
function ActiveCls:ActivityTimeLimitExchangeResult(msg)
	-- debug_print("限时兑换"..msg.activityId)
	-- print_debug("限时兑换",#msg.exchange,msg.activityId)
	--self.exchangeType=1
		hzj_print(msg.activityId,"msg.activityId",self.exchangeType,msg.activityId)
	-- if self.exchangeType==nil then
	-- 	self.exchangeType=1
	-- end
	if msg.activityId ~= nil then
		self.tableStatus = {}
		self.exchangeInfo = {}
		for i=1,#msg.exchange do
			self.exchangeInfo[#self.exchangeInfo + 1] = msg.exchange[i]
			for j=1,#msg.exchange[i].state do
				self.tableStatus[#self.tableStatus + 1] = msg.exchange[i].state[j]
			end
		end
		for i=1,#self.tableStatus do
			debug_print("#self.tableStatus",self.tableStatus[i].id,self.tableStatus[i].state)
		end
		for i=1,#self.exchangeInfo do
			for j=1,#self.exchangeInfo[i].state do
				hzj_print("#self.exchangeInfo",self.exchangeInfo[i].state[j].id,self.exchangeInfo[i].count)
				
			end
		end
		debug_print(msg.activityId,"msg.activityId")
		self:ShowPanel(msg.activityId)
		self:GetActiveTime(msg.activityId,msg.nowTime)
	end
end

--招財貓
function ActiveCls:ZhaoCaiCatActivityQueryResult(msg)
	hzj_print("招財貓")
	-- self:ShowPanel(19)
	self:ShowPanel(self.buttonId)

	self:ShowLuckyCatCost(msg)
	self.luckyCatAnim:Play("show")
	self:ShowLuckyCatVip(msg.zhaoCaiCatID)
	self:ShowLuckyCatTime(msg.activitySurplusTime)
end

function ActiveCls:ZhaoCaiCatActivityChouJiangResult(msg)
	debug_print(msg.currentGetDiamonds)
	self.luckyCatCount = msg.currentGetDiamonds
	self.nextLuckyCatTimes = msg.nextZhaoCaiCatID
	self.msg = msg
	local list = {}
	list = self:GetNumberList(self.luckyCatCount,true)
	for i=1,#self.ScrollView do
		if #list < i then
			list[i] = 0
		end
	end
	for i=1,#self.ScrollView do
		self.luckyCatPasstime[i] = 0
		self.luckyCatDiffTime[i] = 0
		-- self.luckyCatPos[i] = Vector3(self.luckyCatPos[i].x,self.ScrollView[i].localPosition.y,self.luckyCatPos[i].z)
		self.endPosY[i] = (lastPosY/10) * list[i] + lastPosY*2 + 0.5
	end
	self.luckyCatMove = true
end

function ActiveCls:ZhaoCaiCatActivityChouJiangRecordResult(msg)
	if msg.state == 0 then
		if self.recordNum > 0 then
			self.luckyCatRecord = msg.zhaoCaiCatChouJiangRecord
		else
			self:SetLuckyCatRecord(msg.zhaoCaiCatChouJiangRecord)
		end
		self.recordNum = self.recordNum + 1 
	end
end

--連續累計充值
function ActiveCls:ConRecActivityQueryResult(msg)
	self:ShowPanel(msg.activityId)
	self:LoadTotalMsgPanel(msg)
	for i=1,#msg.cumComPro do
		hzj_print("id:"..msg.cumComPro[i].cumComId.."   state    "..msg.cumComPro[i].cumComState)
	end
end

function ActiveCls:ConRecActivityAwaQueryResult(msg)
	self:GetItems(msg.conRecAwardItem)
    self:ConRecActivityQueryRequest()
end

function ActiveCls:GetItems(item)
	local itemstables = {}
	for i=1,#item do
		itemstables[i] = {}
		itemstables[i].id = item[i].itemID
		itemstables[i].count = item[i].itemNum
		local _,data,_,_,itype = gametool.GetItemDataById(item[i].itemID)
		local color = gametool.GetItemColorByType(itype,data)
		itemstables[i].color = color
	end
	local windowManager = self:GetGame():GetWindowManager()
    local AwardCls = require "GUI.Task.GetAwardItem"
    windowManager:Show(AwardCls,itemstables)
end

function ActiveCls:SinglContiRecharActivityQueryResult(msg)
	-- self:ShowPanel(28)
	self:ShowPanel(self.buttonId)

	self:ShowDailyContinuePanel(msg)
end

function ActiveCls:SinglContiRecharActivityAwaQueryResult(msg)
	self:GetItems(msg.singlContiRecharAwardItem)
	self:SinglContiRecharActivityQueryRequest()
end

function ActiveCls:ZhaoCaiCatActivityQueryRequest()
	self.myGame:SendNetworkMessage( require "Network.ServerService".ZhaoCaiCatActivityQueryRequest())
end

function ActiveCls:ZhaoCaiCatActivityChouJiangRequest(id)
	self.myGame:SendNetworkMessage( require "Network.ServerService".ZhaoCaiCatActivityChouJiangRequest(id))
end

function ActiveCls:ConRecActivityQueryRequest()
	self.myGame:SendNetworkMessage( require "Network.ServerService".ConRecActivityQueryRequest())
end

function ActiveCls:SinglContiRecharActivityQueryRequest()
	self.myGame:SendNetworkMessage( require "Network.ServerService".SinglContiRecharActivityQueryRequest())
end

function ActiveCls:SinglContiRecharActivityAwaQueryRequest(type,id)
	self.myGame:SendNetworkMessage( require "Network.ServerService".SinglContiRecharActivityAwaQueryRequest(type,id))
end

function ActiveCls:DailyRechargeActivityQueryRequest(id)
	self.myGame:SendNetworkMessage( require "Network.ServerService".DailyRechargeActivityQueryRequest(id))
end

function ActiveCls:DailyRechargeActivityAwardQueryRequest(purProId)
	self.myGame:SendNetworkMessage( require "Network.ServerService".DailyRechargeActivityAwardQueryRequest(purProId))
end

function ActiveCls:HappyTurnMusicRequest(turnType)
	self.myGame:SendNetworkMessage( require "Network.ServerService".HappyTurnMusicRequest(turnType))
end

function ActiveCls:HappyTurnMusicQueryRequest()
	self.myGame:SendNetworkMessage( require "Network.ServerService".HappyTurnMusicQueryRequest())
end

function ActiveCls:OnDailyChargeButtonClicked()
	self:OnTotalChargeButtonClicked()
end

function ActiveCls:OnDailyGetButtonClicked()
	local data = require "StaticData.Activity.ContinueDailyChargeAward":GetData(self.dailyId)
	for i=1,#self.dailyMsgData do
		if self.dailyMsgData[i].leiJiComId == self.dailyId then
			if self.dailyMsgData[i].leiJiComState == 1 then
				self:SinglContiRecharActivityAwaQueryRequest(data:GetType(),self.dailyId)
			end
		end
	end
end

function ActiveCls:OnActiveReturnClicked()
	local sceneManager = utility:GetGame():GetSceneManager()
	sceneManager:PopScene()
end

function ActiveCls:OnTotalChargeButtonClicked()
	local windowManager = self:GetGame():GetWindowManager()
    windowManager:Show(require "GUI.Deposit.Deposit")
end

function ActiveCls:OnRefreshButtonClicked()
	self.myGame:SendNetworkMessage( require "Network.ServerService".ActivityTimeLimitRefreshRequest(self.exchangeType,self.buttonId))	
end

function ActiveCls:OnExchangeButton1Clicked()
	self.exchangeType=1
	self:SetExchangeInfo(1)
end

function ActiveCls:OnExchangeButton2Clicked()
	self.exchangeType=2	
	self:SetExchangeInfo(2)
end

function ActiveCls:OnExchangeButton3Clicked()
	self.exchangeType=3
	self:SetExchangeInfo(3)
end

function ActiveCls:OnTotalFinshButton1Clicked()
	self:GetTotalAward(1,self.totalId[1])
end

function ActiveCls:OnTotalFinshButton2Clicked()
	self:GetTotalAward(1,self.totalId[2])
end

function ActiveCls:OnTotalFinshButton3Clicked()
	self:GetTotalAward(1,self.totalId[3])
end

function ActiveCls:GetTotalAward(type,id)
	self.myGame:SendNetworkMessage( require "Network.ServerService".ConRecActivityAwaQueryRequest(type,id))	
end

function ActiveCls:OnTotalFinshBoxButton1Clicked()
	self:TotalBoxButton(1)
end

function ActiveCls:OnTotalFinshBoxButton2Clicked()
	self:TotalBoxButton(2)
end

function ActiveCls:OnTotalFinshBoxButton3Clicked()
	self:TotalBoxButton(3)
end

function ActiveCls:OnTotalFinshBoxButton4Clicked()
	self:TotalBoxButton(4)
end

function ActiveCls:OnTotalFinshBoxButton5Clicked()
	self:TotalBoxButton(5)
end

function ActiveCls:OnTotalFinshBoxButton6Clicked()
	self:TotalBoxButton(6)
end

function ActiveCls:OnTotalFinshBoxButton7Clicked()
	self:TotalBoxButton(7)
end

function ActiveCls:OnTotalFinshBoxButton8Clicked()
	self:TotalBoxButton(8)
end

function ActiveCls:OnTotalFinshBoxButton9Clicked()
	self:TotalBoxButton(9)
end

function ActiveCls:TotalBoxButton(id)
	if self.totalBoxState[id] == 1 then
		self:GetTotalAward(2,self.totalBoxId[id])
	else
		local windowManager = self:GetGame():GetWindowManager()
    	windowManager:Show(require "GUI.Active.ActiveAwardShow","StaticData.Activity.ContinueTotalAward",self.totalBoxId[id])
	end
	
end

function ActiveCls:CallBack(table,flag)	
end

function ActiveCls:OnProgressButtonClicked()
	local key = require "StaticData.Activity.topupActivity":GetKeys()
	if self.progressDataId <= key.Length then
		local windowManager = utility:GetGame():GetWindowManager()
		local ConnectCls = require "GUI.Connecting.Connecting"	
	-- local data = require "StaticData.Activity.topupActivity":GetData(1)
		local data = require "StaticData.Activity.topupActivity":GetData(self.progressDataId)
		self.connectting = windowManager:Show(ConnectCls,data,1,29,self.CallBack)
		debug_print("sdhfkjshdfksdhfjksdf",self.connectting,self)
	end
end

function ActiveCls:OnOneTimeButtonClicked()
	if not self.isRotate then
		self:HappyTurnMusicRequest(1)
	end
end

function ActiveCls:OnTenTimeButtonClicked()
	if not self.isRotate then
		self:HappyTurnMusicRequest(2)
	end
	-- self.animtor:Play("get")
end

function ActiveCls:OnPointButtonClicked()
	local windowManager = self:GetGame():GetWindowManager()
    windowManager:Show(require "GUI.Shop.Shop",KShopType_LotteryShop)
end

function ActiveCls:OnLuckyCatButtonClicked()
	if not self.luckyCatMove then
		self.luckyCatAnim:Play("click")
		self:ZhaoCaiCatActivityChouJiangRequest(1)
	end
end

function ActiveCls:SetLuckyCatRecord(zhaoCaiCatChouJiangRecord)
	self:RemoveLuckyCatRecord()
	for i=1,#zhaoCaiCatChouJiangRecord do
		local AcitveItemCls = require "GUI.Active.LuckyCatRecord".New(self.luckyCatRecordPoint,zhaoCaiCatChouJiangRecord[i].playerName,tostring(zhaoCaiCatChouJiangRecord[i].diamondNum))
		self.luckyCatNode[i] = AcitveItemCls
		self:AddChild(self.luckyCatNode[i])
	end
end

local numList = {}
function ActiveCls:GetNumberList(num,start)
	if start then
		numList = {}
	end
	local t1,t2 = math.modf(num/10)
	t2 = (t2*10)
	numList[#numList + 1] = t2
	if t2 == 0 or t1 ~= 0 then
		self:GetNumberList(t1,false)
	end
	return numList
end

--逐額充值
function ActiveCls:ShowProgressChargePanel(data)
	self.progressMsgData = data.buyPur
	self.progressDataId = data.curBuyState
	self:RemoveProgressCharge()
	self:ShowProgressCharge()
	self:LoadProgressCharge(data.buyPur)
	self:LoadProgressAward(data)
end

function ActiveCls:ShowProgressCharge()

	local data = require "StaticData.Activity.Activity":GetData(self.buttonId)
	-- local data = require "StaticData.Activity.Activity":GetData(29)
	local active = require "StaticData.Activity.Active":GetData(data:GetActivityType())
	local desc = active:GetDescription()
	self.progressDesc.text = desc
	self.progressNode = {}
	local keys = require "StaticData.Activity.ProgressChargeInfo":GetKeys()
	for i=0,keys.Length - 1 do
		local AcitveItemCls = require "GUI.Active.ProgressChargeText".New(self.progressRankPoint,keys[i],1,nil,nil)
		self.progressNode[i + 1] = AcitveItemCls
		self:AddChild(AcitveItemCls)
	end
end

function ActiveCls:LoadProgressRecord(data)
	self.progressRecordNode = {}
	for i=1,#data do
		local AcitveItemCls = require "GUI.Active.ProgressChargeText".New(self.progressRecordPoint,data[i].curBuyState,2,data[i].playerName,data[i].diamondNum)
		self.progressRecordNode[i + 1] = AcitveItemCls
		self:AddChild(AcitveItemCls)
	end
end

function ActiveCls:LoadProgressAward(data)
	local progressKeys = require "StaticData.Activity.TopUpProgressAward":GetKeys()
	local count = require "StaticData.Activity.TopUpProgressAward":GetData(progressKeys[progressKeys.Length - 1]):GetBuyNum()
	self.progressFill.fillAmount = data.curPurchaseNum/count
	local key =  require "StaticData.Activity.topupActivity":GetKeys()
	if data.curBuyState > key.Length then
		self.progressButton.transform:GetComponent(typeof(UnityEngine.UI.Image)).material = utility.GetGrayMaterial()
		data.curBuyState = key[key.Length - 1]
	else
		self.progressButton.transform:GetComponent(typeof(UnityEngine.UI.Image)).material = utility.GetCommonMaterial()
	end
	local progressData = require "StaticData.Activity.topupActivity":GetData(data.curBuyState)
	local _,data,itemName,iconPath,itemType = gametool.GetItemDataById(progressData:GetIetm())
	utility.LoadSpriteFromPath(iconPath,self.progressAwardIcon)
	self.progressAwardText.text = string.format(ActivityStringTable[5],progressData:GetNum())
	self.progressButtonText.text = string.format(ActivityStringTable[7],progressData:GetPrice()/100)
	
end

function ActiveCls:LoadProgressCharge(data)
	self.progressAwardNode = {}
	local progressKeys = require "StaticData.Activity.TopUpProgressAward":GetKeys()
	local progressData = require "StaticData.Activity.TopUpProgressAward"
	for i=0,progressKeys.Length - 1 do
		local state
		for j=1,#data do
			if data[j].buyPurId == progressKeys[i] then
				state = data[j].awardState
				break
			end
		end
		local AcitveItemCls = require "GUI.Active.DailyContinueItem".New(self.progressPoint,progressData,3,progressKeys[i],state)
		AcitveItemCls:SetCallback(self,self.ProgressClicked)
		self.progressAwardNode[i + 1] = AcitveItemCls
		self:AddChild(AcitveItemCls)
	end
end

function ActiveCls:ProgressClicked(id)
	if self.progressMsgData ~= nil then
		for i=1,#self.progressMsgData do
			if self.progressMsgData[i].buyPurId == id then
				if self.progressMsgData[i].awardState == 1 then
					self:DailyRechargeActivityAwardQueryRequest(id)				
    			else
    				local windowManager = self:GetGame():GetWindowManager()
    				windowManager:Show(require "GUI.Active.ActiveAwardShow","StaticData.Activity.TopUpProgressAward",id)
    			end
				break
			end
		end
	end
end

function ActiveCls:RemoveProgressCharge()
	if self.progressNode ~= nil then
		for i=1,#self.progressNode do
			self:RemoveChild(self.progressNode[i],true)
		end
	end
	if self.progressAwardNode ~= nil then
		for i=1,#self.progressAwardNode do
			self:RemoveChild(self.progressAwardNode[i],true)
		end
	end
end

function ActiveCls:RemoveProgressRecord()
	if self.progressRecordNode ~= nil then
		for i=1,#self.progressRecordNode do
			self:RemoveChild(self.progressRecordNode[i],true)
		end
	end
end

--單筆連續充值
function ActiveCls:ShowDailyContinuePanel(msg)
	self:RemoveDailyAllItem()
	local data = require "StaticData.Activity.Activity":GetData(self.buttonId)
	-- local data = require "StaticData.Activity.Activity":GetData(28)
	local active = require "StaticData.Activity.Active":GetData(data:GetActivityType())
	local desc = active:GetDescription()
	local notice = active:GetDescriptionNotice()
	self.dailyId = msg.curId
	self.dailyDesc.text = desc
	self.dailyNode = {}
	self.dailyDescNotice.text = notice
	self:LoadDailyItem(msg.leiJiAwads)
	self:LoadDailyAward(msg)
	self:LoadDailyAwardItem(msg.curId)
end

function ActiveCls:LoadDailyAward(data)
	local dailyData = require "StaticData.Activity.ContinueDailyChargeAward":GetData(data.curId)
	local descData = require "StaticData.Activity.ActiveItem":GetData(dailyData:GetInfo())
	self.dailyTitle.text = descData:GetDescription()
	self.dailyChargeNum.text = data.curDayDiamonds
	local time = self:GetLocakTime(data.actSurTime)
	local timesTable = utility.Split(time,":")
	self.dailyLastTime.text = string.format(ActivityStringTable[0],timesTable[1],timesTable[2],timesTable[3])
end

function ActiveCls:LoadDailyAwardItem(id)
	self.dailyAwardNode = {}
	local dailyData = require "StaticData.Activity.ContinueDailyChargeAward":GetData(id)
	local itemID = dailyData:GetItemID()
	local itemNum = dailyData:GetItemNum()
	for j=0,itemID.Count - 1 do
		local _,data,_,_,itype = gametool.GetItemDataById(itemID[j])
		local color = gametool.GetItemColorByType(itype,data)
		local awardItem = require "GUI.Active.ActiveAwardItem".New(self.dailyAwardPoint,itemID[j],itemNum[j],color,false)
		self:AddChild(awardItem)
		self.dailyAwardNode[#self.dailyAwardNode + 1] = awardItem
	end
end

function ActiveCls:LoadDailyItem(data)
	local dailyData = require "StaticData.Activity.ContinueDailyChargeAward"
	self.dailyMsgData = data
	self:DailyHideCharge()
	local keys = dailyData:GetKeys()
	for i=1,#data do
		if data[i].leiJiComId == self.dailyId then
			if data[i].leiJiComState == 1 then
				self.fillId = data[i].leiJiComId 
				self.dailyGetButton.transform:GetComponent(typeof(UnityEngine.UI.Image)).material = utility.GetCommonMaterial()
				self.dailyFinshedItem:SetActive(true)
			elseif data[i].leiJiComState == 2 then
				self.dailyFinshedItem:SetActive(true)
				self.fillId = data[i].leiJiComId - 1
			elseif data[i].leiJiComState == 0 then
				self.fillId = data[i].leiJiComId
				self.dailyDoneItem:SetActive(true)
			end
		end
	end
	self.dailyFill.fillAmount = tonumber(self.fillId)/keys.Length
	for i=0,keys.Length - 1 do
		local dataType = dailyData:GetData(keys[i]):GetType()
		local state
		for j=1,#data do
			if data[j].leiJiComId == keys[i] then
				state = data[j].leiJiComState
				break
			end
		end
		local DailyContinueCls = require "GUI.Active.DailyContinueItem".New(self.dailyPoint,dailyData,dataType,keys[i],state)
		self.dailyNode[#self.dailyNode + 1] = DailyContinueCls
		DailyContinueCls:SetCallback(self,self.DailyItemClicked)
		self:AddChild(DailyContinueCls)
	end
end

function ActiveCls:DailyHideCharge()
	self.dailyDoneItem:SetActive(false)
	self.dailyFinshedItem:SetActive(false)
	self.dailyGetButton.transform:GetComponent(typeof(UnityEngine.UI.Image)).material = utility.GetGrayMaterial()
end

function ActiveCls:DailyItemClicked(id)
	if self.dailyMsgData ~= nil then
		local dataType = require "StaticData.Activity.ContinueDailyChargeAward":GetData(id):GetType()
		for i=1,#self.dailyMsgData do
			if self.dailyMsgData[i].leiJiComId == id then
				if self.dailyMsgData[i].leiJiComState == 2 then
					local windowManager = self:GetGame():GetWindowManager()
    				windowManager:Show(require "GUI.Active.ActiveAwardShow","StaticData.Activity.ContinueDailyChargeAward",id)
    			elseif self.dailyMsgData[i].leiJiComState == 1 then
    				self:SinglContiRecharActivityAwaQueryRequest(dataType,id)
    			end
				break
			end
		end
	end
end

function ActiveCls:RemoveDailyAllItem()
	if self.dailyNode ~= nil then
		for i=1,#self.dailyNode do
			self:RemoveChild(self.dailyNode[i],true)
		end
	end
	if self.dailyAwardNode ~= nil then
		for i=1,#self.dailyAwardNode do
			self:RemoveChild(self.dailyAwardNode[i],true)
		end
	end
end


--連續充值
function ActiveCls:ShowTotalPanel()
	local data = require "StaticData.Activity.ContinueDailyAward"
	local keys = data:GetKeys()
	self:RemoveTotalItem()
	self.totalNode = {}
	for i=0,keys.Length - 1 do
		local total = data:GetData(keys[i])
		self.totalDiaNum[i + 1].text = total:GetPrice()
		self.totalItemDesc[i + 1].text = string.format(PointFight[10],"<color=#74ff21>"..total:GetPrice().."</color>")
		local itemID = total:GetItemID()
		local itemNum = total:GetItemNum()
		local colors = {}
		for j=0,itemID.Count - 1 do
			local _,data,_,_,itype = gametool.GetItemDataById(itemID[j])
			local color = gametool.GetItemColorByType(itype,data)
			colors[j] = color
			local awardItem = require "GUI.Active.ActiveAwardItem".New(self.totalPoint[i + 1],itemID[j],itemNum[j],colors[j],false)
			self:AddChild(awardItem)
			self.totalNode[#self.totalNode + 1] = awardItem
		end
	end
end

function ActiveCls:RemoveTotalItem()
	if self.totalNode ~= nil then
		for i=1,#self.totalNode do
			self:RemoveChild(self.totalNode[i],true)
		end
	end
end

--連續充值協議
function ActiveCls:LoadTotalMsgPanel(msg)
	local activeData = require "StaticData.Activity.Activity":GetData(msg.activityId)
	local descData = require "StaticData.Activity.Active":GetData(activeData:GetActivityType())
	self.totalDesc.text = descData:GetDescription()
	self:HideTotalState()
	self:HideTotalBoxState()
	local time = self:GetLocakTime(msg.actSurTime)
	local timesTable = utility.Split(time,":")
	for i=1,#timesTable do
		timesTable[i] = "<color=#ffff00>"..timesTable[i].."</color>"
	end
	self.totalId = {}
	self.totalBoxId = {}
	self.totalBoxState = {}
	self.totalLastTime.text = string.format(ActivityStringTable[0],timesTable[1],timesTable[2],timesTable[3])
	local data = msg.curPosComPro
	for i=1,#data do
		self.totalId[i] = data[i].curPosId
		self.totalFinshedDays[i].text = string.format(PointFight[11],data[i].curPosDay)
		if data[i].curPosState == 0 then
			self.totalItemDone[i]:SetActive(true)
		elseif data[i].curPosState == 1 then
			self.totalItemFinshed[i].gameObject:SetActive(true)
		elseif data[i].curPosState == 2 then
			self.totalItemNot[i]:SetActive(true)
		end
	end
	local box = msg.cumComPro
	for i=1,#box do
		self.totalBoxId[i] = box[i].cumComId
		self.totalBoxState[i] = box[i].cumComState
		if box[i].cumComState == 0 then
			self.totalBoxDone[i]:SetActive(true)
		elseif box[i].cumComState == 1 then
			self.totalBoxFinshed[i].gameObject:SetActive(true)
			self.totalBoxFinshed[i].material = utility.GetCommonMaterial()
		elseif box[i].cumComState == 2 then
			self.totalBoxFinshed[i].gameObject:SetActive(true)
			self.totalBoxFinshed[i].material = utility.GetGrayMaterial()
		end
	end
end

function ActiveCls:HideTotalState()
	for i=1,#self.totalItemNot do
		self.totalItemNot[i]:SetActive(false)
		self.totalItemFinshed[i].gameObject:SetActive(false)
		self.totalItemDone[i]:SetActive(false)
	end
end

function ActiveCls:HideTotalBoxState()
	for i=1,#self.totalBoxFinshed do
		self.totalBoxFinshed[i].gameObject:SetActive(false)
		self.totalBoxDone[i].gameObject:SetActive(false)
	end
	
end


--招財貓
function ActiveCls:ShowLuckyCat()
	-- self.exchangeTimeLabel.transform.sizeDelta = Vector2(100,100)
	-- debug_print(self.exchangeTimeLabel.transform.rect.width)
	
	local AcitveItemCls = require "GUI.Active.LuckyCatRecord".New(self.luckyCatRecordPoint,"你好啊進擊的冰綠茶",tostring(58900))
	self:AddChild(AcitveItemCls)
	self.luckyCatAnim:Play("show")
	self:ShowLuckyCatVip(3)
	-- for i=1,#self.luckyCatPasstime do
	-- 	self.luckyCatPasstime[i] = 0
	-- end
end

function ActiveCls:RemoveLuckyCatRecord()
	if self.luckyCatNode ~= nil then
		for i=1,#self.luckyCatNode do
			self:RemoveChild(self.luckyCatNode[i],true)
		end
	end
end

function ActiveCls:ShowLuckyCatVip(id)
	local luckyCat = require "StaticData.Activity.NewServiceCat"
	local keys = luckyCat:GetKeys()
	local lastId = id
	if id > keys.Length then
		id = keys[keys.Length - 1]
	end
	local data = luckyCat:GetData(id)
	local price = data:GetPrice()
	local nowVip = data:GetVip()
	self.luckyCatCost.text = price
	self.luckyCatVipText.text = "VIP"..nowVip
	local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    local playerVip = userData:GetVip()
    local tableId = 0

    for i=0,keys.Length - 1 do
    	local vip = luckyCat:GetData(keys[i]):GetVip()
    	local lastVip = luckyCat:GetData(keys[keys.Length - 1]):GetVip()
    	if playerVip >= lastVip then
    		tableId = keys[keys.Length - 1]
    		-- debug_print(tableId)
    		break
		else
			if vip > playerVip then
    			tableId = keys[i] - 1
    			break
			end
		end
    end
    if tableId - id >= 0 then
    	self.luckyCatTimes.text = tableId - id + 1
    else
    	self.luckyCatTimes.text = 0
    end
    if lastId > keys.Length then
    	self.luckyCatTimes.text = 0
    end
end

--招財貓活動時間
function ActiveCls:ShowLuckyCatTime(time)
	local times = self:GetLocakTime(time)
	local timesTable = utility.Split(times,":")
	self.luckyCatDays.text = timesTable[1]
	self.luckyCatHours.text =string.format(ActivityStringTable[8],timesTable[2],timesTable[3])
end

function ActiveCls:ShowLuckyCatCost(msg)
	self.luckyCatCumuGet.text = msg.cumulativeGetDiamonds
	self.luckyCatCumuCost.text = msg.cumulativeConsumeDiamonds
end

function ActiveCls:LuckyCatMoveOut()
	if self.luckyCatMove then
		for i=1,#self.ScrollView do
			self.luckyCatDiffTime[i] = (self.luckyCatPasstime[i]/self.luckyCatTime[i])
	 		if self.luckyCatDiffTime[i] >= 1 then
				self.luckyCatDiffTime[i] = 1
			end
			if self.luckyCatDiffTime[5] >= 1 then
				self.luckyCatMove = false
				self.luckyCatAnim:Play("get")
				self:ShowLuckyCatVip(self.nextLuckyCatTimes)
				self:ShowLuckyCatCost(self.msg)
				self:SetLuckyCatRecord(self.luckyCatRecord)
			end
			local TweenUtility = require "Utils.TweenUtility"

			self.posY[i] = TweenUtility.EaseOutQuad(self.luckyCatPos[i].y, self.endPosY[i], self.luckyCatDiffTime[i])
			if self.posY[i] >= lastPosY then
				-- debug_print(self.luckyCatPos[i].y)
				self.posY[i] = self:GetLuckyCatNumber(self.posY[i],lastPosY)
			end
			-- debug_print(posY[4])
			self.ScrollView[i].localPosition = Vector3(self.luckyCatPos[i].x,self.posY[i],self.luckyCatPos[i].z)
			self.luckyCatPasstime[i] = self.luckyCatPasstime[i] + UnityEngine.Time.deltaTime
			-- debug_print(self.luckyCatDiffTime[5].."aaaaaaaaaaaaaaaa"..self.luckyCatPasstime[5].."aaaaaaaaaaaaaaaaaaaaaa"..self.luckyCatTime[5])
		end
	else
		
	end
end

function ActiveCls:GetLuckyCatNumber(endNum,startNum)
	endNum = endNum - startNum
	if endNum/startNum >= 1 then
		endNum = self:GetLuckyCatNumber(endNum,startNum)
	end
	return endNum
end

--轉轉樂
function ActiveCls:ShowWheel()
	self:ShowWheelItem()
	local data = require "StaticData.Activity.LuckyLottery":GetData(1)
	self.oneTimeNum.text = data:GetOnetime()
	self.tenTimeNum.text = data:GetTentime()
	self.animtor:Play("show")
	self:ResetWheelPoint()
end
function ActiveCls:OnLoadPlayerResponse()

	self:ResetWheelPoint()
end

function ActiveCls:ResetWheelPoint()
	local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
	self.pointNum.text = userData:GetHappyTurnMusicJiFenCoin()
end

function ActiveCls:LoadWheelTime(data)
	local text = ""
	local times = self:GetLocakTime(data.turnMusicSurTime)
	local timesTable = utility.Split(times,":")
	if #timesTable == 3 then
		text = string.format(ActivityStringTable[0],timesTable[1],timesTable[2],timesTable[3])
	end
	self.timeLabel.text = text
	self.lastTime = 0
	self.wheelLastTime = data.turnMusicCDTime/1000
	self.freeTime.text = utility.ConvertTime(self.wheelLastTime)
	self:SetWheelFreeTime(data.turnMusicCDTime)

end

function ActiveCls:SetWheelFreeTime(time)
	if time == 0 then
		self.ontTimeIcon:SetActive(false)
		self.freeObj:SetActive(false)
		self.oneTimeNum.text = "本次免费"
	else
		self.ontTimeIcon:SetActive(true)
		self.freeObj:SetActive(true)
	end
end

function ActiveCls:WheelTimeCountdown()
	if self.wheelLastTime ~= nil then
		if self.wheelLastTime <= 0 then
			self.freeTime.gameObject:SetActive(false)
		else
			self.freeTime.gameObject:SetActive(true)
		--	self.countTime=self.countTime-Time.deltaTime
			if os.time() - self.lastTime >= 1 then
				self.lastTime = os.time()
				self.wheelLastTime = self.wheelLastTime - 1
			end
			self.freeTime.text = utility.ConvertTime(self.wheelLastTime)
		end	
	end
end

local slowRotate = false
local time = 6
local showTime = 5
function ActiveCls:WheelRotate()

	if self.isRotate then
			self:SlowWheelRotate()
	else
		if slowRotate then
			showTime = showTime - Time.deltaTime
			if showTime < 0 then
				self.animtor:Play("show")
				slowRotate = false
			end
		end
	end
end


function ActiveCls:SlowWheelRotate()

	 
	
	 local t = self.passedTime/time
	 if t >= 1 then
		t = 1
		self.isRotate = false
		-- self.rotateZ = self.wheelBack.eulerAngles.z
		slowRotate = true
		showTime = 5
		self.animtor:Play("get")
		if self.turnMusicAwaId ~= 0 then
			self:SetWheelItem(self.turnMusicAwaId)
		else
			self:SetItems(self.happyTurnMusicTenAwa)
		end
	end
	local TweenUtility = require "Utils.TweenUtility"

	local z = TweenUtility.EaseOutCirc(self.rotateZ, -self.endEulerAnglesZ-720, t)
	self.wheelBack.eulerAngles = Vector3(0,0,z)
	self.passedTime = self.passedTime + UnityEngine.Time.deltaTime

	-- local finished = false
	-- local t = passedTime / totalTime
	-- if t >= 1 then
	-- 	t = 1
	-- 	finished = true
	-- end

	-- local TweenUtility = require "Utils.TweenUtility"
	-- local value = TweenUtility.EaseInOutSine(0, 10, t)


	-- passedTime = passedTime + UnityEngine.Time.deltaTime

	-- if finished then

	-- end



	-- slowSpeed = moveSpeed - moveSpeed * Time.time
	-- self.wheelBack:Rotate(Vector3.back  * -slowSpeed)
	-- self.wheelBack.rotation = Quaternion.Euler(0,0,-120)
	-- if slowSpeed then

	--  moveSpeed = moveSpeed - 10
	
	--  if moveSpeed <= 650 and math.ceil(aa +45) > math.ceil(self.wheelBack.eulerAngles.z) and math.ceil(aa +30) < math.ceil(self.wheelBack.eulerAngles.z) then
	-- 	moveSpeed = 50
	-- end
	-- self.wheelBack:Rotate(Vector3(0, 0, -1)*math.abs(moveSpeed)*Time.deltaTime)
	-- debug_print(moveSpeed.."速度"..aa.."旋转aaaaaaaaaaaaaaa"..self.wheelBack.eulerAngles.z)
	-- if moveSpeed <= 200 and math.ceil(aa+15) > math.ceil(self.wheelBack.eulerAngles.z) and math.ceil(aa - 15) < math.ceil(self.wheelBack.eulerAngles.z) then
	-- 	self.isRotate = false
	-- 	time = 0.5
	-- 	moveSpeed = 1000
	-- 	self.animtor:Play("get")

		-- if not slowSpeed then
		-- 	targetRotation = Quaternion.Euler(0,0, (delaultAngle * count + self.origionZ)) * Quaternion.identity
		-- 	slowSpeed = true
		-- 	debug_print(delaultAngle * count + self.origionZ.."坐标aaaaaaaaaaaaaaaaa"..self.wheelBack.rotation.z)
		-- else
		-- self.wheelBack.rotation = Quaternion.Lerp(self.wheelBack.rotation, targetRotation, Time.deltaTime * 10)
  --       if Quaternion.Angle(self.wheelBack.rotation,targetRotation) < 1 then
        	-- self.wheelBack.rotation = Vector3(0,0,z)
  --           self.isRotate = false
  --           slowSpeed = false
  --           slowRotate = true
		-- 	-- time = 0.5
		-- 	-- moveSpeed = 1000
		-- 	-- self.animtor:Play("get")
  --       end
    -- end
		-- self.wheelBack.rotation = UnityEngine.Quaternion.Slerp(self.wheelBack.rotation, Quaternion.Euler(0, 180, 0), Vector3(0, 0, -1)*moveSpeed*Time.deltaTime)
		-- self.isRotate = false
		-- slowRotate = true
		-- time = 0.5
		-- moveSpeed = 1000
		-- self.animtor:Play("get")
	-- end
	-- end
	-- if self.wheelBack.localRotation.z > 120 then
	-- 	slowSpeed = false
	-- end
	-- self.wheelBack:Rotate(Vector3.back * Time.deltaTime * slowSpeed)
end

--转盘item
function ActiveCls:ShowWheelItem()
	local keys = require "StaticData.Activity.ActivityCircle":GetKeys()
	local id = {}
	local num = {}
	for i=0,keys.Length - 1 do
		local data = require "StaticData.Activity.ActivityCircle":GetData(keys[i])
		id[#id + 1] = data:Getinfo()
		num[#num + 1] = data:GetAwardItemNumber()
	end
	local PropUtility = require "Utils.PropUtility"
	for i=1,#self.wheelItem do
		local iconPath,color,itemType = self:WheelItemInfo(id[i])
		utility.LoadSpriteFromPath(iconPath,self.wheelItemIcon[i])
		PropUtility.AutoSetRGBColor(self.wheelItemFrame[i],color)
		if itemType == "RoleChip" or  itemType == "EquipChip" then
        	self.DebrisIcon[i]:SetActive(true)
       	 self.DebrisCorner[i]:SetActive(true)
    	else
    		self.DebrisIcon[i]:SetActive(false)
       	 self.DebrisCorner[i]:SetActive(false)
    	end
    	self.wheelItemNum[i].text = num[i]
	end
	-- 
	-- if itemType == "RoleChip" or  itemType == "EquipChip" then
 --        self.DebrisIcon:SetActive(true)
 --        self.DebrisCorner:SetActive(true)
 --    else
 --    	self.DebrisIcon:SetActive(false)
 --        self.DebrisCorner:SetActive(false)
 --    end
end

function ActiveCls:WheelItemInfo(id,color)
	
	local _,data,itemName,iconPath,itemType = gametool.GetItemDataById(id)
	
	if color == -1 or color == nil then
		color = gametool.GetItemColorByType(itemType,data)
	end
	return iconPath,color,itemType
end

function ActiveCls:RedDotStateQuery()
    -- 查询红点提示
    local S2CGuideRedResult = require "Network.PB.S2CGuideRedResult"
    local UserDataType = require "Framework.UserDataType"
    local RedDotData = self:GetCachedData(UserDataType.RedDotData)
     if RedDotData ~= nil then
     	activeInfo = RedDotData:GetActiveInfo()
     	self:SetActiveRedDot(activeInfo)
     	for i=1,#activeInfo do
    		debug_print(activeInfo[i].activityID)
    	end
        -- local day_consume = RedDotData:GetModuleRedState(S2CGuideRedResult.day_consume)
        -- self.nodeCls[#self.nodeCls]:SetRedDot(day_consume)
        -- local consume = RedDotData:GetModuleRedState(S2CGuideRedResult.consume)
        -- self.nodeCls[1]:SetRedDot(consume)
    end
end

function ActiveCls:RedDotStateUpdated(moduleId,moduleState)
    -- 红点更新处理
    local S2CGuideRedResult = require "Network.PB.S2CGuideRedResult"
    local UserDataType = require "Framework.UserDataType"
    local RedDotData = self:GetCachedData(UserDataType.RedDotData)
    if RedDotData ~= nil then
    	activeInfo = RedDotData:GetActiveInfo()
    	self:SetActiveRedDot(activeInfo)
    end
end

function ActiveCls:SetActiveRedDot(data)
	if self.nodeCls ~= nil then
	for i=1,#self.idtables do
		for j=1,#data do
			if data[j].activityID == self.idtables[i] then
				self.nodeCls[i]:SetRedDot(data[j].red)
				break
			end
		end
	end
	end
end

function ActiveCls:OnActivityQueryRequest(activeid)
	self.myGame:SendNetworkMessage( require "Network.ServerService".ActivityQueryRequest(activeid))
end


function ActiveCls:ShowAwardPanel(activeData,type)
	local itemstables = {}
	if type == 1 or type == 2 then
		self.items = utility.Split(activeData:GetItemID(),";")
		self.nums = utility.Split(activeData:GetItemNum(),";")
		self.color = utility.Split(activeData:GetItemColor(),";")
		for i=1,#self.items do
			itemstables[i] = {}
			itemstables[i].id = self.items[i]
			itemstables[i].count = self.nums[i]
			itemstables[i].color = self.color[i]
		end
	else
		local gametool = require "Utils.GameTools"
		local itemId = activeData:GetItemID()
		local itemNum = activeData:GetItemNum()
		local colors = {}
		for i=0,itemId.Count - 1 do
			local _,data,_,_,itype = gametool.GetItemDataById(itemId[i])
			local color = gametool.GetItemColorByType(itype,data)
			colors[i] = color
		end
	
		for i=0,itemId.Count - 1 do
			itemstables[i + 1] = {}
			itemstables[i + 1].id = itemId[i]
			itemstables[i + 1].count = itemNum[i]
			itemstables[i + 1].color = colors[i]
		end
	end

	local windowManager = self:GetGame():GetWindowManager()
    local AwardCls = require "GUI.Task.GetAwardItem"
    windowManager:Show(AwardCls,itemstables)
end

function ActiveCls:GetActiveTime(activityId,time)
	if time ~= nil then
		local activeData = require "StaticData.Activity.Activity":GetData(activityId)
	-- local serverTime = tonumber(time)
	-- local timeType = activeData:GetTimeType()
	-- local startTime = activeData:GetStartTime()
	-- local endTime = activeData:GetEndTime()
		local activetgrandype = activeData:GetActivetgrandype()
		local text = ""
	-- if timeType == 1 then
	-- 	if serverTime >= startTime and serverTime <= endTime then
	-- 		local lastTime = endTime - serverTime
			local times = self:GetLocakTime(time)
			local timesTable = utility.Split(times,":")
			if #timesTable == 3 then
				text = string.format(ActivityStringTable[0],timesTable[1],timesTable[2],timesTable[3])
			end
		
	-- 	end
	-- end
		if activetgrandype == 1 or activetgrandype == 2 then
			self.lastTimeLabel.text = text
		elseif activetgrandype == 5 then
			self.DaysastTimeLabel.text = text
		elseif activetgrandype ==  7 then
			self.LevelLaseTimeLabel.text = text
		elseif activetgrandype ==8 then
			self.PowerLaseTimeLabel.text = text
		elseif activetgrandype == 17 then
			self.DaysastTimeLabel.text = text
		elseif activetgrandype == 12 then
			self.exchangeTimeLabel.text = text
		end
	end
end


function ActiveCls:GetLocakTime(time)
	local dayChange = 60*60*24
	local hourChange = 60*60
	local minChange = 60
	local day,lastTime = math.modf(time/dayChange)
	local hour
	lastTime = lastTime * dayChange
	hour,lastTime = math.modf(lastTime/hourChange)
	lastTime = lastTime * hourChange
	local min = math.ceil(lastTime/minChange)
	return day..":"..hour..":"..min
end


function ActiveCls:Show()
	local  activeData = require "StaticData.Activity.Activity"
	-- local  data = activeData:GetKeys()
	self.nodeCls = {}
	-------------------------
	--self.idtables[#self.idtables+1]=1
	----------------------
	local id = nil
	if self.idtables~= nil or #self.operationActicity.activities ~= 0 then
		
		if self.idtables ~= nil then
			firstid = self.idtables[1]
			hzj_print(firstid)
			for i=1,#self.idtables do

				local  id = activeData:GetData(self.idtables[i]):GetActivityId()
				local data = require "StaticData.Activity.Active"				
				local typeId = activeData:GetData(id):GetActivityType()
				local name = data:GetData(typeId):GetName()
				local flag =false
				if id == firstid then
					flag=true
					self:OnChildClicked(firstid,nil,nil)
				end
				hzj_print(id , firstid,flag)
				local AcitveItemCls = require "GUI.Active.ActiveItem".New(self.button,id,flag,name,firstid)
				self.nodeCls[i] = AcitveItemCls
				self.nodeCls[i]:SetCallback(self,self.OnChildClicked)
				self:AddChild(AcitveItemCls)
			end
		end
		
		--运营活动
		if #self.operationActicity.activities ~= 0 then
			if firstid == nil then
				firstid=self.operationActicity.activities[1].id

			end
			for i=1,#self.operationActicity.activities do	

				local flag =false
				if self.operationActicity.activities[i].id == firstid then
					flag=true
					self:OnChildServerClicked(firstid,nil,nil,self.operationActicity.activities[1])

				end
				hzj_print(self.button,self.operationActicity.activities[i].id,flag,self.operationActicity.activities[i].baseInfo.title,self.operationActicity.activities[i])
				local AcitveItemCls = require "GUI.Active.ActiveItem".New(self.button,self.operationActicity.activities[i].id,flag,self.operationActicity.activities[i].baseInfo.title,self.operationActicity.activities[i])
				self.nodeCls[#self.nodeCls+1] = AcitveItemCls
				self.nodeCls[#self.nodeCls]:SetCallback(self,self.OnChildServerClicked)
				self:AddChild(AcitveItemCls)
			end
		end

	end

	-- hzj_print(#self.nodeCls,"self.nodeCls")



	-- --老活动
	-- if self.idtables ~= nil then
	-- 	local firstid = self.idtables[1]
	-- 	hzj_print(firstid)
	-- 	for i=1,#self.idtables do
	-- 		local  id = activeData:GetData(self.idtables[i]):GetActivityId()
	-- 		local AcitveItemCls = require "GUI.Active.ActiveItem".New(self.button,id,firstid)
	-- 		self.nodeCls[i] = AcitveItemCls
	-- 		self.nodeCls[i]:SetCallback(self,self.OnChildClicked)
	-- 		self:AddChild(AcitveItemCls)
	-- 	end
	-- 	self:OnChildClicked(firstid,nil,nil)
	-- --运营活动
	-- elseif #self.operationActicity.activities ~= 0 then

	-- end
end


function ActiveCls:SetRedDot()
	if self.nodeCls ~= nil then
		for i=1,#self.nodeCls do
			self.nodeCls[i]:SetRedDot(2)
		end
	end
end

--关闭点中按钮

function ActiveCls:CloseItemOpen(onObj,offObj)
	if onObj ~= nil and offObj ~= nil then
		hzj_print("CloseItemOpen")
		for i=1,#self.nodeCls do
			self.nodeCls[i]:ShowOnOrOff()
		end
		onObj.gameObject:SetActive(true)
		offObj.gameObject:SetActive(false)
	end
end
-------------------------------服务器推送活动------------------------
function ActiveCls:SetSellAvtivity(OperationActicityData)
	for i=1,#self.serverPanelActicity do
		if OperationActicityData.id == self.serverPanelActicity[i]:GetActivityID() then
			self:AddChild(self.serverPanelActicity[i])
			return
		end
		
	end
	local sellAvtivityPanel = require "GUI.Active.SellActivity".New(self.operationActicityLayout,OperationActicityData)
	self:AddChild(sellAvtivityPanel)
	self.serverPanelActicity[#self.serverPanelActicity+1]=sellAvtivityPanel
	-- if self.sellAvtivityPanel == nil then
	
	
	-- end


end
--测试
function ActiveCls:SetTest(OperationActicityData)
	if self.testPanel == nil then
		self.testPanel = require "GUI.Active.SellActivity".New(self.operationActicityLayout,OperationActicityData)
		self:AddChild(self.testPanel)
	else
		self:AddChild(self.testPanel)
	end
end


---------------------------------------------------------------------
--隐藏所有的运营活动
function ActiveCls:HideAllOperationAvtivity()
	for i=1,#self.serverPanelActicity do
		self:RemoveChild(self.serverPanelActicity[i])
	end
	-- if self.testPanel ~= nil then
	-- 	self:RemoveChild(self.testPanel)
	-- end
	-- if self.sellAvtivityPanel ~= nil then
	-- 	self:RemoveChild(self.sellAvtivityPanel)
	-- end


end
function ActiveCls:OnChildServerClicked(id,onObj,offObj,OperationActicityData)
	hzj_print("skllllllllllllllllllllllllllllllllllllldfh")
	--self.operationActicityLayout
	
	hzj_print("ididididiidididididdiid",id)
	if self.buttonId ~= id then
		self:SetActivrBase()
		self:ActivePanelHide()
		self:HideAllOperationAvtivity()
		self.operationActicityLayout.gameObject:SetActive(true)
		self.buttonId = id
		if OperationActicityData.type == kActivity_Sale then
			self:SetSellAvtivity(OperationActicityData)
			
			
		-- 	hzj_print("OnChildServerClicked",OperationActicityData.id)
		-- elseif OperationActicityData.id ==10002 then
		-- 	self:SetTest(OperationActicityData)
			
		end
		self:CloseItemOpen(onObj,offObj)

	end

	
end
function ActiveCls:OnChildClicked(id,onObj,offObj)
	 hzj_print(id.."aa",self.buttonId,id,"$$$$$$$$$$$$$$$",onObj,offObj)
	if self.buttonId ~= id then
		self.buttonId = id
		local activeData = require "StaticData.Activity.Activity":GetData(id)
		local activetgrandype = activeData:GetActivetgrandype()
	-- hzj_print(id.."@@@@@@@@@@@@@@@@@@@",self.buttonId,id,"@@@@@",activetgrandype)

		if activetgrandype == 3 then
			self:ZhaoCaiCatActivityQueryRequest()
		elseif activetgrandype == 19 then
			self:ConRecActivityQueryRequest()
		elseif activetgrandype == 21 then
			self:SinglContiRecharActivityQueryRequest()
		elseif activetgrandype == 20 then
			self:DailyRechargeActivityQueryRequest(29)
		elseif activetgrandype == 9 then
			self:HappyTurnMusicQueryRequest()
		else
			self:OnActivityQueryRequest(id)
		end
		
		self:CloseItemOpen(onObj,offObj)
	end
	 debug_print(id.."aa",self.buttonId,id,"aaaaa")

	-- print("aaaaaaaaaaaa",clickedState.name)
end
-- function ActiveCls:SetChildInfo(activeId)
	-- local transform = self:GetUnityTransform()
	-- self.childButton = transform:Find("Button/Button/Viewport/Content/"..activeId):GetComponent(typeof(UnityEngine.UI.Button))
	-- self.activeButton = self.childButton.transform:GetComponent(typeof(UnityEngine.UI.Button))
	-- self.rectTransform = self.childButton.transform:GetComponent(typeof(UnityEngine.RectTransform))
	-- self.activeLabel = self.childButton.transform:Find("ActiveNameLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	-- self.labelrect = self.activeLabel:GetComponent(typeof(UnityEngine.RectTransform))
	-- self.outline = self.activeLabel:GetComponent(typeof(UnityEngine.UI.Outline))
 --    self.buttonImage = self.activeButton.gameObject:GetComponent(typeof(UnityEngine.UI.Image))

-- end

-- function  ActiveCls:HideAllChild()
	-- local  activeData = require "StaticData.Activity.Activity"
	-- local  data = activeData.GetKeys()
	-- for i=0,(data.Length - 1) do
	-- 	self:SetChildInfo(data[i])
	-- 	self.activeButton.transform.localRotation = Quaternion.Euler(0,0,7.2)
	-- 	local onSelectButtonImage = self.activeButton.gameObject:GetComponent(typeof(UnityEngine.UI.Image))
	-- 	onSelectButtonImage.sprite = AtlasesLoader:LoadAtlasSprite("UI/Atlases/active/Tag2")
	-- 	self:ChangePosition(self.rectTransform,212,53)
	-- 	self.activeLabel.fontSize = 33
	-- 	self.activeLabel.transform.localPosition = Vector2(-48,0)
	-- 	self.activeLabel.alignment = UnityEngine.TextAnchor.UpperRight
	-- 	self.activeLabel.color = UnityEngine.Color(0,0,0,1)
	-- 	self.outline.effectColor = UnityEngine.Color(1,1,1,1)
	-- end
-- end

function  ActiveCls:ShowPanel(activeId)
	-- self:HideAllChild()
	-- self:SetChildInfo(activeId)
	-- self.buttonImage.sprite = AtlasesLoader:LoadAtlasSprite("UI/Atlases/active/Tag1")
	-- self:ChangePosition(self.rectTransform,240,70)
	-- self.activeLabel.fontSize = 35
	-- self.activeLabel.transform.localPosition = Vector2(-15,0)
	-- self.activeLabel.alignment = UnityEngine.TextAnchor.UpperLeft
	-- self.activeLabel.color = UnityEngine.Color(1,1,1,1)
	-- self.outline.effectColor = UnityEngine.Color(0,0,0,1)
	local activeData = require "StaticData.Activity.Activity":GetData(activeId)
	local activeType = activeData:GetActivityType()
	local activetgrandype = activeData:GetActivetgrandype()
		debug_print("self.exchangeType",self.exchangeType,activeId,activetgrandype)

	self:ShowDesc(activeType)
	self:RemoveItem()
	self:SetActivrBase()
	self:ActivePanelHide()
	if activetgrandype == 20 then
		self.ProgressCharge.gameObject:SetActive(true)
	else
	if activetgrandype == 21 then
		self.DailyContinue.gameObject:SetActive(true)
	else
	if activetgrandype == 19 then
		self.ContinueTotal.gameObject:SetActive(true)
		self:ShowTotalPanel()
	else
	if activetgrandype == 3 then
		self.luckyCat.gameObject:SetActive(true)
	else
		self:GetActiveTime(activeId,self.data.nowTime)
		if activetgrandype == 9 then
		self.Lottery.gameObject:SetActive(true)
		self:ShowWheel()
	else
		self.desc.gameObject:SetActive(true)
	if activetgrandype == 12 then
		--限时兑换
		debug_print("self.exchangeType",self.exchangeType)
		self.ExchangeInfo:SetActive(true)
		if self.exchangeType==nil then
			debug_print("********************")
			self.exchangeType=1
			self:SetExchangeInfo(1)	
		else
			debug_print("~~~~~~~~~~~~~~~~~~~~~~~")
			self:SetExchangeInfo(self.exchangeType)
		end
	else
		self.ActiveInfo:SetActive(true)
		local activeData = require "StaticData.Activity.Active":GetData(activeType)
		local name = activeData:GetName()
		self.BigTitleName.text = name
		if activetgrandype == 15 then
			--商店
			self.IllustBase:SetActive(true)
		else
			if activetgrandype == 1 or activetgrandype == 2 then 
			-- 	--消费与充值
				self.IllustBase:SetActive(true)
			elseif activetgrandype == 5 then
			-- 	--七日登陆
				self.DaysIllustBase:SetActive(true)
				self.Active7Title:SetActive(true)
				self.Active8Title:SetActive(false)
			elseif activetgrandype == 7 then
				--等级
				self.LevelIllustBase:SetActive(true)
			elseif activetgrandype == 8 then
				--战力
				self.PowerIllustBase:SetActive(true)
			elseif activetgrandype == 17 then
				--8日
				self.DaysIllustBase:SetActive(true)
				self.Active7Title:SetActive(false)
				self.Active8Title:SetActive(true)
			end
			self:LoadAwardItem(activeId,activetgrandype)
		end
	end
	end
	end
	end
end
end
end

function ActiveCls:ActivePanelHide()
	hzj_print("ActivePanelHide")
	self.ExchangeInfo:SetActive(false)
	self.ActiveInfo:SetActive(false)
	self.Lottery.gameObject:SetActive(false)
	self.luckyCat.gameObject:SetActive(false)
	self.operationActicityLayout.gameObject:SetActive(false)
end

function ActiveCls:SetExchangeInfo(index)
	debug_print("SetExchangeInfo(index)",index)
	self:RemoveItem()
	self:HideExchangeButton()
	self.exchangeButtons[index].gameObject:SetActive(false)
	self.exchangeButtonOn[index]:SetActive(true)
	self:LoadExchangeItem(index)
	self:LoadExchangePanel(index)
end

function ActiveCls:HideExchangeButton()
	for i=1,#self.exchangeButtons do
		self.exchangeButtons[i].gameObject:SetActive(true)
		self.exchangeButtonOn[i]:SetActive(false)
	end
end

function ActiveCls:SetActivrBase()
	self.IllustBase:SetActive(false)
	self.DaysIllustBase:SetActive(false)
	self.PowerIllustBase:SetActive(false)
	self.LevelIllustBase:SetActive(false)
	self.ContinueTotal.gameObject:SetActive(false)
	self.DailyContinue.gameObject:SetActive(false)
	self.desc.gameObject:SetActive(false)
	self.ProgressCharge.gameObject:SetActive(false)
end

function ActiveCls:ShowDesc(activeType)
	local activeData = require "StaticData.Activity.Active":GetData(activeType)
	local name = activeData:GetName()
	local desc = activeData:GetDescription()
	local notice = activeData:GetDescriptionNotice()
	self.nameLabel.text = name
	self.descLabel.text = desc
	if notice ~= "null" then
		self.noticeLabel.text = notice
	else
		self.noticeLabel.text = ""
	end
end

--加载奖励列表
function ActiveCls:LoadAwardItem(activeId,type)
	if self.tableStatus ~= nil then
		local tables = self:GetTables(activeId,type)
		self.node = {}
		local count = #tables
		for i=1,count do
			AcitveAwardItemCls = require "GUI.Active.ActiveAwardList".New(self.ListPoint,tables[i],self.tableStatus,type,activeId)
			self.node[i] = AcitveAwardItemCls
			self:AddChild(self.node[i])
		end
	end
end

function ActiveCls:LoadExchangeItem(index)
	debug_print("LoadExchangeItem",index)
	local keys = require "StaticData.Activity.ExchangeIndex":GetKeys()
	local exchangeIndex = require "StaticData.Activity.ExchangeIndex"
	self.node = {}
	local tables = {}
	-- local count = keys.Length - 1
	-- for i=0,count do
	-- 	local id = require "StaticData.Activity.ExchangeIndex":GetData(keys[i]):GetIndextype()
	-- 	if index == id then
	-- 		tables[#tables + 1] = keys[i]
	-- 	end
	-- end
	local state = {}
	for i=1,#self.tableStatus do
		local type = exchangeIndex:GetData(self.tableStatus[i].id):GetIndextype()
		if type == index then
			tables[#tables + 1] = self.tableStatus[i]
		end
	end
	for i=1,#tables do
		debug_print(tables[i].id, tables[i].state, "tables[i].state *******************", i)
		AcitveAwardItemCls = require "GUI.Active.ExchangeIndexCls".New(self.exchangePoint,tables[i].id,tables[i].state,tables,type,self.buttonId)
		self.node[#self.node + 1] = AcitveAwardItemCls
		self:AddChild(AcitveAwardItemCls)
	end
end

function ActiveCls:LoadExchangePanel(index)
	local data = require "StaticData.Activity.Exchange":GetData(index)
	self.refreshDysLabel.text = data:GetRefreshDya()
	if self.exchangeInfo ~= nil then
		self.exchangeTImes.text = string.format(ActivityStringTable[2],self.exchangeInfo[index].count)
		hzj_print(self.exchangeInfo[index].countDown,"self.exchangeInfo[index].countDown")
		local times = self:GetLocakTime(self.exchangeInfo[index].countDown)
		local timesTable = utility.Split(times,":")


		self.refreshTimes.text = "下次刷新时间"..timesTable[1].."天"..timesTable[2].."时"..timesTable[3].."分"--string.format(ActivityStringTable[0],timesTable[2],timesTable[3])
	end
	-- if data ~= nil then
	-- 	self.exchangeTimeLabel.text = data.times
	-- end

end

function ActiveCls:GetTables(activeId,type)
	local activedata 
	local tables = {}
	if type == 1 or type == 2 then
		activedata = require "StaticData.Activity.ActivityConsumption"
		local keys = activedata:GetKeys()
		for i=0,(keys.Length - 1) do
			local temp = math.floor(keys[i]/100)
			if temp == activeId then
				tables[#tables + 1] = keys[i]
			end
		end
	else
		if type == 5 then
			activedata = require "StaticData.Activity.NewServerLogin"
		elseif type == 7 then
			activedata = require "StaticData.Activity.NewServerLevel"
		elseif type ==8 then
			activedata = require "StaticData.Activity.NewServerPower"
		elseif type == 17 then
			activedata = require "StaticData.Activity.NewPlayerLogin"
		end
		if activedata ~= nil then
		local keys = activedata:GetKeys()
		for i=0,(keys.Length - 1) do
			tables[#tables + 1] = keys[i]
		end
		end
	end
	return tables
end


function ActiveCls:RemoveItem()
	if self.node ~= nil then
		for i=1,#self.node do
			self:RemoveChild(self.node[i],true)
		end
	end
end

function ActiveCls:RemoveAll()
	for i=1,#self.nodeCls do
			self:RemoveChild(self.nodeCls[i],true)
		end
end

function ActiveCls:ChangePosition(object,width,height)
	-- 改变组件位置
	object.sizeDelta = Vector2(width,height)
end


return ActiveCls