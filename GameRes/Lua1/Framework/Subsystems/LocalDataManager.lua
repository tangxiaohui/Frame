--
-- User: fenghao
-- Date: 5/11/17
-- Time: 3:22 PM
--

require "Framework.GameSubSystem"
require "Collection.OrderedDictionary"
local utility = require "Utils.Utility"

-- 放置一些本地的数据(可存放临时状态 标志等数据) --

-----------------------------------------------------------------------
--- 局部数据Entry, 可以存储多种数据 --------------------------------------
-----------------------------------------------------------------------

local LocalDataEntry = Class(LuaObject)

function LocalDataEntry:Ctor()
    self.mainData = nil
    self.dataDict = OrderedDictionary.New()
    self.hasDropped = false
end

function LocalDataEntry:GetMainData()
    return self.mainData
end

function LocalDataEntry:SetMainData(data)
    self.mainData = data
end

function LocalDataEntry:SetData(name, data)
    self.dataDict:Remove(name)
    self.dataDict:Add(name, data)
end

function LocalDataEntry:GetData(name)
    return self.dataDict:GetEntryByKey(name)
end

function LocalDataEntry:RemoveData(name)
    return self.dataDict:Remove(name)
end

function LocalDataEntry:Drop()
    self.hasDropped = true
end

function LocalDataEntry:HasDropped()
    return self.hasDropped == true
end


-----------------------------------------------------------------------
--- 临时数据管理类 ------------------------------------------------------
-----------------------------------------------------------------------

local LocalDataManager = Class(GameSubSystem)

function LocalDataManager:Ctor()
    self.dataDict = OrderedDictionary.New()
end

local function GetEntry(self, name)
    return self.dataDict:GetEntryByKey(name)
end

local function SetEntry(self, name, entry)
    self.dataDict:Add(name, entry)
end

-- 设置主数据
function LocalDataManager:SetMainData(name, data)
    local entry = GetEntry(self, name)
    if entry == nil then
        entry = LocalDataEntry.New()
        SetEntry(self, name, entry)
    end
    entry:SetMainData(data)
end

-- 获取主数据
function LocalDataManager:GetMainData(name)
    local entry = GetEntry(self, name)
    if entry ~= nil then
        return entry:GetMainData()
    end
end

-- 设置数据
function LocalDataManager:GetData(name, dataName)
    local entry = GetEntry(self, name)
    if entry ~= nil then
        return entry:GetData(dataName)
    end
end

-- 设置数据
function LocalDataManager:SetData(name, dataName, data)
    local entry = GetEntry(self, name)
    if entry == nil then
        entry = LocalDataEntry.New()
        SetEntry(self, name, entry)
    end
    entry:SetData(dataName, data)
end

-- 丢弃数据 --
function LocalDataManager:Drop(name)
    local entry = self.dataDict:GetEntryByKey(name)
    if entry ~= nil then
        entry:Drop()
        self.dataDict:Remove(name)
        return entry
    end
    return nil
end

-----------------------------------------------------------------------
--- 实现 GameSubSystem 的接口
-----------------------------------------------------------------------
function LocalDataManager:GetGuid()
    return require "Framework.SubsystemGUID".LocalDataManager
end

function LocalDataManager:Startup()
end

function LocalDataManager:Shutdown()
end

function LocalDataManager:Restart()
end

function LocalDataManager:Update()
end

return LocalDataManager