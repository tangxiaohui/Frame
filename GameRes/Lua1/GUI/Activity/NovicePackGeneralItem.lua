local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local NovicePackGeneralItemCls = Class(BaseNodeClass)

function NovicePackGeneralItemCls:Ctor(parent,itemID,itemNum)
	self.Parent=parent
	self.itemID=itemID
	self.itemNum=itemNum
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function NovicePackGeneralItemCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/NovicePackGeneralItem', function(go)
		self:BindComponent(go)
	end)
end

function NovicePackGeneralItemCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
	self:InitViews(self.itemID,self.itemNum)
end

function NovicePackGeneralItemCls:OnResume()
	-- 界面显示时调用
	NovicePackGeneralItemCls.base.OnResume(self)
	self:RegisterControlEvents()

--	self:RegisterNetworkEvents()
end

function NovicePackGeneralItemCls:OnPause()
	-- 界面隐藏时调用
	NovicePackGeneralItemCls.base.OnPause(self)
	self:UnregisterControlEvents()
--	self:UnregisterNetworkEvents()
end

function NovicePackGeneralItemCls:OnEnter()
	-- Node Enter时调用
	NovicePackGeneralItemCls.base.OnEnter(self)
end

function NovicePackGeneralItemCls:OnExit()
	-- Node Exit时调用
	NovicePackGeneralItemCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function NovicePackGeneralItemCls:InitControls()
	local transform = self:GetUnityTransform()
	self.game = utility.GetGame()
	self.GeneralItemIcon1 = transform:Find('GeneralItemIcon1'):GetComponent(typeof(UnityEngine.UI.Image))	
	self.DebrisIcon = transform:Find('DebrisIcon').gameObject
	self.DebrisCorner = transform:Find('DebrisCorner').gameObject
	self.GeneralItemNumLabel1 = transform:Find('GeneralItemNumLabel1'):GetComponent(typeof(UnityEngine.UI.Text))
	self.GeneralItemButton = transform:Find('GeneralItemIcon1'):GetComponent(typeof(UnityEngine.UI.Button))	

	self.colorTrans=transform:Find('Frame')
	self.DebrisIcon.gameObject:SetActive(false)
	self.DebrisCorner.gameObject:SetActive(false)

	transform:SetParent(self.Parent)

	
end

function  NovicePackGeneralItemCls:InitViews(itemID,itemNum)
	--self.tables=tables
	print(itemID,itemNum,"+++++++++++++++++")
--	local noviceItem = require"StaticData/Activity/OnlineTimeAward":GetData(self.tables.index)
	
	self.itemID=itemID
	self.itemNum=itemNum

	local infData 
	local data
	local itemName
	local iconPath
	local itemTypeStr
	local gameTool = require "Utils.GameTools"
	infData,data,itemName,iconPath ,itemTypeStr= gameTool.GetItemDataById(self.itemID)
	utility.LoadSpriteFromPath(iconPath,self.GeneralItemIcon1)
	self.GeneralItemNumLabel1.text=self.itemNum
	local itemColor=gameTool.GetItemColorByType(itemTypeStr,data)

	if itemColor~=nil then
		local PropUtility = require "Utils.PropUtility"
   	    PropUtility.AutoSetRGBColor(self.colorTrans, itemColor)
	end
	 -- 显示/隐藏 碎片图标 --
    if itemTypeStr == "RoleChip" or  itemTypeStr == "EquipChip" then
        self.DebrisIcon:SetActive(true)
        self.DebrisCorner:SetActive(true)
    else
    	self.DebrisIcon:SetActive(false)
        self.DebrisCorner:SetActive(false)
    end
	

end



function NovicePackGeneralItemCls:RegisterControlEvents()
	-- 注册 GeneralItemButton 的事件
	self.__event_button_onGeneralItemButtonClicked__ = UnityEngine.Events.UnityAction(self.GeneralItemButtonClick, self)
	self.GeneralItemButton.onClick:AddListener(self.__event_button_onGeneralItemButtonClicked__)
end

function NovicePackGeneralItemCls:UnregisterControlEvents()
	if self.__event_button_onGeneralItemButtonClicked__ then
		self.GeneralItemButton.onClick:RemoveListener(self.__event_button_onGeneralItemButtonClicked__)
		self.__event_button_onGeneralItemButtonClicked__ = nil
	end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------

function NovicePackGeneralItemCls:GeneralItemButtonClick( )

	local gameTool = require "Utils.GameTools"
		gameTool.ShowItemWin(self.itemID)
end



return NovicePackGeneralItemCls