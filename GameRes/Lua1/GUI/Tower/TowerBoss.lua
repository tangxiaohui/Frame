local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local net = require "Network.Net"
require "LUT.StringTable"

local TowerBoss = Class(BaseNodeClass)
windowUtility.SetMutex(TowerBoss, true)

function  TowerBoss:Ctor()
	
end

function TowerBoss:OnWillShow(levelBoss,maxBossId,count,resetTimes)
	self.maxBossId = maxBossId
	self.id = levelBoss
	
	if levelBoss ~= 0 then
		if maxBossId ~= 0 then
			if levelBoss > maxBossId then
				if levelBoss - 1 == maxBossId then
					self.maxLevelBoss = levelBoss
				else
					self.maxLevelBoss = maxBossId + 1
				end
			else
				self.maxLevelBoss = math.min(maxBossId,levelBoss)
			end
		else
			self.maxLevelBoss = 1
		end
	else
		self.maxLevelBoss = 0
	end
	self.index = self.maxLevelBoss
	if self.index == 0 then
		self.index = 1
	end
	self.count = count
	self.resetTimes = resetTimes
end

function  TowerBoss:OnInit()
	utility.LoadNewGameObjectAsync("UI/Prefabs/TowerBoss",function(go)
		self:BindComponent(go)
	end)
end

function TowerBoss:OnComponentReady()
	self:InitControls()
end

