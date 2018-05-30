require "StaticData.Manager"
require "Collection.OrderedDictionary"

PlayerPromote = Class(LuaObject)

function PlayerPromote:Ctor(id)
    local attrMgr = Data.PlayerPromote.Manager.Instance()
    self.data = attrMgr:GetObject(id)
    if self.data == nil then
        print(string.format("等级信息：，ID: %s 不存在", id))
        return
    end
end

function PlayerPromote:ToString()
    return "PlayerPromote"
end

function PlayerPromote:GetLevel()
    return self.data.level
end

function PlayerPromote:GetExp()
    return self.data.exp
end

function PlayerPromote:GetexpPerLevel()
    return self.data.expPerLevel
end


function PlayerPromote:GetOpenSystem01()
    return self.data.openSystem01
end

function PlayerPromote:GetOpenSystem02()
    return self.data.openSystem02
end

function PlayerPromote:GetOpenSystem03()
    return self.data.openSystem03
end

function PlayerPromote:GetOpenSystem04()
    return self.data.openSystem04
end

function PlayerPromote:GetWillOpenSystem()
    local dict = {}
    local system1 =  self:GetOpenSystem01()
    if system1~=0 then
        dict[#dict+1]=system1
    end

    local system2 =  self:GetOpenSystem02()
    if system2~=0 then
         dict[#dict+1]=system2
        end

    local system3 =  self:GetOpenSystem03()
    if system3~=0 then
        dict[#dict+1]=system3
        end
    local system4 =  self:GetOpenSystem04()
    if system4~=0 then
         dict[#dict+1]=system4
        end
    return dict

end


PlayerPromoteAttrRatioManager = Class(DataManager)

local PlayerLevelAttrRatioManager = PlayerPromoteAttrRatioManager.New(PlayerPromote)
return PlayerLevelAttrRatioManager