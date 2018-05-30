
require "StaticData.Manager"

local FoeTeamData = Class(LuaObject)

function FoeTeamData:Ctor(id)
    local foeTeamMgr = Data.FoeTeam.Manager.Instance()
    self.data = foeTeamMgr:GetObject(id)
    if self.data == nil then
        error(string.format("敌人队伍，ID: %s 不存在", id))
    end
end

function FoeTeamData:GetId()
    return self.data.id
end

-- 01

function FoeTeamData:GetFoeID01()
    return self.data.foeID01
end

function FoeTeamData:GetFoeAbility01()
    return self.data.foeAbility01
end

function FoeTeamData:GetFoeColor01()
    return self.data.foeColor01
end

function FoeTeamData:GetFoeLevel01()
    return self.data.foeLevel01
end

function FoeTeamData:GetFoeScaleRate01()
	return self.data.foeScaleRate01
end

-- 02

function FoeTeamData:GetFoeID02()
    return self.data.foeID02
end

function FoeTeamData:GetFoeAbility02()
    return self.data.foeAbility02
end

function FoeTeamData:GetFoeColor02()
    return self.data.foeColor02
end

function FoeTeamData:GetFoeLevel02()
    return self.data.foeLevel02
end

function FoeTeamData:GetFoeScaleRate02()
	return self.data.foeScaleRate02
end

-- 03

function FoeTeamData:GetFoeID03()
    return self.data.foeID03
end

function FoeTeamData:GetFoeAbility03()
    return self.data.foeAbility03
end

function FoeTeamData:GetFoeColor03()
    return self.data.foeColor03
end

function FoeTeamData:GetFoeLevel03()
    return self.data.foeLevel03
end

function FoeTeamData:GetFoeScaleRate03()
	return self.data.foeScaleRate03
end

-- 04

function FoeTeamData:GetFoeID04()
    return self.data.foeID04
end

function FoeTeamData:GetFoeAbility04()
    return self.data.foeAbility04
end

function FoeTeamData:GetFoeColor04()
    return self.data.foeColor04
end

function FoeTeamData:GetFoeLevel04()
    return self.data.foeLevel04
end

function FoeTeamData:GetFoeScaleRate04()
	return self.data.foeScaleRate04
end

-- 05

function FoeTeamData:GetFoeID05()
    return self.data.foeID05
end

function FoeTeamData:GetFoeAbility05()
    return self.data.foeAbility05
end

function FoeTeamData:GetFoeColor05()
    return self.data.foeColor05
end

function FoeTeamData:GetFoeLevel05()
    return self.data.foeLevel05
end

function FoeTeamData:GetFoeScaleRate05()
	return self.data.foeScaleRate05
end

-- 06

function FoeTeamData:GetFoeID06()
    return self.data.foeID06
end

function FoeTeamData:GetFoeAbility06()
    return self.data.foeAbility06
end

function FoeTeamData:GetFoeColor06()
    return self.data.foeColor06
end

function FoeTeamData:GetFoeLevel06()
    return self.data.foeLevel06
end

function FoeTeamData:GetFoeScaleRate06()
	return self.data.foeScaleRate06
end


local foeTeamManagerClass = Class(DataManager)
return foeTeamManagerClass.New(FoeTeamData)