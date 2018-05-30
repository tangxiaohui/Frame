local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "LUT.StringTable"
local SkinIconItem = Class(BaseNodeClass)

function SkinIconItem:Ctor(parent,id)
	self.parent = parent
	self.id = id
end


-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function SkinIconItem:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/NewCardSkinIcon', function(go)
		self:BindComponent(go,false)
	end)
end

function SkinIconItem:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()
end

function SkinIconItem:OnResume()
	-- 界面显示时调用
	SkinIconItem.base.OnResume(self)
	self:LoadItem(self.id)
end

function SkinIconItem:OnPause()
	-- 界面隐藏时调用
	SkinIconItem.base.OnPause(self)
end

function SkinIconItem:OnEnter()
	-- Node Enter时调用
	SkinIconItem.base.OnEnter(self)
end

function SkinIconItem:OnExit()
	-- Node Exit时调用
	SkinIconItem.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function SkinIconItem:InitControls()
	local transform = self:GetUnityTransform()
	
	self.icon = transform:Find("Base/Icon"):GetComponent(typeof(UnityEngine.UI.Image))
	self.frame = transform:Find("Frame"):GetComponent(typeof(UnityEngine.UI.Image))
	self.rarity = transform:Find("Rarity"):GetComponent(typeof(UnityEngine.UI.Image))
end

function SkinIconItem:LoadItem(id)
	local skinData = require "StaticData.CardSkin.Skin":GetData(id)
	local rarity = skinData:GetRarity(skinData:GetColor())
	utility.LoadSpriteFromPath(rarity,self.rarity)
	local skinIcon = skinData:GetSkinicon()
	utility.LoadSpriteFromPath(skinIcon,self.icon)
	local color = skinData:GetColor()
	local PropUtility = require "Utils.PropUtility"
	self.frame.color = PropUtility.GetRGBColorValue(color)
end


return SkinIconItem