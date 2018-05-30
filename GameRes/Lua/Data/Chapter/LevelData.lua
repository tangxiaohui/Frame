--
-- User: fbmly
-- Date: 4/13/17
-- Time: 8:03 PM
--

require "Object.LuaObject"

local LevelData = Class(LuaObject)

function LevelData:Ctor()
    self.star = 0
end

-----------------------------------------------------------------------
--- 根据不同业务 写的更新函数
-----------------------------------------------------------------------
-- # 对应 FBQueryAllMapResult 协议 直接更新 关卡所有信息 (参数对应 FBItem 类型)
-- # 对应 FBBuyChallengeResult 协议  更新现有的一个关卡信息 (参数对应 FBItem 类型)
-- # 对应 FBOverResult 协议 更新关卡信息 (参数对应 FBItem 类型)
function LevelData:SetAllData(levelData)
    self.id = levelData.fbID
    self.star = math.max(self.star, levelData.star)

    -- 剩余次数
    self.remainingTimes = levelData.done

    -- 购买次数(重置次数?)
    self.buy = levelData.buy

    self.remainOpenTime = levelData.remainOpenTime

    -- 范围检查
    if self.star > 3 then self.star = 3 end
    if self.star < 0 then self.star = 0 end

    --print("新的数据为: ", self.id, self.star, self.remainingTimes, self.buy, self.remainOpenTime)
end

-----------------------------------------------------------------------
--- 获取函数
-----------------------------------------------------------------------
function LevelData:GetId()
    return self.id
end

function LevelData:GetStar()
    return self.star
end

function LevelData:GetBuyTimes()
    return self.buy
end

function LevelData:GetRemainTimes()
    return self.remainingTimes
end

return LevelData


--function LevelData:Print()
--    print('------------------- level -------------------')
--
--    print('id', self:GetId())
--
--    print('star', self:GetStar())
--
--    print('buy times', self:GetBuyTimes())
--
--    print('remain open time', self:GetRemainOpenTime())
--
--    print('remain times', self:GetRemainTimes())
--
--    print('---------------------------------------------')
--end
--
--return LevelData