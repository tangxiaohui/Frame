local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
local messageGuids = require "Framework.Business.MessageGuids"
-- local messageManager = require "Network.MessageManager"
local ConnectingCls = Class(BaseNodeClass)

function ConnectingCls:Ctor()

end

local function OnGameReconnected(self)

	self.callBack:Invoke(self,false)
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function ConnectingCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/Connecting', function(go)
		self:BindComponent(go)
	end)
end
function ConnectingCls:OnWillShow(data,count,masterTableID,callBack)
	self.data=data
	self.count=count
	self.masterTableID=masterTableID
	 if callBack ~=nil then
        self.callBack=LuaDelegate.New()
        self.callBack:Set(table, callBack)
    end


end
function ConnectingCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function ConnectingCls:OnResume()
	-- 界面显示时调用
	ConnectingCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:InitData()
    self:RegisterEvent(messageGuids.LoadAllUserDataFinished, OnGameReconnected)

end

function ConnectingCls:OnPause()
	-- 界面隐藏时调用
	ConnectingCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
	self:UnregisterEvent(messageGuids.LoadAllUserDataFinished, OnGameReconnected)

end

function ConnectingCls:OnEnter()
	-- Node Enter时调用
	ConnectingCls.base.OnEnter(self)
end

function ConnectingCls:OnExit()
	-- Node Exit时调用
	ConnectingCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function ConnectingCls:InitControls()
	local transform = self:GetUnityTransform()
	self.game = utility:GetGame()

	self.backgroundObject = transform:Find("TranslucentLayer").gameObject
	--self.TranslucentLayer = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Image))
	self.connectingObject = transform:Find("Loading").gameObject

	self.backgroundObject:SetActive(false)
	self.connectingObject:SetActive(false)
end


local function RotateTrans(self)
	-- while(true) do
	-- 	if self.rotateCou~=nil then
	-- 		self.connecting.localEulerAngles=Vector3(self.connecting.localEulerAngles.x, self.connecting.localEulerAngles.y, self.connecting.localEulerAngles.z-10)
	-- 		coroutine.step()
	-- 	else
	-- 		break
	-- 	end
	-- end
end

local function ShowNormol(str)
	local windowManager = utility:GetGame():GetWindowManager()
	local ConfirmDialogClass = require "GUI.Dialogs.NormalDialog"	
	windowManager:Show(ConfirmDialogClass, str)
end

function ConnectingCls:InitData()
end

function ConnectingCls:ControlRotate(flag)
	-- if flag then
	-- 	if self.rotateCou==nil then
	-- 		self.rotateCou=coroutine.start(RotateTrans,self) 
	-- 	end
	-- else
	-- 	if self.rotateCou~=nil then
	-- 		coroutine.stop(self.rotateCou) 
	-- 		self.rotateCou=nil
	-- 	end
	-- end
end

function ConnectingCls:RegisterControlEvents()
end

function ConnectingCls:UnregisterControlEvents()
end

function ConnectingCls:RegisterNetworkEvents()
	self.game:RegisterMsgHandler(net.S2CVipChargeDoneResult, self, self.VipChargeDoneResult)
end

function ConnectingCls:UnregisterNetworkEvents()
	 self.game:UnRegisterMsgHandler(net.S2CVipChargeDoneResult, self, self.VipChargeDoneResult)
end

function ConnectingCls:VipChargeDoneResult(msg)
	-- self:ControlRotate(false)
	debug_print("VipChargeDoneResult停止转圈")
	if msg.success then
		--self:ColseWinsNode()
        self.callBack:Invoke(self,true)
        debug_print("---------------------------------------")
		--ShowNormol("充值成功！")
	else
		--ShowNormol("充值失败！")
        self.callBack:Invoke(self,false)

		--self:ColseWinsNode()
	end
end

local function CloseNode(self)
	coroutine.step()
	self:Close()
end

function ConnectingCls:ColseWinsNode()
	self:StartCoroutine(CloseNode)
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
return ConnectingCls
