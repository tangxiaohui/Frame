require "StaticData.Manager"

RoleInfoData = Class(LuaObject)

function RoleInfoData:Ctor(id)
    local RoleInfoMgr = Data.RoleInfo.Manager.Instance()
    self.data = RoleInfoMgr:GetObject(id)
    if self.data == nil then
        error(string.format("角色信息不存在，ID: %s 不存在", id))
        return
    end
end

function RoleInfoData:GetId()
    return self.data.id
end

function RoleInfoData:GetName()
    return self.data.name
end

function RoleInfoData:GetDesc()
    return self.data.desc
end

function RoleInfoData:GetPassiveSkillName()
	return self.data.passiveSkillName
end

function RoleInfoData:GetPassiveSkillDesc()
	return self.data.passiveSkillDesc
end

function RoleInfoData:GetActiveSkillName()
	return self.data.activeSkillName
end

function RoleInfoData:GetActiveSkillDesc()
	return self.data.activeSkillDesc
end

function RoleInfoData:GetMonolog()
	return self.data.monolog
end

function RoleInfoData:GetUniqueWeaponDesc()
	return self.data.UniqueWeaponDesc
end

function RoleInfoData:GetCardName()
    local StringUtility = require "Utils.StringUtility"
    local array = StringUtility.CreateArray(self.data.name)
    local cardName = ""
    for i = 1,#array do
        cardName = cardName..array[i].."\n"
    end
    return cardName
end

RoleInfoManager = Class(DataManager)

local RoleInfoManager = RoleInfoManager.New(RoleInfoData)
return RoleInfoManager