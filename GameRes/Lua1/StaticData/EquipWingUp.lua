require "StaticData.Manager"

EquipWingUpData = Class(LuaObject)

function EquipWingUpData:Ctor(id)
    local EquipWingUpMgr = Data.EquipWingUp.Manager.Instance()
    self.data = EquipWingUpMgr:GetObject(id)
    if self.data == nil then
        error(string.format("翅膀进阶信息不存在，ID: %s 不存在", id))
        return
    end
end

function EquipWingUpData:GetId()
    return self.data.id
end

function EquipWingUpData:GetItemId()
    return self.data.itemId
end

function EquipWingUpData:GetColor()
    return self.data.color
end

function EquipWingUpData:GetAfterColor()
    return self.data.afterColor
end

function EquipWingUpData:GetLevelLimit()
    return self.data.levelLimit
end

function EquipWingUpData:GetAddField()
    return self.data.addField
end

function EquipWingUpData:GetAddValue()
    return self.data.addValue
end

function EquipWingUpData:GetNeedNum()
    return self.data.needNum
end

function EquipWingUpData:GetNeedSuipianID()
    return self.data.needSuipianID
end

function EquipWingUpData:GetNeedCoin()
    return self.data.needCoin
end

EquipWingUpManager = Class(DataManager)

local EquipWingUpDataMgr = EquipWingUpManager.New(EquipWingUpData)
return EquipWingUpDataMgr