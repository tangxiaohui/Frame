
local BattleWinConditionUtils = {}

-- 触发接口
local ConditionInterfaces = {}
-- "0.普通
-- 1.在n回合内消灭所有敌人
-- 2.指定位置角色存活
-- 3.己方剩余人数大于n人
-- 4.己方全员hp%高于n"

-- 0.普通
ConditionInterfaces[0] = function(battlefield, param)
	return true
end

-- 1.在n回合内消灭所有敌人
ConditionInterfaces[1] = function(battlefield, n)
	return battlefield:GetRoundNumber() <= n
end

-- 2.指定位置角色存活
ConditionInterfaces[2] = function(battlefield, pos)
	return true
	-- if pos >= 1 and pos <= 6 then
	-- 	local members = battlefield:GetRightTeam():GetMembers()
	-- 	return members[pos] ~= nil and members[pos]:IsAlive()
	-- elseif pos == 7 then
	-- 	-- 7为前排
	-- 	return battlefield:GetRightTeam():IsAnyFrontrowAlive()
	-- elseif pos == 8 then
	-- 	-- 8为后排
	-- 	return battlefield:GetRightTeam():IsAnyBackrowAlive()
	-- end
	-- return true
end

-- 3. 己方剩余人数大于n人
ConditionInterfaces[3] = function(battlefield, n)
	return battlefield:GetRightTeam():NumOfAlives() >= n
end

-- 4. 己方全员hp%高于n"
ConditionInterfaces[4] = function(battlefield, n)
	local members = battlefield:GetRightTeam():GetMembers()
	for k, v in pairs(members) do
		if v:GetHpRate() < n then
			return false
		end
	end
	return true
end

function BattleWinConditionUtils.IsTrue(battlefield, conditionId, param)
	local routine = ConditionInterfaces[conditionId]
	if type(routine) == "function" then
		return routine(battlefield, param)
	end
	return true
end

return BattleWinConditionUtils