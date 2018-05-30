local BaseNodeClass = require "Framework.Base.Node"
local utility = require "Utils.Utility"
local messageGuids = require "Framework.Business.MessageGuids"

local TarotPropertyPanel = Class(BaseNodeClass)

-----------------------------------------------------------------------
--- 私有函数
-----------------------------------------------------------------------
local function DeapwnAllControls(self)
    local count = self.propertyMap:Count()
    for i = 1, count do
        local item = self.propertyMap:GetEntryByIndex(i)
        self.contentProvider:DespawnItem(item)
        self:RemoveChild(item)
    end
    self.propertyMap:Clear()
end

local function SpawnAllControls(self)
    local UserDataType = require "Framework.UserDataType"
    local tarotData = self:GetCachedData(UserDataType.TarotData)
    local propertySet = tarotData:GetAllProperies()
    propertySet:Foreach(function(propertyId, propertyValue)
        if propertyId > 0 and propertyValue > 0 then
            local item = self.contentProvider:SpawnItem(self.contentTransform)
            self.propertyMap:Add(propertyId, item)
            item:Set(propertyId, propertyValue)
            self:AddChild(item)
        end
    end)
end

local function InitControls(self)
    local transform = self:GetUnityTransform()
    self.contentTransform = transform:Find("Scroll View/Viewport/Content")

    -- 缓存属性 --
    require "Collection.OrderedDictionary"
    self.propertyMap = OrderedDictionary.New()

    SpawnAllControls(self)
end

local function SetControls(self)
end

local function OnTarotCardStateChanged(self, msg)
    if not msg.success then
        return
    end

    DeapwnAllControls(self)
    SpawnAllControls(self)
    SetControls(self)
end

local function RegisterEvents(self)
    self:RegisterEvent(messageGuids.TarotCardStateChanged, OnTarotCardStateChanged)
end

local function UnregisterEvents(self)
    self:UnregisterEvent(messageGuids.TarotCardStateChanged, OnTarotCardStateChanged)
end

function TarotPropertyPanel:Ctor(transform, contentProvider)
    self.contentProvider = contentProvider
    self:BindComponent(transform.gameObject, false)
    InitControls(self)
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function TarotPropertyPanel:OnInit()
end

function TarotPropertyPanel:OnResume()
    TarotPropertyPanel.base.OnResume(self)
    SetControls(self)
    RegisterEvents(self)
end

function TarotPropertyPanel:OnPause()
    TarotPropertyPanel.base.OnPause(self)
    UnregisterEvents(self)
    DeapwnAllControls(self)
end

-----------------------------------------------------------------------
--- 外部接口
-----------------------------------------------------------------------

return TarotPropertyPanel
