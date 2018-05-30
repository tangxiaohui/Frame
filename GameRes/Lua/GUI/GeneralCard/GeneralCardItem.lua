local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "System.LuaDelegate"

local GeneralCardItemCls = Class(BaseNodeClass)

function GeneralCardItemCls:Ctor(parent)
	self.parent = parent
	self.callback = LuaDelegate.New()
	self:InitVariable()
end

function GeneralCardItemCls:SetCallback(table, func)
	self.endCallBack = true
    self.callback:Set(table, func)
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function GeneralCardItemCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/FullCardItem', function(go)
		self:BindComponent(go,false)
	end)
end

function GeneralCardItemCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()
end

function GeneralCardItemCls:OnResume()
	-- 界面显示时调用
	GeneralCardItemCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:ResetItem()
end

function GeneralCardItemCls:OnPause()
	-- 界面隐藏时调用
	GeneralCardItemCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:ClearVariable()
end

function GeneralCardItemCls:OnEnter()
	-- Node Enter时调用
	GeneralCardItemCls.base.OnEnter(self)
end

function GeneralCardItemCls:OnExit()
	-- Node Exit时调用
	GeneralCardItemCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function GeneralCardItemCls:InitControls()
	local transform = self:GetUnityTransform()
	self.transform = transform
	--self.BaseButton = transform:Find('Base'):GetComponent(typeof(UnityEngine.UI.Button))
	self.iconImage = transform:Find('CardIllust/CardPortrait'):GetComponent(typeof(UnityEngine.UI.Image))
	self.CHNNameImage = transform:Find('CardName/CardNameImageCHN'):GetComponent(typeof(UnityEngine.UI.Image))
	self.JPNameImage = transform:Find('CardName/CardNameImageJP'):GetComponent(typeof(UnityEngine.UI.Image))
	self.starFrame = transform:Find('StarFrame/5Star')
	self.raceImage = transform:Find('Racial/RacialIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.HPLabel = transform:Find("HP/Num"):GetComponent(typeof(UnityEngine.UI.Text))
	self.ATKLabel = transform:Find("ATK/Num"):GetComponent(typeof(UnityEngine.UI.Text))
	self.ActiveLabel = transform:Find("CardSkill/Scroll View/Viewport/Content/Active/ActiveLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.PassiveLabel = transform:Find("CardSkill/Scroll View/Viewport/Content/Passive/PassiveLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.cartTypeImage = transform:Find("CardSkill/CardType"):GetComponent(typeof(UnityEngine.UI.Image))
	self.activeLabelElement = transform:Find("CardSkill/Scroll View/Viewport/Content/Active"):GetComponent(typeof(UnityEngine.UI.LayoutElement)) 
	self.passLabelElement = transform:Find("CardSkill/Scroll View/Viewport/Content/Passive"):GetComponent(typeof(UnityEngine.UI.LayoutElement)) 
	self.RarityImage = transform:Find("Rare/Image"):GetComponent(typeof(UnityEngine.UI.Image))
	self.nameText = transform:Find("Name/Text"):GetComponent(typeof(UnityEngine.UI.Text))
end

function GeneralCardItemCls:InitVariable()
	self.icon = nil
	self.star = nil
	self.color = nil
	self.race = nil
	self.cardType = nil
	self.hp = nil
	self.atk = nil
	self.activeSkill = nil
	self.passiveSkill = nil
	self.endCallBack = nil
	self.scale = nil
end

function GeneralCardItemCls:RegisterControlEvents()
	-- self.__event_button_onBaseButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBaseButtonClicked, self)
	-- self.BaseButton.onClick:AddListener(self.__event_button_onBaseButtonClicked__)
end

function GeneralCardItemCls:UnregisterControlEvents()
	-- if self.__event_button_onBaseButtonClicked__ then
	-- 	self.BaseButton.onClick:RemoveListener(self.__event_button_onBaseButtonClicked__)
	-- 	self.__event_button_onBaseButtonClicked__ = nil
	-- end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function GeneralCardItemCls:SetAllVariable(icon,star,color,race,cardType,hp,atk,activeSkill,passiveSkill,scale)
	self.icon = icon
	self.star = star
	self.color = color
	self.race = race
	self.cardType = cardType
	self.hp = hp
	self.atk = atk
	self.activeSkill = activeSkill
	self.passiveSkill = passiveSkill
	self.scale = scale
end

function GeneralCardItemCls:SetIcon(icon)
	self.icon = icon
end

function GeneralCardItemCls:SetStar(star)
	self.star = star
end

function GeneralCardItemCls:SetRarity(rarity)
	self.rarity = rarity
end

function GeneralCardItemCls:SetColor(color)
	self.color = color
end

function GeneralCardItemCls:SetRace(race)
	self.race = race
end

function GeneralCardItemCls:SetCardType(cardType)
	self.cardType = cardType
end

function GeneralCardItemCls:SetHP(hp)
	self.hp = hp
end

function GeneralCardItemCls:SetATK(atk)
	self.atk = atk
end

function GeneralCardItemCls:SetActiveSkill(activeSkill)
	self.activeSkill = activeSkill
end

function GeneralCardItemCls:SetPassiveSkill(passiveSkill)
	self.passiveSkill = passiveSkill
end

function GeneralCardItemCls:SetEndCallBack(endCallBack)
	self.endCallBack = endCallBack
end

function GeneralCardItemCls:SetScale(scale)
	self.scale = scale
end

function GeneralCardItemCls:SetId(id)
	self.id = id
end

function GeneralCardItemCls:SetUID(uid)
	self.uid = uid
end

function GeneralCardItemCls:ClearVariable()
	self.icon = nil
	self.star = nil
	self.color = nil
	self.race = nil
	self.cardType = nil
	self.hp = nil
	self.atk = nil
	self.activeSkill = nil
	self.passiveSkill = nil
	self.scale = nil
end

local function SetObjActive(obj,active)
	obj.gameObject:SetActive(active)
end

local function SetPanel(self)
	-- 名字
	local gameTool = require "Utils.GameTools"

	-- 头像 名字
	if self.icon ~= nil then
		-- gameTool.SetRoleCardName(self.icon,self.CHNNameImage,self.JPNameImage)
		-- 抽卡立绘
		utility.LoadIllustRolePortraitImage(self.id, self.iconImage)
	end
	local roleinfoData = require "StaticData.RoleInfo"
	self.nameText.text = roleinfoData:GetData(self.id):GetCardName()
	-- 星星
	-- if self.star ~= nil then
		-- gameTool.AutoSetRoleStar(self.starFrame,self.star)
		-- gameTool.SetGradientColor(self.CHNNameImage,self.star)
		-- gameTool.SetGradientColor(self.JPNameImage,self.star)
	-- end
	--ssr
	if self.rarity ~= nil then
		utility.LoadSpriteFromPath(self.rarity,self.RarityImage)
	end
	
	--種族
	if self.race ~= nil then
		utility.LoadRaceIcon(self.race,self.raceImage)
	end
	-- 类型
	if self.cardType ~= nil then
		utility.LoadSpriteFromPath(self.cardType,self.cartTypeImage)
	end
	-- 属性
	if self.hp ~= nil then
		self.HPLabel.text = self.hp
		gameTool.SetGradientColor(self.HPLabel,self.star)
	end
	if self.atk ~= nil then
		self.ATKLabel.text = self.atk
		gameTool.SetGradientColor(self.ATKLabel,self.star)
	end
	if self.activeSkill ~= nil then
		self.ActiveLabel.text = self.activeSkill
		self.activeLabelElement.preferredHeight = self.ActiveLabel.preferredHeight + 12
	end
	if self.passiveSkill ~= nil then
		self.PassiveLabel.text = self.passiveSkill
		self.passLabelElement.preferredHeight = self.PassiveLabel.preferredHeight + 10
	end

	if self.scale ~= nil then
		self.transform.localScale = self.scale
	end

	-- 回调
	if self.endCallBack then
		self.callback:Invoke()
	end
end

local function DelayReset(self)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	SetPanel(self)
end

function GeneralCardItemCls:ResetItem()
	self:StartCoroutine(DelayReset)
end

-- function GeneralCardItemCls:OnBaseButtonClicked()
-- 	self.callback:Invoke(self.id)
-- end

return GeneralCardItemCls