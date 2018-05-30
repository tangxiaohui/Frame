local BaseNodeClass = require "Framework.Base.Node"
local utility = require "Utils.Utility"
local TarotUtils = require "Utils.TarotUtils"

local TarotCardItem = Class(BaseNodeClass)

-----------------------------------------------------------------------
--- 私有函数
-----------------------------------------------------------------------
local function InitControls(self)
    local transform = self:GetUnityTransform()
    self.cardImage = transform:Find("Base/Front/Card"):GetComponent(typeof(UnityEngine.UI.Image))
    self.nameLabel = transform:Find("Base/Front/NameLabel"):GetComponent(typeof(UnityEngine.UI.Text))
    self.statusLabel = transform:Find("Base/Front/Status/StatusLabel"):GetComponent(typeof(UnityEngine.UI.Text))
    self.numLabel = transform:Find("Base/Front/Status/NumLabel"):GetComponent(typeof(UnityEngine.UI.Text))
    self.backObject = transform:Find("Base/Back").gameObject
    self.animator = transform:GetComponent(typeof(UnityEngine.Animator))
    self.animator.enabled = false
end

-- 获取当前Stage
local function GetStage(self)
    return TarotUtils.GetCurrentStage(self.tarotId)
end

-- 获取指定Stage的属性ID和值
local function GetStageProperty(self, stage)
    return TarotUtils.GetTarotPropertyAtStage(self.tarotId, stage)
end

-- 获取指定Stage的道具ID和值
local function GetStageItem(self, stage)
    return TarotUtils.GetTarotItemAtStage(self.tarotId, stage)
end

local function SetTarotScale(self)
    -- 牌的状态
    if GetStage(self) == kTarotState_Straight then
        self.cardImage.transform.localScale = Vector3(1, 1, 1)
    else
        self.cardImage.transform.localScale = Vector3(1, -1, 1)
    end
end

local function SetControls(self, isUpdate)
    -- 加载图标
    utility.LoadSpriteFromPath(self.staticTarotData:GetTarotIllust(), self.cardImage)
    self.nameLabel.text = self.staticTarotData:GetName()

    -- 属性
    local propertyId, propertyValue = GetStageProperty(self, GetStage(self))
    if propertyId ~= nil then
        local PropertyUtils = require "Utils.PropertyUtils"
        PropertyUtils.Format(propertyId,self.statusLabel,"%s",propertyValue,self.numLabel,"+%d")
    else
        self.statusLabel.text = nil
        self.numLabel.text = nil
    end

    -- 牌背
    if not isUpdate then
        self.backObject:SetActive(GetStage(self) == kTarotState_Unactive)
        SetTarotScale(self)
    end
end

local function RegisterEvents(self)
end

local function UnregisterEvents(self)
end

function TarotCardItem:Ctor(tarotId, parentTransform)
    self.tarotId = tarotId
    self.staticTarotData = require "StaticData.Tarot.Tarot":GetData(self.tarotId)
    self.parentTransform = parentTransform
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function TarotCardItem:OnInit()
    -- 加载界面(只走一次)
    utility.LoadNewGameObjectAsync("UI/Prefabs/TarotCard", function(go)
		self:BindComponent(go)
	end)
end

function TarotCardItem:OnComponentReady()
    InitControls(self)
end

function TarotCardItem:OnResume()
    TarotCardItem.base.OnResume(self)
    self:LinkComponent(self.parentTransform, true)
    SetControls(self)
    RegisterEvents(self)
end

function TarotCardItem:OnPause()
    TarotCardItem.base.OnPause(self)
    UnregisterEvents(self)
end

function TarotCardItem:OnCleanup()
    utility.UnloadResource("UI/Prefabs/TarotCard", typeof(UnityEngine.GameObject))
    TarotCardItem.base.OnCleanup(self)
end

-----------------------------------------------------------------------
--- 外部接口
-----------------------------------------------------------------------
-- 当前stage
function TarotCardItem:GetStage()
    return GetStage(self)
end

-- 下一stage
function TarotCardItem:GetNextStage()
    return TarotUtils.GetNextStage(GetStage(self))
end

-- 上一stage
function TarotCardItem:GetPreviousStage()
    return TarotUtils.GetPreviousStage(GetStage(self))
end

function TarotCardItem:GetStageProperty(stage)
    return GetStageProperty(self, stage)
end

function TarotCardItem:GetStageItem(stage)
    return GetStageItem(self, stage)
end

function TarotCardItem:Update()
    if self:IsRunning() then
        SetControls(self, true) 
    end
end


local function GetAnimatorStateByStages(previous, current)
    if previous == -1 then
        return nil
    end

    if previous == kTarotState_Unactive and current == kTarotState_Inverted then
        return "fanpai"
    elseif previous == kTarotState_Inverted and current == kTarotState_Straight then
        return "zhengmian"
    end

    return nil
end

local function WaitForAnimationFinished(self, callback)
    --local stateInfo = self.animator:GetCurrentAnimatorStateInfo(0)
    repeat
        coroutine.step()
    until(self.animator:GetCurrentAnimatorStateInfo(0):IsName("Empty"))
    SetTarotScale(self)
    coroutine.step()
    self.animator.enabled = false
    callback()
end

-- 动画相关(从previous到current)
function TarotCardItem:CrossFade(callback)
    local stateName = GetAnimatorStateByStages(self:GetPreviousStage(), GetStage(self))
    if stateName == nil then return end
    -- 播放 --
    self.animator.enabled = true
    self.animator:Play(stateName, 0, 0)
    self.animator:Update(0)
    self:StartCoroutine(WaitForAnimationFinished, callback)
end

return TarotCardItem
