require "StaticData.Manager"

FactoryItemData = Class(LuaObject)

function FactoryItemData:Ctor(id)
    local FactoryItemMgr = Data.FactoryItem.Manager.Instance()
    self.data = FactoryItemMgr:GetObject(id)
    if self.data == nil then
        error(string.format("工厂数据不存在，ID: %s 不存在", id))
        return
    end
end

function FactoryItemData:GetId()
    return self.data.id
end

function FactoryItemData:GetInfo()
    return self.data.info
end

function FactoryItemData:GetIcon()
    return self.data.icon
end

function FactoryItemData:GetColor()
    return self.data.color
end

function FactoryItemData:GetType()
    return self.data.type
end

function FactoryItemData:GetRepairTime()
    return self.data.repairTime
end

function FactoryItemData:GetRobTime()
    return self.data.robTime
end

function FactoryItemData:GetNpcBoxProp()
    return self.data.npcBoxProp
end

function FactoryItemData:GetIconInRepair()
    return self.data.iconInRepair
end

function FactoryItemData:GetIconInOpen()
    return self.data.iconInOpen
end

function FactoryItemData:GetRobProp()
    return self.data.robProp
end


FactoryItemManager = Class(DataManager)

local FactoryItemDataMgr = FactoryItemManager.New(FactoryItemData)
return FactoryItemDataMgr