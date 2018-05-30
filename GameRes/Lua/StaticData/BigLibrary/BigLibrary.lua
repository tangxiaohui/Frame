require "StaticData.Manager"

BigLibraryData = Class(LuaObject)
function BigLibraryData:Ctor(id)
    local BigLibraryMgr = Data.BigLibrary.Manager.Instance()
    self.data = BigLibraryMgr:GetObject(id)  

    if self.data == nil then
        error(string.format("大书库信息不存在，ID: %s 不存在", id))
        return
    end

    local BigLibraryInfoMgr=Data.BigLibraryInfo.Manager.Instance()
    self.Infodata=BigLibraryInfoMgr:GetObject(self.data.info)
    
   if self.Infodata == nil then
        error(string.format("大书库描述信息不存在，ID: %s 不存在", id))
        return
    end
    
end


function BigLibraryData:GetName()
    return self.Infodata.name
end 

function BigLibraryData:GetInfo()
    return self.data.info
end

function BigLibraryData:GetType()
    return self.data.type
end


function BigLibraryData:GetID()
    return self.data.id 
end

BigLibraryDataManager = Class(DataManager)

local BigLibraryDataMgr = BigLibraryDataManager.New(BigLibraryData)

function BigLibraryDataMgr:GetKeys()
    return Data.BigLibrary.Manager.Instance():GetKeys()
end
return BigLibraryDataMgr