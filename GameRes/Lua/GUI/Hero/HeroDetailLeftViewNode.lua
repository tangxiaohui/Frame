--
-- User: fenghao
-- Date: 17/06/2017
-- Time: 4:08 PM
--

local BaseNodeClass = require "Framework.Base.Node"
local HeroDetailLeftViewNode = Class(BaseNodeClass)
local utility = require "Utils.Utility"
local net = require "Network.Net"

local function IsCurrentAnimationState(animator, stateName)
    local stateInfo = animator:GetCurrentAnimatorStateInfo(0)
    return stateInfo:IsName(stateName)
end

local function InitControls(self)
    local transform = self:GetUnityTransform()

    -- 人物立绘控件 --
    self.portraitImage = transform:Find("LinePersonGroup/ImageParent/CharacterImage"):GetComponent(typeof(UnityEngine.UI.Image))

    -- 星级控件 --
    self.starObjects = {
        transform:Find("CardInfoStarLayout/Star1").gameObject,
        transform:Find("CardInfoStarLayout/Star2").gameObject,
        transform:Find("CardInfoStarLayout/Star3").gameObject,
        transform:Find("CardInfoStarLayout/Star4").gameObject,
        transform:Find("CardInfoStarLayout/Star5").gameObject
    }

    -- 种族图标 --
    self.raceIconImage = transform:Find("CardInfoStarLayout/RaceBase/RaceIcon"):GetComponent(typeof(UnityEngine.UI.Image))
    self.raceName = transform:Find("CardInfoStarLayout/RaceBase/Text"):GetComponent(typeof(UnityEngine.UI.Text))

    -- 卡牌类型(力敏智) --
    self.attributeLabel = transform:Find("CardInfoStarLayout/CardTypeBase/Text"):GetComponent(typeof(UnityEngine.UI.Text))
    self.attributeIcon = transform:Find("CardInfoStarLayout/CardTypeBase/Icon"):GetComponent(typeof(UnityEngine.UI.Image))

    -- 等级 --
    self.levelLabel = transform:Find("CardInfoGroup/HeroCharacter/CardPreInfo/LevelBase/Text"):GetComponent(typeof(UnityEngine.UI.Text))

    -- 名字组 --
    local nameGroup1 = transform:Find("CardInfoGroup/HeroCharacter/HeroNameGroup1")
    local nameGroup2 = transform:Find("CardInfoGroup/HeroCharacter/HeroNameGroup2")
    local nameGroup3 = transform:Find("CardInfoGroup/HeroCharacter/HeroNameGroup3")
    local nameGroup4 = transform:Find("CardInfoGroup/HeroCharacter/HeroNameGroup4")
    local nameGroup5 = transform:Find("CardInfoGroup/HeroCharacter/HeroNameGroup5")

    self.nameGroupObjects = {
        nameGroup1.gameObject,
        nameGroup2.gameObject,
        nameGroup3.gameObject,
        nameGroup4.gameObject,
        nameGroup5.gameObject,
    }

    self.nameGroupLabels = {
        nameGroup1:Find("HeroCharacter/Text"):GetComponent(typeof(UnityEngine.UI.Text)),
        nameGroup2:Find("HeroCharacter/Text"):GetComponent(typeof(UnityEngine.UI.Text)),
        nameGroup3:Find("HeroCharacter/Text"):GetComponent(typeof(UnityEngine.UI.Text)),
        nameGroup4:Find("HeroCharacter/Text"):GetComponent(typeof(UnityEngine.UI.Text)),
        nameGroup5:Find("HeroCharacter/Text"):GetComponent(typeof(UnityEngine.UI.Text)),
    }

    -- 品级颜色 --
    local qualityRank = transform:Find("CardInfoGroup/HeroCharacter/QualityGroup/QualityRank")
    self.qualityRankImage = qualityRank:GetComponent(typeof(UnityEngine.UI.Image))
    self.qualityRankText = qualityRank:Find("Text"):GetComponent(typeof(UnityEngine.UI.Text))

    -- 主动技能 --
    local activeSkill = transform:Find("CardInfoGroup/CardSkillGroup/Viewport/Content/ActiveSkill")
    self.activeSkillRootTrans = activeSkill
    self.activeSkillText = activeSkill:Find("Description"):GetComponent(typeof(UnityEngine.UI.Text))

    -- 被动技能 --
    local passiveSkill = transform:Find("CardInfoGroup/CardSkillGroup/Viewport/Content/PassiveSkill")
    self.passiveSkillRootTrans = passiveSkill
    self.passiveSkillText = passiveSkill:Find("Description"):GetComponent(typeof(UnityEngine.UI.Text))
	
	self.RarityImage = transform:Find("CardInfoGroup/HeroCharacter/CardPreInfo/Rarity/Image"):GetComponent(typeof(UnityEngine.UI.Image))

      -- 碎片 --(GetNeedCardSuipianNum)
    self.fragmentLabel = transform:Find("CardInfoStarLayout/FragmentNum/Label"):GetComponent(typeof(UnityEngine.UI.Text))

    -- 碎片来源按钮
    self.fragmentSourceButton = transform:Find("CardInfoStarLayout/FragmentNum/Button"):GetComponent(typeof(UnityEngine.UI.Button))
	
