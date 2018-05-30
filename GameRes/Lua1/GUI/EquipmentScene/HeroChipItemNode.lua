
local BaseNodeClass = require "Framework.Base.Node"
local utility = require "Utils.Utility"
require "System.LuaDelegate"

--local InitialCardItemNode = Class(BaseNodeClass)

local HeroChipItemNode = Class(BaseNodeClass)

function HeroChipItemNode:Ctor(data, parentTransform)
    self.heroChipData = data
    self.cardSuipianID = self.heroChipData.cardSuipianID
    self.number = self.heroChipData.number
    self.parentTransform = parentTransform
    self.callback = LuaDelegate.New()

    self:GetHeroChipData(self.cardSuipianID)
end

function HeroChipItemNode:GetHeroId()
    return self.heroData:GetId()
end

function HeroChipItemNode:GetChipShowData()
    -- 返回右侧图像显示数据
    return self.monolog,self.portraitImage
end

function HeroChipItemNode:OnInit()
    -- 加载界面(只走一次)
    utility.LoadNewGameObjectAsync('UI/Prefabs/HeroCardItem', function(go)
        self:BindComponent(go, false)
    end)
end

-----------------------------------------------------------------------
--- 回调
-----------------------------------------------------------------------
function HeroChipItemNode:SetCallback(table, func)
    self.callback:Set(table, func)
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function HeroChipItemNode:GetHeroChipData(id)
    local infoData,data,itemName ,iconPath =  require "Utils.GameTools".GetItemDataById(id)
    
    self.itemName = itemName
    self.iconPath = iconPath
    self.majorAttr = data:GetMajorAttr()
    self.monolog = infoData:GetMonolog()
    self.composeNum = data:GetComposeNum()
    local portraitImage = data:GetPortraitImage()
    self.portraitImage = portraitImage
end

function HeroChipItemNode:OnComponentReady()
    self:LinkComponent(self.parentTransform)
    self:InitControls()
    
end

function HeroChipItemNode:OnResume()
    HeroChipItemNode.base.OnResume(self)

    self:RegisterControlEvents()
    self:ResetChipView()
end

function HeroChipItemNode:OnPause()
    HeroChipItemNode.base.OnPause(self)

    self:UnregisterControlEvents()
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
local function UpdateCardAttributeIcon(self)
    local attr = self.majorAttr

    local iconControl

    if attr == 0 then
        self.CardBasisHeroPowerAttributeIcon.gameObject:SetActive(true)
        iconControl = self.CardBasisHeroPowerAttributeIcon
    elseif attr == 1 then
        self.CardBasisHeroQuickAttributeIcon.gameObject:SetActive(true)
        iconControl = self.CardBasisHeroQuickAttributeIcon
        else
        self.CardBasisHeroIntelligenceAttributeIcon.gameObject:SetActive(true)
        iconControl = self.CardBasisHeroIntelligenceAttributeIcon
    end

    
    iconControl.material = utility.GetCommonMaterial()
    
end


function HeroChipItemNode:InitControls()
    self.myGame = utility:GetGame()
     local transform = self:GetUnityTransform()
     self.gameObject = transform.gameObject

    self.BaseButton = transform:Find('Base'):GetComponent(typeof(UnityEngine.UI.Button))

    self.CardBasisHeroListHeadIcon1 = transform:Find("Base/CardBasisHeroListHeadIcon1"):GetComponent(typeof(UnityEngine.UI.Image))
    self.CardBasisHeroListHeadIcon1.material = utility.GetCommonMaterial()
    
    self.HeadFrame1 = transform:Find('Base/HeadFrame1'):GetComponent(typeof(UnityEngine.UI.Image))
    self.HeadFrame1.material = utility.GetCommonMaterial()
    
    self.CardBasisHeroPowerAttributeIcon = transform:Find('Base/CardBasisHeroPowerAttributeIcon'):GetComponent(typeof(UnityEngine.UI.Image))
    self.CardBasisHeroQuickAttributeIcon = transform:Find('Base/CardBasisHeroQuickAttributeIcon'):GetComponent(typeof(UnityEngine.UI.Image))
    self.CardBasisHeroIntelligenceAttributeIcon = transform:Find('Base/CardBasisHeroIntelligenceAttributeIcon'):GetComponent(typeof(UnityEngine.UI.Image))
    UpdateCardAttributeIcon(self)

    self.Lv_Title1 = transform:Find('Base/Lv1/Lv_Title1').gameObject
    self.Lv_Title1:SetActive(false)
    
    --self.UpLvButton1 = transform:Find('Base/UpLvButton1'):GetComponent(typeof(UnityEngine.UI.Button))
    --self.UpLvButton1.gameObject:SetActive(true)

    self.CardBasisHeroListNameLabel1 = transform:Find("Base/CardBasisHeroListNameLabel1"):GetComponent(typeof(UnityEngine.UI.Text))
    self.CardChipNumObject = transform:Find("Base/Debris").gameObject
    self.CardChipNumObject:SetActive(true)
    self.CardChipNumLabel = transform:Find("Base/Debris/CardBasisHeroDebrisMaskLabel"):GetComponent(typeof(UnityEngine.UI.Text))
    
