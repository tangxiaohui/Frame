local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
-- local windowUtility = require "Framework.Window.WindowUtility"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"
require "LUT.StringTable"
local messageGuids = require "Framework.Business.MessageGuids"
require "Collection.OrderedDictionary"
local messageGuids = require "Framework.Business.MessageGuids"
require "GUI.Spine.SpineController"

local CardDrawCls = Class(BaseNodeClass)
-- windowUtility.SetMutex(CardDrawCls, true)

function CardDrawCls:Ctor()
	local ctrl = SpineController.New()
	self.ctrl = ctrl
end

-- >>> 按钮超时处理逻辑开始
local function SetButtonInteractable(self, active)
	self.OrdinaryButton.interactable = active
	self.OneTimesButton.interactable = active
	self.TenTimesButton.interactable = active
end

local function StopButtonLockTimer(self)
	self:StopAllCoroutines()
	SetButtonInteractable(self, true)
end

local function OnDelayButtonLockTimer(self)
	coroutine.wait(1)
	StopButtonLockTimer(self)
end

local function StartButtonLockTimer(self)
	StopButtonLockTimer(self)
	SetButtonInteractable(self, false)
	self:StartCoroutine(OnDelayButtonLockTimer)
end

-- <<< 按钮超时处理逻辑结束

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function CardDrawCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/CardDraw', function(go)
		self:BindComponent(go)
	end)
end

function CardDrawCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()	
end

function CardDrawCls:OnResume()
	-- 界面显示时调用
	CardDrawCls.base.OnResume(self)

	require "Utils.GameAnalysisUtils".RecordLocalAction(kTrackingId_DrawCardView)

	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:RegisterEventObserver()
	self:OnChoukaQueryRequest()
	self:GetXunBaolingCount()

	self:ScheduleUpdate(self.Update)

	self:InitSpineShow()
	-- self:FadeIn(function(self, t)
 --        local transform = self.tweenObjectTrans

 --        local TweenUtility = require "Utils.TweenUtility"
 --        local s = TweenUtility.EaseOutBack(0, 1, t)

 --        transform.localScale = Vector3(s, s, s)
 --    end)
	
	--- 新手引导
	local guideMgr = utility.GetGame():GetGuideManager()
	guideMgr:AddGuideEvnt(kGuideEvnt_NormalDrawTips)
	guideMgr:AddGuideEvnt(kGuideEvnt_NormalDraw)
--	guideMgr:AddGuideEvnt(kGuideEvnt_DiamondDrawTips)
	guideMgr:AddGuideEvnt(kGuideEvnt_DiamondDraw)
	--if self.cardTypePattern == DiamondOnePattern then
	--guideMgr:AddGuideEvnt(kGuideEvnt_Draw2MainPanel)
	guideMgr:SortGuideEvnt()
	guideMgr:ShowGuidance()
end

function CardDrawCls:OnPause()
	-- 界面隐藏时调用
	CardDrawCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
	self:UnRegisterEventObserver()
	self:CloseSpine()
end

function CardDrawCls:OnEnter()
	-- Node Enter时调用
	CardDrawCls.base.OnEnter(self)
end

function CardDrawCls:OnExit()
	-- Node Exit时调用
	CardDrawCls.base.OnExit(self)
end

function CardDrawCls:IsTransition()
    return false
end

-- function CardDrawCls:OnExitTransitionDidStart(immediately)
-- 	CardDrawCls.base.OnExitTransitionDidStart(self, immediately)

--     -- if not immediately then
--     --     self:FadeOut(function(self, t)
--     --         local transform = self.tweenObjectTrans

--     --         local TweenUtility = require "Utils.TweenUtility"

--     --         local s = TweenUtility.EaseInBack(1, 0, t)
--     --         transform.localScale = Vector3(s, s, s)
--     --     end)
--     -- end
-- end

function CardDrawCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end

function CardDrawCls:InitSpineShow()
	self.ctrl:SetData(self.skeletonGraphic,self.speakerLabel,6)
end

function CardDrawCls:CloseSpine()
	self.ctrl:Stop()
end

function CardDrawCls:Update()
	self:UpdateHintTime()
end

