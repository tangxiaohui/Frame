require "StaticData.Manager"

TaskData = Class(LuaObject)
function TaskData:Ctor(id)
    local TaskMgr = Data.Task.Manager.Instance()
    self.data = TaskMgr:GetObject(id)  

    if self.data == nil then
        error(string.format("任务信息不存在，ID: %s 不存在", id))
        return
    end
    
     local TaskInfoMgr=Data.TaskInfo.Manager.Instance()
     
     self.Infodata=TaskInfoMgr:GetObject(self.data.info)
    
    if self.Infodata == nil then
         error(string.format("任务描述信息不存在，ID: %s 不存在", id))
    return
end
    
end


function TaskData:GetID()
    return self.data.id 
end

function TaskData:GetInfo()
    return self.data.info 
end

function TaskData:GetType()
    return self.data.type 
end

function TaskData:GetChain()
    return self.data.chain 
end

function TaskData:GetLast()
    return self.data.last 
end

function TaskData:GetNext()
    return self.data.next 
end

function TaskData:GetLimit()
    return self.data.limit 
end

function TaskData:GetStartTime()
    return self.data.startTime 
end

function TaskData:GetEndTime()
    return self.data.endTime 
end

function TaskData:GetItemID_1()
    return self.data.itemID_1
end

function TaskData:GetItemNum_1()
    return self.data.itemNum_1 
end

function TaskData:GetItemColor_1()
    return self.data.itemColor_1 
end

function TaskData:GetItemID_2()
    return self.data.itemID_2
end

function TaskData:GetItemNum_2()
    return self.data.itemNum_2 
end

function TaskData:GetItemColor_2()
    return self.data.itemColor_2 
end

function TaskData:GetName()
    return self.Infodata.name 
end

function TaskData:GetDescription()
    return self.Infodata.description
end


TaskDataManager = Class(DataManager)

local TaskDataMgr = TaskDataManager.New(TaskData)

function TaskDataMgr:GetKeys()
    return Data.Task.Manager.Instance():GetKeys()
end
return TaskDataMgr