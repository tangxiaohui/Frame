--
-- User: fenghao
-- Date: 5/29/17
-- Time: 2:49 PM
--

local BaseNodeClass = require "Framework.Base.WindowNode"

local PlayerCurrencyBarPanel = Class(BaseNodeClass)

local windowUtility = require "Framework.Window.WindowUtility"

local utility = require "Utils.Utility"
require "LUT.StringTable"

windowUtility.SetMutex(PlayerCurrencyBarPanel, true)

function PlayerCurrencyBarPanel:Ctor()
    self.isShow = true
end

function PlayerCurrencyBarPanel:GetRootHangingPoint()
    return self:GetUIManager():GetForegroundLayer()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function PlayerCurrencyBarPanel:OnInit()
    utility.LoadNewGameObjectAsync('UI/Prefabs/CurrencyBarPanel', function(go)
        self:BindComponent(go)
    end)
end

function PlayerCurrencyBarPanel:OnComponentReady()
    self:InitControls()
end

local function OnUpdateText(self, value, owner)
    owner.text = utility.ConvertCurrencyUnit(tostring(utility.ToInteger(value)))
end

local function OnUpdate(self)
    self.CoinLabel:Update()
    self.DiamondLabel:Update()
end

function PlayerCurrencyBarPanel:InitControls()
    local transform = self:GetUnityTransform()

    local AnimatedValueControlClass = require "GUI.Controls.AnimatedValueControl"

    self.VigorLabel = transform:Find("Currency/TiLi/TheMainTiLiLabel"):GetComponent(typeof(UnityEngine.UI.Text))            -- 体力
    self.CoinLabel = AnimatedValueControlClass.New(transform:Find("Currency/Money/TheMainMoneyLabel"):GetComponent(typeof(UnityEngine.UI.Text)))           -- 金币
    self.CoinLabel:SetCallbackOnUpdate(self, OnUpdateText)
    self.DiamondLabel = AnimatedValueControlClass.New(transform:Find("Currency/Diamond/TheMainDiamondLabel"):GetComponent(typeof(UnityEngine.UI.Text)))    -- 钻石
    self.DiamondLabel:SetCallbackOnUpdate(self, OnUpdateText)

    -- 体力
    self.VigorButton = transform:Find('Currency/TiLi/TiLiAddButton'):GetComponent(typeof(UnityEngine.UI.Button))  
    -- 金币
    self.CoinButton = transform:Find('Currency/Money/MoneyAddButton'):GetComponent(typeof(UnityEngine.UI.Button))  
    -- 钻石
    self.DiamondButton = transform:Find('Currency/Diamond/DiamondAddButton'):GetComponent(typeof(UnityEngine.UI.Button)) 

    self:ScheduleUpdate(OnUpdate)
end

local function SetControls(self)
    local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    self.VigorLabel.text = string.format("%d/%d", userData:GetVigor(), userData:GetMaxVigor())
    self.CoinLabel:SetValue(userData:GetCoin())
    self.DiamondLabel:SetValue(userData:GetDiamond())
end

function PlayerCurrencyBarPanel:OnResume()
    PlayerCurrencyBarPanel.base.OnResume(self)

    self:RegisterControlEvents()
    self:RegisterEvents()

    SetControls(self)
end

function PlayerCurrencyBarPanel:OnPause()
    PlayerCurrencyBarPanel.base.OnPause(self)

    self:UnregisterControlEvents()
    self:UnregisterEvents()
end

function PlayerCurrencyBarPanel:RegisterControlEvents()
    -- 注册 购买体力 的事件
    self.__event_button_onVigorButtonClicked__ = UnityEngine.Events.UnityAction(self.OnVigorButtonClicked, self)
    self.VigorButton.onClick:AddListener(self.__event_button_onVigorButtonClicked__)

     -- 注册 购买金币 的事件
    self.__event_button_onCoinButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCoinButtonClicked, self)
    self.CoinButton.onClick:AddListener(self.__event_button_onCoinButtonClicked__)

    -- 注册 购买钻石 的事件
    self.__event_button_onDiamondButtonClicked__ = UnityEngine.Events.UnityAction(self.OnDiamondButtonClicked, self)
    self.DiamondButton.onClick:AddListener(self.__event_button_onDiamondButtonClicked__)

end

function PlayerCurrencyBarPanel:UnregisterControlEvents()
    -- 取消注册 购买体力 的事件
    if self.__event_button_onVigorButtonClicked__ then
        self.VigorButton.onClick:RemoveListener(self.__event_button_onVigorButtonClicked__)
        self.__event_button_onVigorButtonClicked__ = nil
    end

      -- 取消注册 购买金币 的事件
    if self.__event_button_onCoinButtonClicked__ then
        self.CoinButton.onClick:RemoveListener(self.__event_button_onCoinButtonClicked__)
        self.__event_button_onCoinButtonClicked__ = nil
    end

      -- 取消注册 购买钻石 的事件
    if self.__event_button_onDiamondButtonClicked__ then
        self.DiamondButton.onClick:RemoveListener(self.__event_button_onDiamondButtonClicked__)
        self.__event_button_onDiamondButtonClicked__ = nil
    end
