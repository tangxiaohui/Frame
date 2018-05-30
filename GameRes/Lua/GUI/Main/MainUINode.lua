local UINodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
local calculateRed = require"Utils.CalculateRed"
local messageGuids = require "Framework.Business.MessageGuids"
local InitialCard = require "StaticData.InitialCard"
require "Framework.GameSubSystem"
require "Const"

require "LUT.StringTable"

local MainUINode = Class(UINodeClass)

function MainUINode:OnInit()
    self.cardId = nil
    utility.LoadNewGameObjectAsync('UI/Prefabs/TheMainPanel', function(go)
        self:BindComponent(go)
    end)
end

local function CreateMain3DScene(self)
    local MainUINode3DSceneClass = require "GUI.Main.MainUINode_Scene"
    local main3DScene = MainUINode3DSceneClass.New(self.controls.sceneScrollViewTrans, self.controls.bubbleTransform)
    self:AddChild(main3DScene)
end

function MainUINode:OnComponentReady()
    self:InitControls()
    print("1111111111111111111111111111111111111111111111111111")
    CreateMain3DScene(self)
    self:CreateActivityPanel()
    self:Create7DayFerver()
    self:CreateFirstCharge()
end

--创建活动面板
function MainUINode:CreateActivityPanel()
 local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    print(userData:GetIsShowOnline())
    if userData:GetIsShowOnline() then
        self.NovicePacksAwardButton = require"GUI.Activity.NovicePacksAwardButton".New(self.controls.ActivityLeftTrans)
        self:AddChild(self.NovicePacksAwardButton)
    end
end

--创建首冲
function MainUINode:CreateFirstCharge()
    local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
     if not userData:GetFirstChargeAward() then
        self.FirstChargeButton = require"GUI.Active.FirstChargeButton".New(self.controls.ActivePoint)
        self:AddChild(self.FirstChargeButton)
    end
end


function MainUINode:Create7DayFerver()
    local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
     if userData:GetSevenDayHappy() then
        self.DayFerverButton = require"GUI.Active.DayFerverButton".New(self.controls.ActivePoint)
        self:AddChild(self.DayFerverButton)
    end
end

-- 更新龟仙屋红点
local function UpdateKameRedDot(self)
    self.kameRedDotImage:SetActive(require "Utils.TarotUtils".HasRedDot() or require "Utils.RedDotUtils".HasZodiacRedDot())
end

-- 在背包更新的时候 更新某些操作
local function OnItemBagUpdate(self)
    UpdateKameRedDot(self)
end





function MainUINode:OnCleanup()
    MainUINode.base.OnCleanup(self)
    print("MainUINode >> Cleanup")
end

function MainUINode:OnResume()
    MainUINode.base.OnResume(self)
    self:ShopHeishiQueryRequest()
   --  print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&")
    self:InitView()
    self:RegisterControlEvents()
    self:RegisterNetworkEvents()
    self:SelectChatMessage()
    self:OnGuideGonggaoRequest()
    self:GetGame():SendNetworkMessage(require"Network/ServerService".MailRequest())
    self:GetGame():SendNetworkMessage( require "Network/ServerService".TiliCountDownRequest(3))


    -- 显示 SceneCanvas 并且将 MainUI的UI模式关闭 --
    local uiManager = self:GetUIManager()
    uiManager:GetMainSceneUICanvas():ShowRoot()
    uiManager:GetMainUICanvas():SetUIMode(false)
	-- self:BlackeMarketTimeShow()
	self:ScheduleUpdate(self.Update)

    self:RedDotStateQuery()

     ------------------注冊主場景的监听事件---------------------------------
    self:RegisterEvent(messageGuids.EnterElvenTreeScene, self.OnElvenTreeButtonClicked)
    self:RegisterEvent(messageGuids.EnterJourneyScene, self.OnChallengButtonClicked)

    self:RegisterEvent(messageGuids.EnterPitScene, self.OnEnterPitClicked)

    self:RegisterEvent(messageGuids.EnterCastleScene, self.OnEnterCastleClicked)

    self:RegisterEvent(messageGuids.EnterProtectScene, self.OnProtectPrincessClicked)

    self:RegisterEvent(messageGuids.EnterGuildScene, self.OnGuildButtonClicked)

    self:RegisterEvent(messageGuids.EnterShopScene, self.OnNormalShopButtonClicked)

    self:RegisterEvent(messageGuids.EnterMailScene, self.OnMailBtnClicked)

    self:RegisterEvent(messageGuids.EnterChapterScene, self.OnChapterButtonClicked)

    self:RegisterEvent(messageGuids.EnterArenaScene, self.OnArenaButtonClicked)

    self:RegisterEvent(messageGuids.CardRedDotChanged, self.RedDotStateUpdated)
    self:RegisterEvent(messageGuids.ModuleRedDotChanged, self.RedDotStateUpdated)

    self:RegisterEvent(messageGuids.AddedOneItem, OnItemBagUpdate)
    self:RegisterEvent(messageGuids.UpdatedOneItem, OnItemBagUpdate)
    self:RegisterEvent(messageGuids.LocalRedDotChanged, self.LocalRedDotChanged)

    local guideMgr = utility.GetGame():GetGuideManager()
	guideMgr:AddGuideEvnt(kGuideEvnt_MainPanel)
	guideMgr:AddGuideEvnt(kGuideEvnt_ClickTavern)
	guideMgr:AddGuideEvnt(kGuideEvnt_GetReadyDungeonGideTips)
	guideMgr:AddGuideEvnt(kGuideEvnt_MainPanel2Dungeon)
	guideMgr:AddGuideEvnt(kGuideEvnt_GetReadyHeroPanelGideTips)
	guideMgr:AddGuideEvnt(kGuideEvnt_MainPanel2HeroPanel)
	guideMgr:AddGuideEvnt(kGuideEvnt_StartMailGuide)
	guideMgr:AddGuideEvnt(kGuideEvnt_StartSigninGuide)
	guideMgr:AddGuideEvnt(kGuideEvnt_StartShopGuide)
	guideMgr:AddGuideEvnt(kGuideEvnt_StartElventreeGuide)
	guideMgr:AddGuideEvnt(kGuideEvnt_StartChatGuide)
	guideMgr:AddGuideEvnt(kGuideEvnt_StartTaskGuide)
-------------------测试--------------------------------
    guideMgr:AddGuideEvnt(kGuideEvnt_2ndFBMainButton)
    guideMgr:AddGuideEvnt(kGuideEvnt_3rdFBMainButton)



-------------------------End-------------------------------

	
	guideMgr:SortGuideEvnt()
    guideMgr:ShowGuidance()

    self.payTipTran.localPosition=self.payTipTranPos
    self.dungeonTipTran.localPosition=self.dungeonTipTranPos

    self:LocalRedDotChanged()
    
end
function MainUINode:ShowWorldBossIcon(flag)
    if flag then
        self.controls.bossButton.gameObject:SetActive(true)
    else
        self.controls.bossButton.gameObject:SetActive(false)
    end
    
end

function MainUINode:OnPause()
    MainUINode.base.OnPause(self)
    self:UnregisterNetworkEvents()
    self:UnregisterControlEvents()

    -- 隐藏 SceneCanvas 并且将 MainUI的UI模式开启 --
    local uiManager = self:GetUIManager()
    uiManager:GetMainSceneUICanvas():HideRoot()
    uiManager:GetMainUICanvas():SetUIMode(true)


    
      -----------------------------取消监听事件--------------------------------------
    self:UnregisterEvent(messageGuids.EnterElvenTreeScene, self.OnElvenTreeButtonClicked)
    self:UnregisterEvent(messageGuids.EnterJourneyScene, self.OnChallengButtonClicked)

    self:UnregisterEvent(messageGuids.EnterPitScene, self.OnEnterPitClicked)

    self:UnregisterEvent(messageGuids.EnterCastleScene, self.OnEnterCastleClicked)

    self:UnregisterEvent(messageGuids.EnterProtectScene, self.OnProtectPrincessClicked)

    self:UnregisterEvent(messageGuids.EnterGuildScene, self.OnGuildButtonClicked)

    self:UnregisterEvent(messageGuids.EnterShopScene, self.OnNormalShopButtonClicked)

    self:UnregisterEvent(messageGuids.EnterMailScene, self.OnMailBtnClicked)

    self:UnregisterEvent(messageGuids.EnterChapterScene, self.OnChapterButtonClicked)

    self:UnregisterEvent(messageGuids.EnterArenaScene, self.OnArenaButtonClicked)

    self:UnregisterEvent(messageGuids.CardRedDotChanged, self.RedDotStateUpdated)
    self:UnregisterEvent(messageGuids.ModuleRedDotChanged, self.RedDotStateUpdated)

    self:UnregisterEvent(messageGuids.AddedOneItem, OnItemBagUpdate)
    self:UnregisterEvent(messageGuids.UpdatedOneItem, OnItemBagUpdate)
    self:UnregisterEvent(messageGuids.LocalRedDotChanged, self.LocalRedDotChanged)
