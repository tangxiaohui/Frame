require "StaticData.Manager"

local GrowthfundData = Class(LuaObject)

function  GrowthfundData:Ctor(id)
	local GrowthfundDataMgr = Data.Growthfund.Manager.Instance()
	self.data = GrowthfundDataMgr:GetObject(id)
	if self.data == nil then
		error(string.format("活动，ID：%s 不存在",id))
		return
	end
end

function  GrowthfundData:GetID()
	return self.data.id
end

function  GrowthfundData:GetCost()
	return self.data.cost
end

function  GrowthfundData:GetLevellimit()
	return self.data.levellimit
end

function  GrowthfundData:GetType()
	return self.data.type
end

function  GrowthfundData:GetViplimit()
	return self.data.viplimit
end

function  GrowthfundData:GetAcquired()
	return self.data.acquired
end

local GrowthfundManager = Class(DataManager)

local GrowthfundDataMgr = GrowthfundManager.New(GrowthfundData)



return GrowthfundDataMgr