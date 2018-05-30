--
-- User: fenghao
-- Date: 6/5/17
-- Time: 8:26 PM
--

require "Object.LuaObject"
local utility = require "Utils.Utility"

BattleParameter = Class(LuaObject)

function BattleParameter:Ctor()
    self.rightTeam = nil
    self.leftTeams = nil
    self.starter = nil
end

function BattleParameter:SetRightTeam(teamParameter)
    self.rightTeam = teamParameter
end

function BattleParameter:GetRightTeam()
    return self.rightTeam
end

function BattleParameter:SetLeftTeams(teamParameters)
    self.leftTeams = teamParameters
end

function BattleParameter:NumberOfLeftTeam()
    return #self.leftTeams
end

function BattleParameter:GetLeftTeam(pos)
    return self.leftTeams[pos]
end

function BattleParameter:SetStarter(starter)
    self.starter = starter
end

function BattleParameter:GetStarter()
    return self.starter
end

function BattleParameter:Verify()
    utility.ASSERT(self.leftTeams ~= nil, "敌人队伍为空!")
    utility.ASSERT(self.rightTeam ~= nil, "己方队伍为空!")
end


-- msg = leftWaves
local function CopyLeftTeamsToProtobuf(self, msg)
    local teamCount = self:NumberOfLeftTeam()
    for i = 1, teamCount do
        local pb = msg:add()
        self:GetLeftTeam(i):CopyToProtobuf(pb)
    end
end

-- msg = rightCards
local function CopyRightTeamToProtobuf(self, msg)
    local rightTeam = self:GetRightTeam()
    rightTeam:CopyToProtobuf(msg)
end

-- msg = FightingProcessData
function BattleParameter:CopyToProtobuf(msg)
    -- 左边队伍 msg.leftWaves
    CopyLeftTeamsToProtobuf(self, msg.leftWaves)

    -- 右边队伍 msg.rightCards
    CopyRightTeamToProtobuf(self, msg.rightCards)
end
