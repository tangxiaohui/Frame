require "StaticData.Manager"

TreeBuyTimesData = Class(LuaObject)
function TreeBuyTimesData:Ctor(id)
    local TreeBuyTimesMgr = Data.TreeBuyTimes.Manager.Instance()
    self.data = TreeBuyTimesMgr:GetObject(id)
    if self.data == nil then
        error(string.format("精灵树购买次数信息不存在，ID: %s 不存在", id))
        return
    end 
end

function TreeBuyTimesData:GetId()
    return self.data.id
end

function TreeBuyTimesData:GetCount()
    return self.data.count
end

function TreeBuyTimesData:GetCost()
    return self.data.cost
end

TreeBuyTimesManager = Class(DataManager)

local TreeBuyTimesDataMgr = TreeBuyTimesManager.New(TreeBuyTimesData)
return TreeBuyTimesDataMgr