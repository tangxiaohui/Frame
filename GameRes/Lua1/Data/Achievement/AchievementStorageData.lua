require "Const"
require "Collection.OrderedDictionary"

local AchievementClass = require "Data.Achievement.AchievementData"


----------------------------------------------------------------------
AchievementStorageData = Class(LuaObject)

function AchievementStorageData:Ctor()
    self.AchievementStorageDict = OrderedDictionary.New()
end


-----------------------------------------------------------------------
--- 根据不同业务 写的更新函数
-----------------------------------------------------------------------
function AchievementStorageData:SetAllData(items)
    self.AchievementStorageDict:Clear()
    for i = 1, #items do
        self:UpdateData(items[i])
    end
    self:Sort()
end

function AchievementStorageData:UpdateData(item)
 
    local id = item.id

    local Data = self.AchievementStorageDict:GetEntryByKey(id)

    if Data ~= nil then
        Data:UpdateData(item)
    else
        Data = AchievementClass.New()
        Data:UpdateData(item)
        self.AchievementStorageDict:Add(id, Data)
    end
    --self:Sort()
    
end

function AchievementStorageData:Remove(id)
    local Data = self.AchievementStorageDict:GetEntryByKey(id)
    if Data ~= nil then
        self.AchievementStorageDict:Remove(id)
        return Data
    end

    return nil
end

function AchievementStorageData:Sort()
    -- 排序
    self.AchievementStorageDict:Sort(function(a, b)
        if a:GetSortValue() == b:GetSortValue() then
            return a:GetId() < b:GetId()
        else
            return a:GetSortValue() > b:GetSortValue()
        end
        
    end)
end

-----------------------------------------------------------------------
--- 获取函数
-----------------------------------------------------------------------

function AchievementStorageData:GetItem(id)
    return self.AchievementStorageDict:GetEntryByKey(id)
end

function AchievementStorageData:Count()
    return self.AchievementStorageDict:Count()
end

function AchievementStorageData:GetDataByIndex(index)
    local data = self.AchievementStorageDict:GetEntryByIndex(index)
    return data
end

function AchievementStorageData:GetItemDict()
      return self.AchievementStorageDict
end


return AchievementStorageData