require "StaticData.Manager"

local TowerData = Class(LuaObject)

function TowerData:Ctor(id)
	local TowerMgr = Data.TowerBiglevelaward.Manager.Instance()
	self.data = TowerMgr:GetObject(id)
	if self.data == nil then
		error(string.format("爬塔，ID：%s 不存在",id))
		return
	end
end

function  TowerData:GetID()
	return self.data.id
end

function  TowerData:GetLevel()
	return self.data.level
end

function  TowerData:GetNeeeStar()
	return self.data.neeeStar
end

function  TowerData:GetAwarditem()
	return self.data.awarditem
end

function  TowerData:GetAwardnum()
	return self.data.awardnum
end

local TowerDataManager = Class(DataManager)
local TowerDataMgr = TowerDataManager.New(TowerData)

function TowerDataMgr:GetKeys()
    return Data.TowerBiglevelaward.Manager.Instance():GetKeys()
end
return TowerDataMgr