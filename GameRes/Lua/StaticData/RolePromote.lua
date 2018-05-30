require "StaticData.Manager"

RolePromoteData = Class(LuaObject)

function RolePromoteData:Ctor(id)
    local RolePromoteMgr = Data.RolePromote.Manager.Instance()
    self.data = RolePromoteMgr:GetObject(id)
    if self.data == nil then
        error(string.format("��Ϣ�����ڣ�ID: %s ������", id))
        return
    end
end

function RolePromoteData:GetLevel()
    return self.data.level
end

function RolePromoteData:GetExp()
    return self.data.exp
end

function RolePromoteData:GetExpLevel()
    return self.data.expPerLevel
end

RolePromoteManager = Class(DataManager)

local RolePromoteDataMgr = RolePromoteManager.New(RolePromoteData)
return RolePromoteDataMgr