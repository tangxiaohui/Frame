local BaseNodeClass = require "Framework.Base.UIScene"
local utility = require "Utils.Utility"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"
require "LUT.StringTable"
require "Const"
require "Collection.OrderedDictionary"


local AllPanelEnumState = 1
local LiPanelEnumState 	= 2
local MinPanelEnumState = 3
local ZhiPanelEnumState = 4
local GYJPanelEnumState = 5

-- button 选中颜色
local ButtonSelectedImageColor = UnityEngine.Color(1,1,1,1)
local ButtonNormalImageColor = UnityEngine.Color(0.537254,0.537254,0.537254,1)
---------------------------------------------------------------------
local FormationCls = Class(BaseNodeClass)

function FormationCls:Ctor(fType,func,arg)
	-- 阵容类型
	self.fType = fType

	-- 确定/战斗 按钮方法
	utility.ASSERT(type(func) == "function","参数func类型需为function")
	self.func = func
	self.arg = arg
end


-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function FormationCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/Formation', function(go)
		self:BindComponent(go)
	end)
end

function FormationCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
	self:LoadCardData()
	self:LoadOnFormation()
	self:RefreshFormationNodeState()
end

function FormationCls:OnResume()
	-- 界面显示时调用
	FormationCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self.power=0
	-- 雇佣军
	self:LoadGYJFormation()

	self:AddObserver()
	self:SwitchPanelCtrl(AllPanelEnumState)


	local guideMgr = utility.GetGame():GetGuideManager()
	guideMgr:AddGuideEvnt(kGuideEvnt_FormationTips)
	guideMgr:AddGuideEvnt(kGuideEvnt_Formation_Set1stHero)
	guideMgr:AddGuideEvnt(kGuideEvnt_Formation_Set2ndHero)
	guideMgr:AddGuideEvnt(kGuideEvnt_Formation_Set3rdHero)
	guideMgr:AddGuideEvnt(kGuideEvnt_Formation_AttrTips)
	guideMgr:AddGuideEvnt(kGuideEvnt_Formation_StrTips)
	guideMgr:AddGuideEvnt(kGuideEvnt_Formation_AgiTips)
	guideMgr:AddGuideEvnt(kGuideEvnt_Formation_IntTips)
	guideMgr:AddGuideEvnt(kGuideEvnt_Formation2Fight)
	guideMgr:AddGuideEvnt(kGuideEvnt_2ndFBLevelFight)
	guideMgr:AddGuideEvnt(kGuideEvnt_3rdFBLevelFight)
	guideMgr:SortGuideEvnt()
	guideMgr:ShowGuidance()

	
end

function FormationCls:OnPause()
	-- 界面隐藏时调用
	FormationCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
	self:RemoveObserver()
	self:OnPanelStateExit(self.CurrPanelState)
end

function FormationCls:OnEnter()
	-- Node Enter时调用
	FormationCls.base.OnEnter(self)
end

