local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local ZodiacDrawCls = Class(BaseNodeClass)

function ZodiacDrawCls:Ctor()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function ZodiacDrawCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/ZodiacDraw', function(go)
		self:BindComponent(go)
	end)
end

function ZodiacDrawCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function ZodiacDrawCls:OnResume()
	-- 界面显示时调用
	ZodiacDrawCls.base.OnResume(self)
	self:ScheduleUpdate(self.Update)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:GetGame():SendNetworkMessage(require"Network/ServerService".StarQueryRequest())
end

function ZodiacDrawCls:OnPause()
	-- 界面隐藏时调用
	ZodiacDrawCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function ZodiacDrawCls:OnEnter()
	-- Node Enter时调用
	ZodiacDrawCls.base.OnEnter(self)
end

function ZodiacDrawCls:OnExit()
	-- Node Exit时调用
	ZodiacDrawCls.base.OnExit(self)
end

function ZodiacDrawCls:OnWillShow()
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function ZodiacDrawCls:InitControls()
	local transform = self:GetUnityTransform()
	self.TranslucentLayer = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Base = transform:Find('Base/Base/Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Image = transform:Find('Base/Base/Image'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Frame = transform:Find('Base/Base/Frame'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Deco1 = transform:Find('Base/Base/Deco1'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Title = transform:Find('Base/Base/Title'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Deco2 = transform:Find('Base/Deco2'):GetComponent(typeof(UnityEngine.UI.Image))
	self.CoinDrawButton = transform:Find('Base/CoinDraw/CoinDrawButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.CoinDrawFree = transform:Find('Base/CoinDraw/CoinDrawButton/Free')
	self.CoinDrawDraw = transform:Find('Base/CoinDraw/CoinDrawButton/Draw')
	self.Icon = transform:Find('Base/CoinDraw/Price/Icon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Base1 = transform:Find('Base/CoinDraw/Price/Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.NumLabel = transform:Find('Base/CoinDraw/Price/Base/NumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.LastBase = transform:Find('Base/CoinDraw/LastTime')
	self.LastFreeTime = transform:Find('Base/CoinDraw/LastTime/LastFreeTime'):GetComponent(typeof(UnityEngine.UI.Text))
	self.LastTimeNum = transform:Find('Base/CoinDraw/LastTime/LastTimeNum'):GetComponent(typeof(UnityEngine.UI.Text))
	self.LastPayTimeNum = transform:Find('Base/CoinDraw/LastPayTime/LastTimeNum'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ColdTimeBase = transform:Find('Base/CoinDraw/ColdTime')
	self.ColdTime = transform:Find('Base/CoinDraw/ColdTime/ColdTime'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ColdTimeNum = transform:Find('Base/CoinDraw/ColdTime/ColdTimeNum'):GetComponent(typeof(UnityEngine.UI.Text))
	self.CoinDrawButton1 = transform:Find('Base/Draw/CoinDrawButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.CoinDrawFree1 = transform:Find('Base/Draw/CoinDrawButton/Free')
	self.CoinDrawDraw1 = transform:Find('Base/Draw/CoinDrawButton/Draw')
	self.Icon1 = transform:Find('Base/Draw/Price/Icon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Base2 = transform:Find('Base/Draw/Price/Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.NumLabel1 = transform:Find('Base/Draw/Price/Base/NumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.LastBase1 = transform:Find('Base/Draw/LastTime')
	self.LastFreeTime1 = transform:Find('Base/Draw/LastTime/LastFreeTime'):GetComponent(typeof(UnityEngine.UI.Text))
	self.LastTimeNum1 = transform:Find('Base/Draw/LastTime/LastTimeNum'):GetComponent(typeof(UnityEngine.UI.Text))
	self.LastPayTimeNum1 = transform:Find('Base/Draw/LastPayTime/LastTimeNum'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ColdTimeBase1 = transform:Find('Base/Draw/ColdTime')
	self.ColdTime1 = transform:Find('Base/Draw/ColdTime/ColdTime'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ColdTimeNum1 = transform:Find('Base/Draw/ColdTime/ColdTimeNum'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ReturnButton = transform:Find('Base/ReturnButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.BoomEffect = transform:Find('Base/Effect/liehun_baozha_effect')
	self.BoomEffect.gameObject:SetActive(false)
end


function ZodiacDrawCls:RegisterControlEvents()
	-- 注册 CoinDrawButton 的事件
	self.__event_button_onCoinDrawButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCoinDrawButtonClicked, self)
	self.CoinDrawButton.onClick:AddListener(self.__event_button_onCoinDrawButtonClicked__)

	-- 注册 CoinDrawButton1 的事件
	self.__event_button_onCoinDrawButton1Clicked__ = UnityEngine.Events.UnityAction(self.OnCoinDrawButton1Clicked, self)
	self.CoinDrawButton1.onClick:AddListener(self.__event_button_onCoinDrawButton1Clicked__)

	-- 注册 ReturnButton 的事件
	self.__event_button_onReturnButtonClicked__ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked, self)
	self.ReturnButton.onClick:AddListener(self.__event_button_onReturnButtonClicked__)
end

function ZodiacDrawCls:UnregisterControlEvents()
	-- 取消注册 CoinDrawButton 的事件
	if self.__event_button_onCoinDrawButtonClicked__ then
		self.CoinDrawButton.onClick:RemoveListener(self.__event_button_onCoinDrawButtonClicked__)
		self.__event_button_onCoinDrawButtonClicked__ = nil
	end

	-- 取消注册 CoinDrawButton1 的事件
	if self.__event_button_onCoinDrawButton1Clicked__ then
		self.CoinDrawButton1.onClick:RemoveListener(self.__event_button_onCoinDrawButton1Clicked__)
		self.__event_button_onCoinDrawButton1Clicked__ = nil
	end

	-- 取消注册 ReturnButton 的事件
	if self.__event_button_onReturnButtonClicked__ then
		self.ReturnButton.onClick:RemoveListener(self.__event_button_onReturnButtonClicked__)
		self.__event_button_onReturnButtonClicked__ = nil
	end
end

function ZodiacDrawCls:RegisterNetworkEvents()
	local myGame = utility.GetGame()
	myGame:RegisterMsgHandler(net.S2CStarQueryResult, self, self.OnQueryResult)
	myGame:RegisterMsgHandler(net.S2CStarCoinWishResult, self, self.OnCoinDrawResult)
	myGame:RegisterMsgHandler(net.S2CStarDiamondWishResult, self, self.OnDiamondDrawResult)
end

function ZodiacDrawCls:UnregisterNetworkEvents()
	local myGame = utility.GetGame()
	myGame:UnRegisterMsgHandler(net.S2CStarQueryResult, self, self.OnQueryResult)
	myGame:UnRegisterMsgHandler(net.S2CStarCoinWishResult, self, self.OnCoinDrawResult)
	myGame:UnRegisterMsgHandler(net.S2CStarDiamondWishResult, self, self.OnDiamondDrawResult)
end
local function DelayEnabledButton(self,button)
	coroutine.wait(1)
	self.CoinDrawButton.enabled=true
	self.CoinDrawButton1.enabled=true
end 
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function ZodiacDrawCls:OnCoinDrawButtonClicked()
	self.CoinDrawButton.enabled=false
	self:StartCoroutine(DelayEnabledButton,self.CoinDrawButton)

	--CoinDrawButton控件的点击事件处理
	self:GetGame():SendNetworkMessage(require"Network/ServerService".StarCoinWishRequest())
end

function ZodiacDrawCls:OnCoinDrawButton1Clicked()
	self.CoinDrawButton1.enabled=false
	self:StartCoroutine(DelayEnabledButton,self.CoinDrawButton1)
	--CoinDrawButton1控件的点击事件处理
	self:GetGame():SendNetworkMessage(require"Network/ServerService".StarDiamondWishRequest())
end

function ZodiacDrawCls:OnReturnButtonClicked()
	--ReturnButton控件的点击事件处理
	debug_print("*****************", "OnReturnButtonClicked")
	self:Close()
end

local function PlayEffect(self, msg)
	self.BoomEffect.gameObject:SetActive(false)
	self.BoomEffect.gameObject:SetActive(true)
	coroutine.wait(1)
	local windowManager = self:GetGame():GetWindowManager()
    windowManager:Show(require "GUI.Zodiac.ZodiacDrawResult", msg.item)
end


function ZodiacDrawCls:OnCoinDrawResult(msg)
	
	--self:StartCoroutine(DelayEnabledButton,self.CoinDrawButton)
	-- coroutine.start(PlayEffect, self, msg)
	self:StartCoroutine(PlayEffect, msg)
end

function ZodiacDrawCls:OnDiamondDrawResult(msg)
	--self:StartCoroutine(DelayEnabledButton,self.CoinDrawButton1)
	
	-- coroutine.start(PlayEffect, self, msg)
	self:StartCoroutine(PlayEffect, msg)
end

function ZodiacDrawCls:OnQueryResult(msg)
	self.coinFreeDrawTime = msg.coinSurFreeCount
	if self.coinFreeDrawTime > 0 then
		self.LastTimeNum.text = self.coinFreeDrawTime
		self.LastBase.gameObject:SetActive(true)
	else
		self.LastBase.gameObject:SetActive(false)
	end
	
	self.diamondFreeDrawTime = msg.diamSurFreeCount
	if self.diamondFreeDrawTime > 0 then
		self.LastTimeNum1.text = self.diamondFreeDrawTime
		self.LastBase1.gameObject:SetActive(true)
	else
		self.LastBase1.gameObject:SetActive(false)
	end
	
	self.coinDrawTime = msg.todayCoinSurCount
	self.LastPayTimeNum.text = self.coinDrawTime
	self.diamondDrawTime = msg.todayDiamondSurCount
	self.LastPayTimeNum1.text = self.diamondDrawTime

	self.coinCooldownTimer = msg.coinFreeCDTime / 1000
	self.CoinDrawFree.gameObject:SetActive(false)
	self.CoinDrawDraw.gameObject:SetActive(true)
	if self.coinCooldownTimer > 0 then
		self.coinCooldownTimestamp = os.time()
		self.coinCooldownEnabled = true
		self.ColdTimeNum.text = utility.ConvertTime(self.coinCooldownTimer)
		self.ColdTimeBase.gameObject:SetActive(true)
	else
		self.ColdTimeBase.gameObject:SetActive(false)
		if self.coinFreeDrawTime > 0 then
			self.CoinDrawFree.gameObject:SetActive(true)
			self.CoinDrawDraw.gameObject:SetActive(false)
		end
	end
	
	self.diamondCooldownTimer = msg.diamFreeCDTime / 1000
	self.CoinDrawFree1.gameObject:SetActive(false)
	self.CoinDrawDraw1.gameObject:SetActive(true)
	if self.diamondCooldownTimer > 0 then
		self.diamondCooldownTimestamp = os.time()
		self.diamondCooldownEnabled = true
		self.ColdTimeNum1.text = utility.ConvertTime(self.diamondCooldownTimer)
		self.ColdTimeBase1.gameObject:SetActive(true)
	else
		self.ColdTimeBase1.gameObject:SetActive(false)
		if self.diamondFreeDrawTime > 0 then
			self.CoinDrawFree1.gameObject:SetActive(true)
			self.CoinDrawDraw1.gameObject:SetActive(false)
		end
	end
	
	local zodiacDrawMgr = require "StaticData.Zodiac.ZodiacDraw"
	self.NumLabel.text = zodiacDrawMgr:GetData(1):GetNeedNum()
	self.NumLabel1.text = zodiacDrawMgr:GetData(2):GetNeedNum()
end

function ZodiacDrawCls:Update()
	if self.coinCooldownEnabled then
		if os.time() - self.coinCooldownTimestamp >= 1 then
			self.coinCooldownTimestamp = os.time()
			self.coinCooldownTimer = self.coinCooldownTimer - 1
		end
		
		if self.coinCooldownTimer <= 0 then
			self.ColdTimeBase.gameObject:SetActive(false)
			if self.coinFreeDrawTime > 0 then
				self.CoinDrawFree.gameObject:SetActive(true)
				self.CoinDrawDraw.gameObject:SetActive(false)
			else
				self.CoinDrawFree.gameObject:SetActive(false)
				self.CoinDrawDraw.gameObject:SetActive(true)
			end
			self.coinCooldownEnabled = false
		else
			self.ColdTimeNum.text = utility.ConvertTime(self.coinCooldownTimer)
		end
	end
	
	if self.diamondCooldownEnabled then
		if os.time() - self.diamondCooldownTimestamp >= 1 then
			self.diamondCooldownTimestamp = os.time()
			self.diamondCooldownTimer = self.diamondCooldownTimer - 1
		end
		
		if self.diamondCooldownTimer <= 0 then
			self.ColdTimeBase1.gameObject:SetActive(false)
			if self.diamondFreeDrawTime > 0 then
				self.CoinDrawFree1.gameObject:SetActive(true)
				self.CoinDrawDraw1.gameObject:SetActive(false)
			else
				self.CoinDrawFree1.gameObject:SetActive(false)
				self.CoinDrawDraw1.gameObject:SetActive(true)
			end
			self.diamondCooldownEnabled = false
		else
			self.ColdTimeNum1.text = utility.ConvertTime(self.diamondCooldownTimer)
		end
	end
end

return ZodiacDrawCls
