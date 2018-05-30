local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local PersonalInformationChangeHeadCls = Class(BaseNodeClass)
require "System.LuaDelegate"
function PersonalInformationChangeHeadCls:Ctor(parent,info,flag,cardID)
	self.Parent = parent
	self.Info = info
	self.Flag=flag
	self.callback = LuaDelegate.New()
	self.headCardID=cardID

--	print()
--	print(self.Parent,info,"頭像",self.headCardID,flag)
end



-----------------------------------------------------------------------
--- 回调
-----------------------------------------------------------------------
function PersonalInformationChangeHeadCls:SetCallback(tables,id, func)
	self.tables=tables
    self.callback:Set(id, func)
end



-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function PersonalInformationChangeHeadCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/PersonalInformationChangeHead', function(go)
		self:BindComponent(go,false)
	end)
end

function PersonalInformationChangeHeadCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
	self:LinkComponent(self.Parent)
--	self
end

function PersonalInformationChangeHeadCls:OnResume()
	-- 界面显示时调用
	PersonalInformationChangeHeadCls.base.OnResume(self)
	self:RegisterControlEvents()
--	self:RegisterNetworkEvents()
end


function PersonalInformationChangeHeadCls:RefreshHeadCard(parentTran)
	print("PersonalInformationChangeHeadCls",self.Parent,parentTran)
	self.PersonalInformationHeadIcon.material=nil
	self.Flag=true
	--self.Parent = parentTran
	print(self:GetUnityTransform().name)
	 self:GetUnityTransform():SetParent(parentTran)
	self.PersonalInformationHeadIconButton.enabled=self.Flag

end

function PersonalInformationChangeHeadCls:CancleCheck()
	print("处理取消点中的特效")
	PersonalInformationChangeHeadCls.base.Color=UnityEngine.Color(0, 0, 0, 1)
	print(self.Color)
end


function PersonalInformationChangeHeadCls:OnPause()
	-- 界面隐藏时调用
	PersonalInformationChangeHeadCls.base.OnPause(self)
	self:UnregisterControlEvents()
--	self:UnregisterNetworkEvents()
end

function PersonalInformationChangeHeadCls:OnEnter()
	-- Node Enter时调用
	PersonalInformationChangeHeadCls.base.OnEnter(self)
end

function PersonalInformationChangeHeadCls:OnExit()
	-- Node Exit时调用
	PersonalInformationChangeHeadCls.base.OnExit(self)
end

function PersonalInformationChangeHeadCls:IsOpen()
	-- if self.Info.

end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function PersonalInformationChangeHeadCls:InitControls()
	local transform = self:GetUnityTransform()
	self.Base = transform:Find('Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.PersonalInformationHeadIcon = transform:Find('Base/PersonalInformationHeadIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.PersonalInformationHeadIconButton=self.PersonalInformationHeadIcon:GetComponent(typeof(UnityEngine.UI.Button))
	--if(self.Flag)
		self.PersonalInformationHeadIconButton.enabled=self.Flag
		if self.Flag then
		self.PersonalInformationHeadIcon.material=nil
		end
	--local resPath = string.format("UI/Atlases/CardHead/%s", self.Info)
	--print(self.Info)
	-- print(self.headCardID)
	-- local tempIconName = require"StaticData/PlayerHead":GetData(self.headCardID):GetIcon()
	-- local iconPath = "UI/Atlases/CardHead/"..tostring(tempIconName)

 --	print(self.headCardID,self.PersonalInformationHeadIcon)
 	  utility.LoadRoleHeadIcon(self.headCardID , self.PersonalInformationHeadIcon)
end


function PersonalInformationChangeHeadCls:RegisterControlEvents()

		-- 注册 PersonalInformationRetrunButton 的事件
	self.__event_button_onPersonalInformationHeadIconButtonClicked__ = UnityEngine.Events.UnityAction(self.OnPersonalInformationHeadIconButtonClicked, self)
	self.PersonalInformationHeadIconButton.onClick:AddListener(self.__event_button_onPersonalInformationHeadIconButtonClicked__)
end


function PersonalInformationChangeHeadCls:OnPersonalInformationHeadIconButtonClicked()
	print("OnPersonalInformationHeadIconButtonClicked",self.headCardID)
	self.callback:Invoke(self.tables,self.headCardID)
	PersonalInformationChangeHeadCls.base.Color=UnityEngine.Color(1, 0, 0, 1)
	print(PersonalInformationChangeHeadCls.base.Color)
end

function PersonalInformationChangeHeadCls:UnregisterControlEvents()

	if self.__event_button_onPersonalInformationHeadIconButtonClicked__ then
		self.PersonalInformationHeadIconButton.onClick:RemoveListener(self.__event_button_onPersonalInformationHeadIconButtonClicked__)
		self.__event_button_onPersonalInformationHeadIconButtonClicked__ = nil
	end


end



-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
return PersonalInformationChangeHeadCls