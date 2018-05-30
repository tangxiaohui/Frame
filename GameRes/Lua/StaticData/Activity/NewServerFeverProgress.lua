require "StaticData.Manager"

local ActivityData = Class(LuaObject)

function ActivityData:Ctor(id)
	local ActivityMgr = Data.NewServerFeverProgress.Manager.Instance()
	self.data = ActivityMgr:GetObject(id)
	if self.data == nil then
		error(string.format("七日狂欢进度，ID：%s 不存在",id))
		return
	end
end 

function ActivityData:GetID()
	return self.data.id
end

function ActivityData:GetItemID()
	return self.data.awarditemID
end

function ActivityData:GetItemNum()
	return self.data.awarditemNum
end

function ActivityData:GetProgress()
	return self.data.progress
end

function ActivityData:GetInfo()
	return self.data.info
end

local ActivityManagerClass = Class(DataManager)

local ActivityDataMgr = ActivityManagerClass.New(ActivityData)

function ActivityDataMgr:GetKeys()
    return Data.NewServerFeverProgress.Manager.Instance():GetKeys()
end

return ActivityDataMgr