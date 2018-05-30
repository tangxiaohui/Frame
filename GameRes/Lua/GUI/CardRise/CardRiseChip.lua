local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "System.LuaDelegate"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local FormationItemCls = Class(BaseNodeClass)

function FormationItemCls:Ctor(parent)
	self.parent = parent
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function FormationItemCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/MyGeneralItem', function(go)
		self:BindComponent(go,false)
	end)
end

function FormationItemCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()
end

function FormationItemCls:OnResume()
	-- 界面显示时调用
	FormationItemCls.base.OnResume(self)
	self:RegisterControlEvents()
	--self:RegisterNetworkEvents()
end

function FormationItemCls:OnPause()
	-- 界面隐藏时调用
	FormationItemCls.base.OnPause(self)
	self:UnregisterControlEvents()
	--self:UnregisterNetworkEvents()
end

function FormationItemCls:OnEnter()
	-- Node Enter时调用
	FormationItemCls.base.OnEnter(self)
end

function FormationItemCls:OnExit()
	-- Node Exit时调用
	FormationItemCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function FormationItemCls:InitControls()
	local transform = self:GetUnityTransform()
	self.Base = transform:Find('ItemInfoButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.Icon = transform:Find('ItemIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	
	self.ItemNeedCountLabel = transform:Find('GeneralItemNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ItemNeedCountLabel.gameObject:SetActive(true)

	self.FrameTrans = transform:Find('Frame')
	self.colorImage = self.FrameTrans:Find('Image'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ChipTrans = transform:Find('DebrisCorner').gameObject
	self.ChipBase = transform:Find("DebrisIcon").gameObject
	self.ChipBase:SetActive(true)
	self.ChipTrans:SetActive(true)

	self.myGame = utility:GetGame()
end


function FormationItemCls:RegisterControlEvents()
	-- 注册 Base 的事件
	self.__event_button_onBaseClicked__ = UnityEngine.Events.UnityAction(self.OnBaseClicked, self)
	self.Base.onClick:AddListener(self.__event_button_onBaseClicked__)
end

function FormationItemCls:UnregisterControlEvents()
	-- 取消注册 Base 的事件
	if self.__event_button_onBaseClicked__ then
		self.Base.onClick:RemoveListener(self.__event_button_onBaseClicked__)
		self.__event_button_onBaseClicked__ = nil
	end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function FormationItemCls:OnBaseClicked()
	--Base控件的点击事件处理
	local id = self.cardData:GetScrapId()
	utility.ShowSourceWin(id)
end


------------------------------------------------------------------------
local function SetItemGray(self)
	local graymaterial = utility:GetGrayMaterial()
	self.Icon.material = graymaterial
	self.ItemNeedCountLabel.material = graymaterial
	self.ChipTrans.transform:GetComponent(typeof(UnityEngine.UI.Image)).material = graymaterial
	self.ChipBase.transform:GetComponent(typeof(UnityEngine.UI.Image)).material = graymaterial
	self.colorImage.material = graymaterial
end


local function DelayResetView(self,cardData,count)
	while (not self:IsReady()) do
		coroutine.step(1)
	end

	local gameTool = require "Utils.GameTools"

	local id = cardData:GetId()
	local _,data,name,icon,itemType = gameTool.GetItemDataById(id)

	--self.NameLabel.text = name
	
	-- TODO : string
	local UserDataType = require "Framework.UserDataType"

  
 --   local fragmentBagData = self:GetCachedData(UserDataType.CardChipBagData)
  	local cardChipBagData = self:GetCachedData(UserDataType.CardChipBagData)

    local currentFragments = cardChipBagData:GetCardChipCount(self.cardData:GetScrapId())
	self.ItemNeedCountLabel.text = string.format("%s/%s",currentFragments,count)

	utility.LoadSpriteFromPath(icon,self.Icon)

	-- 设置颜色
	local color = gameTool.GetItemColorByType(itemType,data)
	local PropUtility = require "Utils.PropUtility"
    PropUtility.AutoSetRGBColor(self.FrameTrans, color)

    local debrisID = cardData:GetStaticData():GetScrapId()
   -- local UserDataType = require "Framework.UserDataType"
    local hadCount = cardChipBagData:GetCardChipCount(debrisID)

    if tonumber(count) > tonumber(hadCount) then
    	SetItemGray(self)
    end
end

function FormationItemCls:ResetView(cardData,count)
	-- 刷新显示
	self.cardData = cardData
	-- coroutine.start(DelayResetView,self,cardData,count)
	self:StartCoroutine(DelayResetView, cardData,count)
end




return FormationItemCls