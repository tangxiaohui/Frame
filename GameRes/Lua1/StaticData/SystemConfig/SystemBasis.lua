require "StaticData.Manager"

SystemBasisData = Class(LuaObject)

function SystemBasisData:Ctor(id)
    local SystemBasisMgr = Data.SystemBasis.Manager.Instance()
    
    self.data = SystemBasisMgr:GetObject(id)
    if self.data == nil then
        error(string.format("系统设置SystemBasis信息不存在，ID: %s 不存在", id))
        return
    end

end

function SystemBasisData:GetId()
    return self.data.id
end

function SystemBasisData:GetMinLevel()
    return self.data.minLevel
end

function SystemBasisData:GetDescriptionInfo()
    return self.data.descriptionInfo
end

function SystemBasisData:GetInfo()
    return self.data.info
end

function SystemBasisData:GetRefType()
	return self.data.refType
end

SystemBasisManager = Class(DataManager)

local SystemBasisDataMgr = SystemBasisManager.New(SystemBasisData)
function SystemBasisDataMgr:GetKeys()
    return Data.SystemBasis.Manager.Instance():GetKeys()
end
return SystemBasisDataMgr