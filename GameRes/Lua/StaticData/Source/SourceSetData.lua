require "StaticData.Manager"

SourceSetData = Class(LuaObject)
function SourceSetData:Ctor(id)
    local SourceSetMgr = Data.PropSourceSet.Manager.Instance()
    self.data = SourceSetMgr:GetObject(id)  

    if self.data == nil then
        error(string.format("来源库信息（附表）不存在，ID: %s 不存在", id))
        return
    end

   local SourceSetInfoMgr = Data.PropSourceSetInfo.Manager.Instance()
   self.infodata = SourceSetInfoMgr:GetObject(self.data.info)
    
   if self.infodata == nil then
        error(string.format("来源库信息（附表）描述信息不存在，ID: %s 不存在", id))
        return
    end
    
end

function SourceSetData:GetInfoDesc()
    return self.infodata.desc
end

function SourceSetData:GetInfo()
    return self.data.info
end

function SourceSetData:GetPropId()
    return self.data.propId
end

function SourceSetData:GetSourceId()
    return self.data.isourceId
end

function SourceSetData:GetSourceType()
    return self.data.sourceType
end

function SourceSetData:GetDungeonId()
    return self.data.dungeonId
end

SourceSetDataManager = Class(DataManager)

local SourceSetDataMgr = SourceSetDataManager.New(SourceSetData)
return SourceSetDataMgr