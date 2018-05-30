require "StaticData.Manager"

LegionRightData = Class(LuaObject)

function LegionRightData:Ctor(id)
    local LegionRightMgr = Data.LegionRight.Manager.Instance()
    self.data = LegionRightMgr:GetObject(id)
    if self.data == nil then
        error(string.format("军团职位信息不存在，ID: %s 不存在", id))
        return
    end
end

function LegionRightData:GetId()
    return self.data.id
end

function LegionRightData:GetInfo()
    return self.data.info
end

function LegionRightData:GetMaxNum()
	return self.data.MaxNum
end

function LegionRightData:GetIsPermit()
	return self.data.IsPermit
end

function LegionRightData:GetIsKick()
	return self.data.IsKick
end

function LegionRightData:GetIsPosition()
    return self.data.IsPosition
end

function LegionRightData:GetIsHandout()
    return self.data.IsHandout
end

function LegionRightData:GetIsNotice()
    return self.data.IsNotice
end

function LegionRightData:GetIsActive()
    return self.data.IsActive
end

LegionRightManager = Class(DataManager)

local LegionRightDataMgr = LegionRightManager.New(LegionRightData)
return LegionRightDataMgr