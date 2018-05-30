local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
local GuildMercenaryCls = Class(BaseNodeClass)
local GuildCommonFunc = require "GUI/Guild/GuildCommonFunc"
require "Data.CardBagData"

function GuildMercenaryCls:Ctor()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function GuildMercenaryCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/GuildMercenary', function(go)
		self:BindComponent(go)
	end)
end

function GuildMercenaryCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function GuildMercenaryCls:OnResume()
	-- 界面显示时调用
	GuildMercenaryCls.base.OnResume(self)
	self:FadeIn(function(self, t)
        local transform = self.base

        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	 self.lastT=0
	self:ScheduleUpdate(self.Update)

end

function GuildMercenaryCls:OnPause()
	-- 界面隐藏时调用
	GuildMercenaryCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function GuildMercenaryCls:OnEnter()
	-- Node Enter时调用
	GuildMercenaryCls.base.OnEnter(self)
	self:RequestMercenaryUI()
end

function GuildMercenaryCls:OnExit()
	-- Node Exit时调用
	GuildMercenaryCls.base.OnExit(self)
end

function GuildMercenaryCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end

function GuildMercenaryCls:Update()
	local countFlag = false
	if os.time()-self.lastT>=1 then
        self.lastT=os.time()
        countFlag=true
    end
    if self.selfGuyongjun~= nil then
    	

		for i=1,#self.selfGuyongjun do
			if countFlag then
				self.selfGuyongjun[i].totalTime=self.selfGuyongjun[i].totalTime+1000
			end


			local time = self.selfGuyongjun[i].totalTime/1000
			if time>=86400 then
				self.TimeLabel[i].text="我很累！我要归队"
			else
				self.TimeLabel[i].text =utility.ConvertTime(time) 				
			end
			
		end
	end
	
    
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function GuildMercenaryCls:InitControls()
	local transform = self:GetUnityTransform()
	self.base = transform:Find('Base')
	self.CheckInRetrunButton = self.base:Find('CheckInRetrunButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.My = self.base:Find('My')
	self.MyButton = self.base:Find('MyButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.MyBtnHighlight = self.base:Find('MyButton/Highlight')
	self.All = self.base:Find('All')
	self.AllButton = self.base:Find('AllButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.AllBtnHighlight = self.base:Find('AllButton/Highlight')
	self.Scroll_View = self.base:Find('All/Scroll View'):GetComponent(typeof(UnityEngine.UI.ScrollRect))
	self.Viewport = self.base:Find('All/Scroll View/Viewport'):GetComponent(typeof(UnityEngine.UI.Mask))
	self.Content = self.base:Find('All/Scroll View/Viewport/Content')
	--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))
	-- self.Scrollbar = self.base:Find('All/Scrollbar'):GetComponent(typeof(UnityEngine.UI.Scrollbar))
	
	self.On = {}
	self.Off = {}
	self.Frame = {}
	self.CharacterIcon = {}
	self.TypeIcon = {}
	self.NeoCardInfoLevelLabel = {}
	self.ConferButton = {}
	self.PriceLabel = {}
	self.TimeLabel = {}
	self.PlaceBtn = {}
	self.RarityImage = {}
	self.RankStarIcon = {}
	for i=1,2 do
		self.On[i] = self.base:Find('My/MyItem'..i..'/Card/On')
		self.Off[i] = self.base:Find('My/MyItem'..i..'/Card/Off')
		self.Frame[i] = self.base:Find('My/MyItem'..i..'/Card/On/Frame'):GetComponent(typeof(UnityEngine.UI.Image))
		self.CharacterIcon[i] = self.base:Find('My/MyItem'..i..'/Card/On/CharacterIcon'):GetComponent(typeof(UnityEngine.UI.Image))
		self.TypeIcon[i] = self.base:Find('My/MyItem'..i..'/Card/On/TypeIcon'):GetComponent(typeof(UnityEngine.UI.Image))
		self.NeoCardInfoLevelLabel[i] = self.base:Find('My/MyItem'..i..'/Card/On/LevelBase/NeoCardInfoLevelLabel'):GetComponent(typeof(UnityEngine.UI.Text))
		self.ConferButton[i] = self.base:Find('My/MyItem'..i..'/Card/On/Info/ConferButton'):GetComponent(typeof(UnityEngine.UI.Button))
		self.PriceLabel[i] = self.base:Find('My/MyItem'..i..'/Card/On/Info/PriceLabel'):GetComponent(typeof(UnityEngine.UI.Text))
		self.TimeLabel[i] = self.base:Find('My/MyItem'..i..'/Card/On/Info/TimeLabel'):GetComponent(typeof(UnityEngine.UI.Text))
		self.PlaceBtn[i] = self.base:Find('My/MyItem'..i..'/Card/Off/Image'):GetComponent(typeof(UnityEngine.UI.Button))
		self.RankStarIcon[i] = {}
		self.RarityImage[i] = self.On[i]:Find('Rarity'):GetComponent(typeof(UnityEngine.UI.Image))
		for j=1,5 do
			self.RankStarIcon[i][j] = self.base:Find('My/MyItem'..i..'/Card/On/CharacterRank/RankStarIcon'..j):GetComponent(typeof(UnityEngine.UI.Image))
		end
	end
end


function GuildMercenaryCls:RegisterControlEvents()
	-- 注册 CheckInRetrunButton 的事件
	self.__event_button_onCheckInRetrunButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCheckInRetrunButtonClicked, self)
	self.CheckInRetrunButton.onClick:AddListener(self.__event_button_onCheckInRetrunButtonClicked__)

	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCheckInRetrunButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

	-- 注册 MyButton 的事件
	self.__event_button_onMyButtonClicked__ = UnityEngine.Events.UnityAction(self.OnMyButtonClicked, self)
	self.MyButton.onClick:AddListener(self.__event_button_onMyButtonClicked__)

	-- 注册 AllButton 的事件
	self.__event_button_onAllButtonClicked__ = UnityEngine.Events.UnityAction(self.OnAllButtonClicked, self)
	self.AllButton.onClick:AddListener(self.__event_button_onAllButtonClicked__)

	-- 注册 Scroll_View 的事件
	self.__event_scrollrect_onScroll_ViewValueChanged__ = UnityEngine.Events.UnityAction_UnityEngine_Vector2(self.OnScroll_ViewValueChanged, self)
	self.Scroll_View.onValueChanged:AddListener(self.__event_scrollrect_onScroll_ViewValueChanged__)

	-- 注册 Scrollbar 的事件
	-- self.__event_scrollbar_onScrollbarValueChanged__ = UnityEngine.Events.UnityAction_float(self.OnScrollbarValueChanged, self)
	-- self.Scrollbar.onValueChanged:AddListener(self.__event_scrollbar_onScrollbarValueChanged__)

	-- 注册 ConferButton 的事件
	self.__event_button_onConferButtonClicked__ = UnityEngine.Events.UnityAction(self.OnConferButtonClicked, self)
	self.ConferButton[1].onClick:AddListener(self.__event_button_onConferButtonClicked__)

	-- 注册 Image1 的事件
	self.__event_button_onImage1Clicked__ = UnityEngine.Events.UnityAction(self.OnImage1Clicked, self)
	self.PlaceBtn[1].onClick:AddListener(self.__event_button_onImage1Clicked__)

	-- 注册 ConferButton1 的事件
	self.__event_button_onConferButton1Clicked__ = UnityEngine.Events.UnityAction(self.OnConferButton1Clicked, self)
	self.ConferButton[2].onClick:AddListener(self.__event_button_onConferButton1Clicked__)

	-- 注册 Image2 的事件
	self.__event_button_onImage2Clicked__ = UnityEngine.Events.UnityAction(self.OnImage2Clicked, self)
	self.PlaceBtn[2].onClick:AddListener(self.__event_button_onImage2Clicked__)

end

function GuildMercenaryCls:UnregisterControlEvents()
	-- 取消注册 CheckInRetrunButton 的事件
	if self.__event_button_onCheckInRetrunButtonClicked__ then
		self.CheckInRetrunButton.onClick:RemoveListener(self.__event_button_onCheckInRetrunButtonClicked__)
		self.__event_button_onCheckInRetrunButtonClicked__ = nil
	end

	-- 取消注册 MyButton 的事件
	if self.__event_button_onMyButtonClicked__ then
		self.MyButton.onClick:RemoveListener(self.__event_button_onMyButtonClicked__)
		self.__event_button_onMyButtonClicked__ = nil
	end

	-- 取消注册 AllButton 的事件
	if self.__event_button_onAllButtonClicked__ then
		self.AllButton.onClick:RemoveListener(self.__event_button_onAllButtonClicked__)
		self.__event_button_onAllButtonClicked__ = nil
	end

	-- 取消注册 Scroll_View 的事件
	if self.__event_scrollrect_onScroll_ViewValueChanged__ then
		self.Scroll_View.onValueChanged:RemoveListener(self.__event_scrollrect_onScroll_ViewValueChanged__)
		self.__event_scrollrect_onScroll_ViewValueChanged__ = nil
	end

	-- 取消注册 Scrollbar 的事件
	-- if self.__event_scrollbar_onScrollbarValueChanged__ then
	-- 	self.Scrollbar.onValueChanged:RemoveListener(self.__event_scrollbar_onScrollbarValueChanged__)
	-- 	self.__event_scrollbar_onScrollbarValueChanged__ = nil
	-- end

	-- 取消注册 ConferButton 的事件
	if self.__event_button_onConferButtonClicked__ then
		self.ConferButton[1].onClick:RemoveListener(self.__event_button_onConferButtonClicked__)
		self.__event_button_onConferButtonClicked__ = nil
	end

	-- 取消注册 Image1 的事件
	if self.__event_button_onImage1Clicked__ then
		self.PlaceBtn[1].onClick:RemoveListener(self.__event_button_onImage1Clicked__)
		self.__event_button_onImage1Clicked__ = nil
	end

	-- 取消注册 ConferButton1 的事件
	if self.__event_button_onConferButton1Clicked__ then
		self.ConferButton[2].onClick:RemoveListener(self.__event_button_onConferButton1Clicked__)
		self.__event_button_onConferButton1Clicked__ = nil
	end

	-- 取消注册 Image2 的事件
	if self.__event_button_onImage2Clicked__ then
		self.PlaceBtn[2].onClick:RemoveListener(self.__event_button_onImage2Clicked__)
		self.__event_button_onImage2Clicked__ = nil
	end

	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end

end

function GuildMercenaryCls:RegisterNetworkEvents()
	utility:GetGame():RegisterMsgHandler(net.S2CGHQueryGuyongjunResult, self, self.GHQueryGuyongjunResult)
	utility:GetGame():RegisterMsgHandler(net.S2CGHAddGuyongjunResult, self, self.GHAddGuyongjunResult)
	utility:GetGame():RegisterMsgHandler(net.S2CGHDelGuyongjunResult, self, self.GHDelGuyongjunResult)
end

function GuildMercenaryCls:UnregisterNetworkEvents()
	utility:GetGame():UnRegisterMsgHandler(net.S2CGHQueryGuyongjunResult, self, self.GHQueryGuyongjunResult)
	utility:GetGame():UnRegisterMsgHandler(net.S2CGHAddGuyongjunResult, self, self.GHAddGuyongjunResult)
	utility:GetGame():UnRegisterMsgHandler(net.S2CGHDelGuyongjunResult, self, self.GHDelGuyongjunResult)
end

----------------------------------------------------------------------------
--动画处理--
----------------------------------------------------------------------------
function GuildMercenaryCls:IsTransition()
    return true
end

-- ## 在这里执行 淡出函数! (immediately 值只针对 WindowNode 及其子类)
function GuildMercenaryCls:OnExitTransitionDidStart(immediately)
    GuildMercenaryCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.base

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function GuildMercenaryCls:OnCheckInRetrunButtonClicked()
	self:Close()
end

function GuildMercenaryCls:OnMyButtonClicked()

	self:SwitchToMyPage(true)

	self.usedCardUID = {}
	for i=1,2 do
		local bActive = self.selfGuyongjun[i]~=nil
		self.On[i].gameObject:SetActive(bActive)
		self.Off[i].gameObject:SetActive(not bActive)
		if bActive then
			local cardUID = self.selfGuyongjun[i].cardUID

			local UserDataType = require "Framework.UserDataType"
        	local cardBagData = self:GetCachedData(UserDataType.CardBagData)
			local cardInfo = cardBagData:GetRoleByUid(cardUID)	--格式见Game.Role
			if cardInfo then
				local cardExl = require "StaticData.Role":GetData(cardInfo.id)
				local PropUtility = require "Utils.PropUtility"
				PropUtility.AutoSetRGBColor(self.Frame[i],cardInfo.color)
				-- self.Frame[i].color = require "Utils.PropUtility".GetColorValue(cardInfo.color)
				self.NeoCardInfoLevelLabel[i].text = cardInfo.level
				self.PriceLabel[i].text = self.selfGuyongjun[i].totalGain


				hzj_print("self.selfGuyongjun[i].totalTime",self.selfGuyongjun[i].totalTime)
				local time = self.selfGuyongjun[i].totalTime/1000
				if time>86400 then
					self.TimeLabel[i].text="我很累！我要休息"
				else
				self.TimeLabel[i].text =utility.ConvertTime(time) --GuildCommonFunc.TranslateTime(self.selfGuyongjun[i].totalTime)
				
				end
				utility.LoadRoleHeadIcon(cardInfo.id, self.CharacterIcon[i])
				utility.LoadRaceIcon(cardExl:GetRace(),self.TypeIcon[i])
				--ssr
				local rarity = cardExl:GetRarity()
				utility.LoadSpriteFromPath(rarity,self.RarityImage[i])
				-- local star = cardExl:GetStar()
				-- for j=1,5 do
					-- self.RankStarIcon[i][j].gameObject:SetActive(j<=star)
				-- end
			end

			self.usedCardUID[i] = cardUID
		else
			self.usedCardUID[i] = 0
		end
	end
end

function GuildMercenaryCls:OnAllButtonClicked()
	self:SwitchToMyPage(false)
	self:ClearPage()
	if #self.otherGuyongjun==0 then
		return
	end
	self.node = {}
	for i=1,#self.otherGuyongjun do
		local key = self.otherGuyongjun[i].cardID
		-- if not self.cardDict:Contains(key) then
		-- 	debug_print(key)
			self.node[i] = require "GUI/Guild/GuildMercenaryItem".New(self.Content, self.otherGuyongjun[i])
			self:AddChild(self.node[i])
		-- 	self.cardDict:Add(key,node)
		-- end
	end
end

function GuildMercenaryCls:SwitchToMyPage(bMy)
	self.My.gameObject:SetActive(bMy)
	self.All.gameObject:SetActive(not bMy)
	self.MyBtnHighlight.gameObject:SetActive(bMy)
	self.AllBtnHighlight.gameObject:SetActive(not bMy)
end

function GuildMercenaryCls:ClearPage()
	if self.node ~= nil then
		for i=1,#self.node do
			self:RemoveChild(self.node[i])
		end
	end
	-- if self.cardDict==nil then
	-- 	self.cardDict = OrderedDictionary.New()
	-- else
	-- 	local keys = self.cardDict:GetKeys()
	-- 	for i=1,#keys do
	-- 		local node = self.cardDict:GetEntryByKey(keys[i])
	-- 		self:RemoveChild(node)
	-- 	end
	-- 	self.cardDict:Clear()
	-- end
end

function GuildMercenaryCls:OnScroll_ViewValueChanged(posXY)
	--Scroll_View控件的点击事件处理
end

function GuildMercenaryCls:OnScrollbarValueChanged(value)
	--Scrollbar控件的点击事件处理
end

function GuildMercenaryCls:OnConferButtonClicked()
	self:RemoveCard(1)
end

function GuildMercenaryCls:OnConferButton1Clicked()
	self:RemoveCard(2)
end

function GuildMercenaryCls:RemoveCard(i)
	local cardUID = self.selfGuyongjun[i].cardUID
	local ghId = self:GetCachedData(require "Framework.UserDataType".PlayerData):GetGonghuiID()
	utility:GetGame():SendNetworkMessage(require "Network/ServerService".GHDelGuyongjunRequest(ghId, cardUID))
end

function GuildMercenaryCls:OnImage1Clicked()
	self:PreviewAllMyCards()
end

function GuildMercenaryCls:OnImage2Clicked()
	self:PreviewAllMyCards()
end

function GuildMercenaryCls:PreviewAllMyCards()
	local UserDataType = require "Framework.UserDataType"
    local cardBagData = self:GetCachedData(UserDataType.CardBagData)
    if cardBagData:RoleCount()==0 then
		GuildCommonFunc.ShowErrorTip("您暂时没有可用的卡牌！")
	elseif cardBagData:RoleCount()==1 and self.usedCardUID[1]~=0 then
		GuildCommonFunc.ShowErrorTip("您没有未上阵的卡牌了！")
	else
		utility:GetGame():GetWindowManager():Show(require "GUI/Guild/GuildMercenaryCard", self.usedCardUID)
	end
end

function GuildMercenaryCls:GHQueryGuyongjunResult(msg)
	self.selfGuyongjun = msg.selfGuyongjun
	self.otherGuyongjun = msg.otherGuyongjun

	self:OnMyButtonClicked()
end

function GuildMercenaryCls:GHAddGuyongjunResult(msg)
	self:RequestMercenaryUI()
end

function GuildMercenaryCls:GHDelGuyongjunResult(msg)
	self:RequestMercenaryUI()
end

function GuildMercenaryCls:RequestMercenaryUI()
	local ghId = self:GetCachedData(require "Framework.UserDataType".PlayerData):GetGonghuiID()
	utility:GetGame():SendNetworkMessage(require "Network/ServerService".GHQueryGuyongjunRequest(ghId))
end

return GuildMercenaryCls
