local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local ElvenTreeSnatchPlayerCls = Class(BaseNodeClass)
require "System.LuaDelegate"
function ElvenTreeSnatchPlayerCls:Ctor(parent,info)
	self.Parent=parent
	self.info=info
	self.callback = LuaDelegate.New()
	--print(type(self.callback),self.info.playerUID,"PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP")

end
function ElvenTreeSnatchPlayerCls:SetCallback(table,func)
	--print(type(self.callback),type(func))
 	self.table=table
    self.callback:Set(self.table,func)
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function ElvenTreeSnatchPlayerCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/ElvenTreeSnatchPlayer', function(go)
		self:BindComponent(go)
	end)
end

function ElvenTreeSnatchPlayerCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function ElvenTreeSnatchPlayerCls:OnResume()
	-- 界面显示时调用
	ElvenTreeSnatchPlayerCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self.EnemyTeamTable = {}
	self:InitViews()


end

function ElvenTreeSnatchPlayerCls:OnPause()
	-- 界面隐藏时调用
	ElvenTreeSnatchPlayerCls.base.OnPause(self)
	self:UnregisterControlEvents()
	
	self:UnregisterNetworkEvents()
end
------------------网络事件注册----------------------------------------
function ElvenTreeSnatchPlayerCls:RegisterNetworkEvents()
	utility:GetGame():RegisterMsgHandler(net.S2CCheckPlayerCardWithEquipResult, self, self.OnCheckPlayerCardWithEquipResult)
end

function ElvenTreeSnatchPlayerCls:UnregisterNetworkEvents()
	utility:GetGame():UnRegisterMsgHandler(net.S2CCheckPlayerCardWithEquipResult, self, self.OnCheckPlayerCardWithEquipResult)
end

function ElvenTreeSnatchPlayerCls:OnEnter()
	-- Node Enter时调用
	ElvenTreeSnatchPlayerCls.base.OnEnter(self)
end

function ElvenTreeSnatchPlayerCls:OnExit()
	-- Node Exit时调用
	ElvenTreeSnatchPlayerCls.base.OnExit(self)
end
function ElvenTreeSnatchPlayerCls:InitViews()

	hzj_print("*************",self.info.repairBoxID,self.info.playerLevel,self.info.playerName,self.info.playerUID,self.info.totalZhanli,self.info.canRob,self.info.cards,self.info.headID,self.info.headColor,self.info.gonghuiName)
	string.find("元字符串","模式字符串")
	-- body
