local BaseNodeClass = require "Framework.Base.Node"
local utility = require "Utils.Utility"
local messageGuids = require "Framework.Business.MessageGuids"

local TarotCardPanel = Class(BaseNodeClass)

-----------------------------------------------------------------------
--- 私有函数
-----------------------------------------------------------------------
local function CreateControls(self)
    require "Collection.OrderedDictionary"
    self.tarotLineupControlMap = OrderedDictionary.New()

    local TarotLineupItemClass = require "GUI.Tarot.TarotLineupItem"
    local TarotDataManager = require "StaticData.Tarot.Tarot"
    TarotDataManager:Foreach(function(tarotData)
        -- 创建控件数组
        self.tarotLineupControlMap:Add(tarotData:GetId(), TarotLineupItemClass.New(tarotData:GetId(), self.contentTransform))
    end)
end

local function ShowControls(self)
    local count = self.tarotLineupControlMap:Count()
    for i = 1, count do
        local item = self.tarotLineupControlMap:GetEntryByIndex(i)
        self:AddChild(item)
    end
end

local function InitControls(self)
    local transform = self:GetUnityTransform()
    self.scrollRect = transform:Find("Scroll View"):GetComponent(typeof(UnityEngine.UI.ScrollRect))
    self.contentTransform = transform:Find("Scroll View/Viewport/Content")
    CreateControls(self)
    ShowControls(self)
end

local function UpdateAllItemRedDot(self)
    local count = self.tarotLineupControlMap:Count()
    for i = 1, count do
        local item = self.tarotLineupControlMap:GetEntryByIndex(i)
        if item ~= nil then
            item:UpdateRedDot()
        end
    end
end

local function OnTarotCardStateChanged(self, msg)
    if not msg.success then
        return
    end

    -- 更新自己
    local tarotId = msg.newState.id
    local item = self.tarotLineupControlMap:GetEntryByKey(tarotId)
    if item ~= nil then
        item:Update()
        self:GetUIManager():DisableInput()
        item:CrossFade(function() self:GetUIManager():EnableInput() end)
    end

    -- 更新所有控件的红点状态
    UpdateAllItemRedDot(self)
end

local function OnItemBagUpdate(self)
    -- 更新所有控件的红点状态
    UpdateAllItemRedDot(self)
end

local function RegisterEvents(self)
    self:RegisterEvent(messageGuids.TarotCardStateChanged, OnTarotCardStateChanged)
    self:RegisterEvent(messageGuids.AddedOneItem, OnItemBagUpdate)
    self:RegisterEvent(messageGuids.UpdatedOneItem, OnItemBagUpdate)
end

local function UnregisterEvents(self)
    self:UnregisterEvent(messageGuids.TarotCardStateChanged, OnTarotCardStateChanged)
    self:UnregisterEvent(messageGuids.AddedOneItem, OnItemBagUpdate)
    self:UnregisterEvent(messageGuids.UpdatedOneItem, OnItemBagUpdate)
end

function TarotCardPanel:Ctor(transform)
    self:BindComponent(transform.gameObject, false)
    InitControls(self)
end


local function DelayStartSystemGuide(self,data)
    while (not data:IsReady()) do
        coroutine.step(1)
    end
   
    utility.GetGame():GetSystemGuideManager():SetNeetSystemGuideID(kSystem_Guide[15].systemGuideID,self)
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function TarotCardPanel:OnInit()
end


function TarotCardPanel:OnResume()
    TarotCardPanel.base.OnResume(self)
    RegisterEvents(self)
    self:StartCoroutine(DelayStartSystemGuide,self.tarotLineupControlMap:GetEntryByIndex(1))

end

function TarotCardPanel:OnPause()
    TarotCardPanel.base.OnPause(self)
    UnregisterEvents(self)
end

return TarotCardPanel
