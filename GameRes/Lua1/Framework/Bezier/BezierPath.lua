--
-- User: fenghao
-- Date: 5/8/17
-- Time: 6:19 PM
--

require "Object.LuaObject"
local Vector3 = Vector3
local utility = require "Utils.Utility"
local BezierClass = require "Framework.Bezier.Bezier"

local rad2Deg = Mathf.Rad2Deg
local math = math

local BezierPath = Class(LuaObject)

function BezierPath:Ctor(points, precision)
    self:SetPoints(points, precision)
end

function BezierPath:SetPoints(points, precision)
    utility.ASSERT(type(points) == "table", "参数 points 必须是 table 类型!")

    local pointCount = #points

    utility.ASSERT(pointCount >= 4, "点的个数必须大于等于4")
    utility.ASSERT(pointCount % 4 == 0, "点的个数必须是4的倍数")

    -- 获取数量(4个为一组)
    local bezierNumber = utility.ToInteger(pointCount / 4)

    -- 创建贝赛尔曲线数组 和 长度比率数组
    self.beziers = {}
    self.lengthRatio = {}

    -- 总长度
    self.length = 0

    local PointPos = 1

    -- 循环创建
    for i = 1, bezierNumber do
        self.beziers[i] = BezierClass.New(
            points[PointPos],
            points[PointPos + 1],
            points[PointPos + 2],
            points[PointPos + 3],
            precision
        )

        self.length = self.length + self.beziers[i]:Length()
        PointPos = PointPos + 4
    end

    -- 缓存每段曲线在整个曲线中的比例
    for i = 1, bezierNumber do
        self.lengthRatio[i] = self.beziers[i]:Length() / self.length
    end
end

function BezierPath:Length()
    return self.length
end

function BezierPath:Point(ratio)
    local added = 0.0
    local count = #self.lengthRatio
    for i = 1, count do
        added = added + self.lengthRatio[i]
        if added >= ratio then
            return self.beziers[i]:Point( (self.lengthRatio[i] - (added - ratio)) / self.lengthRatio[i] )
        end
    end
    return self.beziers[count]:Point(1.0)
end

function BezierPath:Place2d(transform, ratio)
    transform.position = self:Point(ratio)
    ratio = ratio + 0.001
    if ratio <= 1.0 then
        local v3Dir = self:Point(ratio) - transform.position
        local angle = math.atan2(v3Dir.y, v3Dir.x) * rad2Deg
        transform.eulerAngles = Vector3(0, 0, angle)
    end
end

function BezierPath:PlaceLocal2d(transform, ratio)
    transform.localPosition = self:Point(ratio)
    ratio = ratio + 0.001
    if ratio <= 1.0 then
        local v3Dir = self:Point(ratio) - transform.localPosition
        local angle = math.atan2(v3Dir.y, v3Dir.x) * rad2Deg
        transform.localEulerAngles = Vector3(0, 0, angle)
    end
end

function BezierPath:Place(transform, ratio, up)
    up = up or Vector3(0, 1, 0)
    transform.position = self:Point(ratio)
    ratio = ratio + 0.001
    if ratio<=1.0 then
        transform:LookAt( self:Point( ratio ), up )
    end
end

function BezierPath:PlaceLocal(transform, ratio, up)
    up = up or Vector3(0, 1, 0)
    ratio = self:GetRationInOneRange(ratio)
    transform.localPosition = self:Point(ratio)
    ratio = self:GetRationInOneRange (ratio + 0.001)
    if ratio <= 1.0 then
        transform:LookAt( transform.parent:TransformPoint( self:Point(ratio) ) , up )
    end
end

function BezierPath:GetRationInOneRange(ratio)
    if ratio >= 0.0 and ratio <= 1.0 then
        return ratio
    elseif ratio < 0.0 then
        return math.ceil(ratio) - ratio
    else
        return ratio - math.floor(ratio)
    end
end

return BezierPath