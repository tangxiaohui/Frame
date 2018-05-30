local BaseNodeClass = require "Framework.Base.Node"
local utility = require "Utils.Utility"
local messageGuids = require "Framework.Business.MessageGuids"

local TarotProgressPanel = Class(BaseNodeClass)

-----------------------------------------------------------------------
--- 私有函数
-----------------------------------------------------------------------
local function DespawnAllItems(self)
    local count = self.propertyMap:Count()
    for i = 1, count do
        local item = self.propertyMap:GetEntryByIndex(i)
        self.contentProvider:DespawnItem(item)
        self:RemoveChild(item)
    end
    self.propertyMap:Clear()
end

local function SpawnAllItems(self)
    local UserDataType = require "Framework.UserDataType"
    local tarotData = self:GetCachedData(UserDataType.TarotData)
    local progressData = require "StaticData.Tarot.TarotProgress":GetData(tarotData:GetTarotProgressId())
    local propertySet = progressData:GetProperties()
    propertySet:Foreach(function(propertyId, propertyValue)
        if propertyId > 0 and propertyValue > 0 then
            local item = self.contentProvider:SpawnItem(self.contentTransform)
            self.propertyMap:Add(propertyId, item)
            item:Set(propertyId, propertyValue)
            self:AddChild(item)
        end
    end)
end

local function UpdateRedDot(self)
    self.redDotImage.enabled = require "Utils.TarotUtils".CanActiveTarotProgress()
end

local function InitControls(self)
    local transform = self:GetUnityTransform()
    self.alreadyActivatedNumLabel = transform:Find("Info/Now/NumLabel"):GetComponent(typeof(UnityEngine.UI.Text))
    self.nextProgressNumLabel = transform:Find("Info/Next/NumLabel"):GetComponent(typeof(UnityEngine.UI.Text))
    self.priceObject = transform:Find("Price").gameObject
    self.priceLabel = transform:Find("Price/PriceLabel"):GetComponent(typeof(UnityEngine.UI.Text))
    self.redDotImage = transform:Find("Price/RedDot"):GetComponent(typeof(UnityEngine.UI.Image))
    self.coinIconImage = transform:Find("Price/CoinIcon"):GetComponent(typeof(UnityEngine.UI.Image))
    self.contentTransform = transform:Find("ProgressList/Scroll View/Viewport/Content")
    self.activeButton = transform:Find("Price/ActiveButton"):GetComponent(typeof(UnityEngine.UI.Button))

    -- 缓存属性 --
    require "Collection.OrderedDictionary"
    self.propertyMap = OrderedDictionary.New()

    SpawnAllItems(self)
end

local function GetTarotData(self)
    local UserDataType = require "Framework.UserDataType"
    return self:GetCachedData(UserDataType.TarotData)
end

local function UpdateTotalOfCards(self)
    self.alreadyActivatedNumLabel.text = GetTarotData(self):GetNumOfTarotCards() .. "张"
end

local function UpdateProgressInfo(self)
    local progressData = require "StaticData.Tarot.TarotProgress":GetData(GetTarotData(self):GetTarotProgressId())
    self.nextProgressNumLabel.text = progressData:GetConditionTarotNum() .. "张"
    self.priceLabel.text = progressData:GetItemNum()

    -- 当为最高级的时候, 隐藏显示 --
    if progressData:GetNextId() == 0 then
        self.priceObject:SetActive(false)
        return
    end

    -- 判断道具是否存在 --
    if utility.IsItemEnough(progressData:GetItemId(), progressData:GetItemNum()) then
        self.priceLabel.color = UnityEngine.Color(1, 1, 1, 1)
    else
        self.priceLabel.color = UnityEngine.Color(1, 0, 0, 1)
    end

    local gameTool = require "Utils.GameTools"
    local _,_,_,icon_2 = gameTool.GetItemDataById(progressData:GetItemId())
    utility.LoadSpriteFromPath(icon_2, self.coinIconImage)
     
    self.priceObject:SetActive(true)
end

local function SetControls(self)
    UpdateTotalOfCards(self)
    UpdateRedDot(self)
    UpdateProgressInfo(self)
end

local function OnActiveConfirm(self)
    local ServerService = require "Network.ServerService"
    self:GetGame():SendNetworkMessage(ServerService.TarotProgressActiveRequest(GetTarotData(self):GetTarotProgressId()))
end

local function OnActiveCancel(self)
    debug_print("NO")
end

local function OnActiveButtonClicked(self)
    utility.ShowConfirmDialog(TarotCardStateTable[6],self,OnActiveConfirm,OnActiveCancel)
end

local function OnTarotProgressChanged(self, msg)
    if msg.success then
        DespawnAllItems(self)
        SpawnAllItems(self)
        SetControls(self)
    end
end

local function OnTarotCardStateChanged(self, msg)
    if msg.success then
        UpdateTotalOfCards(self)
        UpdateRedDot(self)
    end
end

local function RegisterEvents(self)
    self.__event_button_activeButtonClicked__ = UnityEngine.Events.UnityAction(OnActiveButtonClicked, self)
    self.activeButton.onClick:AddListener(self.__event_button_activeButtonClicked__)

    self:RegisterEvent(messageGuids.TarotProgressChanged, OnTarotProgressChanged)
    self:RegisterEvent(messageGuids.TarotCardStateChanged, OnTarotCardStateChanged)
end

local function UnregisterEvents(self)
    if self.__event_button_activeButtonClicked__ then
        self.activeButton.onClick:RemoveListener(self.__event_button_activeButtonClicked__)
        self.__event_button_activeButtonClicked__ = nil
    end

    self:UnregisterEvent(messageGuids.TarotProgressChanged, OnTarotProgressChanged)
    self:UnregisterEvent(messageGuids.TarotCardStateChanged, OnTarotCardStateChanged)
end

function TarotProgressPanel:Ctor(transform, contentProvider)
    self.contentProvider = contentProvider
    self:BindComponent(transform.gameObject, false)
    InitControls(self)
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function TarotProgressPanel:OnInit()
end

function TarotProgressPanel:OnComponentReady()
end

function TarotProgressPanel:OnResume()
    TarotProgressPanel.base.OnResume(self)
    SetControls(self)
    RegisterEvents(self)
end

function TarotProgressPanel:OnPause()
    TarotProgressPanel.base.OnPause(self)
    UnregisterEvents(self)
    DespawnAllItems(self)
end

function TarotProgressPanel:OnCleanup()
    TarotProgressPanel.base.OnCleanup(self)
end


-----------------------------------------------------------------------
--- 外部接口
-----------------------------------------------------------------------

return TarotProgressPanel
