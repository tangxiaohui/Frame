
require "Class"
require "System.LuaDelegate"
local utility = require "Utils.Utility"

local TweenClass = require "Framework.Tween"

local AnimatedValueControl = Class()


local function OnUpdateValue(self, value)
    self.currentValue = value
    self.callbackOnUpdate:Invoke(value, self.owner)
end

local function InitTween(self)
    local TweenUtility = require "Utils.TweenUtility"
    self.tween = TweenClass.New(TweenUtility.Linear)
    self.tween:SetCallbackOnUpdate(self, OnUpdateValue)
end

function AnimatedValueControl:Ctor(owner)
    self.currentValue = 0
    self.duration = 0.3
    self.owner = owner
    self.callbackOnUpdate = LuaDelegate.New()
    InitTween(self)
end

function AnimatedValueControl:SetValue(newValue)
    self.tween:Stop()
    self.tween:SetStartValue(self.currentValue)
    self.tween:SetEndValue(newValue)
    self.tween:SetDuration(self.duration)
    self.tween:Play()
end

function AnimatedValueControl:SetCallbackOnUpdate(instance, func)
    self.callbackOnUpdate:Set(instance, func)
end

function AnimatedValueControl:Update()
    self.tween:Update()
end

return AnimatedValueControl