end
local function ShakeTran(self,moveTransNum,trans)
    while true do

        if moveTransNum<60 then
           trans.localPosition=Vector3(trans.localPosition.x+0.1,trans.localPosition.y,trans.localPosition.z)
            moveTransNum=moveTransNum+1
        elseif moveTransNum>=60 and moveTransNum<120 then
           trans.localPosition=Vector3(trans.localPosition.x-0.1,trans.localPosition.y,trans.localPosition.z)
             moveTransNum=moveTransNum+1
        else
            moveTransNum=0
        end
        
        coroutine.step()
        
    end


end
function MainUINode:LocalRedDotChanged()
    local flag = calculateRed.GetMainRoleRedData()

    hzj_print("LocalRedDotChanged",flag)
    self.heroRedDotImage:SetActive(flag)
    
    flag = calculateRed.CalculateBagRedData()
    hzj_print("LocalRedDotChanged1",flag)
    self.backpackRedDotImage:SetActive(flag)
    
end
function MainUINode:ShowTips()
    print( self.upLevel,"6666666666666666666")
    if self.upLevel==false then
        self.dungeonTipTran.gameObject:SetActive(true)
        if self.coroutineDungeonTable~=nil then
            self:StopCoroutine(self.coroutineDungeonTable) 
        end

       -- self.moveTransNum=0
        self.coroutineDungeonTable=self:StartCoroutine(ShakeTran,0,self.dungeonTipTran)  
        
    else
        self.dungeonTipTran.gameObject:SetActive(false)
        if self.coroutineDungeonTable~=nil then
            self:StopCoroutine(self.coroutineDungeonTable) 
        end

    end

     if self.firstPay==false then
        self.payTipTran.gameObject:SetActive(true)
        if self.coroutineFirstPayTable~=nil then
            self:StopCoroutine(self.coroutineFirstPayTable) 
        end

       -- self.moveTransNum=0
        self.coroutineFirstPayTable=self:StartCoroutine(ShakeTran,0,self.payTipTran)  
        
    else
        self.payTipTran.gameObject:SetActive(false)
        if self.coroutineFirstPayTable~=nil then
            self:StopCoroutine(self.coroutineFirstPayTable) 
        end

    end

end

function MainUINode:Update()
	self:Countdown()
    self:CountTimedown()
     ---判断当前是否有世界boss
    local UserDataType = require "Framework.UserDataType"
    local worldBossData = self:GetCachedData(UserDataType.WorldBossData)
   -- debug_print(worldBossData:Count(),"  ===============")
    if worldBossData:Count()>0 then
        self:ShowWorldBossIcon(true)
    else
        self:ShowWorldBossIcon(false)
    end
end

local function InitMainButtonControls(self)
    local transform = self:GetUnityTransform()

    -- 角色 --
    self.controls.heroCardButton = transform:Find("Shortcut/ShortcutLayout/ShortcutButton1"):GetComponent(typeof(UnityEngine.UI.Button))

    -- 酒馆 --
    self.controls.tavernButton = transform:Find("Shortcut/ShortcutLayout/ShortcutButton2"):GetComponent(typeof(UnityEngine.UI.Button))
    -- 背包 --
    self.controls.backpackButton = transform:Find("Shortcut/ShortcutLayout/ShortcutButton3"):GetComponent(typeof(UnityEngine.UI.Button))

    -- 任务 --
    self.controls.taskButton = transform:Find("Shortcut/ShortcutLayout/ShortcutButton4"):GetComponent(typeof(UnityEngine.UI.Button))

    -- 好友 --
    self.controls.friendButton = transform:Find("Shortcut/ShortcutLayout/ShortcutButton5"):GetComponent(typeof(UnityEngine.UI.Button))

    -- 大书库 --
    self.controls.achieveButton = transform:Find("Shortcut/ShortcutLayout/ShortcutButton6"):GetComponent(typeof(UnityEngine.UI.Button))
   


    -- ///// ---

    self.controls.ActivityTrans= transform:Find("RightButtons")
    self.controls.ActivityLeftTrans= transform:Find("LeftButtons")
    self.controls.ActivePoint = transform:Find("ActivePoint")
    -- 充值 --
    self.controls.chargeButton = transform:Find("RightButtons/Button1"):GetComponent(typeof(UnityEngine.UI.Button))

    -- 新手礼包 --
  --  self.controls.giftButton = transform:Find("RightButtons/Button2"):GetComponent(typeof(UnityEngine.UI.Button))

    -- 签到 --
    self.controls.signinButton = transform:Find("RightButtons/Button3"):GetComponent(typeof(UnityEngine.UI.Button))

    -- 活动 --
    self.controls.activityButton = transform:Find("RightButtons/Button4"):GetComponent(typeof(UnityEngine.UI.Button))

    -- 奇遇 --
    self.controls.encounterButton = transform:Find("RightButtons/Button5"):GetComponent(typeof(UnityEngine.UI.Button))

    -- 聊天
    self.controls.chatButton = transform:Find("Dialog/TheMainDialogButton"):GetComponent(typeof(UnityEngine.UI.Button))
   -- 限时神降--
    self.controls.limiteButton = transform:Find("RightButtons/Button6"):GetComponent(typeof(UnityEngine.UI.Button))


  ---------左侧按钮 

      -- 冒险 --
    self.controls.adventureButton = transform:Find("LeftButtons/Button1"):GetComponent(typeof(UnityEngine.UI.Button))

    self.controls.bossButton = transform:Find("LeftButtons/Button2"):GetComponent(typeof(UnityEngine.UI.Button))

    self.controls.blackMarketButton = transform:Find("LeftButtons/Button3"):GetComponent(typeof(UnityEngine.UI.Button))

    self.controls.blackMarketTimeText = self.controls.blackMarketButton.transform:Find("Text"):GetComponent(typeof(UnityEngine.UI.Text))

  
   
end



