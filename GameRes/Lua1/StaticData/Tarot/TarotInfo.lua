require "StaticData.Manager"

local TarotInfoData = Class()

local function CacheNativeMembers(self, data)
    self.id = data.id
    self.name = data.tarotName
end

function TarotInfoData:Ctor(id)
    local TarotInfoManager = Data.TarotInfo.Manager.Instance()
    local data = TarotInfoManager:GetObject(id)
    if data == nil then
        error(string.format("塔罗牌本地化数据不存在, ID: %s 不存在", id))
    end
    CacheNativeMembers(self, data)
end

function TarotInfoData:GetId()
    return self.id
end

function TarotInfoData:GetName()
    return self.name
end

local TarotInfoDataManager = Class(DataManager)
return TarotInfoDataManager.New(TarotInfoData)
