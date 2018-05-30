local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local messageGuids = require "Framework.Business.MessageGuids"
local LimitedHeroCls = Class(BaseNodeClass)

function LimitedHeroCls:Ctor()
	--self.id=40


end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function LimitedHeroCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/LimitedHero', function(go)
		self:BindComponent(go)
	end)
end
function LimitedHeroCls:OnWillShow()
	
		
end
function LimitedHeroCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end
function LimitedHeroCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function LimitedHeroCls:OnResume()
	-- 界面显示时调用
	LimitedHeroCls.base.OnResume(self)
	self.game:SendNetworkMessage( require"Network/ServerService".ActivityGodComingRequest())
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:RegisterEventObserver()
	self:ScheduleUpdate(self.Update)
end

function LimitedHeroCls:OnPause()
	-- 界面隐藏时调用
	LimitedHeroCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
	self:UnRegisterEventObserver()
end

function LimitedHeroCls:OnEnter()
	-- Node Enter时调用
	LimitedHeroCls.base.OnEnter(self)
end

function LimitedHeroCls:OnExit()
	-- Node Exit时调用
	LimitedHeroCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function LimitedHeroCls:InitControls()
	local transform = self:GetUnityTransform()
	debug_print(transform.gameObject.name)
	self.ReturnButton = transform:Find('Base/ReturnButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.rightFrameImage1 = transform:Find('Base/Right/Frame1/Base/Image'):GetComponent(typeof(UnityEngine.UI.Image))
	self.rightFrameImage2 = transform:Find('Base/Right/Frame2/Base/Image'):GetComponent(typeof(UnityEngine.UI.Image))
	self.rightFrameImage3 = transform:Find('Base/Right/Frame3/Base/Image'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Portrait = transform:Find('Base/Left/Portrait/Image'):GetComponent(typeof(UnityEngine.UI.Image))
	self.DiaLabel = transform:Find('Base/Top/Diamond/DiaLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Name = transform:Find('Base/Left/Point/Name'):GetComponent(typeof(UnityEngine.UI.Text))
	self.star = transform:Find('Base/Left/Point/Image'):GetComponent(typeof(UnityEngine.UI.Image))
	self.DiaLabel1 = transform:Find('Base/Middle/Parent/Draw/One/OneDiamond/DiaLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.DiaLabel2 = transform:Find('Base/Middle/Parent/Draw/Ten/TenDiamond/DiaLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	
	self.InfoButton = transform:Find('Base/Middle/Parent/Box/InfoButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.OneButton = transform:Find('Base/Middle/Parent/Draw/One/OneButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.TenButton = transform:Find('Base/Middle/Parent/Draw/Ten/TenButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.TimeText=transform:Find('Base/Top/Time/Base/Hours/TimeLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.dayText=transform:Find('Base/Top/Time/Base/Days/Text (1)'):GetComponent(typeof(UnityEngine.UI.Text))
	self.game=self:GetGame()
end
function LimitedHeroCls:InitView()
	hzj_print(self.id,"self.id")
	local activityData = require "StaticData.Activity.LimitGodActivity"
	data=activityData:GetData(self.id)
	--debug_print(data:GetInfo(),data:GetOnetime(),data:GetTentime(),data:GetPortrait1(),data:GetPic1(),data:GetPic2())

	utility.LoadAtlasesSpriteByFullName(data:GetPic1(),self.rightFrameImage1)
	utility.LoadAtlasesSpriteByFullName(data:GetPic2(),self.rightFrameImage2)
	utility.LoadAtlasesSpriteByFullName(data:GetPic3(),self.rightFrameImage3)
	--utility.LoadAtlasesSpriteByFullName(data:GetPortrait1(),self.Portrait)
	utility.LoadRolePortraitImage(data:GetRoleID(), self.Portrait)

	local UserDataType = require "Framework.UserDataType"
    local RoleData = require "StaticData.Role":GetData(data:GetRoleID())
    



	self.Name.text=RoleData:GetInfo()
	
	local rarity = RoleData:GetRarity()
	utility.LoadSpriteFromPath(rarity,self.star)

	self.DiaLabel1.text=data:GetOnetime()

	self.DiaLabel2.text=data:GetTentime()

	self:UpdatePlayerData()
end


function LimitedHeroCls:UpdatePlayerData()
	
	local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)

	self.DiaLabel.text = userData:GetDiamond()


end

function LimitedHeroCls:RegisterControlEvents()
	-- 注册 InfoButton 的事件
	self.__event_button_onInfoButtonClicked__ = UnityEngine.Events.UnityAction(self.OnInfoButtonClicked, self)
	self.InfoButton.onClick:AddListener(self.__event_button_onInfoButtonClicked__)

	-- 注册 OneButton 的事件
	self.__event_button_onOneButtonClicked__ = UnityEngine.Events.UnityAction(self.OnOneButtonClicked, self)
	self.OneButton.onClick:AddListener(self.__event_button_onOneButtonClicked__)

	-- 注册 TenButton 的事件
	self.__event_button_onTenButtonClicked__ = UnityEngine.Events.UnityAction(self.OnTenButtonClicked, self)
	self.TenButton.onClick:AddListener(self.__event_button_onTenButtonClicked__)

	-- 注册 ReturnButton 的事件
	self.__event_button_onReturnButtonClicked__ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked, self)
	self.ReturnButton.onClick:AddListener(self.__event_button_onReturnButtonClicked__)
end

function LimitedHeroCls:UnregisterControlEvents()
	-- 取消注册 InfoButton 的事件
	if self.__event_button_onInfoButtonClicked__ then
		self.InfoButton.onClick:RemoveListener(self.__event_button_onInfoButtonClicked__)
		self.__event_button_onInfoButtonClicked__ = nil
	end

	-- 取消注册 OneButton 的事件
	if self.__event_button_onOneButtonClicked__ then
		self.OneButton.onClick:RemoveListener(self.__event_button_onOneButtonClicked__)
		self.__event_button_onOneButtonClicked__ = nil
	end

	-- 取消注册 TenButton 的事件
	if self.__event_button_onTenButtonClicked__ then
		self.TenButton.onClick:RemoveListener(self.__event_button_onTenButtonClicked__)
		self.__event_button_onTenButtonClicked__ = nil
	end

	-- 取消注册 ReturnButton 的事件
	if self.__event_button_onReturnButtonClicked__ then
		self.ReturnButton.onClick:RemoveListener(self.__event_button_onReturnButtonClicked__)
		self.__event_button_onReturnButtonClicked__ = nil
	end
end

function LimitedHeroCls:RegisterNetworkEvents()
	self:GetGame():RegisterMsgHandler(net.S2CLoadPlayerResult,self,self.UpdatePlayerData)

	 self:GetGame():RegisterMsgHandler(net.S2CChoukaDiamondChooseTenResult, self, self.OnChoukaDiamondChooseTenResultResponse)
	 self:GetGame():RegisterMsgHandler(net.S2CChoukaDiamondChooseResult, self, self.OnChoukaDiamondChooseResultResponse)
	 self:GetGame():RegisterMsgHandler(net.S2CActivityGodComingResult, self, self.ActivityGodComingResult)
end

function LimitedHeroCls:UnregisterNetworkEvents()
	self:GetGame():UnRegisterMsgHandler(net.S2CLoadPlayerResult,self,self.UpdatePlayerData)
	self:GetGame():UnRegisterMsgHandler(net.S2CChoukaDiamondChooseTenResult, self, self.OnChoukaDiamondChooseTenResultResponse)
	self:GetGame():UnRegisterMsgHandler(net.S2CChoukaDiamondChooseResult, self, self.OnChoukaDiamondChooseResultResponse)
	self:GetGame():UnRegisterMsgHandler(net.S2CActivityGodComingResult, self, self.ActivityGodComingResult)
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function LimitedHeroCls:OnInfoButtonClicked()
	debug_print("OnInfoButtonClicked")
	--InfoButton控件的点击事件处理
	local activityData = require "StaticData.Activity.LimitGodActivity"
	data=activityData:GetData(self.id)

	local DrawPoolData = require "StaticData.DrawPool.DrawPool":GetData(data:GetInfo())
	local str = DrawPoolData:GetDescription()
	local windowManager = self:GetWindowManager()
	
    windowManager:Show(require "GUI.CommonDescriptionModule",str)

end


function LimitedHeroCls:ShowSelifGameObject()
	self.gameObject:SetActive(true)	
	self.mainCamera.fieldOfView = 60
	--self:GetXunBaolingCount()
end
function LimitedHeroCls:RegisterEventObserver()
	self.AddCardDict = OrderedDictionary.New()
	-- 添加事件的监听
	self:RegisterEvent(messageGuids.AddedOneCard,self.AddedOneCard)
	self:RegisterEvent('ShowCardDraw',self.ShowSelifGameObject)
end

function LimitedHeroCls:UnRegisterEventObserver()
	-- 取消添加事件的监听
	self:UnregisterEvent(messageGuids.AddedOneCard,self.AddedOneCard)
	self:UnregisterEvent('ShowCardDraw',self.ShowSelifGameObject)
end
function LimitedHeroCls:AddedOneCard(data)
	local UpdatedCardID = data:GetId()
	if not self.AddCardDict:Contains(UpdatedCardID) then
		self.AddCardDict:Add(UpdatedCardID,UpdatedCardID)
	end
end
function LimitedHeroCls:AddAwardItem(msg,count,type)
    self.mainCamera= self:GetUIManager():GetMainUICanvas():GetCamera()
    self.gameObject = self:GetUnityTransform().gameObject
    local eventMgr = self.game:GetEventManager()
    eventMgr:PostNotification('ClosePlayNotice')

    local messageGuids = require "Framework.Business.MessageGuids"
	self:DispatchEvent(messageGuids.ExitLobbyScene)

	local sceneManager = self:GetGame():GetSceneManager()
	if self.CardDrawResultCls == nil then
		self.CardDrawResultCls = require "GUI.CardDrawResult".New()		
	end

	if self.gameObject.activeSelf then
		sceneManager:PushScene(self.CardDrawResultCls)
		self.gameObject:SetActive(false)
	end
    self.CardDrawResultCls:OnShowItem(msg,count,type,self.itemXunbaolingCount,self.remainCount,self.AddCardDict,true)
end



function LimitedHeroCls:OnChoukaDiamondChooseTenResultResponse(msg)
	debug_print(msg,"OnChoukaDiamondChooseTenResultResponse","DiamondTen")
	--self.cardType = self.cardDrawType.DiamondTen
	self:AddAwardItem(msg,10,"DiamondTen")
end

function LimitedHeroCls:OnChoukaDiamondChooseResultResponse(msg)
	self.diamondCDTime = msg.diamondCDTime / 1000
	-- self.remainCount = msg.remainCount
	-- self.cardType = self.cardDrawType.DiamondOne
	-- self:UpdateHintView()
	self:AddAwardItem(msg,1,"DiamondOne")	
end

function LimitedHeroCls:Update()
	if self.countTimerFlag then
		if os.time()-self.lastT>=1 then
			self.lastT=os.time()
			self.countTimer=self.countTimer-1
		end
		if self.countTimer <= 0 then
			self.countTimerFlag=false
			self:Close()

		else
			local day = self.countTimer/84600
			local timer = ( self.countTimer % 84600)
			self.TimeText.text=utility.ConvertTime(timer)
			self.dayText.text=day
		end
	end

end

function LimitedHeroCls:ActivityGodComingResult(msg)
	debug_print(msg.tid,msg.hastime,"hastime")
	self.id=msg.tid
	self.countTimer=msg.hastime+1
	self.countTimerFlag=true
	self.lastT=0
	self:InitView()
end

function LimitedHeroCls:ChoukaDiamondChooseRequest()
	self.myGame:SendNetworkMessage( require"Network/ServerService".ChoukaDiamondChooseRequest())
end


function LimitedHeroCls:OnOneButtonClicked()
	--OneButton控件的点击事件处理
		--TenButton控件的点击事件处理
	debug_print("OnOneButtonClicked")
	require "Utils.GameAnalysisUtils".RecordLocalAction(kTrackingId_DrawCardDiamondAction)

	--self:ChoukaDiamondChooseTenRequest()
	self.game:SendNetworkMessage( require"Network/ServerService".GodChooseOneRequet())

end

function LimitedHeroCls:OnTenButtonClicked()
	--TenButton控件的点击事件处理
	debug_print("OnTenButtonClicked")
	require "Utils.GameAnalysisUtils".RecordLocalAction(kTrackingId_DrawCardDiamondTenTimesAction)

	--self:ChoukaDiamondChooseTenRequest()
	self.game:SendNetworkMessage( require"Network/ServerService".GodChooseTenRequest())


end

function LimitedHeroCls:OnReturnButtonClicked()
	--ReturnButton控件的点击事件处理
	self:Close()
end

return LimitedHeroCls
