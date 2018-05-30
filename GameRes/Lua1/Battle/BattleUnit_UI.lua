require "GUI.HeaderHpUIPanel"

local HEADER_HANGING_POINT = "Header"
local HEADER_HANGING_POINT_2 = "root/Dummy002"
local HEADER_HANGING_POINT_3 = "Dummy002"

local uiManager = require "Utils.Utility".GetUIManager()
local battleUICamera = uiManager:GetBattleUICanvas():GetCamera()

-- 获取血条
local function SetupHpBar(self)
    local hpBar = HeaderHpUIPanel.New("HpGroup")
    hpBar:InitWithPrefabName("UI/Prefabs/BattleUnitInfoStatus") --加载
    hpBar:GetGameObject():SetActive(false) -- 默认是隐藏的
    self.uiControls.hpBar = hpBar
end

-- 获取buff group --

-- 获取Battlefield
local function GetCurrentCamera(self)
    if self:GetParent() ~= nil then
        local battlefield = self:GetParent():GetParent()
        if battlefield == nil then return nil end
        local worldCameraObject = battlefield:GetCurrentCamera()
        if worldCameraObject == nil then return nil end
        return worldCameraObject:GetComponent(typeof(UnityEngine.Camera))
    end
    return nil
end

-- 定位位置
local function RepositionHpBar(self)
    if self.uiControls.hpBar == nil then
        return
    end

    if not self:IsAlive() then
        self.uiControls.hpBar:GetGameObject():SetActive(false) -- 这时候隐藏
        return
    end

    if self:GetGameObject() == nil then
        return
    end

    local transform = self:GetGameObject().transform

    local headerTrans = transform:Find(HEADER_HANGING_POINT) or transform:Find(HEADER_HANGING_POINT_2) or transform:Find(HEADER_HANGING_POINT_3)
    if headerTrans then
        transform = headerTrans
    end

    local worldCamera = GetCurrentCamera(self)
    if worldCamera == nil then return end


    local viewPoint = worldCamera:WorldToViewportPoint(transform.position)

    local targetWorldPoint = battleUICamera:ViewportToWorldPoint(viewPoint)

    self.uiControls.hpBar.transform.position = targetWorldPoint
    local pos = self.uiControls.hpBar.transform.localPosition
    pos.z = 10
    self.uiControls.hpBar.transform.localPosition = pos
end

function BattleUnit:SetupUIs()
    self.uiControls = {}
    SetupHpBar(self)
end

-- 归还血条
function BattleUnit:ClearUI()
    self.uiControls.hpBar:Clear()
end

function BattleUnit:SetHpGroupActive(active)
    if self.uiControls.hpBar ~= nil then
        self.uiControls.hpBar.guiRoot.gameObject:SetActive(active)
    end
end

function BattleUnit:SetRageForUI(rage)
    if self.uiControls.hpBar ~= nil then
        self.uiControls.hpBar:SetRage(rage)
    end
end

function BattleUnit:AddBuffForUI(stateId, iconPath)
    if self.uiControls.hpBar ~= nil then
        self.uiControls.hpBar:AddBuff(stateId, iconPath)
    end
end

function BattleUnit:RemoveBuffForUI(stateId)
    if self.uiControls.hpBar ~= nil then
        self.uiControls.hpBar:RemoveBuff(stateId)
    end
end

function BattleUnit:UpdateHpBar()
    if self.uiControls.hpBar ~= nil then
        self.uiControls.hpBar:SetHp(self:GetCurHp(), self:GetMaxHp())
    end
end

-- 初始化血条
function BattleUnit:InitHpBar()
    local hpBar = self.uiControls.hpBar
    local isFriendSide = (self:OnGetSide() == 1)  --判断是否为右边
    if isFriendSide then
        hpBar:SetRightMode()
    end
    hpBar:GetGameObject():SetActive(true) -- 这时候激活
end

function BattleUnit:UpdateAllUIControls()
    RepositionHpBar(self)
--    UpdateHpBar(self)
end
