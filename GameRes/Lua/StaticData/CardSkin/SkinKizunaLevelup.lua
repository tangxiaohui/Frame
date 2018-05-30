require "StaticData.Manager"

SkinLevelData = Class(LuaObject)

function SkinLevelData:Ctor(id)
    local SkinLevelMgr = Data.SkinKizunaLevelup.Manager.Instance()
    
    self.data = SkinLevelMgr:GetObject(id)
    if self.data == nil then
        error(string.format("卡牌羁绊等级信息，ID: %s 不存在", id))
        return
    end
end

function SkinLevelData:GetID()
    return self.data.id
end

function SkinLevelData:GetNeedItem()
    return self.data.needItem
end

function SkinLevelData:GetNeedNum()
    return self.data.itemNum
end

function SkinLevelData:GetLevelRank()
    return self.data.levelRank
end

function SkinLevelData:GetStage()
    return self.data.stage
end

SkinLevelManager = Class(DataManager)

local SkinLevelDataMgr = SkinLevelManager.New(SkinLevelData)

return SkinLevelDataMgr