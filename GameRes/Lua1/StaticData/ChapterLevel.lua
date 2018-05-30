
require "StaticData.Manager"

local ChapterLevelData = Class(LuaObject)

function ChapterLevelData:Ctor(id)
    local chapterLevelMgr = Data.ChapterLevel.Manager.Instance()
    self.data = chapterLevelMgr:GetObject(id)
    if self.data == nil then
        error(string.format("关卡，ID: %s 不存在", id))
        return
    end

    -- 初始化关卡信息
    local levelInfoMgr = require "StaticData.LevelInfo"
    self.levelInfo = levelInfoMgr:GetData(self.data.levelInfo)

    -- 初始化队伍信息
    local foeTeamMgr = require "StaticData.FoeTeam"
    self.teams = {}

    for i = 0, self.data.teams.Count - 1 do
        self.teams[#self.teams + 1] = foeTeamMgr:GetData(self.data.teams[i])
    end
end

function ChapterLevelData:GetId()
    return self.data.id
end

function ChapterLevelData:GetLevelInfo()
    return self.levelInfo
end

function ChapterLevelData:GetPreLevelId()
    return self.data.preLevelId
end

function ChapterLevelData:GetNextLevelId()
    return self.data.nextLevelID
end

function ChapterLevelData:GetBranchLevelId()
    return self.data.branchLevelId
end

function ChapterLevelData:GetChapterId()
    return self.data.chapterId
end

function ChapterLevelData:GetLevelImage()
    return self.data.levelImage
end

function ChapterLevelData:GetFbType()
    return self.data.fbType
end

function ChapterLevelData:GetVigorToConsume()
    return self.data.costTili
end

function ChapterLevelData:GetExpToGain()
    return self.data.gainExp
end

function ChapterLevelData:GetQuestToAdd()
    return self.data.addTansuo
end

function ChapterLevelData:GetMapType()
    return self.data.mapType
end

function ChapterLevelData:GetMonsterLevel()
    return self.data.monster_level
end

function ChapterLevelData:GetMonsterStage()
    return self.data.monster_stage
end

function ChapterLevelData:GetPlotID()
    return self.data.plotId
end

function ChapterLevelData:GetSceneID()
    return self.data.sceneId
end

function ChapterLevelData:GetBGM()
    return self.data.useBGM
end

function ChapterLevelData:GetTeams()
    return self.teams
end

function ChapterLevelData:GetRewardIds()
    return self.data.rewardId
end

function ChapterLevelData:GetLevelLimit()
    return self.data.levelLimit
end

function ChapterLevelData:GetMaxAvailableTimes()
    return self.data.maxFightCount
end

function ChapterLevelData:GetSourceIndex()
   return self.data.SourceIndex
end

local chapterLevelManagerClass = Class(DataManager)
return chapterLevelManagerClass.New(ChapterLevelData)