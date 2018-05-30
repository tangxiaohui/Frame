require "StaticData.Manager"

ArenaMileStoneData = Class(LuaObject)

function ArenaMileStoneData:Ctor(id)
    local ArenaMileStoneMgr = Data.ArenaMileStone.Manager.Instance()
    self.data = ArenaMileStoneMgr:GetObject(id)
    if self.data == nil then
        error(string.format("竞技场里程碑信息不存在，ID: %s 不存在", id))
        return
    end

end

function ArenaMileStoneData:GetId()
    return self.data.id
end

function ArenaMileStoneData:GetWins()
    return self.data.Wins
end

function ArenaMileStoneData:GetItemID()
    return self.data.itemID
end

function ArenaMileStoneData:GetItemNum()
    return self.data.itemNum
end

function ArenaMileStoneData:GetItemColor()
    return self.data.itemColor
end


ArenaMileStoneManager = Class(DataManager)

local ArenaMileStoneDataMgr = ArenaMileStoneManager.New(ArenaMileStoneData)
return ArenaMileStoneDataMgr