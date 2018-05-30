--
-- User: fbmly
-- Date: 3/24/17
-- Time: 5:16 PM
--

require "Framework.GameSubSystem"
local game = require "Game.Cos3DGame"

local messageGuids = require "Framework.Business.MessageGuids"

local TimeManager = Class(GameSubSystem)

local PingInterval = 30   -- 发送心跳包的间隔

function TimeManager:Ctor()
    self.serverTimestamp = 0  -- 服务器时间
    self.pingCountdown = PingInterval   -- 当前的countdown
end

---------------------------------------------------------------------------
------- 获取接口
---------------------------------------------------------------------------
function TimeManager:GetServerTimestamp()
    return self.serverTimestamp
end

---------------------------------------------------------------------------
------- 接收服务器推送事件
---------------------------------------------------------------------------
local function UpdateServerTime(self, sysTime)
    self.serverTimestamp = sysTime
    game:DispatchEvent(messageGuids.ServerTimeUpdated, nil, self.serverTimestamp)
end

local function OnPingResponse(self, msg)
    UpdateServerTime(self, msg.sysTime)
end

local function OnLoginResponse(self, msg)
    UpdateServerTime(self, msg.sysTime)
end

---------------------------------------------------------------------------
------- 实现 GameSubSystem 的接口
---------------------------------------------------------------------------
function TimeManager:GetGuid()
    return require "Framework.SubsystemGUID".TimeManager
end

function TimeManager:Startup()
    self.pingCountdown = PingInterval
    local net = require "Network.Net"
    game:RegisterMsgHandler(net.S2CPingResult, self, OnPingResponse)
    game:RegisterMsgHandler(net.S2CLoginResult, self, OnLoginResponse)
end

function TimeManager:Shutdown()
    local net = require "Network.Net"
    game:UnRegisterMsgHandler(net.S2CPingResult, self, OnPingResponse)
    game:UnRegisterMsgHandler(net.S2CLoginResult, self, OnLoginResponse)
end

function TimeManager:Restart()
    self.pingCountdown = PingInterval
end

local function PingUpdate(self)
    if game:IsServerConnected() then
        self.pingCountdown = self.pingCountdown - UnityEngine.Time.unscaledDeltaTime
        if self.pingCountdown <= 0 then
            self.pingCountdown = PingInterval

            local ServerService = require "Network.ServerService"
            game:SendNetworkMessage(ServerService.Ping())
        end
    end
end

function TimeManager:Update()
    PingUpdate(self)
end

return TimeManager