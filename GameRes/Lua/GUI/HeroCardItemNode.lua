local BaseNodeClass = require "Framework.Base.Node"
local utility = require "Utils.Utility"
require "System.LuaDelegate"
require "LUT.StringTable"
require "Const"
local propUtility = require "Utils.PropUtility"

local HeroCardItemNode = Class(BaseNodeClass)

-- 几种模式: 1. 已获得 2. 未获得 3. 碎片模式

function HeroCardItemNode:Ctor()
    self.mode = kCardItemMode_None
    self.selectionMode = kCardItemSelectionMode_Radio
    self.controlStartup = false
    self.isCharacterIconDirty = false
    self.isSelected = false
    self.parentTransform = nil
end

local function IsControlStartup(self)
    return self.controlStartup
end

function HeroCardItemNode:OnInit()
    -- 加载界面
    utility.LoadNewGameObjectAsync("UI/Prefabs/HeroCardItem", function(go)
        self.originalObjectName = go.name
        -- canvas group --
        self.canvasGroup = go:GetComponent(typeof(UnityEngine.CanvasGroup))
        self:BindComponent(go, false)
    end)
end

local function InitControls(self)
    local transform = self:GetUnityTransform():Find("Base")

    ---->> 控件绑定初始化 <<----
    self.mainButton = transform:GetComponent(typeof(UnityEngine.UI.Button))


    -- 角色头像 --
    self.characterIcon = transform:Find("CharacterIcon"):GetComponent(typeof(UnityEngine.UI.Image))

    -- 种族 --
    self.raceIcon = transform:Find("RaceIcon"):GetComponent(typeof(UnityEngine.UI.Image))

    -- 品质边框 --
    self.colorFrame = transform:Find("Frame"):GetComponent(typeof(UnityEngine.UI.Image))

    -- 左边信息框
    self.leftBaseObject = transform:Find("LeftBase").gameObject

    -- 红点 --
    self.redDotImage = transform:Find("RedPoint"):GetComponent(typeof(UnityEngine.UI.Image))

    -- 等级 --
    self.levelLabel = transform:Find("LeftBase/LevelLabel"):GetComponent(typeof(UnityEngine.UI.Text))
    self.levelLabelObject = self.levelLabel.gameObject
    self.levelBaseImage = transform:Find('LeftBase'):GetComponent(typeof(UnityEngine.UI.Image))

    -- 碎片图标 --
    self.fragmentImgObject = transform:Find("LeftBase/FragmentIcon").gameObject
    self.fragmentImgBaseObject = transform:Find('DebrisBase').gameObject

    -- 星星 --
    self.starsObj = transform:Find("CharacterStars").gameObject
    self.stars = {
        transform:Find("CharacterStars/RankStarIcon1").gameObject,
        transform:Find("CharacterStars/RankStarIcon2").gameObject,
        transform:Find("CharacterStars/RankStarIcon3").gameObject,
        transform:Find("CharacterStars/RankStarIcon4").gameObject,
        transform:Find("CharacterStars/RankStarIcon5").gameObject
    }

    -- 底部信息 --
    self.bottomInfoObject = transform:Find("BottomInfo").gameObject

    -- <<已足够>> --
    self.enoughTips = transform:Find("BottomInfo/Bg/EnoughTips"):GetComponent(typeof(UnityEngine.UI.Text))
    self.enoughTipsObject = self.enoughTips.gameObject

    -- <<显示当前碎片的情况>> --
    self.fragmentLabel = transform:Find("BottomInfo/Bg/ProgressLabel"):GetComponent(typeof(UnityEngine.UI.Text))
    self.fragmentLabelObject = self.fragmentLabel.gameObject

    -- 单选组 --
    self.radioObject = transform:Find("OnSelect").gameObject

    -- 多选组 --
    self.checkObject = transform:Find("OnMultiSelect").gameObject
	
	--ssr
	self.RarityImage = transform:Find("Rarity"):GetComponent(typeof(UnityEngine.UI.Image))
end

local function ResetAll(self)
    -- 角色头像
    self.characterIcon.sprite = nil

    -- 左边信息框
    self.leftBaseObject:SetActive(false)

    -- 等级
    self.levelLabelObject:SetActive(false)
    self.levelBaseImage.enabled = false
    self.levelLabel.text = ""

    -- 碎片图标
    self.fragmentImgObject:SetActive(false)
    self.fragmentImgBaseObject:SetActive(false)

    -- 星星
    self.starsObj:SetActive(false)

    -- 底部信息
    self.bottomInfoObject:SetActive(false)

    -- 已足够
    self.enoughTipsObject:SetActive(false)

    -- 碎片情况
    self.fragmentLabelObject:SetActive(false)
    self.fragmentLabel.text = ""

    -- 单选组
    self.radioObject:SetActive(false)

    -- 多选组
    self.checkObject:SetActive(false)

    self:SetCustomName(nil)
