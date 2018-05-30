local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"
require "Const"
require "LUT.StringTable"
require "GUI.Spine.SpineController"

-- 普通商店货币
local NormalShopCurrency = {}
NormalShopCurrency[1] = 10410001
NormalShopCurrency[2] = 10410002

--保护公主商店货币
local ProtectPrincessShopCurrency = {}
ProtectPrincessShopCurrency[1] = 10410005

--竞技场商店货币
local ArenaShopCurrency = {}
ArenaShopCurrency[1] = 10410004

--黑市商店货币 宝石商店货币
local BlackMarketShopCurrency = {}
BlackMarketShopCurrency[1] = 10410001

--军团商店货币
local ArmyGroupShopCurrency = {}
ArmyGroupShopCurrency[1] = 10410007

--军团积分战商店货币
local PointFightShopCurrency = {}
PointFightShopCurrency[1] = 10410012

--爬塔商店货币
local TowerShopCurrency = {}
TowerShopCurrency[1] = 10410010

--抽卡积分商店
local IntegralShopCurrency = {}
IntegralShopCurrency[1] = 10410015
--转转乐积分商店

local LotteryShopCurrency = {}
LotteryShopCurrency[1] = 10410013
-- TODO : Add商店类型
--货币  shop类型 1=普通商店 2=保护公主商店 3=竞技场商店 4=>黑市 5=军团币 6国战 7宝石 8爬塔 9 ,10 凑数据 表里没有  碎片 11 公会积分战 12抽卡积分  13 转转乐
local ShopCurrencyTheme = {NormalShopCurrency,
							ProtectPrincessShopCurrency,ArenaShopCurrency,
							BlackMarketShopCurrency,ArmyGroupShopCurrency,
							NormalShopCurrency,BlackMarketShopCurrency,
							TowerShopCurrency,NormalShopCurrency,
							NormalShopCurrency,PointFightShopCurrency,
							IntegralShopCurrency,LotteryShopCurrency}

-- 商店名称路径
local FixedTitleImagePath = "UI/Atlases/Shop/"
local ShopTitleImagePath = {"title_daoju",
							"title_gongzhu",
							"title_jinjichang",
							"title_heishi",
							"title_juntuan",
							"title_guozhan",
							"title_baoshi",
							"title_pata",
							"title_shuipian",
							"title_shuipian",
							"Title_jifenzhanshangdian",
							"title_shuipian",
							"title_zhuanzhuanleshangdian"}


-- 展示的最大数量
local shopItemMaxCount = 50
-- 刷新消耗最大次数
local MaxBuyCostCount = 20
-----------------------------------------------------------------------
local NormalShopCls = Class(BaseNodeClass)
-- windowUtility.SetMutex(NormalShopCls, true)

function NormalShopCls:Ctor()
	local ctrl = SpineController.New()
	self.ctrl = ctrl
end
function NormalShopCls:OnWillShow(ShopType,blackForever)
	self.ShopType = ShopType
	if self.blackForever ~= nil then
		self.blackForever = blackForever
	end
	debug_print(self.ShopType,"::::::::::::::::")
	--self:AddObserver()
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function NormalShopCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/Shop', function(go)
		self:BindComponent(go)
	end)
end

function NormalShopCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
	self:InitItemNode()
	self:InitShopTitle()
	self:GetRefreshTimeList()

end

local function PlayBGM(self, id)
	local audioManager = self:GetAudioManager()
	audioManager:SaveBGM()
	audioManager:FadeInBGM(id)
end

local function ReplayBGM(self)
	local audioManager = self:GetAudioManager()
	audioManager:ReplayBGM()
end

function NormalShopCls:ResetShop(ShopType)
	--debug_print(self.itemCount)
	self:HideItemList(self.itemCount)
	self.ShopType=ShopType

	self:GetCanSellData()
	self:ResetShopCurrencyTheme()
	--self:ItemBagQueryRequest()
	self:RefreshHintView()
	self:ShopQueryRequest(self.ShopType)

	self:InitShopTitle()
	self:SetFreeRefresh()
end

