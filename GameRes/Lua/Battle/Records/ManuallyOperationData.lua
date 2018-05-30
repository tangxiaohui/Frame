--
-- User: fenghao
-- Date: 6/9/17
-- Time: 9:40 PM
--

require "Object.LuaObject"

local ManuallyOperationData = Class(LuaObject)

function ManuallyOperationData:Ctor()
end

function ManuallyOperationData:SetWave(wave)
    self.wave = wave
end

function ManuallyOperationData:GetWave()
    return self.wave
end

function ManuallyOperationData:SetRound(round)
    self.round = round
end

function ManuallyOperationData:GetRound()
    return self.round
end

function ManuallyOperationData:SetPos(pos)
    self.pos = pos
end

function ManuallyOperationData:GetPos()
    return self.pos
end

function ManuallyOperationData:SetTargets(targets)
    self.targets = targets
end

function ManuallyOperationData:GetTargets()
    return self.targets
end

function ManuallyOperationData:SetTargetType(targetType)
    self.targetType = targetType
end

function ManuallyOperationData:GetTargetType()
    return self.targetType
end

function ManuallyOperationData:SetTargetParam(param)
    self.targetParam = param
end

function ManuallyOperationData:GetTargetParam()
    return self.targetParam
end

function ManuallyOperationData:SetDiscard(discard)
    self.discarded = discard
end

function ManuallyOperationData:IsDiscarded()
    return self.discarded
end

-- msg = ManuallyOperationData
function ManuallyOperationData:CopyToProtobuf(msg)
    msg.wave = self:GetWave()
    msg.round = self:GetRound()
    msg.pos = self:GetPos()

	if self.targets ~= nil then
		for i = 1, #self.targets do
			msg.targets:append(self.targets[i])
		end
	end

    msg.targetType = self:GetTargetType()
    msg.targetParam = self:GetTargetParam()
    msg.discarded = self:IsDiscarded()
end

-- msg = ManuallyOperationData
function ManuallyOperationData:InitByProtobuf(msg)
    self:SetWave(msg.wave)
    self:SetRound(msg.round)
    self:SetPos(msg.pos)
    self:SetTargets(msg.targets)
    self:SetTargetType(msg.targetType)
    self:SetTargetParam(msg.targetParam)
    self:SetDiscard(msg.discarded)
end

return ManuallyOperationData