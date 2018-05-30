require "StaticData.Manager"

PowerRatio = Class(LuaObject)

function PowerRatio:Ctor(id)
	local ratioMgr = Data.PowerRatio.Manager.Instance()
	self.data = ratioMgr:GetObject(id)
	if self.data == nil then
		print(string.format("基础属性计算系数初始化失败，ID: %s 不存在", id))
		return
	end
end

function PowerRatio:ToString()
	return "PowerRatio"
end

function PowerRatio:GetHpRatio()
	return self.data.hp
end

function PowerRatio:GetApRatio()
	return self.data.ap
end

function PowerRatio:GetDpRatio()
	return self.data.dp
end

function PowerRatio:GetSpeedRatio()
	return self.data.speed
end

function PowerRatio:GetVamRatio()
	return self.data.vam
end

function PowerRatio:GetAvoidRatio()
	return self.data.avoid
end

function PowerRatio:GetDecritRatio()
	return self.data.decrit
end

function PowerRatio:GetCritRatio()
	return self.data.crit
end

function PowerRatio:GetHitRatio()
	return self.data.hit
end

function PowerRatio:GetSkillDamageRatio()
	return self.data.skillDamage
end

function PowerRatio:GetAttackDamageRatio()
	return self.data.attackDamage
end

PowerRatioManager = Class(DataManager)

local powerRatioManager = PowerRatioManager.New(PowerRatio)
return powerRatioManager