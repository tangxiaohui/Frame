require "StaticData.Manager"

RoleRacialData = Class(LuaObject)

function RoleRacialData:Ctor(id)
	local RoleRacialMgr = Data.RoleRacial.Manager.Instance()
	self.data = RoleRacialMgr:GetObject(id)
	
	if self.data == nil then
		error(string.format("种族信息不存在，ID:%s 不存在",id))
		return
	end
end

function RoleRacialData:GetID()
	return self.data.id
end

function RoleRacialData:GetRacialIcon()
	return self.data.RacialIcon
end

RoleRacialDataManager = Class(DataManager)

local RoleRacialDataMgr = RoleRacialDataManager.New(RoleRacialData)

return RoleRacialDataMgr