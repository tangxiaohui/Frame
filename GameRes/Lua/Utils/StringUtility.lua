--
-- User: fenghao
-- Date: 19/06/2017
-- Time: 2:26 AM
--

local StringUtility = {}

local function GetByteCount(str, index)
    local curByte = string.byte(str, index)
    if curByte >= 0x0 and curByte <= 0x7F then
        return 1
    elseif curByte >= 0xC0 and curByte <= 0xDF then
        return 2
    elseif curByte >= 0xE0 and curByte <= 0xEF then
        return 3
    elseif curByte >= 0xF0 and curByte <= 0xF7 then
        return 4
    end
    return 1
end

local function AppendToArray(array, str)
    array[#array + 1] = str
end

local function CreateArray(array, str)
    local pos = 1
    local length = str:len()
    while(pos <= length)
    do
        local byteCount = GetByteCount(str, pos)
        AppendToArray(array, str:sub(pos, pos + byteCount - 1))
        pos = pos + byteCount
    end
end

function StringUtility.CreateArray(str)
    local array = {}
    CreateArray(array, str)
    return array
end

function StringUtility.Append(array, str)
    CreateArray(array, str)
end

function StringUtility.ToString(array, sep, startPos, endPos)
    return table.concat(array, sep, startPos, endPos)
end

return StringUtility