
require "Framework.GameSubSystem"
require "Framework.NotificationCenter"

local EventManager = Class(GameSubSystem)

function EventManager:Ctor()
    self.internalNotificationCenter = NotificationCenter.New()
end

function EventManager:AddObserver(key, table, func, cipher)
    self.internalNotificationCenter:AddObserver(key, table, func, cipher)
end

function EventManager:RemoveObserver(key, table, func, cipher)
    self.internalNotificationCenter:RemoveObserver(key, table, func, cipher)
end

function EventManager:PostNotification(key, cipher, ...)
    self.internalNotificationCenter:PostNotification(key, cipher, ...)
end

function EventManager:PostNotificationReversely(key, cipher, ...)
    self.internalNotificationCenter:PostNotificationReversely(key, cipher, ...)
end

---------------------------------------------------------------------------
------- 实现 GameSubSystem 的接口
---------------------------------------------------------------------------
function EventManager:GetGuid()
    return require "Framework.SubsystemGUID".EventManager
end

function EventManager:Startup()
end

function EventManager:Shutdown()
end

function EventManager:Restart()
end

function EventManager:Update()
    -- empty
end

return EventManager