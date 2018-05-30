require "StaticData.Manager"

local TarotData = Class()

-- private
local function GetNewStageData(data, index)
    local TarotStageDataClass = require "StaticData.Tarot.TarotStageData"
    return TarotStageDataClass.New(
        data.stage[index],
        data.itemType[index],
        data.needNum[index],
        data.powerType[index],
        data.powerNum[index]
    )
end

local function InitStageData(self)
    self.stageMap = {}
    local count = self.data.stage.Count - 1
    for i = 0, count do
        local stageData = GetNewStageData(self.data, i)
        self.stageMap[stageData:GetStage()] = stageData
    end
end

local function GetStageData(self, stage)
    return self.stageMap[stage]
end

function TarotData:Ctor(id)
    local TarotManager = Data.Tarot.Manager.Instance()
    self.data = TarotManager:GetObject(id)
    if self.data == nil then
        error(string.format("塔罗牌主表数据不存在, ID: %s 不存在", id))
    end
    InitStageData(self)
end

-- 塔罗牌ID
function TarotData:GetId()
    return self.data.id
end

-- 塔罗牌名字(TODO 待优化)
function TarotData:GetName()
    return require "StaticData.Tarot.TarotInfo":GetData(self.data.info):GetName()
end

-- 塔罗牌图片
function TarotData:GetTarotIllust()
    return self.data.tarotIllust
end

-- >> 获取各阶段数据

-- 获取所需道具ID
function TarotData:GetStageItemId(stage)
    local stageData = GetStageData(self, stage)
    if stageData ~= nil then
        return stageData:GetItemId()
    end
    return 0
end

-- 获取所需道具数量
function TarotData:GetStageItemNum(stage)
    local stageData = GetStageData(self, stage)
    if stageData ~= nil then
        return stageData:GetItemNum()
    end
    return 0
end

-- 获取当前阶段的属性ID
function TarotData:GetStagePropertyId(stage)
    local stageData = GetStageData(self, stage)
    if stageData ~= nil then
        return stageData:GetPropertyId()
    end
    return 0
end

-- 获取当前阶段的属性值
function TarotData:GetStagePropertyValue(stage)
    local stageData = GetStageData(self, stage)
    if stageData ~= nil then
        return stageData:GetPropertyValue()
    end
    return 0
end

local TarotDataManager = Class(DataManager)

-- static
function TarotDataManager.GetRowCount()
    local keys = Data.Tarot.Manager.Instance():GetKeys()
    if keys ~= nil then return keys.Length end
    return 0
end

function TarotDataManager.GetRowIdByIndex(index)
    local keys = Data.Tarot.Manager.Instance():GetKeys()
    if keys ~= nil then return keys[index] end
    return nil
end

function TarotDataManager:Foreach(func)
    local keyCount = TarotDataManager.GetRowCount() - 1
    for i = 0, keyCount do
        local id = TarotDataManager.GetRowIdByIndex(i)
        local tarotData = self:GetData(id)
        func(tarotData)
    end
end

function TarotDataManager:Any(func)
    local keyCount = TarotDataManager.GetRowCount() - 1
    for i = 0, keyCount do
        local id = TarotDataManager.GetRowIdByIndex(i)
        local tarotData = self:GetData(id)
        if func(tarotData) then
            return true
        end
    end
    return false
end

return TarotDataManager.New(TarotData)
