require "StaticData.Manager"

local LimitGodActivityData = Class(LuaObject)

function  LimitGodActivityData:Ctor(id)
	local LimitGodActivityDataMgr = Data.LimitGodActivity.Manager.Instance()
	self.data = LimitGodActivityDataMgr:GetObject(id)
	if self.data == nil then
		error(string.format("活动，ID：%s 不存在",id))
		return
	end
end

function  LimitGodActivityData:GetID()
	return self.data.id
end

function LimitGodActivityData:GetInfo()
	return self.data.info
end

function LimitGodActivityData:GetOnetime()
	return self.data.onetime
end

function LimitGodActivityData:GetTentime()
	return self.data.tentime
end

function LimitGodActivityData:GetRoleID()
	return self.data.ID
end
function LimitGodActivityData:GetPic1()
	return self.data.pic1
end

function LimitGodActivityData:GetPic2()
	return self.data.pic2
end

function LimitGodActivityData:GetPic3()
	return self.data.pic3
end

local LimitGodActivityManager = Class(DataManager)

local LimitGodActivityDataMgr = LimitGodActivityManager.New(LimitGodActivityData)



return LimitGodActivityDataMgr