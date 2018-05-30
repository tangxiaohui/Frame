--
-- User: fenghao
-- Date: 04/07/2017
-- Time: 9:59 AM
--

local BaseNodeClass = require "Framework.Base.Node"
local utility = require "Utils.Utility"
require "Const"

local ProtectPrincessHeadNode = Class(BaseNodeClass)

local function InitControls(self)
    local transform = self:GetUnityTransform()

    -- 箱子 --
    self.chestObject = transform:Find("Chest").gameObject

    -- 战斗 --
    self.fightObject = transform:Find("Fight").gameObject

    self.headLightObject = transform:Find("Fight/Light").gameObject -- 选中高亮
    self.headFightObject = transform:Find("Fight/Fight").gameObject

    self.headIconImage = transform:Find("Fight/HeadBase/HeadIcon"):GetComponent(typeof(UnityEngine.UI.Image)) -- 头像

    self.waveLabel = transform:Find("Fight/WaveBase/WaveNum"):GetComponent(typeof(UnityEngine.UI.Text)) -- 波数

    self.levelLabel = transform:Find("Fight/LvLabel"):GetComponent(typeof(UnityEngine.UI.Text)) -- 等级
end

local function ResetAll(self)

end

local function IsDirty(self)
    return self.controlStartup
end

-- 数值变更 --

local function OnSelectedStatusChanged(self)
    self.headLightObject:SetActive(self:IsSelected())
    self.headFightObject:SetActive(self:IsSelected())
end

local function OnHeadIconChanged(self)
    if self.iconDirty then
        self.iconDirty = false
        -- 加载玩家头像 --
        if type(self:GetHeadCardID()) == "number" then
            utility.LoadPlayerHeadIcon(self:GetHeadCardID(), self.headIconImage)
        end
    end
end

local function OnLevelChanged(self)
    if type(self:GetLevel()) == "number" then
        self.levelLabel.text = string.format("Lv.%d", self:GetLevel())
    end
end

local function OnWaveNumChanged(self)
    if type(self:GetWaveNum()) == "number" then
        self.waveLabel.text = self:GetWaveNum()
    end
end

local function OnModeChanged(self)
    if self.mode == kProtectPrincessHeadMode_None then
        ResetAll(self)
        return
    end

    self.chestObject:SetActive(self.mode == kProtectPrincessHeadMode_Box)
    self.fightObject:SetActive(self.mode == kProtectPrincessHeadMode_Fight)

    OnSelectedStatusChanged(self)
    OnHeadIconChanged(self)
    OnLevelChanged(self)
    OnWaveNumChanged(self)
end

function ProtectPrincessHeadNode:Ctor(transform)
    self.controlStartup = false
    self.isSelected = false
    self.headCardID = false
    self.currentLevel = nil
    self.waveNum = nil
    self.currentRatio = 0
    self.gateID = nil

    self.iconDirty = false

    self.mode = kProtectPrincessHeadMode_None
    self:BindComponent(transform.gameObject, false)
    InitControls(self)
    self:Clear()
    self:InactiveComponent()
end


function ProtectPrincessHeadNode:SetMode(mode)
    if self.mode ~= mode then
        self.mode = mode
        if IsDirty(self) then
            OnModeChanged(self)
        end
    end
end

function ProtectPrincessHeadNode:GetMode()
    return self.mode
end

function ProtectPrincessHeadNode:SetSelected(selected)
    if self.isSelected ~= selected then
        self.isSelected = selected
        if IsDirty(self) then
            OnSelectedStatusChanged(self)
        end
    end
end

function ProtectPrincessHeadNode:IsSelected()
    return self.isSelected
end

function ProtectPrincessHeadNode:SetHeadCardID(headID)
    if self.headCardID ~= headID then
        self.headCardID = headID
        self.iconDirty = true
        if IsDirty(self) then
            OnHeadIconChanged(self)
        end
    end
end

function ProtectPrincessHeadNode:GetHeadCardID()
    return self.headCardID
end

function ProtectPrincessHeadNode:SetLevel(level)
    if self.currentLevel ~= level then
        self.currentLevel = level
        if IsDirty(self) then
            OnLevelChanged(self)
        end
    end
end

function ProtectPrincessHeadNode:GetLevel()
    return self.currentLevel
end

function ProtectPrincessHeadNode:SetWaveNum(wave)
    if self.waveNum ~= wave then
        self.waveNum = wave
        if IsDirty(self) then
            OnWaveNumChanged(self)
        end
    end
end

function ProtectPrincessHeadNode:GetWaveNum()
    return self.waveNum
end

function ProtectPrincessHeadNode:SetExtraData(data)
    self.extraData = data
end

function ProtectPrincessHeadNode:GetExtraData()
    return self.extraData
end

function ProtectPrincessHeadNode:SetRatio(ratio)
    self.currentRatio = ratio
end

function ProtectPrincessHeadNode:GetRatio()
    return self.currentRatio
end

function ProtectPrincessHeadNode:SetPosition(pos)
    local transform = self:GetUnityTransform()
    transform.localPosition = pos
end

function ProtectPrincessHeadNode:SetScale(scale)
    local transform = self:GetUnityTransform()
    transform.localScale = Vector3.New(scale, scale, scale)
end

function ProtectPrincessHeadNode:SetGateID(gateID)
    self.gateID = gateID
end

function ProtectPrincessHeadNode:GetGateID()
    return self.gateID
end

function ProtectPrincessHeadNode:Clear()
    ResetAll(self)
end

---> 控件初始化 <---
local function SetControls(self)
    -- 初始化控件 --
    OnModeChanged(self)
    self.iconDirty = false
end

local function ResetControls(self)
    -- 清除控件状态 --
    ResetAll(self)
end

function ProtectPrincessHeadNode:OnResume()
    ProtectPrincessHeadNode.base.OnResume(self)

    SetControls(self)

    self.controlStartup = true
end

function ProtectPrincessHeadNode:OnPause()
    ProtectPrincessHeadNode.base.OnPause(self)

    ResetControls(self)

    self.controlStartup = false
end

return ProtectPrincessHeadNode
