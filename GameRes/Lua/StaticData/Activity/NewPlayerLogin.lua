require "StaticData.Manager"

local ActivityData = Class(LuaObject)

function ActivityData:Ctor(id)
	local ActivityMgr = Data.NewPlayerLogin.Manager.Instance()
	self.data = ActivityMgr:GetObject(id)
	if self.data == nil then
		error(string.format("8日连续登陆，ID：%s 不存在",id))
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

function ActivityData:GetDay()
	return self.data.day
end

function ActivityData:GetInfo()
	return self.data.info
end

local ActivityManagerClass = Class(DataManager)

local ActivityDataMgr = ActivityManagerClass.New(ActivityData)

function ActivityDataMgr:GetKeys()
    return Data.NewPlayerLogin.Manager.Instance():GetKeys()
end

return ActivityDataMgr