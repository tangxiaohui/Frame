require "Game.Role"
local utility = require "Utils.Utility"

UserData = Class(LuaObject)

function UserData:Ctor()
	self.baseInfo = {}
end

local function GetUserId(uid)
	return tonumber(utility.SplitNew(uid,":",true)[2])
end

local function IsLevelUp(oldLevel, newLevel)
	return type(oldLevel) == "number" and type(newLevel) == "number" and oldLevel < newLevel
end

function UserData:SetBaseInfo(baseInfo)
	-- # 基本信息

	-- uid
	if self.baseInfo.uid ~= baseInfo.playerUID then
		self.baseInfo.uid = baseInfo.playerUID
		self.baseInfo.id = GetUserId(baseInfo.playerUID)
	end

	-- name
	if self.baseInfo.name ~= baseInfo.playerName then
		self.baseInfo.name = baseInfo.playerName
	end

	-- level
	self.isLevelUp = IsLevelUp(self.baseInfo.level, baseInfo.level)
	if self.baseInfo.level ~= baseInfo.level then
		self.baseInfo.level = baseInfo.level
	end
	

	-- diamond
	if self.baseInfo.diamond ~= baseInfo.diamond then
		self.baseInfo.diamond = baseInfo.diamond
	end

	-- coin
	if self.baseInfo.coin ~= baseInfo.coin then
		self.baseInfo.coin = baseInfo.coin
	end
	
	-- vigor
	if self.baseInfo.vigor ~= baseInfo.tili then
		self.baseInfo.vigor = baseInfo.tili
	end

	-- maxVigor
	if self.baseInfo.maxVigor ~= baseInfo.tili_full then
		self.baseInfo.maxVigor = baseInfo.tili_full
	end

	-- vip
	if self.baseInfo.vip ~= baseInfo.vip then
		self.baseInfo.vip = baseInfo.vip
	end

	-- exp
	if self.baseInfo.exp ~= baseInfo.exp then
		self.baseInfo.exp = baseInfo.exp
	end
	
	-- prestige
	if self.baseInfo.prestige ~= baseInfo.shengwang then
		self.baseInfo.prestige = baseInfo.shengwang
	end

	--gonghuiID
	if self.baseInfo.gonghuiID ~= baseInfo.gonghuiID then
		self.baseInfo.gonghuiID = baseInfo.gonghuiID
	end

	-- headCardID
	if self.baseInfo.headCardID ~= baseInfo.headCardID then
		self.baseInfo.headCardID = baseInfo.headCardID
	end

	-- protectCoin
	if self.baseInfo.princessCoin ~= baseInfo.protectCoin then
		self.baseInfo.princessCoin = baseInfo.protectCoin
	end

	-- shengwang
	if self.baseInfo.shengwang ~= baseInfo.shengwang then
		print(baseInfo.shengwang ,"----------baseInfo.shengwang -------")
		self.baseInfo.shengwang = baseInfo.shengwang
	end
	
	-- ghfcoin
	if self.baseInfo.ghfcoin ~= baseInfo.ghfcoin then
		self.baseInfo.ghfcoin = baseInfo.ghfcoin
	end
	
	-- sevenDayHappy
	if self.baseInfo.sevenDayHappy ~= baseInfo.sevenDayHappy then
		self.baseInfo.sevenDayHappy = baseInfo.sevenDayHappy
	end
	
		-- isShowOnline
	if self.baseInfo.isShowOnline ~= baseInfo.isShowOnline then
		-- print(baseInfo.isShowOnline ,"----------baseInfo.shengwang -------")
		self.baseInfo.isShowOnline = baseInfo.isShowOnline
	end

	

	if self.baseInfo.gonghuiCoin ~= baseInfo.gonghuiCoin then
		-- if self.baseInfo.gonghuiCoin~=nil and baseInfo.gonghuiCoin>self.baseInfo.gonghuiCoin then
			-- local item = {}
			-- item.id = 10410007
			-- item.count = baseInfo.gonghuiCoin-self.baseInfo.gonghuiCoin
			-- item.color = 0
			-- local items = {}
			-- items[1] = item
			-- utility:GetGame():GetWindowManager():Show(require "GUI.Task.GetAwardItem",items)
		-- end
		self.baseInfo.gonghuiCoin = baseInfo.gonghuiCoin
	end

	if self.baseInfo.gonghuiName ~= baseInfo.gonghuiName then
		self.baseInfo.gonghuiName = baseInfo.gonghuiName
	end

	if self.baseInfo.remainBuyTiliCount ~= baseInfo.remainBuyTiliCount then
		self.baseInfo.remainBuyTiliCount = baseInfo.remainBuyTiliCount
	end

	if self.baseInfo.remainBuyCoinCount ~= baseInfo.remainBuyCoinCount then
		self.baseInfo.remainBuyCoinCount = baseInfo.remainBuyCoinCount
	end

	if self.baseInfo.remainBuyCoinCount ~= baseInfo.remainBuyCoinCount then
		self.baseInfo.remainBuyCoinCount = baseInfo.remainBuyCoinCount
	end

	if self.baseInfo.alreadyBuyTiliCount ~= baseInfo.alreadyBuyTiliCount then
		self.baseInfo.alreadyBuyTiliCount = baseInfo.alreadyBuyTiliCount
	end

	if self.baseInfo.alreadyBuyCoinCount ~= baseInfo.alreadyBuyCoinCount then
		self.baseInfo.alreadyBuyCoinCount = baseInfo.alreadyBuyCoinCount
	end
		-- shouchongState
	if self.baseInfo.shouchongState ~= baseInfo.shouchongState then
		print(baseInfo.shouchongState ,"----------baseInfo.shouchongState -------")
		self.baseInfo.shouchongState = baseInfo.shouchongState
	end

	if self.baseInfo.awardInfo ~= baseInfo.awardInfo then
		self.baseInfo.awardInfo = baseInfo.awardInfo
	end

	if self.baseInfo.createTime ~= baseInfo.createTime then
		self.baseInfo.createTime = baseInfo.createTime
	end

	if self.baseInfo.levelUpTime ~= baseInfo.levelUpTime then
		self.baseInfo.levelUpTime = baseInfo.levelUpTime
	end
	
	if self.baseInfo.towerCoin ~= baseInfo.towerCoin then
		self.baseInfo.towerCoin = baseInfo.towerCoin
	end
	if self.baseInfo.choukaCoin ~= baseInfo.choukaCoin then
		self.baseInfo.choukaCoin = baseInfo.choukaCoin
	end
	if self.baseInfo.happyTurnMusicJiFenCoin ~= baseInfo.happyTurnMusicJiFenCoin then
		self.baseInfo.happyTurnMusicJiFenCoin = baseInfo.happyTurnMusicJiFenCoin
	end
	if self.baseInfo.happyTurnMusicIsOpen ~= baseInfo.happyTurnMusicIsOpen then
		self.baseInfo.happyTurnMusicIsOpen = baseInfo.happyTurnMusicIsOpen
	end

	if self.baseInfo.godOpen ~= baseInfo.godOpen then
		self.baseInfo.godOpen = baseInfo.godOpen
	end

	if self.baseInfo.treeLevel ~= baseInfo.treeLevel then
		self.baseInfo.treeLevel = baseInfo.treeLevel
	end

	debug_print(self.baseInfo.treeLevel,"self.baseInfo.treeLevel")
