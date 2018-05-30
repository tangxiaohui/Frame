
-- lua 使用 LuaDebug, luajit 使用 LuaDebugjit
-- local breakSocketHandle,debugXpCall = require("LuaDebug")("localhost",7003)
-- local timer = Timer.New(function() 
-- breakSocketHandle() end, 1, -1, false)
-- timer:Start();
-- print("HELLO WORLD!!")

local sandbox_print = print

print = function()
end

debug_print = print
-- debug_print = sandbox_print
hzj_print = sandbox_print

require "Const"
require "Network.Net"
require "Network.Network"
require "Network.MessageManager"

require "Object.LuaGameObject"
require "Object.LuaComponent"

require "Event.CameraPathEventHandler"
require "Event.CollisionEventHandler"
require "Event.BattleUnitEventHandler"

require "Utils.Probability"

require "Game.Global" 