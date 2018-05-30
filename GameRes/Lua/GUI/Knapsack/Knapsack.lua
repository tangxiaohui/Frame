local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"
require "Const"
require "LUT.StringTable"
local messageGuids = require "Framework.Business.MessageGuids"



-- 装备
local EquipPanelState  = KKnapsackItemType_EquipNormal
-- 道具
local ItemPanelState   = KKnapsackItemType_Item
-- 碎片
local DebrisPanelState = KKnapsackItemType_EquipDebris
-- 宠物
local PetPanelState    = KKnapsackItemType_EquipPet

-- button 选中颜色
local ButtonSelectedImageColor = UnityEngine.Color(1,1,1,1)
local ButtonNormalImageColor = UnityEngine.Color(0.537254,0.537254,0.537254,1)

-----------------------------------------------------------------------
local KnapsackCls = Class(BaseNodeClass)
windowUtility.SetMutex(KnapsackCls, true)

function KnapsackCls:Ctor()
end
function KnapsackCls:OnWillShow()

end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function KnapsackCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/NeoBackpack', function(go)
		self:BindComponent(go)
	end)
end

function KnapsackCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
	self:LoadBagScrollContent()
end

function KnapsackCls:OnResume()
	-- 界面显示时调用
	KnapsackCls.base.OnResume(self)

	require "Utils.GameAnalysisUtils".RecordLocalAction(kTrackingId_KnapsackView)

	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:RegisterEventMonitor()
	self:LocalRedDotChanged()

	self:StateChangeCtrl(EquipPanelState)
	self.fliterType = KEquipType_EquipAll

	self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
end

function KnapsackCls:OnPause()
	-- 界面隐藏时调用
	KnapsackCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
	self:UnregisterEventMonitor()
end

function KnapsackCls:OnEnter()
	-- Node Enter时调用
	KnapsackCls.base.OnEnter(self)
end

function KnapsackCls:OnExit()
	-- Node Exit时调用
	KnapsackCls.base.OnExit(self)
end


function KnapsackCls:IsTransition()
    return true
end

function KnapsackCls:OnExitTransitionDidStart(immediately)
	KnapsackCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function KnapsackCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function KnapsackCls:InitControls()
	local transform = self:GetUnityTransform()

	self.tweenObjectTrans = transform:Find('Base')
	
	-- 背包返回按钮
	self.BackpackReturnButton = transform:Find('Base/CrossButton'):GetComponent(typeof(UnityEngine.UI.Button))
	-- 装备标签按钮
	self.BackpackEquipTagButton = transform:Find('Base/EquipButton'):GetComponent(typeof(UnityEngine.UI.Button))
	-- Item标签按钮
	self.BackpackItemTagButton = transform:Find('Base/ItemButton'):GetComponent(typeof(UnityEngine.UI.Button))
	-- 碎片按钮
	self.BackpackFragmentTagButton = transform:Find('Base/FragmentButton'):GetComponent(typeof(UnityEngine.UI.Button))
	-- 宠物标签按钮
	self.BackpackPetTagButton = transform:Find('Base/PetButton'):GetComponent(typeof(UnityEngine.UI.Button))
	-- 筛选按钮
	self.BackpackFliterButton = transform:Find('Base/FliterButton'):GetComponent(typeof(UnityEngine.UI.Button))
	-- 出售按钮
	self.SellAllButton = transform:Find('Base/SellButton'):GetComponent(typeof(UnityEngine.UI.Button))

	-- 筛选名称
	self.fliterTagLabel = transform:Find('Base/Base/TextLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	-- 背包挂点
	self.scrollTrans = transform:Find('Base/Layout')
	self.debrisRed = self.BackpackFragmentTagButton.transform:Find("RedDot").gameObject
  self.itemRedDot = self.BackpackItemTagButton.transform:Find("RedDot").gameObject
	--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))
	
end