function MainUINode:InitControls()
    local transform = self:GetUnityTransform()

    self.controls = {}

    self.controls.sceneScrollViewTrans = transform:Find("SceneScrollView")
    self.controls.bubbleTransform = transform:Find("BigMap/Bubbles")
    self.controls.TheMainCharacterExpFill = transform:Find('Character/Exp/TheMainCharacterExpFill'):GetComponent(typeof(UnityEngine.UI.Image))
    self.controls.characterNameLbl = transform:Find("Character/Name/TheMainCharacterNameLabel"):GetComponent(typeof(UnityEngine.UI.Text))
    self.controls.characterLevelLbl = transform:Find("Character/Lv/TheMainCharacterLvLabel"):GetComponent(typeof(UnityEngine.UI.Text))
    self.controls.characterVipLbl = transform:Find("Character/Vip/VipButton/TheMainCharacterVipLabel"):GetComponent(typeof(UnityEngine.UI.Text))

    self.controls.chatMessageLabel = transform:Find("Dialog/DialogBox/TheMainDialogLabel"):GetComponent(typeof(UnityEngine.UI.Text))

    self.VipButton = transform:Find('Character/Vip/VipButton'):GetComponent(typeof(UnityEngine.UI.Button))

    self.controls.PlayerInfoButton = transform:Find("Character/Head/Base/PersonalInformationHeadIcon"):GetComponent(typeof(UnityEngine.UI.Button))
    self.controls.PlayerInfoImage = transform:Find("Character/Head/Base/PersonalInformationHeadIcon"):GetComponent(typeof(UnityEngine.UI.Image))
    self.readChatMessageTime = "0"
    self.nextOpenLevel = transform:Find("NextFunction/Lv"):GetComponent(typeof(UnityEngine.UI.Text))
    self.nextOpenLevelInfo = transform:Find("NextFunction/Function"):GetComponent(typeof(UnityEngine.UI.Text))
    self.nextOpenLevelParent = transform:Find("NextFunction")
    self.RecoverTime = transform:Find("Power/StaminaRecoverTime"):GetComponent(typeof(UnityEngine.UI.Text))
    self.Power = transform:Find("Power")
    self.Power.gameObject:SetActive(false)

    InitMainButtonControls(self)

    ---@红点
    -- 角色
    self.heroRedDotImage = self.controls.heroCardButton.transform:Find('RedDotImage'):GetComponent(typeof(UnityEngine.UI.Image)).gameObject
    -- 酒馆
    self.tavernRedDotImage = self.controls.tavernButton.transform:Find('RedDotImage'):GetComponent(typeof(UnityEngine.UI.Image)).gameObject
    -- 背包
    self.backpackRedDotImage = self.controls.backpackButton.transform:Find('RedDotImage'):GetComponent(typeof(UnityEngine.UI.Image)).gameObject
    -- 任务
    self.taskRedDotImage = self.controls.taskButton.transform:Find('RedDotImage'):GetComponent(typeof(UnityEngine.UI.Image)).gameObject
    -- 好友
    self.friendRedDotImage = self.controls.friendButton.transform:Find('RedDotImage'):GetComponent(typeof(UnityEngine.UI.Image)).gameObject
    -- 大书库
    self.biglibraryRedDotImage = self.controls.achieveButton.transform:Find('RedDotImage'):GetComponent(typeof(UnityEngine.UI.Image)).gameObject
    -- 签到
    self.signinRedDotImage = self.controls.signinButton.transform:Find('RedDotImage'):GetComponent(typeof(UnityEngine.UI.Image)).gameObject

    --龟仙屋
    self.kameRedDotImage = self.controls.bubbleTransform:Find("Bubble1/RedDotImage").gameObject
	--公会
	self.guildRedDotImage = self.controls.bubbleTransform.transform:Find('Bubble4/RedDotImage').gameObject
	--精灵树
	self.elevTreeRedDotImage = self.controls.bubbleTransform.transform:Find('Bubble2/RedDotImage').gameObject
    --邮件
    self.mailRedDotImage = self.controls.bubbleTransform.transform:Find('Bubble5/RedDotImage').gameObject
    --副本
    self.checkPointRedDotImage = self.controls.bubbleTransform.transform:Find('Bubble6/RedDotImage').gameObject
	--竞技场
    self.arenaRedDotImage = self.controls.bubbleTransform.transform:Find('Bubble7/RedDotImage').gameObject
    --探险
    self.exploreRedDotImage = self.controls.bubbleTransform.transform:Find('Bubble8/RedDotImage').gameObject
    --活动
    self.activeRedDotImage = self.controls.activityButton.transform:Find('RedDotImage').gameObject
    -- 成就
    self.achieveRedDotImage = self.controls.encounterButton.transform:Find('RedDotImage').gameObject

    -- 首冲提示
    self.payTipTran = transform:Find("RightButtons/Button1/Tip")
    self.payTipTran.gameObject:SetActive(false)
    self.payTipTranPos=self.payTipTran.localPosition
    -- 副本提示
    self.dungeonTipTran = transform:Find("BigMap/Bubbles/Bubble6/Tip")
    self.dungeonTipTran.gameObject:SetActive(false)
    self.dungeonTipTranPos=self.dungeonTipTran.localPosition
    
    -- -- 显示跑马灯
    self:GetGame():GetPersistentWindowManager():Show(require "GUI.Marquee.MarqueePanel")

    -- -- 显示 体力 金币 钻石
    self:GetGame():GetPersistentWindowManager():Show(require "GUI.PlayerCurrencyBarPanel")

    local eventMgr = utility.GetGame():GetEventManager()
    eventMgr:AddObserver('ChangeChatMessage', self, self.ChangeChatMessage)
    self.GuideGonggao = true
    self.blackForever = false
    local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    if userData:GetGodOpenIsOpen() then
        self.controls.limiteButton.gameObject:SetActive(true)
    else
        self.controls.limiteButton.gameObject:SetActive(false)

    end
end

--根据CardID选择头像
function MainUINode:LoadImageBycardID(id)
    utility.LoadRoleHeadIcon(id, self.controls.PlayerInfoImage)
end

function MainUINode:RedDotStateQuery()
    -- 查询红点提示
    local S2CGuideRedResult = require "Network.PB.S2CGuideRedResult"
    local UserDataType = require "Framework.UserDataType"
    local RedDotData = self:GetCachedData(UserDataType.RedDotData)

    if RedDotData ~= nil then
        -- 酒馆
        local cardDrawState = RedDotData:GetModuleRedState(S2CGuideRedResult.chouka)
        self.tavernRedDotImage:SetActive(cardDrawState == 1)
        -- 背包
        local backpacState = RedDotData:GetModuleRedState(S2CGuideRedResult.beibao_suipian)
     --   debug_print("backpacState",backpacState)
       -- self.backpackRedDotImage:SetActive(backpacState == 1)
        -- 任务
        local taskState = RedDotData:GetModuleRedState(S2CGuideRedResult.task)
        self.taskRedDotImage:SetActive(taskState == 1)
        -- 好友
        local freendTiliState = RedDotData:GetModuleRedState(S2CGuideRedResult.havefriendtili)
        local freendApplyState = RedDotData:GetModuleRedState(S2CGuideRedResult.friend_apply)
        local freendState = (freendTiliState==1) or (freendApplyState==1)
        self.friendRedDotImage:SetActive(freendState)
        -- 大书库
		local collection = RedDotData:GetModuleRedState(S2CGuideRedResult.big_tujian)
		local award = RedDotData:GetModuleRedState(S2CGuideRedResult.big_jiangli)
		local cardRed = RedDotData:GetCollectionCardInfo()
		local equipRed = RedDotData:GetCollectionEquipInfo()
		local cardRedInfo=2
		local equipRedInfo=2
		for i=1,#cardRed do
			if cardRed[i].red == 1 then
				cardRedInfo = cardRed[i].red
				break
			end
		end
		for i=1,#equipRed do
			if equipRed[i].red == 1 then
				equipRedInfo = equipRed[i].red
				break
			end
		end
        self.biglibraryRedDotImage:SetActive(cardRedInfo == 1 or award == 1 or equipRedInfo == 1)

        --成就
         local achieve = RedDotData:GetMainUIChengJiuState()
        debug_print(achieve,"成就")
         self.achieveRedDotImage:SetActive(achieve)

         -- 签到
        local signin = RedDotData:GetModuleRedState(S2CGuideRedResult.qiandao)
        self.signinRedDotImage:SetActive(signin == 1)
		
		 -- 公会
        local guild = RedDotData:GetModuleRedState(S2CGuideRedResult.gonghui)
        self.guildRedDotImage:SetActive(guild == 1)
		
		--精灵树
		local elvenTreeCangku = RedDotData:GetModuleRedState(S2CGuideRedResult.rob_cangku)
        local elvenTreeRizhi = RedDotData:GetModuleRedState(S2CGuideRedResult.rob_rizhi)
        local elvenTreeRobred = RedDotData:GetModuleRedState(S2CGuideRedResult.rob_red)
        if elvenTreeCangku==1 or elvenTreeRizhi==1 or elvenTreeRobred ==1 then
            self.elevTreeRedDotImage:SetActive(true)
        else
            self.elevTreeRedDotImage:SetActive(false)
        end

        --探险
        local explore = RedDotData:GetModuleRedState(S2CGuideRedResult.adventureCount)
        self.exploreRedDotImage:SetActive(explore == 1)
        debug_print(explore,"explore",explore)
	
		--邮件
		local mail = RedDotData:GetModuleRedState(S2CGuideRedResult.mail)
        self.mailRedDotImage:SetActive(mail == 1)

		--副本
		local checkPiont = RedDotData:GetModuleRedState(S2CGuideRedResult.fb_wangchengdu)
        self.checkPointRedDotImage:SetActive(checkPiont == 1)
		
		--竞技场
		local arena = RedDotData:GetModuleRedState(S2CGuideRedResult.arena_zhanbao)
        local arena_award = RedDotData:GetModuleRedState(S2CGuideRedResult.arena_award)
        debug_print(arena_award,"arena_award",arena,(arena == 1 or arena_award == 1))
        self.arenaRedDotImage:SetActive(arena == 1 or arena_award == 1)

    
       -- self:SetSevenActiveRedDot(RedDotData)
        --活动
		self:SetActiveRedDot(RedDotData)
    end
end

