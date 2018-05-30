local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local messageGuids = require "Framework.Business.MessageGuids"

local MaxNumberUsePanelCls = Class(BaseNodeClass)

function MaxNumberUsePanelCls:Ctor(id)
	
end
function MaxNumberUsePanelCls:OnWillShow(id)
	self.id = id
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function MaxNumberUsePanelCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/MaxNumberUsePanel', function(go)
		self:BindComponent(go)
	end)
end

function MaxNumberUsePanelCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function MaxNumberUsePanelCls:OnResume()
	-- 界面显示时调用
	MaxNumberUsePanelCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:InitViews()
end

function MaxNumberUsePanelCls:OnPause()
	-- 界面隐藏时调用
	MaxNumberUsePanelCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function MaxNumberUsePanelCls:OnEnter()
	-- Node Enter时调用
	MaxNumberUsePanelCls.base.OnEnter(self)
end

function MaxNumberUsePanelCls:OnExit()
	-- Node Exit时调用
	MaxNumberUsePanelCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function MaxNumberUsePanelCls:InitControls()
	local transform = self:GetUnityTransform()
	self.TranslucentLayer = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))
	--名字
	self.ItemNameLable = transform:Find('Base/ItemNameLable'):GetComponent(typeof(UnityEngine.UI.Text))	
	--图标
	self.EquipIcon = transform:Find('Base/ItemBox/EquipIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	--边框
	self.Frame = transform:Find('Base/ColorFrame/Frame'):GetComponent(typeof(UnityEngine.UI.Image))
	--描述按钮
	self.StatusLabel = transform:Find('Base/StatusLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--使用按钮
	self.UseButton = transform:Find('Base/UseButton'):GetComponent(typeof(UnityEngine.UI.Button))
	--添加按钮
	self.AddButton = transform:Find('Base/AddButton'):GetComponent(typeof(UnityEngine.UI.RepeatButton))
	--减少按钮
	
	self.ReduceButton = transform:Find('Base/ReduceButton'):GetComponent(typeof(UnityEngine.UI.RepeatButton))
	--初始数量
	--self.NumberText = transform:Find('Base/BoxImage/NumberText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.InputField = transform:Find('Base/BoxImage/InputField'):GetComponent(typeof(UnityEngine.UI.InputField))

end
function MaxNumberUsePanelCls:InitViews()
	self.currentAddNum=1
	self.InputField.text=self.currentAddNum

	local gametool = require "Utils.GameTools"
	local PropUtility = require "Utils.PropUtility"

	local infoData,data,name,iconPath,itype = gametool.GetItemDataById(self.id)
	local color = gametool.GetItemColorByType(itype,data)
	
	PropUtility.AutoSetRGBColor(self.Frame,color)
	utility.LoadSpriteFromPath(iconPath,self.EquipIcon)
	self.ItemNameLable.text = name

	local desc 

	if itype == "RoleChip"  or itype == "EquipChip" then
		local name = infoData:GetName()
		desc = string.format("%s%s",ShopStringTable[5],name)
	else
		desc = infoData:GetDesc()
	end
	self.StatusLabel.text  = desc

	--获取当前物品最大个数
	local UserDataType = require "Framework.UserDataType"
	local itemCardData = self:GetCachedData(UserDataType.ItemBagData)
	self.maxItemNum=itemCardData:GetItemCountById(self.id)
	self.boxId = data:GetBoxId()
	

end

function MaxNumberUsePanelCls:RegisterControlEvents()
	-- 注册 TranslucentLayer 的事件
	self.__event_button_onTranslucentLayerClicked__ = UnityEngine.Events.UnityAction(self.OnTranslucentLayerClicked, self)
	self.TranslucentLayer.onClick:AddListener(self.__event_button_onTranslucentLayerClicked__)

	-- 注册 UseButton 的事件
	self.__event_button_onUseButtonClicked__ = UnityEngine.Events.UnityAction(self.OnUseButtonClicked, self)
	self.UseButton.onClick:AddListener(self.__event_button_onUseButtonClicked__)

	-- 注册 AddButton Repeat 的事件
	self.__event_button_onAddButtonRepeated__ = UnityEngine.Events.UnityAction(self.OnAddButtonRepeated, self)
	self.AddButton.m_OnRepeat:AddListener(self.__event_button_onAddButtonRepeated__)

		-- 注册 AddButton 的事件
	self.__event_button_onAddButtonClicked__ = UnityEngine.Events.UnityAction(self.OnAddButtonClicked, self)
	self.AddButton.onClick:AddListener(self.__event_button_onAddButtonClicked__)

	-- 注册 ReduceButton Repeat 的事件
	self.__event_button_onReduceButtonRepeated__ = UnityEngine.Events.UnityAction(self.OnReduceButtonRepeated, self)
	self.ReduceButton.m_OnRepeat:AddListener(self.__event_button_onReduceButtonRepeated__)

	-- 注册 ReduceButton 的事件
	self.__event_button_onReduceButtonClicked__ = UnityEngine.Events.UnityAction(self.OnReduceButtonClicked, self)
	self.ReduceButton.onClick:AddListener(self.__event_button_onReduceButtonClicked__)

	-- 注册 InputField 的事件
	self.__event_input_onInputFieldEndEdit__ = UnityEngine.Events.UnityAction_string(self.OnInputFieldEndEdit, self)
	self.InputField.onEndEdit:AddListener(self.__event_input_onInputFieldEndEdit__)

end

function MaxNumberUsePanelCls:UnregisterControlEvents()

	-- 取消注册 InputField 的事件
	if self.__event_input_onInputFieldEndEdit__ then
		self.InputField.onEndEdit:RemoveListener(self.__event_input_onInputFieldEndEdit__)
		self.__event_input_onInputFieldEndEdit__ = nil
	end

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


	-- 取消注册 AddButton m_OnRepeat 的事件
	if self.__event_button_onAddButtonRepeated__ then
		self.AddButton.m_OnRepeat:RemoveListener(self.__event_button_onAddButtonRepeated__)
		self.__event_button_onAddButtonRepeated__ = nil
	end

	-- 取消注册 ReduceButton  m_OnRepeat的事件
	if self.__event_button_onReduceButtonRepeated__ then
		self.ReduceButton.m_OnRepeat:RemoveListener(self.__event_button_onReduceButtonRepeated__)
		self.__event_button_onReduceButtonRepeated__ = nil
	end

end


function MaxNumberUsePanelCls:RegisterNetworkEvents()
	utility:GetGame():RegisterMsgHandler(net.S2COpenTreasureChestRewardResult,self,self.OpenTreasureChestRewardResult)
end

function MaxNumberUsePanelCls:UnregisterNetworkEvents()
	utility:GetGame():UnRegisterMsgHandler(net.S2COpenTreasureChestRewardResult,self,self.OpenTreasureChestRewardResult)
end

function MaxNumberUsePanelCls:OnInputFieldEndEdit()
	local inputNum =tonumber( self.InputField.text)
	if inputNum>self.maxItemNum then
		self.InputField.text = self.maxItemNum
		self.currentAddNum = self.maxItemNum
	end
	hzj_print("OnInputFieldEndEdit")

end

function MaxNumberUsePanelCls:OpenTreasureChestRewardResult(msg)

	if msg.status then
		self:DispatchEvent(messageGuids.UpdataKnapsackWindow,nil,KKnapsackItemType_Item)

		-- local itemstables = {}
		-- for i=1,#msg.openTreasureChestReward do
		-- 	itemstables[#itemstables+1] = {}
		-- 	itemstables[#itemstables].id=msg.openTreasureChestReward[i].itemID
		-- 	itemstables[#itemstables].count=msg.openTreasureChestReward[i].itemNum
		-- 	itemstables[#itemstables].color=msg.openTreasureChestReward[i].itemColor
		-- end
		-- -- local windowManager = self:GetGame():GetWindowManager()
	 --    local AwardCls = require "GUI.Task.GetAwardItem"
	 --    windowManager:Show(AwardCls,itemstables)

	    local windowManager = utility:GetGame():GetWindowManager()
   		windowManager:Show(require "GUI.Tower.TowerSweepAward",msg.openTreasureChestReward,3)
	end
	self:Close()

end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
local function ShowNormalDialog(self,str)
	local windowManager = utility.GetGame():GetWindowManager()
  	local ConfirmDialogClass = require "GUI.Dialogs.NormalDialog"	
 	windowManager:Show(ConfirmDialogClass, str)
end
function MaxNumberUsePanelCls:OnTranslucentLayerClicked()
	--TranslucentLayer控件的点击事件处理
	self:Close()
end

function MaxNumberUsePanelCls:OnUseButtonClicked()
	--UseButton控件的点击事件处理
	if self.currentAddNum ==0 then
		ShowNormalDialog(self,"个数为"..self.currentAddNum.."无法打开")
	else
		local inputNum =tonumber( self.InputField.text)
		self.currentAddNum = inputNum
		if inputNum>self.maxItemNum then
			self.InputField.text = self.maxItemNum
			self.currentAddNum = self.maxItemNum
		end

		utility:GetGame():SendNetworkMessage( require"Network/ServerService".OpenTreasureChestRewardRequest(0,self.id,self.currentAddNum))
		debug_print("请求打开")
	end
end


function MaxNumberUsePanelCls:OnAddButtonClicked()
	--AddButton控件的点击事件处理
	--debug_print("OnAddButtonClicked")
	self:AddNum()
end

function MaxNumberUsePanelCls:OnReduceButtonClicked()
	--ReduceButton控件的点击事件处理
	--debug_print("OnReduceButtonClicked")
	self:ReduceNum()
end


function MaxNumberUsePanelCls:OnAddButtonRepeated()
	--AddButton控件的点击事件处理
	--debug_print("OnAddButtonRepeated")
	self:AddNum()
end

function MaxNumberUsePanelCls:OnReduceButtonRepeated()
	--ReduceButton控件的点击事件处理
	--debug_print("OnReduceButtonRepeated")
	self:ReduceNum()
end
function MaxNumberUsePanelCls:AddNum()
	if self.currentAddNum== self.maxItemNum then
		
 	else
 		self.currentAddNum=self.currentAddNum+1
 		self.NumberText.text=self.currentAddNum
	end
	
end

function MaxNumberUsePanelCls:ReduceNum()
	if self.currentAddNum== 0 then
		
 	else
 		self.currentAddNum=self.currentAddNum-1 		
 		self.NumberText.text=self.currentAddNum
	end
end

return MaxNumberUsePanelCls
