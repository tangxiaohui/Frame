--
-- User: fbmly
-- Date: 5/7/17
-- Time: 2:16 PM
--

require "Class"

BattleTargetInfo = Class()

function BattleTargetInfo:Ctor(targets, targetType, param)
    self.targets = targets
    self.targetType = targetType
    self.param = param
end

function BattleTargetInfo:ToString()
    print("BattleTargetInfo")
end

-- {BattleUnit}
function BattleTargetInfo:GetTargets()
    return self.targets
end

function BattleTargetInfo:GetTargetType()
    return self.targetType
end

function BattleTargetInfo:GetTargetParam()
    return self.param
end

function BattleTargetInfo:CompareTargetType(targetType)
    return self.targetType == targetType
end

function BattleTargetInfo:GetGameObjects()
    local gameObjects = {}
    for i = 1, #self.targets do
        gameObjects[#gameObjects + 1] = self.targets[i]:GetGameObject()
    end
    return gameObjects
end

function BattleTargetInfo:GetTarget(pos)
    return self.targets[pos]
end

function BattleTargetInfo:GetGameObject(pos)
    return self.targets[pos]:GetGameObject()
end

function BattleTargetInfo:Count()
    return #self.targets
end