function KnapsackCls:RegisterControlEvents()
	-- 注册 装备标签按钮 的事件
    self.__event_button_onBackpackEquipTagButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBackpackEquipTagButtonClicked, self)
    self.BackpackEquipTagButton.onClick:AddListener(self.__event_button_onBackpackEquipTagButtonClicked__)

    -- 注册 Item标签按钮 的事件
    self.__event_button_onBackpackItemTagButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBackpackItemTagButtonClicked, self)
    self.BackpackItemTagButton.onClick:AddListener(self.__event_button_onBackpackItemTagButtonClicked__)

    -- 注册 碎片按钮 的事件
    self.__event_button_onBackpackFragmentTagButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBackpackFragmentTagButtonClicked, self)
    self.BackpackFragmentTagButton.onClick:AddListener(self.__event_button_onBackpackFragmentTagButtonClicked__)

    -- 注册 宠物标签按钮 的事件
    self.__event_button_onBackpackPetTagButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBackpackPetTagButtonClicked, self)
    self.BackpackPetTagButton.onClick:AddListener(self.__event_button_onBackpackPetTagButtonClicked__)

	-- 注册 背包返回按钮 的事件
    self.__event_button_onBackpackReturnButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBackpackReturnButtonClicked, self)
    self.BackpackReturnButton.onClick:AddListener(self.__event_button_onBackpackReturnButtonClicked__)

    -- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBackpackReturnButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

    -- 注册 筛选按钮 的事件
    self.__event_button_onBackpackFliterButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBackpackFliterButtonClicked, self)
    self.BackpackFliterButton.onClick:AddListener(self.__event_button_onBackpackFliterButtonClicked__)

     -- 批量出售按钮
    self.__event_button_onSellAllButtonClicked__ = UnityEngine.Events.UnityAction(self.OnSellAllButtonClicked, self)
    self.SellAllButton.onClick:AddListener(self.__event_button_onSellAllButtonClicked__)
end

function KnapsackCls:UnregisterControlEvents()
	  -- 取消注册 装备标签按钮 的事件
    if self.__event_button_onBackpackEquipTagButtonClicked__ then
        self.BackpackEquipTagButton.onClick:RemoveListener(self.__event_button_onBackpackEquipTagButtonClicked__)
        self.__event_button_onBackpackEquipTagButtonClicked__ = nil
    end

    -- 取消注册 Item标签按钮 的事件
    if self.__event_button_onBackpackItemTagButtonClicked__ then
        self.BackpackItemTagButton.onClick:RemoveListener(self.__event_button_onBackpackItemTagButtonClicked__)
        self.__event_button_onBackpackItemTagButtonClicked__ = nil
    end

     -- 取消注册 碎片按钮 的事件
    if self.__event_button_onBackpackFragmentTagButtonClicked__ then
        self.BackpackFragmentTagButton.onClick:RemoveListener(self.__event_button_onBackpackFragmentTagButtonClicked__)
        self.__event_button_onBackpackFragmentTagButtonClicked__ = nil
    end

    -- 取消注册 宠物标签按钮 的事件
    if self.__event_button_onBackpackPetTagButtonClicked__ then
        self.BackpackPetTagButton.onClick:RemoveListener(self.__event_button_onBackpackPetTagButtonClicked__)
        self.__event_button_onBackpackPetTagButtonClicked__ = nil
    end

    -- 取消注册 背包返回按钮 的事件
    if self.__event_button_onBackpackReturnButtonClicked__ then
        self.BackpackReturnButton.onClick:RemoveListener(self.__event_button_onBackpackReturnButtonClicked__)
        self.__event_button_onBackpackReturnButtonClicked__ = nil
    end

    -- 取消注册 筛选按钮 的事件
     if self.__event_button_onBackpackFliterButtonClicked__ then
        self.BackpackFliterButton.onClick:RemoveListener(self.__event_button_onBackpackFliterButtonClicked__)
        self.__event_button_onBackpackFliterButtonClicked__ = nil
    end

    -- 取消注册 批量出售按钮 的事件
     if self.__event_button_onSellAllButtonClicked__ then
        self.SellAllButton.onClick:RemoveListener(self.__event_button_onSellAllButtonClicked__)
        self.__event_button_onSellAllButtonClicked__ = nil
    end

    -- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end
end

function KnapsackCls:RegisterNetworkEvents()
	
end

function KnapsackCls:UnregisterNetworkEvents()
	
end

function KnapsackCls:RegisterEventMonitor()
	self:RegisterEvent(messageGuids.CloseKnapsackWindow,self.OnBackpackReturnButtonClicked)
	self:RegisterEvent(messageGuids.UpdataKnapsackWindow,self.UpdateContentWithMsg)
	-- self:RegisterEvent(messageGuids.CardRedDotChanged, self.RedDotStateUpdated)
 --    self:RegisterEvent(messageGuids.ModuleRedDotChanged, self.RedDotStateUpdated)

    self:RegisterEvent(messageGuids.LocalRedDotChanged, self.LocalRedDotChanged)


