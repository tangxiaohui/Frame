require "StaticData.Manager"

local ActivityData = Class(LuaObject)

function ActivityData:Ctor(id)
	local ActivityMgr = Data.NewServerLevel.Manager.Instance()
	self.data = ActivityMgr:GetObject(id)
	if self.data == nil then
		error(string.format("等级冲刺，ID：%s 不存在",id))
		return
	end
end 

function ActivityData:GetID()
	return self.data.id
end

function ActivityData:GetLevel()
	return self.data.level
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
    return Data.NewServerLevel.Manager.Instance():GetKeys()
end

return ActivityDataMgr