end

function HeroDetailLeftViewNode:Ctor(transform, rootAnimator)
    self.firstEnter = true
    self.rootAnimator = rootAnimator
    self:BindComponent(transform.gameObject, false)
    InitControls(self)
end
function HeroDetailLeftViewNode:SetHeroID(heroId)
    debug_print("HeroDetailAttributePanel:SetHeroID(heroId)",heroId)
    self.heroId=heroId
end
local function OnFragmentSourceButtonClicked(self)
    local utility = require "Utils.Utility"
    if self.heroId ~= nil then
       
        local roleMgr = require "StaticData.Role"
        self.data = roleMgr:GetData(self.heroId)
        utility.ShowSourceWin(self.data:GetScrapId())
       
    elseif self.userRoleData ~= nil then
       utility.ShowSourceWin(self.userRoleData:GetScrapId())
    end
end


function HeroDetailLeftViewNode:OnResume()
    HeroDetailLeftViewNode.base.OnResume(self)
     -- 注册 查看碎片获取源的按钮 --
    self.__event_fragmentSourceButtonClicked__ = UnityEngine.Events.UnityAction(OnFragmentSourceButtonClicked, self)
    self.fragmentSourceButton.onClick:AddListener(self.__event_fragmentSourceButtonClicked__)
	
	self:GetGame():RegisterMsgHandler(net.S2CCardCorrCardSkinInfoQueryResult,self,self.CardCorrCardSkinInfoQueryResult)
end

function HeroDetailLeftViewNode:OnPause()
    HeroDetailLeftViewNode.base.OnPause(self)

    -- 取消注册 查看碎片获取源的按钮 --
    if self.__event_fragmentSourceButtonClicked__ then
        self.fragmentSourceButton.onClick:RemoveListener(self.__event_fragmentSourceButtonClicked__)
        self.__event_fragmentSourceButtonClicked__ = nil
    end
	
	self:GetGame():UnRegisterMsgHandler(net.S2CCardCorrCardSkinInfoQueryResult, self, self.CardCorrCardSkinInfoQueryResult)
end

