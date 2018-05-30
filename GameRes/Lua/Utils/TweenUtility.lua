
local TweenUtility = {}

-- translated from https://github.com/dentedpixel/LeanTween/blob/master/Assets/Plugins/LeanTween/LeanTween.cs

local math = math
local Mathf = Mathf

function TweenUtility.EaseOutQuadOpt(start, diff, ratioPassed)
    return -diff * ratioPassed * (ratioPassed - 2) + start
end

function TweenUtility.EaseInQuadOpt(start, diff, ratioPassed)
    return diff * ratioPassed * ratioPassed + start
end

function TweenUtility.EaseInOutQuadOpt(start, diff, ratioPassed)
    ratioPassed = ratioPassed / 0.5
    if ratioPassed < 1 then
        return diff / 2 * ratioPassed * ratioPassed + start
    end
    ratioPassed = ratioPassed - 1
    return -diff / 2 * (ratioPassed * (ratioPassed - 2) - 1) + start
end

function TweenUtility.Constant(start, end_, val)
    return TweenUtility.Linear(start, end_, math.floor(val))
end

function TweenUtility.Linear(start, end_, val)
    return Mathf.Lerp(start, end_, val)
end

function TweenUtility.Clerp(start, end_, val)
    local min = 0.0
    local max = 360.0
    local half = math.abs((max - min) / 2.0)
    local retval = 0.0
    local diff = 0.0
    if ((end_ - start) < -half) then
        diff = ((max - start) + end_) * val
        retval = start + diff
    elseif ((end_ - start) > half) then
        diff = -((max - end_) + start) * val
        retval = start + diff
    else
        retval = start + (end_ - start) * val
    end
    return retval
end

function TweenUtility.Spring(start, end_, val)
    val = Mathf.Clamp01(val)
    val = (Mathf.Sin(val * Mathf.PI * (0.2 + 2.5 * val * val * val)) * Mathf.Pow(1 - val, 2.2 ) + val) * (1 + (1.2 * (1 - val) ))
    return start + (end_ - start) * val
end

function TweenUtility.EaseInQuad(start, end_, val)
    end_ = end_ - start
    return end_ * val * val + start
end

function TweenUtility.EaseOutQuad(start, end_, val)
    end_ = end_ - start
    return -end_ * val * (val - 2) + start
end

function TweenUtility.EaseInOutQuad(start, end_, val)
    val = val / 0.5
    end_ = end_ - start
    if (val < 1) then
        return end_ / 2 * val * val + start
    end
    val = val - 1
    return -end_ / 2 * (val * (val - 2) - 1) + start
end

function TweenUtility.EaseInOutQuadOpt2(start, diffBy2, val, val2)
    val = val / 0.5
    if (val < 1) then
        return diffBy2 * val2 + start
    end
    val = val - 1
    return -diffBy2 * ((val2 - 2) - 1) + start
end

function TweenUtility.EaseInCubic(start, end_, val)
    end_ = end_ - start
    return end_ * val * val * val + start
end

function TweenUtility.EaseOutCubic(start, end_, val)
    val = val - 1
    end_ = end_ - start
    return end_ * (val * val * val + 1) + start
end

function TweenUtility.EaseInOutCubic(start, end_, val)
    val = val / 0.5
    end_ = end_ - start
    if (val < 1) then
        return end_ / 2 * val * val * val + start
    end
    val = val - 2
    return end_ / 2 * (val * val * val + 2) + start
end

function TweenUtility.EaseInQuart(start, end_, val)
    end_ = end_ - start
    return end_ * val * val * val * val + start
end

function TweenUtility.EaseOutQuart(start, end_, val)
    val = val - 1
    end_ = end_ - start
    return -end_ * (val * val * val * val - 1) + start
end

function TweenUtility.EaseInOutQuart(start, end_, val)
    val = val / 0.5
    end_ = end_ - start
    if (val < 1) then
        return end_ / 2 * val * val * val * val + start
    end
    val = val - 2
    return -end_ / 2 * (val * val * val * val - 2) + start
end

