require "Collection.OrderedDictionary"

local AchievementStorageClass = require "Data.Achievement.AchievementStorageData"

PlayerAchievemenData = Class(LuaObject)

function PlayerAchievemenData:Ctor()
    self.AchievementStorageDict = OrderedDictionary.New()
end

function PlayerAchievemenData:SetAllData(datas) 

    local typeId = datas.head.sid
    local data = self.AchievementStorageDict:GetEntryByKey(typeId)

    if data == nil then
        data = AchievementStorageClass.New()
        data:SetAllData(datas.Chengjiu)
        self.AchievementStorageDict:Add(typeId, data)
    else
        for i = 1 ,#datas.Chengjiu do
            data:UpdateData(datas.Chengjiu[i])
        end
        data:Sort()
    end

end

function PlayerAchievemenData:UpdateData(typeId,data)
    local achievementdata = self.AchievementStorageDict:GetEntryByKey(typeId)
    achievementdata:UpdateData(data)
    achievementdata:Sort()
end


function PlayerAchievemenData:GetData(typeId)

    if self.AchievementStorageDict:Contains(typeId) then
        return self.AchievementStorageDict:GetEntryByKey(typeId)
    end

    return nil
end

function PlayerAchievemenData:Clear()
    self.AchievementStorageDict:Clear()
end