function TowerBoss:OnResume()
	TowerBoss.base.OnResume(self)
	self:FadeIn(function(self, t)
        local transform = self.transform

        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:LoadPanel(self.index)
	self:LoadTimes(self.count,self.resetTimes)
end

function TowerBoss:OnPause()
	TowerBoss.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function TowerBoss:OnEnter()
	TowerBoss.base.OnEnter(self)
end

function TowerBoss:OnExit()
	TowerBoss.base.OnExit(self)
end

function TowerBoss:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end

function  TowerBoss:InitControls()
	local transform = self:GetUnityTransform()
	self.transform = transform:Find("Base")

	self.returnButton = transform:Find("Base/Base/RetrunButton"):GetComponent(typeof(UnityEngine.UI.Button))
	self.bossPortrait = self.transform:Find("BossPortrait/Portrait"):GetComponent(typeof(UnityEngine.UI.Image))
	self.lvNum = self.transform:Find("BossPortrait/Lvnum"):GetComponent(typeof(UnityEngine.UI.Text))
	self.nameLabel = self.transform:Find("BossPortrait/NameBase/NameLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.rightButton = self.transform:Find("BossPortrait/RightButton"):GetComponent(typeof(UnityEngine.UI.Button))
	self.leftButton = self.transform:Find("BossPortrait/LeftButton"):GetComponent(typeof(UnityEngine.UI.Button))
	self.infoLabel = self.transform:Find("BossInfo/Base/InfoLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.timesLabel = self.transform:Find("TimesLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.resetTimesLabel = self.transform:Find("ResetTimesLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.resetButton = self.transform:Find("ResetButton"):GetComponent(typeof(UnityEngine.UI.Button))
	self.fightButton = self.transform:Find("FightButton"):GetComponent(typeof(UnityEngine.UI.Button))
	self.itemParent = self.transform:Find("BossInfo/Award/ItemLayout")
	if self.maxLevelBoss >= self.index then
		self.fightButton.transform:GetComponent(typeof(UnityEngine.UI.Image)).material = utility:GetCommonMaterial()
	else
		self.fightButton.transform:GetComponent(typeof(UnityEngine.UI.Image)).material = utility:GetGrayMaterial()
	end

	--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))
end

----------------------------------------------------------------------------
--动画处理--
----------------------------------------------------------------------------
function TowerBoss:IsTransition()
    return true
end

-- ## 在这里执行 淡出函数! (immediately 值只针对 WindowNode 及其子类)
function TowerBoss:OnExitTransitionDidStart(immediately)
    TowerBoss.base.OnExitTransitionDidStart(self, immediately)

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
function TowerBoss:RegisterControlEvents()
	--注册退出事件
	self._event_button_onReturnButtonClicked_ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked,self)
	self.returnButton.onClick:AddListener(self._event_button_onReturnButtonClicked_)
	--注册rightButton事件
	self._event_button_onRightButtonClicked_ = UnityEngine.Events.UnityAction(self.OnRightButtonClicked,self)
	self.rightButton.onClick:AddListener(self._event_button_onRightButtonClicked_)
	--注册leftButton事件
	self._event_button_onLeftButtonClicked_ = UnityEngine.Events.UnityAction(self.OnLeftButtonClicked,self)
	self.leftButton.onClick:AddListener(self._event_button_onLeftButtonClicked_)
	--注册重置事件
	self._event_button_onResetButtonClicked_ = UnityEngine.Events.UnityAction(self.OnResetButtonClicked,self)
	self.resetButton.onClick:AddListener(self._event_button_onResetButtonClicked_)
	--注册战斗事件
	self._event_button_onFightButtonClicked_ = UnityEngine.Events.UnityAction(self.OnFightButtonClicked,self)
	self.fightButton.onClick:AddListener(self._event_button_onFightButtonClicked_)
	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

end

function TowerBoss:UnregisterControlEvents()
	--取消注册退出事件
	if self._event_button_onReturnButtonClicked_ then
		self.returnButton.onClick:RemoveListener(self._event_button_onReturnButtonClicked_)
		self._event_button_onReturnButtonClicked_ = nil
	end
	--取消注册rightButton事件
	if self._event_button_onRightButtonClicked_ then
		self.rightButton.onClick:RemoveListener(self._event_button_onRightButtonClicked_)
		self._event_button_onRightButtonClicked_ = nil
	end
	--取消注册leftButton事件
	if self._event_button_onLeftButtonClicked_ then
		self.leftButton.onClick:RemoveListener(self._event_button_onLeftButtonClicked_)
		self._event_button_onLeftButtonClicked_ = nil
	end
	--取消注册重置事件
	if self._event_button_onResetButtonClicked_ then
		self.resetButton.onClick:RemoveListener(self._event_button_onResetButtonClicked_)
		self._event_button_onResetButtonClicked_ = nil
	end
	--取消注册战斗事件
	if self._event_button_onFightButtonClicked_ then
		self.fightButton.onClick:RemoveListener(self._event_button_onFightButtonClicked_)
		self._event_button_onFightButtonClicked_ = nil
	end
	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end
end

function TowerBoss:RegisterNetworkEvents()
	utility.GetGame():RegisterMsgHandler(net.S2CBuyBossResetCountResult,self,self.BuyBossResetCountResult)
end

function TowerBoss:UnregisterNetworkEvents()
	utility.GetGame():UnRegisterMsgHandler(net.S2CBuyBossResetCountResult,self,self.BuyBossResetCountResult)
end

function TowerBoss:BuyBossResetCountRequest()
	self:GetGame():SendNetworkMessage(require "Network.ServerService".BuyBossResetCountRequest())
end

function TowerBoss:BuyBossResetCountResult(msg)
	local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    local playerVip = userData:GetVip()
    local vipData = require "StaticData.Vip.Vip":GetData(playerVip)

	local count = vipData:GetBuyTowerBossResetLimit() - msg.alreayBuyBossCount
	self.count = msg.surplusCount
	self.resetTimes = count

	self:LoadTimes(msg.surplusCount, self.resetTimes)
end

function TowerBoss:OnReturnButtonClicked()
	self:Close(true)
end

function TowerBoss:OnResetButtonClicked()
	local windowManager = utility:GetGame():GetWindowManager()
	if self.resetTimes <= 0 then
		windowManager:Show(require "GUI.Dialogs.ErrorDialog", "重置次数不足")
	else
	    local str = string.format("剩余%d次重置机会，是否确定重置", self.resetTimes)
	    local ConfirmDialogClass = require "GUI.Dialogs.ConfirmDialog"
	    windowManager:Show(ConfirmDialogClass, str, self, self.BuyBossResetCountRequest)
	end
end

function TowerBoss:OnFightButtonClicked()
	if self.maxLevelBoss >= self.index  then
		self:BossBattleFight(self.index)
	end
end

function TowerBoss:OnRightButtonClicked()
	self.index = self.index + 1
	self:SetFightButton()
end

function TowerBoss:OnLeftButtonClicked()
	self.index = self.index - 1
	self:SetFightButton()
end

function TowerBoss:SetFightButton()
	self:LoadPanel(self.index)
	if self.maxLevelBoss >= self.index then
		self.fightButton.transform:GetComponent(typeof(UnityEngine.UI.Image)).material = utility:GetCommonMaterial()
	else
		self.fightButton.transform:GetComponent(typeof(UnityEngine.UI.Image)).material = utility:GetGrayMaterial()
	end
end

--加载界面
function TowerBoss:LoadPanel(id)
	local keys = Data.TowerBoss.Manager.Instance():GetKeys()
	if id <= 0 then
		id = keys[keys.Length - 1]
	elseif id > keys.Length then
		id = keys[0]
	end
	self.index = id
	local bossData = require "StaticData.Tower.TowerBoss":GetData(id)
	local bossId = bossData:GetTeamPortrait()
	self.lvNum.text = bossData:GetMonsterLevel()
	local roleData = require "StaticData.Role":GetData(bossId)
	local iconName = roleData:GetId()
	utility.LoadRolePortraitImage(iconName,self.bossPortrait)
	local roleinfoData = require "StaticData.RoleInfo"
	local name = roleinfoData:GetData(bossId):GetName()
	self.nameLabel.text = name
	self.infoLabel.text = roleinfoData:GetData(bossId):GetDesc()
	self:LoadAward(id,self.maxBossId)
end

function TowerBoss:LoadTimes(count,resetTimes)
	self.timesLabel.text = count
	self.resetTimesLabel.text = resetTimes
end

function TowerBoss:LoadAward(id,maxBossId)
	self:RemoveAll()
	local nodeCls = require "GUI.Active.ActiveAwardItem"
	local gametool = require "Utils.GameTools"
	self.node = {}
	local table = self:GetItemTable(id,maxBossId)
	for i=1,#table do
		local _,data,_,_,itype = gametool.GetItemDataById(table[i].id)
        color = gametool.GetItemColorByType(itype,data)
        self.node[i] = nodeCls.New(self.itemParent,table[i].id,table[i].num,color,false)
		self:AddChild(self.node[i])
	end
end

function TowerBoss:GetItemTable(id,maxBossId)
	local table = {}
	local bossData = require "StaticData.Tower.TowerBoss":GetData(id)
	table[1] = {}
	table[1].id = bossData:GetAwarditem()
	table[1].num = bossData:GetAwardnum()
	if maxBossId ~= nil then
		if id > maxBossId then
			table[2] = {}
			table[2].id = bossData:GetFirstitem()
			table[2].num = bossData:GetFirstnum()
		end
	else
		table[2] = {}
		table[2].id = bossData:GetFirstitem()
		table[2].num = bossData:GetFirstnum()
	end
	return table
end

function TowerBoss:RemoveAll()
	if self.node ~= nil then
		for i=1,#self.node do
			self:RemoveChild(self.node[i],true)
		end
	end
end

function TowerBoss:BossBattleFight(id)
	-- 判断剩余次数
	if self.count <= 0 then 
		local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
        local windowManager = self:GetGame():GetWindowManager()
        windowManager:Show(ErrorDialogClass, "挑战次数不足")
		return
	end
	if self.maxLevelBoss >= id then
    -- local UserDataType = require "Framework.UserDataType"
    -- local playerChapterData = self:GetCachedData(UserDataType.PlayerChapterData)
    -- local remainTimes = playerChapterData:GetLevelRemainingTimes(self.levelData:GetChapterId(), self.levelData:GetId())

    -- if remainTimes <= 0 then
    --     utility.ShowErrorDialog(SweepStringTable[5])
    --     return
    -- end

    self:Close(true)
    local ServerService = require "Network.ServerService"
    local net = require "Network.Net"

    local towerData = require "StaticData.Tower.TowerBoss":GetData(id)
    local LocalDataType = require "LocalData.LocalDataType"
    local BattleUtility = require "Utils.BattleUtility"

    -- 获取关卡敌人队伍 --
    local foeTeamParameters = BattleUtility.CreateBattleTeamsByBossLevelID(id)

    local battleParams = require "LocalData.Battle.BattleParams".New()


    battleParams:SetSceneID(9)
    -- TODO : 音乐
    -- battleParams:SetBGM(self.levelData:GetBGM())

    battleParams:SetBattleType(kLineup_TowerBossAttack)
    battleParams:SetBattleOverLocalDataName(LocalDataType.TowerBossBattleResult)
    battleParams:SetBattleStartProtocol( ServerService.BossFightRequest(id) )
    battleParams:SetBattleResultResponsePrototype( net.S2CBossFightResult )
    battleParams:SetBattleResultViewClassName("GUI.Tower.TowerBattleResule")
    battleParams:SetMaxBattleRounds(30)
    battleParams:SetBattleResultWhenReachMaxRounds(false)
    battleParams:SetPVPMode(false)
    -- battleParams:SetSkillRestricted(towerData:GetMapType() == kMapType_SkillRestricted)
    -- battleParams:SetUnlimitedRage(towerData:GetMapType() == kMapType_UnlimitedRage)

    utility.StartBattle(battleParams, foeTeamParameters, nil)
else
	local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
        local windowManager = self:GetGame():GetWindowManager()
        windowManager:Show(ErrorDialogClass, "请先挑战等级更低的BOSS来解锁该BOSS！")
end
end

return TowerBoss