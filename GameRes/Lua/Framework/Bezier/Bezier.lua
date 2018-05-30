--
-- User: fenghao
-- Date: 5/8/17
-- Time: 6:19 PM
--

require "Object.LuaObject"
local Vector3 = Vector3
local utility = require "Utils.Utility"

local Bezier = Class(LuaObject)

local function BezierPoint(self, t)
    return ((self.aa * t + (self.bb)) * t + self.cc) * t + self.a
end

local function BinarySearch(array, length)
    local startPos = 1
    local endPos = #array

    local currentPos = startPos

    local res = false

    while(startPos <= endPos)
    do
        currentPos = utility.ToInteger((startPos + endPos) / 2)
        -- found it
        if array[currentPos] == length then
            res = true
            break
        end

        if array[currentPos] < length then
            startPos = currentPos + 1
        else
            endPos = currentPos - 1
        end

    end

    return res, currentPos
end

local function Map(self, u)
    -- 目标值
    local targetLength = u * self.length

    local _, currentPos = BinarySearch(self.arcLengths, targetLength)

    if self.arcLengths[currentPos] >= targetLength then
        currentPos = currentPos - 1
    end

    if currentPos < 1 then
        currentPos = 1
    end

    -- 相差的距离
    local maxLength = #self.arcLengths

    local ratio = (targetLength - self.arcLengths[currentPos]) / (self.arcLengths[currentPos + 1] - self.arcLengths[currentPos])
    -- 比 --
    return (ratio + currentPos - 1) / (maxLength - 1)
end

function Bezier:Ctor(a, b, c, d, precision)
    self.a = a
    self.aa = (-a + (b - c) * 3 + d)
    self.bb = (a + c) * 3 - b * 6
    self.cc = (b - a) * 3

    self.len = 1.0 / precision
    self.arcLengths = {}
    self.arcLengths[1] = 0

    local ov = a
    local v
    local clen = 0

    -- 存放路过每个阶段时的总长度
    local arrayLength = utility.ToInteger(self.len) + 1
    for i = 2, arrayLength do
        v = BezierPoint(self, (i - 1) * precision)
        clen = clen + Vector3.Distance(ov, v)
        self.arcLengths[i] = clen
        ov = v
    end

    -- 保存最终的总长度
    self.length = clen
end

function Bezier:Length()
    return self.length
end

-- 获取 t 的所在位置
function Bezier:Point(t)
    return BezierPoint( self, Map(self, t) )
end

return Bezier