function TweenUtility.EaseInQuint(start, end_, val)
    end_ = end_ - start
    return end_ * val * val * val * val * val + start
end

function TweenUtility.EaseOutQuint(start, end_, val)
    val = val - 1
    end_ = end_ - start
    return end_ * (val * val * val * val * val + 1) + start
end

function TweenUtility.EaseInOutQuint(start, end_, val)
    val = val / 0.5
    end_ = end_ - start
    if (val < 1) then
        return end_ / 2 * val * val * val * val * val + start
    end
    val = val - 2
    return end_ / 2 * (val * val * val * val * val + 2) + start
end

function TweenUtility.EaseInSine(start, end_, val)
    end_ = end_ - start
    return -end_ * Mathf.Cos(val / 1 * (Mathf.PI / 2)) + end_ + start
end

function TweenUtility.EaseOutSine(start, end_, val)
    end_ = end_ - start
    return end_ * Mathf.Sin(val / 1 * (Mathf.PI / 2)) + start
end

function TweenUtility.EaseInOutSine(start, end_, val)
    end_ = end_ - start
    return -end_ / 2 * (Mathf.Cos(Mathf.PI * val / 1) - 1) + start
end

function TweenUtility.EaseInExpo(start, end_, val)
    end_ = end_ - start
    return end_ * Mathf.Pow(2, 10 * (val / 1 - 1)) + start
end

function TweenUtility.EaseOutExpo(start, end_, val)
    end_ = end_ - start
    return end_ * (-Mathf.Pow(2, -10 * val / 1) + 1) + start
end

function TweenUtility.EaseInOutExpo(start, end_, val)
    val = val / 0.5
    end_ = end_ - start
    if (val < 1) then
        return end_ / 2 * Mathf.Pow(2, 10 * (val - 1)) + start
    end
    val = val - 1
    return end_ / 2 * (-Mathf.Pow(2, -10 * val) + 2) + start
end

function TweenUtility.EaseInCirc(start, end_, val)
    end_ = end_ - start
    return -end_ * (Mathf.Sqrt(1 - val * val) - 1) + start
end

function TweenUtility.EaseOutCirc(start, end_, val)
    val = val - 1
    end_ = end_ - start
    return end_ * Mathf.Sqrt(1 - val * val) + start
end

function TweenUtility.EaseInOutCirc(start, end_, val)
    val = val / 0.5
    end_ = end_ - start
    if (val < 1) then
        return -end_ / 2 * (Mathf.Sqrt(1 - val * val) - 1) + start
    end
    val = val - 2
    return end_ / 2 * (Mathf.Sqrt(1 - val * val) + 1) + start
end

function TweenUtility.EaseOutBounce(start, end_, val)
    val = val / 1
    end_ = end_ - start

    if (val < (1 / 2.75)) then
        return end_ * (7.5625 * val * val) + start
    elseif (val < (2 / 2.75)) then
        val = val - (1.5 / 2.75)
        return end_ * (7.5625 * (val) * val + 0.75) + start
    elseif (val < (2.5 / 2.75)) then
        val = val - (2.25 / 2.75)
        return end_ * (7.5625 * (val) * val + 0.9375) + start
    else
        val = val - (2.625 / 2.75)
        return end_ * (7.5625 * (val) * val + 0.984375) + start
    end
end

function TweenUtility.EaseInBounce(start, end_, val)
    end_ = end_ - start
    local d = 1
    return end_ - TweenUtility.EaseOutBounce(0, end_, d-val) + start
end

function TweenUtility.EaseInOutBounce(start, end_, val)
    end_ = end_ - start
    local d = 1
    if (val < d/2) then
        return TweenUtility.EaseInBounce(0, end_, val*2) * 0.5 + start
    else
        return TweenUtility.EaseOutBounce(0, end_, val*2-d) * 0.5 + end_*0.5 + start
    end
end

function TweenUtility.EaseInBack(start, end_, val, overshoot)
    overshoot = overshoot or 1.0
    end_ = end_ - start
    val = val / 1
    local s = 1.70158 * overshoot
    return end_ * (val) * val * ((s + 1) * val - s) + start
