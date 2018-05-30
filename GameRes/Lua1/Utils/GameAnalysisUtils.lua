
-- note: 这里是热云GameAnalysis的SDK的接口

local GameAnalysisUtils = {}

local utility = require "Utils.Utility"

local CURRENCY_TYPE = "CNY"

local function GetGameAnalysisManager()
    return _G.ReYunGameAnalysisManager.Instance
end

local function GetUserData()
    local UserDataType = require "Framework.UserDataType"
    return utility.GetGame():GetDataCacheManager():GetData(UserDataType.PlayerData)
end

local function GetPlayerLevel()
    return GetUserData():GetLevel()
end

local function GetPlayerUid()
    return GetUserData():GetUid()
end

local function GetPlayerName()
    return GetUserData():GetName()
end

local function GetServerId()
    return (utility.GetGame():GetGameServer():GetCurrentServerReadonly())
end

-- 进入场景时调用 --
local enterSceneTable = {}
function GameAnalysisUtils.EnterScene(name)
    enterSceneTable["scene"] = name
    GetGameAnalysisManager():SetEvent("进入界面", enterSceneTable)
end

-- 完成关卡时调用 --
local function GetLevelQuestTypeDesc(levelId)
    local ChapterLevelUtils = require "Utils.ChapterLevelUtils"
    return string.format( "关卡(%s)",  ChapterLevelUtils.GetLevelChapterNumDesc(levelId))
end

-- 没有人调用.(TODO 一会修复)
function GameAnalysisUtils.LevelStart(levelId)
    GetGameAnalysisManager():SetQuest(levelId, "Start", GetLevelQuestTypeDesc(levelId))
end

-- 关卡胜利
function GameAnalysisUtils.LevelDone(levelId)
    GetGameAnalysisManager():SetQuest(levelId, "Done", GetLevelQuestTypeDesc(levelId))
end

-- 关卡失败
function GameAnalysisUtils.LevelFail(levelId)
    GetGameAnalysisManager():SetQuest(levelId, "Fail", GetLevelQuestTypeDesc(levelId))
end

-- 任务奖励领取完成时调用
function GameAnalysisUtils.TaskDrawDone(taskid, type)
    GetGameAnalysisManager():SetQuest(taskid, "Done", string.format("任务奖励领取(类型:%d)", type))
end

-- 记录支付行为(不包括赠送)
function GameAnalysisUtils.StartPayment(transactionId, currencyAmount, virtualCoinAmount, iapName, iapAmount)
    -- 用户开始充值
    GetGameAnalysisManager():StartPayment(
        transactionId,
        nil,    -- paymentType
        CURRENCY_TYPE,    -- currencyType
        currencyAmount,
        virtualCoinAmount,
        iapName,
        iapAmount
    )
end

-- 用户完成支付
function GameAnalysisUtils.EndPayment(transactionId, currencyAmount, virtualCoinAmount, iapName, iapAmount)
    GetGameAnalysisManager():EndPayment(
        transactionId,
        nil,
        CURRENCY_TYPE,
        currencyAmount,
        virtualCoinAmount,
        iapName,
        iapAmount,
        GetPlayerLevel()
    )
end

-- 系统赠送
function GameAnalysisUtils.Reward(transactionId, iapName, iapAmount)
    GetGameAnalysisManager():StartPayment(
        transactionId,
        "FREE",
        CURRENCY_TYPE,
        0,
        iapAmount,
        iapName,
        iapAmount
    )

    GetGameAnalysisManager():EndPayment(
        transactionId,
        "FREE",
        CURRENCY_TYPE,
        0,
        iapAmount,
        iapName,
        iapAmount,
        GetPlayerLevel()
    )
end

-- 消耗
function GameAnalysisUtils.Consume(item, itemNumber, priceInVirtualCurrency)
    GetGameAnalysisManager():SetEconomy(item, itemNumber, priceInVirtualCurrency)
end

-- 注册
function GameAnalysisUtils.Register()
    GetGameAnalysisManager():Register(
        GetPlayerUid(),
        nil, -- accountType
        "Other",
        -1,
        GetServerId(),
        GetPlayerName()
    )
end

-- 登录
function GameAnalysisUtils.Login()
    GetGameAnalysisManager():Login(
        GetPlayerUid(),
        GetPlayerLevel(),
        GetServerId(),
        "Other",
        -1,
        GetPlayerName()
    )
end


-- 记录本地行为(埋点) -- TODO 这个函数回头移动到其他地方.
function GameAnalysisUtils.RecordLocalAction(trackingID)
    local game = require "Utils.Utility".GetGame()
    return game:SendNetworkMessage(require "Network.ServerService".ActionRecordRequest(trackingID))
end

return GameAnalysisUtils
