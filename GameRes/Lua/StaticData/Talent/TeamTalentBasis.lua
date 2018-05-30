require "StaticData.Manager"

TeamTalentBasisData = Class(LuaObject)

-----------------------------------------------------------------------
--- 初始化
-----------------------------------------------------------------------
local function CacheRanks(self)
    self.ranks = {}
    for i = 0, self.data.rank.Count - 1 do
        self.ranks[#self.ranks + 1] = self.data.rank[i]
    end
end

local function CacheLevels(self)
    self.levels = {}
    for i = 0, self.data.level.Count - 1 do
        self.levels[#self.levels + 1] = self.data.level[i]
    end
end

local function CacheNeedTypes(self)
    self.needTypes = {}
    for i = 0, self.data.needType.Count - 1 do
        self.needTypes[#self.needTypes + 1] = self.data.needType[i]
    end
end

local function CacheNeedNums(self)
    self.needNums = {}
    for i = 0, self.data.needNum.Count - 1 do
        self.needNums[#self.needNums + 1] = self.data.needNum[i]
    end
end

-- Passed
local function TestData(self)
    require "Utils.PrintTable"
    debug_print("数据输出测试开始 >>>>> ")
    debug_print("ID: ", self:GetID())
    PrintTable(self:GetRank())
    PrintTable(self:GetLevel())
    PrintTable(self:GetNeedType())
    PrintTable(self:GetNeedNum())
    debug_print("数据输出测试结束 <<<<< ")
end

function TeamTalentBasisData:Ctor(id)
    local TeamTalentBasisDataMgr = Data.TeamTalentBasis.Manager.Instance()
    self.data = TeamTalentBasisDataMgr:GetObject(id)
    if self.data == nil then
        error(string.format("角色天赋信息数据不存在，ID: %s 不存在", id))
    end
    CacheRanks(self)
    CacheLevels(self)
    CacheNeedTypes(self)
    CacheNeedNums(self)
    -- TestData(self)
end

function TeamTalentBasisData:GetID()
    return self.data.id
end

function TeamTalentBasisData:GetRank()
    return  self.ranks
end

function TeamTalentBasisData:GetLevel()
    return  self.levels
end

function TeamTalentBasisData:GetNeedType()
    return  self.needTypes
end

function TeamTalentBasisData:GetNeedNum()
    return self.needNums
end

--根据稀有度获取
function TeamTalentBasisData:GetInfoByRank(rank)
	if rank < 0 then
		debug_print("rank",rank,"Error !")
		return
	end
    return self.ranks[rank+1]
          ,self.levels[rank+1]
          ,self.needTypes[rank+1]
          ,self.needNums[rank+1]
end

TeamTalentBasisDataManager = Class(DataManager)

local TeamTalentBasisDataMgr = TeamTalentBasisDataManager.New(TeamTalentBasisData)
return TeamTalentBasisDataMgr