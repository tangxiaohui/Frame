require "StaticData.Manager"

EquipStrengthenData = Class(LuaObject)

function EquipStrengthenData:Ctor(id)
    local EquipStrengthenMgr = Data.EquipStrengthen.Manager.Instance()
    self.data = EquipStrengthenMgr:GetObject(id)
    if self.data == nil then
        error(string.format("装备强化信息不存在，ID: %s 不存在", id))
        return
    end
end

function EquipStrengthenData:GetId()
    return self.data.level
end


function EquipStrengthenData:GetAttackNeedCoin()
    return self.data.needCoin
end

function EquipStrengthenData:GetADefeneNeedCoin()
    return self.data.needCoin2
end



EquipStrengthenManager = Class(DataManager)

local EquipStrengthenDataMgr = EquipStrengthenManager.New(EquipStrengthenData)
return EquipStrengthenDataMgr