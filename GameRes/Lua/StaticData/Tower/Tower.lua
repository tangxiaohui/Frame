require "StaticData.Manager"

local TowerData = Class(LuaObject)

function TowerData:Ctor(id)
	local TowerMgr = Data.Tower.Manager.Instance()
	self.data = TowerMgr:GetObject(id)
	if self.data == nil then
		error(string.format("爬塔，ID：%s 不存在",id))
		return
	end
end

function  TowerData:GetID()
	return self.data.id
end

function  TowerData:GetLevelreset()
	return self.data.levelreset
end

function  TowerData:GetBosstimes()
	return self.data.bosstimes
end

function  TowerData:GetBigLevel()
	return self.data.BigLevel
end

function  TowerData:GetAddPrice()
	return self.data.addPrice
end

function  TowerData:GetPriceRate()
	return self.data.PriceRate
end

local TowerDataManager = Class(DataManager)
local TowerDataMgr = TowerDataManager.New(TowerData)

return TowerDataMgr