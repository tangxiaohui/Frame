local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local net = require "Network.Net"

local VipGiftPanelCls = Class(BaseNodeClass)
windowUtility.SetMutex(VipGiftPanelCls, true)

function  VipGiftPanelCls:Ctor()
end

function VipGiftPanelCls:OnWillShow(id,type,activeId)
	self.id = id
	self.type = type
	self.activeId = activeId --七日狂欢总表
end

function  VipGiftPanelCls:OnInit()
	utility.LoadNewGameObjectAsync("UI/Prefabs/VipGift",function(go)
		self:BindComponent(go)
	end)
end

function VipGiftPanelCls:OnComponentReady()
	self:InitControls()
end

function VipGiftPanelCls:OnResume()
	VipGiftPanelCls.base.OnResume(self)
	self:FadeIn(function(self, t)
        local transform = self.transform

        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
	self:RegisterControlEvents()
	self:RegisterNetworkEvenrs()
	self:ShowPanel()
end

function VipGiftPanelCls:OnPause()
	VipGiftPanelCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
	-- self:RemoveAll()
end

function VipGiftPanelCls:OnEnter()
	VipGiftPanelCls.base.OnEnter(self)
end

function VipGiftPanelCls:OnExit()
	VipGiftPanelCls.base.OnExit(self)
end

function VipGiftPanelCls:IsTransition()
    return true
end

function VipGiftPanelCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end

function VipGiftPanelCls:InitControls()
	local transform = self:GetUnityTransform()
	self.transform = transform:Find("Base")
	self.base = self.transform:Find("SmallWindowBase")
	self.itemPoint = self.transform:Find("ItemListLayout")
	self.priceLabel = self.base:Find("PriceLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.cancelButton = self.transform:Find("ButtonLayout/CancelButton"):GetComponent(typeof(UnityEngine.UI.Button))
	self.buyButton = self.transform:Find("ButtonLayout/BuyButton"):GetComponent(typeof(UnityEngine.UI.Button))
	self.itemIcon = self.base:Find("DiaIcon"):GetComponent(typeof(UnityEngine.UI.Image))
	--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))

	self.myGame = utility:GetGame()

end

----------------------------------------------------------------------------
--动画处理--
----------------------------------------------------------------------------
function VipGiftPanelCls:IsTransition()
    return true
end

-- ## 在这里执行 淡出函数! (immediately 值只针对 WindowNode 及其子类)
function VipGiftPanelCls:OnExitTransitionDidStart(immediately)
    VipGiftPanelCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.transform

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function VipGiftPanelCls:RegisterControlEvents()
	self._event_button_oncancelButtonClicked_ = UnityEngine.Events.UnityAction(self.OnCancelButtonClicked,self)
	self.cancelButton.onClick:AddListener(self._event_button_oncancelButtonClicked_)

	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCancelButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

	self._event_button_onbuyButtonClicked_ = UnityEngine.Events.UnityAction(self.OnBuyButtonClicked,self)
	self.buyButton.onClick:AddListener(self._event_button_onbuyButtonClicked_)
end

function VipGiftPanelCls:UnregisterControlEvents()
	if self._event_button_oncancelButtonClicked_ then
		self.cancelButton.onClick:RemoveListener(self._event_button_oncancelButtonClicked_)
		self._event_button_oncancelButtonClicked_ = nil
	end

	if self._event_button_onbuyButtonClicked_ then
		self.buyButton.onClick:RemoveListener(self._event_button_onbuyButtonClicked_)
		self._event_button_onbuyButtonClicked_ = nil
	end

	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end
end

function VipGiftPanelCls:RegisterNetworkEvenrs()
	self.myGame:RegisterMsgHandler(net.S2CVipDiamondLibaoBuyResult,self,self.OnVipDiamondLibaoBuyResult)
	self.myGame:RegisterMsgHandler(net.S2CActivitySevenDayAwardResult,self,self.ActivitySevenDayAwardResult)
end

function VipGiftPanelCls:UnregisterNetworkEvents()
	self.myGame:UnRegisterMsgHandler(net.S2CVipDiamondLibaoBuyResult,self,self.OnVipDiamondLibaoBuyResult)
	self.myGame:UnRegisterMsgHandler(net.S2CActivitySevenDayAwardResult,self,self.ActivitySevenDayAwardResult)
end

function VipGiftPanelCls:OnVipDiamondLibaoBuyRequest()
	self.myGame:SendNetworkMessage( require "Network.ServerService".VipDiamondLibaoBuyRequest(self.vipPackId))
end

function VipGiftPanelCls:OnVipChargeQuery()
    self:GetGame():SendNetworkMessage( require "Network.ServerService".VipChargeQuery())
end

