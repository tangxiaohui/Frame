
local PropertyUtils = {}

function PropertyUtils.GetProperty(id)
    if type(id) ~= "number" or id <= 0 then return nil end
    local PropertyInfoManager = require "StaticData.PropertyInfo"
    local propertyData = PropertyInfoManager:GetData(id)
    return id, propertyData:GetName(), propertyData:GetRateStr()
end

local function FormatLabel(label, format, value)
    label.text = string.format(format, value)
end

function PropertyUtils.Format(id, idLabel, idFormat, value, valueLabel, valueFormat)
    local id, name, rateStr = PropertyUtils.GetProperty(id)
    if id == nil then return end
    FormatLabel(idLabel, idFormat, name)
    FormatLabel(valueLabel, string.format("%s%s%s", valueFormat, rateStr, rateStr), value)
end

return PropertyUtils
