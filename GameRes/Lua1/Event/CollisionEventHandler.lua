require "Event.EventHandler"

CollisionEventHandler = Class(EventHandler)

function CollisionEventHandler:ToString()
	return "CollisionEventHandler"
end

local collisionEventHandler = CollisionEventHandler.New()

local function OnCollisionDetected(handler, src, dst)
	if handler:GetGameObject() == src then
		handler:OnCollisionDetected(dst)
	end
end

function _G.BattleUnitOnCollisionDetected(src, dst)
	collisionEventHandler:Dispatch(OnCollisionDetected, src, dst)
end

function _G.ClearBattleUnitCollisionEventHandler()
	collisionEventHandler:Clear()
end

return collisionEventHandler