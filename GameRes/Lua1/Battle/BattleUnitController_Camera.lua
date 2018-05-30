
local function RemoveAllAudioListeners(self)
    self.animationEventListener:RemoveAllAudioListeners()
end

local function ResetCameraComponent(cameraTrans)
    if cameraTrans == nil then
        return
    end

    local cameraComponent = cameraTrans:GetComponent(typeof(UnityEngine.Camera))
    if cameraComponent == nil then
        return
    end

    local mask = LayerMask.GetMask(
					"Default",
					"TransparentFX",
					"Ignore Raycast",
					"Water",
					"UI",
					"Toon",
					"SkillAnimation",
					"Environment"
				)

    cameraComponent.cullingMask = mask
end

local function InitCamera(self)
    self.cameraParentTrans = self:GetChildTransform("CameraParent")
    if self.cameraParentTrans == nil then
        return
    end

    self.selfSkillCamera = self.cameraParentTrans:Find("Camera")
    if self.selfSkillCamera ~= nil then
        ResetCameraComponent(self.selfSkillCamera)
        self.selfSkillCamera = self.selfSkillCamera.gameObject
        self.selfSkillCamera:SetActive(false)
    end

    RemoveAllAudioListeners(self)
end

local function InitCameraPath(self)
    self.mainCameraPath = self:GetChildTransform("Camerapath")
end

local function GetMainCameraPath(self)
    return self.mainCameraPath
end

local function GetSkillCameraObject(self)
    return self.selfSkillCamera
end

local function GetSpecialCameraObjectByNumber(self, n)
    if self.cameraParentTrans ~= nil then
        local cameraTrans = self.cameraParentTrans:Find(string.format("Camera%d", n))
        if cameraTrans ~= nil then
            return cameraTrans.gameObject
        end
    end
    return nil
end

local function StopAllCameraPaths(self)
    self.animationEventListener:StopAllCameraPaths()
end

local function ActiveCameraObject(self, cameraObject)
    self:GetBattlefield():ActiveCameraObject(cameraObject)
end

function BattleUnitController:PlayMainCameraPathAnimation()
    local mainCameraPath = GetMainCameraPath(self)
    if mainCameraPath == nil then
        return false
    end

    local cameraObject = GetSkillCameraObject(self)
    if cameraObject == nil then
        return false
    end

    StopAllCameraPaths(self)
    ActiveCameraObject(self, cameraObject)
    mainCameraPath:SendMessage("Play")
    return true
end

function BattleUnitController:StopMainCameraPathAnimation()
    local mainCameraPath = GetMainCameraPath(self)
    if mainCameraPath == nil then
        return false
    end

    local cameraObject = GetSkillCameraObject(self)
    if cameraObject == nil then
        return false
    end

    StopAllCameraPaths(self)
    self:GetBattlefield():ResetToDefaultCameraObject()
    return true
end

function BattleUnitController:GetCameraShakeObject()
    local selfCameraObject = GetSkillCameraObject(self)
    if selfCameraObject ~= nil and selfCameraObject.activeSelf then
        return self.cameraParentTrans.gameObject
    end

    return self:GetBattlefield():GetRootCameraParent()
end

function BattleUnitController:ActivateSpecialCameraObjectByNumber(n)
    local cameraObject = GetSpecialCameraObjectByNumber(self, n)
    if cameraObject ~= nil then
        ActiveCameraObject(self, cameraObject)
    end
    return nil
end

function BattleUnitController:ClearSkillCameraBloomEffect()
    self:GetBattlefield():RemoveBloomEffect(GetSkillCameraObject(self))
end

function BattleUnitController:OnInitCamera()
    InitCamera(self)
    InitCameraPath(self)
end