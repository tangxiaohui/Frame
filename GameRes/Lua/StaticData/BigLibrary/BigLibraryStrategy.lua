require "StaticData.Manager"

BigLibraryStrategyData = Class(LuaObject)
function BigLibraryStrategyData:Ctor(id)
    local BigLibraryStrategyMgr = Data.BigLibraryStrategy.Manager.Instance()
    self.data = BigLibraryStrategyMgr:GetObject(id)  

    if self.data == nil then
        error(string.format("大书库攻略信息不存在，ID: %s 不存在", id))
        return
    end

    local BigLibraryStrategyInfoMgr=Data.BigLibraryStrategyInfo.Manager.Instance()
    self.Infodata=BigLibraryStrategyInfoMgr:GetObject(self.data.info)
    
   if self.Infodata == nil then
        error(string.format("大书库攻略描述信息不存在，ID: %s 不存在", id))
        return
    end
    
end


function BigLibraryStrategyData:GetName()
    return self.Infodata.name
end 

function BigLibraryStrategyData:GetDesc()
    return self.Infodata.description
end 

function BigLibraryStrategyData:GetInfo()
    return self.data.info
end

function BigLibraryStrategyData:GetFather()
    return self.data.father
end

function BigLibraryStrategyData:GetSon()
    return self.data.son
end

function BigLibraryStrategyData:GetID()
    return self.data.id 
end




BigLibraryStrategyDataManager = Class(DataManager)

local BigLibraryStrategyDataMgr = BigLibraryStrategyDataManager.New(BigLibraryStrategyData)

function BigLibraryStrategyDataMgr:GetKeys()
    return Data.BigLibraryStrategy.Manager.Instance():GetKeys()
end
return BigLibraryStrategyDataMgr