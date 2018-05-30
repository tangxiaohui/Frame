require "StaticData.Manager"

local VipInfoData = Class(LuaObject)

function  VipInfoData:Ctor(id)
	local VipInfoMgr = Data.VipInfo.Manager.Instance()
	self.data = VipInfoMgr:GetObject(id)
	if self.data == nil then
		error(string.format("活动，ID：%s 不存在",id))
		return
	end
end

function VipInfoData:GetID()
	return self.data.id
end

function VipInfoData:GetInfo()
	return self.data.info
end

function VipInfoData:GetPosition()
	return self.data.position
end

function VipInfoData:GetLEVEL0Info()
	return self.data.LEVEL0Info
end

function VipInfoData:GetIsShow()
	return self.data.isShow
end

local VipInfoDataManager = Class(DataManager)

local VipInfoDataMgr = VipInfoDataManager.New(VipInfoData)

function VipInfoDataMgr:GetKeys()
    return Data.VipInfo.Manager.Instance():GetKeys()
end

return VipInfoDataMgr