--
-- User: fenghao
-- Date: 5/29/17
-- Time: 6:40 PM
--

-- 到 准备登录渠道 转换
local TransitionClass = require "Framework.FSM.Transition"

local LuaReload2PrepareToLoginChannelTransition = Class(TransitionClass)

function LuaReload2PrepareToLoginChannelTransition:Ctor()
end

function LuaReload2PrepareToLoginChannelTransition:IsTriggered(_, data)
end

function LuaReload2PrepareToLoginChannelTransition:GetTargetState(_, data)
end


-- 状态 Lua重装载
local StateClass = require "Framework.FSM.State"

local LuaReloadState = Class(StateClass)

function LuaReloadState:Ctor()
    self:AddTransition(LuaReload2PrepareToLoginChannelTransition.New())
end

function LuaReloadState:Enter(owner, data)
end

function LuaReloadState:Update(owner, data)
end

function LuaReloadState:Exit(owner, data)
end

return LuaReloadState