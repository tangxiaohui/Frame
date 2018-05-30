local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
local windowUtility = require "Framework.Window.WindowUtility"
-- local messageManager = require "Network.MessageManager"
local BackpackCls = Class(BaseNodeClass)
windowUtility.SetMutex(BackpackCls, true)

function BackpackCls:Ctor()
	self.ItemLayer = {[1] = "Item",[2] = "Equip",[3] = "Debris"}
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function BackpackCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/Backpack', function(go)
		self:BindComponent(go)
	end)
end
 
--function BackpackCls:GetRootHangingPoint()
  --  return self:GetUIManager():GetModuleLayer()
--end

function BackpackCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
	self.CurrentLayer = self.ItemLayer[1]
--	self.Scrollbar.value = 1
	self:SetButtonActive()
end

function BackpackCls:IsTransition()
    return true
end

function BackpackCls:OnResume()
	-- 界面显示时调用
	-- self:ScheduleUpdate(self.For)
	BackpackCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self.IsOpenBackpackSell = false
	self.CurrentFiltrate.text = "当前筛选：全部"
	self:AddObserver()
	self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)
        transform.localScale = Vector3(s, s, s)
    end)
    self.game:SendNetworkMessage(require "Network.ServerService".ItemBagQueryRequest())
end

function BackpackCls:OnExitTransitionDidStart(immediately)
	BackpackCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans
            local TweenUtility = require "Utils.TweenUtility"
            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function BackpackCls:OnPause()
	-- 界面隐藏时调用
	BackpackCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
	self:RemoveObserver()
	-- self:UnscheduleUpdate(self.For)
end

function BackpackCls:OnEnter()
	-- Node Enter时调用
	BackpackCls.base.OnEnter(self)
end

function BackpackCls:OnExit()
	-- Node Exit时调用
	BackpackCls.base.OnExit(self)
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function BackpackCls:InitControls()
	local transform = self:GetUnityTransform()
	self.game = utility.GetGame()
	self.BackpackRetrunButton = transform:Find('TweenObj/BackpackRetrunButton'):GetComponent(typeof(UnityEngine.UI.Button)) -- 返回
	self.BackpackSellButton = transform:Find('TweenObj/BackpackSellButton'):GetComponent(typeof(UnityEngine.UI.Button))  -- 批量出售
	self.TitleText = transform:Find('TweenObj/BackpackSellButton/TitleText'):GetComponent(typeof(UnityEngine.UI.Text))  -- 批量出售TEXT
	self.BackpackDebrisButton = transform:Find('TweenObj/BackpackDebrisButton'):GetComponent(typeof(UnityEngine.UI.Button)) -- 碎片按钮
	self.BackpackEquipmentButton = transform:Find('TweenObj/BackpackEquipmentButton'):GetComponent(typeof(UnityEngine.UI.Button))  -- 装备按钮
	self.BackpackItemButton = transform:Find('TweenObj/BackpackItemButton'):GetComponent(typeof(UnityEngine.UI.Button))  -- 道具按钮
	self.BackpackFilterButton = transform:Find('TweenObj/BackpackFilterButton'):GetComponent(typeof(UnityEngine.UI.Button))  -- 筛选按钮
	self.BackpackUpperLimitLabel = transform:Find('TweenObj/BackpackUpperLimitLabel'):GetComponent(typeof(UnityEngine.UI.Text))	-- 携带上限
	self.normalSprite = transform:Find('TweenObj/BackpackDebrisButton'):GetComponent(typeof(UnityEngine.UI.Image)).sprite  -- 原本的Button图片
	self.BackpackDebrisButtonImage = transform:Find('TweenObj/BackpackDebrisButton'):GetComponent(typeof(UnityEngine.UI.Image)) -- Button上的image
	self.BackpackEquipmentButtonImage = transform:Find('TweenObj/BackpackEquipmentButton'):GetComponent(typeof(UnityEngine.UI.Image)) -- 
	self.BackpackItemButtonImage = transform:Find('TweenObj/BackpackItemButton'):GetComponent(typeof(UnityEngine.UI.Image))  -- 
	self.ItemList = transform:Find('TweenObj/BackpackItemList/Scroll View/Viewport/Content')--:GetComponent(typeof(UnityEngine.UI.GridLayoutGroup)) -- 道具挂点
	self.EquipList = transform:Find('TweenObj/BackpackEquipList/Scroll View/Viewport/Content') -- 装备挂点
	self.SuipianList = transform:Find('TweenObj/BackpackSuipianList/Scroll View/Viewport/Content') -- 碎片挂点
	
	self.ItemList1 = transform:Find('TweenObj/BackpackItemList')
	self.EquipList1 = transform:Find('TweenObj/BackpackEquipList')
	self.SuipianList1 = transform:Find('TweenObj/BackpackSuipianList')

	self.Mask = transform:Find('TweenObj/Mask')
	--self.Scrollbar = transform:Find('TweenObj/BackpackList/Scroll ViewItem/Scrollbar Vertical'):GetComponent(typeof(UnityEngine.UI.Scrollbar))
	self.CurrentFiltrate = transform:Find('TweenObj/CurrentFiltrate'):GetComponent(typeof(UnityEngine.UI.Text)) -- 当前筛选
	self.tweenObjectTrans = transform:Find('TweenObj')

	self.EquipsScrollViewVertical = transform:Find('TweenObj/BackpackEquipList/Scroll View/Scrollbar Vertical'):GetComponent(typeof(UnityEngine.UI.Scrollbar))
	self.ItemsScrollViewVertical = transform:Find('TweenObj/BackpackItemList/Scroll View/Scrollbar Vertical'):GetComponent(typeof(UnityEngine.UI.Scrollbar))
	self.SuipianScrollViewVertical = transform:Find('TweenObj/BackpackSuipianList/Scroll View/Scrollbar Vertical'):GetComponent(typeof(UnityEngine.UI.Scrollbar))

	self.GeneralEquipList = {}  -- 装备列表
	self.GeneralItemList = {}  --道具
	self.GeneralSuipianList = {}  -- 碎片
	
	self.CurrentLayer = self.ItemLayer[1]
