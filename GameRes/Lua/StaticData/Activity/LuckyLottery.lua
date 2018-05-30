require "StaticData.Manager"

local ActiveData = Class(LuaObject)

function  ActiveData:Ctor(id)
	local ActivityItemMgr = Data.LuckyLottery.Manager.Instance()
	self.data = ActivityItemMgr:GetObject(id)
	if self.data == nil then
		error(string.format("转转乐，ID：%s 不存在",id))
		return
	end
end

function  ActiveData:GetID()
	return self.data.id
end

function ActiveData:GetOnetime()
	return self.data.onetime
end

function ActiveData:GetTentime()
	return self.data.tentime
end


function ActiveData:GetAcquirdJifen()
	return self.data.acquirdJifen
end

function ActiveData:GetJifenID()
	return self.data.jifenID
end

local ActiveManager = Class(DataManager)

local ActiveDataMgr = ActiveManager.New(ActiveData)

function ActiveDataMgr:GetKeys()
	return Data.LuckyLottery.Manager.Instance():GetKeys()
end

return ActiveDataMgr