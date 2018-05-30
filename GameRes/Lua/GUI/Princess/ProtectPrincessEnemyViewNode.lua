--
-- User: fenghao
-- Date: 03/07/2017
-- Time: 7:50 PM
--

local BaseNodeClass = require "Framework.Base.Node"
local utility = require "Utils.Utility"
local ServerService = require "Network.ServerService"
local net = require "Network.Net"
require "Collection.OrderedDictionary"
require "Const"

-- 传给阵容界面的包装类 --

--- # 卡牌战斗状态 # ---
local CardRecordItem = Class()

function CardRecordItem:Ctor(cardRecord)
    self.uid = cardRecord.cardUID
    self.anger = cardRecord.anger
    self.hp = cardRecord.hp
    self.hpLimit = cardRecord.hpLimit
end

function CardRecordItem:GetUid()
    return self.uid
end

function CardRecordItem:GetAnger()
    return self.anger
end

function CardRecordItem:GetHp()
    return self.hp
end

function CardRecordItem:GetHpLimit()
    return self.hpLimit
end




local ProtectPrincessEnemyViewNode = Class(BaseNodeClass)

local function InitControls(self)
    local transform = self:GetUnityTransform()

    -- 战斗按钮 --
    self.fightButton = transform:Find("FightButton"):GetComponent(typeof(UnityEngine.UI.Button))

    -- FormationLayout --
    self.formationItemParents = {
        transform:Find("FormationLayout/1"),
        transform:Find("FormationLayout/2"),
        transform:Find("FormationLayout/3"),
        transform:Find("FormationLayout/4"),
        transform:Find("FormationLayout/5"),
        transform:Find("FormationLayout/6"),
    }

    -- 控件列表 --
    local HeroCardItemNodeClass = require "GUI.HeroCardItemNode"
    self.controls = {
        HeroCardItemNodeClass.New(),
        HeroCardItemNodeClass.New(),
        HeroCardItemNodeClass.New(),
        HeroCardItemNodeClass.New(),
        HeroCardItemNodeClass.New(),
        HeroCardItemNodeClass.New()
    }

    -- 空列表控件 --
    self.emptyObjects = {
        transform:Find("FormationLayout/1/Empty").gameObject,
        transform:Find("FormationLayout/2/Empty").gameObject,
        transform:Find("FormationLayout/3/Empty").gameObject,
        transform:Find("FormationLayout/4/Empty").gameObject,
        transform:Find("FormationLayout/5/Empty").gameObject,
        transform:Find("FormationLayout/6/Empty").gameObject,
    }

end

function ProtectPrincessEnemyViewNode:Ctor(transform)
    self:BindComponent(transform.gameObject, false)
    InitControls(self)
end

