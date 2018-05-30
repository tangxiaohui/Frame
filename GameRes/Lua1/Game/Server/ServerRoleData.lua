
local ServerRoleData = Class()

function ServerRoleData:Ctor(role)
	self.id = role.serverID
	self.name = role.name
    self.date = role.date
end

-- 服务器ID
function ServerRoleData:GetId()
    return self.id
end

-- 名字
function ServerRoleData:GetName()
    return self.name
end

-- 日期(这什么鬼)
function ServerRoleData:GetDate()
    return self.date
end

return ServerRoleData