function CardDrawCls:RegisterEventObserver()
	-- 添加事件的监听
	self:RegisterEvent(messageGuids.AddedOneCard,self.AddedOneCard)
	self:RegisterEvent('ShowCardDraw',self.ShowSelifGameObject)
end

function CardDrawCls:UnRegisterEventObserver()
	-- 取消添加事件的监听
	self:UnregisterEvent(messageGuids.AddedOneCard,self.AddedOneCard)
	self:UnregisterEvent('ShowCardDraw',self.ShowSelifGameObject)
end

function CardDrawCls:AddedOneCard(data)
	local UpdatedCardID = data:GetId()
	if not self.AddCardDict:Contains(UpdatedCardID) then
		self.AddCardDict:Add(UpdatedCardID,UpdatedCardID)
	end
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function CardDrawCls:InitControls()
	local transform = self:GetUnityTransform()
	self.gameObject = transform.gameObject
	self.TranslucentLayer = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Frame = transform:Find('TweenObject/Base/Frame'):GetComponent(typeof(UnityEngine.UI.Image))
	self.FightTitle = transform:Find('TweenObject/Base/FightTitle'):GetComponent(typeof(UnityEngine.UI.Image))
	self.CardDrawRetrunButton = transform:Find('TweenObject/CardDrawRetrunButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.OrdinaryImage = transform:Find('TweenObject/Ordinary/OrdinaryImage'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BlackBarsOrdinary = transform:Find('TweenObject/Ordinary/BlackBarsOrdinary'):GetComponent(typeof(UnityEngine.UI.Image))
	self.OrdinaryButton = transform:Find('TweenObject/Ordinary/OrdinaryButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.OrdinaryOneImage = transform:Find('TweenObject/Ordinary/OrdinaryButton/OneTimesImage'):GetComponent(typeof(UnityEngine.UI.Text))
	self.OrdinaryFreeImage = transform:Find('TweenObject/Ordinary/OrdinaryButton/FreeTimesImage'):GetComponent(typeof(UnityEngine.UI.Text))
	self.StarImageOrdinary = transform:Find('TweenObject/Ordinary/StarImageOrdinary'):GetComponent(typeof(UnityEngine.UI.Image))
	self.OrdinaryTitleLabel = transform:Find('TweenObject/Ordinary/OrdinaryTitleLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.OrdinaryTimeLabel = transform:Find('TweenObject/Ordinary/OrdinaryTimeLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.OrdinaryHaveLabel = transform:Find('TweenObject/Ordinary/OrdinaryHaveLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.OrdinaryConsumablesLabel = transform:Find('TweenObject/Ordinary/OrdinaryConsumablesLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.OneTimesImage = transform:Find('TweenObject/OneTimes/OneTimesImage'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BlackBarsOneTimes = transform:Find('TweenObject/OneTimes/BlackBarsOneTimes'):GetComponent(typeof(UnityEngine.UI.Image))
	self.OneTimesButton = transform:Find('TweenObject/OneTimes/OneTimesButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.OneDiamondOneImage = transform:Find('TweenObject/OneTimes/OneTimesButton/OneTimesImage'):GetComponent(typeof(UnityEngine.UI.Text))
	self.OneDiamondFreeImage = transform:Find('TweenObject/OneTimes/OneTimesButton/FreeTimesImage'):GetComponent(typeof(UnityEngine.UI.Text))
	--self.StarImageOneTimes = transform:Find('TweenObject/OneTimes/StarImageOneTimes'):GetComponent(typeof(UnityEngine.UI.Image))
	--self.OneTimesTitleLabel = transform:Find('TweenObject/OneTimes/OneTimesTitleLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.OneTimesTimeLabel = transform:Find('TweenObject/OneTimes/OneTimesTimeLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.OneTimesAwardLabel = transform:Find('TweenObject/OneTimes/OneTimesAwardLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.OneTimesFreeLabel = transform:Find('TweenObject/OneTimes/OneTimesFreeLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.OneTimesConsumables = transform:Find('TweenObject/OneTimes/OneTimesConsumables')
	self.OneTimesConsumablesLabel = transform:Find('TweenObject/OneTimes/OneTimesConsumables/OneTimesConsumablesLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.OneDiamondImage = transform:Find('TweenObject/OneTimes/OneTimesConsumables/OneDiamondImage'):GetComponent(typeof(UnityEngine.UI.Image))
	self.TenTimesImage = transform:Find('TweenObject/TenTimes/TenTimesImage'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BlackBarsTenTimes = transform:Find('TweenObject/TenTimes/BlackBarsTenTimes'):GetComponent(typeof(UnityEngine.UI.Image))
	self.TenTimesButton = transform:Find('TweenObject/TenTimes/TenTimesButton'):GetComponent(typeof(UnityEngine.UI.Button))
	--self.StarImageTenTimes = transform:Find('TweenObject/TenTimes/StarImageTenTimes'):GetComponent(typeof(UnityEngine.UI.Image))
	self.TenTimesTitleLabel = transform:Find('TweenObject/TenTimes/TenTimesTitleLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.TenTimesAwardLabel = transform:Find('TweenObject/TenTimes/TenTimesAwardLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.TenTimesConsumablesLabel = transform:Find('TweenObject/TenTimes/TenTimesConsumables/TenTimesConsumablesLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.TenDiamondImage = transform:Find('TweenObject/TenTimes/TenTimesConsumables/TenDiamondImage'):GetComponent(typeof(UnityEngine.UI.Image))
	self.CardDrawDescription1 = transform:Find('TweenObject/Ordinary/InfoButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.CardDrawDescription2 = transform:Find('TweenObject/OneTimes/InfoButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.CardDrawDescription3 = transform:Find('TweenObject/TenTimes/InfoButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ShopButton = transform:Find('TweenObject/ShopButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.TheMainDiamondLabel=transform:Find('TweenObject/Diamond/TheMainDiamondLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	-- 红点
	self.ordubaryRed = self.OrdinaryButton.transform:Find('RedDot').gameObject
	self.onetimeRed = self.OneTimesButton.transform:Find('RedDot').gameObject

	self.tweenObjectTrans = transform:Find('TweenObject')

	self.myGame = utility:GetGame()

	self.customFreeHintStr = CardDrawStringTable[0]
	self.customConsumeDaojuStr = CardDrawStringTable[1]
	self.customXunbaolingHintStr = CardDrawStringTable[2]
	self.customOneDiamondHintStr = CardDrawStringTable[3]
	self.customXunbaolingID = 10300003
	self.cardDrawType = {DaoJu = "DaoJu", DiamondOne = "DiamondOne", DiamondTen = "DiamondTen",AllDaoju = "AllDaoju"}

	self.awardItemList = {}
	self.AddCardDict = OrderedDictionary.New()

	-- 主场景相机
	self.mainCamera = self:GetUIManager():GetMainUICanvas():GetCamera()
	--- 主场景灯光
	-- self.mainSceneLight = UnityEngine.GameObject.Find('Zhuchangjing/Directional light')
	self.speakerLabel = transform:Find("TweenObject/Frame/Text"):GetComponent(typeof(UnityEngine.UI.Text))
	self.skeletonGraphic = transform:Find('TweenObject/Base/feiying/SkeletonGraphic (feiying)'):GetComponent(typeof(Spine.Unity.SkeletonGraphic))
	self:UpdatePlayerData()


end


function CardDrawCls:RegisterControlEvents()
	-- 注册 CardDrawRetrunButton 的事件
	self.__event_button_onCardDrawRetrunButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCardDrawRetrunButtonClicked, self)
	self.CardDrawRetrunButton.onClick:AddListener(self.__event_button_onCardDrawRetrunButtonClicked__)

	-- 注册 OrdinaryButton 的事件
	self.__event_button_onOrdinaryButtonClicked__ = UnityEngine.Events.UnityAction(self.OnOrdinaryButtonClicked, self)
	self.OrdinaryButton.onClick:AddListener(self.__event_button_onOrdinaryButtonClicked__)

	-- 注册 OneTimesButton 的事件
	self.__event_button_onOneTimesButtonClicked__ = UnityEngine.Events.UnityAction(self.OnOneTimesButtonClicked, self)
	self.OneTimesButton.onClick:AddListener(self.__event_button_onOneTimesButtonClicked__)

	-- 注册 TenTimesButton 的事件
	self.__event_button_onTenTimesButtonClicked__ = UnityEngine.Events.UnityAction(self.OnTenTimesButtonClicked, self)
	self.TenTimesButton.onClick:AddListener(self.__event_button_onTenTimesButtonClicked__)


		-- 注册 CardDrawDescription1 的事件
	self.__event_button_onCardDrawDescription1Clicked__ = UnityEngine.Events.UnityAction(self.OnCardDrawDescription1Clicked, self)
	self.CardDrawDescription1.onClick:AddListener(self.__event_button_onCardDrawDescription1Clicked__)

			-- 注册 CardDrawDescription2 的事件
	self.__event_button_onCardDrawDescription2Clicked__ = UnityEngine.Events.UnityAction(self.OnCardDrawDescription2Clicked, self)
	self.CardDrawDescription2.onClick:AddListener(self.__event_button_onCardDrawDescription2Clicked__)

			-- 注册 CardDrawDescription3 的事件
	self.__event_button_onCardDrawDescription3Clicked__ = UnityEngine.Events.UnityAction(self.OnCardDrawDescription3Clicked, self)
	self.CardDrawDescription3.onClick:AddListener(self.__event_button_onCardDrawDescription3Clicked__)
	
	self.__event_button_onShopButtonClicked__ = UnityEngine.Events.UnityAction(self.OnShopButtonClicked, self)
	self.ShopButton.onClick:AddListener(self.__event_button_onShopButtonClicked__)
end

function CardDrawCls:UnregisterControlEvents()
	if self.__event_button_onShopButtonClicked__ then
		self.ShopButton.onClick:RemoveListener(self.__event_button_onShopButtonClicked__)
		self.__event_button_onShopButtonClicked__ = nil
	end
	-- 取消注册 CardDrawDescription3 的事件

	if self.__event_button_onCardDrawDescription1Clicked__ then
		self.CardDrawDescription1.onClick:RemoveListener(self.__event_button_onCardDrawDescription1Clicked__)
		self.__event_button_onCardDrawDescription1Clicked__ = nil
	end
		-- 取消注册 CardDrawDescription2 的事件
	if self.__event_button_onCardDrawDescription2Clicked__ then
		self.CardDrawDescription2.onClick:RemoveListener(self.__event_button_onCardDrawDescription2Clicked__)
		self.__event_button_onCardDrawDescription2Clicked__ = nil
	end
	-- 取消注册 CardDrawDescription3 的事件
	if self.__event_button_onCardDrawDescription3Clicked__ then
		self.CardDrawDescription3.onClick:RemoveListener(self.__event_button_onCardDrawDescription3Clicked__)
		self.__event_button_onCardDrawDescription3Clicked__ = nil
	end




	-- 取消注册 CardDrawRetrunButton 的事件
	if self.__event_button_onCardDrawRetrunButtonClicked__ then
		self.CardDrawRetrunButton.onClick:RemoveListener(self.__event_button_onCardDrawRetrunButtonClicked__)
		self.__event_button_onCardDrawRetrunButtonClicked__ = nil
	end

	-- 取消注册 OrdinaryButton 的事件
	if self.__event_button_onOrdinaryButtonClicked__ then
		self.OrdinaryButton.onClick:RemoveListener(self.__event_button_onOrdinaryButtonClicked__)
		self.__event_button_onOrdinaryButtonClicked__ = nil
	end

	-- 取消注册 OneTimesButton 的事件
	if self.__event_button_onOneTimesButtonClicked__ then
		self.OneTimesButton.onClick:RemoveListener(self.__event_button_onOneTimesButtonClicked__)
		self.__event_button_onOneTimesButtonClicked__ = nil
	end

	-- 取消注册 TenTimesButton 的事件
	if self.__event_button_onTenTimesButtonClicked__ then
		self.TenTimesButton.onClick:RemoveListener(self.__event_button_onTenTimesButtonClicked__)
		self.__event_button_onTenTimesButtonClicked__ = nil
	end

end

function CardDrawCls:RegisterNetworkEvents()
	 self.myGame:RegisterMsgHandler(net.S2CChoukaQueryResult, self, self.OnCardDrawQueryResponse)
	 self.myGame:RegisterMsgHandler(net.S2CChoukaDaojuChooseResult, self, self.OnChoukaDaojuChooseResponse)
	 self.myGame:RegisterMsgHandler(net.S2CChoukaDiamondChooseResult, self, self.OnChoukaDiamondChooseResultResponse)
	 self.myGame:RegisterMsgHandler(net.S2CChoukaDiamondChooseTenResult, self, self.OnChoukaDiamondChooseTenResultResponse)
	 self.myGame:RegisterMsgHandler(net.S2CUseAllTreasureResult, self, self.OnUseAllTreasureResultResponse)
	 self.myGame:RegisterMsgHandler(net.S2CLoadPlayerResult,self,self.UpdatePlayerData)

end

function CardDrawCls:UnregisterNetworkEvents()
	self.myGame:UnRegisterMsgHandler(net.S2CChoukaQueryResult, self, self.OnCardDrawQueryResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CChoukaDaojuChooseResult, self, self.OnChoukaDaojuChooseResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CChoukaDiamondChooseResult, self, self.OnChoukaDiamondChooseResultResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CChoukaDiamondChooseTenResult, self, self.OnChoukaDiamondChooseTenResultResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CUseAllTreasureResult, self, self.OnUseAllTreasureResultResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CLoadPlayerResult,self,self.UpdatePlayerData)

end
function CardDrawCls:UpdatePlayerData()
	
	local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)

	--self.TheMainDiamondLabel.text = userData:GetDiamond()
	self.TheMainDiamondLabel.text = utility.ConvertCurrencyUnit(tostring(utility.ToInteger(userData:GetDiamond())))


end
-----------------------------------------------------------------------
--- 网络处理
-----------------------------------------------------------------------
function CardDrawCls:OnChoukaQueryRequest()
	self.myGame:SendNetworkMessage( require"Network/ServerService".ChoukaQueryRequest())
end

function CardDrawCls:ChoukaDaojuChooseRequest()
	self.myGame:SendNetworkMessage( require"Network/ServerService".ChoukaDaojuChooseRequest())
end

function CardDrawCls:ItemBagQueryRequest()
	self.myGame:SendNetworkMessage( require"Network/ServerService".ItemBagQueryRequest())
end

function CardDrawCls:ChoukaDiamondChooseRequest()
	self.myGame:SendNetworkMessage( require"Network/ServerService".ChoukaDiamondChooseRequest())
end

function CardDrawCls:ChoukaDiamondChooseTenRequest()
	self.myGame:SendNetworkMessage( require"Network/ServerService".ChoukaDiamondChooseTenRequest())
end



function CardDrawCls:OnCardDrawQueryResponse(msg)
	self.daojuCDTime = msg.daojuCDTime / 1000
	self.diamondCDTime = msg.diamondCDTime / 1000
	self.remainCount = msg.remainCount
	self:ItemBagQueryRequest()
	self:UpdateHintView()
end

-- 免费抽Response
function CardDrawCls:OnChoukaDaojuChooseResponse(msg)
	-- debug_print("哈哈[2]")
	self.myGame:SendNetworkMessage( require"Network/ServerService".ItemBagQueryRequest())
	self.daojuCDTime = msg.daojuCDTime / 1000
	self:UpdateHintView()
	self.cardType = self.cardDrawType.DaoJu
	self:ItemBagQueryRequest()
	self:AddAwardItem(msg,1,self.cardDrawType.DaoJu)
	StopButtonLockTimer(self)
end

function CardDrawCls:GetXunBaolingCount()
	local UserDataType = require "Framework.UserDataType"
	local data = self:GetCachedData(UserDataType.ItemBagData)
	self.itemXunbaolingCount = data:GetItemCountById(self.customXunbaolingID)
	self:UpdateXunbaolingCount()
end

-- 一次抽Response
function CardDrawCls:OnChoukaDiamondChooseResultResponse(msg)
	-- debug_print("哈哈[1]")
	self.diamondCDTime = msg.diamondCDTime / 1000
	self.remainCount = msg.remainCount
	self.cardType = self.cardDrawType.DiamondOne
	self:UpdateHintView()
	self:AddAwardItem(msg,1,self.cardDrawType.DiamondOne)
	StopButtonLockTimer(self)
end

-- 十连抽Response
function CardDrawCls:OnChoukaDiamondChooseTenResultResponse(msg)
	-- debug_print("哈哈[3]")
	debug_print(msg,"OnChoukaDiamondChooseTenResultResponse",self.cardDrawType.DiamondTen)
	self.cardType = self.cardDrawType.DiamondTen
	self:AddAwardItem(msg,10,self.cardDrawType.DiamondTen)
	StopButtonLockTimer(self)
end

function CardDrawCls:OnUseAllTreasureResultResponse(msg)
	self.cardType = self.cardDrawType.AllDaoju
	self:ItemBagQueryRequest()
	self:AddAwardItem(msg,#msg.items,self.cardDrawType.AllDaoju)
end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function CardDrawCls:OnCardDrawRetrunButtonClicked()
	--CardDrawRetrunButton控件的点击事件处理
	debug_print("+++++++++++++++++++++++++++++++++")
	-- local sceneManager = self.myGame:GetSceneManager()
 --    sceneManager:PopScene()
	self:Close()
end

-- 免费抽
function CardDrawCls:OnOrdinaryButtonClicked()
	require "Utils.GameAnalysisUtils".RecordLocalAction(kTrackingId_DrawCardItemAction)

	debug_print("免费抽!!")

	--OrdinaryButton控件的点击事件处理
	local guideMgr = utility.GetGame():GetGuideManager()

--	guideMgr:RemoveGuideEvnt(kGuideEvnt_DiamondDrawTips)
	guideMgr:RemoveGuideEvnt(kGuideEvnt_DiamondDraw)
	--if self.cardTypePattern == DiamondOnePattern then
	guideMgr:RemoveGuideEvnt(kGuideEvnt_Draw2MainPanel)
	guideMgr:SortGuideEvnt()
--	guideMgr:ShowGuidance()

	StartButtonLockTimer(self)
	self:ChoukaDaojuChooseRequest()
end

-- 抽一次
function CardDrawCls:OnOneTimesButtonClicked()
	debug_print("一次抽")

	require "Utils.GameAnalysisUtils".RecordLocalAction(kTrackingId_DrawCardDiamondAction)
	--OneTimesButton控件的点击事件处理
	--self.cardType = self.cardDrawType.DiamondOne
	StartButtonLockTimer(self)
	self:ChoukaDiamondChooseRequest()
end

-- 十连抽
function CardDrawCls:OnTenTimesButtonClicked()
	debug_print("十连抽")

	require "Utils.GameAnalysisUtils".RecordLocalAction(kTrackingId_DrawCardDiamondTenTimesAction)
	--TenTimesButton控件的点击事件处理
	--self.cardType = self.cardDrawType.DiamondTen
	StartButtonLockTimer(self)
	self:ChoukaDiamondChooseTenRequest()
end

---------------------------------------------------------------------------
function CardDrawCls:UpdateHintView()
	if self.daojuCDTime == 0 then
		self.OrdinaryConsumablesLabel.text = self.customFreeHintStr
		self.OrdinaryTimeLabel.gameObject:SetActive(false)
		self.OrdinaryOneImage.gameObject:SetActive(false)
		self.OrdinaryFreeImage.gameObject:SetActive(true)
		self.ordubaryRed:SetActive(true)
	else
		self.OrdinaryConsumablesLabel.text = self.customConsumeDaojuStr
		self.OrdinaryTimeLabel.gameObject:SetActive(true)
		self.OrdinaryOneImage.gameObject:SetActive(true)
		self.OrdinaryFreeImage.gameObject:SetActive(false)
	end

	if self.diamondCDTime == 0 then
		self.OneTimesConsumables.gameObject:SetActive(false)
		self.OneTimesFreeLabel.gameObject:SetActive(true)
		self.OneTimesTimeLabel.gameObject:SetActive(false)
		self.OneDiamondOneImage.gameObject:SetActive(false)
		self.OneDiamondFreeImage.gameObject:SetActive(true)
		self.onetimeRed:SetActive(true)
	else
		self.OneTimesFreeLabel.gameObject:SetActive(false)
		self.OneTimesConsumables.gameObject:SetActive(true)
		self.OneTimesTimeLabel.gameObject:SetActive(true)
		self.OneDiamondOneImage.gameObject:SetActive(true)
		self.OneDiamondFreeImage.gameObject:SetActive(false)
		self.onetimeRed:SetActive(false)
	end

	self:UpdateXunbaolingCount(checkRed)
	self:UpdateHeroRemainCount()
end

function CardDrawCls:UpdateXunbaolingCount()
	if self.daojuCDTime ~= 0 then
		local redActive = self.itemXunbaolingCount > 0
		self.ordubaryRed:SetActive(redActive)
	end
	self.OrdinaryHaveLabel.text =  self.customXunbaolingHintStr..tostring(self.itemXunbaolingCount)
end

function CardDrawCls:UpdateHeroRemainCount()
	self.OneTimesAwardLabel.text = tostring(self.remainCount)..self.customOneDiamondHintStr
end

function CardDrawCls:UpdateHintTime()
	if self.OrdinaryTimeLabel.gameObject.activeInHierarchy then
		if self.daojuCDTime == nil then
			return true
		end
		self.daojuCDTime = self.daojuCDTime - UnityEngine.Time.deltaTime
		if self.daojuCDTime < 0 then
			self.daojuCDTime = 0
			self:UpdateHintView()
		end
	self.OrdinaryTimeLabel.text = utility.ConvertTime(self.daojuCDTime)
	end

	if self.OneTimesTimeLabel.gameObject.activeInHierarchy then
		if self.diamondCDTime == nil then
			return true
		end
		self.diamondCDTime = self.diamondCDTime - UnityEngine.Time.deltaTime
		if self.diamondCDTime < 0 then
			self.diamondCDTime = 0
			self:UpdateHintView()
		end
	self.OneTimesTimeLabel.text = utility.ConvertTime(self.diamondCDTime)
	end

end

local function Coroutinue(self)
	coroutine.step(1)
end 

function CardDrawCls:ShowSelifGameObject()
	self.gameObject:SetActive(true)	
	self.mainCamera.fieldOfView = 60
	self:GetXunBaolingCount()
end

function CardDrawCls:OnCardDrawDescription1Clicked( ... )

	-- local windowManager = self.myGame:GetWindowManager()
 --   	windowManager:Show(require "GUI.Shop.Shop",KShopType_LotteryShop)
		
	local DrawPoolData = require "StaticData.DrawPool.DrawPool":GetData(1)
	local str = DrawPoolData:GetDescription()
	local windowManager = self:GetWindowManager()
	
    windowManager:Show(require "GUI.CommonDescriptionModule",str)


end



function CardDrawCls:OnShopButtonClicked( ... )
	local windowManager = self.myGame:GetWindowManager()
   	windowManager:Show(require "GUI.Shop.Shop",KShopType_IntegralShop)

end
function CardDrawCls:OnCardDrawDescription2Clicked( ... )
	local DrawPoolData = require "StaticData.DrawPool.DrawPool":GetData(2)
	local str = DrawPoolData:GetDescription()
	local windowManager = self:GetWindowManager()
	
    windowManager:Show(require "GUI.CommonDescriptionModule",str)
	-- body
end


function CardDrawCls:OnCardDrawDescription3Clicked( ... )
	local DrawPoolData = require "StaticData.DrawPool.DrawPool":GetData(3)
	local str = DrawPoolData:GetDescription()
	local windowManager = self:GetWindowManager()
	
    windowManager:Show(require "GUI.CommonDescriptionModule",str)
	-- body
end


function CardDrawCls:AddAwardItem(msg,count,type)
    self.mainCamera.fieldOfView = 50

    local eventMgr = self.myGame:GetEventManager()
    eventMgr:PostNotification('ClosePlayNotice')

    local messageGuids = require "Framework.Business.MessageGuids"
	self:DispatchEvent(messageGuids.ExitLobbyScene)

	local sceneManager = self:GetGame():GetSceneManager()
	if self.CardDrawResultCls == nil then
		self.CardDrawResultCls = require "GUI.CardDrawResult".New()		
	end

	if self.gameObject.activeSelf then
		sceneManager:PushScene(self.CardDrawResultCls)
		self.gameObject:SetActive(false)
	end
    self.CardDrawResultCls:OnShowItem(msg,count,type,self.itemXunbaolingCount,self.remainCount,self.AddCardDict)
end


return CardDrawCls