end

function KnapsackCls:UnregisterEventMonitor()
	self:UnregisterEvent(messageGuids.CloseKnapsackWindow,self.OnBackpackReturnButtonClicked)
	self:UnregisterEvent(messageGuids.UpdataKnapsackWindow,self.UpdateContentWithMsg)
	-- self:UnregisterEvent(messageGuids.CardRedDotChanged, self.RedDotStateUpdated)
 --    self:UnregisterEvent(messageGuids.ModuleRedDotChanged, self.RedDotStateUpdated)
     self:UnregisterEvent(messageGuids.LocalRedDotChanged, self.LocalRedDotChanged)
end

-----------------------------------------------------------------------
--- 网络处理
-----------------------------------------------------------------------


-----------------------------------------------------------------------
function KnapsackCls:RedDotStateQuery()
    -- 查询红点提示
    local S2CGuideRedResult = require "Network.PB.S2CGuideRedResult"
    local UserDataType = require "Framework.UserDataType"
    local RedDotData = self:GetCachedData(UserDataType.RedDotData)

    if RedDotData ~= nil then
        local backpacState = RedDotData:GetModuleRedState(S2CGuideRedResult.beibao_suipian)
        self.debrisRed:SetActive(backpacState == 1)
    end
end

function KnapsackCls:LocalRedDotChanged()
    local calculateRed = require"Utils.CalculateRed"
    self.debrisRed:SetActive(calculateRed.CalculateEquipDebrisCompound())
    self.itemRedDot:SetActive(calculateRed.CalculateItemCanOpen())
    
end
-----------------------------------------------------------------------
function KnapsackCls:LoadBagScrollContent()
	-- 加载背包滑动控件
	self.ScrollNode = require "GUI.Knapsack.ScrollNode".New(self.scrollTrans,self,self.OnItemClicked)
	self:AddChild(self.ScrollNode)
end

function KnapsackCls:OnItemClicked(itype,uid,id)
	debug_print("itype,uid,id",itype,uid,id)
	-- 背包点击
	self:ShowEquipWindow(itype,uid,id)
end

function KnapsackCls:UpdateContent(contentType)
 	-- 更新数据
	local UserDataType = require "Framework.UserDataType"
	local data,count

	if contentType == EquipPanelState then
		-- 普通装备
		
		local tempData = self:GetCachedData(UserDataType.EquipBagData)
    	data = tempData:RetrievalByResultFunc(function(item)
        local itemType = item:GetEquipType()
        	
        	if  itemType ~= KEquipType_EquipPet and itemType ~= KEquipType_EquipGem then
        		local uid = item:GetEquipUID()
        		return true,uid
        	end
       		return nil 
      	end)
  		count = data:Count()
	elseif contentType == ItemPanelState then
		-- 物品Item
		
		data = self:GetCachedData(UserDataType.ItemBagData):GetItemDict()
  		count = data:Count()
	elseif contentType == DebrisPanelState then
		-- 装备碎片

  		data = self:GetCachedData(UserDataType.EquipDebrisBag):GetItemDict()
  		count = data:Count()
	elseif contentType == PetPanelState then
		-- 宠物装备

    	local tempData = self:GetCachedData(UserDataType.EquipBagData)
    	data = tempData:RetrievalByResultFunc(function(item)
        local itemType = item:GetEquipType()

        	if  itemType == KEquipType_EquipPet then
        		local uid = item:GetEquipUID()
        		return true,uid
        	end
        	return nil 
      	end)
  		count = data:Count()
	end
	
	self.ScrollNode:UpdateScrollContent(count,data)
	self.ScrollNode:ResetVerticalOffset(1)
end

function KnapsackCls:FliterBagCallback(fliterType)
  -- 筛选回调
  
	self.fliterType = fliterType
	self:UpdataFliterTag(fliterType)

	if fliterType == KEquipType_EquipAll then
		self:UpdateContent(EquipPanelState)
	elseif  fliterType == KEquipType_EquipBind then
		self:OnFliterBindBag()
	else
		self:OnFliterBag(fliterType)
  	end
  	self.ScrollNode:ResetVerticalOffset(1)  
end

function KnapsackCls:OnFliterBag(fliterType)
  -- 筛选装备
  --self.currKnapsackType = EquipPanelState

  local UserDataType = require "Framework.UserDataType"
  local tempData = self:GetCachedData(UserDataType.EquipBagData)
  
  local data = tempData:RetrievalByResultFunc(function (item)
        local itemType = item:GetEquipType()

        if  itemType == fliterType then
          local uid = item:GetEquipUID()
          return true,uid
        end

        return nil 
  end)

  local count = data:Count()    
  self.ScrollNode:UpdateScrollContent(count,data)
