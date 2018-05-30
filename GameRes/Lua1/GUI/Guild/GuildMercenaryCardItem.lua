local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local GuildMercenaryCardItemCls = Class(BaseNodeClass)
require "System.LuaDelegate"

function GuildMercenaryCardItemCls:Ctor(parent, cardInfo)
	self.parent = parent
	self.cardInfo = cardInfo
	self.callback = LuaDelegate.New()
end

function GuildMercenaryCardItemCls:SetCallback(ctable, func)
	self.callback:Set(ctable,func)
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function GuildMercenaryCardItemCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/GuildMercenaryCardItem', function(go)
		self:BindComponent(go)
		self:LinkComponent(nil, true)
	end)
end

function GuildMercenaryCardItemCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
	self:LinkComponent(self.parent)
end

function GuildMercenaryCardItemCls:OnResume()
	-- 界面显示时调用
	GuildMercenaryCardItemCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
end

function GuildMercenaryCardItemCls:OnPause()
	-- 界面隐藏时调用
	GuildMercenaryCardItemCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function GuildMercenaryCardItemCls:OnEnter()
	-- Node Enter时调用
	GuildMercenaryCardItemCls.base.OnEnter(self)
end

function GuildMercenaryCardItemCls:OnExit()
	-- Node Exit时调用
	GuildMercenaryCardItemCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function GuildMercenaryCardItemCls:InitControls()
	local transform = self:GetUnityTransform()
	self.Base = transform:Find('Base'):GetComponent(typeof(UnityEngine.UI.Button))
	self.CharacterIcon = transform:Find('Base/CharacterIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Frame = transform:Find('Base/Frame'):GetComponent(typeof(UnityEngine.UI.Image))
	self.RacialIcon = transform:Find('Base/RacialIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.LevelLabel = transform:Find('Base/LeftBase/LevelLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.OnSelect = transform:Find('Base/OnSelect')
	self.RankStarIcon = {}
	for i=1,5 do
		self.RankStarIcon[i] = transform:Find('Base/CharacterStars/RankStarIcon'..i)
	end
	self.RarityImage = transform:Find("Base/Rarity"):GetComponent(typeof(UnityEngine.UI.Image))
	self:InitView()
end

function GuildMercenaryCardItemCls:InitView()
	local cardExl = require "StaticData.Role":GetData(self.cardInfo.id)
	self.Frame.color = require "Utils.PropUtility".GetRGBColorValue(self.cardInfo.color)
	self.LevelLabel.text = self.cardInfo.level
	utility.LoadRoleHeadIcon(self.cardInfo.id, self.CharacterIcon)
	utility.LoadRaceIcon(cardExl:GetRace(),self.RacialIcon)
	-- local star = cardExl:GetStar()
	-- for i=1,5 do
		-- self.RankStarIcon[i].gameObject:SetActive(i<=star)
	-- end
	
	--ssr
	local rarity = cardExl:GetRarity()
	utility.LoadSpriteFromPath(rarity,self.RarityImage)
end

function GuildMercenaryCardItemCls:RegisterControlEvents()
	-- 注册 Base 的事件
	self.__event_button_onBaseClicked__ = UnityEngine.Events.UnityAction(self.OnBaseClicked, self)
	self.Base.onClick:AddListener(self.__event_button_onBaseClicked__)
end

function GuildMercenaryCardItemCls:UnregisterControlEvents()
	-- 取消注册 Base 的事件
	if self.__event_button_onBaseClicked__ then
		self.Base.onClick:RemoveListener(self.__event_button_onBaseClicked__)
		self.__event_button_onBaseClicked__ = nil
	end
end

function GuildMercenaryCardItemCls:RegisterNetworkEvents()
end

function GuildMercenaryCardItemCls:UnregisterNetworkEvents()
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function GuildMercenaryCardItemCls:OnBaseClicked()
	self.callback:Invoke(self.cardInfo.uid)
end

function GuildMercenaryCardItemCls:DoSelect()
	self.OnSelect.gameObject:SetActive(true)
end

function GuildMercenaryCardItemCls:DoUnselect()
	self.OnSelect.gameObject:SetActive(false)
end

return GuildMercenaryCardItemCls