function VipGiftPanelCls:ActivitySevenDayHappyRequest(hid)
	self.myGame:SendNetworkMessage( require "Network.ServerService".ActivitySevenDayHappyRequest(hid))
end

function VipGiftPanelCls:OnActivityGetAwardRequest(hid,activeId)
	self.myGame:SendNetworkMessage(require "Network/ServerService".ActivitySevenDayAwardRequest(hid,activeId))
end

function VipGiftPanelCls:ActivitySevenDayAwardResult(msg)
	-- debug_print(msg.status)
	if msg.status  then
		self:ActivitySevenDayHappyRequest(self.activeId)
		self:ShowAwardPanel()
		self:Close(true)
	end
end

function VipGiftPanelCls:OnVipDiamondLibaoBuyResult(msg)
	print("msg.result",msg.result)
	if msg.result  then
		self:OnVipChargeQuery()
		self:ShowAwardPanel()
		self:Close(true)
	end
end

function  VipGiftPanelCls:OnCancelButtonClicked()
	self:Close(true)
end

function VipGiftPanelCls:OnBuyButtonClicked()
	if self.type == 1 then
		self:OnVipDiamondLibaoBuyRequest()
	else
		self:OnActivityGetAwardRequest(self.activeId,self.id)
	end
end

function VipGiftPanelCls:ShowPanel()
	if self.type == 1 then
		self:LoadVipItem()
	else
		self:LoadFeverItem()
	end
end

function VipGiftPanelCls:LoadFeverItem()
	self.items = {}
	self.nums ={}
	self.colors = {}
	local activeData = require "StaticData.Activity.NewServerFeverGift":GetData(self.id)
	local itemId = activeData:GetItemID()
	local itemNum = activeData:GetItemNum()
	for i=0,itemId.Count - 1 do
		self.items[#self.items + 1] = itemId[i]
		self.nums[#self.nums + 1] = itemNum[i]
	end
	self.vipPacksNode = {}
	for i=1,#self.items do
		self.vipPacksItem = require "GUI.VIP.VipItem".New(self.itemPoint,self.items[i],self.nums[i],self.colors[i])
		self:AddChild(self.vipPacksItem)
		self.vipPacksNode[i] = self.vipPacksItem
	end
	self.priceLabel.text = activeData:GetNeeditemNum()
	local id = activeData:GetNeeditemID()
	local gametool = require "Utils.GameTools"
	local _,data,itemName,iconPath,itemType = gametool.GetItemDataById(id)
	utility.LoadSpriteFromPath(iconPath,self.itemIcon)
end

function VipGiftPanelCls:LoadVipItem()
	local vipData = require "StaticData.Vip.Vip"
	self.vipPackId = vipData:GetData(self.id):GetPacksID()
	local vipPacks = require "StaticData.Vip.VipPacks"
	self.vipPacksNode = {}
	-- if self.vipPackId ~= 0 then
		local vipPackData = vipPacks:GetData(self.vipPackId)
		self.items = utility.Split(vipPackData:GetItemID(),";")
		self.nums = utility.Split(vipPackData:GetItemNum(),";")
		self.colors = utility.Split(vipPackData:GetItemColor(),";")
		for i=1,#self.items do
			self.vipPacksItem = require "GUI.VIP.VipItem".New(self.itemPoint,self.items[i],self.nums[i],self.colors[i])
			self:AddChild(self.vipPacksItem)
			self.vipPacksNode[i] = self.vipPacksItem
		end
		self.priceLabel.text = vipPackData:GetPrice()
	-- else
	-- 	self.priceLabel.text = 0
	-- end
end

function VipGiftPanelCls:RemoveAll()
	if #self.vipPacksNode ~= 0 then
		for i=1,#self.vipPacksNode do
			self:RemoveChild(self.vipPacksNode[i],true)
		end
	end
end

function VipGiftPanelCls:ShowAwardPanel()
	local itemstables = {}
	local gametool = require "Utils.GameTools"
	local PropUtility = require "Utils.PropUtility"
	for i=1,#self.items do
		local _,data,itemName,iconPath,itemType = gametool.GetItemDataById(self.items[i])
		itemstables[i] = {}
		itemstables[i].id = self.items[i]
		itemstables[i].count = self.nums[i]
		local color
		if self.colors[i] ~= nil and tonumber(self.colors[i]) ~= -1 then
			color = self.colors[i]
		else
			color = gametool.GetItemColorByType(itemType,data)
		end
		-- debug_print(color)
		itemstables[i].color = color
	end

	local windowManager = self:GetGame():GetWindowManager()
    local AwardCls = require "GUI.Task.GetAwardItem"
    windowManager:Show(AwardCls,itemstables)
end

return VipGiftPanelCls