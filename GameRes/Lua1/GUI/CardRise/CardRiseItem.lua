local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local CardRiseItemCls = Class(BaseNodeClass)

function CardRiseItemCls:Ctor(parent)
	self.parent = parent
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function CardRiseItemCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/MyGeneralItem', function(go)
		self:BindComponent(go,false)
	end)
end

function CardRiseItemCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()
end

function CardRiseItemCls:OnResume()
	-- 界面显示时调用
	CardRiseItemCls.base.OnResume(self)
	self:RegisterControlEvents()
end

function CardRiseItemCls:OnPause()
	-- 界面隐藏时调用
	CardRiseItemCls.base.OnPause(self)
	self:UnregisterControlEvents()
end

function CardRiseItemCls:OnEnter()
	-- Node Enter时调用
	CardRiseItemCls.base.OnEnter(self)
end

function CardRiseItemCls:OnExit()
	-- Node Exit时调用
	CardRiseItemCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function CardRiseItemCls:InitControls()
	local transform = self:GetUnityTransform()
	self.Base = transform:Find('ItemInfoButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.Icon = transform:Find('ItemIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	
	self.ItemNeedCountLabel = transform:Find('GeneralItemNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ItemNeedCountLabel.gameObject:SetActive(true)
	self.FrameTrans = transform:Find('Frame')
	self.colorImage = self.FrameTrans:Find('Image'):GetComponent(typeof(UnityEngine.UI.Image))
	self.myGame = utility:GetGame()
end


function CardRiseItemCls:RegisterControlEvents()
	self.__event_button_onBaseClicked__ = UnityEngine.Events.UnityAction(self.OnBaseClicked, self)
	self.Base.onClick:AddListener(self.__event_button_onBaseClicked__)
end

function CardRiseItemCls:UnregisterControlEvents()
	-- 取消注册 Base 的事件
	if self.__event_button_onBaseClicked__ then
		self.Base.onClick:RemoveListener(self.__event_button_onBaseClicked__)
		self.__event_button_onBaseClicked__ = nil
	end
end

function CardRiseItemCls:OnBaseClicked()
	utility.ShowSourceWin(self.id)
end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
local function SetItemGray(self)
	local graymaterial = utility:GetGrayMaterial()
	self.Icon.material = graymaterial
	self.ItemNeedCountLabel.material = graymaterial
	self.colorImage.material = graymaterial
end


local function DelayResetView(self,id,count)
	while (not self:IsReady()) do
		coroutine.step(1)
	end


	local gameTool = require "Utils.GameTools"

	local _,data,name,icon,itemType = gameTool.GetItemDataById(id)

	self.ItemNeedCountLabel.text = count
	
	utility.LoadSpriteFromPath(icon,self.Icon)
	-- 设置颜色
	local color = gameTool.GetItemColorByType(itemType,data)
	local PropUtility = require "Utils.PropUtility"
    PropUtility.AutoSetRGBColor(self.FrameTrans, color)

    local UserDataType = require "Framework.UserDataType"
  	local cardChipBagData = self:GetCachedData(UserDataType.EquipBagData)
    local hadCount = cardChipBagData:GetItemCountById(id)

    if tonumber(count) > tonumber(hadCount) then
    	SetItemGray(self)
    end
    
end


function CardRiseItemCls:ResetView(id,count)
	self.id = id
	-- coroutine.start(DelayResetView,self,id,count)
	self:StartCoroutine(DelayResetView, id,count)
end



return CardRiseItemCls