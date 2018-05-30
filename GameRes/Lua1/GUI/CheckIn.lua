local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
local windowUtility = require "Framework.Window.WindowUtility"
local CheckInCls = Class(BaseNodeClass)
windowUtility.SetMutex(CheckInCls, true)
function CheckInCls:Ctor()

end
--- 场景状态
-----------------------------------------------------------------------
function CheckInCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/CheckIn (1)', function(go)
		self:BindComponent(go)
	end)
end

function CheckInCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
	self.game:SendNetworkMessage(require"Network.ServerService".DailySignInQueryRequest())
end

function CheckInCls:OnResume()
	-- 界面显示时调用
	CheckInCls.base.OnResume(self)

	require "Utils.GameAnalysisUtils".RecordLocalAction(kTrackingId_CheckInView)

	self:GetUnityTransform():SetAsLastSibling()
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	
end

function CheckInCls:OnPause()
	-- 界面隐藏时调用
	CheckInCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function CheckInCls:OnEnter()
	-- Node Enter时调用
	CheckInCls.base.OnEnter(self)
end


function CheckInCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end

function CheckInCls:OnExit()
	-- Node Exit时调用
	CheckInCls.base.OnExit(self)

end
-- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function CheckInCls:InitControls()
	local transform = self:GetUnityTransform()
	self.game = utility.GetGame()
	--主页面返回按钮
	self.CheckInRetrunButton = transform:Find('CheckInRetrunButton'):GetComponent(typeof(UnityEngine.UI.Button))--
	--主页面签到说明按钮
	self.CheckInDescriptionButton = transform:Find('CheckInDescriptionButton'):GetComponent(typeof(UnityEngine.UI.Button))--返回按钮
	--主页面本月月份
	self.CheckInMonthNumText = transform:Find('CheckInTitle/CheckInTitleLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--主页面本月签到次数
	self.CheckInNumText = transform:Find('Times/CheckInTimesLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--签到UI父物体
	self.CheckInItemParent = transform:Find('Scroll View/Viewport/Panel/Content1')
	self.CheckInItemContent2Parent = transform:Find('Scroll View/Viewport/Panel/Content2')
	self.CheckInItemContent3Parent = transform:Find('Scroll View/Viewport/Panel/Content3')

	--背景按钮
	self.BackgroundButton = transform:Find('WindowBase/TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))

	self.maskImage=transform:Find('Scroll View/Viewport'):GetComponent(typeof(UnityEngine.UI.Image))
	--

	self.items={}	
end
local function CheckInCallBack(tables,id,day)
	
	if day<=31 then
		tables.CheckInNumText.text=day
	end
end 

function CheckInCls:InitView(msg)

	self.CheckInMonthNumText.text=msg.month.."月签到奖励"
	--读取签到信息
	for i=1,#msg.dailySignIn do
		if msg.dailySignIn[i].state==1 then
			self.CheckInNumText.text=i-1
			self.checkInDay=i-1
		elseif msg.dailySignIn[i].state==2 then
			self.CheckInNumText.text=i
			--self.checkInDay=i
			end
		self.items[i]=require"GUI.CheckInItem".New(self.CheckInItemParent,msg.dailySignIn[i],false)	
		self.items[i]:SetCallback(self,CheckInCallBack)
		self:AddChild(self.items[i])	

		end
	self.CheckInItemContent2Parent.gameObject:SetActive(true)
	--读取签到信息
	print(#msg.dailySignStage,"*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*")
	for i=1,#msg.dailySignStage do
		--print(msg[i].state)
		-- if msg.dailySignStage[i].state==1 then
		-- 	self.CheckInNumText.text=i-1
		-- 	self.checkInDay=i-1
		-- elseif msg.dailySignIn[i].state==2 then
		-- 	self.CheckInNumText.text=i
		-- 	--self.checkInDay=i
		-- 	end
		self.items[i]=require"GUI.CheckInItem".New(self.CheckInItemContent3Parent ,msg.dailySignStage[i],true)	
		self.items[i]:SetCallback(self,CheckInCallBack)
		self:AddChild(self.items[i])	

		end
	-- body
end


function CheckInCls:RegisterControlEvents()
	-- 注册 CheckInRetrunButton 的事件
	self.__event_button_onCheckInRetrunButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCheckInRetrunButtonClicked, self)
	self.CheckInRetrunButton.onClick:AddListener(self.__event_button_onCheckInRetrunButtonClicked__)

	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCheckInRetrunButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

	-- 注册 CheckInDescriptionButton 的事件
	self.__event_button_onCheckInDescriptionButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCheckInDescriptionButtonClicked, self)
	self.CheckInDescriptionButton.onClick:AddListener(self.__event_button_onCheckInDescriptionButtonClicked__)
	

end

function CheckInCls:UnregisterControlEvents()
	-- 取消注册 CheckInRetrunButton 的事件
	if self.__event_button_onCheckInRetrunButtonClicked__ then
	   self.CheckInRetrunButton.onClick:RemoveListener(self.__event_button_onCheckInRetrunButtonClicked__)
	   self.__event_button_onCheckInRetrunButtonClicked__ = nil
	end
	-- 取消注册 CheckInDescriptionButton 的事件
	if self.__event_button_onCheckInDescriptionButtonClicked__ then
	   self.CheckInDescriptionButton.onClick:RemoveListener(self.__event_button_onCheckInDescriptionButtonClicked__)
	   self.__event_button_onCheckInDescriptionButtonClicked__ = nil
	end
	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end
end




function CheckInCls:RegisterNetworkEvents()
	-- print("RegisterNetworkEvents6666")
    self.game:RegisterMsgHandler(net.S2CDailySignInQueryResult, self, self.DailySignInQueryResult)
   -- self.game:RegisterMsgHandler(net.S2CEquipBagFlush, self, self.EquipBagFlushResult)

   -- self.game:RegisterMsgHandler(net.S2CChangePlayerNameResult, self, self.ChangePlayerNameResult)
    --print("RegisterNetworkEvents")
end

function CheckInCls:UnregisterNetworkEvents()
    self.game:UnRegisterMsgHandler(net.S2CDailySignInQueryResult, self, self.DailySignInQueryResult)
 --   self.game:UnRegisterMsgHandler(net.S2CEquipBagFlush, self, self.EquipBagFlushResult)
end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function CheckInCls:OnCheckInRetrunButtonClicked()
	--CheckInRetrunButton控件的点击事件处理
    self:Close()
end

function CheckInCls:OnCheckInDescriptionButtonClicked()
	-- local windowManager = self.game:GetWindowManager()
 --    windowManager:Show(require "GUI.CheckInDescriptionUIPanel")
   
    local id = require"StaticData.SystemConfig.SystemBasis":GetData(KSystemBasis_CheckID):GetDescriptionInfo()[0]
	local hintStr = require "StaticData.SystemConfig.SystemDescriptionInfo":GetData(id):GetDescription()
	local str = string.gsub(hintStr,"\\n","\n")
	
    local windowManager = self.game:GetWindowManager()
    windowManager:Show(require "GUI.CommonDescriptionModule",str)



end

function CheckInCls:DailySignInQueryResult(msg)

	--print("请求签到信息返回",msg.month,msg.head)
--	self.CheckInNumText.text=self.checkInDay
	self:InitView(msg)
end






return CheckInCls
