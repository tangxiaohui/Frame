--
-- User: fenghao
-- Date: 30/06/2017
-- Time: 8:30 AM
--

local BaseNodeClass = require "Framework.Base.Node"
local BattleResultDataNode = Class(BaseNodeClass)
require "Collection.OrderedDictionary"

local BattleResultDataUnitNodeClass = require "GUI.Modules.ChapterBattleResult.BattleResultDataUnitNode"

local function InitControls(self)
    local transform = self:GetUnityTransform()

    print("transform name :", transform.name, "CardDamage1:", transform:Find("Layout1/CardDamage1"))

    -- 友军
    self.friendUnits = {
        BattleResultDataUnitNodeClass.New(transform:Find("Layout1/CardDamage1")),
        BattleResultDataUnitNodeClass.New(transform:Find("Layout1/CardDamage2")),
        BattleResultDataUnitNodeClass.New(transform:Find("Layout1/CardDamage3")),
        BattleResultDataUnitNodeClass.New(transform:Find("Layout1/CardDamage4")),
        BattleResultDataUnitNodeClass.New(transform:Find("Layout1/CardDamage5")),
        BattleResultDataUnitNodeClass.New(transform:Find("Layout1/CardDamage6")),
    }

    -- 敌军
    self.enemyUnits = {
        BattleResultDataUnitNodeClass.New(transform:Find("Layout2/CardDamage1")),
        BattleResultDataUnitNodeClass.New(transform:Find("Layout2/CardDamage2")),
        BattleResultDataUnitNodeClass.New(transform:Find("Layout2/CardDamage3")),
        BattleResultDataUnitNodeClass.New(transform:Find("Layout2/CardDamage4")),
        BattleResultDataUnitNodeClass.New(transform:Find("Layout2/CardDamage5")),
        BattleResultDataUnitNodeClass.New(transform:Find("Layout2/CardDamage6")),
    }

    self.returnButton = transform:Find("returnButton"):GetComponent(typeof(UnityEngine.UI.Button))
end

local function OnReturnButtonClicked(self)
    local messageGuids = require "Framework.Business.MessageGuids"
    self:DispatchEvent(messageGuids.BattleResultDataBackButton, nil)
end

function BattleResultDataNode:Ctor(transform)
    self:BindComponent(transform.gameObject, false)
    InitControls(self)
end

function BattleResultDataNode:OnResume()
    self.__event_button_returnButtonClicked__ = UnityEngine.Events.UnityAction(OnReturnButtonClicked, self)
    self.returnButton.onClick:AddListener(self.__event_button_returnButtonClicked__)
end

function BattleResultDataNode:OnPause()
    if self.__event_button_returnButtonClicked__ then
        self.returnButton.onClick:RemoveListener(self.__event_button_returnButtonClicked__)
        self.__event_button_returnButtonClicked__ = nil
    end
end

function BattleResultDataNode:Show()
    self:ActiveComponent()
end

function BattleResultDataNode:Close()
    self:InactiveComponent()
end


local function InitDamageData(controlUnits, team, damageDataInfos, maxDamageValue)
--    print("队伍:", team, "伤害信息:", damageDataInfos)

    -- 先初始化 --
    for i = 1, #controlUnits do
        controlUnits[i]:Close()
    end

    -- 构造字典 --
    local damageDict = OrderedDictionary.New()
    for i = 1, #damageDataInfos do
        damageDict:Add(damageDataInfos[i].pos, damageDataInfos[i].totalDamages)
    end

    -- 初始化 --
    local members = team:GetMembers()
    for i = 1, 6 do
        local battleUnit = members[i]
        if battleUnit ~= nil then
            controlUnits[i]:Show(battleUnit, damageDict:GetEntryByKey(i), maxDamageValue)
        end
    end

end

local function CalcMaxDamageValue(playerDamageDatas, enemyDamageDatas)
    local maxDamageValue = 0

    for i = 1, #playerDamageDatas do
        maxDamageValue = math.max(maxDamageValue, math.floor(playerDamageDatas[i].totalDamages))
    end

    for i = 1, #enemyDamageDatas do
        maxDamageValue = math.max(maxDamageValue, math.floor(enemyDamageDatas[i].totalDamages))
    end

    return maxDamageValue
end

-- 设置数据 --
function BattleResultDataNode:SetData(owner)
    local battlefield = owner:GetBattlefield()
    local leftTeam = battlefield:GetLeftTeam()
    local rightTeam = battlefield:GetRightTeam()
    local battleRecordMessage = owner:GetLastBattleRecordMessage()
    if battleRecordMessage == nil then
        return
    end

    print("最后波次", battlefield:GetWaveNumber(), #battleRecordMessage.damageResultData.enemyDamageWaveData)

    local maxDamageValue = CalcMaxDamageValue(battleRecordMessage.damageResultData.playerDamageData, battleRecordMessage.damageResultData.enemyDamageWaveData[battlefield:GetWaveNumber()])

    InitDamageData(self.friendUnits, rightTeam, battleRecordMessage.damageResultData.playerDamageData, maxDamageValue)
    InitDamageData(self.enemyUnits, leftTeam, battleRecordMessage.damageResultData.enemyDamageWaveData[battlefield:GetWaveNumber()].infos, maxDamageValue)

--    print("@@@@>>> 队伍获取 --", leftTeam, rightTeam, battleRecordMessage)
end

return BattleResultDataNode
