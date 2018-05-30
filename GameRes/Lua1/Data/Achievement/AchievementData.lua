--require "Collection.OrderedDictionary"

local Sort_Max = 3
local Sort_Middle = 2
local Sort_Min = 1

require "Object.LuaObject"
AchievementData = Class(LuaObject)

function AchievementData:SetAllData(data)
    self.id = data.id
    self.key = data.key
    self.done = data.done
    self.state = data.state
end

function AchievementData:GetId()
    return self.id
end

function AchievementData:GetKey()
    return self.key
end

function AchievementData:GetDone()
    return self.done
end

function AchievementData:GetState()
    return self.state
end

function AchievementData:UpdateData(data)
    self.id = data.id
    self.key = data.key
    self.done = data.done
    self.state = data.state

    self:SetSortValue(self.state)
end

function AchievementData:SetSortValue(state)
    -- 设置排序
    if state == 0 then
        self.sortValue = Sort_Middle
    elseif state == 1 then
        self.sortValue = Sort_Max
    elseif state == 2 then
        self.sortValue = Sort_Min
    end
end

function AchievementData:GetSortValue()
    return self.sortValue
end

return AchievementData