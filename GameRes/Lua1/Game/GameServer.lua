
require "Object.LuaObject"
local utility = require "Utils.Utility"
require "Const"
require "Collection.OrderedDictionary"
local ServerService = require "Network.ServerService"
local messageGuids = require "Framework.Business.MessageGuids"
local utility = require "Utils.Utility"

local IPAddress = _G.Constant.LoginInfo.loginIp;
local LoginServerPort = _G.Constant.LoginInfo.loginPort
local GMPort = 11100

local USE_CUSTOM_SERVERS = false

local __CustomUserNameSuffix__ = "nil1"

--- >>>>>>>> 服务器公告
local ServerNoticeInfo = Class()
function ServerNoticeInfo:Ctor(jsonData)
    self.title = jsonData.title
    self.content = jsonData.content
end

function ServerNoticeInfo:GetTitle()
    return self.title
end

function ServerNoticeInfo:GetContent()
    return self.content
end

--- >>>>>>>> 服务器信息
local ServerInfo = Class(LuaObject)

function ServerInfo:Ctor(jsonData)
    self.id = jsonData.id
    self.ip = jsonData.ip
    self.port = jsonData.port
    self.name = jsonData.name
    self.is_inner = jsonData.is_inner
    self.limit = jsonData.limit
    self.serverState = jsonData.ServerState
    self.isNew = jsonData.IsNew
    self.is_recommendation = jsonData.Isrecommended
    self.platform = jsonData.plat
    self.content = jsonData.content -- 维护展现内容 --
end

function ServerInfo:ToString()
    local str = string.format(
        "id = %d, ip = %s, port = %d, name = %s, inner = %d, limit = %d, serverState = %d, isNew = %d, isrecommended = %d, platform = %s, content = %s",
        self.id,
        self.ip,
        self.port,
        self.name,
        self.is_inner,
        self.limit,
        self.serverState,
        self.isNew,
        self.is_recommendation,
        self.platform,
        self.content
    )
    return str
end

-- 服务器id --
function ServerInfo:GetId()
    return self.id
end

-- ip --
function ServerInfo:GetIp()
    return self.ip
end

-- 端口 --
function ServerInfo:GetPort()
    return self.port
end

-- 服务器名字 --
function ServerInfo:GetName()
    return self.name
end

-- 是否为内网服 --
function ServerInfo:IsInner()
    return self.is_inner
end

-- 可视限制 --
function ServerInfo:GetLimit()
    return self.limit
end

-- 服务器状态 --
function ServerInfo:GetServerState()
    return self.serverState
end

-- 是否为新服 --
function ServerInfo:IsNew()
    return self.isNew
end

-- 是否推荐 --
function ServerInfo:IsRecommended()
    return self.is_recommendation
end

-- 平台 --
function ServerInfo:GetPlatform()
    return self.platform
end

-- 维护展现内容 --
function ServerInfo:GetContent()
    return self.content
end


--- >>>>>>>> 服务器角色信息
local ServerRoleInfo = Class(LuaObject)

function ServerRoleInfo:Ctor(role)
    self.id = role.serverID
    self.name = role.name
    self.date = role.date
end

function ServerRoleInfo:GetId()
    return self.id
end

function ServerRoleInfo:GetName()
    return self.name
end

function ServerRoleInfo:GetDate()
    return self.date
end

-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
local PlayerPrefs_RecentServer_Key = "295e03ca-320b-42b6-9f91-f2157a08c684"
local RecentServerLimits = 2


-- 整个游戏 登录状态的封装 --
GameServer = Class(LuaObject)

function GameServer:Ctor(game)
    -- 游戏类
    self.game = game

    -- 登录IP设置
    self.ip = IPAddress

    -- GM 控制台 --
    local GMConsoleClass = GMConsole
    if GMConsoleClass ~= nil then
        GMConsole = nil
        self.gmConsole = GMConsoleClass.New()
        -- self.gmConsole:SetIp("")
    end

    -- 公告信息
    self.noticeManifest = require "Game.Server.NoticeManifest".New()

    -- SDK Sessions
    self.sdkSessions = {}

    -- 渠道信息
    self.channelSessions = {}

    -- 服务器列表信息 --
    self.allServers = OrderedDictionary.New()

    -- 最近服务器ID列表 --
    self.recentServers = nil    
	
	-- 当前服务器 --
	self.currentServer = nil

    -- 角色信息 --
    self.allServerRoles = OrderedDictionary.New()


    -- 当前的Session状态
    self.sessionState = kSessionState_Default

    -- 状态管理
    self.previousState = kLoginState_None
    self.currentState = kLoginState_None
