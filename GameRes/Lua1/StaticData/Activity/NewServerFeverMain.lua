require "StaticData.Manager"

local ActivityData = Class(LuaObject)

function ActivityData:Ctor(id)
	local ActivityMgr = Data.NewServerFeverMain.Manager.Instance()
	self.data = ActivityMgr:GetObject(id)
	if self.data == nil then
		error(string.format("七日狂欢Info，ID：%s 不存在",id))
		return
	end
end 

function ActivityData:GetID()
	return self.data.id
end


local ActivityManagerClass = Class(DataManager)
local ActivityDataMgr = ActivityManagerClass.New(ActivityData)

function ActivityDataMgr:GetKeys()
    return Data.Activity.Manager.Instance():GetKeys()
end

function ActivityDataMgr:GetProgress()
	local count = 0
	local feverData = require "StaticData.Activity.NewServerFever"
	local keys = feverData:GetKeys()
	for i=0,(keys.Length - 1) do
		local data = feverData:GetData(keys[i])
		count = count + data:GetProgress()
	end
	local feverGiftData = require "StaticData.Activity.NewServerFeverGift"
	local keys = feverGiftData:GetKeys()
	for i=0,(keys.Length - 1) do
		local data = feverGiftData:GetData(keys[i])
		count = count + data:GetProgress()
	end
	return count
end

return ActivityDataMgr