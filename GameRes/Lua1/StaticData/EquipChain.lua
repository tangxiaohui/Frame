require "StaticData.Manager"

EquipChainData = Class(LuaObject)

function EquipChainData:Ctor(id)
    local EquipChainMgr = Data.EquipChain.Manager.Instance()
    self.data = EquipChainMgr:GetObject(id)
    if self.data == nil then
        error(string.format("宝石连锁信息不存在，ID: %s 不存在", id))
        return
    end
end

function EquipChainData:GetId()
    return self.data.color
end

function EquipChainData:GetAddPropID()
    return self.data.addPropID
end

function EquipChainData:GetAddPropValue()
	return self.data.addPropValue
end

EquipChainManager = Class(DataManager)

local EquipChainDataMgr = EquipChainManager.New(EquipChainData)
return EquipChainDataMgr