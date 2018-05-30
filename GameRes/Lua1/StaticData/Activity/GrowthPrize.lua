require "StaticData.Manager"

local GrowthPrizeData = Class(LuaObject)

function  GrowthPrizeData:Ctor(id)
	local GrowthPrizeDataMgr = Data.GrowthPrize.Manager.Instance()
	self.data = GrowthPrizeDataMgr:GetObject(id)
	if self.data == nil then
		error(string.format("活动，ID：%s 不存在",id))
		return
	end
end

function  GrowthPrizeData:GetID()
	return self.data.id
end

function  GrowthPrizeData:GetType()
	return self.data.type
end

function  GrowthPrizeData:GetIndex()
	return self.data.index
end

function  GrowthPrizeData:GetDescription()
	return self.data.description
end

function  GrowthPrizeData:GetLimit()
	return self.data.limit
end

function  GrowthPrizeData:GetAwardID()
	return self.data.awardID
end

function  GrowthPrizeData:GetAwardNum()
	return self.data.awardNum
end



local GrowthPrizeManager = Class(DataManager)

local GrowthPrizeDataMgr = GrowthPrizeManager.New(GrowthPrizeData)



return GrowthPrizeDataMgr