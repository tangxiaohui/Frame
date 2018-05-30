require "Game.BaseGame" -- 基类

local ServerService = require "Network.ServerService"

local GamePhase = require "Game.GamePhase"

local Cos3DGame = Class(BaseGame)

require "Const"

function Cos3DGame:Ctor()
    require "Game.GameServer"
    self.gameServer = GameServer.New(self)

    self.prevGamePhase = GamePhase.None
    self.currentGamePhase = GamePhase.None
end

function Cos3DGame:Start()
    Cos3DGame.base.Start(self)
    self.gameServer:Start()
end

function Cos3DGame:Close()
    self.gameServer:Close()
    Cos3DGame.base.Close(self)
end

function Cos3DGame:GetGameServer()
    return self.gameServer
end

-----------------------------------------------------------------------
--- 场景阶段相关
-----------------------------------------------------------------------
function Cos3DGame:GetCurrentPhase()
    return self.currentGamePhase
end

function Cos3DGame:GetPreviousPhase()
    return self.prevGamePhase
end

local function SetGamePhase(self, phase)
    if self.currentGamePhase ~= phase then

        -- debug_print("@@@ Set Phase", phase)

        self.prevGamePhase = self.currentGamePhase
        self.currentGamePhase = phase

        local messageGuids = require "Framework.Business.MessageGuids"
        if self.currentGamePhase == GamePhase.Lobby then
            -- 进入大厅 --
            self:DispatchEvent(messageGuids.EnterLobbyScene, nil, phase)
        elseif self.prevGamePhase == GamePhase.Lobby then
            -- 离开大厅
            self:DispatchEvent(messageGuids.ExitLobbyScene, nil, phase)
        end
    end
end

function Cos3DGame:SetGamePhase(phase)
    SetGamePhase(self, phase)
end

-----------------------------------------------------------------------
--- 子类继承的
-----------------------------------------------------------------------
function Cos3DGame:InitCustomSystems()
    local SDKManagerClass = require "Framework.Subsystems.SDK.SDKManager"
    self:AddSubsystem(SDKManagerClass.New())

    local NetworkClass = require "Network.Network"
    self:AddSubsystem(NetworkClass.New())

    local PoolManagerClass = require "Framework.Subsystems.PoolManager"
    self:AddSubsystem(PoolManagerClass.New())

    local WindowManagerClass = require "Framework.Window.WindowManager"
    self:AddSubsystem(WindowManagerClass.New())

    local PersistentWindowManagerClass = require "Framework.Window.PersistentWindowManager"
    self:AddSubsystem(PersistentWindowManagerClass.New())

    local TimeManagerClass = require "Framework.Subsystems.TimeManager"
    self:AddSubsystem(TimeManagerClass.New())

    local GuideManagerClass = require "Framework.Subsystems.GuideManager"
    self:AddSubsystem(GuideManagerClass.New())
    --系统引导
    local SystemGuideManagerClass = require "Framework.Subsystems.SystemGuideManager"
    self:AddSubsystem(SystemGuideManagerClass.New())
end

function Cos3DGame:GetNetworkManager()
    local subsystemGUID = require "Framework.SubsystemGUID"
    return self:GetSubsystem(subsystemGUID.Network)
end

function Cos3DGame:GetPoolManager()
    local subsystemGUID = require "Framework.SubsystemGUID"
    return self:GetSubsystem(subsystemGUID.PoolManager)
end

function Cos3DGame:GetTimeManager()
    local subsystemGUID = require "Framework.SubsystemGUID"
    return self:GetSubsystem(subsystemGUID.TimeManager)
end

function Cos3DGame:GetWindowManager()
    local subsystemGUID = require "Framework.SubsystemGUID"
    return self:GetSubsystem(subsystemGUID.WindowManager)
end

function Cos3DGame:GetPersistentWindowManager()
    local subsystemGUID = require "Framework.SubsystemGUID"
    return self:GetSubsystem(subsystemGUID.PersistentWindowManager)
end
--系统引导
function Cos3DGame:GetSystemGuideManager()
    local subsystemGUID = require "Framework.SubsystemGUID"
    return self:GetSubsystem(subsystemGUID.SystemGuideManager)
end


function Cos3DGame:GetGuideManager()
    local subsystemGUID = require "Framework.SubsystemGUID"
    return self:GetSubsystem(subsystemGUID.GuideManager)
end

function Cos3DGame:GetSDKManager()
    local subsystemGUID = require "Framework.SubsystemGUID"
    return self:GetSubsystem(subsystemGUID.SDKManager)
end

------------------------------------------------------------------------
-- 判断/获取 函数 --
------------------------------------------------------------------------
function Cos3DGame:IsChannelConnected()
    return self.gameServer:IsValidChannelInfo()
end

function Cos3DGame:IsServerConnected()
    return self.gameServer:IsServerConnected()
end

function Cos3DGame:IsTheState(state)
    return self.gameServer:IsTheState(state)
end

function Cos3DGame:IsWaitingForConnect()
    return self.gameServer:IsWaitingForConnect()
end

