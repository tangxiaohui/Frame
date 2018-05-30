local BaseNodeClass = require "Framework.Base.Node"
local utility = require "Utils.Utility"
require "LUT.StringTable"

local TarotLineupItem = Class(BaseNodeClass)

-----------------------------------------------------------------------
--- 私有函数
-----------------------------------------------------------------------
local function InitControls(self)
    local transform = self:GetUnityTransform()
    self.contentPoint = transform:Find("Point")
    self.button = transform:Find("Button"):GetComponent(typeof(UnityEngine.UI.Button))

    self.redDotImage = transform:Find("Status/Base/RedDot"):GetComponent(typeof(UnityEngine.UI.Image))

    self.tarotStateLabel = transform:Find("Status/NameLabel"):GetComponent(typeof(UnityEngine.UI.Text))
    
    self.nextTitleLabel = transform:Find("Status/Status/NextLabel"):GetComponent(typeof(UnityEngine.UI.Text))
    self.propertyNameLabel = transform:Find("Status/Status/NameLabel"):GetComponent(typeof(UnityEngine.UI.Text))
    self.topestTitleLabel = transform:Find("Status/Status/TopestLabel"):GetComponent(typeof(UnityEngine.UI.Text))

    -- 下一级
    self.nextTitleLabel.text = TarotCardStateTable[3]

    -- 最高级
    self.topestTitleLabel.text = TarotCardStateTable[5]

    -- 默认先隐藏这些
    self.nextTitleLabel.enabled = false
    self.propertyNameLabel.enabled = false
    self.topestTitleLabel.enabled = false
end

local function GetLocationPropertyFormatName(currentPropertyId, nextPropertyId)
    if currentPropertyId == nextPropertyId then
        return TarotCardStateTable[4]
    end
    return "%s"
end

local function SetControls(self)
    local currentStage = self.tarotCardControl:GetStage()
    if currentStage == -1 then
        error("当前阶段无效")
    end

    -- 先显示当前
    self.tarotStateLabel.text = TarotCardStateTable[currentStage]

    -- 下一级
    local nextStage = self.tarotCardControl:GetNextStage()
    if nextStage == -1 then
        self.nextTitleLabel.enabled = false
        self.propertyNameLabel.enabled = false
        self.topestTitleLabel.enabled = true
        return -- 没有下一级, 不能显示属性了!
    else
        self.nextTitleLabel.enabled = true
        self.propertyNameLabel.enabled = true
        self.topestTitleLabel.enabled = false
    end

    -- 赋值
    local currentPropertyId = (self.tarotCardControl:GetStageProperty(currentStage))
    local nextPropertyId = (self.tarotCardControl:GetStageProperty(nextStage))
    local PropertyUtils = require "Utils.PropertyUtils"
    local _, propertyName = PropertyUtils.GetProperty(nextPropertyId) 
    self.propertyNameLabel.text = string.format(
        GetLocationPropertyFormatName(currentPropertyId, nextPropertyId),
        propertyName
    )
end

local function OnButtonClicked(self)
    -- 如果是顶级, 不让点击!
    local nextStage = self.tarotCardControl:GetNextStage()
    if nextStage == -1 then
        return
    end
    
    -- 弹出激活窗口
    self:GetWindowManager():Show(
        require "GUI.Tarot.TarotCardActiveModule",
        self.tarotId
    )
end

local function RegisterEvents(self)
    self.__event_button_buttonClicked__ = UnityEngine.Events.UnityAction(OnButtonClicked, self)
    self.button.onClick:AddListener(self.__event_button_buttonClicked__)
end

local function UnregisterEvents(self)
    if self.__event_button_buttonClicked__ then
        self.button.onClick:RemoveListener(self.__event_button_buttonClicked__)
        self.__event_button_buttonClicked__ = nil
    end
end

-- 设置数据!
function TarotLineupItem:Ctor(tarotId, parentTransform)
    self.tarotId = tarotId
    self.parentTransform = parentTransform
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function TarotLineupItem:OnInit()
    -- 加载界面(只走一次)
    utility.LoadNewGameObjectAsync("UI/Prefabs/TarotLineUpItem", function(go)
		self:BindComponent(go)
	end)
end

function TarotLineupItem:OnComponentReady()
    InitControls(self)
    local TarotCardItemClass = require "GUI.Tarot.TarotCardItem"
    self.tarotCardControl = TarotCardItemClass.New(self.tarotId, self.contentPoint)
    self:AddChild(self.tarotCardControl)
end

function TarotLineupItem:OnResume()
    TarotLineupItem.base.OnResume(self)
    self:LinkComponent(self.parentTransform, true)
    SetControls(self)
    self:UpdateRedDot()
    RegisterEvents(self)
end

function TarotLineupItem:OnPause()
    TarotLineupItem.base.OnPause(self)
    UnregisterEvents(self)
end

function TarotLineupItem:OnCleanup()
    utility.UnloadResource("UI/Prefabs/TarotLineUpItem", typeof(UnityEngine.GameObject))
    TarotLineupItem.base.OnCleanup(self)
end

-----------------------------------------------------------------------
--- 外部接口
-----------------------------------------------------------------------
function TarotLineupItem:Update()
    if self:IsRunning() then
        SetControls(self)
        self.tarotCardControl:Update()
    end
end

function TarotLineupItem:CrossFade(callback)
    self.tarotCardControl:CrossFade(callback)
end

function TarotLineupItem:UpdateRedDot()
    -- 显示红点 --
    self.redDotImage.enabled = require "Utils.TarotUtils".CanActiveTheTarotCard(self.tarotId)
end

return TarotLineupItem