end

function UserData:GetRoles()
	return self.roles
end

function UserData:ToString()
	print('UserData')
end

-- 获取基本信息函数
function UserData:GetUid()
	return self.baseInfo.uid
end

function UserData:GetId()
	return self.baseInfo.id
end

function UserData:GetName()
	return self.baseInfo.name
end

function UserData:IsLevelUp()
	return self.isLevelUp
end

function UserData:GetLevel()
	return self.baseInfo.level
end

function UserData:GetDiamond()
	return self.baseInfo.diamond
end

function UserData:GetCoin()
	return tonumber(self.baseInfo.coin)
end

function UserData:GetVigor()
	return self.baseInfo.vigor
end

function UserData:GetMaxVigor()
	return self.baseInfo.maxVigor
end

function UserData:GetVip()
	return self.baseInfo.vip
end

function UserData:GetExp()
	return self.baseInfo.exp
end

function UserData:GetPrestige()
	return self.baseInfo.prestige
end

function UserData:GetGonghuiID()
	return self.baseInfo.gonghuiID
end

function UserData:GetPrincessCoin()
	return self.baseInfo.princessCoin
end

function UserData:GetHeadCardID()
	return self.baseInfo.headCardID
end

function UserData:GetShengwang()
	return self.baseInfo.shengwang