end

-- function BackpackCls:For()
-- 	-- print(self.SuipianList.parent.localPosition.y)
-- 	for i=1,#self.GeneralSuipianList do
-- 		if self.SuipianList:GetChild(i-1).localPosition.y > -100  then
-- 			self.SuipianList:GetChild(i-1).gameObject:SetActive(false)
-- 			self.SuipianList:GetChild(i-1):SetAsLastSibling()
-- 		elseif self.SuipianList:GetChild(i-1).localPosition.y < -700 then
-- 			self.SuipianList:GetChild(i-1).gameObject:SetActive(false)
-- 			self.SuipianList:GetChild(i-1):SetAsFristSibling()
-- 		else 
-- 			self.SuipianList:GetChild(i-1).gameObject:SetActive(true)
-- 		end
-- 	end
-- end



function BackpackCls:RegisterControlEvents()
	-- 注册 BackpackRetrunButton 的事件
	self.__event_button_onBackpackRetrunButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBackpackRetrunButtonClicked, self)
	self.BackpackRetrunButton.onClick:AddListener(self.__event_button_onBackpackRetrunButtonClicked__)

	-- 注册 BackpackSellButton 的事件
	self.__event_button_onBackpackSellButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBackpackSellButtonClicked, self)
	self.BackpackSellButton.onClick:AddListener(self.__event_button_onBackpackSellButtonClicked__)

	-- 注册 BackpackDebrisButton 的事件
	self.__event_button_onBackpackDebrisButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBackpackDebrisButtonClicked, self)
	self.BackpackDebrisButton.onClick:AddListener(self.__event_button_onBackpackDebrisButtonClicked__)

	-- 注册 BackpackEquipmentButton 的事件
	self.__event_button_onBackpackEquipmentButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBackpackEquipmentButtonClicked, self)
	self.BackpackEquipmentButton.onClick:AddListener(self.__event_button_onBackpackEquipmentButtonClicked__)

	-- 注册 BackpackItemButton 的事件
	self.__event_button_onBackpackItemButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBackpackItemButtonClicked, self)
	self.BackpackItemButton.onClick:AddListener(self.__event_button_onBackpackItemButtonClicked__)

	-- 注册 BackpackFilterButton 的事件
	self.__event_button_onBackpackFilterButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBackpackFilterButtonClicked, self)
	self.BackpackFilterButton.onClick:AddListener(self.__event_button_onBackpackFilterButtonClicked__)

	-- 注册 EquipScrollbar_Vertical 的事件
	self.__event_scrollbar_onScrollbar_EquipsVerticalValueChanged__ = UnityEngine.Events.UnityAction_float(self.OnScrollbar_EquipsVerticalValueChanged, self)
	self.EquipsScrollViewVertical.onValueChanged:AddListener(self.__event_scrollbar_onScrollbar_EquipsVerticalValueChanged__)

	-- 注册 ItemScrollbar_Vertical 的事件
	self.__event_scrollbar_onScrollbar_ItemsVerticalValueChanged__ = UnityEngine.Events.UnityAction_float(self.OnScrollbar_ItemsVerticalValueChanged, self)
	self.ItemsScrollViewVertical.onValueChanged:AddListener(self.__event_scrollbar_onScrollbar_ItemsVerticalValueChanged__)

	-- 注册 SuipianScrollbar_Vertical 的事件
	self.__event_scrollbar_onScrollbar_SuipianVerticalValueChanged__ = UnityEngine.Events.UnityAction_float(self.OnScrollbar_SuipianVerticalValueChanged, self)
	self.SuipianScrollViewVertical.onValueChanged:AddListener(self.__event_scrollbar_onScrollbar_SuipianVerticalValueChanged__)
