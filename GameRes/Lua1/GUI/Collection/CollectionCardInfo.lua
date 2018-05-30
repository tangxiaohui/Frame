local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
require "LUT.StringTable"

local CollectionCardInfo = Class(BaseNodeClass)
local moveSpeed = 160
local isClicked = false

function CollectionCardInfo:Ctor()
end

function CollectionCardInfo:OnInit()
	--加载界面
	utility.LoadNewGameObjectAsync("UI/Prefabs/CardInfo",function(go)
		self:BindComponent(go)
	end)
end

function CollectionCardInfo:OnWillShow(id)
	self.id = id
end

function CollectionCardInfo:OnComponentReady()
	self:InitControls()
end

function CollectionCardInfo:OnResume()
	CollectionCardInfo.base.OnResume(self)
	-- local eventMgr = self.myGame:GetEventManager()
    -- eventMgr:PostNotification('ClosePlayNotice')
	self:FadeIn(function(self, t)
        local transform = self.transform

        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 0.97, t)

        transform.localScale = Vector3(s, s, s)
    end)
	self:RegisterControlEvents()
	self:LoadItem()
end

function CollectionCardInfo:OnPause()
	CollectionCardInfo.base.OnPause(self)
	self:UnregisterControlEvents()
end

function CollectionCardInfo:OnEnter()
	CollectionCardInfo.base.OnEnter(self)
end

function CollectionCardInfo:OnExit()
	CollectionCardInfo.base.OnExit(self)
end

function CollectionCardInfo:Update()
	if isClicked then
		self:MoveCard()
	end
end

function CollectionCardInfo:GetRootHangingPoint()
    return self:GetUIManager():GetDialogLayer()
end

