require "StaticData.Manager"

local ActivityData = Class(LuaObject)

function ActivityData:Ctor(id)
	local ActivityMgr = Data.NewServerFeverGift.Manager.Instance()
	self.data = ActivityMgr:GetObject(id)
	if self.data == nil then
		error(string.format("七日狂欢礼包，ID：%s 不存在",id))
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

function ActivityData:GetNeeditemID()
	return self.data.needitemID
end

function ActivityData:GetNeeditemNum()
	return self.data.needitemNum
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

local ActivityManagerClass = Class(DataManager)

local ActivityDataMgr = ActivityManagerClass.New(ActivityData)

function ActivityDataMgr:GetKeys()
    return Data.NewServerFeverGift.Manager.Instance():GetKeys()
end

return ActivityDataMgr