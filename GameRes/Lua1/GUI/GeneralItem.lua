local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local ItemInfoData = require "StaticData.ItemInfo"
local ItemData = require "StaticData.Item"
local EquipData = require "StaticData.Equip"
local EquipCrap = require "StaticData.EquipCrap"
local Item = require "StaticData.Item"

-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local GeneralItemCls = Class(BaseNodeClass)

function GeneralItemCls:Ctor(Parent,ItemData1,Itemtype)
	self.Parent = Parent
	self.Itemtype = Itemtype
	self.Ischeck = false
	self.ItemInfo = {}
	if self.Itemtype == "Item" then
		self.ItemInfo.itemID = ItemData1.itemID
		self.ItemInfo.itemNum = ItemData1.itemNum
		self.ItemInfo.itemUID = ItemData1.itemUID
	end
	if self.Itemtype == "Equip" then
		self.ItemInfo.equipUID = ItemData1.equipUID
		self.ItemInfo.equipID = ItemData1.equipID
		self.ItemInfo.level = ItemData1.level
		self.ItemInfo.pos = ItemData1.pos --位置信息[1,5]
		self.ItemInfo.bindCardUID = ItemData1.bindCardUID --所绑定的卡牌的uid 
		self.ItemInfo.onWhichCard = ItemData1.onWhichCard --穿在哪个卡牌身上 没穿则为空
		self.ItemInfo.exp = ItemData1.exp --只对翅膀
		self.ItemInfo.color = ItemData1.color --只对翅膀
		self.ItemInfo.stoneID = ItemData1.stoneID -- 宝石ID
		self.ItemInfo.stoneUID = ItemData1.stoneUID --宝石UID
		print(self.ItemInfo.color,"颜色")
	end
	if self.Itemtype == "Debris" then
		self.ItemInfo.equipSuipianID = ItemData1.equipSuipianID
		self.ItemInfo.number = ItemData1.number
	end
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function GeneralItemCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/GeneralItem', function(go)
		self:BindComponent(go,false)
	end)
end

function GeneralItemCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.Parent)
	self:InitControls()
end

function GeneralItemCls:OnResume()
	-- 界面显示时调用
	GeneralItemCls.base.OnResume(self)
	self:AddObserver()
	self:RegisterControlEvents()
	self:LoadImageByID() -- 加载图片
	self:SetColor() -- 设置装备颜色
	self:SetNumText() -- 设置
	self:SetNum()
	self:xianshijinbi()
end

function GeneralItemCls:OnPause()
	-- 界面隐藏时调用
	GeneralItemCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:RemoveObserver()
	--self:UnregisterNetworkEvents()
end

function GeneralItemCls:OnEnter()
	-- Node Enter时调用
	GeneralItemCls.base.OnEnter(self)
end

function GeneralItemCls:OnExit()
	-- Node Exit时调用
	GeneralItemCls.base.OnExit(self)
end
function GeneralItemCls:AddObserver()
	self:RegisterEvent('ChangeItemEquipPosition',self.SetItemActive)
	self:RegisterEvent('ChangeItemItemsPosition',self.SetItemActive)
	self:RegisterEvent('ChangeItemSuipianPosition',self.SetItemActive)
end
function GeneralItemCls:RemoveObserver()
	self:UnregisterEvent('ChangeItemEquipPosition',self.SetItemActive)
	self:UnregisterEvent('ChangeItemItemsPosition',self.SetItemActive)
	self:UnregisterEvent('ChangeItemSuipianPosition',self.SetItemActive)
