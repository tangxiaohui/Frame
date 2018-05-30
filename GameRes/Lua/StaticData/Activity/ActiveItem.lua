require "StaticData.Manager"

local ActiveItemData = Class(LuaObject)

function  ActiveItemData:Ctor(id)
	local ActivityItemMgr = Data.ActiveItem.Manager.Instance()
	self.data = ActivityItemMgr:GetObject(id)
	if self.data == nil then
		error(string.format("活动Item，ID：%s 不存在",id))
		return
	end
end

function  ActiveItemData:GetID()
	return self.data.id
end

function ActiveItemData:GetDescription()
	return self.data.description
end

local ActiveItemManager = Class(DataManager)

local ActiveItemDataMgr = ActiveItemManager.New(ActiveItemData)

function ActiveItemDataMgr:GetKeys()
	return Data.ActiveItem.Manager.Instance():GetKeys()
end

return ActiveItemDataMgr