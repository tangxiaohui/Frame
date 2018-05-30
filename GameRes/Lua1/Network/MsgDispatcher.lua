
require "Object.LuaObject"

require "Framework.NotificationCenter"

local utility = require "Utils.Utility"

local MsgDispatcher = Class(LuaObject)

function MsgDispatcher:Ctor()
	self.internalNotificationCenter = NotificationCenter.New()
	self.gameNetwork = require "Network.GameNetwork".New()
end

local function CheckArguments(id, handler, func)
	utility.ASSERT(id ~= nil, "id不能为nil, 检查ProtocolId是否有定义!")
	utility.ASSERT(type(handler) == "table", "handler参数类型必须是table")
	utility.ASSERT(type(func) == "function", "func参数类型必须是function")
end

function MsgDispatcher:RegisterMsgHandler(id, handler, func)
	CheckArguments(id, handler, func)
	self.internalNotificationCenter:RemoveObserver(id, handler, func)
	self.internalNotificationCenter:AddObserver(id, handler, func)
end

function MsgDispatcher:UnRegisterMsgHandler(id, handler, func)
	CheckArguments(id, handler, func)
	self.internalNotificationCenter:RemoveObserver(id, handler, func)
end

function MsgDispatcher:OnReceiveMsg(id, data)
	-- debug_print("received id", id)
	local messageManager = require "Network.MessageManager"
	local msg = messageManager:CreateMessageByData(id, data)
	if msg ~= nil then
		if not self.gameNetwork:HandleMsg(id, msg) then
			self.internalNotificationCenter:PostNotificationReversely(id, nil, msg)
		end
	end
end

function MsgDispatcher:ToString()
	return "MsgDispatcher"
end

return MsgDispatcher