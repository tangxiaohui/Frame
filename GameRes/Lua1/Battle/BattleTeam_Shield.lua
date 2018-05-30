
require "Collection.OrderedDictionary"

local Shield = require "Battle.Shield"

local function OnShowShieldEffect(self, shield)
    shield:Show(self:GetCenter())
end
    
local function OnHideShieldEffect(self, shield)
    shield:Hide()
end

local function ClearBrokenShields(self)
    local count = self.shields:Count()
    for i = count, 1, -1 do
        local currentShield = self.shields:GetEntryByIndex(i)
        if currentShield:IsBroken() then
            self.shields:RemoveByIndex(i)
            OnHideShieldEffect(self, currentShield)
        end
    end
end

function BattleTeam:InitShield()
    self.shields = OrderedDictionary.New()
end

function BattleTeam:ClearShield()
    local count = self.shields:Count()
    for i = 1, count do
        local currentShield = self.shields:GetEntryByIndex(i)
        OnHideShieldEffect(self, currentShield)
    end
    self.shields:Clear()
end

function BattleTeam:GetShieldCount()
    return self.shields:Count()
end

function BattleTeam:GetLastShield()
    return self.shields:GetEntryByIndex(self:GetShieldCount())
end

function BattleTeam:OnCallShield(unit, id)
    local currentShield = self.shields:GetEntryByKey(id)
    if currentShield == nil then
        currentShield = Shield.New(id, self)
        self.shields:Add(id, currentShield)
        OnShowShieldEffect(self, currentShield)
    end
    currentShield:Append(unit)
end

function BattleTeam:NewShieldRound()
    ClearBrokenShields(self)
end

function BattleTeam:CheckShields()
    ClearBrokenShields(self)
end




