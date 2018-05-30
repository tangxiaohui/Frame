require "StaticData.Manager"

local vipInfo = require "StaticData.Vip.VipInfo"

local VipData = Class(LuaObject)

function VipData:Ctor(id)
	local VipMgr = Data.Vip.Manager.Instance()
	self.data = VipMgr:GetObject(id)
	if self.data == nil then
		error(string.format("Vip，ID：%s 不存在",id))
		return
	end
end

function  VipData:GetVip()
	return self.data.vip
end


function  VipData:GetChargeMin()
	return self.data.chargeMin
end

function  VipData:GetBuyTiliLimit()
	return self.data.buyTiliLimit
end

function  VipData:GetBuyCoinLimit()
	return self.data.buyCoinLimit
end

function  VipData:GetBuyJuntuanFbLimit()
	return self.data.buyJuntuanFbLimit
end

function  VipData:GetAddSpeed()
	return self.data.addSpeed
end

function  VipData:GetBuyFoodLimit()
	return self.data.buyFoodLimit
end


function  VipData:GetMaxHeroNum()
	return self.data.maxHeroNum
end

function  VipData:GetAddLeadership()
	return self.data.addLeadership
end

function  VipData:GetBuyBossLimit()
	return self.data.buyBossLimit
end

function  VipData:GetBuyGoldBoxLimit()
	return self.data.buyGoldBoxLimit
end

function  VipData:GetBuyFashionBoxLimit()
	return self.data.buyFashionBoxLimit
end

function  VipData:GetBuyTowerResetLimit()
	return self.data.buyTowerResetLimit
end

function  VipData:GetBuyTowerBossResetLimi()
	return self.data.buyTowerBossResetLimi
end

function  VipData:GetBlackMartEternalOpen()
	return self.data.BlackMartEternalOpen
end

function  VipData:GetPacksID()
	return self.data.packsID
end

function  VipData:GetRespectTimes()
	return self.data.respectTimes
end

function  VipData:GetIntegralWarTimes()
	return self.data.integralWarTimes
end

function  VipData:GetPlunderTimes()
	return self.data.plunderTimes
end

function VipData:GetArenaAlwaysWins()
	return self.data.ArenaAlwaysWins
end

function VipData:GetChengzhangjijin()
	return self.data.Chengzhangjijin
end

function VipData:GetSkipLevel()
	return self.data.skipLevel
end

function VipData:GetBuyTowerBossResetLimit()
	return self.data.buyTowerBossResetLimit
end

function VipData:GetResetDungeonLimit()
	return self.data.resetDungeon
end

function VipData:GetDailyAdventureBuy()
	return self.data.dailyAdventureBuy
end

function VipData:GetArenachallengetimes()
	return self.data.Arenachallengetimes
end

function VipData:GetInfo()
	return self.data.info
end

--获取vip表所有功能左边
function VipData:GetFunctionUnlocked()
	local unlocked = {}
	unlocked[1] = self.data.chargeMin
	unlocked[2] = self.data.addSpeed
	unlocked[3] = self.data.maxHeroNum
	unlocked[4] = self.data.addLeadership
	unlocked[5] = self.data.BlackMartEternalOpen
	unlocked[6] = self.data.packsID
	unlocked[7] = self.data.ArenaAlwaysWins
	unlocked[8] = self.data.Chengzhangjijin
	unlocked[9] = self.data.skipLevel
	unlocked[10] = self.data.skipfight
	unlocked[11] = self.data.skipDaily
	unlocked[12] = self.data.skipFever
	unlocked[13] = self.data.bossauto
	unlocked[14] = self.data.morecoin
	unlocked[15] = self.data.vipdouble

	return unlocked
end

--获取vip表所有限制信息右边
function VipData:GetTimesUnlocked()
	local unlocked = {}
	unlocked[1] = self.data.buyTiliLimit
	unlocked[2] = self.data.buyCoinLimit
	unlocked[3] = self.data.buyJuntuanFbLimit
	unlocked[4] = self.data.buyFoodLimit
	unlocked[5] = self.data.buyBossLimit
	unlocked[6] = self.data.buyGoldBoxLimit
	unlocked[7] = self.data.buyFashionBoxLimit
	unlocked[8] = self.data.buyTowerResetLimit
	unlocked[9] = self.data.buyTowerBossResetLimit
	unlocked[10] = self.data.respectTimes
	unlocked[11] = self.data.integralWarTimes
	unlocked[12] = self.data.plunderTimes
	unlocked[13] = self.data.catconin
	unlocked[14] = self.data.resetDungeon
	unlocked[15] = self.data.dailyAdventureBuy
	unlocked[16] = self.data.dailyCoinStarBuy
	unlocked[17] = self.data.dailyDiaStarBuy
	unlocked[18] = self.data.Arenachallengetimes
	return unlocked
end


local VipDataManager = Class(DataManager)

local VipDataMgr = VipDataManager.New(VipData)

function VipDataMgr:GetKeys()
    return Data.Vip.Manager.Instance():GetKeys()
end

function VipDataMgr:GetBlacketMarketOpenLv()
	local keys = Data.Vip.Manager.Instance():GetKeys()
	local lv = 0
	for i=0,keys.Length - 1 do
		local data = require "StaticData.Vip.Vip":GetData(keys[i])
		if data:GetBlackMartEternalOpen() == 1 then
			lv = keys[i]
			break
		end
	end
	return lv
end

return VipDataMgr