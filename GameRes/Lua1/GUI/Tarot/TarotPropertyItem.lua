local BaseNodeClass = require "Framework.Base.Node"
local utility = require "Utils.Utility"

local TarotPropertyItem = Class(BaseNodeClass)

-----------------------------------------------------------------------
--- 私有函数
-----------------------------------------------------------------------
local function InitControls(self)
    local transform = self:GetUnityTransform()
    self.nameLabel = transform:Find("NameLabel"):GetComponent(typeof(UnityEngine.UI.Text))
    self.numLabel = transform:Find("Status/Base/NumLabel"):GetComponent(typeof(UnityEngine.UI.Text))
end

local function SetControls(self)
    if self.propertyId == nil or self.propertyValue == nil then
        return
    end
    local PropertyUtils = require "Utils.PropertyUtils"
    PropertyUtils.Format(self.propertyId,self.nameLabel,"%s",self.propertyValue,self.numLabel,"%d")
end

local function RegisterEvents(self)
end

local function UnregisterEvents(self)
end

function TarotPropertyItem:Ctor(parentTransform)
    self.originalParentTransform = parentTransform
    self.parentTransform = parentTransform
    self.propertyId = nil
    self.propertyValue = nil
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function TarotPropertyItem:OnInit()
    -- 加载界面(只走一次)
    utility.LoadNewGameObjectAsync("UI/Prefabs/TarotStatusItem", function(go)
		self:BindComponent(go)
	end)
end

function TarotPropertyItem:OnComponentReady()
    InitControls(self)
end

function TarotPropertyItem:OnResume()
    TarotPropertyItem.base.OnResume(self)
    self:LinkComponent(self.parentTransform, true)
    SetControls(self)
    RegisterEvents(self)
end

function TarotPropertyItem:OnPause()
    TarotPropertyItem.base.OnPause(self)
    self:LinkComponent(self.originalParentTransform, false)
    UnregisterEvents(self)
end

function TarotPropertyItem:OnCleanup()
    utility.UnloadResource("UI/Prefabs/TarotStatusItem", typeof(UnityEngine.GameObject))
    TarotPropertyItem.base.OnCleanup(self)
end

-----------------------------------------------------------------------
--- 外部接口
-----------------------------------------------------------------------
function TarotPropertyItem:Set(propertyId, propertyValue)
    self.propertyId = propertyId
    self.propertyValue = propertyValue

    if self.nameLabel ~= nil and self.numLabel ~= nil then
        SetControls(self)
    end
end

function TarotPropertyItem:SetParentTransform(parentTransform)
    self.parentTransform = parentTransform
end

return TarotPropertyItem
