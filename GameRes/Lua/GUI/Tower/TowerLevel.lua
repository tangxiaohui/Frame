local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
require "LUT.StringTable"

local TowerLevel = Class(BaseNodeClass)
windowUtility.SetMutex(TowerLevel, true)

function  TowerLevel:Ctor()
	
end

function TowerLevel:OnWillShow(level)
	self.level = level
end

function  TowerLevel:OnInit()
	utility.LoadNewGameObjectAsync("UI/Prefabs/TowerLevel",function(go)
		self:BindComponent(go)
	end)
end

function TowerLevel:OnComponentReady()
	self:InitControls()
end

function TowerLevel:OnResume()
	TowerLevel.base.OnResume(self)
	self:FadeIn(function(self, t)
        local transform = self.transform

        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
	self:RegisterControlEvents()
	self:LoadPanel(self.level)
end

function TowerLevel:OnPause()
	TowerLevel.base.OnPause(self)
	self:UnregisterControlEvents()
end

function TowerLevel:OnEnter()
	TowerLevel.base.OnEnter(self)
end

function TowerLevel:OnExit()
	TowerLevel.base.OnExit(self)
end

function TowerLevel:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end

function  TowerLevel:InitControls()
	local transform = self:GetUnityTransform()
	self.transform = transform:Find("Base")

	self.returnButton = self.transform:Find("Base/RetrunButton"):GetComponent(typeof(UnityEngine.UI.Button))
	--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))
	self.headIcon = {}
	self.lvLabel = {}
	self.nameLabel = {}
	self.powerLabel = {}
	self.fightButton = {}
	self.itemIcon = {}
	self.itemNum = {}
	self.itemFrame = {}
	for i=1,3 do
		self.headIcon[i] = self.transform:Find("Level/Level"..i.."/Head/Base/Icon"):GetComponent(typeof(UnityEngine.UI.Image))
		self.lvLabel[i] = self.transform:Find("Level/Level"..i.."/Lv/Text"):GetComponent(typeof(UnityEngine.UI.Text))
		self.nameLabel[i] = self.transform:Find("Level/Level"..i.."/NameLabel"):GetComponent(typeof(UnityEngine.UI.Text))
		self.powerLabel[i] = self.transform:Find("Level/Level"..i.."/PowerLabel"):GetComponent(typeof(UnityEngine.UI.Text))
		self.fightButton[i] = self.transform:Find("Level/Level"..i.."/FightButton"):GetComponent(typeof(UnityEngine.UI.Button))
		self.itemNum[i] = {}
		self.itemIcon[i] = {}
		self.itemFrame[i] = {}
		for j=1,2 do
			self.itemNum[i][j] = self.transform:Find("Level/Level"..i.."/MyGeneralItem"..j.."/GeneralItemNumLabel"):GetComponent(typeof(UnityEngine.UI.Text))
			self.itemIcon[i][j] = self.transform:Find("Level/Level"..i.."/MyGeneralItem"..j.."/ItemIcon"):GetComponent(typeof(UnityEngine.UI.Image))
			self.itemFrame[i][j] = self.transform:Find("Level/Level"..i.."/MyGeneralItem"..j.."/Frame/Image"):GetComponent(typeof(UnityEngine.UI.Image))
		end
		
	end
end

----------------------------------------------------------------------------
--动画处理--
----------------------------------------------------------------------------
function TowerLevel:IsTransition()
    return true
end

-- ## 在这里执行 淡出函数! (immediately 值只针对 WindowNode 及其子类)
function TowerLevel:OnExitTransitionDidStart(immediately)
    TowerLevel.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.transform

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

----------------------------------------------------------------------------
--事件处理--
----------------------------------------------------------------------------
function TowerLevel:RegisterControlEvents()
	--注册退出事件
	self._event_button_onReturnButtonClicked_ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked,self)
	self.returnButton.onClick:AddListener(self._event_button_onReturnButtonClicked_)

	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

	--注册挑战事件
	self._event_button_onRoleChallengeButtonClicked_ = {}
	self.OnRoleChallengeButtonClicked = {}
	self.OnRoleChallengeButtonClicked[1] = self.OnRoleChallengeButton1Clicked
	self.OnRoleChallengeButtonClicked[2] = self.OnRoleChallengeButton2Clicked
	self.OnRoleChallengeButtonClicked[3] = self.OnRoleChallengeButton3Clicked
	for i=1,#self.OnRoleChallengeButtonClicked do
		self._event_button_onRoleChallengeButtonClicked_[i] = UnityEngine.Events.UnityAction(self.OnRoleChallengeButtonClicked[i],self)
		self.fightButton[i].onClick:AddListener(self._event_button_onRoleChallengeButtonClicked_[i])
	end
end

