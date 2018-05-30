local BaseNodeClass = require "Framework.Base.UIScene"
local utility = require "Utils.Utility"
local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local ExploreCls = Class(BaseNodeClass)

function ExploreCls:Ctor()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function ExploreCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/Explore', function(go)
		self:BindComponent(go)
	end)
end

function ExploreCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end
local function DelayStartSystemGuide(self,data,index)
	while (not data:IsReady()) do
		coroutine.step(1)
	end
	hzj_print("*****")
	--神秘龙穴探险系统引导
	utility.GetGame():GetSystemGuideManager():SetNeetSystemGuideID(kSystem_Guide[index].systemGuideID,self)


end
function ExploreCls:OnResume()
	-- 界面显示时调用
	ExploreCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self.game:SendNetworkMessage(require "Network.ServerService".StartAdventureRequest())
	self:ScheduleUpdate(self.Update)
	self.Button.enabled=true
	self.Explore_Effect2.gameObject:SetActive(false)
	self.Explore_Effect.gameObject:SetActive(true)
	self.BoatAnim:CrossFade("xuanhuan", 0);	
	self.SkyAnim.speed=0.3
	self.SeaAnim.speed=1
	utility.GetGame():GetSystemGuideManager():SetNeetSystemGuideID(kSystem_Guide[2].systemGuideID,self)
	self:StartCoroutine(DelayStartSystemGuide,self.itemsChild[1],4)
	self:StartCoroutine(DelayStartSystemGuide,self.itemsChild[2],7)
	self:StartCoroutine(DelayStartSystemGuide,self.itemsChild[3],8)
	self:StartCoroutine(DelayStartSystemGuide,self.itemsChild[4],9)


end

function ExploreCls:OnPause()
	-- 界面隐藏时调用
	ExploreCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function ExploreCls:OnEnter()
	-- Node Enter时调用
	ExploreCls.base.OnEnter(self)
end

function ExploreCls:OnExit()
	-- Node Exit时调用
	ExploreCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function ExploreCls:InitControls()
	local transform = self:GetUnityTransform()
	self.game = utility:GetGame()
	
	self.BackButton = transform:Find('Back/BackButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.Button = transform:Find('Top/Button'):GetComponent(typeof(UnityEngine.UI.Button))
	self.FiveButton = transform:Find('Top/FiveButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.TenButton = transform:Find('Top/TenButton'):GetComponent(typeof(UnityEngine.UI.Button))
	--次数
	self.AllNum = transform:Find('Blackbg/RemainNum/Numbg/AllNum'):GetComponent(typeof(UnityEngine.UI.Text))
	self.AddButton = transform:Find('Blackbg/RemainNum/AddButton'):GetComponent(typeof(UnityEngine.UI.Button))
	--倒计时
	self.NeedTime = transform:Find('Blackbg/RecoverTime/Timebg/NeedTime'):GetComponent(typeof(UnityEngine.UI.Text))
	--按钮父物体
	self.layout = transform:Find('Base/Scroll View/Viewport/Content')
	
	self.tipText = transform:Find('Top/Text'):GetComponent(typeof(UnityEngine.UI.Text))



	self.BoatAnim=transform:Find('Sea/Base/Boat'):GetComponent(typeof(UnityEngine.Animator))
	self.SeaAnim=transform:Find('Sea'):GetComponent(typeof(UnityEngine.Animator))
	self.SkyAnim=transform:Find('Sky'):GetComponent(typeof(UnityEngine.Animator))
	self.Explore_Effect2=transform:Find('Sea/Base/Explore_Effect2')
	self.Explore_Effect=transform:Find('Sea/Base/Explore_Effect')
	self.Explore_Effect2.gameObject:SetActive(false)
	self.Explore_Effect.gameObject:SetActive(true)
	self:InitViews()

end
function ExploreCls:RegisterControlEvents()
	-- 注册 BackButton 的事件
	self.__event_button_onBackButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBackButtonClicked, self)
	self.BackButton.onClick:AddListener(self.__event_button_onBackButtonClicked__)

	-- 注册 Button 的事件
	self.__event_button_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnButtonClicked, self)
	self.Button.onClick:AddListener(self.__event_button_onButtonClicked__)
	-- 注册 FiveButton 的事件
	self.__event_button_onFiveButtonClicked__ = UnityEngine.Events.UnityAction(self.OnFiveButtonClicked, self)
	self.FiveButton.onClick:AddListener(self.__event_button_onFiveButtonClicked__)
	-- 注册 TenButton 的事件
	self.__event_button_onTenButtonClicked__ = UnityEngine.Events.UnityAction(self.OnTenButtonClicked, self)
	self.TenButton.onClick:AddListener(self.__event_button_onTenButtonClicked__)

	-- 注册 AddButton 的事件
	self.__event_button_onAddButtonClicked__ = UnityEngine.Events.UnityAction(self.OnAddButtonClicked, self)
	self.AddButton.onClick:AddListener(self.__event_button_onAddButtonClicked__)

