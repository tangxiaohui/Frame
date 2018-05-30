require "StaticData.Manager"

RoleCrapData = Class(LuaObject)

function RoleCrapData:Ctor(id)
    local RoleCrapMgr = Data.RoleCrap.Manager.Instance()
    self.data = RoleCrapMgr:GetObject(id)
    if self.data == nil then
        error(string.format("角色碎片信息不存在，ID: %s 不存在", id))
        return
    end
end

function RoleCrapData:GetId()
    return self.data.id
end

function RoleCrapData:GetInfo()
    return self.data.info
end

function RoleCrapData:GetRoleId()
    return self.data.roleId
end

function RoleCrapData:GetIcon()
    return self.data.icon
end

   

RoleCrapManager = Class(DataManager)

local RoleCrapDataMgr = RoleCrapManager.New(RoleCrapData)
return RoleCrapDataMgr