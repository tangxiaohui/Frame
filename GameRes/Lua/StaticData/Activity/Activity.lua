require "StaticData.Manager"

local ActivityData = Class(LuaObject)

function ActivityData:Ctor(id)
	local ActivityMgr = Data.Activity.Manager.Instance()
	self.data = ActivityMgr:GetObject(id)
	if self.data == nil then
		error(string.format("活动，ID：%s 不存在",id))
		return
	end
end 

function ActivityData:GetID()
	return self.data.id
end

function ActivityData:GetActivityId()
	return self.data.activityId
end

function ActivityData:GetActivityType()
	return self.data.activityType
end

function ActivityData:GetTimeType()
	return self.data.timeType
end

function ActivityData:GetStartTime()
	return self.data.startTime
end

function ActivityData:GetEndTime()
	return self.data.endTime
end

function ActivityData:GetActivityAward()
	return self.data.activityAward
end

function ActivityData:GetActivetgrandype()
	return self.data.activetgrandype
end

local ActivityManagerClass = Class(DataManager)

local ActivityDataMgr = ActivityManagerClass.New(ActivityData)

function ActivityDataMgr:GetKeys()
    return Data.Activity.Manager.Instance():GetKeys()
end

return ActivityDataMgr