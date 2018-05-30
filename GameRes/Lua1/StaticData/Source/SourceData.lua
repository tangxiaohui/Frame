require "StaticData.Manager"

SourceData = Class(LuaObject)
function SourceData:Ctor(id)
    local SourceMgr = Data.PropSource.Manager.Instance()
    self.data = SourceMgr:GetObject(id)  

    if self.data == nil then
        error(string.format("来源信息不存在，ID: %s 不存在", id))
        return
    end

   --  local PropSourceSetMgr = Data.PropSourceSet.Manager.Instance()
   --  self.sourceSetData = PropSourceSetMgr:GetObject(self.data.info)
    
   -- if self.Infodata == nil then
   --      error(string.format("大书库描述信息不存在，ID: %s 不存在", id))
   --      return
   --  end
    
end

function SourceData:GetIndex()
    return self.data.Index
end

function SourceData:GetIndexNum()
    return self.data.IndexNum
end

function SourceData:GetID()
    return self.data.id 
end

SourceDataManager = Class(DataManager)

local SourceDataMgr = SourceDataManager.New(SourceData)
return SourceDataMgr