end

function BackpackCls:UnregisterControlEvents()
	-- 取消注册 BackpackRetrunButton 的事件
	if self.__event_button_onBackpackRetrunButtonClicked__ then
		self.BackpackRetrunButton.onClick:RemoveListener(self.__event_button_onBackpackRetrunButtonClicked__)
		self.__event_button_onBackpackRetrunButtonClicked__ = nil
	end

	-- 取消注册 BackpackSellButton 的事件
	if self.__event_button_onBackpackSellButtonClicked__ then
		self.BackpackSellButton.onClick:RemoveListener(self.__event_button_onBackpackSellButtonClicked__)
		self.__event_button_onBackpackSellButtonClicked__ = nil
	end

	-- 取消注册 BackpackDebrisButton 的事件
	if self.__event_button_onBackpackDebrisButtonClicked__ then
		self.BackpackDebrisButton.onClick:RemoveListener(self.__event_button_onBackpackDebrisButtonClicked__)
		self.__event_button_onBackpackDebrisButtonClicked__ = nil
	end

	-- 取消注册 BackpackEquipmentButton 的事件
	if self.__event_button_onBackpackEquipmentButtonClicked__ then
		self.BackpackEquipmentButton.onClick:RemoveListener(self.__event_button_onBackpackEquipmentButtonClicked__)
		self.__event_button_onBackpackEquipmentButtonClicked__ = nil
	end

	-- 取消注册 BackpackItemButton 的事件
	if self.__event_button_onBackpackItemButtonClicked__ then
		self.BackpackItemButton.onClick:RemoveListener(self.__event_button_onBackpackItemButtonClicked__)
		self.__event_button_onBackpackItemButtonClicked__ = nil
	end

	-- 取消注册 BackpackFilterButton 的事件
	if self.__event_button_onBackpackFilterButtonClicked__ then
		self.BackpackFilterButton.onClick:RemoveListener(self.__event_button_onBackpackFilterButtonClicked__)
		self.__event_button_onBackpackFilterButtonClicked__ = nil
	end

	-- 取消注册 Scrollbar_Vertical 的事件
	if self.__event_scrollbar_onScrollbar_EquipsVerticalValueChanged__ then
		self.EquipsScrollViewVertical.onValueChanged:RemoveListener(self.__event_scrollbar_onScrollbar_EquipsVerticalValueChanged__)
		self.__event_scrollbar_onScrollbar_EquipsVerticalValueChanged__ = nil
	end

	-- 取消注册 Scrollbar_Vertical 的事件
	if self.__event_scrollbar_onScrollbar_ItemsVerticalValueChanged__ then
		self.ItemsScrollViewVertical.onValueChanged:RemoveListener(self.__event_scrollbar_onScrollbar_ItemsVerticalValueChanged__)
		self.__event_scrollbar_onScrollbar_ItemsVerticalValueChanged__ = nil
	end

	-- 取消注册 Scrollbar_Vertical 的事件
	if self.__event_scrollbar_onScrollbar_SuipianVerticalValueChanged__ then
		self.SuipianScrollViewVertical.onValueChanged:RemoveListener(self.__event_scrollbar_onScrollbar_SuipianVerticalValueChanged__)
		self.__event_scrollbar_onScrollbar_SuipianVerticalValueChanged__ = nil
	end