--绑定控件
function CollectionCardInfo:InitControls()
	isClicked = false
	local transform = self:GetUnityTransform()

	self.returnButton = transform:Find("Base"):GetComponent(typeof(UnityEngine.UI.Button))
	
	self.card = transform:Find("FullCardItem")
	self.info = transform:Find("Scroll View")
	self.transform = self.card.transform
	self.cardClicked = self.card:Find("CardIllust/CardPortrait"):GetComponent(typeof(UnityEngine.UI.Button))

	self.content = transform:Find("Scroll View/Viewport/Content/InfoContent")
	--种族
	self.cardRacial = self.content:Find("NormalInfo/Racial/RacialIcon"):GetComponent(typeof(UnityEngine.UI.Image))
	self.cardRacialName = self.content:Find("NormalInfo/Racial/RacialLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	--立绘
	-- self.characterPic = self.card:Find("CardIllust/CardPortrait"):GetComponent(typeof(UnityEngine.UI.Image))
	
	--主属性
	self.quickType = self.content:Find("NormalInfo/Type/Quick").gameObject --敏捷
	self.powerType = self.content:Find("NormalInfo/Type/Power").gameObject --力量
	self.intType = self.content:Find("NormalInfo/Type/Int").gameObject --智慧
	-- self.cardType = self.content:Find("NormalInfo/Type/CardTypeBase/TypeLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	--人物介绍
	self.cardDesciption = self.content:Find("CardDescrption/ActiveLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	
	--颜色
	self.colorType = self.content:Find("NormalInfo/RankBase"):GetComponent(typeof(UnityEngine.UI.Image))
	self.colorLabel = self.content:Find("NormalInfo/RankBase/RankLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	
	--主动技能
	self.cardSkillName_1 = self.content:Find("SkillInfo/SkillLayout/Active/ActiveName"):GetComponent(typeof(UnityEngine.UI.Text))
	self.cardSkillDec_1 = self.content:Find("SkillInfo/SkillLayout/Active/ActiveLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	
	--被动技能
	self.cardSkillName_2 = self.content:Find("SkillInfo/SkillLayout/Passive/PassiveName"):GetComponent(typeof(UnityEngine.UI.Text))
	self.cardSkillDec_2 = self.content:Find("SkillInfo/SkillLayout/Passive/PassiveLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	
	--专属装备
	self.cardEquipState = self.content:Find("UniqueWeapon")
	-- self.cardEquipName = self.skill:Find("CardSkill3/Skill3TitleLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.cardEquipDec = self.content:Find("UniqueWeapon/ActiveLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	
	self.cardState = self.content:Find("NormalInfo/Status")
	--生命值
	self.cardLifeNum = self.cardState:Find("Life/StatusLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.cardLifeFill = self.cardState:Find("Life/Bar/Fill"):GetComponent(typeof(UnityEngine.UI.Image))
	--攻击值
	self.cardAtkNum = self.cardState:Find("Atk/StatusLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.cardAtkFill = self.cardState:Find("Atk/Bar/Fill"):GetComponent(typeof(UnityEngine.UI.Image))
	--防御值
	self.cardDefNum = self.cardState:Find("Def/StatusLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.cardDefFill = self.cardState:Find("Def/Bar/Fill"):GetComponent(typeof(UnityEngine.UI.Image))
	--速度值
	self.cardSpeedNum = self.cardState:Find("SPD/StatusLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.cardSpeedFill = self.cardState:Find("SPD/Bar/Fill"):GetComponent(typeof(UnityEngine.UI.Image))
	--显示名字
	self.heroName = self.content:Find("NormalInfo/CardName"):GetComponent(typeof(UnityEngine.UI.Text))
	-- self.heroNameGameOnbject = {}
	-- for i = 1,5 do
		-- self.heroNameGameOnbject[i] = self.heroname:Find("HeroCharacterBase"..i)
	-- end
	-- self.heroNameLabel = {}
	-- for i = 1,5 do
		-- self.heroNameLabel[i] = transform:Find("HeroCharacter/HeroCharacterPatern1/HeroCharacterBase"..i.."/HeroCharacterBaseTextLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	-- end
	self.iconImage = self.card:Find('CardIllust/CardPortrait'):GetComponent(typeof(UnityEngine.UI.Image))
	self.CHNNameImage = self.card:Find('CardName/CardNameImageCHN'):GetComponent(typeof(UnityEngine.UI.Image))
	self.JPNameImage = self.card:Find('CardName/CardNameImageJP'):GetComponent(typeof(UnityEngine.UI.Image))
	self.starFrame = self.card:Find('StarFrame/5Star')
	self.raceImage = self.card:Find('Racial/RacialIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.HPLabel = self.card:Find("HP/Num"):GetComponent(typeof(UnityEngine.UI.Text))
	self.ATKLabel = self.card:Find("ATK/Num"):GetComponent(typeof(UnityEngine.UI.Text))
	self.ActiveLabel = self.card:Find("CardSkill/Scroll View/Viewport/Content/ActiveLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.PassiveLabel = self.card:Find("CardSkill/Scroll View/Viewport/Content/PassiveLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	--颜色
	self.cardColor = self.card:Find("CardIllust/BackLight"):GetComponent(typeof(UnityEngine.UI.Image))
	self.cardTypeImage = self.card:Find("CardSkill/CardType"):GetComponent(typeof(UnityEngine.UI.Image))
	
	self.RarityImage = self.card:Find("Rare/Image"):GetComponent(typeof(UnityEngine.UI.Image))
	self.NameText = self.card:Find("Name/Text"):GetComponent(typeof(UnityEngine.UI.Text))
	
	self.myGame = utility:GetGame()
	self.resetPosition = Vector2(-291,0)
	self:ScheduleUpdate(self.Update)
end

function CollectionCardInfo:RegisterControlEvents()
	self._event_button_onInfoButtonClicked_ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked,self)
	self.returnButton.onClick:AddListener(self._event_button_onInfoButtonClicked_)
	
	self._event_button_onCardClicked_ = UnityEngine.Events.UnityAction(self.OnCardClicked,self)
	self.cardClicked.onClick:AddListener(self._event_button_onCardClicked_)
end

function CollectionCardInfo:UnregisterControlEvents()
	if self._event_button_onInfoButtonClicked_ then
		self.returnButton.onClick:RemoveListener(self._event_button_onInfoButtonClicked_)
		self._event_button_onInfoButtonClicked_ = nil
	end
	
	if self._event_button_onCardClicked_ then
		self.cardClicked.onClick:RemoveListener(self._event_button_onCardClicked_)
		self._event_button_onCardClicked_ = nil
	end
end

function CollectionCardInfo:OnReturnButtonClicked()
	--print("HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH")
	self:Close(true)
	-- local sceneManager = self.myGame:GetSceneManager()
    -- sceneManager:PopScene()
	-- local eventMgr = self.myGame:GetEventManager()
    -- eventMgr:PostNotification('ShowPlayNotice')
end

function CollectionCardInfo:OnCardClicked()
	isClicked = true
end

----------------------------------------------------------------------------
--动画处理--
----------------------------------------------------------------------------
function CollectionCardInfo:IsTransition()
    return true
end

-- ## 在这里执行 淡出函数! (immediately 值只针对 WindowNode 及其子类)
function CollectionCardInfo:OnExitTransitionDidStart(immediately)
    CollectionCardInfo.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.transform

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function CollectionCardInfo:MoveCard()
	if self.card.localPosition.x >= (self.resetPosition.x ) then
       	self.card:Translate(Vector3.left * Time.deltaTime * moveSpeed)
    else
		self.info.gameObject:SetActive(true)
		-- self.cardClicked.gameObject:SetActive(false)
	end
end

function CollectionCardInfo:LoadItem()
	self:SetCardState()
	self:SetRoleInfo()
	self:SetNameInfo()
	self:SetPanel()
	-- self:SetCardEquip()
end

function CollectionCardInfo:SetPanel()
	-- 名字
	local gameTool = require "Utils.GameTools"
	-- 头像 名字
	local roleData = require "StaticData.Role":GetData(self.id)
	local iconName = roleData:GetPortraitImage()
	local roleinfoData = require "StaticData.RoleInfo"
	local name = roleinfoData:GetData(self.id):GetName()
	-- self.NameText.text = name
	-- gameTool.SetRoleCardName(iconName,self.CHNNameImage,self.JPNameImage)

	-- 抽卡立绘
	utility.LoadIllustRolePortraitImage(self.id, self.iconImage)

	--utility.LoadSpriteFromPath(string.format("UI/Textures/CardIllust/%s", iconName),self.iconImage)
	-- self.iconImage:SetNativeSize()
	-- 星星
	local star = roleData:GetStar()
	-- gameTool.AutoSetRoleStar(self.starFrame,star)
	local rarity = roleData:GetRarity()
	utility.LoadSpriteFromPath(rarity,self.RarityImage)
	-- gameTool.SetGradientColor(self.CHNNameImage,star)
	-- gameTool.SetGradientColor(self.JPNameImage,star)
	--種族
	if self.race ~= nil then
		utility.LoadRaceIcon(self.race,self.raceImage)
	end
	
	-- 属性
	if self.hp ~= nil then
		self.HPLabel.text = self.hp
		gameTool.SetGradientColor(self.HPLabel,star)
	end
	if self.atk ~= nil then
		self.ATKLabel.text = self.atk
		gameTool.SetGradientColor(self.ATKLabel,star)
	end
	if self.activeSkill ~= nil then
		self.ActiveLabel.text = self.activeSkill
	end
	if self.passiveSkill ~= nil then
		self.PassiveLabel.text = self.passiveSkill
	end
	
	if self.color ~= nil then
		local PropUtility = require "Utils.PropUtility"
		self.cardColor.color = PropUtility.GetRGBColorValue(self.color)
	end

	local major = roleData:GetMajorAttr()
	local majorPath = gameTool.GetMajorAttrImagePath(major)
	utility.LoadSpriteFromPath(majorPath,self.cardTypeImage)

end

function CollectionCardInfo:SetRoleInfo()
	local roleinfoData = require "StaticData.RoleInfo"
	local data = roleinfoData:GetData(self.id)
	local roleData = require "StaticData.Role":GetData(self.id)
	self.race = roleData:GetRace()
	self.activeSkill = data:GetActiveSkillDesc()
	self.passiveSkill = data:GetPassiveSkillDesc()
	self.cardDesciption.text = data:GetDesc()
	self.cardSkillName_1.text = data:GetActiveSkillName()
	self.cardSkillDec_1.text = self.activeSkill
	self.cardSkillName_2.text = data:GetPassiveSkillName()
	self.cardSkillDec_2.text = self.passiveSkill
	local desc = data:GetUniqueWeaponDesc()
	if desc ~= "null" then
		self.cardEquipState.gameObject:SetActive(true)
		self.cardEquipDec.text = data:GetUniqueWeaponDesc()
	else
		self.cardEquipState.gameObject:SetActive(false)
	end
	utility.LoadRaceIcon(self.race,self.cardRacial)
	self.cardRacialName.text = Race[self.race]
	self:SetRectTransformDelta(self.cardDesciption)
	self:SetRectTransformDelta(self.cardSkillDec_1)
	self:SetRectTransformDelta(self.cardSkillDec_2)
	self:SetRectTransformDelta(self.cardEquipDec)
	local PropUtility = require "Utils.PropUtility"
	self.color = roleData:GetColorID()
    self.colorType.color = PropUtility.GetRGBColorValue(self.color)
    self.colorLabel.text = Color[self.color]
end

function CollectionCardInfo:SetRectTransformDelta(textLabel )
	local sizeDelta = textLabel.rectTransform.sizeDelta
	sizeDelta.y = textLabel.preferredHeight
	textLabel.rectTransform.sizeDelta = sizeDelta
end

function CollectionCardInfo:SetNameInfo()
	-- self:HideName()
	
	local roleinfoData = require "StaticData.RoleInfo"
	-- local name = roleinfoData:GetData(self.id):GetName()
	self.heroName.text = roleinfoData:GetData(self.id):GetName()
	self.NameText.text = roleinfoData:GetData(self.id):GetCardName()
	-- local tables = {}
	-- print(string.sub(name,4,6))
	-- if string.byte(name) >= 128 then
		-- for i = 0,((#name/3)-1) do
			-- tables[#tables+1] = string.sub(name,1+(i*3),(i+1)*3)
			-- self.heroNameGameOnbject[i+1].gameObject:SetActive(true)
			-- self.heroNameLabel[i+1].text = tables[i+1]
			-- print(tables[i+1])
		-- end
	-- else
		-- for i = 1,#name do
			-- tables[i] = string.sub(name,i,i)
			-- self.heroNameGameOnbject[i].gameObject:SetActive(true)
			-- self.heroNameLabel[i].text = tables[i]
			-- print(tables[i])
		-- end
	-- end
end

-- function CollectionCardInfo:HideName()
	-- for i = 1,5 do
		-- self.heroNameGameOnbject[i].gameObject:SetActive(false)
	-- end
-- end

function CollectionCardInfo:SetCardEquip()
	-- local equipExclusive =  require "StaticData.EquipExclusive"
	-- local keys = equipExclusive:GetKeys()
	-- local tables = {}
	-- local equips = {}
	-- local length = keys.Length - 1
	-- for i = 0,length do
		-- tables[#tables + 1] = keys[i]
	-- end
	-- for i = 1,#tables do
		-- local data = equipExclusive:GetData(tables[i])
		-- equips[#tables] = data:GetJibanCardID()
		-- print("aaaaaaaaaaaaaa",equip)
		-- if(string.find(equip,self.id)) then
			-- print("aaaaa",data:GetId())
		-- end
	-- end
	-- print(#equips)
end

function CollectionCardInfo:SetCardState()
	local UserDataType = require "Framework.UserDataType"
    local cardBagData = self:GetCachedData(UserDataType.CardBagData)
	local userRoleData = cardBagData:GetRoleById(self.id)
	  require "Game.Role"
    -- if userRoleData == nil then
        userRoleData = Role.New()
        userRoleData:UpdateForStatic(self.id, 1, 1)
    -- end
	self.hp = userRoleData:GetHp()
	self.cardLifeNum.text = self.hp
	self.cardLifeFill.fillAmount = self.hp/self:GetMaxStatus(1)
	self.atk = userRoleData:GetAp()
	self.cardAtkNum.text = self.atk
	self.cardAtkFill.fillAmount = self.atk/self:GetMaxStatus(2)
	local dp = userRoleData:GetDp()
	self.cardDefNum.text = dp
	self.cardDefFill.fillAmount = dp/self:GetMaxStatus(3)
	local speed = userRoleData:GetSpeed()
	self.cardSpeedNum.text = speed
	self.cardSpeedFill.fillAmount = speed/self:GetMaxStatus(4)
	local attributeIndex,major = userRoleData:GetMajorAttr()
	local attributeColor = require "Utils.GameTools".GetMajorAttrColor(attributeIndex)
	-- local data = MajorAttr[major]
	if major == "敏" then
		self:SetTypeActive(self.quickType)
	elseif major == "力" then
		self:SetTypeActive(self.powerType)
	elseif major == "智" then
		self:SetTypeActive(self.intType)
	end
	-- self.cardType.text = major
	-- self.cardType.color = attributeColor
	-- local icon = userRoleData:GetPortraitImage()
	-- local path = string.format("%s%s","UI/Textures/CardPortrait/",icon)
	-- print("path设置玩家立绘",path)
	-- utility.LoadRolePortraitImage(roleID,function (prefab)
  		-- self.CharactPortrait.sprite = prefab
  	-- end)
	 -- utility.LoadSpriteFromPath(path,self.characterPic)
end

function CollectionCardInfo:SetTypeActive(obj)
	self.quickType:SetActive(false)
	self.powerType:SetActive(false)
	self.intType:SetActive(false)
	obj:SetActive(true)
end

function CollectionCardInfo:GetMaxStatus(index)
	local maxStatus = require "StaticData.MaxStatus":GetData(index)
	return maxStatus:GetMaxPower()
end

return CollectionCardInfo