end

function ExploreCls:UnregisterControlEvents()		

	-- 取消注册 FiveButton 的事件
	if self.__event_button_onFiveButtonClicked__ then
		self.FiveButton.onClick:RemoveListener(self.__event_button_onFiveButtonClicked__)
		self.__event_button_onFiveButtonClicked__ = nil
	end
	-- 取消注册 TenButton 的事件
	if self.__event_button_onTenButtonClicked__ then
		self.TenButton.onClick:RemoveListener(self.__event_button_onTenButtonClicked__)
		self.__event_button_onTenButtonClicked__ = nil
	end



	-- 取消注册 BackButton 的事件
	if self.__event_button_onBackButtonClicked__ then
		self.BackButton.onClick:RemoveListener(self.__event_button_onBackButtonClicked__)
		self.__event_button_onBackButtonClicked__ = nil
	end

	-- 取消注册 Button 的事件
	if self.__event_button_onButtonClicked__ then
		self.Button.onClick:RemoveListener(self.__event_button_onButtonClicked__)
		self.__event_button_onButtonClicked__ = nil
	end

	-- 取消注册 AddButton 的事件
	if self.__event_button_onAddButtonClicked__ then
		self.AddButton.onClick:RemoveListener(self.__event_button_onAddButtonClicked__)
		self.__event_button_onAddButtonClicked__ = nil
	end

end

function ExploreCls:RegisterNetworkEvents()
	 self.game:RegisterMsgHandler(net.S2CStartAdventureResultMessage, self, self.StartAdventureResult)
	self.game:RegisterMsgHandler(net.S2CAdvanceAdventureResultMessage, self, self.AdvanceAdventureResult)
	self.game:RegisterMsgHandler(net.S2CBuyAdventureTimesResultMessage, self, self.BuyAdventureTimesResult)
end

function ExploreCls:UnregisterNetworkEvents()
	self.game:UnRegisterMsgHandler(net.S2CStartAdventureResultMessage, self, self.StartAdventureResult)
	self.game:UnRegisterMsgHandler(net.S2CAdvanceAdventureResultMessage, self, self.AdvanceAdventureResult)
	self.game:UnRegisterMsgHandler(net.S2CBuyAdventureTimesResultMessage, self, self.BuyAdventureTimesResult)

    



end

function  ExploreCls:Update()
	if  self.flagTime then
		if os.time()-self.lastT>=1 then
			self.lastT=os.time()
			self.countTime=self.countTime-1
		end

		if self.countTime < 0 then
			self.flagTime=false
			self.NeedTime.text=""
			self.game:SendNetworkMessage(require "Network.ServerService".StartAdventureRequest())

		else
			self.NeedTime.text=utility.ConvertTime(self.countTime)

		end

	end

end

local function ResetTime(self,time)
	hzj_print("time",time)
	local  num =  tonumber(self.msg.recoveryTime)
	self.countTime=self.msg.recoveryTime
	if num>0 then
		self.flagTime=true
		
	end
	self.lastT=0
