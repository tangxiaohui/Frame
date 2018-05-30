require "StaticData.Manager"

local ActivityData = Class(LuaObject)

function ActivityData:Ctor(id)
	local ActivityMgr = Data.Activefever.Manager.Instance()
	self.data = ActivityMgr:GetObject(id)
	if self.data == nil then
		error(string.format("七日狂欢Info，ID：%s 不存在",id))
		return
	end
end 

function ActivityData:GetID()
	return self.data.id
end

function ActivityData:GetDescription()
	return self.data.description
end

local ActivityManagerClass = Class(DataManager)
local ActivityDataMgr = ActivityManagerClass.New(ActivityData)


return ActivityDataMgr