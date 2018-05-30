
require "Object.LuaObject"
local utility = require "Utils.Utility"
local TweenUtility = require "Utils.TweenUtility"

local AudioFader = Class(LuaObject)

local function GetDeltaTime(self)
    if self.ignoreTimeScale then
        return UnityEngine.Time.unscaledDeltaTime
    end
    return UnityEngine.Time.deltaTime
end

function AudioFader:Ctor()
    self.ignoreTimeScale = false
end

function AudioFader:SetIgnoreTimeScale(ignore)
    self.ignoreTimeScale = ignore
end

function AudioFader:Start(audioComponent, duration, targetVolume)
    utility.ASSERT(not self:IsFading(), "当前正在执行不能再次调用!")

    self.audioComponent = audioComponent
    self.isFading = true
    self.passedTime = 0
    self.totalTime = duration
    self.startVolume = audioComponent:GetVolume()
    self.endVolume = targetVolume
end

function AudioFader:Stop()
    if self:IsFading() then
        -- 恢复音量 --
        self.audioComponent:SetVolume(self.startVolume)
        self.audioComponent:Stop()
        self.isFading = nil
        self.passedTime = nil
        self.totalTime = nil
        self.startVolume = nil
        self.endVolume = nil
    end
end

function AudioFader:Update()
    if self:IsFading() and self.audioComponent:IsPlaying() then
        local t = self.passedTime / self.totalTime

        local finished

        if t >= 1 then
            t = 1
            finished = true
        end

        local volume = TweenUtility.Linear(self.startVolume, self.endVolume, t)
        self.audioComponent:SetVolume(volume)

        self.passedTime = self.passedTime + GetDeltaTime(self)

        if finished then
            self:Stop()
        end
    end
end

function AudioFader:IsFading()
    return utility.ToBoolean(self.isFading)
end

return AudioFader