function NormalShopCls:SetFreeRefresh()
	local  ShopRefreshPrice = require "StaticData.Shop.ShopRefreshPrice"
	local count =ShopRefreshPrice:GetKeys().Length
	local  ShopRefreshPriceData 
	self.freeTime=0
	
	for i=1,count do
		ShopRefreshPriceData=ShopRefreshPrice:GetData(i)
		local cost
		-- 道具商店刷新消耗
		if  self.ShopType == KShopType_Normal then			
			cost = ShopRefreshPriceData:GetNormalShop()
			
		--竞技场商店
	    elseif self.ShopType == KShopType_Arena then
	    	cost = ShopRefreshPriceData:GetArenaShop()
	    
	   	elseif self.ShopType == KShopType_ProtectPrincess then

	   		cost = ShopRefreshPriceData:GetProtectPrincessShop()
	   		
	   	elseif self.ShopType == KShopType_Gem then
	   		cost = ShopRefreshPriceData:GetGemShop()
	   		
		elseif self.ShopType == KShopType_BlackMarket then
			cost = ShopRefreshPriceData:GetBlackMarketShop()
		
		elseif self.ShopType == KShopType_ArmyGroup then
			cost = ShopRefreshPriceData:GetArmyGroupShop()
		
		elseif self.ShopType == KShopType_GuildPoint then
			cost = ShopRefreshPriceData:GetGuildPointShop()
		
	    elseif self.ShopType == KShopType_Tower then
			cost = ShopRefreshPriceData:GetTowerShop()
		
		--积分战
		elseif self.ShopType == KShopType_IntegralShop then
			cost = ShopRefreshPriceData:GetIntegralShop()
		
		elseif self.ShopType == KShopType_LotteryShop then
			cost = ShopRefreshPriceData:GetLotteryShop()
		
		end
		if cost == 0 then
			self.freeTime=i
		else
			break
		end

	end
	hzj_print(self.freeTime,"self.freeTime")
	-- if self.freeTime == 0 or self.freeTime == self.alreadyBuy then
	-- 	--self.FreeRefreshTimeLabel.gameObject:SetActive(false)
	-- else
		local  count = self.freeTime-self.alreadyBuy
		if count<=0 then
			count=0
		end
		self.FreeRefreshTimeLabel.gameObject:SetActive(true)
		self.FreeRefreshTimeLabel.text="免费刷新:"..count.."/"..self.freeTime
	-- end
		


end
function NormalShopCls:OnResume()

	require "Utils.GameAnalysisUtils".RecordLocalAction(kTrackingId_ShopView)

	-- 界面显示时调用
	NormalShopCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()

	PlayBGM(self,1006)

	self:GetCanSellData()
	self:ResetShopCurrencyTheme()
	--self:ItemBagQueryRequest()
	self:RefreshHintView()
	self:ShopQueryRequest(self.ShopType)
	self:InitSpineShow()

   	local levelLimit = require"StaticData.SystemConfig.SystemBasis":GetData(KSystemBasis_BlackMarketID):GetMinLevel()
   	local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    if userData:GetLevel() >= levelLimit then
		self:ShopHeishiQueryRequest()

	end
	--self:ResumeItem()

	self:FadeIn(function(self, t,finished)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
        if finished then
        	self.itemScrollRect.enabled = true
        end
    end)
end

function NormalShopCls:OnPause()
	-- 界面隐藏时调用
	NormalShopCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
	self:CloseSpine()

	ReplayBGM(self)
	--self:RemoveObserver()
end

function NormalShopCls:OnEnter()
	-- Node Enter时调用
	NormalShopCls.base.OnEnter(self)
end

function NormalShopCls:OnExit()
	-- Node Exit时调用
	NormalShopCls.base.OnExit(self)
end

function NormalShopCls:InitSpineShow()
	self.ctrl:SetData(self.skeletonGraphic,self.speakerLabel,2)
end

function NormalShopCls:CloseSpine()
	self.ctrl:Stop()
end

function NormalShopCls:IsTransition()
    return true
end

