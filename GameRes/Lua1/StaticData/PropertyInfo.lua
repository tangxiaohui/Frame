require "StaticData.Manager"

local PropertyInfoData = Class()

function PropertyInfoData:Ctor(id)
    -- debug_print("#######", id)
    local PropertyInfoManager = Data.PropertyInfo.Manager.Instance()
    local data = PropertyInfoManager:GetObject(id)
    if data == nil then
        error(string.format("属性本地化数据不存在, ID: %s 不存在", id))
    end
    self.id = data.id
    self.name = data.name
    self.isRate = data.isRate
end

function PropertyInfoData:GetName()
    return self.name
end

function PropertyInfoData:GetRateStr()
    if self.isRate then
        return "%"
    else
        return ""
    end
end

local PropertyInfoDataManager = Class(DataManager)
return PropertyInfoDataManager.New(PropertyInfoData)
