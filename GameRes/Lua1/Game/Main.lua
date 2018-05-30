require "Object.LuaObject"
require "Battle.Battlefield"
require "Battle.BattleParticipator"
require "Battle.BattleParameter"

Game = Class(LuaObject)

function Game:Ctor()
	--print("Game:Ctor")
	self.network = require "Network.Network"
	self.msgDispatcher = require "Network.MsgDispatcher"
	self.msgManager = require "Network.MessageManager"
	self.userData = require "Data.UserData"
	local roles = self.userData:GetRoles()
	local participators = {}
	for i = 1, 6 do
		participators[i] = BattleParticipator.New(roles[i]:GetId(), i, roles[i]:GetColor(), roles[i]:GetLv())
	end

	-- 初始化关卡参数
	local bp = BattleParameter.New()

	-- 初始化敌人队列
	bp:InitLeftUnitsWithDungeonData(1)

	-- 添加自己的队列 (永远是Side.Right)
	for i = 1, 6 do
		bp:AddUnit(participators[i], Side.Right)
	end
	bp:SetStarter(Side.Right)
	
	self.battlefield = Battlefield.New(bp)
end

function Game:Start()
	--print("Game:Start")
	self.network:Start()
	self.ip = "192.168.31.64"
	self.port = 1010
	self.username = "Test"
	self.password = "TestPwd"
end

function Game:Update(dt)
	--print("Game:Update")
	self.battlefield:Update()
	self.network:Update(dt)
end

function Game:Reconnect()
	self.network:Connect(self.ip, self.port, self.username, self.password)
end

function Game:RegisterMsgHandler(prototype, handler)
	self.msgDispatcher:RegisterMsgHandler(self.msgManager:GetProtocolId(prototype), handler)
end

function Game:UnRegisterMsgHandler(prototype, handler)
	self.msgDispatcher:UnRegisterMsgHandler(self.msgManager:GetProtocolId(prototype), handler)
end

function Game:ToString()
	return "Game"
end

local game = Game.New()
return game