local function OnProtectCheckEnemyResponse(self, msg)
    self.enemyMsg = msg

    -- TODO : 设置名字 --
    local messageGuids = require "Framework.Business.MessageGuids"
    self:DispatchEvent(messageGuids.ProtectShowInspectorTitle, nil, true, msg.enemyName)

    -- TODO : 设置控件 --
    local enemies = msg.enemys
    local count = math.min(#enemies, #self.controls)

    for i = 1, #self.controls do
        self:RemoveChild(self.controls[i])
    end

    for i = 1, count do
        local currentEnemy = enemies[i]

        -- 不显示空的Item
        self.emptyObjects[currentEnemy.cardPos]:SetActive(false)

        local staticRole = require "StaticData.Role":GetData(currentEnemy.cardID)

        -- 显示英雄卡牌
        local heroCardItemNode = self.controls[currentEnemy.cardPos]
        heroCardItemNode:SetMode(kCardItemMode_Got)
        heroCardItemNode:SetID(currentEnemy.cardID)
        heroCardItemNode:SetLevel(currentEnemy.cardLevel)
        heroCardItemNode:SetColorID(currentEnemy.cardColor)
        heroCardItemNode:SetRaceID((staticRole:GetRace()))
        heroCardItemNode:SetStar(staticRole:GetStar())
		heroCardItemNode:SetRarity(staticRole:GetRarity())
        heroCardItemNode:SetIconName(staticRole:GetHeadIcon())
        heroCardItemNode:SetRequiredFragmentNumber(0)
        heroCardItemNode:SetCurrentFragmentNumber(0)
        heroCardItemNode:SetSelected(false)
        heroCardItemNode:SetParentTransform(self.formationItemParents[currentEnemy.cardPos])
        self:AddChild(heroCardItemNode)
    end

    self:ActiveComponent()
end


local function GetTeam(self)
--    self.enemyMsg
    local BattleUtility = require "Utils.BattleUtility"

    local enemies = self.enemyMsg.enemys

    local units = {}

    for i = 1, #enemies do
        local currentEnemyInfo = enemies[i]
        local unitParameter = BattleUtility.CreateStaticBattleUnitParameter(currentEnemyInfo.cardID, currentEnemyInfo.cardColor, currentEnemyInfo.cardLevel, currentEnemyInfo.stage, nil, currentEnemyInfo.cardPos)
        units[#units + 1] = unitParameter
    end

    return BattleUtility.CreateBattleTeams(units)
end

local function OnFightButtonClicked(self)
    if self.enemyMsg == nil then
        return
    end
	
	if self.protectMsg == nil then
		return
	end

    print("开始战斗!!!")

    local foeTeams = GetTeam(self)

    local LocalDataType = require "LocalData.LocalDataType"
    local battleParams = require "LocalData.Battle.BattleParams".New()
    battleParams:SetSceneID(2)
    battleParams:SetBattleType(kLineup_Protect)
    -- battleParams:DisableManuallyOperation()
    battleParams:SetBattleOverLocalDataName(LocalDataType.ProtectBattleResult)
    battleParams:SetBattleStartProtocol( ServerService.ProtectStartFightRequest(self.enemyMsg.gate) )
    battleParams:SetBattleResultResponsePrototype( net.S2CProtectStartFightResult )
    battleParams:SetBattleResultViewClassName( "GUI.BattleResults.ProtectFightingResultModule" )
    battleParams:SetMaxBattleRounds(30)
    battleParams:SetBattleResultWhenReachMaxRounds(false)
    battleParams:SetPVPMode(true)
    battleParams:SetSkillRestricted(false)
    battleParams:SetUnlimitedRage(false)

    local formation = utility.StartBattle(battleParams, foeTeams, nil)

    -- @ 己方卡牌状态字典 --
    local dict = OrderedDictionary.New()
    for i = 1, #self.protectMsg.selfCardRecord do
        local cardItem = CardRecordItem.New(self.protectMsg.selfCardRecord[i])
        dict:Add(cardItem:GetUid(), cardItem)
    end
    formation:SetPrivateArgs(dict, self.protectMsg.gyjInfo)
end

function ProtectPrincessEnemyViewNode:OnResume()
    self:GetGame():RegisterMsgHandler(net.S2CProtectCheckEnemyResult, self, OnProtectCheckEnemyResponse)

    -- 注册 开始战斗 --
    self.__event_fightButtonClicked__ = UnityEngine.Events.UnityAction(OnFightButtonClicked, self)
    self.fightButton.onClick:AddListener(self.__event_fightButtonClicked__)

end

function ProtectPrincessEnemyViewNode:OnPause()
    self:GetGame():UnRegisterMsgHandler(net.S2CProtectCheckEnemyResult, self, OnProtectCheckEnemyResponse)

    -- 取消注册 开始战斗 --
    if self.__event_fightButtonClicked__ then
        self.fightButton.onClick:RemoveListener(self.__event_fightButtonClicked__)
        self.__event_fightButtonClicked__ = nil
    end

end

function ProtectPrincessEnemyViewNode:Show(msg)
    print("显示敌人界面 >>>>")
    self:ActiveComponent()

    self.protectMsg = msg

    local msg, prototype = ServerService.CheckProtectEnemyRequest(msg.curGate)
    self:GetGame():SendNetworkMessage(msg, prototype)
end

function ProtectPrincessEnemyViewNode:Close()
    self:InactiveComponent()

    self.protectMsg = nil

    for i = 1, #self.controls do
        self:RemoveChild(self.controls[i])
    end

    for i = 1, #self.emptyObjects do
        self.emptyObjects[i]:SetActive(true)
    end
end

return ProtectPrincessEnemyViewNode
