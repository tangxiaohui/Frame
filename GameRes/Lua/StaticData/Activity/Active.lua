require "StaticData.Manager"

local ActiveData = Class(LuaObject)

function  ActiveData:Ctor(id)
	local ActivityItemMgr = Data.Active.Manager.Instance()
	self.data = ActivityItemMgr:GetObject(id)
	if self.data == nil then
		error(string.format("活动，ID：%s 不存在",id))
		return
	end
end

function  ActiveData:GetID()
	return self.data.id
end

function ActiveData:GetDescription()
	return self.data.description
end

function ActiveData:GetName()
	return self.data.name
end

function ActiveData:GetDescriptionNotice()
	return self.data.descriptionNotice
end

local ActiveManager = Class(DataManager)

local ActiveDataMgr = ActiveManager.New(ActiveData)

function ActiveDataMgr:GetKeys()
	return Data.Active.Manager.Instance():GetKeys()
end

return ActiveDataMgr