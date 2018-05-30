require "StaticData.Manager"

PointFightMileStoneData = Class(LuaObject)
function PointFightMileStoneData:Ctor(id)

    local PointFightMileStoneMgr = Data.PointFightMileStone.Manager.Instance()

    self.data = PointFightMileStoneMgr:GetObject(id)
    if self.data == nil then
        error(string.format("里程碑信息不存在，ID: %s 不存在", id))
        return
    end
end

function PointFightMileStoneData:GetID()
    return self.data.id
end

function PointFightMileStoneData:GetWins()
    return self.data.Wins
end

function PointFightMileStoneData:GetItemID()
    return self.data.itemID
end

function PointFightMileStoneData:GetItemNum()
    return self.data.itemNum
end

function PointFightMileStoneData:GetItemColor()
    return self.data.itemColor
end




PointFightMileStoneManager = Class(DataManager)

local PointFightMileStoneDataMgr = PointFightMileStoneManager.New(PointFightMileStoneData)

function PointFightMileStoneDataMgr:GetKeys()
    return Data.PointFightMileStone.Manager.Instance():GetKeys()
end

return PointFightMileStoneDataMgr
