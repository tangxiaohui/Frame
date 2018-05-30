require "StaticData.Manager"

local ActivityData = Class(LuaObject)

function ActivityData:Ctor(id)
	local ActivityMgr = Data.Exchange.Manager.Instance()
	self.data = ActivityMgr:GetObject(id)
	if self.data == nil then
		error(string.format("限时兑换，ID：%s 不存在",id))
		return
	end
end 

function ActivityData:GetID()
	return self.data.id
end

function ActivityData:GetExchangetimes()
	return self.data.Exchangetimes
end

function ActivityData:GetRefreshDya()
	return self.data.refreshDya
end

function ActivityData:GetInfo()
	return self.data.info
end

local ActivityManagerClass = Class(DataManager)

local ActivityDataMgr = ActivityManagerClass.New(ActivityData)

function ActivityDataMgr:GetKeys()
    return Data.Exchange.Manager.Instance():GetKeys()
end

return ActivityDataMgr