end

local function SetGmConsoleInfo(self)
    local currentServerInfo = self.currentServer
    if self.gmConsole ~= nil and currentServerInfo ~= nil and self.userName ~= nil and string.len(self.userName) > 0 then
        self.gmConsole:SetIp(currentServerInfo:GetIp())
        self.gmConsole:SetPort(GMPort)
        self.gmConsole:SetUserName(self.userName)
    end
end

local function ResetGmConsoleInfo(self)
	if self.gmConsole ~= nil then
        self.gmConsole:SetIp("")
        self.gmConsole:SetPort(0)
		self.gmConsole:SetUserName("")
	end
end

-- 通知状态改变 --
local function NotifyGameServerStateChanged(self, errorMessage)
    self.game:DispatchEvent(messageGuids.GameServerStateChangedNotify, nil, self, errorMessage)
end

-- 设置状态 --
local function SetState(self, newState)
    self.previousState = self.currentState
    self.currentState = newState
end

-- 获取当前的状态 --
local function GetCurrentState(self)
    return self.currentState
end

-- 获取前次的状态 --
local function GetPreviousState(self)
    return self.previousState
end

-- 设置当前的服务器公告
local function SetServerNotice(self, jsonData)
    self.noticeManifest:Set(jsonData["notices"])
end

local function ResetServerNotice(self)
    self.noticeManifest:Clear()
end

function GameServer:GetServerNoticeCount()
    return self.noticeManifest:Count()
end

function GameServer:GetServerNoticeByIndex(pos)
    return self.noticeManifest:GetNoticeByIndex(pos)
end

-- 设置当前SDK的信息 --
local function SetSDKSessions(self, platform, id, channelId, channelUserId, userName, token, productCode, deviceUID, deviceName, deviceModel)
    self.sdkSessions.platform = platform
    self.sdkSessions.id = id
    self.sdkSessions.channelId = channelId
    self.sdkSessions.channelUserId = channelUserId
    self.sdkSessions.userName = userName
    self.sdkSessions.token = token
    self.sdkSessions.productCode = productCode
    self.sdkSessions.deviceUID = deviceUID
    self.sdkSessions.deviceName = deviceName
    self.sdkSessions.deviceModel = deviceModel

    -- 设置用户名 --
    self.userName = channelUserId

    if type(__CustomUserNameSuffix__) == "string" then
		self.userName = self.userName .. __CustomUserNameSuffix__
    end
end

-- 重置当前SDK的信息 --
local function ResetSDKSessions(self)
    self.sdkSessions.platform = nil
    self.sdkSessions.id = nil
    self.sdkSessions.channelId = nil
    self.sdkSessions.channelUserId = nil
    self.sdkSessions.userName = nil
    self.sdkSessions.token = nil
    self.sdkSessions.productCode = nil
    self.sdkSessions.deviceUID = nil
    self.sdkSessions.deviceName = nil
    self.sdkSessions.deviceModel = nil

    self.userName = nil
end

local function GetSDKChannelID(self)
    return self.sdkSessions.channelId
end

function GameServer:GetChannelUserId()
    return self.sdkSessions.channelUserId
end

-- 设置渠道的信息 --
local function SetChannelSessions(self, signature, account, channel)
    self.channelSessions.signature = signature
    self.channelSessions.account = account
    self.channelSessions.channel = channel
end

-- 重置渠道的信息 --
local function ResetChannelSessions(self)
    self.channelSessions.signature = nil
    self.channelSessions.account = nil
    self.channelSessions.channel = nil
end

-- 设置服务器信息 --
local function SetServerInfo_Impl(self, serverInfo)
    if self.allServers:Contains(serverInfo:GetId()) then
        self.allServers:Remove(serverInfo:GetId())
    end
    self.allServers:Add(serverInfo:GetId(), serverInfo)
