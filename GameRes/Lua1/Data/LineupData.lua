
-- 阵容

require "Object.LuaObject"
local utility = require "Utils.Utility"

LineupData = Class(LuaObject)

function LineupData:Ctor(type)
    self.type = type
    self.troop = {
        [1] = 0,
        [2] = 0,
        [3] = 0,
        [4] = 0,
        [5] = 0,
        [6] = 0
    }
end

function LineupData:GetType()
    return self.type
end

function LineupData:GetTroop()
    return self.troop
end

function LineupData:ValidCount()
    local sum = 0
    for i = 1, #self.troop do
        if utility.IsValidUid(self.troop[i]) then
            sum = sum + 1
        end
    end
    return sum
end

-- 阵容操作 随后添加
function LineupData:Set(pos, uid)
    if utility.IsValidUid(uid) then
        self.troop[pos] = uid
        return
    end
    error('无效uid')
end

function LineupData:Reset(pos, uid)
    local oldUid = self.troop[pos]
    if utility.IsValidUid(oldUid) and oldUid ~= uid then
        return
    end
    self.troop[pos] = 0
end

function LineupData:Clear()
    self.troop[1] = 0
    self.troop[2] = 0
    self.troop[3] = 0
    self.troop[4] = 0
    self.troop[5] = 0
    self.troop[6] = 0
end
