require "Const"
require "Collection.OrderedDictionary"

local EquipDebrisClass = require "Data.EquipBag.EquipDebrisData"

-- # 装备碎片背包 # --
----------------------------------------------------------------------
EquipDebrisBagData = Class(LuaObject)

function EquipDebrisBagData:Ctor()
    self.EquipDebrisBagDict = OrderedDictionary.New()
end


-----------------------------------------------------------------------
--- 根据不同业务 写的更新函数
-----------------------------------------------------------------------
function EquipDebrisBagData:SetAllData(items)
    self.EquipDebrisBagDict:Clear()
    for i = 1, #items do
        self:UpdateData(items[i])
    end
    self:Sort()
end

function EquipDebrisBagData:UpdateData(item)
 
    local id = item.equipSuipianID

    local equipUserData = self.EquipDebrisBagDict:GetEntryByKey(id)

    if equipUserData ~= nil then
        equipUserData:UpdateData(item)
    else
        equipUserData = EquipDebrisClass.New()
        equipUserData:UpdateData(item)
        self.EquipDebrisBagDict:Add(id, equipUserData)
    end
    self:Sort()
    
    return equipUserData
end

function EquipDebrisBagData:Remove(id)
    local equipUserData = self.EquipDebrisBagDict:GetEntryByKey(id)
    if equipUserData ~= nil then
        self.EquipDebrisBagDict:Remove(id)
        return equipUserData
    end

    return nil
end

function EquipDebrisBagData:Sort()
    -- 排序
    self.EquipDebrisBagDict:Sort(function(a, b)
        if a:GetNumber() == b:GetNumber() then
            return a:GetEquipSuipianID() > b:GetEquipSuipianID()
        else
            return a:GetNumber() > b:GetNumber()
        end
        
    end)
end

-----------------------------------------------------------------------
--- 获取函数
-----------------------------------------------------------------------
function EquipDebrisBagData:GetItemCountById(id)
    -- 获取碎片数量
    local count = 0

    local item = self:GetItem(id)

    if item == nil then
        count = 0
    else
        count = item:GetItem()
    end
    return count
end



function EquipDebrisBagData:GetItem(id)
    return self.EquipDebrisBagDict:GetEntryByKey(id)
end

function EquipDebrisBagData:Count()
    return self.EquipDebrisBagDict:Count()
end

function EquipDebrisBagData:GetDataByIndex(index)
    local data = self.EquipDebrisBagDict:GetEntryByIndex(index)
    return data
end

function EquipDebrisBagData:GetItemDict()
      return self.EquipDebrisBagDict
end