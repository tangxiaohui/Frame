
local WindowManager = require "Framework.Window.WindowManager"

local PersistentWindowManager = Class(WindowManager)

function PersistentWindowManager:GetGuid()
    return require "Framework.SubsystemGUID".PersistentWindowManager
end

return PersistentWindowManager
