require "StaticData.Manager"

local ActivityData = Class(LuaObject)

function ActivityData:Ctor(id)
	local ActivityMgr = Data.NewServerLogin.Manager.Instance()
	self.data = ActivityMgr:GetObject(id)
	if self.data == nil then
		error(string.format("七日登陆，ID：%s 不存在",id))
		return
	end
end 

function ActivityData:GetID()
	return self.data.id
end

function ActivityData:GetDay()
	return self.data.day
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
    return Data.NewServerLogin.Manager.Instance():GetKeys()
end

return ActivityDataMgr