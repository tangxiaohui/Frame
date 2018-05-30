
local NodeClass = require "Framework.Base.Node"
local utility = require "Utils.Utility"
local messageGuids = require "Framework.Business.MessageGuids"
local TweenUtility = require "Utils.TweenUtility"

local BattleAssistCameraEffectNode = Class(NodeClass)

-- FIXME: 以后要将这个类改成战斗通用推镜头的

local function OnCameraFOVUpdate(self, time, callbackOnUpdate, callbackOnFinished)
    local finished
    local passedTime = 0

    repeat
        local t = passedTime / time
        if t >= 1 then
            t = 1
            finished = true
        end

        callbackOnUpdate(t)

        -- update passedTime
        passedTime = passedTime + UnityEngine.Time.deltaTime

        coroutine.step(1)
    until(finished == true)

    -- call finished --
    if callbackOnFinished then
        callbackOnFinished()
    end
end

local function DelayCameraShake(self)
    coroutine.wait(0.5)
    if self.rootCameraParentObject ~= nil then
        local cameraShakerComponent = self.rootCameraParentObject:GetComponent(typeof(EZCameraShake.CameraShaker))
        if cameraShakerComponent == nil then
            cameraShakerComponent = self.rootCameraParentObject:AddComponent(typeof(EZCameraShake.CameraShaker))
        end
        cameraShakerComponent:Shake(1, true)
    end
end

local function Reset(self)
end

local function OnBeginAssistAttack(self, targetPosition, useShake)
    if self.performingCameraEffect then
        error("error: 特效正在执行中不继续执行了!")
        return;
    end

    -- 显示速度线 --
    self.speedLineImage.enabled = true

    self.performingCameraEffect = true

    self.currentCamera = self.battlefield:GetCurrentCamera():GetComponent(typeof(UnityEngine.Camera))
    if self.currentCamera ~= nil then

        local cameraTransform = self.currentCamera.transform

        -- (只记录一次)
        if type(self.originalFOV) ~= "number" then
            self.originalFOV = self.currentCamera.fieldOfView
            self.originalRotation = cameraTransform.rotation
        end

        local relativePos = targetPosition - cameraTransform.position
        local targetRotation = UnityEngine.Quaternion.LookRotation(relativePos)

        self:StartCoroutine(
            OnCameraFOVUpdate,
            0.15,
            function(t)
                -- 更新 FOV --
                local fov = TweenUtility.Linear(self.originalFOV, self.originalFOV - 13, t)
                self.currentCamera.fieldOfView = fov

                -- 更新旋转 --
                local rotation = UnityEngine.Quaternion.Slerp(self.originalRotation, targetRotation, t)
                cameraTransform.rotation = rotation
            end,
            function()
                self.speedLineImage.enabled = false
            end
        )

        -- 震屏
        if useShake then
            self:StartCoroutine(DelayCameraShake)
        end
    end

end

local function OnEndAssistAttack(self)
    if self.performingCameraEffect then
        self.performingCameraEffect = false

        self.speedLineImage.enabled = false

        self:StopAllCoroutines()

        local transform = self.currentCamera.transform
        transform.rotation = self.originalRotation
        self.currentCamera.fieldOfView = self.originalFOV
    end
end

function BattleAssistCameraEffectNode:Ctor(owner, speedLineImage)
    self.owner = owner
    self.speedLineImage = speedLineImage
    self.battlefield = owner:GetBattlefield()
    self.rootCameraParentObject = self.battlefield:GetRootCameraParent()
    self.performingCameraEffect = false
end

function BattleAssistCameraEffectNode:OnInit()

end

function BattleAssistCameraEffectNode:OnEnter()
    BattleAssistCameraEffectNode.base.OnEnter(self)
    
    -- 注册消息 --
    self:RegisterEvent(messageGuids.BattleStartCameraZoomUp, OnBeginAssistAttack, nil)
    self:RegisterEvent(messageGuids.BattleEndCameraZoomUp, OnEndAssistAttack, nil)
end

function BattleAssistCameraEffectNode:OnPause()
    BattleAssistCameraEffectNode.base.OnPause(self)

    -- 取消注册消息 --
    self:UnregisterEvent(messageGuids.BattleStartCameraZoomUp, OnBeginAssistAttack, nil)
    self:UnregisterEvent(messageGuids.BattleEndCameraZoomUp, OnEndAssistAttack, nil)
end

return BattleAssistCameraEffectNode