end

function HeroChipItemNode:RegisterControlEvents()

end

function HeroChipItemNode:UnregisterControlEvents()

end

function HeroChipItemNode:RegisterControlEvents()
    -- 注册 Base 的事件
    self.__event_button_onBaseClicked__ = UnityEngine.Events.UnityAction(self.OnBaseClicked, self)
    self.BaseButton.onClick:AddListener(self.__event_button_onBaseClicked__)
end

function HeroChipItemNode:UnregisterControlEvents()
    -- 取消注册 Base 的事件
    if self.__event_button_onBaseClicked__ then
        self.BaseButton.onClick:RemoveListener(self.__event_button_onBaseClicked__)
        self.__event_button_onBaseClicked__ = nil
    end
end
-----------------------------------------------------------------------------------------------
function HeroChipItemNode:OnCardSuipianBuildRequest(id)
    self.myGame:SendNetworkMessage( require"Network/ServerService".CardSuipianBuildRequest(id))
end


-----------------------------------------------------------------------------------------------

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function HeroChipItemNode:OnBaseClicked()
    print(self.cardSuipianID)
    self.callback:Invoke(self.monolog,self.portraitImage)

    --[[
    if self.canBuildCard then
        self:OnCardSuipianBuildRequest(self.cardSuipianID)
    end
    --]]
end

function HeroChipItemNode:RefresheChipData(data)
    self.heroChipData = data
    if  self.heroChipData == nil then
        self.number = 0
    else
        self.cardSuipianID = self.heroChipData.cardSuipianID
        self.number = self.heroChipData.number
    end

    self:ResetChipView()
end


function HeroChipItemNode:ResetChipView()
    -- 数量小于0 隐藏操作
    if self.number <= 0 then
        self.gameObject:SetActive(false)
        return
    end

    -- 查询数据
    local _,data,itemName =  require "Utils.GameTools".GetItemDataById(self.cardSuipianID)

    self.CardBasisHeroListNameLabel1.text = itemName
    

    local UserDataType = require "Framework.UserDataType"

    local cardBagData = self:GetCachedData(UserDataType.CardBagData)

    local cardId = data:GetId()
    local cardUid = string.format("c:%s",cardId)

    local roleCard = cardBagData:GetRoleByUid(cardUid)
    --roleCard.number
    self.CardChipNumLabel.text = tostring(self.number)

    --[[
    if self.number < self.composeNum then
        -- 数量小于可合成可合成数量
        self.CardChipNumLabel.text = tostring(self.number).."/"..tostring(self.composeNum)
        self.canBuildCard = false
    else
        if  roleCard == nil then
             -- 数量大于可合成数量 并且没有此卡
            self.CardChipNumLabel.text = "可合成"
            self.canBuildCard = true
        else
            -- 数量大于可合成数量 有此卡
            self.CardChipNumLabel.text = tostring(self.number)
            self.canBuildCard = false
        end
    end
    --]]
   

   utility.LoadSpriteFromPath(string.format(self.iconPath),self.CardBasisHeroListHeadIcon1)

end



return HeroChipItemNode