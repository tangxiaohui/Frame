--
-- User: fbmly
-- Date: 4/13/17
-- Time: 5:58 PM
--

require "Collection.OrderedDictionary"

local utility = require "Utils.Utility"

local ChapterData = Class(LuaObject)

local LevelDataClass = require "Data.Chapter.LevelData"

function ChapterData:Ctor()
    self.levelDict = OrderedDictionary.New()
end

-----------------------------------------------------------------------
--- 根据不同业务 写的更新函数
-----------------------------------------------------------------------
-- # 对应 FBQueryAllMapResult 协议 直接更新 章节信息和所有关卡 (参数对应 FBMapInfo 类型)
function ChapterData:SetAllData(mapInfo)
    self.id = mapInfo.mapID -- 章节ID

    self.completes = mapInfo.complete   -- 奖励领取情况

    self.totalScore = mapInfo.wanchengdu    -- 总体分数(最高15分)

    -- 清除所有关卡数据
    self.levelDict:Clear()


    local levels = mapInfo.fbItem

    local currentLevel

    -- 设置所有
    for i = 1, #levels do
        currentLevel = LevelDataClass.New()
        currentLevel:SetAllData(levels[i])
        self.levelDict:Add(currentLevel:GetId(), currentLevel)
    end

end

--- # 对应 FBBuyChallengeResult 协议  更新现有的一个关卡信息 (参数对应 FBItem 类型)
function ChapterData:UpdateExistingLevel(fbItem)

    local levelUserData = self.levelDict:GetEntryByKey(fbItem.fbID)

    -- 这里必须要有关卡数据 --
    if levelUserData == nil then
        error(
            string.format("关卡ID: %d 的用户数据不存在!", fbItem.fbID)
        )
    end

    levelUserData:SetAllData(fbItem)
end

--- # 对应 FBOverResult 协议 更新关卡信息 (参数对应 FBItem 类型)
function ChapterData:Update(fbItem)
    local levelUserData = self.levelDict:GetEntryByKey(fbItem.fbID)
    if levelUserData == nil then
        levelUserData = LevelDataClass.New()
        levelUserData:SetAllData(fbItem)
        self.levelDict:Add(levelUserData:GetId(), levelUserData)
        return
    end
    levelUserData:SetAllData(fbItem)
end

----- # 对应 FBOverResult 协议的 msg (参数对应 FBOverResult 类型)
function ChapterData:UpdateFBOver(msg, chapterID)
    -- 首先更新本身
    self.id = chapterID
    self.completes = msg.complete
    self.totalScore = msg.wanchengdu


    -- 然后更新关卡
    local fbItem = msg.fbItem

    local levelUserData = self.levelDict:GetEntryByKey(fbItem.fbID)

    if levelUserData == nil then
        levelUserData = LevelDataClass.New()
        levelUserData:SetAllData(fbItem)
        self.levelDict:Add(levelUserData:GetId(), levelUserData)
    else
        levelUserData:SetAllData(fbItem)
    end
end

--- # 对应 FBDrawCompleteAwardResult 协议  更新现有的一个章节的领取奖励状态 (参数对应 FBDrawCompleteAwardResult 类型)
function ChapterData:UpdateChapterStage(awardResult)
    self.completes[awardResult.stage] = awardResult.wanchengdu
end

-----------------------------------------------------------------------
--- 获取函数
-----------------------------------------------------------------------
function ChapterData:GetId()
    return self.id
end

function ChapterData:GetCompleteStatus(pos)
    utility.ASSERT(type(pos) == "number", "参数 pos 必须是 number 类型")
    utility.ASSERT(pos >= 1 and pos <= 3, "参数 pos 的取值范围 [1-3]")
    return self.completes[pos]
end

function ChapterData:GetTotalScore()
    return self.totalScore
end

-----------------------------------------------------------------------
--- 获取函数2
-----------------------------------------------------------------------
function ChapterData:GetLevelStar(levelId)
    local currentLevel = self.levelDict:GetEntryByKey(levelId)
    if currentLevel ~= nil then
        return currentLevel:GetStar()
    end
    return 0
end

function ChapterData:GetLevelBuyTimes(levelId)
    local currentLevel = self.levelDict:GetEntryByKey(levelId)
    if currentLevel ~= nil then
        return currentLevel:GetBuyTimes()
    end
    return 0
end

function ChapterData:GetLevelRemainingTimes(levelId)
    local currentLevel = self.levelDict:GetEntryByKey(levelId)
    if currentLevel ~= nil then
        return currentLevel:GetRemainTimes()
    end
    local StaticLevelDataMgr = require "StaticData.ChapterLevel"
    return StaticLevelDataMgr:GetData(levelId):GetMaxAvailableTimes()
end

function ChapterData:Count()
    return self.levelDict:Count()
end

--
--function ChapterData:Print()
--    print('--------------------- chapter  -----------------------')
--
--    print('id', self:GetId())
--
--    local count = self.levelDict:Count()
--    for i = 1, count do
--        local currentLevel = self.levelDict:GetEntryByIndex(i)
--        currentLevel:Print()
--    end
--
--    print('-------------------------------------------------------')
--end
--
return ChapterData