function TowerLevel:UnregisterControlEvents()
	--取消注册退出事件
	if self._event_button_onReturnButtonClicked_ then
		self.returnButton.onClick:RemoveListener(self._event_button_onReturnButtonClicked_)
		self._event_button_onReturnButtonClicked_ = nil
	end

	--取消注册挑战事件
	for i=1,#self._event_button_onRoleChallengeButtonClicked_ do
		if self._event_button_onRoleChallengeButtonClicked_[i] then
			self.fightButton[i].onClick:RemoveListener(self._event_button_onRoleChallengeButtonClicked_[i])
			self._event_button_onRoleChallengeButtonClicked_[i] = nil
		end
	end

	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end
end

function TowerLevel:OnReturnButtonClicked()
	self:Close(true)
end

function TowerLevel:LoadPanel(level)
	local table = self:GetIdTable(level)
	local levelData = require "StaticData.Tower.TowerLevels"
	local gametool = require "Utils.GameTools"
	for i=1,#table do
		local data = levelData:GetData(table[i])
		self.powerLabel[i].text = data:GetTeamPower()
		self.lvLabel[i].text = data:GetMonsterLevel()
		local bossId = data:GetTeamIcon()
		local roleinfoData = require "StaticData.RoleInfo"
		local name = roleinfoData:GetData(bossId):GetName()
		self.nameLabel[i].text = name
		utility.LoadRoleHeadIcon(bossId , self.headIcon[i])
		local itemId = data:GetAwarditem()
		local itemNum = data:GetAwardnum()
		for j=0,itemId.Count - 1 do
			local _,data,_,iconPath,itemType = gametool.GetItemDataById(itemId[j])
			utility.LoadSpriteFromPath(iconPath,self.itemIcon[i][j+1])
			local color = gametool.GetItemColorByType(itemType,data)
			local PropUtility = require "Utils.PropUtility"
 			PropUtility.AutoSetRGBColor(self.itemFrame[i][j+1],color)
 			self.itemNum[i][j+1].text = itemNum[j]
		end
	end
end

function TowerLevel:GetIdTable(level)
	local levelData = require "StaticData.Tower.TowerLevels"
	local keys = levelData:GetKeys()
	local table = {}
	for i=0,keys.Length - 1 do
		local data = levelData:GetData(keys[i])
		if data:GetLevelid() == level then
			table[#table + 1] = keys[i]
		end
	end
	return table
end

function TowerLevel:OnRoleChallengeButton1Clicked()
	self:ChallengeButtonEvent(1)
end

function TowerLevel:OnRoleChallengeButton2Clicked()
	self:ChallengeButtonEvent(2)
end

function TowerLevel:OnRoleChallengeButton3Clicked()
	self:ChallengeButtonEvent(3)
end

function TowerLevel:ChallengeButtonEvent(id)
	-- 判断剩余次数
    -- local UserDataType = require "Framework.UserDataType"
    -- local playerChapterData = self:GetCachedData(UserDataType.PlayerChapterData)
    -- local remainTimes = playerChapterData:GetLevelRemainingTimes(self.levelData:GetChapterId(), self.levelData:GetId())

    -- if remainTimes <= 0 then
    --     utility.ShowErrorDialog(SweepStringTable[5])
    --     return
    -- end

    self:Close(true)
    local table = self:GetIdTable(self.level)
    local ServerService = require "Network.ServerService"
    local net = require "Network.Net"

    local towerData = require "StaticData.Tower.TowerLevels":GetData(table[id])
    local LocalDataType = require "LocalData.LocalDataType"
    local BattleUtility = require "Utils.BattleUtility"

    -- 获取关卡敌人队伍 --
    local foeTeamParameters = BattleUtility.CreateBattleTeamsByTowerLevelID(table[id])

    local battleParams = require "LocalData.Battle.BattleParams".New()

    print("场景ID >>>> ", towerData:GetSceneID())

    battleParams:SetSceneID(towerData:GetSceneID())
    -- TODO : 音乐
    -- battleParams:SetBGM(self.levelData:GetBGM())

    battleParams:SetBattleType(kLineup_TowerAttack)
    battleParams:SetBattleOverLocalDataName(LocalDataType.TowerBattleResult)
    battleParams:SetBattleStartProtocol( ServerService.TowerFightRequest(self.level,id) )
    battleParams:SetBattleResultResponsePrototype( net.S2CTowerFightResult )
    battleParams:SetBattleResultViewClassName("GUI.Tower.TowerBattleResule")
    battleParams:SetMaxBattleRounds(30)
    battleParams:SetBattleResultWhenReachMaxRounds(false)
    battleParams:SetPVPMode(false)
    battleParams:SetSkillRestricted(towerData:GetMapType() == kMapType_SkillRestricted)
    battleParams:SetUnlimitedRage(towerData:GetMapType() == kMapType_UnlimitedRage)

    utility.StartBattle(battleParams, foeTeamParameters, nil)
end



return TowerLevel