end
function BackpackCls:RegisterNetworkEvents()
	self.game:RegisterMsgHandler(net.S2CEquipBagQueryResult, self, self.EquipBagQuery)
	self.game:RegisterMsgHandler(net.S2CItemBagQueryResult, self, self.ItemBagQuery)
	self.game:RegisterMsgHandler(net.S2CEquipSuipianBagQueryResult, self, self.DebrisBagQuery)
	self.game:RegisterMsgHandler(net.S2CEquipSellResult, self, self.EquipSellResult)
end
function BackpackCls:UnregisterNetworkEvents()
	self.game:UnRegisterMsgHandler(net.S2CEquipBagQueryResult, self, self.EquipBagQuery)
	self.game:UnRegisterMsgHandler(net.S2CItemBagQueryResult, self, self.ItemBagQuery)
	self.game:UnRegisterMsgHandler(net.S2CEquipSuipianBagQueryResult, self, self.DebrisBagQuery)
	self.game:UnRegisterMsgHandler(net.S2CEquipSellResult, self, self.EquipSellResult)
end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function BackpackCls:SetButtonActive() --设置筛选出售按钮显示隐藏  
	if self.CurrentLayer == self.ItemLayer[1] then --道具
		self.BackpackSellButton.interactable = false
		self.BackpackSellButton.gameObject:SetActive(false)
		self.BackpackFilterButton.interactable = false
		self.BackpackFilterButton.gameObject:SetActive(false)
		self.CurrentFiltrate.gameObject:SetActive(false)
		return true
	end
	if self.CurrentLayer == self.ItemLayer[2] then --装备
		self.BackpackSellButton.interactable = true
		self.BackpackSellButton.gameObject:SetActive(true)
		self.BackpackFilterButton.interactable = true
		self.BackpackFilterButton.gameObject:SetActive(true)
		self.CurrentFiltrate.gameObject:SetActive(true)
		return true
	end
	if self.CurrentLayer == self.ItemLayer[3] then --碎片
		self.BackpackSellButton.interactable = true
		self.BackpackSellButton.gameObject:SetActive(true)
		self.BackpackFilterButton.interactable = false
		self.BackpackFilterButton.gameObject:SetActive(false)
		self.CurrentFiltrate.gameObject:SetActive(false)
		return true
	end
	return false
end
--       -359    -338
function BackpackCls:ButtonSetAsLastSibling(Button) -- 设置三个Button的现实顺序
	local name = string.format("UI/Atlases/Friends/%s", "Friends_AngleButton_Orange")	
	utility.LoadResourceAsync(name, typeof(UnityEngine.Sprite), function(prefab) -- 橘红
       	if self.BackpackDebrisButton == Button then
		self.BackpackDebrisButton.transform:SetAsLastSibling()
		self.BackpackDebrisButtonImage.sprite = prefab
		self.BackpackDebrisButton.transform.localPosition = Vector3(-359,28.5,0)--chu
		self.BackpackEquipmentButton.transform:SetSiblingIndex(1)
		self.BackpackEquipmentButtonImage.sprite = self.normalSprite
		self.BackpackEquipmentButton.transform.localPosition = Vector3(-338,91.1,0)--chu
		self.BackpackItemButton.transform:SetSiblingIndex(2)
		self.BackpackItemButtonImage.sprite = self.normalSprite
		self.BackpackItemButton.transform.localPosition = Vector3(-338,156,0)--chu
	elseif self.BackpackEquipmentButton == Button then
		self.BackpackEquipmentButton.transform:SetAsLastSibling()
		self.BackpackEquipmentButtonImage.sprite = prefab
		self.BackpackEquipmentButton.transform.localPosition = Vector3(-359,91.1,0)--chu
		self.BackpackDebrisButton.transform:SetSiblingIndex(1)
		self.BackpackDebrisButtonImage.sprite = self.normalSprite
		self.BackpackDebrisButton.transform.localPosition = Vector3(-338,28.5,0)--chu
		self.BackpackItemButton.transform:SetSiblingIndex(2)
		self.BackpackItemButtonImage.sprite = self.normalSprite
		self.BackpackItemButton.transform.localPosition = Vector3(-338,156,0)--chu
	elseif self.BackpackItemButton == Button then
		self.BackpackItemButton.transform:SetAsLastSibling()
		self.BackpackItemButtonImage.sprite = prefab
		self.BackpackItemButton.transform.localPosition = Vector3(-359,156,0)--chu
		self.BackpackDebrisButton.transform:SetSiblingIndex(1)
		self.BackpackDebrisButtonImage.sprite = self.normalSprite
		self.BackpackDebrisButton.transform.localPosition = Vector3(-338,28.5,0)--chu
		self.BackpackEquipmentButton.transform:SetSiblingIndex(2)
		self.BackpackEquipmentButtonImage.sprite = self.normalSprite
		self.BackpackEquipmentButton.transform.localPosition = Vector3(-338,91.1,0)--chu
	end
   	end)
