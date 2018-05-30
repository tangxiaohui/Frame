require "StaticData.Manager"

local TowerLevelData = Class(LuaObject)

function TowerLevelData:Ctor(id)
	local TowerMgr = Data.TowerLevels.Manager.Instance()
	self.data = TowerMgr:GetObject(id)
	if self.data == nil then
		error(string.format("爬塔关卡，ID：%s 不存在",id))
		return
	end
end

function  TowerLevelData:GetID()
	return self.data.id
end

function  TowerLevelData:GetLevelid()
	return self.data.levelid
end

function  TowerLevelData:GetBosstimes()
	return self.data.bosstimes
end

function  TowerLevelData:GetInfo()
	return self.data.info
end

function  TowerLevelData:GetType()
	return self.data.type
end

function  TowerLevelData:GetMapType()
	return self.data.maptype
end

function  TowerLevelData:GetStarcount()
	return self.data.starcount
end

function  TowerLevelData:GetMonsterLevel()
	return self.data.monster_level
end

function TowerLevelData:GetMonsterStage()
	return self.data.monster_stage
end

function  TowerLevelData:GetSceneID()
	return self.data.sceneId
end

function  TowerLevelData:GetTeamid()
	return self.data.teamid
end

function  TowerLevelData:GetTeamIcon()
	return self.data.TeamIcon
end

function  TowerLevelData:GetWintype()
	return self.data.wintype
end

function  TowerLevelData:GetWintypeparam()
	return self.data.wintypeparam
end

function  TowerLevelData:GetTeamPower()
	return self.data.TeamPower
end

function  TowerLevelData:GetConditionInfo()
	return self.data.ConditionInfo
end

function  TowerLevelData:GetAwarditem()
	return self.data.awarditem
end

function  TowerLevelData:GetAwardnum()
	return self.data.awardnum
end

local TowerDataManager = Class(DataManager)
local TowerDataMgr = TowerDataManager.New(TowerLevelData)
function TowerDataMgr:GetKeys()
    return Data.TowerLevels.Manager.Instance():GetKeys()
end

return TowerDataMgr