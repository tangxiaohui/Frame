require "StaticData.Manager"

BigLibraryInfoData = Class(LuaObject)
function BigLibraryInfoData:Ctor(id)
    local BigLibraryInfoMgr = Data.BigLibraryInfo.Manager.Instance()
   -- self.keys= BigLibraryStrategyInfoMgr:GetKeys()
    self.data = BigLibraryInfoMgr:GetObject(id)
    
    if self.data == nil then
        error(string.format("道具信息不存在，ID: %s 不存在", id))
        return
    end
    
end

function BigLibraryInfoData:GetName()
    return self.data.name
end


 function BigLibraryInfo:GetItemId()
    return self.data.id
 end



BigLibraryInfoDataManager = Class(DataManager)

local BigLibraryInfoDataMgr = BigLibraryInfoDataManager.New(BigLibraryInfoData)
return BigLibraryInfoDataMgr