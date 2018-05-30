local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local messageGuids = require "Framework.Business.MessageGuids"
require "LUT.StringTable"

local TarotCardActiveModule = Class(BaseNodeClass)

-- ### 表示这个窗口只能同时弹出1个
windowUtility.SetMutex(TarotCardActiveModule, true)

function TarotCardActiveModule:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end

-----------------------------------------------------------------------
--- 私有函数
-----------------------------------------------------------------------
local function InitControls(self)
    local transform = self:GetUnityTransform()
    self.tweenObjectTrans = transform:Find('Base')
    self.contentPoint = transform:Find("Base/Point")
    self.backgroundButton = transform:Find("Base/BackgroundButton"):GetComponent(typeof(UnityEngine.UI.Button))
    self.activeButton = transform:Find("Base/ActiveButton"):GetComponent(typeof(UnityEngine.UI.Button))
    self.itemIconImage = transform:Find("Base/ActiveButton/Icon"):GetComponent(typeof(UnityEngine.UI.Image))
    self.itemPriceLabel = transform:Find("Base/ActiveButton/Text"):GetComponent(typeof(UnityEngine.UI.Text))


    self.materialIconImage = transform:Find("Base/CurrencyGroup/IconImage"):GetComponent(typeof(UnityEngine.UI.Image))
    self.materialNumLabel = transform:Find("Base/CurrencyGroup/Text"):GetComponent(typeof(UnityEngine.UI.Text))
end

local function SetControls(self)
    local itemId, itemNum = self.tarotCardControl:GetStageItem(self.tarotCardControl:GetNextStage())
    -- 道具图标
    local gameTool = require "Utils.GameTools"
    local _,_,_,icon_2 = gameTool.GetItemDataById(itemId)
    utility.LoadSpriteFromPath(icon_2, self.itemIconImage)
    utility.LoadSpriteFromPath(icon_2, self.materialIconImage)
    -- 道具数量
    self.itemPriceLabel.text = itemNum

    local isEnough, _, nowNum = utility.IsItemEnough(itemId, itemNum)
    if isEnough then
        self.itemPriceLabel.color = UnityEngine.Color(1, 1, 1, 1)
    else
        self.itemPriceLabel.color = UnityEngine.Color(1, 0, 0, 1)
    end

    -- 获取数量
    self.materialNumLabel.text = nowNum
end

local function OnActiveButtonClicked(self)
    local itemId, itemNum = self.tarotCardControl:GetStageItem(self.tarotCardControl:GetNextStage())
    if not utility.IsItemEnough(itemId, itemNum) then
        local gameTool = require "Utils.GameTools"
        local _,_,name_2,_ = gameTool.GetItemDataById(itemId)
        utility.ShowErrorDialog(string.format(TarotCardStateTable[7], name_2))
        return
    end

    local ServerService = require "Network.ServerService"
    self:GetGame():SendNetworkMessage(ServerService.TarotCardActiveRequest(self.tarotId))

end

local function OnBackgroundButtonClicked(self)
    utility.GetGame():GetSystemGuideManager():SetNeetSystemGuideID(kSystem_Guide[16].systemGuideID,self)
    
    self:Close()
end

local function OnTarotCardStateChanged(self, msg)

    if msg.success then
        self:Close()
    end
end

local function OnItemBagUpdate(self)
    SetControls(self)
end


local function RegisterEvents(self)
    self.__event_button_activeButtonClicked__ = UnityEngine.Events.UnityAction(OnActiveButtonClicked, self)
    self.activeButton.onClick:AddListener(self.__event_button_activeButtonClicked__)

    self.__event_button_backgroundButton__ = UnityEngine.Events.UnityAction(OnBackgroundButtonClicked, self)
    self.backgroundButton.onClick:AddListener(self.__event_button_backgroundButton__)

    self:RegisterEvent(messageGuids.TarotCardStateChanged, OnTarotCardStateChanged)
    self:RegisterEvent(messageGuids.AddedOneItem, OnItemBagUpdate)
    self:RegisterEvent(messageGuids.UpdatedOneItem, OnItemBagUpdate)
end

local function UnregisterEvents(self)
    if self.__event_button_activeButtonClicked__ then
        self.activeButton.onClick:RemoveListener(self.__event_button_activeButtonClicked__)
        self.__event_button_activeButtonClicked__ = nil
    end

    if self.__event_button_backgroundButton__ then
        self.backgroundButton.onClick:RemoveListener(self.__event_button_backgroundButton__)
        self.__event_button_backgroundButton__ = nil
    end

    self:UnregisterEvent(messageGuids.TarotCardStateChanged, OnTarotCardStateChanged)
    self:UnregisterEvent(messageGuids.AddedOneItem, OnItemBagUpdate)
    self:UnregisterEvent(messageGuids.UpdatedOneItem, OnItemBagUpdate)
end

function TarotCardActiveModule:Ctor()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function TarotCardActiveModule:OnWillShow(tarotId)
    self.tarotId = tarotId
end

function TarotCardActiveModule:OnInit()
    -- 加载界面(只走一次)
    utility.LoadNewGameObjectAsync("UI/Prefabs/TarotCardActiveModule", function(go)
	    self:BindComponent(go)
	end)
end

function TarotCardActiveModule:OnComponentReady()
    InitControls(self)
    local TarotCardItemClass = require "GUI.Tarot.TarotCardItem"
    self.tarotCardControl = TarotCardItemClass.New(self.tarotId, self.contentPoint)
    self:AddChild(self.tarotCardControl)
end

function TarotCardActiveModule:OnResume()
    TarotCardActiveModule.base.OnResume(self)
    SetControls(self)
    RegisterEvents(self)
    utility.GetGame():GetSystemGuideManager():SetNeetSystemGuideID(kSystem_Guide[15].systemGuideID,self)
    utility.GetGame():GetSystemGuideManager():SetNeetSystemGuideID(kSystem_Guide[16].systemGuideID,self)

end

function TarotCardActiveModule:OnPause()
    TarotCardActiveModule.base.OnPause(self)
    UnregisterEvents(self)
end

function TarotCardActiveModule:OnCleanup()
    utility.UnloadResource("UI/Prefabs/TarotCardActiveModule", typeof(UnityEngine.GameObject))
    TarotCardActiveModule.base.OnCleanup(self)
end

-----------------------------------------------------------------------
--- 动画
-----------------------------------------------------------------------
function TarotCardActiveModule:IsTransition()
    return true
end

-- ## 在这里执行 淡出函数! (immediately 值只针对 WindowNode 及其子类)
function TarotCardActiveModule:OnExitTransitionDidStart(immediately)
    TarotCardActiveModule.base.OnExitTransitionDidStart(self, immediately)
    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans
            local TweenUtility = require "Utils.TweenUtility"
            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

return TarotCardActiveModule
