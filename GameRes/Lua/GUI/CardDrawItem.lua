local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
local gameTool = require "Utils.GameTools"
require "System.LuaDelegate"

local CardDrawResultAwardCls = Class(BaseNodeClass)

function CardDrawResultAwardCls:Ctor(parent)
	self.parent = parent
	self.callback = LuaDelegate.New()
	self:InitVariable()
end

function CardDrawResultAwardCls:SetCallback(table, func)
    self.callback:Set(table, func)
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function CardDrawResultAwardCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/CardItem', function(go)
		self:BindComponent(go,false)
	end)
end

function CardDrawResultAwardCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()
end

function CardDrawResultAwardCls:OnResume()
	-- 界面显示时调用
	CardDrawResultAwardCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:ResetItem()
end

function CardDrawResultAwardCls:OnPause()
	-- 界面隐藏时调用
	CardDrawResultAwardCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:ClearVariable()
end

function CardDrawResultAwardCls:OnEnter()
	-- Node Enter时调用
	CardDrawResultAwardCls.base.OnEnter(self)
end

function CardDrawResultAwardCls:OnExit()
	-- Node Exit时调用
	CardDrawResultAwardCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function CardDrawResultAwardCls:InitControls()
	local transform = self:GetUnityTransform()

	self.BaseButton = transform:Find('Base'):GetComponent(typeof(UnityEngine.UI.Button))

	self.iconImage = transform:Find('Base/Icon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.nameLabel = transform:Find('Base/HeroName'):GetComponent(typeof(UnityEngine.UI.Text))
	self.starFrame = transform:Find('Base/Stars')
	self.raceImage = transform:Find('Base/RaceIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.debrisObjFront = transform:Find('Base/FragmentIcon').gameObject
	self.debrisObjBack = transform:Find('Base/Fragment').gameObject
	self.colorFrame = transform:Find('Base/Frame'):GetComponent(typeof(UnityEngine.UI.Image))
	self.newObj = transform:Find('Base/New').gameObject
	self.effectPoint = transform:Find('EffectPoint')
	self.RarityImage = transform:Find('Base/Rarity'):GetComponent(typeof(UnityEngine.UI.Image))
end

function CardDrawResultAwardCls:InitVariable()
	self.itemPattern = nil
	self.icon = nil
	self.name = nil
	self.star = nil
	self.color = nil
	self.race = nil
	self.isNew = nil
	self.needEffect = nil
end

function CardDrawResultAwardCls:RegisterControlEvents()
	self.__event_button_onBaseButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBaseButtonClicked, self)
	self.BaseButton.onClick:AddListener(self.__event_button_onBaseButtonClicked__)
end

function CardDrawResultAwardCls:UnregisterControlEvents()
	if self.__event_button_onBaseButtonClicked__ then
		self.BaseButton.onClick:RemoveListener(self.__event_button_onBaseButtonClicked__)
		self.__event_button_onBaseButtonClicked__ = nil
	end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function CardDrawResultAwardCls:SetAllVariable(itemPattern,icon,name,star,color,race,isNew,needEffect)
	self.itemPattern = itemPattern
	self.icon = icon
	self.name = name
	self.star = star
	self.color = color
	self.race = race
	self.isNew = isNew
	self.needEffect = needEffect
end

function CardDrawResultAwardCls:SetPattern(itemPattern)
	self.itemPattern = itemPattern
end

function CardDrawResultAwardCls:SetIcon(icon)
	self.icon = icon
end

function CardDrawResultAwardCls:SetName(name)
	self.name = name
end

function CardDrawResultAwardCls:SetStar(star)
	self.star = star
end

function CardDrawResultAwardCls:SetColor(color)
	self.color = color
end

function CardDrawResultAwardCls:SetRace(race)
	self.race = race
end

function CardDrawResultAwardCls:SetIsNew(isNew)
	self.isNew = isNew
end

function CardDrawResultAwardCls:SetId(id)
	self.id = id
end

function CardDrawResultAwardCls:SetNeedEffect(needEffect)
	self.needEffect = needEffect
end

function CardDrawResultAwardCls:ClearVariable()
	self.itemPattern = nil
	self.icon = nil
	self.name = nil
	self.star = nil
	self.color = nil
	self.race = nil
	self.isNew = nil
	self.needEffect = nil

	if self.effect ~= nil then		
		UnityEngine.Object.Destroy(self.effect)
		self.effect = nil
	end
	self.newObj:SetActive(false)
end

local function SetObjActive(obj,active)
	obj.gameObject:SetActive(active)
end

local function SetDebrisPattern(self)
	SetObjActive(self.debrisObjBack,true)
	SetObjActive(self.debrisObjFront,true)
	SetObjActive(self.raceImage,true)
end

local function SetNomarlPattern(self)
	SetObjActive(self.debrisObjBack,false)
	SetObjActive(self.debrisObjFront,false)
	SetObjActive(self.raceImage,false)
end

local function SetRolePattern(self)
	SetObjActive(self.debrisObjBack,false)
	SetObjActive(self.debrisObjFront,false)
	SetObjActive(self.raceImage,true)
end

local function SortLayer(self)
	coroutine.step(1)
	_G.CanvasDepthReorderer.GetInstance ():Sort ()
end

local function SetPanel(self)
	-- 名字
	if self.name ~= nil then
		self.nameLabel.text = self.name
	end
	-- 頭像
	if self.icon ~= nil then
		utility.LoadSpriteFromPath(self.icon,self.iconImage)
	end
	-- 星星
	if self.star ~= nil then
		if self.star ~= 0 then
			self.RarityImage.gameObject:SetActive(true)
		local rarity = require "StaticData.StartoSSR":GetData(self.star):GetSSR()
		utility.LoadSpriteFromPath(rarity,self.RarityImage)
		else
			self.RarityImage.gameObject:SetActive(false)
		end
		-- gameTool.AutoSetRoleStar(self.starFrame,self.star)
	end
	-- 顏色
	if self.color ~= nil then
		--colorFrame
		local propUtility = require "Utils.PropUtility"
		local color = propUtility.GetRGBColorValue(self.color)
		self.colorFrame.color = color
		self.nameLabel.color = color
	end
	--種族
	if self.race ~= nil then
		utility.LoadRaceIcon(self.race,self.raceImage)
	end
	--新獲得
	if self.isNew ~= nil then
		self.newObj:SetActive(self.isNew)
	end	

	if self.needEffect ~= nil and self.color > 0 then
		
		--- 序列帧
		if self.effect == nil then
			gameTool.AddItemEffect(self.color,self.effectPoint,function (go)
				self.effect = go
			end)
		end

		-- gameTool.AddItemEffect(self.color,self.effectPoint)
		-- local path = gameTool.GetItemEffectPath(self.color)
		-- utility.LoadNewGameObjectAsync(path, function(go)
		-- 	go.transform:SetParent(self.effectPoint)
		-- 	go.transform.localPosition = Vector3(0,0,0)
		-- 	go.transform.localScale = Vector3(1,1,1)
		-- 	self.effect = go.gameObject
		-- end)
	end
end

local function DelayReset(self)
	while (not self:IsReady()) do
		coroutine.step(1)
	end

	if self.itemPattern == 1 then
		SetRolePattern(self)
	elseif self.itemPattern == 2 then
		SetNomarlPattern(self)
	elseif self.itemPattern == 3 then
		SetDebrisPattern(self)
	end
	self.newObj:SetActive(false)
	SetPanel(self)
end

function CardDrawResultAwardCls:ResetItem()
	self:StartCoroutine(DelayReset)
end

function CardDrawResultAwardCls:OnBaseButtonClicked()
	self.callback:Invoke(self.id)
end

return CardDrawResultAwardCls