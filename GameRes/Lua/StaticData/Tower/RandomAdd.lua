require "StaticData.Manager"

local RandomAddData = Class(LuaObject)

function RandomAddData:Ctor(id)
	local TowerMgr = Data.RandomAdd.Manager.Instance()
	self.data = TowerMgr:GetObject(id)
	if self.data == nil then
		error(string.format("加成，ID：%s 不存在",id))
		return
	end
end

function  RandomAddData:GetID()
	return self.data.id
end

function  RandomAddData:GetTypeid()
	return self.data.typeid
end

function  RandomAddData:GetPriceRate()
	return self.data.PriceRate
end

function RandomAddData:GetIcon()
	return self.data.Icon
end

local TowerDataManager = Class(DataManager)
local TowerDataMgr = TowerDataManager.New(RandomAddData)

return TowerDataMgr