end



---> 变更事件处理 <---
local function OnSelectionModeChanged(self)
    local selectionMode = self:GetSelectionMode()
    self.radioObject:SetActive(selectionMode == kCardItemSelectionMode_Radio)
    self.checkObject:SetActive(selectionMode == kCardItemSelectionMode_Check)
end

local function OnCardIDChanged(self)

end

local function OnCardUIDChanged(self)
    self:UpdateRedDotStatus()
end

local function OnCardRaceChanged(self)
    if self.raceIcon ~= nil then
        utility.LoadRaceIcon(self:GetRaceID(),self.raceIcon)

        local mode = self:GetMode()
        if mode == kCardItemMode_NotGetYet then
            self.raceIcon.material = utility.GetGrayMaterial()
        else
            self.raceIcon.material = utility.GetCommonMaterial()
        end
    end
end

local function OnCardLevelChanged(self)
    local mode = self:GetMode()
    if mode == kCardItemMode_Got then
        utility.ASSERT(type(self.cardLevel) == "number" and self.cardLevel > 0, "这个模式要求 self.cardLevel 是个有效值!")

        self.leftBaseObject:SetActive(true)
        self.fragmentImgObject:SetActive(false)
        self.fragmentImgBaseObject:SetActive(false)
        self.levelLabelObject:SetActive(true)
        self.levelBaseImage.enabled = true
        self.levelLabel.text = self.cardLevel
    else
        self.leftBaseObject:SetActive(true)
        self.levelLabelObject:SetActive(false)
        self.levelBaseImage.enabled = false
        self.levelLabel.text = ""
        self.fragmentImgObject:SetActive(true)
        self.fragmentImgBaseObject:SetActive(true)
    end
end

local function OnCardColorIDChanged(self)
    local mode = self:GetMode()
    if mode == kCardItemMode_Got or mode == kCardItemMode_Fragment then
        utility.ASSERT(type(self:GetColorID()) == "number", "这个模式要求 colorID 是个有效值!")
        local color = propUtility.GetRGBColorValue(self:GetColorID())
        self.colorFrame.color = color
    else
        self.colorFrame.color =  UnityEngine.Color(0.5,0.5,0.5,1)
    end
end

local function OnCardStarChanged(self)
    local mode = self:GetMode()
    if mode == kCardItemMode_Got then
        -- local star = self:GetStar()
		--ssr
		self.RarityImage.gameObject:SetActive(true)
		local rarity = self:GetRarity()
		utility.LoadSpriteFromPath(rarity,self.RarityImage)
        -- utility.ASSERT(type(star) == "number" and star > 0, "这个模式要求 star 是个有效值!")
        -- local gametool = require "Utils.GameTools"
        -- gametool.AutoSetRoleStar(self.starsObj.transform,star)
        --for i = 1, #self.stars do
        --    self.stars[i]:SetActive(i <= star)
        --end
        -- self.starsObj:SetActive(true)
    else
		self.RarityImage.gameObject:SetActive(false)
        -- self.starsObj:SetActive(false)
    end
end

local function OnCustomObjectNameChanged(self)
    local customName = self:GetCustomName()
    local gameObject = self:GetUnityGameObject()
    if customName == nil then
        gameObject.name = self.originalObjectName
    else
        gameObject.name = customName
    end
end

local function LoadCardIcon(self)
    utility.LoadRoleHeadIcon(self:GetID(), self.characterIcon)
end

local function OnCardIconNameChanged(self)
    local mode = self:GetMode()

    -- 加载 --
    if self.isCharacterIconDirty then
        utility.ASSERT(type(self:GetID()) == "number" and self:GetID() > 0, "加载头像时 id必须是有效值!")
        LoadCardIcon(self)
        self.isCharacterIconDirty = false
    end

    -- 设置颜色
    if mode == kCardItemMode_Got or mode == kCardItemMode_Fragment then
        self.characterIcon.material = utility.GetCommonMaterial()
    else
        self.characterIcon.material = utility.GetGrayMaterial()
    end
end

local function OnRequiredFragmentNumberChanged(self)
end

local function HasFragmentRedDot(self)
    local requiredNumber = self:GetRequiredFragmentNumber()
    local currentNumber = self:GetCurrentFragmentNumber()
    return self:GetMode() == kCardItemMode_NotGetYet and currentNumber >= requiredNumber
end