end

function TweenUtility.EaseOutBack(start, end_, val, overshoot)
    overshoot = overshoot or 1.0
    local s = 1.70158 * overshoot
    end_ = end_ - start
    val = (val / 1) - 1
    return end_ * ((val) * val * ((s + 1) * val + s) + 1) + start
end

function TweenUtility.EaseInOutBack(start, end_, val, overshoot)
    overshoot = overshoot or 1.0
    local s = 1.70158 * overshoot
    end_ = end_ - start
    val = val / 0.5

    if ((val) < 1) then
        s = s *((1.525) * overshoot)
        return end_ / 2 * (val * val * (((s) + 1) * val - s)) + start
    end
    val = val - 2
    s = s * ((1.525) * overshoot)
    return end_ / 2 * ((val) * val * (((s) + 1) * val + s) + 2) + start
end

function TweenUtility.EaseInElastic(start, end_, val, overshoot, period)
    overshoot = overshoot or 1.0
    period = period or 0.3
    end_ = end_ - start

    local p = period
    local s = 0
    local a = 0

    if (val == 0) then
        return start
    end

    if (val == 1) then
        return start + end_
    end

    if (a == 0 or a < Mathf.Abs(end_)) then
        a = end_
        s = p / 4
    else
        s = p / (2 * Mathf.PI) * Mathf.Asin(end_ / a)
    end

    if(overshoot>1 and val>0.6) then
        overshoot = 1 + ((1-val) / 0.4 * (overshoot-1))
    end
    -- Debug.Log("ease in elastic val:"+val+" a:"+a+" overshoot:"+overshoot)

    val = val-1
    return start-(a * Mathf.Pow(2, 10 * val) * Mathf.Sin((val - s) * (2 * Mathf.PI) / p)) * overshoot
end

function TweenUtility.EaseOutElastic(start, end_, val, overshoot, period)
    overshoot = overshoot or 1.0
    period = period or 0.3
    end_ = end_ - start

    local p = period
    local s = 0
    local a = 0

    if (val == 0) then
        return start
    end

    -- Debug.Log("ease out elastic val:"+val+" a:"+a);
    if (val == 1) then
        return start + end_
    end

    if (a == 0 or a < Mathf.Abs(end_)) then
        a = end_
        s = p / 4
    else
        s = p / (2 * Mathf.PI) * Mathf.Asin(end_ / a)
    end

    if(overshoot>1 and val<0.4) then
        overshoot = 1 + (val / 0.4 * (overshoot-1))
    end
    --Debug.Log("ease out elastic val:"+val+" a:"+a+" overshoot:"+overshoot);

    return start + end_ + a * Mathf.Pow(2, -10 * val) * Mathf.Sin((val - s) * (2 * Mathf.PI) / p) * overshoot
end

function TweenUtility.EaseInOutElastic(start, end_, val, overshoot, period)
    overshoot = overshoot or 1.0
    period = period or 0.3

    end_ = end_ - start

    local p = period
    local s = 0
    local a = 0

    if (val == 0) then
        return start
    end

    val = val / (1/2)

    if (val == 2) then
        return start + end_
    end

    if (a == 0 or a < Mathf.Abs(end_)) then
        a = end_
        s = p / 4
    else
        s = p / (2 * Mathf.PI) * Mathf.Asin(end_ / a)
    end

    if(overshoot>1) then
        if( val<0.2) then
            overshoot = 1 + (val / 0.2 * (overshoot-1))
        elseif( val > 0.8 ) then
            overshoot = 1 + ((1-val) / 0.2 * (overshoot-1))
        end
    end

    if (val < 1) then
        val = val-1
        return start - 0.5 * (a * Mathf.Pow(2, 10 * val) * Mathf.Sin((val - s) * (2 * Mathf.PI) / p)) * overshoot
    end

    val = val-1
    return end_ + start + a * Mathf.Pow(2, -10 * val) * Mathf.Sin((val - s) * (2 * Mathf.PI) / p) * 0.5 * overshoot
end

return TweenUtility