function FormationCls:OnExit()
	-- Node Exit时调用
	FormationCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function FormationCls:InitControls()
	local transform = self:GetUnityTransform()
	self.transform = transform
	--self.BigBaseBase = transform:Find('BigBase/BigBaseBase'):GetComponent(typeof(UnityEngine.UI.Image))
	--self.FrameBelow = transform:Find('BigBase/FrameBelow'):GetComponent(typeof(UnityEngine.UI.Image))
	--self.FrameAbove = transform:Find('BigBase/FrameAbove'):GetComponent(typeof(UnityEngine.UI.Image))
	--self.RidBase = transform:Find('RidBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ArenaReturnButton = transform:Find('ArenaReturnButton'):GetComponent(typeof(UnityEngine.UI.Button))
	--self.BlackStripes = transform:Find('Title/BlackStripes'):GetComponent(typeof(UnityEngine.UI.Image))
	
	
	self.HeroLayout = transform:Find('HeroList/HeroLayout'):GetComponent(typeof(UnityEngine.UI.ScrollRect))
	self.ArenaRankSingularStrengthNumLabel = transform:Find('Strength/ArenaRankSingularStrengthNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--self.TitelText = transform:Find('BackRowTitle/TitelText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.FormationFightButton = transform:Find('ButtonList/FormationFightButton'):GetComponent(typeof(UnityEngine.UI.Button))
	------------------------------------------------------------------------------
	self.FormationAllHeroButton = transform:Find('BookmarkButtonList/5/FormationAllHeroButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.FormationPowerButton = transform:Find('BookmarkButtonList/4/FormationPowerButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.FormationAgileButton = transform:Find('BookmarkButtonList/3/FormationAgileButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.FormationIntelligenceButton = transform:Find('BookmarkButtonList/2/FormationIntelligenceButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.FormationMercenariesButton = transform:Find('BookmarkButtonList/1/FormationMercenariesButton'):GetComponent(typeof(UnityEngine.UI.Button))

	self.ButtonCheckList = {self.FormationMercenariesButton,self.FormationIntelligenceButton,self.FormationAgileButton,self.FormationPowerButton,self.FormationAllHeroButton}
	
	----
	local originalButtonParent = transform:Find('BookmarkButtonList')
	local parent_1 = originalButtonParent:Find('1')
	local parent_2 = originalButtonParent:Find('2')
	local parent_3 = originalButtonParent:Find('3')
	local parent_4 = originalButtonParent:Find('4')
	local parent_5 = originalButtonParent:Find('5')
	self.originalButtonParentList = {parent_1,parent_2,parent_3,parent_4,parent_5}
	self.tatgetButtonParent = transform:Find('ButtonFrame')

	self.FormationLayout = transform:Find('HeroList/HeroLayout/HeroLayoutViewport/HeroLayoutContent')
	self.HeroGridLayout = self.FormationLayout:GetComponent(typeof(UnityEngine.UI.GridLayoutGroup))
	self.OnFormationLayout = transform:Find('FormationHeroLayout')
	self.GridLayout = self.OnFormationLayout:GetComponent(typeof(UnityEngine.UI.GridLayoutGroup))

	self.myGame = utility:GetGame()
	-- 卡牌列表
	self.HeroCardList = {}
	-- 卡牌字典
	self.BagCardDict = OrderedDictionary.New()
	-- 力
	self.LiCardDict = OrderedDictionary.New()
	-- 敏
	self.MinCardDict = OrderedDictionary.New()
	-- 智力
	self.ZhiCardDict = OrderedDictionary.New()
	-- 雇佣军
	self.GYJCardDict = OrderedDictionary.New()

	-- 阵容node字典
	self.FormationNodeDict  = OrderedDictionary.New()
	-- 阵容node位置字典
	self.FormationNodePostionDict = OrderedDictionary.New()
	-- 阵容状态字典
	self.FormationStateDict = OrderedDictionary.New()
	-- -- 上阵列表组件
	self.OnFomationList =  {}

	self.FightingPower = 0

	self.fightButtonImage = self.FormationFightButton:GetComponent(typeof(UnityEngine.UI.Image))
	self.fightButtonSprite = self.fightButtonImage.sprite
	self.ConfrimButtonSprite = transform:Find('ConfrimButtonImage'):GetComponent(typeof(UnityEngine.UI.Image)).sprite
	self.buttonMaskImage = transform:Find('ButtonList/FormationFightButton/UI_shuaguang/Mask'):GetComponent(typeof(UnityEngine.UI.Image))

	if self.fType == kLineup_Protect then
	 	self.FormationMercenariesButton.gameObject:SetActive(true)
   	else
   		self.FormationMercenariesButton.gameObject:SetActive(false)
   	end

   	--- 设置图标
   	if self.fType == kLineup_ArenaDefence or self.fType == kLineup_ElvenTree or self.fType == kLineup_GuildPointDefence then
   		self.fightButtonImage.sprite = self.ConfrimButtonSprite
   		self.buttonMaskImage.sprite = self.ConfrimButtonSprite
   	else
   		self.fightButtonImage.sprite = self.fightButtonSprite
   		self.buttonMaskImage.sprite = self.fightButtonSprite
   	end	
   	self.buttonMaskImage:SetNativeSize()
   	self.nodeScrollRect = transform:Find('HeroList/HeroLayout'):GetComponent(typeof(UnityEngine.UI.ScrollRect))
   	self.nodeScrollRect.enabled = false

   	self.toggle=transform:Find('Toggle'):GetComponent(typeof(UnityEngine.UI.Toggle))
   	self.toggle.isOn=false
   	if self.fType ~= kLineup_JourneyToExplore4 then
		self.toggle.transform.gameObject:SetActive(false)
   	end

   	-- 正在发送中的ID
   	self.WaitServerPutOnIdDict = OrderedDictionary.New()
   	self.WaitServerPutOffIdDict = OrderedDictionary.New()
end


function FormationCls:RegisterControlEvents()
	-- 注册 ArenaReturnButton 的事件
	self.__event_button_onArenaReturnButtonClicked__ = UnityEngine.Events.UnityAction(self.OnArenaReturnButtonClicked, self)
	self.ArenaReturnButton.onClick:AddListener(self.__event_button_onArenaReturnButtonClicked__)

	-- 注册 FormationAllHeroButton 的事件
	self.__event_button_onFormationAllHeroButtonClicked__ = UnityEngine.Events.UnityAction(self.OnFormationAllHeroButtonClicked, self)
	self.FormationAllHeroButton.onClick:AddListener(self.__event_button_onFormationAllHeroButtonClicked__)

	-- 注册 FormationPowerButton 的事件
	self.__event_button_onFormationPowerButtonClicked__ = UnityEngine.Events.UnityAction(self.OnFormationPowerButtonClicked, self)
	self.FormationPowerButton.onClick:AddListener(self.__event_button_onFormationPowerButtonClicked__)

	-- 注册 FormationAgileButton 的事件
	self.__event_button_onFormationAgileButtonClicked__ = UnityEngine.Events.UnityAction(self.OnFormationAgileButtonClicked, self)
	self.FormationAgileButton.onClick:AddListener(self.__event_button_onFormationAgileButtonClicked__)

	-- 注册 FormationIntelligenceButton 的事件
	self.__event_button_onFormationIntelligenceButtonClicked__ = UnityEngine.Events.UnityAction(self.OnFormationIntelligenceButtonClicked, self)
	self.FormationIntelligenceButton.onClick:AddListener(self.__event_button_onFormationIntelligenceButtonClicked__)

	-- 注册 FormationMercenariesButton 的事件
	self.__event_button_onFormationMercenariesButtonClicked__ = UnityEngine.Events.UnityAction(self.OnFormationMercenariesButtonClicked, self)
	self.FormationMercenariesButton.onClick:AddListener(self.__event_button_onFormationMercenariesButtonClicked__)

	-- 注册 FormationFightButton 的事件
	self.__event_button_onFormationFightButtonClicked__ = UnityEngine.Events.UnityAction(self.OnFormationFightButtonClicked, self)
	self.FormationFightButton.onClick:AddListener(self.__event_button_onFormationFightButtonClicked__)
	-- 注册 Toggle 事件
	self.__event_button_onToggleArmorValueChanged__ = UnityEngine.Events.UnityAction_bool(self.OnToggleClicked, self)
	self.toggle.onValueChanged:AddListener(self.__event_button_onToggleArmorValueChanged__)

end

function FormationCls:UnregisterControlEvents()


	-- 取消注册 toggle 的事件
	if self.__event_button_onToggleArmorValueChanged__ then
		self.toggle.onValueChanged:RemoveListener(self.__event_button_onToggleArmorValueChanged__)
		self.__event_button_onToggleArmorValueChanged__ = nil
	end


	-- 取消注册 ArenaReturnButton 的事件
	if self.__event_button_onArenaReturnButtonClicked__ then
		self.ArenaReturnButton.onClick:RemoveListener(self.__event_button_onArenaReturnButtonClicked__)
		self.__event_button_onArenaReturnButtonClicked__ = nil
	end

	-- 取消注册 FormationAllHeroButton 的事件
	if self.__event_button_onFormationAllHeroButtonClicked__ then
		self.FormationAllHeroButton.onClick:RemoveListener(self.__event_button_onFormationAllHeroButtonClicked__)
		self.__event_button_onFormationAllHeroButtonClicked__ = nil
	end

	-- 取消注册 FormationPowerButton 的事件
	if self.__event_button_onFormationPowerButtonClicked__ then
		self.FormationPowerButton.onClick:RemoveListener(self.__event_button_onFormationPowerButtonClicked__)
		self.__event_button_onFormationPowerButtonClicked__ = nil
	end

	-- 取消注册 FormationAgileButton 的事件
	if self.__event_button_onFormationAgileButtonClicked__ then
		self.FormationAgileButton.onClick:RemoveListener(self.__event_button_onFormationAgileButtonClicked__)
		self.__event_button_onFormationAgileButtonClicked__ = nil
	end

	-- 取消注册 FormationIntelligenceButton 的事件
	if self.__event_button_onFormationIntelligenceButtonClicked__ then
		self.FormationIntelligenceButton.onClick:RemoveListener(self.__event_button_onFormationIntelligenceButtonClicked__)
		self.__event_button_onFormationIntelligenceButtonClicked__ = nil
	end

	-- 取消注册 FormationMercenariesButton 的事件
	if self.__event_button_onFormationMercenariesButtonClicked__ then
		self.FormationMercenariesButton.onClick:RemoveListener(self.__event_button_onFormationMercenariesButtonClicked__)
		self.__event_button_onFormationMercenariesButtonClicked__ = nil
	end

	-- 取消注册 FormationFightButton 的事件
	if self.__event_button_onFormationFightButtonClicked__ then
		self.FormationFightButton.onClick:RemoveListener(self.__event_button_onFormationFightButtonClicked__)
		self.__event_button_onFormationFightButtonClicked__ = nil
	end
end
-----------------------------------------------------------------------
function FormationCls:RegisterNetworkEvents()
	self.myGame:RegisterMsgHandler(net.S2CPutOnZhenrongResult, self, self.OnPutOnZhenrongResponse)
	self.myGame:RegisterMsgHandler(net.S2CPutOffZhenrongResult, self, self.OnPutOffZhenrongResponse)
	self.myGame:RegisterMsgHandler(net.S2CZhenrongInnerChangeResult, self, self.OnZhenrongInnerChangeResponse)
	self.myGame:RegisterMsgHandler(net.S2CProtectGyjQueryResult, self, self.OnProtectGyjQueryResponse)
	self.myGame:RegisterMsgHandler(net.S2CProtectUseGyjResult, self, self.OnProtectUseGyjResponse)
	self.myGame:RegisterMsgHandler(net.S2CZhenrongAdjustResult, self, self.OnZhenrongAdjustResponse)
	self.myGame:RegisterMsgHandler(net.S2CWBossFightStartResult, self, self.WBossFightStartResult)

end

function FormationCls:UnregisterNetworkEvents()
	self.myGame:UnRegisterMsgHandler(net.S2CPutOnZhenrongResult, self, self.OnPutOnZhenrongResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CPutOffZhenrongResult, self, self.OnPutOffZhenrongResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CZhenrongInnerChangeResult, self, self.OnZhenrongInnerChangeResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CProtectGyjQueryResult, self, self.OnProtectGyjQueryResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CProtectUseGyjResult, self, self.OnProtectUseGyjResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CZhenrongAdjustResult, self, self.OnZhenrongAdjustResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CWBossFightStartResult, self, self.WBossFightStartResult)
end
-----------------------------------------------------------------------
local function ContainsValue(dict,compareValue)
	local keys = dict:GetKeys()
	for i = 1 ,#keys do
		local key = keys[i]
		local value = dict:GetEntryByKey(key)
		if value == compareValue then
			return true
		end
	end
	return false
end

local function AddToDict(dict,key,value)
	local result = ContainsValue(dict,value)
	if not result then
		local contain = dict:Contains(key)
		if not contain then
			dict:Add(key,value)
		end
	end
end

local function GetDictContains(dict,key)
	return dict:Contains(key)
end

local function GetDictCount(dict)
	return dict:Count()
end

local function DeletedDictByKey(dict,key)
	if GetDictContains(dict,key) then
		dict:Remove(key)
	end
end

function FormationCls:OnPutCardOnLineup(uid,fType,pos)
	-- 上阵 请求
	if pos <= self.MaxCardOn then
		AddToDict(self.WaitServerPutOnIdDict,pos,uid)
		self.myGame:SendNetworkMessage( require"Network/ServerService".PutCardOnLineup(uid,fType,pos,self.FightingPower+self.power))
	end
end

local function CheckCouldPutOff(self)
	local result = true
	if self.fType == kLineup_ArenaDefence then
		local UserDataType = require "Framework.UserDataType"
		local cardBagData = self:GetCachedData(UserDataType.CardBagData)
		local count = cardBagData:GetTroopCount(self.fType)
		local realCount = count - GetDictCount(self.WaitServerPutOffIdDict)
		if realCount <= 1 then
			result = false
			utility.ShowErrorDialog("防守阵容不能为空")
		end
	end
	return result
end

function FormationCls:OnPutCardOffLineup(fType,pos,index)
	-- local data = self.cardBagData:GetRoleByUid(uid)
	-- local  power = 
	-- 下阵 请求
	if CheckCouldPutOff(self) then
		if not GetDictContains(self.WaitServerPutOffIdDict,pos) then
			self.WaitServerPutOffIdDict:Add(pos,true)
		end
		self.myGame:SendNetworkMessage( require"Network/ServerService".PutCardOffLineup(fType,pos,index,self.FightingPower-self.power))
	end
end

function FormationCls:OnZhenrongInnerChangeReques(ctype,fromPos,toPos) 
	-- 交换阵容
	self.myGame:SendNetworkMessage( require"Network/ServerService".ZhenrongInnerChangeRequest(ctype,fromPos,toPos))
end

function FormationCls:OnSProtectGyjQueryRequest()
	-- 雇佣军query请求
	self.myGame:SendNetworkMessage( require"Network/ServerService".OnSProtectGyjQueryRequest())
end

function FormationCls:OnProtectUseGyjRequest(gyjcardUID,playerID)
	-- 雇用 雇佣军
	self.myGame:SendNetworkMessage( require"Network/ServerService".OnProtectUseGyjRequest(gyjcardUID,playerID))
end

function FormationCls:OnSZhenrongAdjustRequest(itype,cardUID,cardPos,gyjcardPos,sid)
	-- 雇佣军阵容操作 @ sid: -1上阵 0下阵
	self.myGame:SendNetworkMessage( require"Network/ServerService".OnSZhenrongAdjustRequest(itype,cardUID,cardPos,gyjcardPos,sid))
end

function FormationCls:OnPutOnZhenrongResponse(msg)
	if msg.state == 0 then
		local node = self.BagCardDict:GetEntryByKey(msg.cardUIDFrom)
		node:ResetSelectedState(true)
		self.FormationStateDict:Add(msg.toPos,msg.cardUIDFrom)

		local formationNode = self.FormationNodeDict:GetEntryByKey(msg.toPos)
		formationNode:ResetViewOnFormation(msg.cardUIDFrom,true,self.fType,msg.toPos)
		formationNode:ChangeOnFormationState(true)
		DeletedDictByKey(self.WaitServerPutOnIdDict,msg.toPos)
	end
end

function FormationCls:OnPutOffZhenrongResponse(msg)
	-- 下阵Response
	if msg.state == 0 then

		local pos = msg.fromPos
		local uid = self.FormationStateDict:GetEntryByKey(pos)
		self.FormationStateDict:Remove(pos)
		local node = self.BagCardDict:GetEntryByKey(uid)
		node:ResetSelectedState(false)
		local formation = self.FormationNodeDict:GetEntryByKey(pos)
		formation:OnPutOffFormation(false)
		DeletedDictByKey(self.WaitServerPutOffIdDict,pos)
	end
end

function FormationCls:OnProtectGyjQueryResponse(msg)
	debug_print("FormationCls:OnProtectGyjQueryResponse")
	for i=1,#msg.card do
		local item = msg.card[i]
		debug_print(
			string.format(
				"uid:%s, pos:%d, playerID:%d"
				, item.cardUID
				, item.pos
				, item.playerID
				, item.cardID
			)
		)
	end

	-- 雇佣军
	self:ResetGYJBagNode(msg.card,true)
end

function FormationCls:OnProtectUseGyjResponse(msg)

	debug_print("FormationCls:OnProtectGyjQueryResponse")

	for i = 1, #msg.gyjInfo do
		local item = msg.gyjInfo[i]

		debug_print(
			string.format(
				"uid:%s, pos:%d, playerID:%d, cardID:%d, pos:%d, hp:%s"
				, item.cardUID
				, item.pos
				, item.playerID
				, item.cardID
				, item.cardPos
				, item.hp
			)
		)


	end

	-- for i=1,#msg.card do
	-- 	local item = msg.card[i]
	-- 	debug_print(
	-- 		string.format(
	-- 			"uid:%s, pos:%d, playerID:%d"
	-- 			, item.cardUID
	-- 			, item.pos
	-- 			, item.playerID
	-- 			, item.cardID
	-- 		)
	-- 	)
	-- end


	-- 雇用 雇佣兵
	self:RemoveNodeFromPanel(self.GYJCardDict)
	self.GYJCardDict:Clear()
	self.gyjInfo = msg.gyjInfo
	local carduid = self.gyjInfo.cardUID 
	self.gyjInfo.cardUID = string.format("%s%s","gyj",carduid)
	local tables = {}
	tables[1] = msg.gyjInfo	
	self:ResetGYJBagNode(tables)
	self:AddNodeToPanel(self.GYJCardDict)
end
------------------------------------------------------------

local function ReplaceValueFromDict(dict,key1,key2)
	-- 交换value
	local ContainKey1 = dict:Contains(key1)
	local ContainKey2 = dict:Contains(key2)

	local value1 
	local value2

	if ContainKey1 then
		value1 = dict:GetEntryByKey(key1)
		dict:Remove(key1)
	end

	if ContainKey2 then
		value2 = dict:GetEntryByKey(key2)
		dict:Remove(key2)
	end

	if value1 then
		dict:Add(key2,value1)
	end

	if value2 then
		dict:Add(key1,value2)
	end

end

function FormationCls:OnZhenrongAdjustResponse(msg)
	-- 阵容操作
	if msg.state ~= 0 then
		return
	end

	if msg.head.sid == -1 then
		-- 上阵
		local uid = self.gyjInfo.cardUID
		local node = self.GYJCardDict:GetEntryByKey(uid)
		debug_print("佣兵上阵", node.uid, "旧位置", node.pos, "新位置", self.GYJToPos)
		node:ResetSelectedState(true)
		node:UpdatePos(self.GYJToPos)
		self.gyjInfo.cardPos = self.GYJToPos
		self.FormationStateDict:Add(self.GYJToPos,uid)

		local data = node:GetData()
		local formationNode = self.FormationNodeDict:GetEntryByKey(self.GYJToPos)
		formationNode:ResetViewOnGYJFormation(data,true,self.fType,self.GYJToPos)
		formationNode:ChangeOnFormationState(true)

	elseif msg.head.sid == 0 then
		local pos = self.GYJFromPos
		local uid = self.FormationStateDict:GetEntryByKey(pos)
		debug_print("阵容下阵", self.GYJFromPos, uid)
		debug_print("@@@@ UID", uid)
		self.FormationStateDict:Remove(pos)
		local node = self.GYJCardDict:GetEntryByKey(uid)
		node:ResetSelectedState(false)
		local formation = self.FormationNodeDict:GetEntryByKey(pos)
		formation:OnPutOffFormation(false)
		self.gyjInfo.cardPos = 0
	else
		ReplaceValueFromDict(self.FormationStateDict,self.GYJChangeFromPos,self.GYJChangeToPos)
		self.gyjInfo.cardPos = msg.head.sid
	end
end

function FormationCls:OnZhenrongInnerChangeResponse(msg)
	ReplaceValueFromDict(self.FormationStateDict,msg.fromPos,msg.toPos)
end

-----------------------------------------------------------------------

function FormationCls:AddObserver()
	-- 添加事件
	self:RegisterEvent('ChangeArenaFightingPower',self.ChangeArenaFightingPower)
	-- 阵容拖动开始
	self:RegisterEvent('BeginDragFormation',self.OnBeginDragFormation)
	-- 阵容拖动结束
	self:RegisterEvent('EndDragFormation',self.OnEndDragFormation)
end

function FormationCls:RemoveObserver()
	self:UnregisterEvent('ChangeArenaFightingPower',self.ChangeArenaFightingPower)
	self:UnregisterEvent('BeginDragFormation',self.OnBeginDragFormation)
	self:UnregisterEvent('EndDragFormation',self.OnEndDragFormation)
end
function FormationCls:ChangeArenaFightingPower(power)
	--修改战斗力
	self.FightingPower = self.FightingPower + power
	self.ArenaRankSingularStrengthNumLabel.text = self.FightingPower
end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function FormationCls:LoadCardData()
	-- 加载玩家卡牌数据
	local HeroCardItemNodeClass = require "GUI.Arena.FormationItem"
    local UserDataType = require "Framework.UserDataType"
    local cardBagData = self:GetCachedData(UserDataType.CardBagData)
    local count = cardBagData:RoleCount()

    for i =1 ,count do
    	local node = HeroCardItemNodeClass.New(self.FormationLayout,i)
    	node:SetCallback(self,self.OnBagCardClicked)
    	node:ResetView(cardBagData:GetRoleByPos(i))
    	self.HeroCardList[#self.HeroCardList + 1] = node
    end

    -- 排序 
   	table.sort(self.HeroCardList, function(node1, node2)
       	-- 等级优先  等级相同排颜色
       	if node1:GetLv() == node2:GetLv() then
       		return node1:GetColor() > node2:GetColor()
       	else
       		return node1:GetLv() > node2:GetLv()
       	end
    end)

   	-- 添加
   	for i = 1 ,#self.HeroCardList do
   		local node = self.HeroCardList[i]
   		
   		node:SetIndex(i)

   		local uid = node:GetUid()
   		self.BagCardDict:Add(uid,node)

   		local majorAttr = node:GetMajorAttr()
   		if majorAttr == 0 then
   			self.LiCardDict:Add(uid,node)
   		elseif majorAttr == 1 then
   			self.MinCardDict:Add(uid,node)
   		elseif majorAttr == 2 then
   			self.ZhiCardDict:Add(uid,node)
   		end
   	end

   	-- 已经上阵阵容
   	local default = cardBagData:GetTroopByLineup(self.fType)

   	for j = 1,#default do
   		local posUid = default[j]
   		if posUid ~= 0 then
   			self.FormationStateDict:Add(j,posUid)
   		end
   	end

end

function FormationCls:LoadGYJFormation()
	-- 加载雇佣军
	if self.fType ~= kLineup_Protect then
		return
	end
	
	-- 请求雇佣军
	if self.gyjInfo.cardUID == "gyj" then
		debug_print("请求雇佣军阵容信息")
		self.GYJCardDict:Clear()
		self:OnSProtectGyjQueryRequest()
		return
	end

	debug_print("雇佣军刷新!!")

	local tables = {}
	tables[1] = self.gyjInfo
	self:ResetGYJBagNode(tables)
	if self.gyjInfo.cardPos ~= 0 then
		local uid = self.gyjInfo.cardUID
		local node = self.GYJCardDict:GetEntryByKey(uid)
		node:ResetSelectedState(true)
		debug_print("雇佣军刷新位置", self.gyjInfo.cardPos, uid)
		self.FormationStateDict:Add(self.gyjInfo.cardPos,uid)

		local data = node:GetData()
		local formationNode = self.FormationNodeDict:GetEntryByKey(self.gyjInfo.cardPos)
		formationNode:ResetViewOnGYJFormation(data,true,self.fType,self.gyjInfo.cardPos)
		formationNode:ChangeOnFormationState(true)
	end
end

function FormationCls:ResetGYJBagNode(tables,showPrice)
	-- 雇佣军背包node
	local nodeCls = require "GUI.Formation.GYJItemNode"
	local cardList = {}
	for i = 1 ,#tables do
		local node = nodeCls.New(self.FormationLayout,i)
		node:SetCallback(self,self.OnGYJBagCardClicked)
		node:ResetView(tables[i],showPrice)
		cardList[#cardList + 1] = node
	end

	table.sort(cardList, function(node1, node2)
       	-- 等级优先  等级相同排颜色
       	if node1:GetLv() == node2:GetLv() then
       		return node1:GetColor() > node2:GetColor()
       	else
       		return node1:GetLv() > node2:GetLv()
       	end
    end)

    for i = 1 ,#cardList do
    	local node = cardList[i]
    	local uid = node:GetUid()
    	debug_print("增加佣兵UID", uid, node)
    	self.GYJCardDict:Add(uid,node)
    end
end

local function DelaySetNodePosition(self)
	while (not self:IsReady()) do
		coroutine.step(1)
	end

	local nodeCount = self.OnFormationLayout.transform.childCount - 1
	for i = 0 ,nodeCount do
		local node = self.OnFormationLayout.transform:GetChild(i)
		local pos = node:GetComponent(typeof(UnityEngine.RectTransform)).anchoredPosition
		self.FormationNodePostionDict:Add(i+1,pos)
	end
	self.GridLayout.enabled = false
	self.nodeScrollRect.enabled = true
end

function FormationCls:LoadOnFormation()
	-- 加载6张上阵卡牌展示
	
	-- 获得解锁
	local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
	local playerLevel = userData:GetLevel()
	
	-- 获取解锁数量
	local configData = require "StaticData.SystemConfig.FormationConfig"
	-- 解锁对应等级
	self.lockLevelList = {}

	for i=4,1,-1 do
		
		local levelTemp = configData:GetData(i):GetLevel()
		local levelMaxOn = configData:GetData(i):GetMaxCardOn()
		self.lockLevelList[levelMaxOn] = levelTemp
		
		if playerLevel >= levelTemp then
			self.MaxCardOn = levelMaxOn		
			break
		end		
	end

	local FormationHeroClass = require "GUI.Formation.FormationHero"
	for i=1,6 do

		local node = FormationHeroClass.New(self.OnFormationLayout,i)
		self:AddChild(node)
		node:SetCallback(self, self.OnFormationCardClicked)
		
		local islock = i > self.MaxCardOn
		node:OnClearLock(islock,self.lockLevelList[i])

		self.FormationNodeDict:Add(i,node)
	end

	-- coroutine.start(DelaySetNodePosition,self)
	self:StartCoroutine(DelaySetNodePosition)
end

function FormationCls:OnBagCardClicked(uid,index,state)
	debug_print("OnBagCardClicked")
	
	if self.fType== kLineup_ArenaDefence then
		local UserDataType = require "Framework.UserDataType"
	    local cardBagData = self:GetCachedData(UserDataType.CardBagData)
		local data = cardBagData:GetRoleByUid(uid)
		self.power= data:GetPower()

	end

	-- 背包卡牌点击事件
	if not state then
		local toPos = self:ForeachFormationPos()
		if toPos == nil then
			return
		end
		self:OnPutCardOnLineup(uid,self.fType,toPos)
	else
		local pos = self:GetFormationPosByUid(uid)
		self:OnPutCardOffLineup(self.fType,pos,uid)
	end
	
end

function FormationCls:UseGYJ(args)
	debug_print("uid", args.uid, "playerID", args.playerID)
	-- 使用雇佣军
	self:OnProtectUseGyjRequest(args.uid,args.playerID)
end

-- 确认窗口
function FormationCls:ConfirmUseGYJ(str,args)
	local windowManager = self:GetGame():GetWindowManager()
    local ConfirmDialog = require "GUI.Dialogs.ConfirmDialog"
    windowManager:Show(ConfirmDialog,str,self,self.UseGYJ,nil,args)
end

-- 点击雇佣军头像
function FormationCls:OnGYJBagCardClicked(uid,playerID,price,pos,state)
	if self.gyjInfo.cardUID == "gyj" then
		local str = string.format("是否花费%s金币雇佣",price)
		local args = {}
		args.uid = uid
		args.playerID = playerID
		self:ConfirmUseGYJ(str,args)
		return
	end

	if not state then
		debug_print("OnGYJBagCardClicked 1")
		local toPos = self:ForeachFormationPos()
		if toPos == nil then
			return
		end
		self.GYJToPos = toPos
		local cardUID,cardPos = self:GetOnFormationCardInfo()
		self:OnSZhenrongAdjustRequest(self.fType,cardUID,cardPos,toPos,-1)
	else
		local cardUID,cardPos = self:GetOnFormationCardInfo()
		self.GYJFromPos = pos
		debug_print("OnGYJBagCardClicked 2", pos, cardUID)
		self:OnSZhenrongAdjustRequest(self.fType,cardUID,cardPos,0,0)
	end
end

-- 点击右边已上阵的控件时的回调
function FormationCls:OnFormationCardClicked(pos,uid)
	debug_print("OnFormationCardClicked")

	if self.fType== kLineup_ArenaDefence then

		local UserDataType = require "Framework.UserDataType"
	    local cardBagData = self:GetCachedData(UserDataType.CardBagData)
		local data = cardBagData:GetRoleByUid(uid)
		self.power= data:GetPower()

	end

	--hzj_print("阵容点击事件", pos, uid, self.fType, self.gyjInfo.cardUID)

	-- 阵容点击事件
	if self.fType == kLineup_Protect and uid == self.gyjInfo.cardUID then
		self.GYJFromPos = pos
		local cardUID,cardPos = self:GetOnFormationCardInfo()
		self:OnSZhenrongAdjustRequest(self.fType,cardUID,cardPos,0,0)
	else
		self:OnPutCardOffLineup(self.fType,pos,uid)
	end
end

function FormationCls:GetRoleHp(uid)
	-- 获取角色hp
	local UserDataType = require "Framework.UserDataType"
    local cardBagData = self:GetCachedData(UserDataType.CardBagData)
    local roleData = cardBagData:GetRoleByUid(uid)
    local hp 
    if roleData == nil then
    	if self.gyjInfo.cardUID == "gyj" then
    		hp = 1
    	else
    		hp = self.gyjInfo.hp
    	end
   	else
   		hp = roleData:GetHp()
   	end
    return hp
end

function FormationCls:AddNodeToPanel(dict)
	-- 添加node
	local keys = dict:GetKeys()
	for i = 1 ,#keys do
		local uid = keys[i]
		local node = dict:GetEntryByKey(uid)
		self:AddChild(node)
		
		self:RefreshCardBagState(uid)

		if self.fType == kLineup_Protect and self.PrivateDict ~= nil then
			-- 保护公主
			local cardState = self.PrivateDict:GetEntryByKey(uid)
			local hp
			if cardState == nil then
				hp = self:GetRoleHp(uid)
			else
				hp = cardState:GetHp()
			end
			node:SetCardHp(hp)
		end
	end
end

function FormationCls:RemoveNodeFromPanel(dict)
	-- 删除node
	local count = dict:Count()
	for i = 1 ,count do
		local node = dict:GetEntryByIndex(i)
		self:RemoveChild(node)
	end
end

function FormationCls:RefreshCardBagState(uid)
	-- 设置卡牌状态
	local active
	local count = self.FormationStateDict:Count()
	for i = 1 ,count do
		local iUId = self.FormationStateDict:GetEntryByIndex(i)
		active = (uid == iUId)
		if active then
			break
		end
	end

	local node 
	node = self.BagCardDict:GetEntryByKey(uid)
	if self.fType == kLineup_Protect and node == nil then
		node = self.GYJCardDict:GetEntryByKey(uid)
	end
	node:ResetSelectedState(active)
end

function FormationCls:RefreshFormationNodeState()
	-- 刷新阵容卡牌
	local keys = self.FormationStateDict:GetKeys()
	for i = 1 ,#keys do
		local index = keys[i]
		local uid = self.FormationStateDict:GetEntryByKey(index)
		if uid ~= 0 then
			local node = self.FormationNodeDict:GetEntryByKey(index)
			node:ResetViewOnFormation(uid,true,self.fType,index)
			node:ChangeOnFormationState(true)
		end
	end

	if self.fType == kLineup_ElvenTree then
	 	local node = self.FormationNodeDict:GetEntryByKey(5)
   		node:InterceptOnly()
   	end

end

function FormationCls:ForeachFormationPos()
	-- 遍历上阵卡牌位置
	for i = 1 ,6 do
		local key = self.FormationStateDict:GetEntryByKey(i)
		local sending = GetDictContains(self.WaitServerPutOnIdDict,i)
		if sending then
			--debug_print("@@@ 正在发送",i)
		end
		if key == nil and (not sending) then
			--debug_print("@@@ 返回结果",i)
			return i
		end
	end

	return nil
end

function FormationCls:GetFormationPosByUid(uid)
	-- 通过uid获取卡牌位置
	local keys = self.FormationStateDict:GetKeys()
	for i = 1 , #keys do
		local cUid = self.FormationStateDict:GetEntryByKey(keys[i])
		if uid == cUid then
			return keys[i]
		end
	end
end
----------------------阵容拖动----------------------------------------
local DragRange = 100
function FormationCls:OnBeginDragFormation(index)
	self.DragNodeIndex = index
	local node = self.FormationNodeDict:GetEntryByKey(index)
	node:SetSiblingIndex(5)
end

local function ReplaceDictValue(dict,key,value)
	-- 替换字典的值
	if dict:Contains(key) then
		dict:Remove(key)
		dict:Add(key,value)
	end
end 

function FormationCls:OnEndDragFormation(pos)
	if self.DragNodeIndex == nil then
		return
	end

	local originalNode = self.FormationNodeDict:GetEntryByKey(self.DragNodeIndex)
	local originalPos = self.FormationNodePostionDict:GetEntryByKey(self.DragNodeIndex)

	local result,toIndex = self:DecideExchange(pos)
	
	if toIndex ~= nil then
		-- 抢夺模式
		if self.fType == kLineup_ElvenTree then
			if toIndex == 5 then
				result = false
			end
   		end

   		if toIndex > self.MaxCardOn then
   			result = false
   		end
	end
	

	if result then
		-- 交换
		
		local toPos = self.FormationNodePostionDict:GetEntryByKey(toIndex)
		originalNode:SetAnchoredPosition(toPos)
		originalNode:ChangePosIndex(toIndex)

		local targetNode = self.FormationNodeDict:GetEntryByKey(toIndex)
		targetNode:SetAnchoredPositionTween(originalPos)
		targetNode:ChangePosIndex(self.DragNodeIndex)
		
		ReplaceDictValue(self.FormationNodeDict,toIndex,originalNode)
		ReplaceDictValue(self.FormationNodeDict,self.DragNodeIndex,targetNode)
		local result
		if self.fType == kLineup_Protect then
			result = self:IsChangeGJYNode(self.DragNodeIndex,toIndex)
		end

		if result then
			local resultIndex = self:GetGYJChangeIndex(self.DragNodeIndex,toIndex)
			local cardUID,cardPos = self:GetOnFormationCardInfo(true,resultIndex,self.gyjInfo.cardPos)
			self.GYJChangeFromPos = self.DragNodeIndex
			self.GYJChangeToPos = toIndex
			self:OnSZhenrongAdjustRequest(self.fType,cardUID,cardPos,resultIndex,resultIndex)
		else
			self:OnZhenrongInnerChangeReques(self.fType,self.DragNodeIndex,toIndex)
		end
	else
		-- 还原
		originalNode:SetAnchoredPositionTween(originalPos)
	end

	self.DragNodeIndex = nil
end

function FormationCls:IsChangeGJYNode(fromPos,toPos)
	-- 检查是否是雇佣军交换	
	local GYJUid = self.gyjInfo.cardUID
	local fromUid = self.FormationStateDict:GetEntryByKey(fromPos)
	local toUid = self.FormationStateDict:GetEntryByKey(toPos)
	local result = (GYJUid == fromUid) or (GYJUid == toUid)
	return result
end

function FormationCls:GetOnFormationCardInfo(Change,toPos,fromPos)
	-- 获取 阵容uid pos
	-- 包含雇佣兵
	local uidStr = ""
	local posTables = {}

	local keys = self.FormationStateDict:GetKeys()
	for i = 1 ,#keys do
		local pos = keys[i]
		if Change and pos == toPos then
			pos = fromPos
		end
		local uid = self.FormationStateDict:GetEntryByIndex(i)
		if uid ~= self.gyjInfo.cardUID then
			uidStr = string.format("%s%s%s",uidStr,uid,",")
			posTables[#posTables + 1] = pos
		end
	end
	return uidStr,posTables
end

function FormationCls:GetGYJChangeIndex(fromIndex,toIndex)
	-- 交换
	local resultIndex
	local fromUid = self.FormationStateDict:GetEntryByKey(fromIndex)
	if fromUid == self.gyjInfo.cardUID then
		resultIndex = toIndex
	else
		resultIndex = fromIndex
	end
	return resultIndex
end

local function ComparePosition(fromPos,toPos)

	local horizontal = ( math.abs(toPos.x - fromPos.x) < DragRange )
	local vertical = ( math.abs(toPos.y - fromPos.y) < DragRange ) 
	local result = horizontal and vertical
	return result
end

function FormationCls:DecideExchange(pos)
	-- 比对交换位置
	for i = 1 ,6 do		
		if i ~= self.DragNodeIndex then
			local nodePos = self.FormationNodePostionDict:GetEntryByKey(i)
			local result = ComparePosition(pos,nodePos)

			if result then
				return result,i
			end
		end		
	end

end


-----------------------------------------------------------------------
--- Panel处理
-----------------------------------------------------------------------
function FormationCls:SwitchPanelCtrl(state)
	if self.CurrPanelState == state then
		return
	end

	if self.CurrPanelState ~= nil then
		self:OnPanelStateExit(self.CurrPanelState)
	end

	self:OnPanelStateEnter(state)
end

function FormationCls:OnPanelStateEnter(state)
	
	if state == AllPanelEnumState then

		self:ChangeButtonTheme(self.FormationAllHeroButton)
		self:OnAllPanelStateEnter()
	elseif state == LiPanelEnumState then

		self:ChangeButtonTheme(self.FormationPowerButton)
		self:OnLiPanelStateEnter()
	elseif state == MinPanelEnumState then

		self:ChangeButtonTheme(self.FormationAgileButton)
		self:OnMinPanelStateEnter()
	elseif state == ZhiPanelEnumState then

		self:ChangeButtonTheme(self.FormationIntelligenceButton)
		self:OnZhiPanelStateEnter()
	elseif state == GYJPanelEnumState then

		self:ChangeButtonTheme(self.FormationMercenariesButton)
		self:OnGYJPanelStateEnter()
	end
	self.CurrPanelState = state
end

function FormationCls:OnPanelStateExit(state)
	
	if state == AllPanelEnumState then
		self:OnAllPanelStateExit()
	elseif state == LiPanelEnumState then
		self:OnLiPanelStateExit()
	elseif state == MinPanelEnumState then
		self:OnMinPanelStateExit()
	elseif state == ZhiPanelEnumState then
		self:OnZhiPanelStateExit()
	elseif state == GYJPanelEnumState then
		self:OnGYJPanelStateExit()
	end
	self.CurrPanelState = nil
end

-- 所有
function FormationCls:OnAllPanelStateEnter()
	self:AddNodeToPanel(self.BagCardDict)
end

function FormationCls:OnAllPanelStateExit()
	self:RemoveNodeFromPanel(self.BagCardDict)
end

-- 力
function FormationCls:OnLiPanelStateEnter()
	self:AddNodeToPanel(self.LiCardDict)
end

function FormationCls:OnLiPanelStateExit()
	self:RemoveNodeFromPanel(self.LiCardDict)
end

-- 敏
function FormationCls:OnMinPanelStateEnter()
	self:AddNodeToPanel(self.MinCardDict)
end

function FormationCls:OnMinPanelStateExit()
	self:RemoveNodeFromPanel(self.MinCardDict)
end

-- 智
function FormationCls:OnZhiPanelStateEnter()
	self:AddNodeToPanel(self.ZhiCardDict)
end

function FormationCls:OnZhiPanelStateExit()
	self:RemoveNodeFromPanel(self.ZhiCardDict)
end

-- 佣兵
function FormationCls:OnGYJPanelStateEnter()
	local spacing = self.HeroGridLayout.spacing
	spacing.y = spacing.y + 20
	self.HeroGridLayout.spacing = spacing
	self:AddNodeToPanel(self.GYJCardDict)
end

function FormationCls:OnGYJPanelStateExit()
	local spacing = self.HeroGridLayout.spacing
	spacing.y = spacing.y - 20
	self.HeroGridLayout.spacing = spacing
	self:RemoveNodeFromPanel(self.GYJCardDict)
end
------------------------------------------------------------------------
function FormationCls:SetPrivateArgs(dict,gyjInfo)
	-- 设置保卫公主参数
	-- 卡牌信息
	self.PrivateDict = dict
	local keys = self.PrivateDict:GetKeys()
	for i = 1 ,#keys do
		local uid = keys[i]
		local state = self.PrivateDict:GetEntryByKey(uid)
	end
	-- 雇佣军信息
	self.gyjInfo = gyjInfo
	local carduid = self.gyjInfo.cardUID 
	self.gyjInfo.cardUID = string.format("%s%s","gyj",carduid)
end
-------------------------------------------------------------------------
function FormationCls:OnArenaReturnButtonClicked()
	--ArenaReturnButton控件的点击事件处理
	local sceneManager = self.myGame:GetSceneManager()
    sceneManager:PopScene()
end

function FormationCls:OnFormationAllHeroButtonClicked()
	--FormationAllHeroButton控件的点击事件处理
	self:SwitchPanelCtrl(AllPanelEnumState)
end

function FormationCls:OnFormationPowerButtonClicked()
	--FormationPowerButton控件的点击事件处理
	self:SwitchPanelCtrl(LiPanelEnumState)
end

function FormationCls:OnFormationAgileButtonClicked()
	--FormationAgileButton控件的点击事件处理
	self:SwitchPanelCtrl(MinPanelEnumState)
end


function FormationCls:OnFormationIntelligenceButtonClicked()
	--FormationIntelligenceButton控件的点击事件处理
	self:SwitchPanelCtrl(ZhiPanelEnumState)
end


function FormationCls:OnFormationMercenariesButtonClicked()
	--FormationMercenariesButton控件的点击事件处理
	self:SwitchPanelCtrl(GYJPanelEnumState)
end

function FormationCls:WBossFightStartResult(msg)	
	debug_print(self.isThreeType,msg.hp,msg.maxHp,"  +++++++++++++++")
	local WorldBossLevelData = require "StaticData.Boss.WorldBossChallengtimes":GetData(self.isThreeType)
	local attackRate=WorldBossLevelData:GetAttackRate()
	local sceneManager = self.myGame:GetSceneManager()
    sceneManager:PopScene()
	self.func(self.arg,attackRate,self.isThreeType,msg.hp,msg.maxHp,self.bossID)
end

function FormationCls:OnFormationSendBossFightStart()
 	if self.toggle.isOn then
 		self.isThreeType=2
		
	else
		self.isThreeType=1
	end
	self.myGame:SendNetworkMessage(require "Network.ServerService".WBossFightStartRequest(self.isThreeType,self.bossID))
end

function FormationCls:SetBossID(bossID)
 	debug_print("SetBossID",bossID)
 	self.bossID=bossID
end

function FormationCls:OnFormationFightButtonClicked()

	debug_print("开始战斗")

	--FormationFightButton控件的点击事件处理
	local UserDataType = require "Framework.UserDataType"
	local cardBagData = self:GetCachedData(UserDataType.CardBagData)
	local count = cardBagData:GetTroopCount(self.fType)
	
	if count == 0 and (self.fType ~= kLineup_ElvenTree and self.fType ~= kLineup_ArenaDefence) then
		utility.ShowErrorDialog(CommonStringTable[2])
		return
	end


	if self.fType == kLineup_ArenaAttack then
		local ArenaDefenceCount = cardBagData:GetTroopCount(kLineup_ArenaDefence)
		if ArenaDefenceCount == 0 then
			utility.ShowErrorDialog("防守阵容不能为空，请先设置防守阵容")
			return
		end
	end
	
	if self.fType == kLineup_GuildPointAttack then
		local ArenaDefenceCount = cardBagData:GetTroopCount(kLineup_GuildPointDefence)
		if ArenaDefenceCount == 0 then
			utility.ShowErrorDialog("防守阵容不能为空，请先设置防守阵容")
			return
		end
	end

	
	if self.fType == kLineup_JourneyToExplore4 then
		self:OnFormationSendBossFightStart()
		return
	end

	local sceneManager = self.myGame:GetSceneManager()
    sceneManager:PopScene()
	self.func(self.arg)
end
------------------------------------------------------------------------
---  改变button 样式
------------------------------------------------------------------------
local function ChangeParent(object,parent)
	-- 改变组件位置
	object.transform:SetParent(parent)
end

local function SetLabelTheme(label,OnShow)
	--设置文字样式
	local outLine = label:GetComponent(typeof(UnityEngine.UI.Outline))
	if OnShow then
		label.fontSize = 35
		label.color = UnityEngine.Color(1,1,1,1)
		outLine.enabled = true
	else
		label.fontSize = 32
		label.color = UnityEngine.Color(0,0,0,1)
		outLine.enabled = false
	end
end 

local function GetParentTransform(self,targetButton)
	local parent
	for i = 1 ,#self.originalButtonParentList do
		if self.ButtonCheckList[i] == targetButton then
			parent = self.originalButtonParentList[i]
			return parent
		end
	end
	
	return parent
end

local function ChangePos(target,scale,offset)
	target.transform.localScale = Vector3(scale,scale,scale)
	local pos = target.transform.localPosition
	pos.x = pos.x + offset
	target.transform.localPosition = pos
end

function FormationCls:ChangeButtonTheme(targetButton)
	-- 更改button按钮选中主题
	if targetButton == self.OnSelectButton then
		return
	end
	local gameTool = require "Utils.GameTools"
	
	local buttonImage = targetButton.gameObject:GetComponent(typeof(UnityEngine.UI.Image))
	buttonImage.color = ButtonSelectedImageColor
	ChangeParent(targetButton,self.tatgetButtonParent)
	local textLabel = targetButton.transform:Find('TextLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	SetLabelTheme(textLabel,true)
	ChangePos(targetButton,1.1,-5)

	if self.OnSelectButton ~= nil then
		local onSelectButtonImage = self.OnSelectButton.gameObject:GetComponent(typeof(UnityEngine.UI.Image))
		onSelectButtonImage.color = ButtonNormalImageColor
		local parent = GetParentTransform(self,self.OnSelectButton)
		ChangeParent(self.OnSelectButton,parent)
		local textLabel = self.OnSelectButton.transform:Find('TextLabel'):GetComponent(typeof(UnityEngine.UI.Text))
		SetLabelTheme(textLabel,false)
		ChangePos(self.OnSelectButton,1,5)
	end

	self.OnSelectButton = targetButton
end



local function OnConfirmBuy(self)
    print("向服务器发协议购买精英三倍券",self.needCoin)
	self.myGame:SendNetworkMessage(require "Network.ServerService".BuyThreefoldKeyRequest(self.needCount))
    
end

local function OnCancelBuy(self)
  	self.toggle.isOn=false
end

function FormationCls:SetBossKey(num)
	self.keysNum=num
end

function FormationCls:OnToggleClicked()
	print("self.toggle.isOn",self.toggle.isOn)
    local UserDataType = require "Framework.UserDataType"
    local itemCardData = self:GetCachedData(UserDataType.ItemBagData)
    local count=itemCardData:GetItemCountById(10300126)
    if self.keysNum<3 then

    	local windowManager = utility:GetGame():GetWindowManager()
   		local ConfirmDialogClass = require "GUI.Dialogs.NormalDialog"	
		windowManager:Show(ConfirmDialogClass, "剩余挑战次数无法使用精英三倍卷！")
		self.toggle.isOn=false
    	return

    end

	
    if self.toggle.isOn then    	
    	local WorldBossLevelData = require "StaticData.Boss.WorldBossChallengtimes":GetData(2)
	--	print(WorldBossLevelData:GetAdditem(),"  ---------------------")
		local needCount = WorldBossLevelData:GetAddItemNum()

		if count >= needCount  then
			
			print("count >= needCount",count,needCount)
		else

			print("count < needCount",count,needCount)
			self.needCount=needCount-count
			 self.needCoin=WorldBossLevelData:GetAddItemPrice()*(self.needCount)
			 local UserDataType = require "Framework.UserDataType"
			 local userData = self:GetCachedData(UserDataType.PlayerData)

			 local diamond = userData:GetDiamond()

			 debug_print(userData:GetDiamond(),"  ************************")
			 if diamond>=self.needCoin then

			 	
	     		local utility = require "Utils.Utility"
	   			utility.ShowBuyConfirmDialog("当前精英三倍券不足，是否花费"..self.needCoin.."钻石购买？", self, OnConfirmBuy, OnCancelBuy)
			
			 else
			 	self.toggle.isOn=false
			 	local windowManager = utility:GetGame():GetWindowManager()
   				local ConfirmDialogClass = require "GUI.Dialogs.NormalDialog"	
				windowManager:Show(ConfirmDialogClass, "钻石不足！")
			 end

			
		end

   	else
   		print("不需要")

   	end


	
end



return FormationCls