end

function KnapsackCls:OnFliterBindBag()
	-- 刷新绑定的背包数据
	local UserDataType = require "Framework.UserDataType"
	local tempData = self:GetCachedData(UserDataType.EquipBagData)
  
	local data = tempData:RetrievalByResultFunc(function (item)
        local bindCardUID = item:GetBindCardUID()

        if  bindCardUID ~= "" then
          local uid = item:GetEquipUID()
          return true,uid
        end

        return nil 
	end)

	local count = data:Count()    
	self.ScrollNode:UpdateScrollContent(count,data)
end

function KnapsackCls:UpdataFliterTag(fliterType)
  -- 更新筛选标签
  local index
  if fliterType == KEquipType_EquipAll then
    index = 18
  elseif fliterType == KEquipType_EquipWeapon then
    index = 19
  elseif fliterType == KEquipType_EquipArmor then
    index = 20
  elseif fliterType == KEquipType_EquipAccessories then
    index = 21
  elseif fliterType == KEquipType_EquipShoesr then
    index = 22
  elseif fliterType == KEquipType_EquipFashion then
    index = 23
  elseif fliterType == KEquipType_EquipSpar then
    index = 37
  elseif fliterType == KEquipType_EquipBind then
    index = 38

  end

  self.fliterTagLabel.text = EquipStringTable[index]
  self.fliterType = fliterType
end
 
function KnapsackCls:ShowEquipWindow(itype,uid,id)
	-- 显示装备
	local gametool = require "Utils.GameTools"
	local windowManager = self:GetGame():GetWindowManager()

	if itype == KKnapsackItemType_EquipNormal then
		windowManager:Show(require "GUI.EquipmentWindow.EquipmentWindow",uid,id,KEquipWinShowType_BaseInfo)
	elseif itype == KKnapsackItemType_Item then
		local infoData,data,name,iconPath,itype = gametool.GetItemDataById(id)
		local useNum = data:GetCanUse()
		if useNum==5 then
			local windowManager = utility:GetGame():GetWindowManager()
	   		windowManager:Show(require "GUI.Knapsack.MaxNumberUsePanel",id)
		elseif useNum==6 then
			  local windowManager = utility:GetGame():GetWindowManager()
	   		windowManager:Show(require "GUI.CommonItemWin",id,true)
   	else
      local windowManager = utility:GetGame():GetWindowManager()
      windowManager:Show(require "GUI.CommonItemWin",id,false)
    end
	elseif itype == KKnapsackItemType_EquipDebris then
		windowManager:Show(require "GUI.EquipmentWindow.EquipmentWindow",uid,id,KEquipWinShowType_Combine,nil,true)
	end
end

function KnapsackCls:UpdateContentWithMsg(contentType,fliter)
	-- 消息更新内容
	print("消息更新内容",fliter,self.fliterType)
	if fliter then
		self:FliterBagCallback(self.fliterType)
	else
		self:UpdateContent(contentType)
	end
end

-----------------------------------------------------------------------
--- 状态管理
-----------------------------------------------------------------------
function KnapsackCls:StateChangeCtrl(state)
	-- 状态切换
	if self.currPanelState == state then		
		return 
	end

	if self.currPanelState ~= nil then
		self:OnPanelStateExit(self.currPanelState)
	end

	self:OnPanelStateEnter(state)
end

function KnapsackCls:OnPanelStateEnter(state)
	-- 状态进入

	if state == EquipPanelState then
		
		self:ChangeButtonTheme(self.BackpackEquipTagButton)
		self:OnEquipPanelStateEnter()

	elseif state == ItemPanelState then
		
		self:ChangeButtonTheme(self.BackpackItemTagButton)
		self:OnItemPanelStateEnter()

	elseif state == DebrisPanelState then
		
		self:ChangeButtonTheme(self.BackpackFragmentTagButton)
		self:OnDebrisPanelStateEnter()

	elseif state == PetPanelState then
		
		self:ChangeButtonTheme(self.BackpackPetTagButton)
		self:OnPetPanelStateEnter()

	end

	self:UpdateContent(state)
	self.currPanelState = state
end


