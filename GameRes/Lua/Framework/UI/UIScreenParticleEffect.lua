--
-- User: fenghao
-- Date: 11/07/2017
-- Time: 4:25 PM
--

require "Object.LuaObject"
local utility = require "Utils.Utility"

local UIScreenParticleEffect = Class(LuaObject)

function UIScreenParticleEffect:Ctor(canvas, gameObject)
    self.gameObject = gameObject
    self.canvas = canvas
    self.screenClickButton = self.gameObject:GetComponent(typeof(ScreenClickButton))

    -- 加载对象 --
    utility.LoadNewPureGameObjectAsync("Effect/Effects/UI/UI_tongyong_dianji", function(gameObject)
        self.particleSystemObject = gameObject
        self.particleSystemTransform = gameObject.transform
        self.particleSystemTransform:SetParent(self.canvas:GetCanvasTransform(), true)
        self.particleSystemTransform.localScale = Vector3(1, 1, 1)
        self.particleSystemTransform.localPosition = Vector3(0, 0, 0)
        self.particleSystemTransform.localRotation = Quaternion.identity
    end)
end

local function GetParticleSystem(self)
    return self.particleSystemObject, self.particleSystemTransform
end

local function RepositionParticleSystem(canvas, transform)
    local screenPosition = UnityEngine.Input.mousePosition

    local camera = canvas:GetCamera()

    local targetWorldPosition = camera:ScreenToWorldPoint(screenPosition)

    transform.position = targetWorldPosition

    local localPos = transform.localPosition
    localPos.z = 0
    transform.localPosition = localPos
end

local function OnScreenClickButtonClicked(self)
    local game = utility.GetGame()
    local GamePhase = require "Game.GamePhase"
    if game:GetCurrentPhase() == GamePhase.Battle then
        return
    end

    local go, transform = GetParticleSystem(self)
    if go ~= nil then
        RepositionParticleSystem(self.canvas, transform)
        utility.PlayParticleSystem(go)
		
		-- -- 播放點擊音效
		-- local audioManager = game:GetAudioManager()
		-- audioManager:PlaySE(3)
    end
end

local function OnGlobalButtonClicked()
    local game = utility.GetGame()
    local audioManager = game:GetAudioManager()
    audioManager:PlaySE(1)
end

function UIScreenParticleEffect:Start()
    -- 屏幕点击 --
    self.__event_screenClickButtonClicked__ = UnityEngine.Events.UnityAction(OnScreenClickButtonClicked, self)
    self.screenClickButton.onClick:AddListener(self.__event_screenClickButtonClicked__)

    -- 注册按钮点击全局事件
    self.__evnet_globalButtonClicked__ = UnityEngine.Events.UnityAction(OnGlobalButtonClicked, self)
    UnityEngine.UI.Button.onClickStatic:AddListener(self.__evnet_globalButtonClicked__)
end

function UIScreenParticleEffect:Reset()
    -- 屏幕点击 --
    if self.__event_screenClickButtonClicked__ then
        self.screenClickButton.onClick:RemoveListener(self.__event_screenClickButtonClicked__)
        self.__event_screenClickButtonClicked__ = nil
    end

    -- 取消注册按钮点击全局事件
    if self.__evnet_globalButtonClicked__ then
        UnityEngine.UI.Button.onClickStatic:RemoveListener(self.__evnet_globalButtonClicked__)
        self.__evnet_globalButtonClicked__ = nil
    end
end

return UIScreenParticleEffect