end

function UserData:GetIsShowOnline()
	return self.baseInfo.isShowOnline
end

function UserData:GetGonghuiCoin()
	return self.baseInfo.gonghuiCoin
end

function UserData:GetRemainBuyTiliCount()
	return self.baseInfo.remainBuyTiliCount
end

function UserData:GetRemainBuyCoinCount()
	return self.baseInfo.remainBuyCoinCount
end

function UserData:GetAlreadyBuyCoinCount()
	return self.baseInfo.alreadyBuyCoinCount
end

function UserData:GetAlreadyBuyTiliCount()
	return self.baseInfo.alreadyBuyTiliCount
end

function UserData:GetGonghuiName()
	return self.baseInfo.gonghuiName
end

function UserData:GetGuildNameToDisplay()
	if type(self.baseInfo.gonghuiName) == "string" and self.baseInfo.gonghuiName:len() > 0 then
		return self.baseInfo.gonghuiName
	end
	return "无帮派"
end

function UserData:GetGhfcoin()
	return self.baseInfo.ghfcoin
end

function UserData:GetSevenDayHappy()
	return self.baseInfo.sevenDayHappy
end

--是否领取首冲
function UserData:GetFirstChargeAward()
	return self.baseInfo.awardInfo
end

--是否首冲
function UserData:GetPayState()
	return self.baseInfo.shouchongState
end

function UserData:GetCreateTime()
	return self.baseInfo.createTime
end

function UserData:GetLastLevelUpTime()
	return self.baseInfo.levelUpTime
end

function UserData:GetTowerCoin()
	return self.baseInfo.towerCoin
end
--抽卡积分
function UserData:GetChoukaCoin()
	return self.baseInfo.choukaCoin
end
function UserData:GetHappyTurnMusicJiFenCoin()
	return self.baseInfo.happyTurnMusicJiFenCoin
end
function UserData:GetHappyTurnMusicIsOpen()
	return self.baseInfo.happyTurnMusicIsOpen
end
function UserData:GetGodOpenIsOpen()
	return self.baseInfo.godOpen
end

function UserData:GetTreeLevel()
	return self.baseInfo.treeLevel
end

--	optional int32  = 1;
--	optional int64  = 2;
--	optional int32  = 3;
--	optional int32  = 4;
--	optional int32  = 5;
--	optional int32  = 6;
--	optional int32 zhanli = 7;
--	optional string  = 8;
--	optional string  = 9;
--	optional int32  = 10;
--	optional int32  = 11;
--	optional int32 protectCoin = 12;
--	optional int32 headCardID = 13;
--	optional int32 headCardColor = 14;
--	optional int32 gonghuiID = 15;
--	optional string gonghuiName = 16;
--	optional int32 remainBuyTiliCount = 17;
--	optional int32 remainBuyCoinCount = 18;
--	optional int32 gonghuiCoin = 19;
--	optional bool isShowSevenDay=20;
--	optional string chargeArg=21;
--	optional int32 captainAwakenID=22;
--	optional int32 guozhanCoin=23;
--	optional int32 remainBuyFoodCount =24;
--	optional bool isShowOnline=25;
--	optional int32 towerCoin=26;
--	optional int32 prayCoin=27;
--end