local function OnCurrentFragmentNumberChanged(self)
    local mode = self:GetMode()

    self.bottomInfoObject:SetActive(mode == kCardItemMode_NotGetYet or mode == kCardItemMode_Fragment)

    -- 未获得 --
    if mode == kCardItemMode_NotGetYet then
        local requiredNumber = self:GetRequiredFragmentNumber()
        local currentNumber = self:GetCurrentFragmentNumber()
        utility.ASSERT(type(currentNumber) == "number" and currentNumber >= 0, "这个模式要求 currentFragmentNumber 是个有效值!")
        utility.ASSERT(type(requiredNumber) == "number" and requiredNumber > 0, "这个模式要求 requiredFragmentNumber 是个有效值!")

        if currentNumber >= requiredNumber then
            self.enoughTipsObject:SetActive(true)
            self.fragmentLabelObject:SetActive(false)
        else
            self.enoughTipsObject:SetActive(false)
            self.fragmentLabelObject:SetActive(true)
            self.fragmentLabel.text = string.format("%d/%d", currentNumber, requiredNumber)
        end

    -- 碎片模式 --
    elseif mode == kCardItemMode_Fragment then
        local currentNumber = self:GetCurrentFragmentNumber()
        utility.ASSERT(type(currentNumber) == "number" and currentNumber >= 0, "这个模式要求 currentFragmentNumber 是个有效值!")

        self.enoughTipsObject:SetActive(false)
        self.fragmentLabelObject:SetActive(true)
        self.fragmentLabel.text = currentNumber
    end

    -- 拥有的状态 是不显示的 --
    self:UpdateRedDotStatus()
end

local function OnSelectedStatusChanged(self)
    local selectionMode = self:GetSelectionMode()
    local isSelected = self:IsSelected()
    self.radioObject:SetActive(selectionMode == kCardItemSelectionMode_Radio and isSelected)
    self.checkObject:SetActive(selectionMode == kCardItemSelectionMode_Check and isSelected)
end

local function OnParentTransformChanged(self)
    if self.parentTransform ~= nil then
        self:LinkComponent(self.parentTransform)
    end
end

local function OnModeChanged(self)
    -- 不显示 --
    if self.mode == kCardItemMode_None then
        ResetAll(self)
        self.canvasGroup.alpha = 0
        return
    end

    OnCardLevelChanged(self)
    OnCardColorIDChanged(self)
    OnCardStarChanged(self)
    OnCardIconNameChanged(self)
    OnCurrentFragmentNumberChanged(self)
    OnSelectedStatusChanged(self)
    OnCardRaceChanged(self)

    self.canvasGroup.alpha = 1
end


---- 点击事件 ----
local function OnMainButtonClicked(self)
    local messageGuids = require "Framework.Business.MessageGuids"
    self:DispatchEvent(messageGuids.HeroCardItemClicked, nil, self)
end


function HeroCardItemNode:UpdateRedDotStatus()
    --hzj_print(self:GetMode(),"self:GetMode()")
    if self:GetMode() == kCardItemMode_Got then
        
        local CalculateRed = require "Utils.CalculateRed"
        local flag  = CalculateRed.GetChooseRoleRedData(self:GetID())
        self.redDotImage.enabled = flag
        --hzj_print(self:GetID(),"self:GetID()",flag)
    end
end

---> 控件初始化 <---
local function SetControls(self)
    -- 初始化控件 --
    self.isCharacterIconDirty = true
    OnModeChanged(self)
    OnParentTransformChanged(self)
    OnCustomObjectNameChanged(self)
    self:UpdateRedDotStatus()
end

local function ResetControls(self)
    -- 清除控件状态 --
    ResetAll(self)
end

function HeroCardItemNode:OnComponentReady()
    InitControls(self)
end

function HeroCardItemNode:OnResume()
    HeroCardItemNode.base.OnResume(self)

    SetControls(self)

    -- 注册点击事件 --
    self.__event_mainButtonClicked__ = UnityEngine.Events.UnityAction(OnMainButtonClicked, self)
    self.mainButton.onClick:AddListener(self.__event_mainButtonClicked__)

    self.controlStartup = true
end

function HeroCardItemNode:OnPause()
    HeroCardItemNode.base.OnPause(self)

    ResetControls(self)

    -- 取消点击事件 --
    if self.__event_mainButtonClicked__ then
        self.mainButton.onClick:RemoveListener(self.__event_mainButtonClicked__)
        self.__event_mainButtonClicked__ = nil
    end

    self.controlStartup = false
end


---> 控件设置 <---

-- 模式
function HeroCardItemNode:SetMode(mode)
    if self.mode ~= mode then
        self.mode = mode
        if self.controlStartup then
            OnModeChanged(self)
        end
    end