end


function PlayerCurrencyBarPanel:OnVipBuyTiliCoinRequest(btype)
    utility:GetGame():SendNetworkMessage( require"Network/ServerService".OnVipBuyTiliCoin(btype))
end

-----------------------------------------------------------

local function OnUpdatedPlayerData(self, _)
    if self.isShow then
        SetControls(self)
    end
end

local function OnEnterLobby(self)
    self.isShow = true
    self:ActiveComponent()
    SetControls(self)
end

local function ExitLobbyScene(self)
    self.isShow = false
    self:InactiveComponent()
end

function PlayerCurrencyBarPanel:RegisterEvents()
    local messageGuids = require "Framework.Business.MessageGuids"
    self:RegisterEvent(messageGuids.UpdatedPlayerData, OnUpdatedPlayerData)
    self:RegisterEvent(messageGuids.EnterLobbyScene, OnEnterLobby)
    self:RegisterEvent(messageGuids.ExitLobbyScene, ExitLobbyScene)
    self:RegisterEvent(messageGuids.OnCoinBuyWithDiamond, self.OnCoinButtonClicked)
end

function PlayerCurrencyBarPanel:UnregisterEvents()
    local messageGuids = require "Framework.Business.MessageGuids"
    self:UnregisterEvent(messageGuids.UpdatedPlayerData, OnUpdatedPlayerData)
    self:UnregisterEvent(messageGuids.EnterLobbyScene, OnEnterLobby)
    self:UnregisterEvent(messageGuids.ExitLobbyScene, ExitLobbyScene)
    self:UnregisterEvent(messageGuids.OnCoinBuyWithDiamond, self.OnCoinButtonClicked)
end


function PlayerCurrencyBarPanel:OnVigorButtonClicked()
    local str = ""
    local playerData = self:GetPlayerData()
    local remainCount = playerData:GetRemainBuyTiliCount()
    local alreadyCount = playerData:GetAlreadyBuyTiliCount()
    local staticDataCls = require "StaticData.Player.StaminaBuy"
    local keys = staticDataCls:GetKeys()
    local maxCount = keys[keys.Length -1]
    local id = math.min(alreadyCount +1,maxCount)
    local staticData = staticDataCls:GetData(id)

    local cost = staticData:GetPrice()
    local num = staticData:GetNum()

    str = string.format(CommonStringTable[7],cost,CommonStringTable[8],num,CommonStringTable[10],alreadyCount,remainCount)
    self:ButRequest(str,self.OnVipBuyTiliRequest)
end

function PlayerCurrencyBarPanel:OnVipBuyTiliRequest()
    self:OnVipBuyTiliCoinRequest(1)
end
function PlayerCurrencyBarPanel:EnabledCallBack(self)
        debug_print("***************************",self)
self.CoinButton.enabled=true
end

function PlayerCurrencyBarPanel:OnCoinButtonClicked()
    self.CoinButton.enabled=false
     local sceneManager = utility:GetGame():GetSceneManager()
     sceneManager:PopToRootScene()
    local scene = require "GUI.Treasure.Treasure"
    sceneManager:PushScene(scene.New(self.EnabledCallBack,self))
    -- local str = ""
    -- local playerData = self:GetPlayerData()
    -- local remainCount = playerData:GetRemainBuyCoinCount()
    -- local alreadyCount = playerData:GetAlreadyBuyCoinCount()
    -- local staticDataCls = require "StaticData.Player.CoinBuy"
    -- local keys = staticDataCls:GetKeys()
    -- local maxCount = keys[keys.Length -1]
    -- local id = math.min(alreadyCount +1,maxCount)
    -- local staticData = staticDataCls:GetData(id)

    -- local cost = staticData:GetPrice()
    -- local num = staticData:GetNum()
    -- debug_print(CommonStringTable[7],cost,CommonStringTable[8],num,CommonStringTable[9],alreadyCount,remainCount)
    -- str = string.format(CommonStringTable[7],cost,CommonStringTable[8],num,CommonStringTable[9],alreadyCount,remainCount)
 --   self:ButRequest(str,self.OnVipBuyCoinRequest)
end

function PlayerCurrencyBarPanel:OnVipBuyCoinRequest()
    self:OnVipBuyTiliCoinRequest(2)
end

function PlayerCurrencyBarPanel:OnDiamondButtonClicked()
    local windowManager = self:GetGame():GetWindowManager()
    windowManager:Show(require "GUI.Deposit.Deposit")
end

function PlayerCurrencyBarPanel:GetPlayerData()
    -- 获取玩家数据
    local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    return userData
end

function PlayerCurrencyBarPanel:ButRequest(str,func)
    -- 购买请求
    local windowManager = utility:GetGame():GetWindowManager()
    local ConfirmDialogClass = require "GUI.Dialogs.ConfirmDialog"
    windowManager:Show(ConfirmDialogClass, str, self, func)
end


return PlayerCurrencyBarPanel