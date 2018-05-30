--
-- User: fenghao
-- Date: 20/07/2017
-- Time: 11:17 PM
--

require "Framework.GameSubSystem"

local SDKManager = Class(GameSubSystem)

function SDKManager:Ctor()
end

-----------------------------------------------------------------------
--- 内部初始化函数
-----------------------------------------------------------------------
local function LoadJointSDKManager(self)
    local UnityEngine = UnityEngine
    local GameObject = UnityEngine.GameObject
    local go = GameObject.New("JointSDKManager", typeof(_G.LoginSDK))
    UnityEngine.Object.DontDestroyOnLoad(go)
    self.gameObject = go
    self.transform = go.transform
end

local function LoadComponents(self)
    self.loginSDKComponent = self.gameObject:GetComponent(typeof(_G.LoginSDK))
end

-----------------------------------------------------------------------
--- 外部接口
-----------------------------------------------------------------------

-- 父渠道ID (如Android下的易接渠道为200. 对应服务器的channel字段)
function SDKManager:GetPlatformId()
    return self.loginSDKComponent.platformId
end

-- 子渠道ID (子渠道 如UC, 百度. 对应服务器的sdkId字段)
function SDKManager:GetChannelId()
    return self.loginSDKComponent.channelId
end

function SDKManager:Login(loginTable,callback)
    self.loginSDKComponent:Login(loginTable,callback)
end

function SDKManager:Logout(callback)
    self.loginSDKComponent:Logout(callback)
end

function SDKManager:Pay(unitPrice,unitName,count,callBackInfo,callBackUrl,luaFunction)
     self.loginSDKComponent:Pay(unitPrice,unitName,count,callBackInfo,callBackUrl,luaFunction)
end

-- /// <param name="roleId">当前登录的玩家角色 ID，必须为数字</param>
-- /// <param name="roleName">当前登录的玩家角色名，不能为空，不能为 null</param>
-- /// <param name="roleLevel">当前登录的玩家角色等级，必须为数字，且不能为 0，若无，传入 1</param>
-- /// <param name="zoneId">当前登录的游戏区服 ID，必须为数字，且不能为 0，若无，传入 1</param>
-- /// <param name="zoneName">//当前登录的游戏区服名称，不能为空，不能为null</param>
-- /// <param name="balance">用户虚拟货币余额，必须为数字，若无，传入 0</param>
-- /// <param name="vip">当前用户 VIP 等级，必须为数字，若无，传入 1</param>
-- /// <param name="partyName">前角色所属帮派，不能为空，不能为 null，若无，传入“无帮派”</param>
-- /// <param name="roleCTime">单位为秒，创建角色的时间(时间戳)</param>
-- /// <param name="roleLevelMTime">单位为秒，角色等级变化时间(时间戳)</param>
-- /// <param name="key">表示设置数据的模式，默认等于0表示登录成功之后同步数据，等于1表示创建新角色，2角色升级，3表示选择服务器进入时使用</param>
function SDKManager:UpdateInfoCheck(roleId, roleName, roleLevel, zoneId, zoneName, balance, vip, partyName, roleCTime, roleLevelMTime, key)
    self.loginSDKComponent:UpdateInfoCheck(roleId, roleName, roleLevel, zoneId, zoneName, balance, vip, partyName, roleCTime, roleLevelMTime, key)
end

function SDKManager:LoginScuess()
     self.loginSDKComponent:LoginScuess()
end

function SDKManager:IsFuckingSDK()
    return self.loginSDKComponent:IsFuckingSDK()
end

function SDKManager:IsSessionEmpty()
    return self.loginSDKComponent:IsSessionEmpty()
end

function SDKManager:SetSessionType(session)
    self.loginSDKComponent:SetSessionType(session)
end

---------------------------------------------------------------------------
------- 实现 GameSubSystem 的接口
---------------------------------------------------------------------------
function SDKManager:GetGuid()
    return require "Framework.SubsystemGUID".SDKManager
end

function SDKManager:Startup()
    LoadJointSDKManager(self)
    LoadComponents(self)
end

function SDKManager:Shutdown()

end

function SDKManager:Restart()

end

function SDKManager:Update()

end


return SDKManager
