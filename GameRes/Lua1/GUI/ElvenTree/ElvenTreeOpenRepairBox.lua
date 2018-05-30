local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local ElvenTreeOpenRepairBoxCls = Class(BaseNodeClass)

function ElvenTreeOpenRepairBoxCls:Ctor()
	
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function ElvenTreeOpenRepairBoxCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/ElvenTreeOpenRepairBox', function(go)
		self:BindComponent(go)
	end)
end
function ElvenTreeOpenRepairBoxCls:OnWillShow(index,flag)
	self.index=index
	self.flag=flag
	end
function ElvenTreeOpenRepairBoxCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function ElvenTreeOpenRepairBoxCls:OnResume()
	-- 界面显示时调用
	ElvenTreeOpenRepairBoxCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:InitViews()
--	self:RegisterNetworkEvents()
end

function ElvenTreeOpenRepairBoxCls:OnPause()
	-- 界面隐藏时调用
	ElvenTreeOpenRepairBoxCls.base.OnPause(self)
	self:UnregisterControlEvents()
--	self:UnregisterNetworkEvents()
end

function ElvenTreeOpenRepairBoxCls:OnEnter()
	-- Node Enter时调用
	ElvenTreeOpenRepairBoxCls.base.OnEnter(self)
end

function ElvenTreeOpenRepairBoxCls:OnExit()
	-- Node Exit时调用
	ElvenTreeOpenRepairBoxCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function ElvenTreeOpenRepairBoxCls:InitControls()
	local transform = self:GetUnityTransform()
	self.game = utility:GetGame()
	self.ElvenTreeDescriptionButton = transform:Find('ConferButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ElvenTreeDescriptionLabel = transform:Find('NeedLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Notice4 = transform:Find('Notice (4)'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Notice3 = transform:Find('Notice (3)'):GetComponent(typeof(UnityEngine.UI.Text))
	self.DyaIcon = transform:Find('DyaIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ElvenTreeReturnButton = transform:Find('CancelButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ElvenTreeDescriptionCrossButton = transform:Find('SmallWindowBase/CheckInDescriptionRetrunButton'):GetComponent(typeof(UnityEngine.UI.Button))

	--背景按钮
	self.BackgroundButton = transform:Find('SmallWindowBase/TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))

	self.Notice4.enabled=false
	self.DyaIcon.enabled=false
	self.ElvenTreeDescriptionLabel.enabled=false

end

function ElvenTreeOpenRepairBoxCls:InitViews( )

	  local UserDataType = require "Framework.UserDataType"
      local userData = self:GetCachedData(UserDataType.PlayerData)
      local vip = userData:GetVip()

		local FactoryConfigData = require"StaticData/Factory/FactoryConfig"
	     debug_print(FactoryConfigData:GetData(1):Slot4Vip(),"**********",FactoryConfigData:GetData(1):Slot4Diamond())

	     if self.index==4 then
	     	local limitVip = FactoryConfigData:GetData(1):Slot4Vip()
	     	debug_print(vip,limitVip)
	     	if vip>=limitVip then
	     		self.Notice4.enabled=false
				self.DyaIcon.enabled=false
	     		self.Notice3.text="达到VIP"..limitVip.."可以进行免费解锁"
	     	else
		     	--self.Notice3.enabled=true
		     	self.Notice3.text="是否进行解锁"
				self.Notice4.enabled=true
				self.DyaIcon.enabled=true
				self.ElvenTreeDescriptionLabel.enabled=true

				self.ElvenTreeDescriptionLabel.text=FactoryConfigData:GetData(1):Slot4Diamond()

			end
	     elseif self.index==5 then

	     		if not self.flag then
	     			print("*/**********")
	     			
		     		--	self.Notice3.enabled=true
		     			self.Notice3.text="请先解锁上一档孵化点"
						self.Notice4.enabled=false
						self.DyaIcon.enabled=false
		     			self.ElvenTreeDescriptionLabel.enabled=false
	     			
	     		else
	     			local limitVip = FactoryConfigData:GetData(1):Slot5Vip()
	     			debug_print(vip,limitVip)
			     	if vip>=limitVip then
			     		self.Notice4.enabled=false
						self.DyaIcon.enabled=false
			     		self.Notice3.text="达到VIP"..limitVip.."可以进行免费解锁"
			     	else
		     			self.Notice4.enabled=true
						self.DyaIcon.enabled=true
						self.Notice3.text="是否进行解锁"
						self.ElvenTreeDescriptionLabel.enabled=true
		     				print("ooooooooooooooooooooo")
						self.ElvenTreeDescriptionLabel.text=FactoryConfigData:GetData(1):Slot5Diamond()
					end
	     		end
	    end

end


function ElvenTreeOpenRepairBoxCls:RegisterControlEvents()
	-- 注册 ElvenTreeDescriptionButton 的事件
	self.__event_button_onElvenTreeDescriptionButtonClicked__ = UnityEngine.Events.UnityAction(self.OnElvenTreeDescriptionButtonClicked, self)
	self.ElvenTreeDescriptionButton.onClick:AddListener(self.__event_button_onElvenTreeDescriptionButtonClicked__)

	-- 注册 ElvenTreeDescriptionButton 的事件
	self.__event_button_onElvenTreeReturnButtonClicked__ = UnityEngine.Events.UnityAction(self.OnElvenTreeReturnButtonClicked, self)
	self.ElvenTreeReturnButton.onClick:AddListener(self.__event_button_onElvenTreeReturnButtonClicked__)

	self.__event_button_onElvenTreeDescriptionCrossButtonClicked__ = UnityEngine.Events.UnityAction(self.OnElvenTreeReturnButtonClicked, self)
	self.ElvenTreeDescriptionCrossButton.onClick:AddListener(self.__event_button_onElvenTreeDescriptionCrossButtonClicked__)

	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnElvenTreeReturnButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

end

function ElvenTreeOpenRepairBoxCls:UnregisterControlEvents()
	-- 取消注册 ElvenTreeDescriptionButton 的事件
	if self.__event_button_onElvenTreeDescriptionButtonClicked__ then
		self.ElvenTreeDescriptionButton.onClick:RemoveListener(self.__event_button_onElvenTreeDescriptionButtonClicked__)
		self.__event_button_onElvenTreeDescriptionButtonClicked__ = nil
	end

	-- 取消注册 ElvenTreeDescriptionButton 的事件
	if self.__event_button_onElvenTreeReturnButtonClicked__ then
		self.ElvenTreeReturnButton.onClick:RemoveListener(self.__event_button_onElvenTreeReturnButtonClicked__)
		self.__event_button_onElvenTreeReturnButtonClicked__ = nil
	end

		-- 取消注册 ElvenTreeDescriptionButton 的事件
	if self.__event_button_onElvenTreeDescriptionCrossButtonClicked__ then
		self.ElvenTreeDescriptionCrossButton.onClick:RemoveListener(self.__event_button_onElvenTreeDescriptionCrossButtonClicked__)
		self.__event_button_onElvenTreeDescriptionCrossButtonClicked__ = nil
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
function ElvenTreeOpenRepairBoxCls:OnElvenTreeDescriptionButtonClicked()
	--ElvenTreeDescriptionButton控件的点击事件处理
	if not self.flag then
	     			
	     		else
			self.game:SendNetworkMessage(require "Network.ServerService".RobQueryRequest(100,self.index))
	     		end
	
	self:Close()
end

function ElvenTreeOpenRepairBoxCls:OnElvenTreeReturnButtonClicked()
	--ElvenTreeDescriptionButton控件的点击事件处理
	self:Close()
end

return ElvenTreeOpenRepairBoxCls