function MainUINode:SetSevenActiveRedDot(RedDotData)

    -- local sevenDayInfo = RedDotData:GetMainUISevenDayState()
    -- -- debug_print("SetSevenActiveRedDot",#sevenDayInfo)
    -- if sevenDayInfo then
    --     self.arenaRedDotImage:SetActive(true)
    -- else
    --     self.arenaRedDotImage:SetActive(false)
    -- end
end

function MainUINode:SetActiveRedDot(RedDotData)
	local activeRed
		local activeInfo = RedDotData:GetActiveInfo()
		for i=1,#activeInfo do
			if activeInfo[i].activityID ~= 0 then
				local activeData = require "StaticData.Activity.Activity":GetData(activeInfo[i].activityID)
				local type = activeData:GetActivetgrandype()
				if activeInfo[i].red == 1 and type ~= 4 then
					activeRed = activeInfo[i].red
					break
				end
			end
		end
        self.activeRedDotImage:SetActive(activeRed == 1)
end

function MainUINode:RedDotStateUpdated(moduleId,moduleState)
    -- 红点更新处理

    local S2CGuideRedResult = require "Network.PB.S2CGuideRedResult"
	local UserDataType = require "Framework.UserDataType"
    local RedDotData = self:GetCachedData(UserDataType.RedDotData)
	local cardRed = RedDotData:GetCollectionCardInfo()
	local equipRed = RedDotData:GetCollectionEquipInfo()
	local cardRedInfo
	local equipRedInfo
	for i=1,#cardRed do
		if cardRed[i].red == 1 then
			cardRedInfo = cardRed[i].red
			break
		end
	end
	for i=1,#equipRed do
		if equipRed[i].red == 1 then
			equipRedInfo = equipRed[i].red
			break
		end
	end
	-- 活动
	self:SetActiveRedDot(RedDotData)
    if moduleId == S2CGuideRedResult.chouka then
        -- 酒馆
        self.tavernRedDotImage:SetActive(moduleState == 1)
    elseif moduleId == S2CGuideRedResult.beibao_suipian then
        -- 背包
        --self.backpackRedDotImage:SetActive(moduleState == 1)
    elseif moduleId == S2CGuideRedResult.task then
        -- 任务
         self.taskRedDotImage:SetActive(moduleState == 1)
    elseif moduleId == S2CGuideRedResult.big_jiangli then
        -- 大书库
        self.biglibraryRedDotImage:SetActive(moduleState == 1)
    elseif moduleId == S2CGuideRedResult.qiandao then
		-- 签到
		self.signinRedDotImage:SetActive(moduleState == 1)
    elseif moduleId == S2CGuideRedResult.gonghui then
		--公会
		self.guildRedDotImage:SetActive(moduleState == 1)
	elseif moduleId == S2CGuideRedResult.rob_cangku or moduleId == S2CGuideRedResult.rob_rizhi or moduleId == S2CGuideRedResult.rob_red then
		--精灵树
	   self.elevTreeRedDotImage:SetActive(moduleState == 1)
	elseif moduleId == S2CGuideRedResult.mail then
		--邮件
		self.mailRedDotImage:SetActive(moduleState == 1)
	elseif moduleId == S2CGuideRedResult.fb_wangchengdu then
		--副本
		self.checkPointRedDotImage:SetActive(moduleState == 1)
	elseif moduleId == S2CGuideRedResult.arena_zhanbao then
		--竞技场
		self.arenaRedDotImage:SetActive(moduleState == 1)
    elseif moduleId == S2CGuideRedResult.arena_award then
        --竞技场jiangli
        self.arenaRedDotImage:SetActive(moduleState == 1)
    elseif moduleId == S2CGuideRedResult.havefriendtili then
        -- 好友体力
        self.friendRedDotImage:SetActive(moduleState == 1)

    elseif moduleId == S2CGuideRedResult.friend_apply then
        -- 好友申请
        self.friendRedDotImage:SetActive(moduleState == 1)
	elseif moduleId == S2CGuideRedResult.chengjiu_tongyong then
        --成就
        self.achieveRedDotImage:SetActive(moduleState == 1)
    elseif moduleId == S2CGuideRedResult.adventureCount then
        --探险
        self.exploreRedDotImage:SetActive(moduleState == 1)
    elseif moduleId == S2CGuideRedResult.star then
        UpdateKameRedDot(self)
    end
end

------- - 按钮处理函数 - -------

local function OnHeroCardButtonClicked(self)

    local sceneManager = self:GetGame():GetSceneManager()
    local HeroSceneClass = require "Scenes.HeroScene"
    sceneManager:PushScene(HeroSceneClass.New())
end

local function OnTavernButtonClicked(self)
    local windowManager = self:GetGame():GetWindowManager()
    windowManager:Show(require "GUI.CardDraw")
    debug_print("GUI.CardDraw")

   

end

local function OnBackpackButtonClicked(self)
    local windowManager = self:GetGame():GetWindowManager()
    windowManager:Show(require "GUI.Knapsack.Knapsack")
end

local function OnTaskButtonClicked(self)
    local isOpen = utility.IsCanOpenModule(KSystemBasis_TaskID)
    if not isOpen then
        return
    end
    local windowManager = self:GetGame():GetWindowManager()
    local TaskCls = require "GUI.Task.Task"
    windowManager:Show(TaskCls)
end

local function OnFriendButtonClicked(self)

    local isOpen = utility.IsCanOpenModule(KSystemBasis_ChatID)
    if not isOpen then
        return
    end
    local windowManager = self:GetGame():GetWindowManager()
    windowManager:Show(require "GUI.Friend.Friends")
end


       
local function OnAdventureButtonClicked(self)
    local isOpen = utility.IsCanOpenModule(KSystemBasis_Explore)
    if not isOpen then
        return
    end
     local sceneManager = utility:GetGame():GetSceneManager()
    local scene = require "GUI.Explore.Explore"
    sceneManager:PushScene(scene.New())

  
end

local function OnBossButtonClicked(self)
    
    local sceneManager = utility:GetGame():GetSceneManager()
    local scene = require "GUI.Boss.Boss"
    sceneManager:PushScene(scene.New())
end
local function OnBlackMarketClicked(self)
    --黑市
    debug_print("adsadadsfafafsa")
    -- self:ShopHeishiQueryRequestequest()
    self:BlackMarketEnter()
    -- self:BlackeMarketTimeShow()
end

local function OnAchieveButtonClicked(self)
    local sceneManager = utility:GetGame():GetSceneManager()
    local scene = require "GUI.Biglibrary.Biglibrary"
    sceneManager:PushScene(scene.New())

  
end

local function OnChargeButtonClicked(self)
    print("Charge >>>")
   --  local rechargeSDKData = require"StaticData.Activity.RechargeSDK"


   --  local libraryKeys = rechargeSDKData:GetKeys()
   --  local Length = libraryKeys.Length -1



   --  for i=0,Length do
        
   -- -- for i=1,#rechargeSDKData:GetKeys() do
   --      local data= rechargeSDKData:GetData(i)
   --       print(data:GetDes(),data:GetFirstDiamond())

   --  end
    local windowManager = self:GetGame():GetWindowManager()
    windowManager:Show(require "GUI.Deposit.Deposit")
end

local function OnGiftButtonClicked(self)
    print("gift >>>")
  
end

local function OnSigninButtonClicked(self)
    print("signin >>>")
    local levelLimit = require "StaticData.SystemConfig.SystemBasis":GetData(KSystemBasis_CheckID):GetMinLevel()
    local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    if userData:GetLevel() < levelLimit then
        local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
        local windowManager = self:GetGame():GetWindowManager()
        local hintStr = string.format(CommonStringTable[0],levelLimit)
        windowManager:Show(ErrorDialogClass, hintStr)
        return true
    end


    local windowManager = self:GetGame():GetWindowManager()
    windowManager:Show(require "GUI.CheckIn")
end

local function OnActivityButtonClicked(self)
    self:OnActiveButtonClicked()
   
end
local function OnLimiteButtonClicked(self)
    local windowManager = self:GetGame():GetWindowManager()
    windowManager:Show(require "GUI.LimiteHero.LimitedHero")
end

local  function ScenarioCallBack(table)
    
  
  print("****************  End  ********************")
    -- body
end 


local function OnEncounterButtonClicked(self)
    local sceneManager = utility:GetGame():GetSceneManager()
    local scene = require "GUI.Achievement.AchievementCls"
    sceneManager:PushScene(scene.New())
    -- self.infos = {}
    -- self.infos[1]="70000101"
    -- self. infos[2]="70000102"
    --  self. infos[3]="70000103"
    --   self. infos[4]="70000104"
    --    self. infos[5]="70000105"
    --     self. infos[6]="70000106"
    --     self. infos[8]="70000107"
    --     self. infos[7]="20000003" 
    --     self. infos[9]="20000004" 


    -- local windowManager = self:GetGame():GetWindowManager()
    -- windowManager:Show(require "GUI.Scenario.Scenario",self,self.infos,ScenarioCallBack)
end


function MainUINode:RegisterControlEvents()
    -- 注册 角色 页面 --
    self.__event_button_heroCardButtonClicked__ = UnityEngine.Events.UnityAction(OnHeroCardButtonClicked, self)
    self.controls.heroCardButton.onClick:AddListener(self.__event_button_heroCardButtonClicked__)

    -- 注册 酒馆 页面 --
    self.__event_button_tavernButtonClicked__ = UnityEngine.Events.UnityAction(OnTavernButtonClicked, self)
    self.controls.tavernButton.onClick:AddListener(self.__event_button_tavernButtonClicked__)

    -- 注册 背包 页面 --
    self.__event_button_backpackButtonClicked__ = UnityEngine.Events.UnityAction(OnBackpackButtonClicked, self)
    self.controls.backpackButton.onClick:AddListener(self.__event_button_backpackButtonClicked__)

    -- 注册 任务 页面 --
    self.__event_button_taskButtonClicked__ = UnityEngine.Events.UnityAction(OnTaskButtonClicked, self)
    self.controls.taskButton.onClick:AddListener(self.__event_button_taskButtonClicked__)

    -- 注册 好友 页面 --
    self.__event_button_friendButtonClicked__ = UnityEngine.Events.UnityAction(OnFriendButtonClicked, self)
    self.controls.friendButton.onClick:AddListener(self.__event_button_friendButtonClicked__)

    -- 注册 大书库 页面 --
    self.__event_button_achieveButtonClicked__ = UnityEngine.Events.UnityAction(OnAchieveButtonClicked, self)
    self.controls.achieveButton.onClick:AddListener(self.__event_button_achieveButtonClicked__)

    -- 注册 充值 页面 --
    self.__event_button_chargeButtonClicked__ = UnityEngine.Events.UnityAction(OnChargeButtonClicked, self)
    self.controls.chargeButton.onClick:AddListener(self.__event_button_chargeButtonClicked__)

    -- -- 注册 新手礼包 页面 --
    -- self.__event_button_giftButtonClicked__ = UnityEngine.Events.UnityAction(OnGiftButtonClicked, self)
    -- self.controls.giftButton.onClick:AddListener(self.__event_button_giftButtonClicked__)

    -- 注册 签到 页面 --
    self.__event_button_signinButtonClicked__ = UnityEngine.Events.UnityAction(OnSigninButtonClicked, self)
    self.controls.signinButton.onClick:AddListener(self.__event_button_signinButtonClicked__)

    -- 注册 活动 页面 --
    self.__event_button_activityButtonClicked__ = UnityEngine.Events.UnityAction(OnActivityButtonClicked, self)
    self.controls.activityButton.onClick:AddListener(self.__event_button_activityButtonClicked__)

    -- 注册 奇遇 页面 --
    self.__event_button_encounterButtonClicked__ = UnityEngine.Events.UnityAction(OnEncounterButtonClicked, self)
    self.controls.encounterButton.onClick:AddListener(self.__event_button_encounterButtonClicked__)

    -- 注册 聊天 页面
    self.__event_button_chatButtonClicked__ = UnityEngine.Events.UnityAction(self.OnChatButtonClicked, self)
    self.controls.chatButton.onClick:AddListener(self.__event_button_chatButtonClicked__)

      -- 头像
    self.__event_button_PlayerInfoButtonClicked__ = UnityEngine.Events.UnityAction(self.OnPlayerInfoButtonClicked, self)
    self.controls.PlayerInfoButton.onClick:AddListener(self.__event_button_PlayerInfoButtonClicked__)
   
    -- Vip
    self.__event_button_VipButtonClicked__ = UnityEngine.Events.UnityAction(self.OnVipButtonClicked, self)
    self.VipButton.onClick:AddListener(self.__event_button_VipButtonClicked__)

     -- boss
    self.__event_button_BossButtonClicked__ = UnityEngine.Events.UnityAction(OnBossButtonClicked, self)
    self.controls.bossButton.onClick:AddListener(self.__event_button_BossButtonClicked__)

     -- 冒险
    self.__event_button_AdventureButtonClicked__ = UnityEngine.Events.UnityAction(OnAdventureButtonClicked, self)
    self.controls.adventureButton.onClick:AddListener(self.__event_button_AdventureButtonClicked__)

    --黑市
    self.__event_button_BlackMarketButtonClicked__ = UnityEngine.Events.UnityAction(OnBlackMarketClicked, self)
    self.controls.blackMarketButton.onClick:AddListener(self.__event_button_BlackMarketButtonClicked__)

  --限时神降
    self.__event_button_LimiteButtonClicked__ = UnityEngine.Events.UnityAction(OnLimiteButtonClicked, self)
    self.controls.limiteButton.onClick:AddListener(self.__event_button_LimiteButtonClicked__)

end

function MainUINode:UnregisterControlEvents()
   -- 取消注册限时神降 --
    if self.__event_button_LimiteButtonClicked__ then
        self.controls.limiteButton.onClick:RemoveListener(self.__event_button_LimiteButtonClicked__)
        self.__event_button_LimiteButtonClicked__ = nil
    end
      -- 取消注册 boss 页面 --
    if self.__event_button_BossButtonClicked__ then
        self.controls.bossButton.onClick:RemoveListener(self.__event_button_BossButtonClicked__)
        self.__event_button_BossButtonClicked__ = nil
    end

    --取消注册黑市
    if self.__event_button_BlackMarketButtonClicked__ then
        self.controls.blackMarketButton.onClick:RemoveListener(self.__event_button_BlackMarketButtonClicked__)
        self.__event_button_BlackMarketButtonClicked__ = nil
    end

      -- 取消注册 冒险 页面 --
    if self.__event_button_AdventureButtonClicked__ then
        self.controls.adventureButton.onClick:RemoveListener(self.__event_button_AdventureButtonClicked__)
        self.__event_button_AdventureButtonClicked__ = nil
    end

    -- 取消注册 角色 页面 --
    if self.__event_button_heroCardButtonClicked__ then
        self.controls.heroCardButton.onClick:RemoveListener(self.__event_button_heroCardButtonClicked__)
        self.__event_button_heroCardButtonClicked__ = nil
    end

    -- 取消注册 酒馆 页面 --
    if self.__event_button_tavernButtonClicked__ then
        self.controls.tavernButton.onClick:RemoveListener(self.__event_button_tavernButtonClicked__)
        self.__event_button_tavernButtonClicked__ = nil
    end

    -- 取消注册 背包 页面 --
    if self.__event_button_backpackButtonClicked__ then
        self.controls.backpackButton.onClick:RemoveListener(self.__event_button_backpackButtonClicked__)
        self.__event_button_backpackButtonClicked__ = nil
    end

    -- 取消注册 任务 页面 --
    if self.__event_button_taskButtonClicked__ then
        self.controls.taskButton.onClick:RemoveListener(self.__event_button_taskButtonClicked__)
        self.__event_button_taskButtonClicked__ = nil
    end

    -- 取消注册 好友 页面 --
    if self.__event_button_friendButtonClicked__ then
        self.controls.friendButton.onClick:RemoveListener(self.__event_button_friendButtonClicked__)
        self.__event_button_friendButtonClicked__ = nil
    end

    -- 取消注册 大书库 页面 --
    if self.__event_button_achieveButtonClicked__ then
        self.controls.achieveButton.onClick:RemoveListener(self.__event_button_achieveButtonClicked__)
        self.__event_button_achieveButtonClicked__ = nil
    end

    -- 取消注册 充值 页面 --
    if self.__event_button_chargeButtonClicked__ then
        self.controls.chargeButton.onClick:RemoveListener(self.__event_button_chargeButtonClicked__)
        self.__event_button_chargeButtonClicked__ = nil
        end

    -- -- 取消注册 新手礼包 页面 --
    -- if self.__event_button_giftButtonClicked__ then
    --     self.controls.giftButton.onClick:RemoveListener(self.__event_button_giftButtonClicked__)
    --     self.__event_button_giftButtonClicked__ = nil
    -- end

    -- 取消注册 签到 页面 --
    if self.__event_button_signinButtonClicked__ then
        self.controls.signinButton.onClick:RemoveListener(self.__event_button_signinButtonClicked__)
        self.__event_button_signinButtonClicked__ = nil
    end

    -- 取消注册 活动 页面 --
    if self.__event_button_activityButtonClicked__ then
        self.controls.activityButton.onClick:RemoveListener(self.__event_button_activityButtonClicked__)
        self.__event_button_activityButtonClicked__ = nil
    end

    -- 取消注册 奇遇 页面 --
    if self.__event_button_encounterButtonClicked__ then
        self.controls.encounterButton.onClick:RemoveListener(self.__event_button_encounterButtonClicked__)
        self.__event_button_encounterButtonClicked__ = nil
    end

    -- 取消注册 聊天 页面 --
    if self.__event_button_chatButtonClicked__ then
        self.controls.chatButton.onClick:RemoveListener(self.__event_button_chatButtonClicked__)
        self.__event_button_chatButtonClicked__ = nil
    end



      -- 取消注册 聊天 页面 --
    if self.__event_button_PlayerInfoButtonClicked__ then
        self.controls.PlayerInfoButton.onClick:RemoveListener(self.__event_button_PlayerInfoButtonClicked__)
        self.__event_button_PlayerInfoButtonClicked__ = nil
    end

       -- 取消注册Vip页面 --
    if self.__event_button_VipButtonClicked__ then
        self.VipButton.onClick:RemoveListener(self.__event_button_VipButtonClicked__)
        self.__event_button_VipButtonClicked__ = nil
    end


end

function MainUINode:OnChapterButtonClicked()
    local myGame = self:GetGame()
    local sceneManager = myGame:GetSceneManager()
    local CheckpointSceneClass = require "Scenes.CheckpointScene"
    sceneManager:PushScene(CheckpointSceneClass.New())
end

function MainUINode:OnShortcutButton__1_Clicked()
    local sceneManager = self:GetGame():GetSceneManager()

    local HeroSceneClass = require "Scenes.HeroScene"
    sceneManager:PushScene(HeroSceneClass.New())
end

function MainUINode:OnMailBtnClicked()
    local isOpen = utility.IsCanOpenModule(KSystemBasis_MailID)
    if not isOpen then
        return
    end
    local windowManager = self:GetGame():GetWindowManager()
    windowManager:Show(require "GUI.Modules.MailModule")
end

--活动按钮事件
function MainUINode:OnActiveButtonClicked()
    -- local windowManager = self:GetGame():GetWindowManager()
    -- windowManager:Show(require "GUI.Active.ActivityFirstChargeCls")
    -- local windowManager = self:GetGame():GetWindowManager()
    -- windowManager:Show(require "GUI.Active.ProgressChargeAward")
    -- local windowManager = self:GetGame():GetWindowManager()
    -- windowManager:Show(require "GUI.SkinSystem.SkinInfoCls",10000126)
	self:ActivityListQueryRequest()
    self:OperationActicityQueryRequest()
	
end
function MainUINode:OperationActicityQueryRequest()
    hzj_print("OperationActicityQueryRequest")
    self.operationActicityQuery=false
    self:GetGame():SendNetworkMessage( require "Network/ServerService".OperationActicityQueryRequest())
end

function MainUINode:ActivityListQueryRequest()
    self.activityListQuery=false
	self:GetGame():SendNetworkMessage( require "Network/ServerService".ActivityListQueryRequest())
end

-- function MainUINode:ShopHeishiQueryRequest()
--     --黑市Query请求
--     self:GetGame():SendNetworkMessage( require "Network/ServerService".ShopHeishiQueryRequest())
-- end
function MainUINode:AllActivityCallBack()
    hzj_print("self.operationActicityQuery",self.operationActicityQuery,self.activityListQuery)
    if self.operationActicityQuery and self.activityListQuery then
        if(#self.activityList.activityId ~= 0 or #self.operationActicity.activities~=0)  then
           local sceneManager = self:GetGame():GetSceneManager()
            local ActiveSenceCls = require "GUI.Active.ActiveSence"
            sceneManager:PushScene(ActiveSenceCls.New(self.activityList.activityId,self.activityList, self.operationActicity))
        else
            local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
            local windowManager = utility.GetGame():GetWindowManager()
            local hintStr = string.format("活动暂未开启")
            windowManager:Show(ErrorDialogClass, hintStr)
        end

    end
    
end

function MainUINode:OperationActivityQueryResult(msg)
    hzj_print("OperationActivityQueryResult")
    self.operationActicityQuery=true
    self.operationActicity=msg
    self:AllActivityCallBack()

end
function MainUINode:OnActivityQueryResult(msg)

    self.activityListQuery=true
    self.activityList=msg
    self:AllActivityCallBack()
    -- print(#msg.activityId)
    -- if(#msg.activityId ~= 0) then
	   -- local sceneManager = self:GetGame():GetSceneManager()
    --     local ActiveSenceCls = require "GUI.Active.ActiveSence"
    --     sceneManager:PushScene(ActiveSenceCls.New(msg.activityId,msg))
    -- else
    --     local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
    --     local windowManager = utility.GetGame():GetWindowManager()

    --     local hintStr = string.format("活动暂未开启")
    --     windowManager:Show(ErrorDialogClass, hintStr)
    -- end
end


---强化按钮事件
function MainUINode:OnPetPowerUpButtonClicked()
    print("MainUINode:OnPetPowerUpButtonClicked()")
    local windowManager = self:GetGame():GetWindowManager()
    windowManager:Show(require "GUI.Pet.PetPowerUp",10000014,10140038)
end

---进阶按钮事件 
function MainUINode:OnPetUpGradeButtonClicked()
    print("MainUINode:OnPetUpGradeButtonClicked()")
    local windowManager = self:GetGame():GetWindowManager()
    windowManager:Show(require "GUI.Pet.PetUpGrade",10000014,10140038)

end



--卡牌穿戴装备
function MainUINode:OnChangeEquipButtonClicked()
    print("MainUINode:OnChallengButtonClicked()")
    local windowManager = self:GetGame():GetWindowManager()
    --ID  装备类型 装备位置
    windowManager:Show(require "GUI.ChangeEquip.ChangeEquip",10000014,1,1)

end


function MainUINode:OnCardTalentButtonClicked()
    print("MainUINode:OnCardTalentButtonClicked()")
    local windowManager = self:GetGame():GetWindowManager()
    windowManager:Show(require "GUI.Talent.Talent",10000014)

end

--显示精灵树
function MainUINode:OnElvenTreeButtonClicked()
    local levelLimit = require "StaticData.SystemConfig.SystemBasis":GetData(KSystemBasis_ElvenTreeID):GetMinLevel()
    local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    if userData:GetLevel() < levelLimit then
        local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
        local windowManager = self:GetGame():GetWindowManager()
        local hintStr = string.format(CommonStringTable[0],levelLimit)
        windowManager:Show(ErrorDialogClass, hintStr)
        return true
    end

    local sceneManager = self:GetGame():GetSceneManager()
    local ElvenTreeCls = require "GUI.ElvenTree.ElvenTree"
    sceneManager:PushScene(ElvenTreeCls.New())
end

function MainUINode:OnProtectPrincessClicked()
    local levelLimit = require "StaticData.SystemConfig.SystemBasis":GetData(KSystemBasis_DefendPrincess):GetMinLevel()
    local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    if userData:GetLevel() < levelLimit then
        local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
        local windowManager = self:GetGame():GetWindowManager()
        local hintStr = string.format(CommonStringTable[0],levelLimit)
        windowManager:Show(ErrorDialogClass, hintStr)
        return true
    end



    local sceneManager = self:GetGame():GetSceneManager()
    local ProtectPrincessClass = require "Scenes.ProtectThePrincessScene"
    sceneManager:PushScene(ProtectPrincessClass.New())

    -- local windowManager = self:GetGame():GetWindowManager()
    -- windowManager:Show(require "GUI.Guild.Guild")

    -- local sceneManager = self:GetGame():GetSceneManager()
    -- local GuildCls = require "GUI.Guild.Guild"
    -- sceneManager:PushScene(GuildCls.New())
end

function MainUINode:OnGuildButtonClicked()
    local levelLimit = require "StaticData.SystemConfig.SystemBasis":GetData(KSystemBasis_GuildID):GetMinLevel()
    local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    if userData:GetLevel() < levelLimit then
        local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
        local windowManager = self:GetGame():GetWindowManager()
        local hintStr = string.format(CommonStringTable[0],levelLimit)
        windowManager:Show(ErrorDialogClass, hintStr)
        return true
    end

    local sceneManager = self:GetGame():GetSceneManager()
    sceneManager:PushScene(require "GUI.Guild.Guild".New(0))
end

function MainUINode:OnChallengButtonClicked()
    -- local levelLimit = require "StaticData.SystemConfig.SystemBasis":GetData(KSystemBasis_Chanllage):GetMinLevel()
    -- local UserDataType = require "Framework.UserDataType"
    -- local userData = self:GetCachedData(UserDataType.PlayerData)
    -- if userData:GetLevel() < levelLimit then
    --     local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
    --     local windowManager = self:GetGame():GetWindowManager()
    --     local hintStr = string.format(CommonStringTable[0],levelLimit)
    --     windowManager:Show(ErrorDialogClass, hintStr)
    --     return true
    -- end

    local isOpen = utility.IsCanOpenModule(KSystemBasis_Explore)
    if not isOpen then
        return
    end
     local sceneManager = utility:GetGame():GetSceneManager()
    local scene = require "GUI.Explore.Explore"
    sceneManager:PushScene(scene.New())
    
end

function MainUINode:OnChatButtonClicked()
    local isOpen = utility.IsCanOpenModule(KSystemBasis_ChatID)
    if not isOpen then
        return
    end
    local windowManager = self:GetGame():GetWindowManager()
    windowManager:Show(require "GUI.Chat")
end

function MainUINode:OnPlayerInfoButtonClicked()
--    local myGame = self:GetGame()
--    local sceneManager = myGame:GetSceneManager()
--    local PersonalInformation = require "GUI.PersonalInformation"
--    sceneManager:PushScene(PersonalInformation.New())
    local windowManager = self:GetGame():GetWindowManager()
    windowManager:Show(require "GUI.PersonalInformation")
end 

function MainUINode:OnArenaButtonClicked()
    local levelLimit = require"StaticData.SystemConfig.SystemBasis":GetData(KSystemBasis_ArenaID):GetMinLevel()

    local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    if userData:GetLevel() < levelLimit then
        local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
        local windowManager = self:GetGame():GetWindowManager()

        local hintStr = string.format(CommonStringTable[0],levelLimit)
        windowManager:Show(ErrorDialogClass, hintStr)
        return true
    end

    local sceneManager = self:GetGame():GetSceneManager()

    local ArenaCls = require "GUI.Arena.Arena"
    sceneManager:PushScene(ArenaCls.New())

    -- local GemCombineCls = require "GUI.GemCombine.GemCombineCls"
    -- sceneManager:PushScene(GemCombineCls.New())
end

function MainUINode:OnNGCButtonClicked()
    local sceneManager=self:GetGame():GetSceneManager()

    local NGCCls=require"GUI.NGC.NGC"
    sceneManager:PushScene(NGCCls.New())
end

local function RefreshRedDotWhilePlayerIsUpdating(self)
    UpdateKameRedDot(self)
end

function MainUINode:InitView()
    local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    self.controls.TheMainCharacterExpFill.fillAmount = userData:GetExp()/self:GetCurrenLevelIntervarExp()
    self.controls.characterNameLbl.text = userData:GetName()
    self.controls.characterLevelLbl.text = userData:GetLevel()
    self.controls.characterVipLbl.text = userData:GetVip()
    self:LoadImageBycardID(userData:GetHeadCardID()) -- LoadHeadImage
    if userData:GetLevel()>=20 then
        self.upLevel=true
    else
        self.upLevel=false
    end
	
	print("*********",userData:GetPayState())
--------------- firstPay--------------
    if userData:GetPayState()==0 then
        self.firstPay=false
    else
        self.firstPay=true
    end
-------------------------------------------
    self:ShowTips()
    self:ShowNextOpenInfo()

    -- 在玩家更新的时候更新红点
    RefreshRedDotWhilePlayerIsUpdating(self)
end

function MainUINode:ShowNextOpenInfo()
    local PlayerPromote = require "StaticData.PlayerPromote"
    local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    local PlayerPromoteData= PlayerPromote:GetData(userData:GetLevel())
    local willOpenList = PlayerPromoteData:GetWillOpenSystem()
    if #willOpenList>=1 then

        local systemBasisData = require"StaticData.SystemConfig.SystemBasis"
        local systemBasisInfoData = require"StaticData.SystemConfig.SystemBasisInfo"
        local info = systemBasisData:GetData(willOpenList[1]):GetInfo()
        self.nextOpenLevelParent.gameObject:SetActive(true)
        self.nextOpenLevel.text=systemBasisData:GetData(willOpenList[1]):GetMinLevel().."级开启:"    
        self.nextOpenLevelInfo.text=systemBasisInfoData:GetData(info):GetName()
    else

        self.nextOpenLevelParent.gameObject:SetActive(false)
    end
    -- for i=1,#willOpenList do
    --     debug_print(systemBasisData:GetData(willOpenList[i]):GetMinLevel(),"&&&&&&&&&&&&&&&&&&&&&&")
        
    --     local info = systemBasisData:GetData(willOpenList[i]):GetInfo()
    --     local name = systemBasisInfoData:GetData(info):GetName()
    --     debug_print(info,name,)


    --     --self.willOpens[i].willLevel.text ='开放等级'..systemBasisData:GetData(willOpenList[i]):GetMinLevel()
    --     debug_print(systemBasisData:GetData(willOpenList[i]):GetMinLevel())

    --     --self.willOpens[i].willName.text =name
    -- end


end


function MainUINode:GetCurrenLevelIntervarExp()
    return utility.GetCurrenLevelIntervarExp()
end

function MainUINode:RegisterNetworkEvents()
    local myGame = utility.GetGame()
    --myGame:RegisterMsgHandler(net.S2CTalkResultResult, self, self.OnSystemNoticeResponse)
    myGame:RegisterMsgHandler(net.S2CLoadPlayerResult, self, self.OnLoadPlayerResponse)
    myGame:RegisterMsgHandler(net.S2CGuideGonggaoResult,self,self.OnGuideGonggaoResponse)
	myGame:RegisterMsgHandler(net.S2CShopHeishiQueryResult,self,self.OnBlackMarketQueryResult)
	myGame:RegisterMsgHandler(net.ActivityListQueryResult,self,self.OnActivityQueryResult)
    myGame:RegisterMsgHandler(net.S2CPlayerLevelUpResult,self,self.OnPlayerLevelUpResult)
    myGame:RegisterMsgHandler(net.S2CTiliCountDownResult,self,self.TiliCountDownResult)
    myGame:RegisterMsgHandler(net.S2COperationActivityQueryResult,self,self.OperationActivityQueryResult)
end

function MainUINode:UnregisterNetworkEvents()
    local myGame = utility.GetGame()
    --myGame:UnRegisterMsgHandler(net.S2CTalkResultResult, self, self.OnSystemNoticeResponse)
    myGame:UnRegisterMsgHandler(net.S2CLoadPlayerResult, self, self.OnLoadPlayerResponse)
    myGame:UnRegisterMsgHandler(net.S2CGuideGonggaoResult,self,self.OnGuideGonggaoResponse)
	myGame:UnRegisterMsgHandler(net.S2CShopHeishiQueryResult,self,self.OnBlackMarketQueryResult)
	myGame:UnRegisterMsgHandler(net.ActivityListQueryResult,self,self.OnActivityQueryResult)
    myGame:UnRegisterMsgHandler(net.S2CPlayerLevelUpResult,self,self.OnPlayerLevelUpResult)
    myGame:UnRegisterMsgHandler(net.S2CTiliCountDownResult,self,self.TiliCountDownResult)
    myGame:UnRegisterMsgHandler(net.S2COperationActivityQueryResult,self,self.OperationActivityQueryResult)
end


function MainUINode:CountTimedown()
    if self.timeDownFlag then
        if self.countTimeDown<0 then
            self.timeDownFlag=false
            self.Power.gameObject:SetActive(false)
            self:GetGame():SendNetworkMessage( require "Network/ServerService".TiliCountDownRequest(3))

        else
            if os.time() - self.lastTimeDown >= 1 then
                self.lastTimeDown=os.time()
                self.countTimeDown=self.countTimeDown-1
            else

            end
            self.RecoverTime.text=utility.ConvertTime(self.countTimeDown)
        end
    end
end
function MainUINode:TiliCountDownResult(msg)

    debug_print(msg.oneTime,"TiliCountDownResult回复一点体力需要时间",tonumber(msg.oneTime))
    local timer=tonumber(msg.oneTime)
    if timer>0 then
        debug_print(msg.oneTime,"\\\\\\\\\\\\\\\\\\\\\\\\\\")
        self.timeDownFlag=true
        self.lastTimeDown=0
        self.countTimeDown=timer
        self.Power.gameObject:SetActive(true)

    else
         self.timeDownFlag=false
        self.Power.gameObject:SetActive(false)

    end

end


local function GetChatCache(self)
    local UserDataType = require "Framework.UserDataType"
    local dataCacheMgr = self:GetGame():GetDataCacheManager()
    local cached = dataCacheMgr:GetData(UserDataType.ChatMessageData)
    return cached
end

function MainUINode:ChangeChatMessage(msg)
    local lastmsg = GetChatCache(self):GetLastMsg()
    if lastmsg ~= nil then
        self.controls.chatMessageLabel.text = lastmsg.fromPlayerName..":"..lastmsg.msg
    end
end

--战队升级
function MainUINode:OnPlayerLevelUpResult(msg)
    local windowManager = self:GetGame():GetWindowManager()
    windowManager:Show(require "GUI.LevelUpPanel",msg)
end

function MainUINode:SelectChatMessage()
    local levelLimit = require"StaticData.SystemConfig.SystemBasis":GetData(KSystemBasis_ChatID):GetMinLevel()

    local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    if userData:GetLevel() >= levelLimit then
        local cached = GetChatCache(self)
        if cached == nil then
            self:GetGame():SendNetworkMessage( require"Network/ServerService".TalkQueryRequest())
        else
            local lastmsg = cached:GetLastMsg()
            if lastmsg ~= nil then
                self.controls.chatMessageLabel.text = lastmsg.fromPlayerName..":"..lastmsg.msg
            end
        end
    end
end

function MainUINode:OnVipButtonClicked()
    local windowManager = self:GetWindowManager()
    local VipSenceCls = require "GUI.VIP.VipSence"
    windowManager:Show(VipSenceCls)
end

function MainUINode:OnNormalShopButtonClicked()
      -- 商店页面点击
    local levelLimit = require"StaticData.SystemConfig.SystemBasis":GetData(KSystemBasis_ShopID):GetMinLevel()

    local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    if userData:GetLevel() < levelLimit then
        local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
        local windowManager = self:GetGame():GetWindowManager()

        local hintStr = string.format(CommonStringTable[0],levelLimit)
        windowManager:Show(ErrorDialogClass, hintStr)
        return true
    end
    local windowManager = self:GetGame():GetWindowManager()
    windowManager:Show(require "GUI.Shop.Shop",1)
end



function MainUINode:BlackMarketEnter()
	local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
	
	local levelLimit = require "StaticData.SystemConfig.SystemBasis":GetData(KSystemBasis_BlackMarketID):GetMinLevel()
	-- local levelLimit = 0
	-- self:BlackMarketVip()
	if userData:GetLevel() < levelLimit then
		local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
        local windowManager = utility.GetGame():GetWindowManager()

        local hintStr = string.format(CommonStringTable[0],levelLimit)
        windowManager:Show(ErrorDialogClass, hintStr)
	else
		-- self:ShopHeishiQueryRequest()
		self:BlackMarketShow()
	end
end

function MainUINode:BlackMarketShow()
	--打开黑市界面
	local windowManager = utility.GetGame():GetWindowManager()
	windowManager:Show(require "GUI.Shop.Shop",KShopType_BlackMarket,self.blackForever)
end

function MainUINode:ShopHeishiQueryRequest()
	--黑市Query请求
    local levelLimit = require "StaticData.SystemConfig.SystemBasis":GetData(KSystemBasis_BlackMarketID):GetMinLevel()
    local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    if userData:GetLevel() >= levelLimit then
	   self:GetGame():SendNetworkMessage( require "Network/ServerService".ShopHeishiQueryRequest())
    end
end

function MainUINode:OnBlackMarketQueryResult(msg)
	--黑市Query结果
	if msg.remainTime == -1 then
        self.controls.blackMarketButton.gameObject:SetActive(true)
		self.controls.blackMarketTimeText.gameObject:SetActive(false)
        self.blackForever = true
		-- self:BlackMarketShow()
	end
	if msg.remainTime > 0 then
        self.controls.blackMarketButton.gameObject:SetActive(true)
		self.blackMarketTime = msg.remainTime
		self.lastTime =0
		self.controls.blackMarketTimeText.gameObject:SetActive(true)
		self.controls.blackMarketTimeText.text = utility.ConvertTime(self.blackMarketTime)
		-- self:BlackMarketShow()
		-- self:BlackMarketVip()
	end
	if msg.remainTime == 0 then
        self.controls.blackMarketButton.gameObject:SetActive(false)
		self.controls.blackMarketTimeText.gameObject:SetActive(false)
	end	
end


function MainUINode:OnBlackMarketForeverResult()
	
end

function MainUINode:BlackMarketVip()
	--黑市判断Vip
	local vipMinLv = 9
	local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
	if userData:GetVip() >= vipMinLv then
		local windowManager = utility.GetGame():GetWindowManager()
		local SystemConfigMgr = require "StaticData.SystemConfig.SystemConfig"
		str = string.format(str,SystemConfigMgr:GetData(2):GetParameNum()[0])
		windowManager:Show(require "GUI.BlackMarket.BlackMarketForever", str)
	end
end

function MainUINode:BlackeMarketTimeShow()
	--黑市开启
	-- local utility = require "Utils.Utility"
	-- local LocalDataType = require "LocalData.LocalDataType"
	-- local localData = utility.DropLocalData(LocalDataType.FBBattleResult)
	-- if msg == nil then
		-- self.controls.blackMarketTimeText.gameObject:SetActive(false)
	-- else
	-- self:ShopHeishiQueryRequest()
		-- local fbMsg = localData:GetMainData()
	-- if msg.showHeishi then
	local windowManager = utility.GetGame():GetWindowManager()
	if self.blackMarketTime ~= nil then
		windowManager:Show(require "GUI.BlackMarket.BlackMarket",self.blackMarketTime)
	end
	
		
	-- else
		-- self.controls.blackMarketTimeText.gameObject:SetActive(false)
	-- end
	-- end
	
end

function MainUINode:Countdown()
	-- 黑市时间倒计时
	if self.blackMarketTime ~= nil then
		if self.blackMarketTime <= 0 then
			self.controls.blackMarketTimeText.gameObject:SetActive(false)
		else
		--	self.countTime=self.countTime-Time.deltaTime
			if os.time() - self.lastTime >= 1 then
				self.lastTime = os.time()
				self.blackMarketTime = self.blackMarketTime - 1
			end
			--print(self.blackMarketTime)
			self.controls.blackMarketTimeText.text = utility.ConvertTime(self.blackMarketTime)
		end	
	end
end

function MainUINode:UpdateCountdownView()
	-- 倒计时显示设置 清空倒计时
	self.cdTime = 0
	self.controls.blackMarketTimeText.gameObject:SetActive(false)
end

function MainUINode:OnLoadPlayerResponse(msg)
    self:InitView()
end

function MainUINode:OnGuideGonggaoResponse(msg)
    local SystemNoticeClass = require "GUI.SystemNotice"
    local windowManager = self:GetGame():GetWindowManager()
    windowManager:Show(SystemNoticeClass, msg.msg)
    self.GuideGonggao = false
end

function MainUINode:OnGuideGonggaoRequest()
    if self.GuideGonggao == true then
        self:GetGame():SendNetworkMessage( require"Network/ServerService".GuideGonggaoRequest())
    end
end

function MainUINode:OnEnterPitClicked()
    local levelLimit = require "StaticData.SystemConfig.SystemBasis":GetData(kSystemBasis_TowerID):GetMinLevel()
    local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    if userData:GetLevel() < levelLimit then
        local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
        local windowManager = self:GetGame():GetWindowManager()
        local hintStr = string.format(CommonStringTable[0],levelLimit)
        windowManager:Show(ErrorDialogClass, hintStr)
        return true
    end
    local sceneManager = self:GetGame():GetSceneManager()
    local GemCombineCls = require "GUI.Tower.Tower"
    sceneManager:PushScene(GemCombineCls.New())
    -- error("爬塔!!")
end

function MainUINode:OnEnterCastleClicked()
    -- 龟仙屋
    local sceneManager = self:GetGame():GetSceneManager()
    local EnterCastlsCls = require "GUI.KameHouse"
    sceneManager:PushScene(EnterCastlsCls.New())
end





return MainUINode