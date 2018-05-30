require "StaticData.Manager"

local ActiveData = Class(LuaObject)

function  ActiveData:Ctor(id)
	local ActivityItemMgr = Data.ProgressChargeInfo.Manager.Instance()
	self.data = ActivityItemMgr:GetObject(id)
	if self.data == nil then
		error(string.format("逐额充值Info，ID：%s 不存在",id))
		return
	end
end

function  ActiveData:GetID()
	return self.data.id
end

function ActiveData:GetDescription()
	return self.data.description
end

function ActiveData:GetTitle()
	return self.data.title
end

function ActiveData:GetRate()
	return self.data.rate
end

local ActiveManager = Class(DataManager)

local ActiveDataMgr = ActiveManager.New(ActiveData)

function ActiveDataMgr:GetKeys()
	return Data.ProgressChargeInfo.Manager.Instance():GetKeys()
end

return ActiveDataMgr