local function ReloadNames(self, name)
    local StringUtility = require "Utils.StringUtility"
    local nameGroupCount = #self.nameGroupObjects
    local nameArray = StringUtility.CreateArray(name)
    local nameLength = math.min(nameGroupCount, #nameArray)
    for i = 1, nameGroupCount do
        local show = i <= nameLength
        self.nameGroupObjects[i]:SetActive(show)
        if show then
            self.nameGroupLabels[i].text = nameArray[i]
        end
    end
end

local function OnReload(self, staticRoleData, roleLevel, color, stage, dataOnly)
    if self.firstEnter then
        self.firstEnter = false
    else
		if not dataOnly then
			if IsCurrentAnimationState(self.rootAnimator, "zhuangbeixinxi") or IsCurrentAnimationState(self.rootAnimator, "zhuangbeixinxi_yingxiongdianji") then
				self.rootAnimator:SetTrigger("EquipHeroClicked")
			else
				self.rootAnimator:SetTrigger("HeroClicked")
			end
			coroutine.wait(0.28)
		end
    end
	
	-- if texture ~= nil then
		-- self.portraitImage.texture = texture
		-- self.portraitImage.enabled = true
	-- end

    -- 星级 --
    -- local star = staticRoleData:GetStar()
    -- for i = 1, #self.starObjects do
        -- self.starObjects[i]:SetActive(i <= star)
    -- end
	
	--ssr
	local rarity = staticRoleData:GetRarity()
	utility.LoadSpriteFromPath(rarity,self.RarityImage)
	
    -- 种族图标 --
	if not dataOnly then
		utility.LoadRaceIcon(staticRoleData:GetRace(),self.raceIconImage)
        self.raceName.text = Race[staticRoleData:GetRace()]
	end

    -- 卡牌类型 --
    local attributeIndex, attributeText = staticRoleData:GetMajorAttr()

    local attributeColor = require "Utils.GameTools".GetMajorAttrColor(attributeIndex)

    self.attributeLabel.text = attributeText
    self.attributeLabel.color = attributeColor
    utility.LoadMajorIcon(attributeIndex,self.attributeIcon)

    -- 卡牌等级 --
    self.levelLabel.text = string.format("Lv%2d",roleLevel)

    -- 姓名显示
    ReloadNames(self, (staticRoleData:GetInfo()))

    -- 品级颜色 --
    local PropUtility = require "Utils.PropUtility"
    self.qualityRankImage.color = PropUtility.GetColorValue(color)
    if stage <= 0 then
        self.qualityRankText.text = Color[color]
    else
        self.qualityRankText.text = string.format("%s+%d", Color[color], stage)
    end

	if dataOnly then
		return
	end
	
    local _,_,passiveSkillName,passiveSkillDesc,activeSkillName,activeSkillDesc = staticRoleData:GetInfo()

    -- 主动技能描述 --
    self.activeSkillText.text = string.format(">>,<color=#E64747FF>【%s】</color><color=#FFBC1BFF>%s</color>", activeSkillName, activeSkillDesc)
    local sizeDelta = self.activeSkillText.rectTransform.sizeDelta
    sizeDelta.y = self.activeSkillText.preferredHeight + 30
    self.activeSkillText.rectTransform.sizeDelta = sizeDelta
    sizeDelta = self.activeSkillRootTrans.sizeDelta
    sizeDelta.y = self.activeSkillText.preferredHeight + 30 + 8
    self.activeSkillRootTrans.sizeDelta = sizeDelta

    -- 被动技能描述 --
    self.passiveSkillText.text = string.format(">>,<color=#E64747FF>【%s】</color><color=#FFBC1BFF>%s</color>", passiveSkillName, passiveSkillDesc)
    local sizeDelta = self.passiveSkillText.rectTransform.sizeDelta
    sizeDelta.y = self.passiveSkillText.preferredHeight + 30
    self.passiveSkillText.rectTransform.sizeDelta = sizeDelta
    sizeDelta = self.passiveSkillRootTrans.sizeDelta
    sizeDelta.y = self.passiveSkillText.preferredHeight + 30 + 8
    self.passiveSkillRootTrans.sizeDelta = sizeDelta
end

local function Reload(self, staticRoleData, roleLevel, color, stage, dataOnly)

    if self.firstEnter then
        self.portraitImage.enabled = false
    end
	
	if dataOnly then
		OnReload(self, staticRoleData, roleLevel, color, stage, dataOnly)
	else
		utility.LoadRolePortraitImage(staticRoleData:GetId(), self.portraitImage)
		self.portraitImage.enabled = true
		OnReload(self, staticRoleData, roleLevel, color, stage, nil)
	end


end


function HeroDetailLeftViewNode:Refresh(heroID, userRoleData, dataOnly)

    local staticData

    if userRoleData ~= nil then
        staticData = userRoleData:GetStaticData()
        self.userRoleData = userRoleData
    else
        staticData = require "StaticData.Role":GetData(heroID)
    end

    if staticData == nil then
        -- 隐藏/清除函数 --
        return
    end
    local UserDataType = require "Framework.UserDataType"
    
    local needFragments=nil
     local currentFragments=nil
    if userRoleData ~= nil then
        local fragmentBagData = self:GetCachedData(UserDataType.CardChipBagData)
         currentFragments = fragmentBagData:GetCardChipCount(userRoleData:GetScrapId())
        needFragments = userRoleData:GetNeedCardSuipianNum()
    else
        local fragmentBagData = self:GetCachedData(UserDataType.CardChipBagData)
         currentFragments = fragmentBagData:GetCardChipCount(staticData:GetScrapId())
   
    end
  
    if needFragments == nil then
        self.fragmentLabel.text = currentFragments
    else
        self.fragmentLabel.text = currentFragments.."/"..needFragments
    end

    local level = 1
    local color = staticData:GetColorID()
    local stage = 0
    if userRoleData ~= nil then
        level = userRoleData:GetLv()
        color = userRoleData:GetColor()
        stage = userRoleData:GetStage()
    end
	self:GetGame():SendNetworkMessage(require "Network/ServerService".CardCorrCardSkinInfoQueryRequest(heroID))
	self:StartCoroutine(Reload, staticData, level, color, stage, dataOnly)
end

function HeroDetailLeftViewNode:CardCorrCardSkinInfoQueryResult(msg)
	if msg.currSkinId ~= 0 then
		local data = require "StaticData.CardSkin.Skin":GetData(msg.currSkinId)
		local iconPath = data:GetSkinIllust()
		utility.LoadAtlasesSpriteByFullName(iconPath,self.portraitImage)
	end
end

return HeroDetailLeftViewNode