end
function ExploreCls:SetExploreInfo()
	-- body
	self.AllNum.text=self.msg.challengeNum

	local num =  tonumber(self.msg.recoveryTime)
	
	if num>0 then
		self.NeedTime.text=self.msg.recoveryTime
	else
		self.NeedTime.text=""
	end
	
	ResetTime(self,self.msg.recoveryTime)
	

end

function ExploreCls:StartAdventureResult(msg)
	hzj_print("StartAdventureResult",msg.buyTimes,msg.challengeNum,msg.recoveryTime)
	self.msg=msg
	self:SetExploreInfo()
end

function ExploreCls:InitViews( ... )
	self:InitChapterInfos()
	local levelLimit = require"StaticData.SystemConfig.SystemBasis":GetData(kSystemBasis_Boss):GetMinLevel()
	self.tipText.text=levelLimit.."级可在探险或者挑战副本时遇到Boss哦！"
end

function ExploreCls:BuyAdventureTimesResult(msg)
	debug_print("BuyAdventureTimesResult",msg.challengeNum,msg.challengeNum,msg.recoveryTime)
	self.msg.challengeNum=msg.challengeNum
	self.msg.recoveryTime=msg.recoveryTime
	self.msg.buyTimes=msg.buyTimes
	
	self.AllNum.text=msg.challengeNum

	ResetTime(self,self.msg.recoveryTime)

end


-- local function ShowItemInfo(self,itemID,num)

-- 	local windowManager = self:GetGame():GetWindowManager()
-- 	local AwardCls = require "GUI.Task.GetAwardItem"	
-- 	self.items={}
-- 	self.items[1]={}
-- 	self.items[1].id=itemID	
-- 	self.items[1].count=num
	
-- 	local gametool = require "Utils.GameTools"
-- 	local _,data,_,_,_ = gametool.GetItemDataById(itemID)
-- 	self.items[1].color=data:GetColor()