end


function BackpackCls:OnScrollbar_EquipsVerticalValueChanged(value)
	--Scrollbar_Vertical控件的点击事件处理
	-- print(value,"改变的值")
	local eventMgr = self.game:GetEventManager()    --注册事件
  	eventMgr:PostNotification('ChangeItemEquipPosition', nil,nil)
end
function BackpackCls:OnScrollbar_ItemsVerticalValueChanged(value)
	--Scrollbar_Vertical控件的点击事件处理
	local eventMgr = self.game:GetEventManager()    --注册事件
  	eventMgr:PostNotification('ChangeItemItemsPosition', nil,nil)
end
function BackpackCls:OnScrollbar_SuipianVerticalValueChanged(value)
	--Scrollbar_Vertical控件的点击事件处理
	local eventMgr = self.game:GetEventManager()    --注册事件
  	eventMgr:PostNotification('ChangeItemSuipianPosition', nil,nil)
end

function BackpackCls:OnBackpackRetrunButtonClicked()
	-- 返回 控件的点击事件处理
	-- self:Hide()
	self:Close()
end

function BackpackCls:OnBackpackDebrisButtonClicked()
	-- 碎片 控件的点击事件处理
	self.SuipianList1.gameObject:SetActive(true)
	self.EquipList1.gameObject:SetActive(false)
	self.ItemList1.gameObject:SetActive(false)
	self.SuipianList1.transform:SetAsLastSibling()
	self:ButtonSetAsLastSibling(self.BackpackDebrisButton)
	if self.CurrentLayer == self.ItemLayer[3] then
		return
	end
	self.game:SendNetworkMessage(require "Network.ServerService".EquipSuipianBagQueryRequest())
	self.CurrentLayer = self.ItemLayer[3]
	self:SetButtonActive()
end

function BackpackCls:OnBackpackEquipmentButtonClicked()
	-- 装备 控件的点击事件处理
	self.SuipianList1.gameObject:SetActive(false)
	self.EquipList1.gameObject:SetActive(true)
	self.ItemList1.gameObject:SetActive(false)
	self.EquipList1.transform:SetAsLastSibling()
	self:ButtonSetAsLastSibling(self.BackpackEquipmentButton)
	if self.CurrentLayer == self.ItemLayer[2] then
		return
	end
	if #self.GeneralEquipList  == 0 then
		self.game:SendNetworkMessage(require "Network.ServerService".EquipBagQueryRequest())
	end
	self.CurrentLayer = self.ItemLayer[2]
	self:SetButtonActive()
end

function BackpackCls:OnBackpackItemButtonClicked()
	-- 道具 控件的点击事件处理
	self.SuipianList1.gameObject:SetActive(false)
	self.EquipList1.gameObject:SetActive(false)
	self.ItemList1.gameObject:SetActive(true)
	self.ItemList1.transform:SetAsLastSibling()
	self:ButtonSetAsLastSibling(self.BackpackItemButton)
	if self.CurrentLayer == self.ItemLayer[1] then
		return
	end
	self.game:SendNetworkMessage(require "Network.ServerService".ItemBagQueryRequest())
	self.CurrentLayer = self.ItemLayer[1]
	self:SetButtonActive()
