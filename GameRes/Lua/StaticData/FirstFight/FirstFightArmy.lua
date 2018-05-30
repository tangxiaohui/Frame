
require "StaticData.Manager"

local FirstFightArmyData = Class(LuaObject)

function FirstFightArmyData:Ctor(id)
    local firstFightMgr = Data.FirstFightArmy.Manager.Instance()
    self.data = firstFightMgr:GetObject(id)
    if self.data == nil then
        error(string.format("第一场战斗队伍，ID: %s 不存在", id))
    end
end

-- ID
function FirstFightArmyData:GetId()
    return self.data.id
end

-- 01
function FirstFightArmyData:GetArmyID01()
    return self.data.armyID01
end

function FirstFightArmyData:GetArmyAbility01()
    return self.data.armyAbility01
end

function FirstFightArmyData:GetArmyColor01()
    return self.data.armyColor01
end

function FirstFightArmyData:GetArmyLevel01()
    return self.data.armyLevel01
end

-- 02
function FirstFightArmyData:GetArmyID02()
    return self.data.armyID02
end

function FirstFightArmyData:GetArmyAbility02()
    return self.data.armyAbility02
end

function FirstFightArmyData:GetArmyColor02()
    return self.data.armyColor02
end

function FirstFightArmyData:GetArmyLevel02()
    return self.data.armyLevel02
end

-- 03
function FirstFightArmyData:GetArmyID03()
    return self.data.armyID03
end

function FirstFightArmyData:GetArmyAbility03()
    return self.data.armyAbility03
end

function FirstFightArmyData:GetArmyColor03()
    return self.data.armyColor03
end

function FirstFightArmyData:GetArmyLevel03()
    return self.data.armyLevel03
end

-- 04
function FirstFightArmyData:GetArmyID04()
    return self.data.armyID04
end

function FirstFightArmyData:GetArmyAbility04()
    return self.data.armyAbility04
end

function FirstFightArmyData:GetArmyColor04()
    return self.data.armyColor04
end

function FirstFightArmyData:GetArmyLevel04()
    return self.data.armyLevel04
end

-- 05
function FirstFightArmyData:GetArmyID05()
    return self.data.armyID05
end

function FirstFightArmyData:GetArmyAbility05()
    return self.data.armyAbility05
end

function FirstFightArmyData:GetArmyColor05()
    return self.data.armyColor05
end

function FirstFightArmyData:GetArmyLevel05()
    return self.data.armyLevel05
end

-- 06
function FirstFightArmyData:GetArmyID06()
    return self.data.armyID06
end

function FirstFightArmyData:GetArmyAbility06()
    return self.data.armyAbility06
end

function FirstFightArmyData:GetArmyColor06()
    return self.data.armyColor06
end

function FirstFightArmyData:GetArmyLevel06()
    return self.data.armyLevel06
end



local FirstFightArmyDataManager = Class(DataManager)
return FirstFightArmyDataManager.New(FirstFightArmyData)