end

function HeroCardItemNode:GetMode()
    return self.mode
end

-- 选择模式
function HeroCardItemNode:SetSelectionMode(mode)
    if self.selectionMode ~= mode then
        self.selectionMode = mode
        if self.controlStartup then
            OnSelectionModeChanged(self)
        end
    end
end

function HeroCardItemNode:GetSelectionMode()
    return self.selectionMode
end

-- ID
function HeroCardItemNode:SetID(id)
    if self.cardId ~= id then
        self.cardId = id
        if self.controlStartup then
            OnCardIDChanged(self)
        end
    end
end

function HeroCardItemNode:GetID()
    return self.cardId
end

-- UID
function HeroCardItemNode:SetUID(uid)
    if self.cardUID ~= uid then
        self.cardUID = uid
        if self.controlStartup then
            OnCardUIDChanged(self)
        end
    end
end

function HeroCardItemNode:GetUID()
    return self.cardUID
end

-- 种族
function HeroCardItemNode:SetRaceID(raceID)
    if self.raceID ~= raceID then
        self.raceID = raceID
        OnCardRaceChanged(self)
    end
end

function HeroCardItemNode:GetRaceID()
    return self.raceID
end

-- 等级
function HeroCardItemNode:SetLevel(level)
    if self.cardLevel ~= level then
        self.cardLevel = level
        if self.controlStartup then
            OnCardLevelChanged(self)
        end
    end
end

function HeroCardItemNode:GetLevel()
    return self.cardLevel
end

-- 设置颜色ID --
function HeroCardItemNode:SetColorID(color)
    if self.cardColorID ~= color then
        self.cardColorID = color
        if self.controlStartup then
            OnCardColorIDChanged(self)
        end
    end
end

function HeroCardItemNode:GetColorID()
    return self.cardColorID
end

-- 设置星星 --
function HeroCardItemNode:SetStar(star)
    if self.cardStar ~= star then
        self.cardStar = star
        if self.controlStartup then
            OnCardStarChanged(self)
        end
    end
end

function HeroCardItemNode:SetRarity(rarity)
    if self.rarity ~= rarity then
        self.rarity = rarity
        if self.controlStartup then
            OnCardStarChanged(self)
        end
    end
end

function HeroCardItemNode:GetStar()
    return self.cardStar
end

function HeroCardItemNode:GetRarity()
    return self.rarity
end

-- 设置卡牌头像的路径名 --
function HeroCardItemNode:SetIconName(iconName)
    if self.cardIconName ~= iconName then
        self.cardIconName = iconName
        self.isCharacterIconDirty = true
        if self.controlStartup then
            OnCardIconNameChanged(self)
        end
    end
end

function HeroCardItemNode:GetIconName()
    return self.cardIconName
end

-- 合成卡牌所需碎片数 --
function HeroCardItemNode:SetRequiredFragmentNumber(number)
    if self.requiredFragmentNumber ~= number then
        self.requiredFragmentNumber = number
        if self.controlStartup then
            OnRequiredFragmentNumberChanged(self)
        end
    end
end

function HeroCardItemNode:GetRequiredFragmentNumber()
    return self.requiredFragmentNumber
end

-- 当前卡牌的个数 --
function HeroCardItemNode:SetCurrentFragmentNumber(number)
    if self.currentFragmentNumber ~= number then
        self.currentFragmentNumber = number

        if self.controlStartup then
            OnCurrentFragmentNumberChanged(self)
        end
    end
end

function HeroCardItemNode:GetCurrentFragmentNumber()
    return self.currentFragmentNumber
end

-- 是否选中 --
function HeroCardItemNode:SetSelected(selected)
    self.isSelected = selected

    if self.controlStartup then
        OnSelectedStatusChanged(self)
    end
end

function HeroCardItemNode:IsSelected()
    return self.isSelected
end

-- 设置父对象 --
function HeroCardItemNode:SetParentTransform(parentTransform)
    self.parentTransform = parentTransform

    if self.controlStartup then
        OnParentTransformChanged(self)
    end
end

function HeroCardItemNode:GetParentTransform()
    return self.parentTransform
end

function HeroCardItemNode:SetExtraData(data)
    self.extraData = data
end

function HeroCardItemNode:GetExtraData(data)
    return self.extraData
end

-- 自定义名字 --
function HeroCardItemNode:GetCustomName()
    return self.customObjectName
end

function HeroCardItemNode:SetCustomName(name)
    if self.customObjectName ~= name then
        self.customObjectName = name

        if self.controlStartup then
            OnCustomObjectNameChanged(self)
        end
    end
end

return HeroCardItemNode