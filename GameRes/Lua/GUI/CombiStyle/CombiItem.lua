local BaseNodeClass = require "Framework.Base.Node"
local utility = require "Utils.Utility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local CombiItemCls = Class(BaseNodeClass)

function CombiItemCls:Ctor(roleId,parent)
	self.roleId=roleId
	self.parent=parent
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function CombiItemCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/CombiItem', function(go)
		self:BindComponent(go)
	end)
end

function CombiItemCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function CombiItemCls:OnResume()
	-- 界面显示时调用
	CombiItemCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
end

function CombiItemCls:OnPause()
	-- 界面隐藏时调用
	CombiItemCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function CombiItemCls:OnEnter()
	-- Node Enter时调用
	CombiItemCls.base.OnEnter(self)
end

function CombiItemCls:OnExit()
	-- Node Exit时调用
	CombiItemCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function CombiItemCls:InitControls()
	local transform = self:GetUnityTransform()
	transform:SetParent(self.parent)
	self.iconImage = transform:Find('Base/HeroCardItem'):GetComponent(typeof(UnityEngine.UI.Image))
	self.iconFrame=transform:Find('Base/Frame')
	self.raceIcon=transform:Find('Base/RaceIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ssrImage=transform:Find('Base/Rarity'):GetComponent(typeof(UnityEngine.UI.Image))
	self.nameText=transform:Find('Base/Name'):GetComponent(typeof(UnityEngine.UI.Text))
	self:InitViews()
end

function  CombiItemCls:InitViews(  )
	
	local roleData = require "StaticData.Role":GetData(self.roleId)
	--设置SSR
	local rarity = roleData:GetRarity()
	utility.LoadSpriteFromPath(rarity,self.ssrImage)
	utility.LoadRaceIcon(roleData:GetRace(),self.raceIcon)
	utility.LoadRoleHeadIcon(self.roleId, self.iconImage)
	local roleinfoData = require "StaticData.RoleInfo"


	self.nameText.text=roleinfoData:GetData(self.roleId):GetName()
	defaultColor=defaultColor

	local PropUtility = require "Utils.PropUtility"
    --    print("颜色 颜色 颜色 颜色", self.itemColor,self.ColorFrameGroupTrans)
    PropUtility.AutoSetRGBColor(self.iconFrame,roleData:GetColorID())
    local UserDataType = require "Framework.UserDataType"
    local cardBagData = self:GetCachedData(UserDataType.CardBagData)
	local userCardData = cardBagData:GetRoleById(self.roleId)
	if userCardData==nil then
		self.iconImage.material=utility:GetGrayMaterial()
	else
		self.iconImage.material=nil
	end



end


function CombiItemCls:RegisterControlEvents()
end

function CombiItemCls:UnregisterControlEvents()
end

function CombiItemCls:RegisterNetworkEvents()
end

function CombiItemCls:UnregisterNetworkEvents()
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
return CombiItemCls