end
function GeneralItemCls:SetItemActive(msg)

	-- print("坐标")
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function GeneralItemCls:InitControls()
	local transform = self:GetUnityTransform()
	self.game = utility.GetGame()
	self.Base = transform:Find('Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ItemIcon = transform:Find('ItemIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Color00 = transform:Find('Frame/Color00')  --1  白
	self.Color01 = transform:Find('Frame/Color01')  --2  绿
	self.Color02 = transform:Find('Frame/Color02')  --3  蓝
	self.Color03 = transform:Find('Frame/Color03')  --4  紫
	self.Color04 = transform:Find('Frame/Color04')  --5  褐
	self.Color05 = transform:Find('Frame/Color05')  --6  红
	self.Color06 = transform:Find('Frame/Color06')  --7  黑
	self.ItemInfoButton = transform:Find('ItemInfoButton'):GetComponent(typeof(UnityEngine.UI.Button)) -- item信息Button

	self.BackpackSellItem = {}  --批量出售选中
	self.BackpackSellItemSelected = transform:Find('BackpackSellItem/BackpackSellItemSelected') -- item出售选中

	self.BackpackSellItem.BackpackSellItemValueNumLabel = transform:Find('BackpackSellItem/BackpackSellItemValueNumLabel'):GetComponent(typeof(UnityEngine.UI.Text)) -- item出售金币显示
	self.BackpackSellItem.BackpackSellItemGoldIcon = transform:Find('BackpackSellItem/BackpackSellItemGoldIcon'):GetComponent(typeof(UnityEngine.UI.Image)) -- item出售金币图片
	self.BackpackSellItem.BackpackSellItemNumLabel = transform:Find('BackpackSellItem/BackpackSellItemNumLabel'):GetComponent(typeof(UnityEngine.UI.Text)) -- item出售数量显示
	self.BackpackSellItem.BackpackSellButton = transform:Find('BackpackSellItem/BackpackSellButton'):GetComponent(typeof(UnityEngine.UI.Button)) -- item出售选中按钮显示

	self.GeneralItemNumLabel = transform:Find('GeneralItemNumLabel'):GetComponent(typeof(UnityEngine.UI.Text)) -- 物品显示数量
	self.ColorList ={[1] = self.Color00,[2] = self.Color01,[3] = self.Color02,[4] = self.Color03,[5] = self.Color04,[6] = self.Color05,[7] = self.Color06}
					 --   白                     绿                  蓝                      紫                   橙                  红              黑
end

function GeneralItemCls:LoadImageByID()
	local ImagePath
	if self.Itemtype == "Equip" then
		local name = EquipData:GetData(self.ItemInfo.equipID):GetIcon()
		ImagePath = string.format("UI/Textures/Equip/aboluo", name)
	elseif self.Itemtype == "Item" then
		local name = ItemData:GetData(self.ItemInfo.itemID):GetResourceID()
		ImagePath = string.format("UI/Atlases/Icon/%s", name) -- 道具图片路径
	else 
	--	local name = EquipInfoData:GetData(self.equipID):GetIcon()
	--	ImagePath = string.format("UI/Atlases/Icon/%s", name) -- 碎片图片路径
	end
	if ImagePath == nil then
		return false
	end
	
	utility.LoadSpriteFromPath("UI/Textures/Equip/aboluo",self.ItemIcon)
    
end

function GeneralItemCls:SetColor()
	local ColorNumber
	if self.Itemtype == "Debris" then
		for i=1,7 do
		self.ColorList[i].gameObject:SetActive(false)
		end
		ColorNumber = 1
	end
	if self.Itemtype == "Equip" then
		local ColorInt = EquipData:GetData(self.ItemInfo.equipID):GetColorID()
		ColorNumber = ColorInt
	end
	if self.Itemtype == "Item" then
		local ColorInt = ItemData:GetData(self.ItemInfo.itemID):GetColor()
		ColorNumber = ColorInt
	end
	for i=1,7 do
		self.ColorList[i].gameObject:SetActive(false)
	end
	self.ColorList[ColorNumber].gameObject:SetActive(true)
end

function GeneralItemCls:SetNumText()
	if self.Itemtype == "Equip" then
		self.GeneralItemNumLabel.gameObject:SetActive(false)
		return false
	else 
		self.GeneralItemNumLabel.text = tostring(self.itemNum)
	end
end

function GeneralItemCls:SetSell(IsOpenSell)
	self.ItemInfoButton.gameObject:SetActive(not IsOpenSell)
	self.BackpackSellItem.BackpackSellItemGoldIcon.gameObject:SetActive(IsOpenSell)
	self.BackpackSellItem.BackpackSellItemValueNumLabel.gameObject:SetActive(IsOpenSell)
	self.BackpackSellItem.BackpackSellButton.gameObject:SetActive(IsOpenSell)
	return self.ItemInfo
end


function GeneralItemCls:SetNum()
	if self.Itemtype == "Equip" then
		self.GeneralItemNumLabel.gameObject:SetActive(false)
	end
	if self.Itemtype == "Debris" then
		self.GeneralItemNumLabel.gameObject:SetActive(true)
		self.GeneralItemNumLabel.text = self.ItemInfo.number
	end
	if self.Itemtype == "Item" then
	--	if ---------------------------------------------------------------------------------------------------------------------------------------
		self.GeneralItemNumLabel.gameObject:SetActive(true)
		self.GeneralItemNumLabel.text = self.ItemInfo.number
	end
end

function GeneralItemCls:xianshijinbi()
	--只有装备碎片可以出售
	if self.Itemtype == "Equip" then
		self.BackpackSellItem.BackpackSellItemValueNumLabel.text = EquipData:GetData(self.ItemInfo.equipID):GetBasePrice()
	end
	if self.Itemtype == "Debris" then
		self.BackpackSellItem.BackpackSellItemValueNumLabel.text = EquipCrap:GetData(self.ItemInfo.equipSuipianID):GetSellPrice()
	end
end

function GeneralItemCls:IsOpen()
	return self.Ischeck
end

function GeneralItemCls:GetBasePrice()
	if self.Itemtype == "Equip" then
		return EquipData:GetData(self.ItemInfo.equipID):GetBasePrice()
	end
	if self.Itemtype == "Debris" then

		return EquipCrap:GetData(self.ItemInfo.equipSuipianID):GetSellPrice()
	end
end
function GeneralItemCls:EquipInfoReturnType()
	return EquipData:GetData(self.ItemInfo.equipID):GetType()
end

function GeneralItemCls:ReturnInfo()
	return self.ItemInfo
end
function GeneralItemCls:SetChecked(Checked)
	self.Ischeck = false
	self.BackpackSellItemSelected.gameObject:SetActive(Checked)
end

function GeneralItemCls:RegisterControlEvents()
	-- 注册 BackpackRetrunButton 的事件
	self.__event_button_onBackpackSellButtonButtonClicked__ = UnityEngine.Events.UnityAction(self.duoxuan, self)
	self.BackpackSellItem.BackpackSellButton.onClick:AddListener(self.__event_button_onBackpackSellButtonButtonClicked__)

	-- 注册 BackpackRetrunButton 的事件
	self.__event_button_onItemInfoButtonButtonClicked__ = UnityEngine.Events.UnityAction(self.Info, self)
	self.ItemInfoButton.onClick:AddListener(self.__event_button_onItemInfoButtonButtonClicked__)
end

function GeneralItemCls:UnregisterControlEvents()
	-- 取消注册 BackpackRetrunButton 的事件
	if self.__event_button_onBackpackSellButtonButtonClicked__ then
		self.BackpackSellItem.BackpackSellButton.onClick:RemoveListener(self.__event_button_onBackpackSellButtonButtonClicked__)
		self.__event_button_onBackpackSellButtonButtonClicked__ = nil
	end

	-- 取消注册 BackpackRetrunButton 的事件
	if self.__event_button_onItemInfoButtonButtonClicked__ then
		self.ItemInfoButton.onClick:RemoveListener(self.__event_button_onItemInfoButtonButtonClicked__)
		self.__event_button_onItemInfoButtonButtonClicked__ = nil
	end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function GeneralItemCls:duoxuan()
	if not self.Ischeck then
		self.BackpackSellItemSelected.gameObject:SetActive(true)
		self.Ischeck = true
	else
		self.BackpackSellItemSelected.gameObject:SetActive(false)
		self.Ischeck = false
	end
end

function GeneralItemCls:Info()
 	if self.Itemtype == "Equip" then
 		local windowManager = self.game:GetWindowManager()
  	    windowManager:Show(require "GUI.BackpackEquipmentInformation","Bagpack",self.ItemInfo.equipID)
 	end
 	if self.Itemtype == "Item" then
		local windowManager = self.game:GetWindowManager()
  		windowManager:Show(require "GUI.BackpackItemInformation")
 	end
end
return GeneralItemCls