--
-- User: fbmly
-- Date: 4/13/17
-- Time: 4:37 PM
--

require "Collection.OrderedDictionary"

local ChapterDataClass = require "Data.Chapter.ChapterData"

PlayerChapterData = Class(LuaObject)

function PlayerChapterData:Ctor()
    self.chapterDict = OrderedDictionary.New()
end

-----------------------------------------------------------------------
--- 根据不同业务 写的更新函数
-----------------------------------------------------------------------
--- # 对应 FBQueryAllMapResult 协议 直接更新所有章节 (参数对应repeated mapInfo)
function PlayerChapterData:SetAllData(mapInfos)
    -- 清除全部
    self.chapterDict:Clear()

    local currentChapter

    -- 设置所有
    for i = 1, #mapInfos do
        currentChapter = ChapterDataClass.New()
        currentChapter:SetAllData(mapInfos[i])
        self.chapterDict:Add(currentChapter:GetId(), currentChapter)
    end
end

--- # 对应 FBBuyChallengeResult 协议  更新现有的一个关卡信息 (参数对应 FBItem 类型)
function PlayerChapterData:UpdateExistingLevel(fbItem, chapterIdToCheck)

    local levelData = require "StaticData.ChapterLevel":GetData(fbItem.fbID)

    local localChapterId = levelData:GetChapterId()

    -- 有机会去验证服务器和本地的数据是否同步
    if type(chapterIdToCheck) == "number" and localChapterId ~= chapterIdToCheck then
        error(
            string.format(
                "服务器传过来的章节ID和客户端的配置不同步, 请检查 => 服务器: %d, 客户端: %d",
                chapterIdToCheck,
                levelData:GetChapterId()
            )
        )
    end

    -- 取得章节数据
    local chapterUserData = self.chapterDict:GetEntryByKey(localChapterId)
    if chapterUserData == nil then
        error(
            string.format("章节ID: %d 的用户数据不存在!", localChapterId)
        )
    end

    -- 然后去更新当前关卡数据
    chapterUserData:UpdateExistingLevel(fbItem)
end

--- # 对应 FBOverResult 协议 更新关卡信息 (参数对应 FBOverResult 类型)
function PlayerChapterData:UpdateFBOver(msg)
    local fbItem = msg.fbItem
    local levelData = require "StaticData.ChapterLevel":GetData(fbItem.fbID)
    local localChapterId = levelData:GetChapterId()

    -- 取得章节数据
    local chapterUserData = self.chapterDict:GetEntryByKey(localChapterId)
    if chapterUserData == nil then
        chapterUserData = ChapterDataClass.New()
        chapterUserData:UpdateFBOver(msg, localChapterId)
        self.chapterDict:Add(chapterUserData:GetId(), chapterUserData)
    else
        chapterUserData:UpdateFBOver(msg, localChapterId)
    end
end


--- # 对应 FBDrawCompleteAwardResult 协议  更新现有的一个章节的领取奖励状态 (参数对应 FBDrawCompleteAwardResult 类型)
function PlayerChapterData:UpdateExistingChapterStage(awardResult)
    local chapterId = awardResult.mapID
    -- 取得章节数据
    local chapterUserData = self.chapterDict:GetEntryByKey(chapterId)
    chapterUserData:UpdateChapterStage(awardResult)
end

-----------------------------------------------------------------------
--- 获取函数
-----------------------------------------------------------------------
-- 数量
function PlayerChapterData:Count()
    print("self.chapterDict:Count()",self.chapterDict:Count())
    return self.chapterDict:Count()
end


-----------------------------------------------------------------------
--- 获取函数 - 章节相关
-----------------------------------------------------------------------
function PlayerChapterData:GetChapterCompleteStatus(chapterId, pos)
    local currentChapter = self.chapterDict:GetEntryByKey(chapterId)
    if currentChapter ~= nil then
        return currentChapter:GetCompleteStatus(pos)
    end
    return 0
end

function PlayerChapterData:GetChapterTotalScore(chapterId)
    local currentChapter = self.chapterDict:GetEntryByKey(chapterId)
    if currentChapter ~= nil then
        return currentChapter:GetTotalScore()
    end
    return 0
end

-----------------------------------------------------------------------
--- 获取函数 - 关卡相关
-----------------------------------------------------------------------
function PlayerChapterData:GetLevelStar(chapterId, levelId)
    local currentChapter = self.chapterDict:GetEntryByKey(chapterId)
    if currentChapter ~= nil then
        return currentChapter:GetLevelStar(levelId)
    end
    return 0
end

function PlayerChapterData:GetLevelBuyTimes(chapterId, levelId)
    local currentChapter = self.chapterDict:GetEntryByKey(chapterId)
    if currentChapter ~= nil then
        return currentChapter:GetLevelBuyTimes(levelId)
    end
    return 0
end

function PlayerChapterData:GetLevelRemainingTimes(chapterId, levelId)
    local currentChapter = self.chapterDict:GetEntryByKey(chapterId)
    if currentChapter ~= nil then
        return currentChapter:GetLevelRemainingTimes(levelId)
    end
    local StaticLevelDataMgr = require "StaticData.ChapterLevel"
    return StaticLevelDataMgr:GetData(levelId):GetMaxAvailableTimes()
end

function PlayerChapterData:HasAnyLevel(chapterId)
    local currentChapter = self.chapterDict:GetEntryByKey(chapterId)
    if currentChapter ~= nil then
        return currentChapter:Count() > 0
    end
    return false
end
