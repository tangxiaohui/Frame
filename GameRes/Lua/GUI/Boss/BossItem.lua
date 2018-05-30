local BaseNodeClass = require "Framework.Base.UIScene"
local utility = require "Utils.Utility"
local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local BossItemCls = Class(BaseNodeClass)
require "System.LuaDelegate"
function BossItemCls:Ctor(bossData,parent,maxKey,table,callback)

	self.bossData=bossData
	self.parent=parent
	self.maxKey=maxKey
	self.table=table
	debug_print(bossData,parent,maxKey,callback)
	if callback ~=nil then
		debug_print(self.callBack)
        self.callBack=LuaDelegate.New()
        self.callBack:Set(table, callback)
        debug_print(self.callBack)
    end

end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function BossItemCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/BossItem', function(go)
		self:BindComponent(go)
	end)
end

function BossItemCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
	self:LinkComponent(self.parent, true)

end

function BossItemCls:OnResume()
	-- 界面显示时调用
	BossItemCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:ScheduleUpdate(self.Update)
end

function BossItemCls:OnPause()
	-- 界面隐藏时调用
	BossItemCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function BossItemCls:OnEnter()
	-- Node Enter时调用
	BossItemCls.base.OnEnter(self)
end

function BossItemCls:OnExit()
	-- Node Exit时调用
	BossItemCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function BossItemCls:InitControls()
	local transform = self:GetUnityTransform()
	self.Frame = transform:Find('Frame'):GetComponent(typeof(UnityEngine.UI.Image))
	self.icon = transform:Find('Head/Base/Icon'):GetComponent(typeof(UnityEngine.UI.Image))
	--self.Frame1 = transform:Find('Head/Frame'):GetComponent(typeof(UnityEngine.UI.Image))
	--self.Image = transform:Find('Lv/Image'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Text = transform:Find('Lv/Text'):GetComponent(typeof(UnityEngine.UI.Text))
	self.NameLabel = transform:Find('NameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.PowerLabel = transform:Find('PowerLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.BattleButton = transform:Find('BattleButton'):GetComponent(typeof(UnityEngine.UI.Button))

	self.fill = transform:Find('Bar/Fill'):GetComponent(typeof(UnityEngine.UI.Image))
	self.hpLabel=transform:Find('HpLabel'):GetComponent(typeof(UnityEngine.UI.Text))

	self.Image2 = transform:Find('Bar/Fill'):GetComponent(typeof(UnityEngine.UI.Image))

	self.hurtMax = transform:Find('Rank1/Rank1Label'):GetComponent(typeof(UnityEngine.UI.Text))
	self.mineHurt = transform:Find('SelfRank/SelfRankLabel'):GetComponent(typeof(UnityEngine.UI.Text))

	--transform:SetParent(self.parent)
	self:InitViews()
end
function  BossItemCls:Update()
	if  self.flagTime then
		if os.time()-self.lastT>=1 then
			self.lastT=os.time()
			self.countTime=self.countTime-1
		end

		if self.countTime <= 0 then
			self.flagTime=false
			self:InactiveComponent()		
		else
			self.PowerLabel.text=utility.ConvertTime(self.countTime)

		end

	end

end
function  BossItemCls:InitViews()
	local WorldBossLevelData = require "StaticData.Boss.WorldBossLevel":GetData(self.bossData.bossId)
	self.bossID = WorldBossLevelData:GetBossID()
	-- self.bossInfo=WorldBossLevelData:GetInfo()
	local bossType = WorldBossLevelData:GetBossIndexByLevel(self.bossData.bossLevel)
	local _,_,_,_,_,_,bossID,bossColor,bosslevel = WorldBossLevelData:GetBossDataByIndex(bossType)
	--关卡ID
	self.bosslevel=bosslevel

	self.shareID=self.bossData.sharerId
	--LV

	self.Text.text=self.bossData.bossLevel


	local roleMgr = require "StaticData.Role"
    local roleData = roleMgr:GetData(bossID)
    self.NameLabel.text=roleData:GetInfo()
    --倒计时
	self.PowerLabel.text=self.bossData.validTime

	--血量
	self.hpLabel.text=self.bossData.hp..'/'..self.bossData.maxHp

	self.fill.fillAmount=self.bossData.hp/self.bossData.maxHp


	self.hurtMax.text = self.bossData.maxHit
	self.mineHurt.text =self.bossData.myHit
	utility.LoadRoleHeadIcon(bossID, self.icon)
	self.countTime=self.bossData.validTime/1000
	self.flagTime=true
	self.lastT=0

end


function BossItemCls:RegisterControlEvents()
	-- 注册 BattleButton 的事件
	self.__event_button_onBattleButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBattleButtonClicked, self)
	self.BattleButton.onClick:AddListener(self.__event_button_onBattleButtonClicked__)

end

function BossItemCls:UnregisterControlEvents()
	-- 取消注册 BattleButton 的事件
	if self.__event_button_onBattleButtonClicked__ then
		self.BattleButton.onClick:RemoveListener(self.__event_button_onBattleButtonClicked__)
		self.__event_button_onBattleButtonClicked__ = nil
	end

end

function BossItemCls:RegisterNetworkEvents()
end

function BossItemCls:UnregisterNetworkEvents()
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function BossItemCls:OnBattleButtonClicked()

	--  debug_print("BossItemCls开始挑战！！！*****************************")
 --    local BattleUtility = require "Utils.BattleUtility"
 -- 	local LocalDataType = require "LocalData.LocalDataType"
 --    local ServerService = require "Network.ServerService"


 --    debug_print(self.bossTeamID,"  HHHHHHHHHHHHHHHHHHHHHHH",self.bosslevel)
	-- local foeTeams = BattleUtility.CreateBattleTeamsByLevelID(self.bosslevel)

	-- local WorldBossData = require "StaticData.Boss.WorldBoss":GetData(1)

	-- local sceneID= WorldBossData:GetSceneId()
 --    local battleParams = require "LocalData.Battle.BattleParams".New()
	-- battleParams:SetSceneID(sceneID)
	-- battleParams:SetScriptID(nil)
	-- battleParams:SetBattleType(kLineup_JourneyToExplore4)	
	-- battleParams:SetBattleOverLocalDataName(LocalDataType.BossBattleResult)
	
	-- battleParams:SetBattleStartProtocol(ServerService.WBossFightEndRequest(1,self.bossData.sharerId))

	-- battleParams:SetBattleResultResponsePrototype(net.S2CWBossFightEndResult)

	-- battleParams:SetRightApRate(100)

	-- battleParams:SetBattleResultViewClassName("GUI.Boss.ElvenTreeBattleResult")
	-- battleParams:SetMaxBattleRounds(10)
	-- battleParams:SetBattleResultWhenReachMaxRounds(false)
	-- battleParams:SetPVPMode(true)
	-- battleParams:DisableManuallyOperation()
	-- battleParams:SetSkillRestricted(false)
	-- battleParams:SetUnlimitedRage(false)

	-- --设置boss的血量
	-- BattleUtility.SetCustomHpParameterInTeam(foeTeams[1], 5, tonumber(self.bossData.hp), tonumber(self.bossData.maxHp))


	-- local formation =  utility.StartBattle(battleParams, foeTeams, nil,function( attackRate,isThreeType,hp,maxHp )
		
	-- 	debug_print(isThreeType,hp,maxHp," ----------------")
	-- 	battleParams:SetRightApRate(attackRate)
	-- 	battleParams:SetBattleStartProtocol(ServerService.WBossFightEndRequest(isThreeType,self.bossData.sharerId))

	-- 	BattleUtility.SetCustomHpParameterInTeam(foeTeams[1], 5, tonumber(hp), tonumber(maxHp))
	-- end)
	-- debug_print("开始挑战 参数设置成功",self.bossData.sharerId)
	-- formation:SetBossID(self.bossData.sharerId)
 -- 	formation:SetBossKey(self.maxKey)
 -- 	if self.callBack== nil then

 -- 		debug_print("self.callBack")

 -- 	end
 	self.callBack:Invoke(self.table,self.bossData,self.bosslevel)
end

return BossItemCls
