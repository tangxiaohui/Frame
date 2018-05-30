local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local NovicePacksAwardButtonCls = Class(BaseNodeClass)

function NovicePacksAwardButtonCls:Ctor(parent)
	self.Parent=parent
	self.callback = LuaDelegate.New()
end


-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function NovicePacksAwardButtonCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/NovicePacksAwardButton', function(go)
		self:BindComponent(go)
	end)
end

function NovicePacksAwardButtonCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function NovicePacksAwardButtonCls:OnResume()
	-- 界面显示时调用
	NovicePacksAwardButtonCls.base.OnResume(self)
	self:RegisterControlEvents()
	self.game:SendNetworkMessage(require"Network/ServerService".OnlineAwardQueryRequest())
	self:RegisterNetworkEvents()
	self:ScheduleUpdate(self.Update)

end

function NovicePacksAwardButtonCls:OnPause()
	-- 界面隐藏时调用
	NovicePacksAwardButtonCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function NovicePacksAwardButtonCls:OnEnter()
	-- Node Enter时调用
	NovicePacksAwardButtonCls.base.OnEnter(self)
end

function NovicePacksAwardButtonCls:OnExit()
	-- Node Exit时调用
	NovicePacksAwardButtonCls.base.OnExit(self)
	
end
function  NovicePacksAwardButtonCls:InitView()

end
function NovicePacksAwardButtonCls:Update()
	self:UpdateTime()
end

--更新时间
function NovicePacksAwardButtonCls:UpdateTime()
	if self.countTime ~=nil then
		if self.countTime<0 then
			self.NovicePacksAwardTimeText.text="可领取"
			self.NovicePacksAwardTimeEffect.gameObject:SetActive(true)
			self.RedDotImage.gameObject:SetActive(true)
		else
		--	self.countTime=self.countTime-Time.deltaTime
			if os.time()-self.lastT>=1 then
				self.lastT=os.time()
				self.countTime=self.countTime-1
			end
			self.NovicePacksAwardTimeEffect.gameObject:SetActive(false)
			self.RedDotImage.gameObject:SetActive(false)
			--print(self.countTime)
			self.NovicePacksAwardTimeText.text=utility.ConvertTime(self.countTime)
		end	
	end
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function NovicePacksAwardButtonCls:InitControls()
	local transform = self:GetUnityTransform()
	 self.game = utility.GetGame()
	self.NovicePacksAwardButton = transform:Find(''):GetComponent(typeof(UnityEngine.UI.Button))
	self.NovicePacksAwardTimeText = transform:Find('NovicePacksAwardTimeLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.NovicePacksAwardTimeEffect = transform:Find('Effect_zaixian')
	self.RedDotImage = transform:Find('RedDotImage')

	
	self.NovicePacksAwardTimeEffect.gameObject:SetActive(false)
	self.RedDotImage.gameObject:SetActive(false)
	transform:SetParent(self.Parent)
	self.lastT =0

end


function NovicePacksAwardButtonCls:RegisterControlEvents()
	-- 注册 NovicePacksAwardButton 的事件
	self.__event_button_onNovicePacksAwardButtonClicked__ = UnityEngine.Events.UnityAction(self.OnNovicePacksAwardButtonClicked, self)
	self.NovicePacksAwardButton.onClick:AddListener(self.__event_button_onNovicePacksAwardButtonClicked__)
end

function NovicePacksAwardButtonCls:UnregisterControlEvents()
	-- 取消注册 NovicePacksAwardButton 的事件
	if self.__event_button_onNovicePacksAwardButtonClicked__ then
		self.NovicePacksAwardButton.onClick:RemoveListener(self.__event_button_onNovicePacksAwardButtonClicked__)
		self.__event_button_onNovicePacksAwardButtonClicked__ = nil
	end
end
function NovicePacksAwardButtonCls:RegisterNetworkEvents()
	--RegisterNetworkEvents控件的网络事件处理
	 self.game:RegisterMsgHandler(net.S2COnlineAwardQueryResult, self, self.OnlineAwardQueryResult)
	
end

function NovicePacksAwardButtonCls:UnregisterNetworkEvents()
	--UnregisterNetworkEvents 控件的网络事件处理
	 self.game:UnRegisterMsgHandler(net.S2COnlineAwardQueryResult, self, self.OnlineAwardQueryResult)
	
end
function NovicePacksAwardButtonCls:OnlineAwardQueryRequest()
	-- body
	self.game:SendNetworkMessage(require"Network/ServerService".OnlineAwardQueryRequest())
end

function NovicePacksAwardButtonCls:OnlineAwardQueryResult(msg)
	print(msg.totalTime,"****************")

	self.totalTime=msg.totalTime
	local OnlineTimeAwardData = require"StaticData/Activity/OnlineTimeAward"
	print(OnlineTimeAwardData:GetData(2):GetBaseMinute())
	for i=1,#msg.list do
	     print(msg.list[i].state,msg.list[i].index,OnlineTimeAwardData:GetData(msg.list[i].index):GetBaseMinute(),"**********",OnlineTimeAwardData:GetData(msg.list[i].index):GetItemID1())

		if msg.list[i].state==1  then
			--self.NovicePacksAwardTimeText.text="可领取"
			--领取的物体
			self.NovicePacksAward=msg.list[i]

			--表示时间已经到了 可以领取
			self.countTime=-1
			break
		elseif msg.list[i].state==2 then
			print(OnlineTimeAwardData:GetData(msg.list[i].index):GetBaseMinute())
			self.countTime=OnlineTimeAwardData:GetData(msg.list[i].index):GetBaseMinute()*60-self.totalTime+1
			print(self.countTime)
			self.NovicePacksAward=msg.list[i]
		--	self.awardItemID=OnlineTimeAwardData:GetData(msg.list[i].index):GetItemID()
	  --      print(OnlineTimeAwardData:GetData(msg.list[i].index):GetBaseMinute(),"**********",OnlineTimeAwardData:GetData(msg.list[i].index):GetItemID())

			break			
		end
	end
	self.isShowOnline=false
	for i=1,#msg.list do
			--是否全部领取了
		if msg.list[i].state~=3 then
			self.isShowOnline=true
			break
			end
		end
	if self.isShowOnline then
	else
	self:UnscheduleUpdate()
	--	print("false 没有可领取的")
	self:CleanupComponent()
	end

end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function NovicePacksAwardButtonCls:OnNovicePacksAwardButtonClicked()
	--NovicePacksAwardButton控件的点击事件处理
	local windowManager = self.game:GetWindowManager()
    windowManager:Show(require "GUI.Activity.NovicePacks",self)
end

return NovicePacksAwardButtonCls

