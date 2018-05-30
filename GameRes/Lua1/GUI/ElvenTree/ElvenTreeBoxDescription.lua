local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local ElvenTreeBoxDescriptionCls = Class(BaseNodeClass)

function ElvenTreeBoxDescriptionCls:Ctor(itemID,itemColor,itemNum)

end
function ElvenTreeBoxDescriptionCls:OnWillShow(itemID,itemColor,itemNum)
	self.itemNum=itemNum
	self.itemID=itemID
	self.itemColor=itemColor
	print(self.itemID)
	end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function ElvenTreeBoxDescriptionCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/ElvenTreeBoxDescription', function(go)
		self:BindComponent(go)
	end)
end

function ElvenTreeBoxDescriptionCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function ElvenTreeBoxDescriptionCls:OnResume()
	-- 界面显示时调用
	ElvenTreeBoxDescriptionCls.base.OnResume(self)
	self:RegisterControlEvents()
		self:InitViews()
--	self:RegisterNetworkEvents()
end

function ElvenTreeBoxDescriptionCls:OnPause()
	-- 界面隐藏时调用
	ElvenTreeBoxDescriptionCls.base.OnPause(self)
	self:UnregisterControlEvents()
--	self:UnregisterNetworkEvents()
end

function ElvenTreeBoxDescriptionCls:OnEnter()
	-- Node Enter时调用
	ElvenTreeBoxDescriptionCls.base.OnEnter(self)
end

function ElvenTreeBoxDescriptionCls:OnExit()
	-- Node Exit时调用
	ElvenTreeBoxDescriptionCls.base.OnExit(self)
end
function ElvenTreeBoxDescriptionCls:InitViews()
	local AtlasesLoader = require "Utils.AtlasesLoader"
  	local GameTools = require "Utils.GameTools"
  	print(self.itemID)
    local _,data,itemName,iconPath,itemTypeStr = GameTools.GetItemDataById(self.itemID)
    -- 设置图标
	utility.LoadSpriteFromPath(iconPath,self.ItemIcon)

    if self.itemColor==-1 then
    	self.itemColor=GameTools.GetItemColorByType(itemTypeStr,data)
    	end
    -- 设置颜色
    local PropUtility = require "Utils.PropUtility"
    --print("颜色 颜色 颜色 颜色", self.itemColor)
    PropUtility.AutoSetRGBColor(self.ColorFrameGroupTrans, self.itemColor)
    self.ItemNameLable.text=itemName--.."      X"..self.itemNum
    self.ItemNumLabel.text="x"..self.itemNum
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function ElvenTreeBoxDescriptionCls:InitControls()
	local transform = self:GetUnityTransform()

	self.ElvenTreeDescriptionButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ItemNameLable = transform:Find('ItemBox/ItemNameLable'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ItemNumLabel = transform:Find('ItemBox/Itemname/ItemNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
 	self.ColorFrameGroupTrans = transform:Find("ItemBox/Base")
	self.ItemIcon=transform:Find("ItemBox/EquipIcon"):GetComponent(typeof(UnityEngine.UI.Image))
	self:InitViews()
 

end


function ElvenTreeBoxDescriptionCls:RegisterControlEvents()
	-- 注册 ElvenTreeDescriptionButton 的事件
	self.__event_button_onElvenTreeDescriptionButtonClicked__ = UnityEngine.Events.UnityAction(self.OnElvenTreeDescriptionButtonClicked, self)
	self.ElvenTreeDescriptionButton.onClick:AddListener(self.__event_button_onElvenTreeDescriptionButtonClicked__)

end

function ElvenTreeBoxDescriptionCls:UnregisterControlEvents()
	-- 取消注册 ElvenTreeDescriptionButton 的事件
	if self.__event_button_onElvenTreeDescriptionButtonClicked__ then
		self.ElvenTreeDescriptionButton.onClick:RemoveListener(self.__event_button_onElvenTreeDescriptionButtonClicked__)
		self.__event_button_onElvenTreeDescriptionButtonClicked__ = nil
	end

end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function ElvenTreeBoxDescriptionCls:OnElvenTreeDescriptionButtonClicked()
	self:Hide()
end

return ElvenTreeBoxDescriptionCls

