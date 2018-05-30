require "StaticData.Manager"

BigLibraryStrategyInfoData = Class(LuaObject)
function BigLibraryStrategyInfoData:Ctor(id)
    local BigLibraryStrategyInfoMgr = Data.BigLibraryStrategyInfo.Manager.Instance()
    self.data = BigLibraryStrategyInfoMgr:GetObject(id)

    local  
    
    if self.data == nil then
        error(string.format("道具信息不存在，ID: %s 不存在", id))
        return
    end
    
end

function BigLibraryStrategyInfoData:GetName()
    return self.data.name
end

function BigLibraryStrategyInfoData:GetDescription()
    return self.data.description
end

-- function BigLibraryStrategyInfoData:GetAllKeys()
--     return self.keys
-- end

 -- function BigLibraryStrategyInfo:GetItemId()
 --    return self.data.id
 -- end
-- function BigLibraryStrategyInfoData:GetItemNum()
--     return self.data.itemNum
-- end

-- function BigLibraryStrategyInfoData:GetBaseMinute()
--     return self.data.minute
-- end



BigLibraryStrategyInfoDataManager = Class(DataManager)

local BigLibraryStrategyInfoDataMgr = BigLibraryStrategyInfoDataManager.New(BigLibraryStrategyInfoData)
return BigLibraryStrategyInfoDataMgr