function KnapsackCls:OnPanelStateExit(state)
	-- 状态退出

	if state == EquipPanelState then
		
	elseif state == ItemPanelState then
		
	elseif state == DebrisPanelState then

	elseif state == PetPanelState then

	end

	self.currPanelState = nil

end

local function SetComponentActive(obj,active)
	-- 设置对象显示状态
	obj.gameObject:SetActive(active)
end

function KnapsackCls:OnEquipPanelStateEnter()
	-- 装备Panel进入
	SetComponentActive(self.SellAllButton,true)
	SetComponentActive(self.BackpackFliterButton,true)
	self:UpdataFliterTag(KEquipType_EquipAll)
end

function KnapsackCls:OnItemPanelStateEnter()
	-- ItemPanel进入
	SetComponentActive(self.SellAllButton,false)
	SetComponentActive(self.BackpackFliterButton,false)
	self:UpdataFliterTag(KEquipType_EquipAll)
end

function KnapsackCls:OnDebrisPanelStateEnter()
	-- DebrisPanel进入
	SetComponentActive(self.SellAllButton,true)
	SetComponentActive(self.BackpackFliterButton,false)
	self:UpdataFliterTag(KEquipType_EquipAll)
end

function KnapsackCls:OnPetPanelStateEnter()
	-- PetPanel进入
	SetComponentActive(self.SellAllButton,false)
	SetComponentActive(self.BackpackFliterButton,false)
	self:UpdataFliterTag(KEquipType_EquipAll)
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------

function KnapsackCls:OnBackpackEquipTagButtonClicked()
	-- 装备
	self:StateChangeCtrl(EquipPanelState)
end

function KnapsackCls:OnBackpackItemTagButtonClicked()
	-- Item
	self:StateChangeCtrl(ItemPanelState)
end

function KnapsackCls:OnBackpackFragmentTagButtonClicked()
	-- 碎片
	self:StateChangeCtrl(DebrisPanelState)
end

function KnapsackCls:OnBackpackPetTagButtonClicked()
	-- 宠物
	self:StateChangeCtrl(PetPanelState)
end

function KnapsackCls:OnBackpackReturnButtonClicked()
	-- 返回
	self:Close()
end

function KnapsackCls:OnBackpackFliterButtonClicked()	
	-- 筛选
    local windowManager = self:GetGame():GetWindowManager()
    windowManager:Show(require "GUI.Knapsack.KnapsackFilter",self.fliterType,self,self.FliterBagCallback)
end

function KnapsackCls:OnSellAllButtonClicked()
	-- 批量出售
	print("批量出售")
	local windowManager = self:GetGame():GetWindowManager()
	windowManager:Show(require "GUI.Knapsack.KnapsackSell",self.currPanelState,self,self.UpdateContent)
end

------------------------------------------------------------------------
---  改变button 样式
------------------------------------------------------------------------
local function ChangePosition(object,offset)
	-- 改变组件位置
	local transform = object.transform
	local tempPosition = transform.localPosition
	tempPosition.x = tempPosition.x + offset
	object.transform.localPosition = tempPosition
end

local function SetLabelTheme(label,OnShow)
	--设置文字样式
	local outLine = label:GetComponent(typeof(UnityEngine.UI.Outline))
	if OnShow then
		label.fontSize = 45
		label.color = UnityEngine.Color(1,1,1,1)
		outLine.enabled = true
	else
		label.fontSize = 36
		label.color = UnityEngine.Color(0,0,0,1)
		outLine.enabled = false
	end
end 

function KnapsackCls:ChangeButtonTheme(targetButton)
	-- 更改button按钮选中主题
	local gameTool = require "Utils.GameTools"
	
	local buttonImage = targetButton.gameObject:GetComponent(typeof(UnityEngine.UI.Image))
	buttonImage.color = ButtonSelectedImageColor
	ChangePosition(targetButton,-30)
	local textLabel = targetButton.transform:Find('TextLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	SetLabelTheme(textLabel,true)

	if self.OnSelectButton ~= nil then
		local onSelectButtonImage = self.OnSelectButton.gameObject:GetComponent(typeof(UnityEngine.UI.Image))
		onSelectButtonImage.color = ButtonNormalImageColor
		ChangePosition(self.OnSelectButton,30)
		local textLabel = self.OnSelectButton.transform:Find('TextLabel'):GetComponent(typeof(UnityEngine.UI.Text))
		SetLabelTheme(textLabel,false)
	end

	self.OnSelectButton = targetButton
end

return KnapsackCls