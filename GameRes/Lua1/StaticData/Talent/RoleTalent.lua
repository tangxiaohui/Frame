require "StaticData.Manager"

local RoleTalentData = Class(LuaObject)
function RoleTalentData:Ctor(id)
    local TalentDataMgr = Data.RoleTalent.Manager.Instance()
    -- 数据本身
    self.data = TalentDataMgr:GetObject(id)
    if self.data == nil then
        error(string.format("角色天赋数据不存在, ID: %s 不存在", id))
        return
    end
    -- 本地化
    self.infoData = require "StaticData.Talent.RoleTalentInfo":GetData(self.data.info)
end

function RoleTalentData:GetId()
    return self.data.id
end

function RoleTalentData:GetName()
    return self.infoData:GetTalentName()
end

function RoleTalentData:GetDesc()
    return self.infoData:GetTalentDes()
end

function RoleTalentData:GetResourceID()
    return self.data.resourceID
end

function RoleTalentData:GetTalentType()
    return self.data.talentType
end

function RoleTalentData:GetExtendID()
    return self.data.extendID
end

function RoleTalentData:GetImmunityID()
    return self.data.mianyiID
end

function RoleTalentData:GetAp()
    return self.data.gongjili
end

function RoleTalentData:GetApRate()
    return self.data.gongjili_prop
end

function RoleTalentData:GetHpLimit()
    return self.data.hpLimit
end

function RoleTalentData:GetHpLimitRate()
    return self.data.hpLimit_prop
end

function RoleTalentData:GetDp()
    return self.data.fangyu
end

function RoleTalentData:GetAngerNum()
    return self.data.angerNum
end

function RoleTalentData:GetCritRate()
    return self.data.baojiProp
end

function RoleTalentData:GetCritDamage()
    return self.data.baojiHurt
end

function RoleTalentData:GetAvoidRate()
    return self.data.shanbiProp
end

function RoleTalentData:GetVamRate()
    return self.data.xixueProp
end

function RoleTalentData:GetAttackDamage()
    return self.data.pugongHurt
end

function RoleTalentData:GetSkillDamage()
    return self.data.jigongHurt
end

function RoleTalentData:GetDecritRate()
    return self.data.kangbaoProp
end

function RoleTalentData:GetSpeed()
    return self.data.speed
end

function RoleTalentData:GetHitRate()
    return self.data.mingzhongProp
end


local RoleTalentDataManager = Class(DataManager)

local RoleTalentDataMgr = RoleTalentDataManager.New(RoleTalentData)
return RoleTalentDataMgr