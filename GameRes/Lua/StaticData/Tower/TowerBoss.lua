require "StaticData.Manager"

local TowerData = Class(LuaObject)

function TowerData:Ctor(id)
	local TowerMgr = Data.TowerBoss.Manager.Instance()
	self.data = TowerMgr:GetObject(id)
	if self.data == nil then
		error(string.format("爬塔Boss，ID：%s 不存在",id))
		return
	end
end

function  TowerData:GetID()
	return self.data.id
end

function  TowerData:GetBossinfo()
	return self.data.bossinfo
end

function  TowerData:GetMonsterLevel()
	return self.data.monster_level
end

function  TowerData:GetMonsterStage()
	return self.data.monster_stage
end

function  TowerData:GetTeamid()
	return self.data.teamid
end

function  TowerData:GetTeamPortrait()
	return self.data.TeamPortrait
end

function  TowerData:GetAwarditem()
	return self.data.awarditem
end

function  TowerData:GetAwardnum()
	return self.data.awardnum
end

function  TowerData:GetFirstitem()
	return self.data.firstitem
end

function  TowerData:GetFirstnum()
	return self.data.firstnum
end


local TowerDataManager = Class(DataManager)
local TowerDataMgr = TowerDataManager.New(TowerData)

function TowerDataMgr:GetKeys()
    return Data.TowerBoss.Manager.Instance():GetKeys()
end

return TowerDataMgr