end

function BackpackCls:OnBackpackFilterButtonClicked()
	-- 筛选 控件的点击事件处理
	local windowManager = self.game:GetWindowManager()
    windowManager:Show(require "GUI.BackpackFilter")
end

function BackpackCls:OnBackpackSellButtonClicked()
	-- 批量出售 控件的点击事件处理
	if not self.IsOpenBackpackSell then
		--篩選
		if self.CurrentLayer == self.ItemLayer[2] then
			for i=1,#self.GeneralEquipList do
			local BasePrice = self.GeneralEquipList[i]:GetBasePrice()
			if BasePrice == 0 then
				--隱藏
				self.EquipList.transform:GetChild(i-1).gameObject:SetActive(false)
			end
			end
		end
		if self.CurrentLayer == self.ItemLayer[3] then
			for i=1,#self.GeneralSuipianList do
			local BasePrice = self.GeneralSuipianList[i]:GetBasePrice()
			if BasePrice == 0 then
				--隱藏
				self.SuipianList.transform:GetChild(i-1).gameObject:SetActive(false)
			end
			end
		end

		self.Mask.gameObject:SetActive(true)
		self.TitleText.text = "完成"
		if self.CurrentLayer == self.ItemLayer[2] then
			for i=1,#self.GeneralEquipList do
			self.GeneralEquipList[i]:SetSell(true)
			end
		end
		if self.CurrentLayer == self.ItemLayer[3] then
			for i=1,#self.GeneralSuipianList do
			self.GeneralSuipianList[i]:SetSell(true)
			end
		end
		self.IsOpenBackpackSell = true
	else
		if self.CurrentLayer == self.ItemLayer[2] then
			for i=1,#self.GeneralEquipList do
			local BasePrice = self.GeneralEquipList[i]:GetBasePrice()
			if BasePrice == 0 then
				--隱藏
				self.EquipList.transform:GetChild(i-1).gameObject:SetActive(true)
			end
			end
		end
		if self.CurrentLayer == self.ItemLayer[3] then
			for i=1,#self.GeneralSuipianList do
			local BasePrice = self.GeneralSuipianList[i]:GetBasePrice()
			if BasePrice == 0 then
				--隱藏
				self.SuipianList.transform:GetChild(i-1).gameObject:SetActive(true)
			end
			end
		end
		self.TitleText.text = "批量出售"
		self.Mask.gameObject:SetActive(false)
		if self.CurrentLayer == self.ItemLayer[2] then
			for i=1,#self.GeneralEquipList do
				self.GeneralEquipList[i]:SetSell(false)
			end
		end
		if self.CurrentLayer == self.ItemLayer[3] then
			for i=1,#self.GeneralSuipianList do
				self.GeneralSuipianList[i]:SetSell(false)
			end
		end
-- 出售
		if self.CurrentLayer == self.ItemLayer[2] then
			for i=1,#self.GeneralEquipList do
				if self.GeneralEquipList[i]:IsOpen() then					
					self.game:SendNetworkMessage(require "Network.ServerService".EquipsSellRequest(self.GeneralEquipList[i]:ReturnInfo().equipUID))
					
					self.GeneralEquipList[i]:SetChecked(false)
				end
			end
		end
		if self.CurrentLayer == self.ItemLayer[3] then
			for i=1,#self.GeneralSuipianList do
				if self.GeneralSuipianList[i]:IsOpen() then
					--发送碎片出售请求
					self.game:SendNetworkMessage(require "Network.ServerService".EquipsSellRequest(self.GeneralEquipList[i]:ReturnInfo().equipUID))					
					self.GeneralSuipianList[i]:SetChecked(false)
				end
			end
		end
		self.IsOpenBackpackSell = false
	end
end
-----------------------------------------------------------------------
--- 事件相关
-----------------------------------------------------------------------
function BackpackCls:AddObserver()
	self:RegisterEvent('ChangeCurrentFilter',self.SetFilter)
end
function BackpackCls:RemoveObserver()
	self:UnregisterEvent('ChangeCurrentFilter',self.SetFilter)
