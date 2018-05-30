require "StaticData.Manager"

local VipPacksData = Class(LuaObject)

function  VipPacksData:Ctor(id)
	local VipPacksMgr = Data.VipPacks.Manager.Instance()
	self.data = VipPacksMgr:GetObject(id)
	if self.data == nil then
		error(string.format("活动，ID：%s 不存在",id))
		return
	end
end

function VipPacksData:GetID()
	return self.data.id
end

function VipPacksData:GetPrice()
	return self.data.price
end

function VipPacksData:GetItemID()
	return self.data.itemID
end

function VipPacksData:GetItemNum()
	return self.data.itemNum
end

function VipPacksData:GetItemColor()
	return self.data.itemColor
end

local VipPacksDataManager = Class(DataManager)

local VipPacksDataMgr = VipPacksDataManager.New(VipPacksData)

function VipPacksDataMgr:GetKeys()
    return Data.VipPacks.Manager.Instance():GetKeys()
end

return VipPacksDataMgr