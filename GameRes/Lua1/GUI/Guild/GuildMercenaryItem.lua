local BaseNodeClass = require "Framework.Base.UIScene"
local utility = require "Utils.Utility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local GuildMercenaryItemCls = Class(BaseNodeClass)
local RoleData = require "StaticData.Role"
local RoleInfoData = require "StaticData.RoleInfo"
local GuildCommonFunc = require "GUI/Guild/GuildCommonFunc"

function GuildMercenaryItemCls:Ctor(parent, gyjInfo)
	self.parent = parent
	self.gyjInfo = gyjInfo
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function GuildMercenaryItemCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/GuildMercenaryItem', function(go)
		self:BindComponent(go, false)
	end)
end

function GuildMercenaryItemCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
	self:LinkComponent(self.parent)
end

function GuildMercenaryItemCls:OnResume()
	-- 界面显示时调用
	GuildMercenaryItemCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
end

function GuildMercenaryItemCls:OnPause()
	-- 界面隐藏时调用
	GuildMercenaryItemCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function GuildMercenaryItemCls:OnEnter()
	-- Node Enter时调用
	GuildMercenaryItemCls.base.OnEnter(self)
end

function GuildMercenaryItemCls:OnExit()
	-- Node Exit时调用
	GuildMercenaryItemCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function GuildMercenaryItemCls:InitControls()
	local transform = self:GetUnityTransform()
	self.Frame = transform:Find('Frame'):GetComponent(typeof(UnityEngine.UI.Image))
	self.CharacterIcon = transform:Find('CharacterIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.TypeIcon = transform:Find('TypeIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.NeoCardInfoLevelLabel = transform:Find('LevelBase/NeoCardInfoLevelLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.CardNameLabel = transform:Find('CardNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Icon = transform:Find('Icon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.PriceLabel = transform:Find('PriceLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.RankStarIcon = {}
	for i=1,5 do
		self.RankStarIcon[i] = transform:Find('CharacterRank/RankStarIcon'..i)
	end
	self.RarityImage = transform:Find("Rarity"):GetComponent(typeof(UnityEngine.UI.Image))
	self:InitView()
end

function GuildMercenaryItemCls:InitView()
	local cardExl = RoleData:GetData(self.gyjInfo.cardID)
	self.Frame.color = require "Utils.PropUtility".GetColorValue(self.gyjInfo.cardColor)
	self.NeoCardInfoLevelLabel.text = self.gyjInfo.cardLevel
	self.CardNameLabel.text = RoleInfoData:GetData(cardExl:GetId()):GetName()
	self.PriceLabel.text = self.gyjInfo.price
	utility.LoadRoleHeadIcon(self.gyjInfo.cardID, self.CharacterIcon)
	utility.LoadRaceIcon(cardExl:GetRace(),self.TypeIcon)
	-- local star = cardExl:GetStar()
	-- for i=1,5 do
		-- self.RankStarIcon[i].gameObject:SetActive(i<=star)
	-- end
	local rarity = cardExl:GetRarity()
	utility.LoadSpriteFromPath(rarity,self.RarityImage)
end

function GuildMercenaryItemCls:RegisterControlEvents()
end

function GuildMercenaryItemCls:UnregisterControlEvents()
end

function GuildMercenaryItemCls:RegisterNetworkEvents()
end

function GuildMercenaryItemCls:UnregisterNetworkEvents()
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------

return GuildMercenaryItemCls
