--
-- User: fbmly
-- Date: 4/17/17
-- Time: 9:38 PM
--

local BaseNodeClass = require "Framework.Base.Node"
local utility = require "Utils.Utility"

local GeneralItem = Class(BaseNodeClass)

function GeneralItem:Ctor(parentTransform, itemID, itemNum, itemColor, itemLevel, gemId1, gemId2)
    self:Set(parentTransform, itemID, itemNum, itemColor, itemLevel, gemId1, gemId2)
end

function GeneralItem:Set(parentTransform, itemID, itemNum, itemColor, itemLevel, gemId1, gemId2)
    if not self:IsRunning() then
        self.parentTransform = parentTransform
        self.itemID = itemID
        self.itemNum = itemNum
        self.itemColor = itemColor
        self.itemLevel = itemLevel
        self.gemId1 = gemId1
        self.gemId2 = gemId2
        return
    end
    error("不能改变!")
end

function GeneralItem:OnInit()
    -- 加载界面(只走一次)
    print("OnInit")
    utility.LoadNewGameObjectAsync('UI/Prefabs/MyGeneralItem', function(go)
        self:BindComponent(go, false)
    end)
end

function GeneralItem:SetScaleFactor(x, y, z)
    if not self:HasUnityGameObject() then
        self.resetScale = true
        self.scaleX = x or 1
        self.scaleY = y or 1
        self.scaleZ = z or 1
        return
    end

    local transform = self:GetUnityTransform()

    if self.resetScale then
        transform.localScale = Vector3(self.scaleX, self.scaleY, self.scaleZ)
        self.resetScale = nil
        self.scaleX = nil
        self.scaleY = nil
        self.scaleZ = nil
    else
        transform.localScale = Vector3(x or 1, y or 1, z or 1)
    end
end

function GeneralItem:OnComponentReady()
    self:InitControls()
end

local function LoadGemObject(gemObject, gemImage, gemId)
    local GameTools = require "Utils.GameTools"
    local _,_,_,iconPath = GameTools.GetItemDataById(gemId)
    utility.LoadSpriteFromPath(iconPath,gemImage)
    gemObject:SetActive(true)
end

local function SetEquipControls(self, staticData)
    if self.equipFlagObject == nil or self.gem1Object == nil or self.gem2Object == nil or self.equipLevelLabel == nil or self.raceIconObject == nil then
        return
    end

    self.raceIconObject:SetActive(false)
    self.gem1Object:SetActive(false)
    self.gem2Object:SetActive(false)
    self.equipLevelLabel.gameObject:SetActive(false)

    local KEquipType = staticData:GetType()

    if type(self.gemId1) == "number" and self.gemId1 > 0 then
        LoadGemObject(self.gem1Object, self.gem1Image, self.gemId1)
    end

    if type(self.gemId2) == "number" and self.gemId2 > 0 then
        LoadGemObject(self.gem2Object, self.gem2Image, self.gemId2)
    end

    local taozhuangID = staticData:GetTaozhuangID()
    self.equipFlagObject:SetActive(type(taozhuangID) == "number" and taozhuangID > 0)

    --debug_print("物品等级", self.itemLevel)
    --KEquipType_EquipAccessories = 3 ---  3.饰品
    --KEquipType_EquipShoesr = 4      ---  4.鞋子
    
    if type(self.itemLevel) == "number" and self.itemLevel > 0 then
        if KEquipType ~= KEquipType_EquipAccessories and KEquipType ~= KEquipType_EquipShoesr then
            self.equipLevelLabel.gameObject:SetActive(true)
            self.equipLevelLabel.text = string.format("Lv%d", self.itemLevel)
        end
    end

    -- 宠物的时候显示种族图标 -- 
    if KEquipType == KEquipType_EquipPet and staticData:GetRaceAdd() > 0 then
        utility.LoadRaceIcon(staticData:GetRaceAdd() ,self.raceIconImage)
        self.raceIconObject:SetActive(true)
    end
end