end

local function SetCustomServerInfo(self)
    if not USE_CUSTOM_SERVERS then
        return
    end
    SetServerInfo_Impl(self, ServerInfo.New{id = 1001, ip = IPAddress, port = 8000, name = "外网服务器"})
end

local function OnSortByServerId(server1, server2)
    return server1:GetId() < server2:GetId()
end

local function SetServerInfo(self, server_list)
    self.allServers:Clear()

    for _, v in pairs(server_list) do
        local newServerInfo = ServerInfo.New(v)
        self.allServers:Add(newServerInfo:GetId(), newServerInfo)
    end

    SetCustomServerInfo(self)

    self.allServers:Sort(OnSortByServerId)
end

-- 清除服务器信息 --
local function ResetServerInfo(self)
    self.allServers:Clear()
end

-- 设置服务器角色信息 --
local function SetServerRoleInfo(self, roleList)
    self.allServerRoles:Clear()

    for _, v in pairs(roleList) do
		if not self.allServerRoles:Contains(v.serverID) then
			local newRoleInfo = ServerRoleInfo.New(v)
			self.allServerRoles:Add(newRoleInfo:GetId(), newRoleInfo)
		end
    end
end

-- 清除服务器角色信息 --
local function ResetServerRoleInfo(self)
    self.allServerRoles:Clear()
end

