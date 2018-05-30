require "StaticData.Manager"

TreeLevelUpData = Class(LuaObject)
function TreeLevelUpData:Ctor(id)
    local TreeLevelUpMgr = Data.TreeLevelUp.Manager.Instance()
    self.data = TreeLevelUpMgr:GetObject(id)
    if self.data == nil then
        error(string.format("精灵树升级信息不存在，ID: %s 不存在", id))
        return
    end
end

function TreeLevelUpData:GetId()
    return self.data.id
end

function TreeLevelUpData:GetNeedType()
    return self.data.needType
end

function TreeLevelUpData:GetNeedNum()
    return self.data.needNum
end

-- function TreeLevelUpData:GetPowerType()
--     return self.data.poweType
-- end

-- function TreeLevelUpData:GetPowerNum()
--     return self.data.powerNum
-- end

function TreeLevelUpData:GetReduceTime()
    return self.data.reduceTime
end

function TreeLevelUpData:GetPowerNum()
    self.powerNums = {}
    for i=0,self.data.powerNum.Count-1 do
        self.powerNums[#self.powerNums+1]=self.data.powerNum[i]
    end
    return self.powerNums
end

function TreeLevelUpData:GetPowerType()
    self.poweTypes = {}
    for i=0,self.data.poweType.Count-1 do
        self.poweTypes[#self.poweTypes+1]=self.data.poweType[i]
    end
    return self.poweTypes
end
-- 获取所有属性
function TreeLevelUpData:GetAllProperiesByLevel(propertySet)
    propertySet = propertySet or require "Game.Property.PropertySet".New()
    self:GetPowerType()
    self:GetPowerNum()
    local count = #self.poweTypes
    for i = 1, count do
        local powerType = self.poweTypes[i]
        local powerNum = self.powerNums[i]
        if powerType ~= nil then           
            propertySet:AddValue(powerType,powerNum)           
        end
    end
    return propertySet
end

TreeLevelUpManager = Class(DataManager)

local TreeLevelUpDataMgr = TreeLevelUpManager.New(TreeLevelUpData)
return TreeLevelUpDataMgr