--	print(self.info.playerLevel,"************")
	self.ElvenTreeSnatchPlayerLvNumLabel.text=self.info.playerLevel
	self.ElvenTreeSnatchPlayerNameLabel.text=self.info.playerName
	self.ElvenTreeSnatchPlayerStrengthNumLabel.text=self.info.totalZhanli

	local GameTools = require "Utils.GameTools"
	local AtlasesLoader = require "Utils.AtlasesLoader"
    local infoData,data,_,iconPath,itemType = GameTools.GetItemDataById(self.info.repairBoxID)
    --  print("^^^^^^^^^^",data:GetColorID())
    -- print("^^^^^^^^^^",infoData:GetColorID())

    -- 设置图标
	utility.LoadSpriteFromPath(iconPath,self.ElvenTreeSnatchPlayerItemIcon)

	
 
    local defaultColor = GameTools.GetItemColorByType(itemType, data)


    local PropUtility = require "Utils.PropUtility"   
    print(self.info.cardColor)

 	PropUtility.AutoSetRGBColor(self.GeneralItemFarme, self.info.cardColor or defaultColor)
	
	--表示是NPC
	if string.find(self.info.playerUID,"npc") ~=nil then
		self.npc=true
	else

		for i=1,#self.info.cards do
			local mod =math.floor( self.info.cards[i].cardID/10000)
			if self.info.cards[i].cardPos ~= 5 then
			hzj_print("self.info.cards[i].cardID",self.info.cards[i].cardID)
				utility:GetGame():SendNetworkMessage( require"Network/ServerService".OnCheckPlayerCardWithEquipRequest(self.info.playerUID,self.info.cards[i].cardID))
			else
				teamFivepos = {}
				local BattleUtility = require "Utils.BattleUtility"

		   	 	local teamFivepos =BattleUtility.CreateStaticBattleUnitParameter(self.info.cards[i].cardID,self.info.cards[i].cardColor,self.info.cards[i].cardLevel, self.info.cards[i].cardStage,nil ,self.info.cards[i].cardPos)
				self.EnemyTeamTable[#self.EnemyTeamTable + 1]=teamFivepos
			end
		end
		self.npc=false
	end

	
end
---临时 构建装备列表
local function SetEquipList(role,equipTable)
	require "Collection.OrderedDictionary"
	local dict = OrderedDictionary.New()
	for i = 1 ,#equipTable do

		local equip = equipTable[i]
		local uid = string.format("%s%s",equip.id,i)
		local fakeEquipData = require "Data.EquipBag.EquipData".New()
        fakeEquipData:UpdateData{
        equipUID = uid,
        equipID = equip.id,
        level = equip.level,
        pos = equip.pos,
        bindCardUID = "",
        onWhichCard = "",
        exp = 0,
        color = equip.color,
        stoneID = {equip.gemId},
        stoneUID = ""
        }
        dict:Add(uid,fakeEquipData)
	end
	role:SetEquipDataList(dict)
end
function ElvenTreeSnatchPlayerCls:OnCheckPlayerCardWithEquipResult(msg)
	local BattleUtility = require "Utils.BattleUtility"
	hzj_print(msg.card.id,msg.card.uid,self.info.playerUID)
--	卡牌装备查询
	
	local role = Role.New()
	role:Update(msg.card)
	SetEquipList(role,msg.equips)
	local rolePos = msg.card.pos[kLineup_ElvenTree+1]
--	hzj_print("role,rolePos",role,rolePos)
	self.EnemyTeamTable[#self.EnemyTeamTable + 1] = BattleUtility.CreateBattleUnitParameter(role,rolePos)
	

	-- if self.currAcceptRoleCount == self.maxAcceptRoleCount then
	-- 	local windowManager = self.myGame:GetWindowManager()
 --   		windowManager:Show(require "GUI.Formation.ArenaEnemyFormation",nil,self.msg.playerSimpleInfo[self.selectedEnemyId].items,self.zhanli,self.SelectCardInArenaFight,self)
 --   		self.currAcceptRoleCount = 0
	-- end
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function ElvenTreeSnatchPlayerCls:InitControls()
	local transform = self:GetUnityTransform()
	self.game=utility.GetGame()
	
	--人物头像
	self.ElvenTreeSnatchPlayerItemIcon = transform:Find('Item/ElvenTreeSnatchPlayerItemIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	--边框颜色父物体
	self.GeneralItemFarme = transform:Find('Item/Frame')
	-- self.GeneralItemFarme01 = transform:Find('Item/Farme/GeneralItemFarme01'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.GeneralItemFarme02 = transform:Find('Item/Farme/GeneralItemFarme02'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.GeneralItemFarme03 = transform:Find('Item/Farme/GeneralItemFarme03'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.GeneralItemFarme04 = transform:Find('Item/Farme/GeneralItemFarme04'):GetComponent(typeof(UnityEngine.UI.Image))
	--self.LvImage = transform:Find('Lv/LvImage'):GetComponent(typeof(UnityEngine.UI.Image))
	--等级Text
	self.ElvenTreeSnatchPlayerLvNumLabel = transform:Find('Lv/ElvenTreeSnatchPlayerLvNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--名字Text
	self.ElvenTreeSnatchPlayerNameLabel = transform:Find('Name/ElvenTreeSnatchPlayerNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--战力Text
	self.ElvenTreeSnatchPlayerStrengthNumLabel = transform:Find('Strength/ElvenTreeSnatchPlayerStrengthNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--抢夺按钮
	self.ElvenTreeSnatchPlayerButton = transform:Find('ElvenTreeSnatchPlayerButton'):GetComponent(typeof(UnityEngine.UI.Button))

	transform:SetParent(self.Parent)
	--self:InitViews()

end


function ElvenTreeSnatchPlayerCls:RegisterControlEvents()
	-- 注册 ElvenTreeSnatchPlayerButton 的事件
	self.__event_button_onElvenTreeSnatchPlayerButtonClicked__ = UnityEngine.Events.UnityAction(self.OnElvenTreeSnatchPlayerButtonClicked, self)
	self.ElvenTreeSnatchPlayerButton.onClick:AddListener(self.__event_button_onElvenTreeSnatchPlayerButtonClicked__)
end

function ElvenTreeSnatchPlayerCls:UnregisterControlEvents()
	-- 取消注册 ElvenTreeSnatchPlayerButton 的事件
	if self.__event_button_onElvenTreeSnatchPlayerButtonClicked__ then
		self.ElvenTreeSnatchPlayerButton.onClick:RemoveListener(self.__event_button_onElvenTreeSnatchPlayerButtonClicked__)
		self.__event_button_onElvenTreeSnatchPlayerButtonClicked__ = nil
	end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function ElvenTreeSnatchPlayerCls:SelectCardInArenaFight()

	
	-- 挑战选择阵容
	print("挑战选择阵容！！！")
	local sceneManager = self:GetGame():GetSceneManager()
    local FormationCls = require "GUI.Formation.Formation"
    sceneManager:PushScene(FormationCls.New(kLineup_Attack,self.StartArenaFight,self))
end


function ElvenTreeSnatchPlayerCls:StartArenaFight()
	-- 开始挑战

	hzj_print("开始挑战！！！*****************************")
    local BattleUtility = require "Utils.BattleUtility"

    local sceneManager = self:GetGame():GetSceneManager()
    local BattleSceneClass = require "Scenes.BattleScene"

    local teamTable = {}
    if self.npc == true then
	   	local teamArgs = {}
	   	for i=1,#self.itemInfo do
	   		teamArgs[i] = {}
	   	 	teamArgs[i].cardID = self.itemInfo[i].cardID
	   	 	teamArgs[i].cardColor = self.itemInfo[i].cardColor
	   	 	teamArgs[i].cardLevel = self.itemInfo[i].cardLevel
	   	 	teamArgs[i].cardPos = self.itemInfo[i].cardPos
	   	 	teamArgs[i].cardStage = self.itemInfo[i].cardStage

	   	 end    	
	   	-- 挑战阵型
	   	local lineupType = kLineup_Attack
	    
	    for i=1,#teamArgs do
	    --	print("***",teamArgs[i].cardID)
	    	teamTable[#teamTable + 1] = BattleUtility.CreateStaticBattleUnitParameter(teamArgs[i].cardID,teamArgs[i].cardColor,teamArgs[i].cardLevel, teamArgs[i].cardStage,nil ,teamArgs[i].cardPos)
	    end  

    elseif self.npc == false then
    	teamTable= self.EnemyTeamTable
    end

    local foeTeams = BattleUtility.CreateBattleTeams(teamTable)

   local LocalDataType = require "LocalData.LocalDataType" 
    local ServerService = require "Network.ServerService"

    local BattleUtility = require "Utils.BattleUtility"

    --local foeTeams = self:GetFoeTeam()

    local battleParams = require "LocalData.Battle.BattleParams".New()
	battleParams:SetSceneID(2)
	battleParams:SetScriptID(nil)
	battleParams:SetBattleType(kLineup_Attack)
	battleParams:SetBattleOverLocalDataName(LocalDataType.ElvenBattleResult)
	battleParams:SetBattleStartProtocol(ServerService.RobFightRequest(self.info.playerUID))
	battleParams:SetBattleResultResponsePrototype(net.S2CRobFightResult)
	battleParams:SetBattleResultViewClassName("GUI.ElvenTree.ElvenTreeBattleResult")
	battleParams:SetMaxBattleRounds(30)
	battleParams:SetBattleResultWhenReachMaxRounds(false)
	battleParams:SetPVPMode(true)
	battleParams:DisableManuallyOperation()
	battleParams:SetSkillRestricted(false)
	battleParams:SetUnlimitedRage(false)

	utility.StartBattle(battleParams, foeTeams, nil)
	self.EnemyTeamTable={}



    -- print(self.info.playerUID,type(self.info.playerUID))
    -- local battleStartParams = require "LocalData.BattleStartParams".New()
    -- battleStartParams:SetBattleResultLocalDataName(LocalDataType.ElvenBattleResult)
    -- battleStartParams:SetBattleRecordProtocol(ServerService.RobFightRequest(self.info.playerUID))
    -- battleStartParams:SetBattleResultResponse(net.S2CRobFightResult)
    -- battleStartParams:SetBattleResultViewHANDLEClassName("GUI.Challenge.ChallengFightResult")
    -- utility.StartBattle(kLineup_Attack, battleStartParams, foeTeams)

end


local function CheckFormationCount(self)
	local UserDataType = require "Framework.UserDataType"
	local cardBagData = self:GetCachedData(UserDataType.CardBagData)
	
	local ArenaDefenceCount = cardBagData:GetTroopCount(kLineup_ElvenTree)
	if ArenaDefenceCount <=1 then
		utility.ShowErrorDialog("防守阵容不能为空，请先设置防守阵容")
		return false
	end
	return true
end
function ElvenTreeSnatchPlayerCls:OnElvenTreeSnatchPlayerButtonClicked()
	--ElvenTreeSnatchPlayerButton控件的点击事件处理
		if not CheckFormationCount(self) then
		return
	end

 	print("点击抢夺按钮")
	self.itemInfo ={}
	print(self.info)
	for i=1,#self.info.cards do
		self.itemInfo[i] = {}
		self.itemInfo[i].cardID=self.info.cards[i].cardID
		self.itemInfo[i].cardColor=self.info.cards[i].cardColor
		self.itemInfo[i].cardLevel=self.info.cards[i].cardLevel
		self.itemInfo[i].cardPos=self.info.cards[i].cardPos
		self.itemInfo[i].cardStage=self.info.cards[i].stage
		self.itemInfo[i].sparColor=self.info.cards[i].sparColor

		print(self.info.cards[i].cardID
		,self.info.cards[i].cardColor
		,self.info.cards[i].cardLevel
		,self.info.cards[i].cardPos
		,self.info.cards[i].stage
		,self.info.cards[i].sparColor)
	end

	local windowManager = self.game:GetWindowManager()
    windowManager:Show(require "GUI.Formation.ArenaEnemyFormation",nil,self.itemInfo,self.info.totalZhanli,self.StartArenaFight,self)
	self.callback:Invoke(self.table)

end

return ElvenTreeSnatchPlayerCls