-- 读取最近登录的服务器的ID --
local function LoadRecentServers()
    local content = UnityEngine.PlayerPrefs.GetString(PlayerPrefs_RecentServer_Key)
    
    local splitedServers = utility.Split(content)

    local loopCount = math.min(#splitedServers, RecentServerLimits)

    local recentServers = {}
    for i = 1, loopCount do
        recentServers[i] = tonumber(splitedServers[i])
    end

    return recentServers
end

local function IsServerIdValid(self, serverId)
    return self.allServers:Contains(serverId)
end

local function SaveRecentServers(servers)
    local content = table.concat(servers, ",")
    UnityEngine.PlayerPrefs.SetString(PlayerPrefs_RecentServer_Key, content)
    UnityEngine.PlayerPrefs.Save()
end

-- 读取最近一次的服务器 --
local function GetMostRecentlyServer(self)
    if self.recentServers == nil then
        return nil
    end

    for i = 1, #self.recentServers do
        if IsServerIdValid(self, self.recentServers[i]) then
            return self.allServers:GetEntryByKey(self.recentServers[i])
        end
    end

    return nil
end

-- 设置一个默认服务器 --
local function SetDefaultServer(self)
    if self.currentServer then
        return
    end

    local server

    -- 找一个最近登录过的 --
    server = GetMostRecentlyServer(self)
    if server ~= nil then
        self.currentServer = server
        return
    end

    -- 找第一个 --
    if self.allServers:Count() > 0 then
        self.currentServer = self.allServers:GetEntryByIndex(1)
        return
    end

    error("服务器列表数据为空!")
end

local function GetCurrentServer(self)
    return self.currentServer
end

-- 清除所选服务器 --
local function ResetDefaultServer(self)
    self.currentServer = nil
end

-- 连接管理
local function IsLoginPhase()
	local game = utility.GetGame()
	local GamePhase = require "Game.GamePhase"
    local phase = game:GetCurrentPhase()
    return phase == GamePhase.None or phase == GamePhase.Login
end

-- HTTP接口请求Json --
local function RequestJsonImpl(self, url, successCallback, failedCallback)

    debug_print("URL", url)

    local www = UnityEngine.WWW(url)
    coroutine.www(www)

    local error = www.error
    if error == nil or string.len(error) == 0 then
        -- 解析 json 数据 --
        local cjson = require "cjson.safe"
        local data = cjson.decode(www.text)

        if data ~= nil then
            if data.error == nil or data.error == 0 then
                successCallback(data)
            else
                failedCallback(data.msg)
            end
        else
            failedCallback("服务器数据加载失败!")
        end
    else
        failedCallback(string.format("网络失败, 原因: %s", www.error))
    end
end

local function IsChannelLogout(result)
    return result == "0"
end

local function IsChannelSuccess(result)
    return result == "1"
end

local function IsChannelUserIdChanged(self, channelUserId)
    return self.sdkSessions.channelUserId ~= nil and self.sdkSessions.channelUserId ~= channelUserId
end

local function IsSwitchingAccount(self, result, channelUserId)
    return (IsChannelLogout(result) or IsChannelSuccess(result)) and IsChannelUserIdChanged(self, channelUserId)
end


local function OnWaitingForLoginScene(onFinished)
	debug_print("OnWaitingForLoginScene >> 1")
    local game = utility.GetGame()
    local sceneManager = game:GetSceneManager()
    local currentScene = sceneManager:GetRunningScene()
    debug_print("OnWaitingForLoginScene >> 2")

    repeat
    	coroutine.step(1)
    until(not sceneManager:IsSwitching())

    debug_print("OnWaitingForLoginScene >> 3")

    repeat
        coroutine.step(1)
    until(currentScene:HasSelfComponentReady()) --note:这里不判断HasComponentReady 因为有些通用组件不需要邦定.

    coroutine.step(1)
    debug_print("OnWaitingForLoginScene >> 4")
    onFinished()
end

local function OnHandleSwitchingAccount(self, result, channelUserId, onFinished)
    if IsSwitchingAccount(self, result, channelUserId) then
        -- 开始切账号了, 当乐的时候为0 代表刚开始切换. 而百度和360则是已经登出并登入完毕了!
        -- 已经就说这一块我仅仅是要界面切走而已!
        if not IsLoginPhase() then
            debug_print("switch >>> 1")
            self.game:GetWindowManager():CloseAll(true)
            utility.JumpScene(function()
            	debug_print("switch JumpScene >> start")
                local game = utility.GetGame()
                local sceneManager = game:GetSceneManager()
                local LoginScene = require "Scenes.LoginScene".New(true)
                sceneManager:ReplaceScene(LoginScene)
                sceneManager:ClearAllScenesExceptWorkingScenes()
                game:GetNetworkManager():Close()

                sceneManager:Update()
                
                coroutine.start(OnWaitingForLoginScene, onFinished)
                debug_print("switch JumpScene >> end")
            end)
        else
            debug_print("switch >>> 3")
            onFinished()
        end
    else
        debug_print("switch >>> 4")
        onFinished()
    end
end

local function LoginYijieSDK(self, result, platform, id, channelId, channelUserId, userName, token, productCode, deviceUID, deviceName, deviceModel) 

    local sdkManager = self.game:GetSDKManager()

    -- debug_print("@@ 登录SDK", result, "<XXX>", platform, "<XXX>",id, "<XXX>",channelId, "<XXX>",channelUserId, "<XXX>",userName, "<XXX>",token, "<XXX>",productCode, "<XXX>",deviceUID, "<XXX>",deviceName, "<XXX>",deviceModel)

    OnHandleSwitchingAccount(self, result, channelUserId, function()

        if IsChannelSuccess(result) then
            debug_print("result >>> 1")
            -- 登录成功 --
            SetState(self, kLoginState_ChannelLogin)
            SetSDKSessions(self, platform, id, channelId, channelUserId, userName, token, productCode, deviceUID, deviceName, deviceModel)
            NotifyGameServerStateChanged(self)
        elseif not IsChannelLogout(result) then
            debug_print("result >>> 2")
    
            -- 登录失败 --
            SetState(self, kLoginState_Logout)
            ResetSDKSessions(self)
    
            NotifyGameServerStateChanged(self, "登录失败")
        end

    end)
end
-- 状态处理函数 --
local function OnStateNone(self)
    debug_print("OnStateNone >>> 1")
    local url = string.format(
        "http://%s:%d/loginserver/notice.do?platforms=%s&sdk_ids=%s",
        self.ip,
        LoginServerPort,
        self.game:GetSDKManager():GetPlatformId(),
        self.game:GetSDKManager():GetChannelId()
    )

    debug_print("@@@ OnStateNone url", url)

    ResetServerNotice(self)

    coroutine.start(
        RequestJsonImpl, 
        self, 
        url, 
        function(jsonData)
            SetServerNotice(self, jsonData)
            SetState(self, kLoginState_Notice)
            NotifyGameServerStateChanged(self)
        end,
        function(errorMsg)
            NotifyGameServerStateChanged(self, "获取公告失败")
        end
    )
end

local function OnStateNotice(self)
	debug_print("OnStateNotice >>> 1")

    -- 设置为登录状态 --
    SetState(self, kLoginState_Login)
    
    -- 应该要自动登录 --
    local sdkManager = self.game:GetSDKManager()
    sdkManager:Login(self,LoginYijieSDK)
end

local function OnStateLogin(self)
    debug_print("正在登录SDK...")
end
local function OnStateLogout(self)
    debug_print("@ prepare to logout!")
    local sdkManager = self.game:GetSDKManager()
    sdkManager:Logout(function(result, platform, id, channelId, channelUserId, userName, token, productCode, deviceUID, deviceName, deviceModel)
        debug_print("@ OnStateLogout", result, platform, id, channelId, channelUserId, userName, token, productCode, deviceUID, deviceName, deviceModel)

        OnHandleSwitchingAccount(self, result, channelUserId, function() 
                -- # 登录结果 # --
            if result == "1" then
                -- PC上的重登录
                SetState(self, kLoginState_ChannelLogin)
                SetSDKSessions(self, platform, id, channelId, channelUserId, userName, token, productCode, deviceUID, deviceName, deviceModel)

                NotifyGameServerStateChanged(self)
            else
                -- 手机(支付宝渠道的登出成功 )
                SetState(self, kLoginState_Notice)
                ResetSDKSessions(self)
                NotifyGameServerStateChanged(self)
            end
        end)

        
    end)
end

local function OnStateChannelLogin(self)
	debug_print("OnStateChannelLogin >>> 1")

    local url = string.format("http://%s:%d/loginserver/login.do?username=%s&app=%s&sdk=%s&uin=%s&sess=%s&platform=%s", self.ip, LoginServerPort, self.userName,self.sdkSessions.productCode,self.sdkSessions.channelId,self.sdkSessions.channelUserId,self.sdkSessions.token,self.sdkSessions.platform)

    -- debug_print("url", url)

    ResetChannelSessions(self)

    coroutine.start(RequestJsonImpl, self, url, function(jsonData)
        -- 登录 & 校验 成功!! --
        SetState(self, kLoginState_RequestServerList)
        SetChannelSessions(self, jsonData.sig, jsonData.account, jsonData.channel)

		local sdkManager = self.game:GetSDKManager()
		sdkManager:LoginScuess()
		
        NotifyGameServerStateChanged(self)

    end, function(errorMsg)
        --debug_print(errorMsg)
        -- 登录失败 --
        SetState(self, kLoginState_Logout)
        ResetSDKSessions(self)

        NotifyGameServerStateChanged(self, errorMsg)
    end)

end

local function OnStateRequestServerList(self)
	debug_print("OnStateRequestServerList >>> 1")

    local url = string.format("http://%s:%d/loginserver/server_list.json", self.ip, LoginServerPort)

    ResetServerInfo(self)
    ResetDefaultServer(self)

    coroutine.start(RequestJsonImpl, self, url, function(jsonData)
        SetServerInfo(self, jsonData.server_list)
        SetDefaultServer(self)
        SetState(self, kLoginState_RequestRoleList)

        NotifyGameServerStateChanged(self)
    end, function(errorMsg)
        -- 请求或解析失败 --
        NotifyGameServerStateChanged(self, errorMsg)
    end)

end

local function OnStateRequestRoleList(self)
	debug_print("OnStateRequestRoleList >>> 1")

    local url = string.format("http://%s:%d/loginserver/role.do?uid=%s", self.ip, LoginServerPort, self.userName)

    -- debug_print("url", url)

    ResetServerRoleInfo(self)

    coroutine.start(RequestJsonImpl, self, url, function(jsonData)
        SetServerRoleInfo(self, jsonData.rolelist)
        SetState(self, kLoginState_WaitingForConnect)

        NotifyGameServerStateChanged(self)

    end, function(errorMsg)
        -- 请求或解析失败 --
        NotifyGameServerStateChanged(self, errorMsg or "错误!")
    end)

end

local function OnStateWaitingForConnect(self)
    debug_print("等待连接...")
end

local function OnStateConnecting(self)
    debug_print("服务器正在连接...")
end

local function OnStateConnected(self)
    debug_print("服务器已经连接 不能重复连接")
end


local handleFunctions = {
    [kLoginState_None] = OnStateNone,
    [kLoginState_Notice] = OnStateNotice,
    [kLoginState_Login] = OnStateLogin,
    [kLoginState_Logout] = OnStateLogout,
    [kLoginState_ChannelLogin] = OnStateChannelLogin,
    [kLoginState_RequestServerList] = OnStateRequestServerList,
    [kLoginState_RequestRoleList] = OnStateRequestRoleList,
    [kLoginState_WaitingForConnect] = OnStateWaitingForConnect,
    [kLoginState_Connecting] = OnStateConnecting,
    [kLoginState_Connected] = OnStateConnected,
}

function GameServer:Next()
    local state = GetCurrentState(self)
    print("state:", state)

    local func = handleFunctions[state]

    if func then
        func(self)
    else
        error("不支持的状态: ", state)
    end
end

function GameServer:Logout()
    SetState(self, kLoginState_Logout)
    self:Next()
end

function GameServer:Connect()
    if self:IsWaitingForConnect() then
        local serverInfo = GetCurrentServer(self)
        if serverInfo ~= nil then
            if serverInfo:GetServerState() == kServerState_Maintain then
                error("TODO 不支持!")
            else
                self.game:GetNetworkManager():Connect(serverInfo:GetIp(), serverInfo:GetPort(), "", "")
            end
        end
    end
end

function GameServer:GetLoginIp()
    return IPAddress
end

function GameServer:GetLoginPort()
    return LoginServerPort
end

function GameServer:ServerCount()
    return self.allServers:Count()
end

function GameServer:GetCurrentServerReadonly()
    local server = GetCurrentServer(self)
    if server ~= nil then
        return server:GetId(), 
               server:GetIp(), 
               server:GetPort(), 
               server:GetName(),
               server:IsInner(),
               server:GetLimit(),
               server:GetServerState(),
               server:IsNew(),
               server:IsRecommended(),
               server:GetPlatform(),
               server:GetContent()
    end
    return nil
end

function GameServer:GetMaxAvailableServerCount()
    return self:ServerCount() + RecentServerLimits
end

function GameServer:GetAllRecentServers()
    return self.recentServers
end

function GameServer:IsServerIdValid(serverId)
    return IsServerIdValid(self, serverId)
end

-- function param1: serverInfo, param2: true if has role or false
function GameServer:ForeachServer(func)
    local count = self.allServers:Count()
    for i = 1, count do
        local serverInfo = self.allServers:GetEntryByIndex(i)
        if serverInfo ~= nil then
            func(serverInfo, self.allServerRoles:Contains(serverInfo:GetId()))
        end
    end
end

function GameServer:IsTheState(state)
    local currentState = GetCurrentState(self)
    return currentState == state
end

function GameServer:IsWaitingForConnect()
    local state = GetCurrentState(self)
    return state == kLoginState_WaitingForConnect
end

function GameServer:IsServerConnected()
    local state = GetCurrentState(self)
    return state == kLoginState_Connected
end

function GameServer:IsValidSDKSessions()
    return self.sdkSessions.id ~= nil
end

function GameServer:IsValidChannelInfo()
    return self.channelSessions.signature ~= nil
end

function GameServer:GetServerEntry(serverId)
    return self.allServers:GetEntryByKey(serverId)
end

function GameServer:HasRoleTheServer(serverId)
    return self.allServerRoles:Contains(serverId)
end

-- 更新服务器选择的事件来记录 --
local function UpdateCurrentServerHistory(self, currentServer)

    if type(currentServer) ~= "table" then
        return
    end

    local currentServerId = currentServer:GetId()

    if type(currentServerId) ~= "number" then
        return
    end

    local recentServers = self.recentServers or {}

    local found = false

    for i = 1, #recentServers do
        if recentServers[i] == currentServerId then
            found = true

            if i > 1 then
                _G.table.remove(recentServers, i)
                _G.table.insert(recentServers, 1, currentServerId)
            end

            break
        end
    end

    if not found then
        _G.table.insert(recentServers, 1, currentServerId)
    end

    -- note: 这里只移除一个 因为不会突然涨1个以上 不过这里这样处理不太严谨!
    if #recentServers > RecentServerLimits then
        _G.table.remove(recentServers)
    end

    self.recentServers = recentServers
end

local function OnLoginResponse(self, _)
	print(">>>> OnLoginResponse")
    local state = GetCurrentState(self)
    if state == kLoginState_Connecting then
        SetState(self, kLoginState_Connected)
        NotifyGameServerStateChanged(self)
    end
end

local function OnGameServerSelectionNodeClicked(self, serverId)
    if type(serverId) == "number" then
        if IsServerIdValid(self, serverId) then
            local serverInfo = self.allServers:GetEntryByKey(serverId)
            if self.currentServer ~= serverInfo then
                self.currentServer = serverInfo
            end
        end
    end
end

function GameServer:Start()
    self.recentServers = LoadRecentServers(self)

    local net = require "Network.Net"
    self.game:RegisterMsgHandler(net.S2CLoginResult, self, OnLoginResponse)

    self.game:RegisterEvent(messageGuids.GameServerSelectionNodeClicked, self, OnGameServerSelectionNodeClicked, nil)
end

function GameServer:Close()
    local net = require "Network.Net"
    self.game:UnRegisterMsgHandler(net.S2CLoginResult, self, OnLoginResponse)

    self.game:UnregisterEvent(messageGuids.GameServerSelectionNodeClicked, self, OnGameServerSelectionNodeClicked, nil)
end




local function OnConfirmReconnect(self)
	self:Connect()
end

local function RunLoginScene(self, isReconnect)
    if not IsLoginPhase() then
        self.game:GetWindowManager():CloseAll(true)
        utility.JumpScene(function()
            local game = utility.GetGame()
            local sceneManager = game:GetSceneManager()
            local LoginScene = require "Scenes.LoginScene".New(isReconnect)
            sceneManager:ReplaceScene(LoginScene)
            sceneManager:ClearAllScenesExceptWorkingScenes()
            SetState(self, kLoginState_None)
        end)
	end
end

local function OnCancelReconnect(self)
    print("<<<<<< OnCancelReconnect >>>>>>>")
	RunLoginScene(self, true)
end

local function ShowReconnectDialog(self)
    utility.ShowConfirmDialog("与服务器失去连接, 是否尝试重新连接?", self, OnConfirmReconnect, OnCancelReconnect)
end

function GameServer:GetSessionState()
    return self.sessionState
end

function GameServer:OnSessionStateChanged(code)
    ResetGmConsoleInfo(self)

    debug_print("@当前Session状态:", code);

    local previousSessionState = self.sessionState
    self.sessionState = code

    if code == kSessionState_Connected then

        -- @ 1. 更新
        UpdateCurrentServerHistory(self, GetCurrentServer(self))

        -- @ 2. 保存
        SaveRecentServers(self.recentServers)

        -- @ 3. 更新GM命令设置
        SetGmConsoleInfo(self)

        -- @ 4. 当前的服务器登录 --
        local currentServer = GetCurrentServer(self)
        if currentServer ~= nil and self:IsValidChannelInfo() then
            --account, server_id, signature, channel, sdkId, deviceId, deviceModel
            local msg, prototype = ServerService.Login(
                self.userName,
                currentServer:GetId(),
                self.channelSessions.signature,
                200,
                GetSDKChannelID(self),
                _G.DeviceUtility.GetIMEI(),
                self.sdkSessions.deviceModel
            )

            -- 发送消息 --
            self.game:SendNetworkMessage(msg, prototype)
        end

        SetState(self, kLoginState_Connecting)
        NotifyGameServerStateChanged(self)
    else
        if previousSessionState ~= kSessionState_Connected and code == kSessionState_ConnectFailed then
            SetState(self, kLoginState_WaitingForConnect)
            NotifyGameServerStateChanged(self, "连接错误!")
        end

        if not IsLoginPhase() then
            ShowReconnectDialog(self)
        end
    end
end