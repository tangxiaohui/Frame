local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local NovicePacksCls = Class(BaseNodeClass)

function NovicePacksCls:Ctor()

end
function NovicePacksCls:OnWillShow(tables)
--	print("/////////////")
	self.tables=tables
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function NovicePacksCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/NovicePacks', function(go)
		self:BindComponent(go)
	end)
end

function NovicePacksCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
	
end
function NovicePacksCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end
function NovicePacksCls:OnResume()
	-- 界面显示时调用
	--self.base.OnResume(self)
	NovicePacksCls.base.OnResume(self)
	--self.game:SendNetworkMessage(require"Network/ServerService".OnlineAwardQueryRequest())
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:ScheduleUpdate(self.Update)
	self:InitView(self.tables.NovicePacksAward)
end

function NovicePacksCls:OnPause()
	-- 界面隐藏时调用
	NovicePacksCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()

end

function NovicePacksCls:OnEnter()
	-- Node Enter时调用
		NovicePacksCls.base.OnEnter(self)
	--self.base.OnEnter(self)
end

function NovicePacksCls:OnExit()
	-- Node Exit时调用
	NovicePacksCls.base.OnExit(self)
--	self:RemoveObserver()
end

function NovicePacksCls:Update()
	self:UpdateTime()
end

local  function IsNil(uobj)
    return uobj == nil or uobj:Equals(nil)
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function NovicePacksCls:InitControls()
	local transform = self:GetUnityTransform()
	self.game = utility.GetGame()
	self.NovicePacksCancelButton = transform:Find('NovicePacksCancelButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.NovicePacksReceiveButton = transform:Find('ButtonLayout/NovicePacksReceiveButton'):GetComponent(typeof(UnityEngine.UI.Button))	
	self.NovicePacksReceiveButtonImage = transform:Find('ButtonLayout/NovicePacksReceiveButton'):GetComponent(typeof(UnityEngine.UI.Image))	
	
	self.Text = transform:Find('Text'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ItemListLayout = transform:Find('ItemListLayout')

	--背景按钮
	self.BackgroundButton = transform:Find('SmallWindowBase/TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))
	self.onlineAwardItem={}
	-- self:AddObserver()
	self.isShowOnline=false
	

end
function NovicePacksCls:InitView(info)	

	print(info.index)
	local noviceData = require"StaticData.Activity.OnlineTimeAward":GetData(info.index)
	local dic = noviceData:GetItemDic()
	local dicCount=dic:Count()
	for i=1,dic:Count() do
		if i>#self.onlineAwardItem then
			self.onlineAwardItem[#self.onlineAwardItem+1]=require"GUI.Activity.NovicePackGeneralItem".New(self.ItemListLayout,dic:GetKeyFromIndex(i),dic:GetEntryByIndex(i))	
		    self:AddChild(self.onlineAwardItem[#self.onlineAwardItem])	

		else
 			 self.onlineAwardItem[i]:InitViews(dic:GetKeyFromIndex(i),dic:GetEntryByIndex(i))
		end
	end

end


--更新时间
function NovicePacksCls:UpdateTime()
	if self.tables.countTime ~=nil then	
		if self.tables.countTime<0 then
			self.Text.text=self.tables.NovicePacksAwardTimeText.text
			if self.NovicePacksReceiveButton.enabled==false then
				self.NovicePacksReceiveButton.enabled=true
				self.NovicePacksReceiveButtonImage.material= utility.GetCommonMaterial()
			end
		else
			if self.NovicePacksReceiveButton.enabled==true then
				self.NovicePacksReceiveButton.enabled=false
				self.NovicePacksReceiveButtonImage.material= utility.GetGrayMaterial()

			end
			self.Text.text="距下次奖励领取时间："..self.tables.NovicePacksAwardTimeText.text
		end
	end
end

function NovicePacksCls:RegisterControlEvents()
	-- 注册 NovicePacksCancelButton 的事件
	self.__event_button_onNovicePacksCancelButtonClicked__ = UnityEngine.Events.UnityAction(self.OnNovicePacksCancelButtonClicked, self)
	self.NovicePacksCancelButton.onClick:AddListener(self.__event_button_onNovicePacksCancelButtonClicked__)

	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnNovicePacksCancelButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

	-- 注册 NovicePacksReceiveButton 的事件
	self.__event_button_onNovicePacksReceiveButtonClicked__ = UnityEngine.Events.UnityAction(self.OnNovicePacksReceiveButtonClicked, self)
	self.NovicePacksReceiveButton.onClick:AddListener(self.__event_button_onNovicePacksReceiveButtonClicked__)

end

function NovicePacksCls:UnregisterControlEvents()
	-- 取消注册 NovicePacksCancelButton 的事件
	if self.__event_button_onNovicePacksCancelButtonClicked__ then
		self.NovicePacksCancelButton.onClick:RemoveListener(self.__event_button_onNovicePacksCancelButtonClicked__)
		self.__event_button_onNovicePacksCancelButtonClicked__ = nil
	end

	-- 取消注册 NovicePacksReceiveButton 的事件
	if self.__event_button_onNovicePacksReceiveButtonClicked__ then
		self.NovicePacksReceiveButton.onClick:RemoveListener(self.__event_button_onNovicePacksReceiveButtonClicked__)
		self.__event_button_onNovicePacksReceiveButtonClicked__ = nil
	end

	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end

end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function NovicePacksCls:RegisterNetworkEvents()
	--RegisterNetworkEvents控件的网络事件处理
	 self.game:RegisterMsgHandler(net.S2COnlineAwardQueryResult, self, self.OnlineAwardQueryResult)
	 self.game:RegisterMsgHandler(net.S2COnlineAwardDrawResult, self, self.OnlineAwardDrawResult)
end

function NovicePacksCls:UnregisterNetworkEvents()
	--UnregisterNetworkEvents 控件的网络事件处理
	 self.game:UnRegisterMsgHandler(net.S2COnlineAwardQueryResult, self, self.OnlineAwardQueryResult)
	 self.game:UnRegisterMsgHandler(net.S2COnlineAwardDrawResult, self, self.OnlineAwardDrawResult)
end
-----------------------------------------------------------------------
--- 网络事件处理
-----------------------------------------------------------------------
function NovicePacksCls:OnlineAwardQueryResult(msg)
	--self:InitView()
   self.isShowOnline=false
	
	self.totalTime=msg.totalTime
	--cal tempItemId = require"StaticData/Item":GetData(id):GetInfo()
	local OnlineTimeAwardData = require "StaticData/Activity/OnlineTimeAward"
	self.OnlineTimeAward=nil
	for i=1,#msg.list do
		--表示可以领取
		if msg.list[i].state==1  then		
			self.OnlineTimeAward=msg.list[i]			
	
			break
		elseif msg.list[i].state==2 then			
			self.OnlineTimeAward=msg.list[i]	
			break		

		end
	
	end	
	for i=1,#msg.list do
			--是否全部领取了
		if msg.list[i].state~=3 then
			self.isShowOnline=true
			break
			end
		end
	if self.isShowOnline then
	--	print("true 有可领取的")
		self:InitView(self.OnlineTimeAward)
	else
	--	print("false 没有可领取的")
		self:OnNovicePacksCancelButtonClicked()
	end
end
function NovicePacksCls:OnNovicePacksCancelButtonClicked()
	--NovicePacksCancelButton控件的点击事件处理
	self:UnregisterControlEvents()
	self:Close()
end
local function GetItemColor(itemType,infoData)	
	if itemType == "Role" then		
		return infoData:GetColorID()
	elseif itemType == "Equip" then		
		return infoData:GetColorID()
	-- elseif itemType == "Item" then		
	-- 	return infoData:GetDesc()
	-- elseif itemType =="RoleCrap" then	
	-- 	return infoData:GetDesc()
	-- elseif itemType == "EquipCrap"then		
	-- 	return infoData:GetInfo()	
	-- elseif itemType =="FactoryItem" then		
	-- 	return infoData:GetDesc()
	-- elseif itemType ==nil then
	-- 	print("物品类型108 无此描述")
	end
	-- error("----物品类型错误----")
	return nil
end
function NovicePacksCls:OnlineAwardDrawResult(msg)
	--C2SOnlineAwardQueryRequest
	print("OnlineAwardDrawResult",msg.index)
	self.tables:OnlineAwardQueryRequest()
	-- local windowManager = self.game:GetWindowManager()
 --    windowManager:Show(require "GUI.Activity.GeneralReward",msg.items)
 
	for i=1,#msg.items do
	  	local modV = math.floor(msg.items[i].itemID/100000)
		if modV==100 then

			local UserDataType = require "Framework.UserDataType"
			local cardBagData = self:GetCachedData(UserDataType.CardBagData)
			local card= cardBagData:GetRoleById(msg.items[i].itemID)

			self.addCardDict = OrderedDictionary.New()
			if card ==nil then
				self.addCardDict:Add(msg.items[i].itemID,msg.items[i].itemID)

			else


			end


			local windowManager = self.game:GetWindowManager()
	   		windowManager:Show(require "GUI.GeneralCard.GetCardWin",msg.items[i].itemID,addCardDict)
	   	end
	end

 
    local items = {}
 	for i=1,#msg.items do
 		print(msg.items[i].itemID,msg.items[i].itemNum,msg.items[i].itemColor)
 		items[i]={}
  		items[i].id=msg.items[i].itemID
  		items[i].count=msg.items[i].itemNum
  		items[i].color=msg.items[i].itemColor
 	end
   
	local windowManager = self:GetGame():GetWindowManager()
  	local AwardCls = require "GUI.Task.GetAwardItem"
  	windowManager:Show(AwardCls,items)

  	self:Close()


end


-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------

--领取按钮
function NovicePacksCls:OnNovicePacksReceiveButtonClicked()

	if self.tables.NovicePacksAward ~=nil then
		
	self.game:SendNetworkMessage(require"Network/ServerService".OnlineAwardDrawRequest(self.tables.NovicePacksAward.index))
	
	end

end
return NovicePacksCls

