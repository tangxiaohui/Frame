local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local BuyNumberPanelCls = Class(BaseNodeClass)
require "Const"
function BuyNumberPanelCls:Ctor()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function BuyNumberPanelCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/BuyNumberPanel', function(go)
		self:BindComponent(go)
	end)
end
--tokenType         表示代币类型
--buyMaxNum			当前可购买最大次数 （如探险最大30 当前29 只能购买一次）
--alreadyBuyNum		已经够买次数		
--buyType           购买类型			
function BuyNumberPanelCls:OnWillShow(tokenType,buyMaxNum,alreadyBuyNum,buyType)
	self.buyType = buyType
	self.tokenType = tokenType
	self.buyMaxNum = buyMaxNum
	self.alreadyBuyNum=alreadyBuyNum	
end

function BuyNumberPanelCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function BuyNumberPanelCls:OnResume()
	-- 界面显示时调用
	BuyNumberPanelCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
end

function BuyNumberPanelCls:OnPause()
	-- 界面隐藏时调用
	BuyNumberPanelCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function BuyNumberPanelCls:OnEnter()
	-- Node Enter时调用
	BuyNumberPanelCls.base.OnEnter(self)
end

function BuyNumberPanelCls:OnExit()
	-- Node Exit时调用
	BuyNumberPanelCls.base.OnExit(self)
