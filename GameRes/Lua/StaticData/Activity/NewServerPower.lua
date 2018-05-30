require "StaticData.Manager"

local ActivityData = Class(LuaObject)

function ActivityData:Ctor(id)
	local ActivityMgr = Data.NewServerPower.Manager.Instance()
	self.data = ActivityMgr:GetObject(id)
	if self.data == nil then
		error(string.format("战力冲刺，ID：%s 不存在",id))
		return
	end
end 

function ActivityData:GetID()
	return self.data.id
end

function ActivityData:GetPower()
	return self.data.Power
end

function ActivityData:GetInfo()
	return self.data.info
end

function ActivityData:GetItemID()
	return self.data.itemID
end

function ActivityData:GetItemNum()
	return self.data.itemNum
end

local ActivityManagerClass = Class(DataManager)

local ActivityDataMgr = ActivityManagerClass.New(ActivityData)

function ActivityDataMgr:GetKeys()
    return Data.NewServerPower.Manager.Instance():GetKeys()
end

return ActivityDataMgr