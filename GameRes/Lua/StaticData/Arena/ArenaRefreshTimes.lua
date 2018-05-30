require "StaticData.Manager"

ArenaTimesData = Class(LuaObject)

function ArenaTimesData:Ctor(id)
    local ArenaTimesMgr = Data.ArenaRefreshTimes.Manager.Instance()
    self.data = ArenaTimesMgr:GetObject(id)
    if self.data == nil then
        error(string.format("竞技场刷新次数，ID: %s 不存在", id))
        return
    end

end

function ArenaTimesData:GetId()
    return self.data.id
end

function ArenaTimesData:GetCost()
    return self.data.cost
end



ArenaTimesManager = Class(DataManager)

local ArenaTimesDataMgr = ArenaTimesManager.New(ArenaTimesData)


function ArenaTimesDataMgr:GetKeys()
	return Data.ArenaRefreshTimes.Manager.Instance():GetKeys()
end

return ArenaTimesDataMgr