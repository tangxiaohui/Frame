
-- 这里是热云TrackIO接口

local GameTrackIOUtils = {}

local utility = require "Utils.Utility"

local function GetReYunTrackIOManager()
	-- debug_print(_G.ReYunTrackIOManager.Instance)
    return _G.ReYunTrackIOManager.Instance
end

local function GetUserData()
    local UserDataType = require "Framework.UserDataType"
    return utility.GetGame():GetDataCacheManager():GetData(UserDataType.PlayerData)
end

local function GetPlayerUid()
    return GetUserData():GetUid()
end

function GameTrackIOUtils.Register()
	GetReYunTrackIOManager():Register(GetPlayerUid())
end

-- 登录
function GameTrackIOUtils.Login()
	GetReYunTrackIOManager():Login(GetPlayerUid())
end

-- 用户完成支付
function GameTrackIOUtils.EndPayment(transactionId, currencyAmount)
	--string transactionId, string payType, string currencyType, float currencyAmount
	GetReYunTrackIOManager():EndPayment(
		transactionId,
		nil,
		"CNY",
		currencyAmount
	)
end

return GameTrackIOUtils
