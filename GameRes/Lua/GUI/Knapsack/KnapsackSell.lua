local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"
require "Const"
require "LUT.StringTable"
require "Collection.OrderedDictionary"
require "System.LuaDelegate"

-----------------------------------------------------------------------
local KnapsackSellCls = Class(BaseNodeClass)
windowUtility.SetMutex(KnapsackSellCls, true)

function KnapsackSellCls:Ctor()
	self.callback = LuaDelegate.New()
end
function KnapsackSellCls:OnWillShow(ptype,ctable,func,itemCls)
	self.ptype = ptype
	self.itemCls = itemCls
	self.callback:Set(ctable,func)
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function KnapsackSellCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/BackpackSell', function(go)
		self:BindComponent(go)
	end)
end

function KnapsackSellCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
	self:LoadBagScrollContent()
end

function KnapsackSellCls:OnResume()
	-- 界面显示时调用
	KnapsackSellCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()

	self:RefreshPanel()

	self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
end

function KnapsackSellCls:OnPause()
	-- 界面隐藏时调用
	KnapsackSellCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
	self.ScrollNode:ClearSelectedState()

end

function KnapsackSellCls:OnEnter()
	-- Node Enter时调用
	KnapsackSellCls.base.OnEnter(self)
end

function KnapsackSellCls:OnExit()
	-- Node Exit时调用
	KnapsackSellCls.base.OnExit(self)
end


function KnapsackSellCls:IsTransition()
    return false
end

function KnapsackSellCls:OnExitTransitionDidStart(immediately)
	KnapsackSellCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function KnapsackSellCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function KnapsackSellCls:InitControls()
	local transform = self:GetUnityTransform()

	self.tweenObjectTrans = transform:Find('Base')
	
	-- 背包返回按钮
	self.BackpackReturnButton = transform:Find('Base/CrossButton'):GetComponent(typeof(UnityEngine.UI.Button))
	
	-- 出售按钮
	self.ConferButton = transform:Find('Base/ConferButton'):GetComponent(typeof(UnityEngine.UI.Button))

	-- 背包挂点
	self.scrollTrans = transform:Find('Base/Layout')

	-- 价格
	self.PriceLabel = transform:Find('Base/PriceLabel'):GetComponent(typeof(UnityEngine.UI.Text))

	--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))

	-- 总价
	self.nodeTotalPrice = 0
	-- 出售列表
	self.sellItemUidsDict = OrderedDictionary.New()

	self.myGame = utility:GetGame()
end


function KnapsackSellCls:RegisterControlEvents()
	-- 注册 背包返回按钮 的事件
    self.__event_button_onBackpackReturnButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBackpackReturnButtonClicked, self)
    self.BackpackReturnButton.onClick:AddListener(self.__event_button_onBackpackReturnButtonClicked__)

    	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBackpackReturnButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

    -- 注册 出售按钮 的事件
    self.__event_button_onConferButtonButtonClicked__ = UnityEngine.Events.UnityAction(self.OnConferButtonButtonClicked, self)
    self.ConferButton.onClick:AddListener(self.__event_button_onConferButtonButtonClicked__)
end

function KnapsackSellCls:UnregisterControlEvents()
	 -- 取消注册 背包返回按钮 的事件
    if self.__event_button_onBackpackReturnButtonClicked__ then
        self.BackpackReturnButton.onClick:RemoveListener(self.__event_button_onBackpackReturnButtonClicked__)
        self.__event_button_onBackpackReturnButtonClicked__ = nil
    end

     -- 取消注册 出售按钮 的事件
    if self.__event_button_onConferButtonButtonClicked__ then
        self.ConferButton.onClick:RemoveListener(self.__event_button_onConferButtonButtonClicked__)
        self.__event_button_onConferButtonButtonClicked__ = nil
    end
    
    -- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end
end

function KnapsackSellCls:RegisterNetworkEvents()
	self.myGame:RegisterMsgHandler(net.S2CEquipSellResult, self, self.OnEquipSellResponse)
    self.myGame:RegisterMsgHandler(net.S2CEquipSuipianSellResult, self, self.OnEquipSuipianSellResponse)
end

function KnapsackSellCls:UnregisterNetworkEvents()
	self.myGame:UnRegisterMsgHandler(net.S2CEquipSellResult, self, self.OnEquipSellResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CEquipSuipianSellResult, self, self.OnEquipSuipianSellResponse)
end
-----------------------------------------------------------------------
--- 网络处理
-----------------------------------------------------------------------
function KnapsackSellCls:OnEquipsSellRequest(uids)
	self.myGame:SendNetworkMessage( require"Network/ServerService".EquipsSellRequest(uids))
end

function KnapsackSellCls:OnEquipSuipianSellRequest(id)
	self.myGame:SendNetworkMessage( require"Network/ServerService".EquipSuipianSellRequest(id))
