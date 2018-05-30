
require "Object.LuaObject"
require "System.LuaDelegate"
local utility = require "Utils.Utility"
local TweenUtility = require "Utils.TweenUtility"


local Tween = Class()

local function GetActualTweenFunction(replacementTweenFunction)
    if type(replacementTweenFunction) ~= "function" then
        return TweenUtility.Linear
    else
        return replacementTweenFunction 
    end
end

local function GetDeltaTime(self)
    return UnityEngine.Time.deltaTime
end

function Tween:Ctor(tweenFunction)
    self.passedTime = 0
    self.isPlaying = false
    self.callbackOnComplete = LuaDelegate.New()
    self.callbackOnUpdate = LuaDelegate.New()
    self.tweenFunction = GetActualTweenFunction(tweenFunction)
end

function Tween:GetDuration()
    return self.duration
end

function Tween:SetDuration(duration)
    self.duration = duration or 0
end

function Tween:GetStartValue()
    return self.startValue
end

function Tween:SetStartValue(startValue)
    self.startValue = startValue
end

function Tween:GetEndValue()
    return self.endValue
end

function Tween:SetEndValue(endValue)
    self.endValue = endValue
end

function Tween:IsPlaying()
    return self.isPlaying
end

function Tween:Stop()
    if self.isPlaying then
        self.passedTime = 0
        self.isPlaying = false
    end
end

function Tween:Pause()
    self.isPlaying = false
end

function Tween:Play()
    self.isPlaying = true
end

function Tween:SetCallbackOnComplete(instance, func)
    self.callbackOnComplete:Set(instance, func)
end

function Tween:SetCallbackOnUpdate(instance, func)
    self.callbackOnUpdate:Set(instance, func)
end

function Tween:Update()
    if self:IsPlaying() then
        local t
        if self.duration ~= 0 then
            t = self.passedTime / self.duration
        else
            t = 1
        end
        
        local finished
        if t >= 1 then
            t = 1
            finished = true
        end
        
        local value = self.tweenFunction(self.startValue, self.endValue, t)
        self.callbackOnUpdate:Invoke(value)

        self.passedTime = self.passedTime + GetDeltaTime(self)


        if finished then
            self.callbackOnComplete:Invoke()
            self:Stop()
        end
    end
end

return Tween