local function SetControls(self)
    local AtlasesLoader = require "Utils.AtlasesLoader"

    local GameTools = require "Utils.GameTools"
    local _,staticData,_,iconPath,itemType = GameTools.GetItemDataById(self.itemID)
    local defaultColor = GameTools.GetItemColorByType(itemType, staticData)

    -- 显示/隐藏 碎片图标 --
    if itemType == "RoleChip" or  itemType == "EquipChip" then
        self.DebrisIcon:SetActive(true)
        self.DebrisCorner:SetActive(true)
    else
    	self.DebrisIcon:SetActive(false)
        self.DebrisCorner:SetActive(false)
    end

    -- debug_print("@ itemType", itemType)

    if itemType == "Equip" then
        SetEquipControls(self, staticData)
    end

    -- 设置图标
	utility.LoadSpriteFromPath(iconPath,self.ItemIcon)

    -- 设置颜色
    local PropUtility = require "Utils.PropUtility"
    --    print("颜色 颜色 颜色 颜色", self.itemColor,self.ColorFrameGroupTrans)
    PropUtility.AutoSetRGBColor(self.ColorFrameGroupTrans, self.itemColor or defaultColor)

    self:SetScaleFactor(0.91, 0.91, 1)

    if not self.itemNum or self.itemNum <= 1 then
        self.NumLabel.text = ""
    else
        self.NumLabel.gameObject:SetActive(true)
        self.NumLabel.text = self.itemNum
    end
end

local function ResetControls(self)
    self.ItemIcon.sprite = nil
    self.itemLevel = nil
end

function GeneralItem:OnResume()
    GeneralItem.base.OnResume(self)
    self:LinkComponent(self.parentTransform, true)
    SetControls(self)
    self:RegisterControlEvents()
end

function GeneralItem:OnPause()
    GeneralItem.base.OnPause(self)
    ResetControls(self)
    self:UnregisterControlEvents()
end

local function FindObject(transform, name)
    local t = transform:Find(name)
    if t == nil then
        return nil
    end
    return t.gameObject
end

local function FindComponent(transform, name, type)
    local t = transform:Find(name)
    if t == nil then
        return nil
    end
    return t:GetComponent(type)
end

function GeneralItem:InitControls()
    local transform = self:GetUnityTransform()

    self.NumLabel = transform:Find("GeneralItemNumLabel"):GetComponent(typeof(UnityEngine.UI.Text))
    self.ItemIcon = transform:Find("ItemIcon"):GetComponent(typeof(UnityEngine.UI.Image))
    self.ColorFrameGroupTrans = transform:Find("Frame")
    self.infoButton = transform:Find("ItemInfoButton"):GetComponent(typeof(UnityEngine.UI.Button))

    -- 碎片图标 --
    self.DebrisIcon = transform:Find("DebrisIcon").gameObject
    self.DebrisCorner = transform:Find("DebrisCorner").gameObject

    -- >>> 装备相关 <<< --
    self.equipFlagObject = FindObject(transform, "Flag") -- 装备套装

    -- 第一个宝石 
    self.gem1Object = FindObject(transform, "Gems/ButtonBox/Gem1")
    self.gem1Image = FindComponent(transform, "Gems/ButtonBox/Gem1/Image", typeof(UnityEngine.UI.Image))
    
    -- 第二个宝石
    self.gem2Object = FindObject(transform, "Gems/ButtonBox/Gem2")
    self.gem2Image = FindComponent(transform, "Gems/ButtonBox/Gem2/Image", typeof(UnityEngine.UI.Image))

    -- 装备等级
    self.equipLevelLabel = FindComponent(transform,"ItemLevelLabel",typeof(UnityEngine.UI.Text))

    self.raceIconObject = FindObject(transform, "RaceIconImage")
    self.raceIconImage = FindComponent(transform, "RaceIconImage", typeof(UnityEngine.UI.Image))
    self.redDotImage = FindComponent(transform, "RedDot", typeof(UnityEngine.UI.Image))
    if self.redDotImage ~= nil then
      self.redDotImage.gameObject:SetActive(false)
    end
end

function GeneralItem:RegisterControlEvents()
	self._event_button_onInfoButtonClicked_ = UnityEngine.Events.UnityAction(self.OnInfoButtonClicked,self)
	self.infoButton.onClick:AddListener(self._event_button_onInfoButtonClicked_)
end

function GeneralItem:UnregisterControlEvents()
	if self._event_button_onInfoButtonClicked_ then
		self.infoButton.onClick:RemoveListener(self._event_button_onInfoButtonClicked_)
		self._event_button_onInfoButtonClicked_ = nil
	end
end

function GeneralItem:OnInfoButtonClicked()
    require "Utils.GameTools".ShowItemWin(self.itemID)
	-- local windowManager = utility:GetGame():GetWindowManager()
	-- windowManager:Show(require "GUI.CommonItemWin",self.itemID)
end

function GeneralItem:SetRedDot(flag)
   -- hzj_print(flag,"SetRedDot",self.itemID,self.redDotImage.enabled)
    self.redDotImage.gameObject:SetActive(flag)
    --hzj_print(flag,"SetRedDot",self.itemID,self.redDotImage.enabled)

end

return GeneralItem