function Cos3DGame:IsSDKConnected()
    return self.gameServer:IsValidSDKSessions()
end

function Cos3DGame:GetAllServers()
    return self.gameServer:GetAllServers()
end

function Cos3DGame:GetRoleServers()
    return self.gameServer:GetRoleServers()
end

function Cos3DGame:GetAllRecentServers()
    return self.gameServer:GetAllRecentServers()
end

function Cos3DGame:GetCurrentServerId()
    return (self.gameServer:GetCurrentServerReadonly())
end

---- 当前渠道是否连接到了!
--function Cos3DGame:IsChannelConnected()
--    return self.gameServer:IsChannelConnected()
--end
--
---- 网络是否已连接
--function Cos3DGame:IsServerConnected()
--    return self:GetNetworkManager():IsConnected()
--end
--
---- 获取所有服务器
--function Cos3DGame:GetAllServers()
--    return self.gameServer:GetAllServers()
--end
--
----获取角色列表
--function Cos3DGame:GetRoleServers()
--    return self.gameServer:GetRoleServers()
--end
--
--function Cos3DGame:GetAllRecentServers()
--    return self.gameServer:GetAllRecentServers()
--end
--
---- 设置初始选择的服务器
--function Cos3DGame:SetDefaultActivatedServer()
--    return self.gameServer:SelectDefaultServer()
--end
--
--function Cos3DGame:SetCurrentServer(info)
--    self.gameServer:SetCurrentServer(info:GetId())
--end
--
--function Cos3DGame:UpdateRecentServer()
--    self.gameServer:UpdateRecentServer()
--end

-----------------------------------------------------------------------
--- 渠道登录
-----------------------------------------------------------------------
function Cos3DGame:StartChannelLogin()
    self.gameServer:Next()
end

function Cos3DGame:StartLogout()
    self.gameServer:Logout()
end

function Cos3DGame:Connect()
    self.gameServer:Connect()
end


--function Cos3DGame:RequestLoginSDK(callback)
--    self.gameServer:RequestLoginSDK(callback)
--end
--
--function Cos3DGame:RequestServerList(successFunc, failedFunc)
--    self.gameServer:RequestAllServers(successFunc, failedFunc)
--end
--
--function Cos3DGame:RequestRoleServerList(successFunc, failedFunc)
--    self.gameServer:RequestRoleServers(successFunc, failedFunc)
--end
--
--function Cos3DGame:ChannelLogin(successFunc, failedFunc)
--    self.gameServer:RequestChannelLogin(successFunc, failedFunc)
--end

-----------------------------------------------------------------------
--- 服务器登录
-----------------------------------------------------------------------



-----------------------------------------------------------------------
--- 网络相关
-----------------------------------------------------------------------
function Cos3DGame:RegisterMsgHandler(prototype, handler, func)
    self:GetNetworkManager():RegisterMsgHandler(prototype, handler, func)
end

function Cos3DGame:UnRegisterMsgHandler(prototype, handler, func)
    self:GetNetworkManager():UnRegisterMsgHandler(prototype, handler, func)
end

function Cos3DGame:SendNetworkMessage(msg, prototype)
    self:GetNetworkManager():SendMsg(msg, prototype)
end

-----------------------------------------------------------------------
--- 服务器连接状态
-----------------------------------------------------------------------
local function IsLoginPhase(self)
    local phase = self:GetCurrentPhase()
    return phase == GamePhase.None or phase == GamePhase.Login
end

local function OnConfirmReconnect(self)
    --self:LoginServer()
end

local function OnCancelReconnect(self)
    print("<<<<<< OnCancelReconnect >>>>>>>")
    self:RunLoginScene()
end

local function ShowReconnectDialog(self)
    local utility = require "Utils.Utility"
    utility.ShowConfirmDialog("与服务器失去连接, 是否尝试重新连接?", self, OnConfirmReconnect, OnCancelReconnect)
end

local function OnHandleSessionStateChanged(self, code)
    local messageGuids = require "Framework.Business.MessageGuids"
    self:DispatchEvent(messageGuids.SessionStateChanged, nil, code)
end

function Cos3DGame:OnSessionStateChanged(code)
    self.gameServer:OnSessionStateChanged(code)
    OnHandleSessionStateChanged(self, code)
end

local function CloseSomthingElse(self)
    self:DispatchEvent("ClosePlayNotice")
end

-- 运行登录画面
function Cos3DGame:RunLoginScene()
    local sceneManager = self:GetSceneManager()
    local LoginScene = require "Scenes.LoginScene".New()
    sceneManager:ReplaceScene(LoginScene)
    sceneManager:ClearAllScenesExceptWorkingScenes()
    CloseSomthingElse(self)
end

-- 运行欢迎画面 (已不使用)
function Cos3DGame:RunSplashScene()
    local sceneManager = self:GetSceneManager()
    local SplashScene = require "Scenes.SplashScene".New()
    sceneManager:ReplaceScene(SplashScene)
    sceneManager:ClearAllScenesExceptWorkingScenes()
end

local instance = Cos3DGame.New()
return instance