end

function KnapsackSellCls:OnEquipSellResponse(msg)
	print("****OnEquipSellResponse*****")
	
	self.ScrollNode:ClearSelectedState()
	self.sellItemUidsDict:Clear()
	self.PriceLabel.text = 0
	self.nodeTotalPrice=0
	self.callback:Invoke(self.ptype)
	self:RefreshEquipSellPanel()
end

function KnapsackSellCls:OnEquipSuipianSellResponse(msg)
	print("****OnEquipSuipianSellResponse*****")
	
	self.ScrollNode:ClearSelectedState()
	self.sellItemUidsDict:Clear()
	self.PriceLabel.text = 0
	self.nodeTotalPrice=0
	self.callback:Invoke(self.ptype)
	self:RefreshEquipDebrisSellPanel()
end
-----------------------------------------------------------------------
function KnapsackSellCls:LoadBagScrollContent()
	-- 加载背包滑动控件
	self.ScrollNode = require "GUI.Knapsack.ScrollSellAll".New(self.scrollTrans,self,self.OnItemClicked)
	self:AddChild(self.ScrollNode)
end

function KnapsackSellCls:OnItemClicked(index,price,data,active)
	-- 背包点击
	local itype = data:GetKnapsackItemType()
	print(index,price,active,"背包点击背包点击")
	self:UpdateSellPanel(index,active)
	self:UpdateSellPrice(price,active)
	self:RefreshSellDict(itype,data,active)
end

function KnapsackSellCls:RefreshEquipSellPanel()
	-- 更新数据
	local UserDataType = require "Framework.UserDataType"	
	local CachedData = self:GetCachedData(UserDataType.EquipBagData)
	local data = CachedData:GetCanSellData()
	local count = data:Count()

	self.ScrollNode:UpdateScrollContent(count,data)
	self.ScrollNode:ResetVerticalOffset(1)
end

function KnapsackSellCls:RefreshEquipDebrisSellPanel()
	-- 更新数据
	
	local UserDataType = require "Framework.UserDataType"	
	local data = self:GetCachedData(UserDataType.EquipDebrisBag):GetItemDict()
	local count = data:Count()

	self.ScrollNode:UpdateScrollContent(count,data)
	self.ScrollNode:ResetVerticalOffset(1)
end

function KnapsackSellCls:RefreshPanel()
	if self.ptype == 1 then
		self:RefreshEquipSellPanel()
	elseif self.ptype == 3 then
		self:RefreshEquipDebrisSellPanel()
	end
end

function KnapsackSellCls:UpdateSellPanel(index,active)
	-- 更新出售显示
	self.ScrollNode:AddSelectedState(index,active)
	self.ScrollNode:SetItemSelecetdState()
end

function KnapsackSellCls:UpdateSellPrice(price,active)
	-- 更新价格
	if active then
		self.nodeTotalPrice = self.nodeTotalPrice + price
	else
		self.nodeTotalPrice = self.nodeTotalPrice - price
	end

	self.PriceLabel.text =  self.nodeTotalPrice
end

function KnapsackSellCls:RefreshSellDict(itype,data,active)
	-- 刷新出售列表
	local uid
	if itype == KKnapsackItemType_EquipNormal then
		uid = data:GetEquipUID()
	elseif itype == KKnapsackItemType_EquipDebris then
		uid = data:GetEquipSuipianID()
	end

	if active then
		self.sellItemUidsDict:Add(uid,itype)
	else
		self.sellItemUidsDict:Remove(uid)
	end
end

function KnapsackSellCls:AllItemSellRequest()
	-- 出售请求
	local keys = self.sellItemUidsDict:GetKeys()
 	
	if #keys < 1 then
		local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
    	local windowManager = utility:GetGame():GetWindowManager()
   		windowManager:Show(ErrorDialogClass, EquipStringTable[25])
   	else
   		local stype = self.sellItemUidsDict:GetEntryByIndex(1)
   		if stype == KKnapsackItemType_EquipNormal then
   			-- 出售装备
        	local uids = ""
        	for i = 1,#keys do
          		local temp = keys[i]
          		uids = string.format("%s%s%s",uids,temp,",")
        	end
        	self:OnEquipsSellRequest(uids)
        elseif stype == KKnapsackItemType_EquipDebris then
        	-- 出售装备碎片
      		local ids = {}
        	for i = 1,#keys do         
          		ids[#ids + 1] = keys[i]
        	end
        	self:OnEquipSuipianSellRequest(ids)
        end
    end

end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function KnapsackSellCls:OnBackpackReturnButtonClicked()
	-- 返回
	self:Close()
end

function KnapsackSellCls:OnConferButtonButtonClicked()
	-- 出售
	self:AllItemSellRequest()
end

return KnapsackSellCls