end
function BuyNumberPanelCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function BuyNumberPanelCls:InitControls()
	local transform = self:GetUnityTransform()
	
	self.TranslucentLayer = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))
	
	self.ItemNameLable = transform:Find('Base/ItemNameLable'):GetComponent(typeof(UnityEngine.UI.Text))
	--提示
	self.StatusLabel = transform:Find('Base/StatusLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.UseButton = transform:Find('Base/UseButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.AddButton = transform:Find('Base/AddButton'):GetComponent(typeof(UnityEngine.UI.RepeatButton))
	self.ReduceButton = transform:Find('Base/ReduceButton'):GetComponent(typeof(UnityEngine.UI.RepeatButton))
	--购买次数提示
	self.NumberText = transform:Find('Base/BoxImage/NumberText'):GetComponent(typeof(UnityEngine.UI.Text))

	--花费
	self.CostText = transform:Find('Base/CostText'):GetComponent(typeof(UnityEngine.UI.Text))
	--可购买次数
	self.BuyTimeText = transform:Find('Base/BuyTimeText'):GetComponent(typeof(UnityEngine.UI.Text))
	--钻石图标
	self.DiamondImage = transform:Find('Base/DiamondImage'):GetComponent(typeof(UnityEngine.UI.Image))

	self:InitViews()
end

function BuyNumberPanelCls:InitViews()
	self:LoadTokenType()
	self:ShowViewByBuyType()
	self.addNum=0
	self:UpdateText()
	


end
function BuyNumberPanelCls:UpdateText()
	local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    local vip = userData:GetVip()

	local vipData = require"StaticData.Vip.Vip"	
	local allCanBuyNum 
	if self.buyType == kBuyType_Explore then
		allCanBuyNum = vipData:GetData(vip):GetDailyAdventureBuy()	
	end

	self.CostText.text=self.addNum*self.oneCost
	self.NumberText.text=self.addNum

	self.BuyTimeText.text =self.canBuyNum.."/"..allCanBuyNum


end
--根据买的类型加载不同静态数据
function BuyNumberPanelCls:ShowViewByBuyType()
	local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    local vip = userData:GetVip()

    local vipData = require"StaticData.Vip.Vip"	

	if self.buyType == kBuyType_Explore then
		self.canBuyNum = vipData:GetData(vip):GetDailyAdventureBuy()	
		hzj_print("self.canBuyNum",self.canBuyNum,self.alreadyBuyNum)
		self.canBuyNum=self.canBuyNum-self.alreadyBuyNum
		hzj_print("self.alreadyBuyNum",self.canBuyNum)
		self.oneCost =  require "StaticData.Adventure.Adventure":GetData(1):GetBuyTime()
	else


	end

end

--加载小号代币类型
function BuyNumberPanelCls:LoadTokenType()
	local gametool = require "Utils.GameTools"
 	local _,_,_,icon = gametool.GetItemDataById(self.tokenType)  
    utility.LoadSpriteFromPath(icon,self.DiamondImage)

end

function BuyNumberPanelCls:RegisterControlEvents()
	-- 注册 TranslucentLayer 的事件
	self.__event_button_onTranslucentLayerClicked__ = UnityEngine.Events.UnityAction(self.OnTranslucentLayerClicked, self)
	self.TranslucentLayer.onClick:AddListener(self.__event_button_onTranslucentLayerClicked__)

	-- 注册 UseButton 的事件
	self.__event_button_onUseButtonClicked__ = UnityEngine.Events.UnityAction(self.OnUseButtonClicked, self)
	self.UseButton.onClick:AddListener(self.__event_button_onUseButtonClicked__)

	-- 注册 AddButton 的事件
	self.__event_button_onAddButtonClicked__ = UnityEngine.Events.UnityAction(self.OnAddButtonClicked, self)
	self.AddButton.onClick:AddListener(self.__event_button_onAddButtonClicked__)

	-- 注册 ReduceButton 的事件
	self.__event_button_onReduceButtonClicked__ = UnityEngine.Events.UnityAction(self.OnReduceButtonClicked, self)
	self.ReduceButton.onClick:AddListener(self.__event_button_onReduceButtonClicked__)

	-- 注册 AddButton 的事件
	self.__event_button_onAddRepeatClicked__ = UnityEngine.Events.UnityAction(self.OnAddRepeatButtonClicked, self)
	self.AddButton.m_OnRepeat:AddListener(self.__event_button_onAddRepeatClicked__)

	-- 注册 ReduceButton 的事件
	self.__event_button_onReduceRepeatClicked__ = UnityEngine.Events.UnityAction(self.OnReduceRepeatClicked, self)
	self.ReduceButton.m_OnRepeat:AddListener(self.__event_button_onReduceRepeatClicked__)

end

function BuyNumberPanelCls:UnregisterControlEvents()
	-- 取消注册 TranslucentLayer 的事件
	if self.__event_button_onTranslucentLayerClicked__ then
		self.TranslucentLayer.onClick:RemoveListener(self.__event_button_onTranslucentLayerClicked__)
		self.__event_button_onTranslucentLayerClicked__ = nil
	end

	-- 取消注册 UseButton 的事件
	if self.__event_button_onUseButtonClicked__ then
		self.UseButton.onClick:RemoveListener(self.__event_button_onUseButtonClicked__)
		self.__event_button_onUseButtonClicked__ = nil
	end

	-- 取消注册 AddButton 的事件
	if self.__event_button_onAddButtonClicked__ then
		self.AddButton.onClick:RemoveListener(self.__event_button_onAddButtonClicked__)
		self.__event_button_onAddButtonClicked__ = nil
	end

	-- 取消注册 ReduceButton 的事件
	if self.__event_button_onReduceButtonClicked__ then
		self.ReduceButton.onClick:RemoveListener(self.__event_button_onReduceButtonClicked__)
		self.__event_button_onReduceButtonClicked__ = nil
	end
	-- 取消注册 AddButton 的事件
	if self.__event_button_onAddRepeatClicked__ then
		self.AddButton.m_OnRepeat:RemoveListener(self.__event_button_onAddRepeatClicked__)
		self.__event_button_onAddRepeatClicked__ = nil
	end

	-- 取消注册 ReduceButton 的事件
	if self.__event_button_onReduceRepeatClicked__ then
		self.ReduceButton.m_OnRepeat:RemoveListener(self.__event_button_onReduceRepeatClicked__)
		self.__event_button_onReduceRepeatClicked__ = nil
	end

end

function BuyNumberPanelCls:RegisterNetworkEvents()
end

function BuyNumberPanelCls:UnregisterNetworkEvents()
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function BuyNumberPanelCls:OnTranslucentLayerClicked()
	--TranslucentLayer控件的点击事件处理
	self:Close()
end

function BuyNumberPanelCls:OnUseButtonClicked()
	--UseButton控件的点击事件处理
	hzj_print("OnUseButtonClicked")
	if self.addNum>0 then
		if self.buyType == kBuyType_Explore then
			self:GetGame():SendNetworkMessage(require "Network.ServerService".BuyAdventureTimesRequest(self.addNum))
		end
		self:Close()
	else
		local windowManager = utility:GetGame():GetWindowManager()
		local ConfirmDialogClass = require "GUI.Dialogs.ErrorDialog"
		windowManager:Show(ConfirmDialogClass, "购买次数不能为0")
	
	end
	


end

function BuyNumberPanelCls:Add()
	--AddButton控件的点击事件处理
	
	if self.addNum < self.canBuyNum then
		self.addNum=self.addNum+1
		self:UpdateText()
	end
	

end


function BuyNumberPanelCls:Reduce()
	--AddButton控件的点击事件处理
	
	if self.addNum > 0 then
		self.addNum=self.addNum-1
		self:UpdateText()
	end

end

function BuyNumberPanelCls:OnAddButtonClicked()
	--AddButton控件的点击事件处理
	hzj_print("OnAddButtonClicked")
	self:Add()

end

function BuyNumberPanelCls:OnReduceButtonClicked()
	--ReduceButton控件的点击事件处理
	hzj_print("OnReduceButtonClicked")
	self:Reduce()

end

function BuyNumberPanelCls:OnAddRepeatButtonClicked()
	--AddButton控件的点击事件处理
	hzj_print("OnAddRepeatButtonClicked")
	self:Add()

end

function BuyNumberPanelCls:OnReduceRepeatClicked()
	--ReduceButton控件的点击事件处理
	hzj_print("OnReduceRepeatClicked")
	self:Reduce()

end
return BuyNumberPanelCls
