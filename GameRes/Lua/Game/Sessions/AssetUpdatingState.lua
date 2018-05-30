--
-- User: fenghao
-- Date: 5/29/17
-- Time: 6:39 PM
--

-- 到 Lua 重装载 转换
local TransitionClass = require "Framework.FSM.Transition"

local AssetUpdating2LuaReloadTransition = Class(TransitionClass)

function AssetUpdating2LuaReloadTransition:Ctor()
end

function AssetUpdating2LuaReloadTransition:IsTriggered(_, data)
end

function AssetUpdating2LuaReloadTransition:GetTargetState(_, data)
end


-- 状态 资源更新
local StateClass = require "Framework.FSM.State"

local AssetUpdatingState = Class(StateClass)

function AssetUpdatingState:Ctor()
    self:AddTransition(AssetUpdating2LuaReloadTransition.New())
end

function AssetUpdatingState:Enter(owner, data)
end

function AssetUpdatingState:Update(owner, data)
end

function AssetUpdatingState:Exit(owner, data)
end

return AssetUpdatingState