--
-- User: fenghao
-- Date: 5/29/17
-- Time: 6:45 PM
--

local TransitionClass = require "Framework.FSM.Transition"

-- 到 等待连接 转换(向上)
local Connecting2WaitingForConnectTransition = Class(TransitionClass)

function Connecting2WaitingForConnectTransition:Ctor()
end

function Connecting2WaitingForConnectTransition:IsTriggered(_, data)
end

function Connecting2WaitingForConnectTransition:GetTargetState(_, data)
end

-- 到 断线 转换
local Connecting2DisconnectedTransition = Class(TransitionClass)

function Connecting2DisconnectedTransition:Ctor()
end

function Connecting2DisconnectedTransition:IsTriggered(_, data)
end

function Connecting2DisconnectedTransition:GetTargetState(_, data)
end

-- 到 已连接 转换
local Connecting2ConnectedTransition = Class(TransitionClass)

function Connecting2ConnectedTransition:Ctor()
end

function Connecting2ConnectedTransition:IsTriggered(_, data)
end

function Connecting2ConnectedTransition:GetTargetState(_, data)
end


-- 状态 连接中
local StateClass = require "Framework.FSM.State"

local ConnectingState = Class(StateClass)

function ConnectingState:Ctor()
    self:AddTransition(Connecting2WaitingForConnectTransition.New())
    self:AddTransition(Connecting2DisconnectedTransition.New())
    self:AddTransition(Connecting2ConnectedTransition.New())
end

function ConnectingState:Enter(owner, data)
end

function ConnectingState:Update(owner, data)
end

function ConnectingState:Exit(owner, data)
end

return ConnectingState
