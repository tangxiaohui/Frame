require "Framework.GameSubSystem"

local Network = Class(GameSubSystem)

function Network:Ctor()
	self.gameSession = GameSession.Instance
	self.msgDispatcher = require "Network.MsgDispatcher".New()
	self.maxMsgHandledPerFrame = 50
	self.receivedMsg = nil
end

-----------------------------------------------------------------------
--- 实现 GameSubSystem 接口
-----------------------------------------------------------------------
function Network:GetGuid()
	return require "Framework.SubsystemGUID".Network
end

function Network:Startup()
end

function Network:Shutdown()
	--self.gameSession:Close()
	--print('session closed!')
end

function Network:Restart()
end

function Network:Close()
	self.gameSession:Close()
end

function Network:Update()
	--print("Network:Update")
	self.gameSession:Update()

	local numHandledMsg = 0
	local receivedMsg = self.receivedMsg
	if receivedMsg ~= nil and receivedMsg.Count > 0 then
		self.receivedMsg = nil
		local count = receivedMsg.Count
		for i = 1, count do
			local protocol = receivedMsg[0]
			if protocol.Id > 0 then
				self.msgDispatcher:OnReceiveMsg(protocol.Id, protocol.Data)
			end
			receivedMsg:RemoveAt(0)
			numHandledMsg = numHandledMsg + 1
			if numHandledMsg >= self.maxMsgHandledPerFrame then
				self.receivedMsg = receivedMsg
				return
			end
		end
	end

	local newProtocols = self.gameSession:GetProtocols()
	if newProtocols ~= nil and newProtocols.Count > 0 then
		if numHandledMsg >= self.maxMsgHandledPerFrame then
			if self.receivedMsg == nil then
				self.receivedMsg = newProtocols
			else
				self.receivedMsg:AddRange(newProtocols)
			end
			return
		end

		local count = newProtocols.Count
		for i = 1, count do
			local protocol = newProtocols[0]
			if protocol.Id > 0 then
				self.msgDispatcher:OnReceiveMsg(protocol.Id, protocol.Data)
			end
			newProtocols:RemoveAt(0)
			numHandledMsg = numHandledMsg + 1
			if numHandledMsg >= self.maxMsgHandledPerFrame then
				if self.receivedMsg == nil then
					self.receivedMsg = newProtocols
				else
					self.receivedMsg:AddRange(newProtocols)
				end
				return
			end
		end
	end
end

function Network:IsConnected()
	return self.gameSession:IsConnected()
end

function Network:Connect(ip, port, username, password)
	if self.gameSession:IsConnecting() or self.gameSession:IsConnected() then
		return
	end
	self.gameSession:Login(ip, port, username, password)
end

function Network:SendMsg(msg, prototype)
	local messageManager = require "Network.MessageManager"
	local id = messageManager:GetProtocolId(prototype)
	-- debug_print("send id", id)
	self.gameSession:SendProtocol(id, msg:SerializeToString())
end

function Network:RegisterMsgHandler(prototype, handler, func)
	local messageManager = require "Network.MessageManager"
	local id = messageManager:GetProtocolId(prototype)
	
	self.msgDispatcher:RegisterMsgHandler(id, handler, func)
end

function Network:UnRegisterMsgHandler(prototype, handler, func)
	local messageManager = require "Network.MessageManager"
	local id = messageManager:GetProtocolId(prototype)

	self.msgDispatcher:UnRegisterMsgHandler(id, handler, func)
end

function Network:GetProtocolNetName(id)
	local messageManager = require "Network.MessageManager"
	return messageManager:GetProtocolNameById(id)
end

function Network:ToString()
	return "Network"
end

return Network