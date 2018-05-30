require "StaticData.Manager"
require "Collection.OrderedDictionary"

RoleSpineData = Class(LuaObject)
function RoleSpineData:Ctor(id)
    local RoleSpineMgr = Data.RoleSpine.Manager.Instance()
    self.data = RoleSpineMgr:GetObject(id)
    if self.data == nil then
        error(string.format("道具信息不存在，ID: %s 不存在", id))
        return
    end
end

function RoleSpineData:GetSpinePath()
    return self.data.SpinePath
end

function RoleSpineData:GetID()
    return self.data.id
end






RoleSpineManager = Class(DataManager)

local RoleSpineMgr = RoleSpineManager.New(RoleSpineData)
return RoleSpineMgr