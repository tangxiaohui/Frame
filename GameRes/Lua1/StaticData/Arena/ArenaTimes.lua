require "StaticData.Manager"

ArenaTimesData = Class(LuaObject)

function ArenaTimesData:Ctor(id)
    local ArenaTimesMgr = Data.ArenaTimes.Manager.Instance()
    self.data = ArenaTimesMgr:GetObject(id)
    if self.data == nil then
        error(string.format("竞技场时间信息不存在，ID: %s 不存在", id))
        return
    end

end

function ArenaTimesData:GetId()
    return self.data.id
end

function ArenaTimesData:GetCount()
    return self.data.count
end

function ArenaTimesData:GetCost()
    return self.data.cost
end

function ArenaTimesData:GetVipLimit()
    return self.data.vipLimit
end

function ArenaTimesData:GetCdTime()
    return self.data.cdTime
end

function ArenaTimesData:GetNeedDiamond()
    return self.info.needDiamond
end


ArenaTimesManager = Class(DataManager)

local ArenaTimesDataMgr = ArenaTimesManager.New(ArenaTimesData)
function ArenaTimesDataMgr:GetKeys()
    return Data.ArenaTimes.Manager.Instance():GetKeys()
end
return ArenaTimesDataMgr