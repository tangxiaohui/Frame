require "StaticData.Manager"

local ActivityConsumptionData = Class(LuaObject)

function ActivityConsumptionData:Ctor(id)
	local ActivityConsumptionMgr = Data.ActivityConsumption.Manager.Instance()
	self.data = ActivityConsumptionMgr:GetObject(id)
	if self.data == nil then
		error(string.format("活动类型，ID：%s 不存在",id))
		return
	end
end

function ActivityConsumptionData:GetID()
	return self.data.id
end

function ActivityConsumptionData:GetActivityId()
	return self.data.ActivityId
end

function ActivityConsumptionData:GetSerial()
	return self.data.serial
end

function ActivityConsumptionData:GetNeedSpending()
	return self.data.needSpending
end

function ActivityConsumptionData:GetItemID()
	return self.data.itemID
end

function ActivityConsumptionData:GetItemNum()
	return self.data.itemNum
end

function ActivityConsumptionData:GetItemColor()
	return self.data.itemColor
end


local ActivityConsumptionManager = Class(DataManager)

local ActivityConsumptionDataMgr = ActivityConsumptionManager.New(ActivityConsumptionData)

function ActivityConsumptionDataMgr:GetKeys()
	return Data.ActivityConsumption.Manager.Instance():GetKeys()
end

return ActivityConsumptionDataMgr