-- 	windowManager:Show(AwardCls,self.items,self,self.AwardCallBack)
-- end
local function CloseNode(self,timer,msg)

	coroutine.wait(timer)
	local infos = {}
	infos[1001]="神秘龙穴"
	infos[1002]="大虚海"
	infos[1003]="魔力战场"
	infos[1004]="绝境求生"
	debug_print("AdvanceAdventureResult",msg.rewardsId,msg.challengeNum)
	self.AllNum.text=msg.challengeNum
	self.msg.challengeNum=msg.challengeNum
	self.msg.recoveryTime=msg.recoveryTime
	
	ResetTime(self,self.msg.recoveryTime)
	local  AwardData = {}
	--物品奖励
	AwardData[#AwardData+1]={}
	AwardData[#AwardData].awardItem={}
	--挑战次数奖励
	AwardData[#AwardData+1]={}
	AwardData[#AwardData].infoData={}
	hzj_print(#msg.rewardsId,"************")
	local gametool = require "Utils.GameTools"
	for i=1,#msg.rewardsId do
		local AdventureAwardData = require "StaticData.Adventure.AdventureAward":GetData(msg.rewardsId[i])
		local contain = false
		if AdventureAwardData:GetAwardType()==1 then

			for j=1,#AwardData[1].awardItem do
				if  AdventureAwardData:GetItemType() == AwardData[1].awardItem[j].itemID then
					AwardData[1].awardItem[j].itemNum=AwardData[1].awardItem[j].itemNum+AdventureAwardData:GetItemNum()
					contain=true
				end
			end
			if contain == false then
				AwardData[1].awardItem[#AwardData[1].awardItem+1]={}
				AwardData[1].awardItem[#AwardData[1].awardItem].itemID= AdventureAwardData:GetItemType() 
				AwardData[1].awardItem[#AwardData[1].awardItem].itemNum=AdventureAwardData:GetItemNum()
				local gametool = require "Utils.GameTools"
				local _,data,_,_,_ = gametool.GetItemDataById( AdventureAwardData:GetItemType() )
				AwardData[1].awardItem[#AwardData[1].awardItem].itemColor=data:GetColor()
			end
		elseif AdventureAwardData:GetAwardType()==2 then

			for j=1,#AwardData[2].infoData do
				if  AdventureAwardData:GetChallengeType() == AwardData[2].infoData[j].id then
					AwardData[2].infoData[j].count=AwardData[2].infoData[j].count+AdventureAwardData:GetChallengeNum()
					contain=true
				end

			end
			if contain == false then
				AwardData[2].infoData[#AwardData[2].infoData+1]={}
				AwardData[2].infoData[#AwardData[2].infoData].id= AdventureAwardData:GetChallengeType() 
				AwardData[2].infoData[#AwardData[2].infoData].count=AdventureAwardData:GetChallengeNum()
				
			end
		end	
	end
	self.AwardData=AwardData

	for i=1,#self.itemsChild do
		self.itemsChild[i]:SetInfo()
	end


	self.Button.enabled=true
	self.Explore_Effect2.gameObject:SetActive(false)
	self.Explore_Effect.gameObject:SetActive(true)
	self.BoatAnim:CrossFade("xuanhuan", 0);
	-- self.SkyAnim:CrossFade("Explore_Sky", 0);
	-- self.SeaAnim:CrossFade("Explore_Sea", 0);
	self.SkyAnim.speed=0.3
	self.SeaAnim.speed=1
	self:ShowItemInfo(AwardData)

	
end

function ExploreCls:ShowItemInfo(AwardData)
	local infos = {}
	infos[1001]="神秘龙穴"
	infos[1002]="大虚海"
	infos[1003]="魔力战场"
	infos[1004]="绝境求生"
	
	if #AwardData[1].awardItem >0 then
		local windowManager = utility:GetGame():GetWindowManager()
    	windowManager:Show(require "GUI.Tower.TowerSweepAward",AwardData[1].awardItem,3,self,self.AwardCallBack)
    else
    	self.AwardCallBack()
 	end   	
end

function ExploreCls:AwardCallBack()
	local infos = {}
	infos[1001]="神秘龙穴"
	infos[1002]="大虚海"
	infos[1003]="魔力战场"
	infos[1004]="绝境求生"
	--探险系统引导
	utility.GetGame():GetSystemGuideManager():SetNeetSystemGuideID(kSystem_Guide[2].systemGuideID,self)
	hzj_print(" #self.AwardData[2].infoData", #self.AwardData[2].infoData)
	if #self.AwardData[2].infoData >0 then
		local str ="神秘宝藏让你的"
		for i=1,#self.AwardData[2].infoData do
		hzj_print(infos[self.AwardData[2].infoData[i].id] .."恢复了"..self.AwardData[2].infoData[i].count.."次！")

		end
		for i=1,#self.AwardData[2].infoData do
			str=str..infos[self.AwardData[2].infoData[i].id] .."恢复了"..self.AwardData[2].infoData[i].count.."次！"
		end
		local windowManager = utility:GetGame():GetWindowManager()
		local ConfirmDialogClass = require "GUI.Dialogs.NormalDialog"	
		windowManager:Show(ConfirmDialogClass,str)
	end

end

function ExploreCls:DelayTime(timer,msg)
	self:StartCoroutine(CloseNode,timer,msg)			
end
function ExploreCls:AdvanceAdventureResult(msg)

	self:DelayTime(3,msg)
	


end



-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function ExploreCls:OnBackButtonClicked()
	--BackButton控件的点击事件处理
	local sceneManager = self.game:GetSceneManager()
    sceneManager:PopScene()
end

function ExploreCls:OnFiveButtonClicked()
	
	local vipLimit =  require "StaticData.Adventure.Adventure":GetData(1):GetFiveTime()
    local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    local vip = userData:GetVip()
    hzj_print("vip>=vipLimit",vip,vipLimit)
	 if vip>=vipLimit  then
		self:OnButtonClicked(5)
	else
		local windowManager = utility:GetGame():GetWindowManager()
   		local ConfirmDialogClass = require "GUI.Dialogs.NormalDialog"	
		windowManager:Show(ConfirmDialogClass,"Vip"..vipLimit.."才可以使用此功能")

	end

end


function ExploreCls:OnTenButtonClicked()
	local vipLimit = require "StaticData.Adventure.Adventure":GetData(1):GetTenTime()
	local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    local vip = userData:GetVip()
    hzj_print("vip>=vipLimit",vip,vipLimit)

    if vip>=vipLimit then
		self:OnButtonClicked(10)
	else
		local windowManager = utility:GetGame():GetWindowManager()
   		local ConfirmDialogClass = require "GUI.Dialogs.NormalDialog"	
		windowManager:Show(ConfirmDialogClass,"Vip"..vipLimit.."才可以使用此功能")

	end

end

function ExploreCls:OnButtonClicked(times)

	local count = 1
	if times ~= nil then
		count=times

	end
	
	


    hzj_print("vip>=vipLimit",vip,vipLimit)

	if self.msg.challengeNum > 0 then

		self.Button.enabled=false
		self.BoatAnim:CrossFade("qianjin", 0);
		--self.SkyAnim:CrossFade("Explore_SkyQuick", 0);
		self.SkyAnim.speed=0.5
		self.SeaAnim.speed=4
		--self.SeaAnim:CrossFade("Explore_SeaQuick", 0);
		self.Explore_Effect2.gameObject:SetActive(true)
		self.Explore_Effect.gameObject:SetActive(false)
		self.game:SendNetworkMessage(require "Network.ServerService".AdvanceAdventureRequest(count))
	else
		local windowManager = utility:GetGame():GetWindowManager()
   		local ConfirmDialogClass = require "GUI.Dialogs.NormalDialog"	
		windowManager:Show(ConfirmDialogClass,"探险神秘宝藏次数不足！")
	end
	--Button控件的点击事件处理
	-- print("点击前进按钮")
	-- local AdventureData = require "StaticData.Adventure.Adventure":GetData(1)
	-- print(AdventureData:GetRecoverTime(),"  *****************-")


	-- local AdventureAwardData = require "StaticData.Adventure.AdventureAward":GetData(5)
	-- print(AdventureAwardData:GetItemType(),"  *****************-")
	-- local uiManager = require "Utils.Utility".GetUIManager()
	-- self.screenParticleWarningEffect = require "Framework.UI.UIScreenWarning".New(uiManager.effectUICanvas)
	-- self.screenParticleWarningEffect:SetActive(true)

end

local function OnConfirmBuy(self)
    print("向服务器发协议购买探险机会")
	self.game:SendNetworkMessage(require "Network.ServerService".BuyAdventureTimesRequest())

end

local function OnCancelBuy(self)
  	 print("取消购买探险机会")
end

function ExploreCls:OnAddButtonClicked()
	local buyWindow = require "GUI.Buy.BuyNumberPanel"
    local windowManager = self:GetGame():GetWindowManager()
    windowManager:Show(buyWindow,kCurrencyId_Diamond,10,self.msg.buyTimes,kBuyType_Explore)


	-- local AdventureData = require "StaticData.Adventure.Adventure":GetData(1)
	-- self.maxTimes=AdventureData:GetMaxTimes()
	-- local utility = require "Utils.Utility"
	-- if self.msg.challengeNum>= self.maxTimes then
	-- 	utility.ShowBuyConfirmDialog("已经达到最大次数，不能购买", self, OnCancelBuy, OnCancelBuy)
	-- else
	-- 	utility.ShowBuyConfirmDialog("是否花费"..AdventureData:GetBuyTime().."钻石购买一次探险机会？", self, OnConfirmBuy, OnCancelBuy)		
	-- end	


	--AddButton控件的点击事件处理

			
end



function  ExploreCls:InitChapterInfos()
	local data = require "StaticData.Chapter"
	local infoData = require "StaticData.ChapterAdventureInfo"
	local chapterInfo = {}
	chapterInfo={}
	chapterInfo[1]={}
	--chapterInfo[1].ChapterID=12100000
	chapterInfo[1].ChapterInfoID=1001
	chapterInfo[1].kLineup=kLineup_JourneyToExplore1
	chapterInfo[1].atlaseName="dragon"
	chapterInfo[1].Color=UnityEngine.Color(160/255,60/255,20/255,1)

	chapterInfo[2]={}
	--chapterInfo[2].ChapterID=12100001
	chapterInfo[2].ChapterInfoID=1002
	chapterInfo[2].kLineup=kLineup_JourneyToExplore2
	chapterInfo[2].atlaseName="sea"
	chapterInfo[2].Color=UnityEngine.Color(20/128,60/255,162/255,1)

	chapterInfo[3]={}
--	chapterInfo[3].ChapterID=12100002
	chapterInfo[3].ChapterInfoID=1003
	chapterInfo[3].kLineup=kLineup_JourneyToExplore3
	chapterInfo[3].atlaseName="magic"
	chapterInfo[3].Color=UnityEngine.Color(140/255,40/255,160/255,1)

	chapterInfo[4]={}
--	chapterInfo[4].ChapterID=12100003
	chapterInfo[4].ChapterInfoID=1004
	chapterInfo[4].kLineup=kLineup_JourneyToExplore5
	chapterInfo[4].atlaseName="live"
	chapterInfo[4].Color=UnityEngine.Color(0/255,160/255,130/255,1)

	local chapterAdventureData = require "StaticData.ChapterAdventure"
	for i=1,#chapterInfo do		
		local data1= chapterAdventureData:GetData(chapterInfo[i].ChapterInfoID)
		chapterInfo[i].ChapterID=data1:GetMapID()
		chapterInfo[i].round=data1:GetRound()
		chapterInfo[i].BossPortrait={}
		chapterInfo[i].BossPortrait[1]=data1:GetBossPortrait1()
		chapterInfo[i].BossPortrait[2]=data1:GetBossPortrait2()
		chapterInfo[i].BossPortrait[3]=data1:GetBossPortrait3()
		chapterInfo[i].BossPortrait[4]=data1:GetBossPortrait4()
		chapterInfo[i].BossPortrait[5]=data1:GetBossPortrait5()
	
		for j=1,#chapterInfo[i].BossPortrait do
			for k=1,chapterInfo[i].BossPortrait[j].Count do
				print(chapterInfo[i].BossPortrait[j][k-1])
			end
			
		end
	end
	self.Chapter={}

	for i=1,#chapterInfo do
		self.Chapter[i]=chapterInfo[i]
		--print("999999999999999  ",#self.Chapter[i].BossPortrait)
	end
	for i=1,#self.Chapter do
		self.Chapter[i].data=data:GetData(self.Chapter[i].ChapterID)
		self.Chapter[i].infoData=infoData:GetData(self.Chapter[i].ChapterInfoID)
		--print(self.Chapter[i].ChapterID,i)	
	end
	self.itemsChild={}
	for i=1,#self.Chapter do
		local item = require "GUI.Explore.ExploreItem".New(self.layout,self.Chapter[i])
		self:AddChild(item)		
		item:SetDidCallback(self,self.ChildClickedCallBack)
		self.itemsChild[#self.itemsChild+1]=item
	end

end


 function ExploreCls:ChildClickedCallBack(table)

	print("SelectChallengdungeonCls")
	print(type(table),table.ChapterID)
	self.childData=table

	local levelLimit = require "StaticData.SystemConfig.SystemBasis":GetData(KSystemBasis_Chanllage):GetMinLevel()
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
    local SelectChallengdungeonCls = require "GUI.Explore.SelectChallengdungeon"
    sceneManager:PushScene(SelectChallengdungeonCls.New(table.ChapterInfoID%1000))
	
end 

return ExploreCls