end
-- 筛选
function BackpackCls:SetFilter(msg)
	self.CurrentFiltrate.text = string.format("当前筛选:%s",msg)
	if msg == "全部" then
		for i=1,#self.GeneralEquipList do
			self.EquipList.transform:GetChild(i-1).gameObject:SetActive(true)
		end
	end
	if msg == "武器" then --1
		for i=1,#self.GeneralEquipList do
			local EquipType = self.GeneralEquipList[i]:EquipInfoReturnType()
			if EquipType == 1 then
			--	显示武器
				self.EquipList.transform:GetChild(i-1).gameObject:SetActive(true)
			else
			--	隐藏武器之外的
				self.EquipList.transform:GetChild(i-1).gameObject:SetActive(false)
			end
		end
	end
	if msg == "防具" then --2
		for i=1,#self.GeneralEquipList do
			local EquipType = self.GeneralEquipList[i]:EquipInfoReturnType()
			if EquipType == 2 then
				self.EquipList.transform:GetChild(i-1).gameObject:SetActive(true)
			else
				self.EquipList.transform:GetChild(i-1).gameObject:SetActive(false)
			end
		end
	end
	if msg == "饰品" then --3
		for i=1,#self.GeneralEquipList do
			local EquipType = self.GeneralEquipList[i]:EquipInfoReturnType()
			if EquipType == 3 then
				self.EquipList.transform:GetChild(i-1).gameObject:SetActive(true)
			else
				self.EquipList.transform:GetChild(i-1).gameObject:SetActive(false)
			end
		end
	end
	if msg == "鞋子" then --4
		for i=1,#self.GeneralEquipList do
			local EquipType = self.GeneralEquipList[i]:EquipInfoReturnType()
			if EquipType == 4 then
				self.EquipList.transform:GetChild(i-1).gameObject:SetActive(true)
			else
				self.EquipList.transform:GetChild(i-1).gameObject:SetActive(false)
			end
		end
	end
	if msg == "时装" then --7
		for i=1,#self.GeneralEquipList do
			local EquipType = self.GeneralEquipList[i]:EquipInfoReturnType()
			if EquipType == 7 then
				self.EquipList.transform:GetChild(i-1).gameObject:SetActive(true)
			else
				self.EquipList.transform:GetChild(i-1).gameObject:SetActive(false)
			end
		end
	end
end

-----------------------------------------------------------------------
--- 网络回调相关
-----------------------------------------------------------------------
function BackpackCls:EquipBagQuery(msg)
	print("现有装备个数：",#(msg.equips)) -- 多少件装备
	if #(msg.equips) == 0 then
		return
	end
	if #self.GeneralEquipList ~= #(msg.equips) then
		for i=1,#(msg.equips) do
			self.GeneralEquipList[i] = require "GUI.GeneralItem".New(self.EquipList,msg.equips[i],self.ItemLayer[2])
			self:AddChild(self.GeneralEquipList[i])
		end
	end
end

function BackpackCls:ItemBagQuery(msg)
	print("现有道具个数："..#(msg.items))
	if #(msg.items) == 0 then
		return
	end
	if #self.GeneralItemList ~= #(msg.items) then
		for i=1,#(msg.items) do
			self.GeneralItemList[i] = require "GUI.GeneralItem".New(self.ItemList,msg.items[i],self.ItemLayer[1])
			self:AddChild(self.GeneralItemList[i])
		end
	end
 end

 function BackpackCls:DebrisBagQuery(msg)
	print("现有碎片个数："..#(msg.suipians))
	if #(msg.suipians) == 0 then
		return
	end
	if #self.GeneralSuipianList ~= #(msg.suipians) then
			for i=1,#(msg.suipians) do
				self.GeneralSuipianList[i] = require "GUI.GeneralItem".New(self.SuipianList,msg.suipians[i],self.ItemLayer[3])
				self:AddChild(self.GeneralSuipianList[i])
			end
	end
 end
--装备出售装备请求回包
function BackpackCls:EquipSellResult(msg)
 	for i=1,#self.GeneralEquipList do
		if self.GeneralEquipList[i]:IsOpen() then
			self:RemoveChild(self.GeneralEquipList[i])
		end
	end
end

function BackpackCls:SuipianSellResult(msg)
	for i=1,#self.GeneralSuipianList do
		if self.GeneralSuipianList[i]:IsOpen() then
			self:RemoveChild(self.GeneralSuipianList[i])
		end
	end
end
return BackpackCls
