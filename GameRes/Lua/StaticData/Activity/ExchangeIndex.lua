require "StaticData.Manager"

local ActivityData = Class(LuaObject)

function ActivityData:Ctor(id)
	local ActivityMgr = Data.ExchangeIndex.Manager.Instance()
	self.data = ActivityMgr:GetObject(id)
	if self.data == nil then
		error(string.format("限时兑换条目，ID：%s 不存在",id))
		return
	end
end 

function ActivityData:GetID()
	return self.data.id
end

function ActivityData:GetNeedItemID()
	return self.data.needitem
end

function ActivityData:GetNeedItemNum()
	return self.data.needitemnum
end

function ActivityData:GetItemID()
	return self.data.getitem
end

function ActivityData:GetItemNum()
	return self.data.getitemnum
end

function ActivityData:GetIndextype()
	return self.data.indextype
end

function ActivityData:GetInfo()
	return self.data.info
end

local ActivityManagerClass = Class(DataManager)

local ActivityDataMgr = ActivityManagerClass.New(ActivityData)

function ActivityDataMgr:GetKeys()
    return Data.ExchangeIndex.Manager.Instance():GetKeys()
end

return ActivityDataMgr