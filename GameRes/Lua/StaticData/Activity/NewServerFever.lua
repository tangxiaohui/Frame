require "StaticData.Manager"

local ActivityData = Class(LuaObject)

function ActivityData:Ctor(id)
	local ActivityMgr = Data.NewServerFever.Manager.Instance()
	self.data = ActivityMgr:GetObject(id)
	if self.data == nil then
		error(string.format("七日狂欢，ID：%s 不存在",id))
		return
	end
end 

function ActivityData:GetID()
	return self.data.id
end

function ActivityData:GetDay()
	return self.data.day
end

function ActivityData:GetIndex()
	return self.data.index
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

function ActivityData:GetProgress()
	return self.data.progress
end

local ActivityManagerClass = Class(DataManager)

local ActivityDataMgr = ActivityManagerClass.New(ActivityData)

function ActivityDataMgr:GetKeys()
    return Data.NewServerFever.Manager.Instance():GetKeys()
end

return ActivityDataMgr