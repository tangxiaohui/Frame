
local utility = require "Utils.Utility"
require "Const"

local ChapterLevelUtils = {}

local function GetStaticChapterData(id)
    return require "StaticData.Chapter":GetData(id)
end

local function GetStaticLevelData(id)
    return require "StaticData.ChapterLevel":GetData(id)
end

local function GetChapterIdFromLevelId(levelId)
    return GetStaticLevelData(levelId):GetChapterId()
end

local function IsLevelOnceOnly(levelId)
    return GetStaticLevelData(levelId):GetMaxAvailableTimes() == 1
    -- local levelType = GetStaticLevelData(levelId):GetFbType()
    -- return levelType == kLevelType_Normal or levelType == kLevelType_Hidden
end

local function GetUserChapterData()
    local UserDataType = require "Framework.UserDataType"
    return utility.GetGame():GetDataCacheManager():GetData(UserDataType.PlayerChapterData)
end

local function GetUserLevelStar(chapterId, levelId)
    local UserDataType = require "Framework.UserDataType"
    local playerChapterData = GetUserChapterData()
    return playerChapterData:GetLevelStar(chapterId, levelId)
end

local function IsPlayerLeastLevelOfTheChapter(chapterId, playerLevel)
    local chapterData = GetStaticChapterData(chapterId)
    local chapterLevel = chapterData:GetChapterLv()
    if playerLevel >= chapterLevel then
        return true
    else
        return false, string.format("这个章节要 %d 级开启哦~", chapterLevel)
    end 
end

local function IsAllLevelsInChapterPassed(chapterId)
    utility.ASSERT(type(chapterId) == "number", "chapterId 不是 number 类型!")

    if chapterId <= 0 then
        return true
    end

    local chapterData = GetStaticChapterData(chapterId)
    local levelID = chapterData:GetFirstLevelID()
    local currentLevelData
    
    while(levelID > 0)
    do
        currentLevelData = GetStaticLevelData(levelID)

        -- 章节ID不一致 遍历结束了!
        if currentLevelData:GetChapterId() ~= chapterId then
            break
        end

        -- 获取动态数据
        local star = GetUserLevelStar(chapterId, currentLevelData:GetId())
        if star <= 0 then
            return false, chapterData
        end

        -- 继续遍历
        levelID = currentLevelData:GetNextLevelId()
    end

    return true
end

local function CanPlayChapterSelf(chapterId)
    local chapterData = GetStaticChapterData(chapterId)
    local res, preChapterData = IsAllLevelsInChapterPassed(chapterData:GetPreChapterID())
    if not res then
        return false, string.format("您需要先通关 %s", preChapterData:GetChapterInfo():GetName())
    end
    return true
end

function ChapterLevelUtils.GetChapterIdFromLevelId(levelId)
    return GetChapterIdFromLevelId(levelId)
end

function ChapterLevelUtils.GetUserLevelStarFromLevelId(levelId)
    return GetUserLevelStar(GetChapterIdFromLevelId(levelId), levelId)
end

-- # 是否能玩这个章节
function ChapterLevelUtils.CanPlayTheChapter(chapterId, playerLevel)
    utility.ASSERT(type(chapterId) == "number", "chapterId 不是 number 类型!")
    utility.ASSERT(type(playerLevel) == "number", "playerLevel 不是 number 类型!")

    local res, reason

    -- 等级判断
    res, reason = IsPlayerLeastLevelOfTheChapter(chapterId, playerLevel)
    if not res then
        return false, reason
    end

    -- 关卡判断
    res, reason = CanPlayChapterSelf(chapterId)
    if not res then
        return false, reason
    end

    return true
end

function ChapterLevelUtils.CanPlayTheLevelSelf(levelId, playerLevel)
    utility.ASSERT(type(levelId) == "number", "levelId 不是 number 类型!")

    local levelData = GetStaticLevelData(levelId)
    local star = GetUserLevelStar(levelData:GetChapterId(), levelId)

    if IsLevelOnceOnly(levelId) and star > 0 then
        return false, "这个关卡只能通关一次!"
    end

    star = nil

    if levelData:GetLevelLimit() > playerLevel then
        return false, string.format("关卡 %s %s 需要 %d 级开启!", levelData:GetLevelInfo():GetChapterNum(), levelData:GetLevelInfo():GetName(), levelData:GetLevelLimit())
    end

    local preLevelId = levelData:GetPreLevelId()
    if preLevelId <= 0 then
        return true
    end

    star = GetUserLevelStar(levelData:GetChapterId(), preLevelId)

    if star > 0 then
        return true
    else
        local preLevelData = GetStaticLevelData(preLevelId)
        return false, string.format("请先通关 %s %s", preLevelData:GetLevelInfo():GetChapterNum(), preLevelData:GetLevelInfo():GetName())
    end
end

function ChapterLevelUtils.CanPlayTheLevel(levelId, playerLevel)
    utility.ASSERT(type(levelId) == "number", "levelId 不是 number 类型!")
    utility.ASSERT(type(playerLevel) == "number", "playerLevel 不是 number 类型!")

    local chapterId = GetChapterIdFromLevelId(levelId)

    local res, reason

    repeat
        -- @ 1. 章节是否通过
        res, reason = ChapterLevelUtils.CanPlayTheChapter(chapterId, playerLevel)
        if not res then break end

        -- @ 2. 关卡本身是否通过
        res, reason = ChapterLevelUtils.CanPlayTheLevelSelf(levelId, playerLevel)
        
    until(true)
    
    return res, reason
end

function ChapterLevelUtils.GetLevelChapterNumDesc(levelId)
    utility.ASSERT(type(levelId) == "number", "levelId 不是 number 类型!")
    return GetStaticLevelData(levelId):GetLevelInfo():GetChapterNum()
end

-- 获取当前关卡已重置次数
function ChapterLevelUtils.GetLevelBuyTimes(levelId)
    utility.ASSERT(type(levelId) == "number", "levelId 不是 number 类型!")
    local chapterId = GetChapterIdFromLevelId(levelId)
    local playerChapterData = GetUserChapterData()
    return playerChapterData:GetLevelBuyTimes(chapterId, levelId)
end

-- 获取最大可重置次数(根据当前vip)
function ChapterLevelUtils.GetMaxLevelBuyTimes(vip)
    utility.ASSERT(type(vip) == "number", "vip 不是 number 类型!")
    local vipData = require "StaticData.Vip.Vip":SafeGetData(vip)
    if vipData ~= nil then
        return vipData:GetResetDungeonLimit()
    end
    return 0
end

-- 获取当前重置需要的钻石数量
function ChapterLevelUtils.GetDiamondBuyLevel(levelId)
    local times = ChapterLevelUtils.GetLevelBuyTimes(levelId)
    local vipBuyData = require "StaticData.ChapterBuy":SafeGetData(times + 1)
    if vipBuyData ~= nil then
        return vipBuyData:GetDiamond()
    end
    return 0
end


return ChapterLevelUtils
