require "Network.Message"

MessageManager = Class(LuaObject)

function MessageManager:Ctor()
	self.name2Message = {}
	self.id2Message = {}
	local protocols = require "Network.Net"
	for k, v in pairs(protocols) do
		local message = Message.New(k, v)
		self.name2Message[k] = message
		
		local field = v.GetFieldDescriptor("id")
		self.id2Message[field.default_value] = message
	end

	self.id2Int = {}
	self.int2Id = {}
	local ids = require "Network.PB.ProtocolId"
	for k, v in pairs(ids) do
		if type(v) == "number" then
			self.id2Int[k] = v
			self.int2Id[v] = k
		end
	end
end

function MessageManager:CreateMessageByName(name)
	local message = self.name2Message[name]
	if message == nil then
		return nil
	end

	return message:Clone(), message:GetPrototype()
end

function MessageManager:CreateMessageById(intId)
	if intId <= 0 then
		print("MessageManager:CreateMessageById failed, cause id isn't valid")
		return
	end

	local id = self.int2Id[intId]
	if id == nil or self.id2Message[id] == nil then
		print("MessageManager:CreateMessageById failed, cause can't find id")
		return
	end
	return self.id2Message[id]:Clone()
end

function MessageManager:CreateMessageByData(intId, data)
	if intId <= 0 then
		print("MessageManager:CreateMessageByData failed, cause id isn't valid")
		return
	end

	if type(data) ~= "string" then
		print("MessageManager:CreateMessageByData failed, cause data isn't string.")
		return
	end

	local id = self.int2Id[intId]
	if id == nil or self.id2Message[id] == nil then
		print("MessageManager:CreateMessageByData failed, cause can't find id")
		return
	end
	local msg = self.id2Message[id]:Clone()
	msg:ParseFromString(data)
	return msg
end

function MessageManager:GetProtocolId(prototype)
	local field = prototype.GetFieldDescriptor("id")
	return self.id2Int[field.default_value]
end

function MessageManager:GetProtocolNameById(id)
	if id == nil or self.id2Message[id] == nil then
		print("MessageManager:CreateMessageByData failed, cause can't find id", id)
		return
	end
	return self.id2Message[id]:GetName()
end

function MessageManager:ToString()
	return "MessageManager"
end

local messageManager = MessageManager.New()
return messageManager