function NormalShopCls:OnExitTransitionDidStart(immediately)
	NormalShopCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function NormalShopCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function NormalShopCls:InitControls()
	local transform = self:GetUnityTransform()
	--self.Frame = transform:Find('Base/Frame'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ShopRetrunButton = transform:Find('Base/ShopRetrunButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ItemListLayout = transform:Find('Base/ShopList/Scroll View/Viewport/Content')
	self.ShopRefreshButton = transform:Find('Base/ShopRefreshButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ShopRefreshTimeLabel = transform:Find('Base/TipLayout/ShopRefreshTimeLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.FreeRefreshTimeLabel = transform:Find('Base/TipLayout/FreeRefreshTimeLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	
	self.ShopCurrencyNumLabel = transform:Find('Base/Currency/ShopCurrencyNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.goldNumLabel = transform:Find('Base/GoldCurrency/GoldLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.tweenObjectTrans = transform:Find('Base')
	-- 货币样式1
	self.currencyThmeObj_1 = transform:Find('Base/Currency').gameObject
	self.currencyIcon_1 = transform:Find('Base/Currency/ShopCurrencyIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	-- 货币样式2
	self.currencyThmeObj_2 = transform:Find('Base/GoldCurrency').gameObject
	self.currencyIcon_2 = transform:Find('Base/GoldCurrency/GoldIcon'):GetComponent(typeof(UnityEngine.UI.Image))

	--self.ShopRefreshTimeLabel = transform:Find('Base/ShopRefreshTimeLabel'):GetComponent(typeof(UnityEngine.UI.Text))

	self.myGame = utility:GetGame()
	self.itemList = {}

	--self.currencyPath = {"UI/Atlases/TheMain/TheMain_DiamondIcon",nil,"UI/Atlases/Icon/gongzhubi_xiao"}

	-- 折扣提示
	self.InfoArea = transform:Find('Base/InfoArea').gameObject
	self.HintLabel = transform:Find('Base/InfoArea/TextLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	-- 标题
	self.titleImage = transform:Find('Base/TitleArea/Title'):GetComponent(typeof(UnityEngine.UI.Image))
	self.speakerLabel = transform:Find("Base/Frame/Text"):GetComponent(typeof(UnityEngine.UI.Text))
	self.skeletonGraphic = transform:Find('Base/mao/SkeletonGraphic (mao)'):GetComponent(typeof(Spine.Unity.SkeletonGraphic))

	self.itemScrollRect = transform:Find('Base/ShopList/Scroll View'):GetComponent(typeof(UnityEngine.UI.ScrollRect))
	self.itemScrollRect.enabled = false
	self.Left = transform:Find('Base/Left'):GetComponent(typeof(UnityEngine.UI.Button))
	self.Right = transform:Find('Base/Right'):GetComponent(typeof(UnityEngine.UI.Button))
	--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))
	self.blackForever = false
	self.FreeRefreshTimeLabel.gameObject:SetActive(false)

end


function NormalShopCls:RegisterControlEvents()
	-- 注册 ShopRetrunButton 的事件
	self.__event_button_onShopRetrunButtonClicked__ = UnityEngine.Events.UnityAction(self.OnShopRetrunButtonClicked, self)
	self.ShopRetrunButton.onClick:AddListener(self.__event_button_onShopRetrunButtonClicked__)

	-- 注册 ShopRefreshButton 的事件
	self.__event_button_onShopRefreshButtonClicked__ = UnityEngine.Events.UnityAction(self.OnShopRefreshButtonClicked, self)
	self.ShopRefreshButton.onClick:AddListener(self.__event_button_onShopRefreshButtonClicked__)

	self.__event_button_onLeftButtonClicked__ = UnityEngine.Events.UnityAction(self.OnShopLeftButtonClicked, self)
	self.Left.onClick:AddListener(self.__event_button_onLeftButtonClicked__)

	self.__event_button_onRightButtonClicked__ = UnityEngine.Events.UnityAction(self.OnShopRightButtonClicked, self)
	self.Right.onClick:AddListener(self.__event_button_onRightButtonClicked__)

	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnShopRetrunButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

end

function NormalShopCls:UnregisterControlEvents()

	if self.__event_button_onRightButtonClicked__ then
		self.Right.onClick:RemoveListener(self.__event_button_onRightButtonClicked__)
		self.__event_button_onRightButtonClicked__ = nil
	end
	if self.__event_button_onLeftButtonClicked__ then
		self.Left.onClick:RemoveListener(self.__event_button_onLeftButtonClicked__)
		self.__event_button_onLeftButtonClicked__ = nil
	end

	-- 取消注册 ShopRetrunButton 的事件
	if self.__event_button_onShopRetrunButtonClicked__ then
		self.ShopRetrunButton.onClick:RemoveListener(self.__event_button_onShopRetrunButtonClicked__)
		self.__event_button_onShopRetrunButtonClicked__ = nil
	end

	-- 取消注册 ShopRefreshButton 的事件
	if self.__event_button_onShopRefreshButtonClicked__ then
		self.ShopRefreshButton.onClick:RemoveListener(self.__event_button_onShopRefreshButtonClicked__)
		self.__event_button_onShopRefreshButtonClicked__ = nil
	end

	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end

end
local function JudgeLevel( data,level )
	if level>=data:GetOpenLevel() then
		
		return true
	else
		return false

	end
end 
-- local function GetLastShop(self,ShopTypeIndex,add)
-- 	local UserDataType = require "Framework.UserDataType"
--     local userData = self:GetCachedData(UserDataType.PlayerData)
-- 	local level = userData:GetLevel()
-- 	local ShopConfig = require "StaticData.Shop.ShopConfig"
-- 	local length = require "StaticData.Shop.ShopConfig":GetKeys()

-- 	local x = 0
-- 	local index = ShopTypeIndex
-- 	for j=0,length.Length-1 do
-- 	 	if ShopConfig:GetData(length[j]):GetId() ==ShopTypeIndex then
-- 	 		index=j
-- 	 	end
-- 	end 
-- 	while(true) do
-- 		index=index+add
-- 		if  index <0 then
-- 			index=length.Length-1
-- 		else			
			
-- 		end
		
-- 		x=x+1
-- 		-- debug_print(i,length.Length)
		 
-- 		debug_print(length[index],ShopTypeIndex,index)
-- 		local data =ShopConfig:GetData(length[index])
-- 		-- debug_print(data:GetId(), data:GetAlwaysOpen(),i,"ShopTypeIndex",ShopTypeIndex)
-- 		--一直开启的商店
-- 		if data:GetAlwaysOpen()== 0 then
-- 			local flag = JudgeLevel(data,level)
-- 			if flag then				
-- 				return data:GetId()
-- 			else				
-- 				debug_print("等级不够")
-- 			end
-- 		else
-- 			--黑市商店
-- 			if data:GetId() == KShopType_BlackMarket then
-- 				local flag=JudgeLevel(data,level)
-- 				if flag then
-- 					if self.blackForever or self.isOpen then
-- 						debug_print("黑市开启")
-- 						return data:GetId()
-- 					end
-- 				end
-- 			end

-- 		end
-- 		if x==length.Length then
-- 			break
-- 		end	
-- 	end	

-- 	return ShopTypeIndex

-- end

local function GetNextShop(self,ShopTypeIndex,add)

	local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
	local level = userData:GetLevel()
	local ShopConfig = require "StaticData.Shop.ShopConfig"
	local length = require "StaticData.Shop.ShopConfig":GetKeys()

	--debug_print(length,length.Length)
	local i = ShopTypeIndex
	local index = ShopTypeIndex
	--获取商店的Index
	for j=0,length.Length-1 do
	 	if ShopConfig:GetData(length[j]):GetId() ==ShopTypeIndex then
	 		index=j
	 	end
	end 
	local x = 0
	--循环所有的商店直到查找到合适的
	while(true) do
		index=index+add
		if add>0 then
			if index >=length.Length  then				
					index=0
			end	
		else
			if  index <0 then
				index=length.Length-1				
			end
		end
		x=x+1
		--获取商店的数据
		local data =ShopConfig:GetData(length[index])	
		--一直开启的商店
		if data:GetAlwaysOpen()== 0 then
			local flag = JudgeLevel(data,level)
			if flag then			
				return data:GetId()
			else				
				debug_print("等级不够")
			end
		else --根据不同情况开启
			--黑市商店
			local flag=JudgeLevel(data,level)
			if data:GetId() == KShopType_BlackMarket then				
				if flag then
					if self.blackForever or self.isOpen then
						debug_print("黑市开启")
						return data:GetId()
					end
				end
			elseif data:GetId() == KShopType_LotteryShop then
				if flag then
					if userData:GetHappyTurnMusicIsOpen() then
						debug_print("转转乐积分商店开启")
						return data:GetId()
					end
				end
			elseif data:GetId() == KShopType_ArmyGroup then
				if flag then
					if userData:GetGonghuiID()~=0 then
						debug_print("工会商店开启")
						return data:GetId()
					end
				end
			elseif data:GetId() == KShopType_GuildPoint then
			if flag then
				if userData:GetGonghuiID()~=0 then
					debug_print("工会商店开启")
					return data:GetId()
				end
			end

			end
		end
		
		
		if x==length.Length then
			break
		end		
	end
	--默认都没有找到的时候返回当前的商店
	return ShopTypeIndex
	
end 

function NormalShopCls:OnShopLeftButtonClicked()
	
	self.ShopType=GetNextShop(self,self.ShopType,-1)
	self:ResetShop(self.ShopType)


end

function NormalShopCls:OnShopRightButtonClicked()	
	self.ShopType=GetNextShop(self,self.ShopType,1)
	self:ResetShop(self.ShopType)
end
function NormalShopCls:RegisterNetworkEvents()
	 self.myGame:RegisterMsgHandler(net.S2CLoadPlayerResult, self, self.OnLoadPlayerResponse)
	 self.myGame:RegisterMsgHandler(net.S2CShopQueryResult, self, self.OnShopQueryResponse)
	 self.myGame:RegisterMsgHandler(net.S2CShopFlushResult, self, self.OnShopFlushResponse)
	 self.myGame:RegisterMsgHandler(net.S2CShopHeishiForEverResult, self, self.OnBlackMarketForeverResult)
	 self.myGame:RegisterMsgHandler(net.S2CShopHeishiQueryResult,self,self.OnBlackMarketQueryResult)
end

function NormalShopCls:UnregisterNetworkEvents()
	self.myGame:UnRegisterMsgHandler(net.S2CLoadPlayerResult, self, self.OnLoadPlayerResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CShopQueryResult, self, self.OnShopQueryResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CShopFlushResult, self, self.OnShopFlushResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CShopHeishiForEverResult, self, self.OnBlackMarketForeverResult)
	self.myGame:UnRegisterMsgHandler(net.S2CShopHeishiQueryResult,self,self.OnBlackMarketQueryResult)
end
-----------------------------------------------------------------------
--- 网络处理
-----------------------------------------------------------------------
function NormalShopCls:ShopQueryRequest(ShopType)

	self.myGame:SendNetworkMessage( require"Network/ServerService".ShopQueryRequest(ShopType))
end

function NormalShopCls:ShopBuyRequest()
	self.myGame:SendNetworkMessage( require"Network/ServerService".ShopBuyRequest())
end

function NormalShopCls:ShopFlushRequest()
	debug_print(self.ShopType)
	self.myGame:SendNetworkMessage( require"Network/ServerService".ShopFlushRequest(self.ShopType))
end

function NormalShopCls:ItemBagSellRequest(uids)
	self.myGame:SendNetworkMessage( require"Network/ServerService".ItemBagSellRequest(uids))
end

function NormalShopCls:ShopHeishiQueryRequest()
--     --黑市Query请求
    self:GetGame():SendNetworkMessage( require "Network/ServerService".ShopHeishiQueryRequest())
end

function NormalShopCls:OnLoadPlayerResponse()
	self:RefreshHintView()
end

function NormalShopCls:OnBlackMarketForeverResult()
	self.blackForever = true
end

function NormalShopCls:OnBlackMarketQueryResult(msg)
	if msg.remainTime == -1 then
		self.blackForever = true

	end
	if msg.remainTime ~= 0 then
        self.isOpen=true
	end
end

function NormalShopCls:OnShopQueryResponse(msg)
	self:GetRefreshTime()
	self.alreadyBuy = msg.alreadyBuy
	self.ShopDiscount = msg.args / 10
	debug_print(" msg.alreadyBuy", msg.alreadyBuy)
	self.InfoArea:SetActive(self.ShopDiscount ~= 1)
	if self.ShopDiscount ~= 1 then
		self.HintLabel.text = string.format("当前商店折扣为%s折",msg.args)
	end
	self:ResetItem(msg)
	self:SetFreeRefresh()
end

function NormalShopCls:OnShopFlushResponse(msg)
	--self:HideItemList(self.itemCount)
end

function NormalShopCls:GetCanSellData()
	-- 查询出售的物品列表
	local UserDataType = require "Framework.UserDataType"
	local itemData = self:GetCachedData(UserDataType.ItemBagData)

	local sellDict = itemData:GetCanSellData()

	local sellCount = sellDict:Count()
	
	if sellCount > 0 then
		local windowManager = utility:GetGame():GetWindowManager()
   		windowManager:Show(require "GUI.Shop.ShopSellInformation",sellDict)
	end
	
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function NormalShopCls:OnShopRetrunButtonClicked()
	--ShopRetrunButton控件的点击事件处理
	debug_print(self.itemCount)
	self:HideItemList(self.itemCount)
	self:Close()
end

function NormalShopCls:OnShopRefreshButtonClicked()
	-- 刷新控件的点击事件处理
	-- TODO : Add商店类型

	debug_print(self.alreadyBuy)
	local alreadyBuy = math.min(self.alreadyBuy + 1,MaxBuyCostCount)
	local staticData = require "StaticData.Shop.ShopRefreshPrice":GetData(alreadyBuy)

	local cost 
	local coinStr

	-- 刷新消耗
	if  self.ShopType == KShopType_Normal then

		cost = staticData:GetNormalShop()
		coinStr = ShopStringTable[6]
    elseif self.ShopType == KShopType_Arena then

    	cost = staticData:GetArenaShop()
    	coinStr = ShopStringTable[8]
   	elseif self.ShopType == KShopType_ProtectPrincess then

   		cost = staticData:GetProtectPrincessShop()
   		coinStr = ShopStringTable[7]
   	elseif self.ShopType == KShopType_Gem then
   		cost = staticData:GetGemShop()
   		coinStr = ShopStringTable[6]
	elseif self.ShopType == KShopType_BlackMarket then
		cost = staticData:GetBlackMarketShop()
		coinStr = ShopStringTable[6]
	elseif self.ShopType == KShopType_ArmyGroup then
		cost = staticData:GetArmyGroupShop()
		coinStr = ShopStringTable[9]
	elseif self.ShopType == KShopType_GuildPoint then
		cost = staticData:GetGuildPointShop()
		coinStr = ShopStringTable[14]
    elseif self.ShopType == KShopType_Tower then
		cost = staticData:GetTowerShop()
		coinStr = ShopStringTable[15]
	--积分战
	elseif self.ShopType == KShopType_IntegralShop then
		cost = staticData:GetIntegralShop()
		coinStr = ShopStringTable[6]
	elseif self.ShopType == KShopType_LotteryShop then
		cost = staticData:GetLotteryShop()
		coinStr = ShopStringTable[6]
	end
	if cost == 0 then
		self:ShopFlushRequest()
		return
	end
	debug_print("cost",cost)
	local ConfirmDialogClass = require "GUI.Dialogs.ConfirmDialog"
	local windowManager = utility:GetGame():GetWindowManager()

	local str = ShopStringTable[10]
	str = string.format(str,cost,coinStr,self.alreadyBuy)

   	windowManager:Show(ConfirmDialogClass, str,self, self.ShopFlushRequest)
end

------------------------------------------------------------------------
function NormalShopCls:InitItemNode()
	--local count = shopItemMaxCount
	for i = 1 , shopItemMaxCount  do
		self.itemList[i] = require"GUI.Shop.ShopItem".New(self.ItemListLayout)		
	end
end

function NormalShopCls:InitShopTitle()
	-- 初始化商店 名称
	debug_print(ShopTitleImagePath[self.ShopType],"InitShopTitle")
	local path = string.format("%s%s",FixedTitleImagePath,ShopTitleImagePath[self.ShopType])
	
	utility.LoadSpriteFromPath(path,self.titleImage)
	self.titleImage:SetNativeSize()
end

function NormalShopCls:ResetItem(msg)
	-- 刷新商店item
	self.itemCount = #msg.shopItems
	--debug_print(#msg.shopItems,"@@@刷新商店item")
	local shopItemsData = utility.CompareItemByShopItemData(msg.shopItems,self.ShopType)
	for i=1,self.itemCount do
		local node = self.itemList[i]

		local active = node:GetNodeActive()
		if not active then 
			self:AddChild(node)
			node:SetNodeActice(true)
			node:ResteInfo(shopItemsData[i],self.ShopType,self.ShopDiscount)
		else
			node:ResteInfo(shopItemsData[i],self.ShopType,self.ShopDiscount)
		end
	end
end

function NormalShopCls:ResetShopCurrencyTheme()
	-- 设置货币样式
	-- TODO : Add商店类型
	local gametool = require "Utils.GameTools"
 	local currencyTheme = ShopCurrencyTheme[self.ShopType]
 	local currencyLength = #currencyTheme
	debug_print("self.ShopType",self.ShopType,currencyTheme[1])

 	if currencyLength > 1 then
 		self.currencyThmeObj_2:SetActive(true)
 		local _,_,_,icon_2 = gametool.GetItemDataById(currencyTheme[2])
 		utility.LoadSpriteFromPath(icon_2,self.currencyIcon_2)
 	else
 		self.currencyThmeObj_2:SetActive(false)
 	end
 	local _,_,_,icon = gametool.GetItemDataById(currencyTheme[1])  
    utility.LoadSpriteFromPath(icon,self.currencyIcon_1)
end


function NormalShopCls:RefreshHintView()
	-- 刷新提示文字 商店名称 货币
	-- TODO : Add商店类型
	local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    self:SetRefreshState(true)
    if  self.ShopType == KShopType_Normal then
    	self.ShopCurrencyNumLabel.text = userData:GetDiamond()
   		self.goldNumLabel.text = userData:GetCoin()	
    elseif self.ShopType == KShopType_Arena then
    	self.ShopCurrencyNumLabel.text = userData:GetShengwang()
   	elseif self.ShopType == KShopType_ProtectPrincess then
   		self.ShopCurrencyNumLabel.text = userData:GetPrincessCoin()
    elseif self.ShopType == KShopType_Gem then
    	self.ShopCurrencyNumLabel.text = userData:GetDiamond()
	elseif self.ShopType == KShopType_BlackMarket then
		if not self.blackForever then
			self:BlackMarketForever()
			self:SetRefreshState(false)
		end
		self.ShopCurrencyNumLabel.text = userData:GetDiamond()
	elseif self.ShopType == KShopType_ArmyGroup then
		self.ShopCurrencyNumLabel.text = userData:GetGonghuiCoin()
	elseif self.ShopType == KShopType_GuildPoint then
		self.ShopCurrencyNumLabel.text = userData:GetGhfcoin()
    elseif self.ShopType == KShopType_Tower then
		self.ShopCurrencyNumLabel.text = userData:GetTowerCoin()
	elseif self.ShopType == KShopType_IntegralShop then
		self.ShopCurrencyNumLabel.text = userData:GetChoukaCoin()
	elseif self.ShopType == KShopType_LotteryShop then

		self.ShopCurrencyNumLabel.text = userData:GetHappyTurnMusicJiFenCoin()
	end
end

function NormalShopCls:SetRefreshState(isHaveRefresh)
	self.ShopRefreshButton.gameObject:SetActive(isHaveRefresh)
	self.ShopRefreshTimeLabel.gameObject:SetActive(isHaveRefresh)
end

function NormalShopCls:BlackMarketForever()
	local vipMinLv = require "StaticData.Vip.Vip":GetBlacketMarketOpenLv()
	local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
	if userData:GetVip() >= vipMinLv then
		local windowManager = utility.GetGame():GetWindowManager()
		local SystemConfigMgr = require "StaticData.SystemConfig.SystemConfig"
		str = string.format(str,SystemConfigMgr:GetData(2):GetParameNum()[0])
		windowManager:Show(require "GUI.BlackMarket.BlackMarketForever", str)
	end
end

function NormalShopCls:HideItemList(count)
	-- 隐藏node
	local x = count or 0
	for i=1,x do
		local node = self.itemList[i]
		self:RemoveChild(node)
		node:SetNodeActice(false)
	end
end

function NormalShopCls:GetRefreshTimeList()
	-- 获取刷新时间数组
	local staticData = require "StaticData.Shop.ShopConfig":GetData(1)
	local times = staticData:GetRefreshTime()
	
	local list = {}
	for i = 0 , times.Count-1  do
		list[#list + 1] = times[i] / 3600
	end
	self.refreshTimeList = list
end

function NormalShopCls:GetRefreshTime()
	-- 获取刷新时间
	local hour = tonumber(os.date("%H",os.time())) 

	local time 
	for i = 1 ,#self.refreshTimeList do
		if hour < self.refreshTimeList[i] then
			time = self.refreshTimeList[i]
		end
	end

	if time == nil then
		time = self.refreshTimeList[1]
	end
	if time < 10 then
		time = string.format("%s%s",0,time)
	end

	self.ShopRefreshTimeLabel.text = string.format(ShopStringTable[13],time)
end

return NormalShopCls