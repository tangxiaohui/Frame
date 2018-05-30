--
-- User: fenghao
-- Date: 5/29/17
-- Time: 6:43 PM
--

-- 到 等待连接 转换
local TransitionClass = require "Framework.FSM.Transition"

local RequestServerList2WaitingForConnectTransition = Class(TransitionClass)

function RequestServerList2WaitingForConnectTransition:Ctor()
end

function RequestServerList2WaitingForConnectTransition:IsTriggered(_, data)
end

function RequestServerList2WaitingForConnectTransition:GetTargetState(_, data)
end


-- 状态 请求服务器列表
local StateClass = require "Framework.FSM.State"

local RequestServerListState = Class(StateClass)

function RequestServerListState:Ctor()
    self:AddTransition(RequestServerList2WaitingForConnectTransition.New())
end

function RequestServerListState:Enter(owner, data)
end

function RequestServerListState:Update(owner, data)
end

function RequestServerListState:Exit(owner, data)
end

return RequestServerListState