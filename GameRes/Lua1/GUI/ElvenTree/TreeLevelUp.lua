local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local TreeLevelUpCls = Class(BaseNodeClass)

function TreeLevelUpCls:Ctor()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function TreeLevelUpCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/TreeLevelUp', function(go)
		self:BindComponent(go)
	end)
end
function TreeLevelUpCls:OnWillShow(level,exp,callback,table)
	self.level=level
	self.exp=exp
	self.callback = LuaDelegate.New()
	self.callback:Set(table, callback)
end
function TreeLevelUpCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function TreeLevelUpCls:OnResume()
	-- 界面显示时调用
	TreeLevelUpCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
end

function TreeLevelUpCls:OnPause()
	-- 界面隐藏时调用
	TreeLevelUpCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function TreeLevelUpCls:OnEnter()
	-- Node Enter时调用
	TreeLevelUpCls.base.OnEnter(self)
end

function TreeLevelUpCls:OnExit()
	-- Node Exit时调用
	TreeLevelUpCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function TreeLevelUpCls:InitControls()
	local transform = self:GetUnityTransform()
	-- self.TranslucentLayer = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.BigFarme = transform:Find('TweenObj/WindowBase/BigFarme'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.UpperBorder = transform:Find('TweenObj/WindowBase/UpperBorder'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.DownerBorder = transform:Find('TweenObj/WindowBase/DownerBorder'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.GrayFarme = transform:Find('TweenObj/WindowBase/GrayFarme'):GetComponent(typeof(UnityEngine.UI.Image))
	self.RetrunButton = transform:Find('TweenObj/RetrunButton'):GetComponent(typeof(UnityEngine.UI.Button))
	-- self.Text = transform:Find('TweenObj/TreeLevel/Text'):GetComponent(typeof(UnityEngine.UI.Text))
	-- self.Image = transform:Find('TweenObj/TreeLevel/Image'):GetComponent(typeof(UnityEngine.UI.Image))
	self.LevelLabel = transform:Find('TweenObj/TreeLevel/LevelLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ExpNumLabel = transform:Find('TweenObj/ExpSlider/ExpNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.FillFrame = transform:Find('TweenObj/ExpSlider/ExpSliderMask/FillFrame'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.Base01 = transform:Find('TweenObj/ExpItemLayout/ExpItem01/Base01'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ExpItem01Color = transform:Find('TweenObj/ExpItemLayout/ExpItem01/ExpItem01Color'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ExpItem01Icon = transform:Find('TweenObj/ExpItemLayout/ExpItem01/ExpItem01Icon'):GetComponent(typeof(UnityEngine.UI.RepeatButton))
	self.ExpItem01IconImage = transform:Find('TweenObj/ExpItemLayout/ExpItem01/ExpItem01Icon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ExpItem01NumLabel = transform:Find('TweenObj/ExpItemLayout/ExpItem01/ExpItem01NumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Frame = transform:Find('TweenObj/LeftSeed/Frame'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Icon = transform:Find('TweenObj/LeftSeed/Frame/Icon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.NumLabel = transform:Find('TweenObj/LeftSeed/Frame/NumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--self.Base = transform:Find('TweenObj/Status/Base'):GetComponent(typeof(UnityEngine.UI.Image))
	--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))
	self.currentText={}
	self.currentText[#self.currentText+1] = transform:Find('TweenObj/Status/Layout/Text'):GetComponent(typeof(UnityEngine.UI.Text))
	self.currentText[#self.currentText+1] = transform:Find('TweenObj/Status/Layout/Text (1)'):GetComponent(typeof(UnityEngine.UI.Text))
	self.currentText[#self.currentText+1] = transform:Find('TweenObj/Status/Layout/Text (2)'):GetComponent(typeof(UnityEngine.UI.Text))
	self.currentText[#self.currentText+1] = transform:Find('TweenObj/Status/Layout/Text (3)'):GetComponent(typeof(UnityEngine.UI.Text))
	--self.Base1 = transform:Find('TweenObj/NextStatus/Base'):GetComponent(typeof(UnityEngine.UI.Image))
	
	self.nextText={}
	self.nextText[#self.nextText+1] = transform:Find('TweenObj/NextStatus/Layout/Text'):GetComponent(typeof(UnityEngine.UI.Text))
	self.nextText[#self.nextText+1] = transform:Find('TweenObj/NextStatus/Layout/Text (1)'):GetComponent(typeof(UnityEngine.UI.Text))
	self.nextText[#self.nextText+1] = transform:Find('TweenObj/NextStatus/Layout/Text (2)'):GetComponent(typeof(UnityEngine.UI.Text))
	self.nextText[#self.nextText+1] = transform:Find('TweenObj/NextStatus/Layout/Text (3)'):GetComponent(typeof(UnityEngine.UI.Text))
	for i=1,#self.currentText do
		self.currentText[i].gameObject:SetActive(false)
	end
	for i=1,#self.nextText do
		self.nextText[i].gameObject:SetActive(false)
	end
--	self.Arrow = transform:Find('TweenObj/Arrow'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Text3 = transform:Find('TweenObj/Text'):GetComponent(typeof(UnityEngine.UI.Text))
	self:InitViews()
end
function TreeLevelUpCls:InitViews()

	local TreeLevelUpData = require"StaticData/Factory/TreeLevelUp":GetData(self.level)
	-- debug_print(TreeLevelUpData:GetNeedType(),TreeLevelUpData:GetNeedNum(),TreeLevelUpData:GetReduceTime())
	-- local nums = TreeLevelUpData:GetPowerNum()
	-- local types = TreeLevelUpData:GetPowerType()
	-- --debug_print()
	-- for i=1,#nums do
	-- 	debug_print(i,nums[i])
	-- end

	-- for i=1,#types do
	-- 	debug_print(i,types[i])
	-- end

	--utility.LoadSpriteFromPath("UI/Atlases/Icon/TalentIcon/"..roleTalentData:GetResourceID(),self.Rank5Skill1Icon)

	local needNum = TreeLevelUpData:GetNeedNum()
	self.LevelLabel.text=self.level
	if needNum>0 then
		self.maxLevel=false		
		self.ExpNumLabel.text=self.exp.."/"..TreeLevelUpData:GetNeedNum()
		self.FillFrame.fillAmount = self.exp/TreeLevelUpData:GetNeedNum()
	else
		self.maxLevel=true
		self.FillFrame.fillAmount =1
		self.ExpNumLabel.text="已达满级"
	end
	local types = TreeLevelUpData:GetPowerType()
	local nums = TreeLevelUpData:GetPowerNum()
	--当前属性
	if self.level==0 then
		self.currentText[1].gameObject:SetActive(true)
		self.currentText[1].text="暂未加成"
	else
		for i=1,#types do
			self.currentText[i].gameObject:SetActive(true)
			self.currentText[i].text=EquipStringTable[types[i]].."+"..nums[i]
		end
		self.currentText[#types+1].gameObject:SetActive(true)
		self.currentText[#types+1].text=string.format(CommonStringTable[12], TreeLevelUpData:GetReduceTime())

	end

	--下一级别的属性

	if self.maxLevel then
		self.nextText[1].gameObject:SetActive(true)
		self.nextText[1].text="最大等级"
	else
		TreeLevelUpData = require"StaticData/Factory/TreeLevelUp":GetData(self.level+1)
		types = TreeLevelUpData:GetPowerType()
		nums = TreeLevelUpData:GetPowerNum()
		for i=1,#types do
			self.nextText[i].gameObject:SetActive(true)
			self.nextText[i].text=EquipStringTable[types[i]].."+"..nums[i]
		end
		self.nextText[#types+1].gameObject:SetActive(true)
		local str = string.gsub(CommonStringTable[12],"\\n","\n")
		self.nextText[#types+1].text=string.format(CommonStringTable[12], TreeLevelUpData:GetReduceTime())
	end

	local UserDataType = require "Framework.UserDataType"
	local itemCardData = self:GetCachedData(UserDataType.ItemBagData)
	local count=itemCardData:GetItemCountById(TreeLevelUpData:GetNeedType())
	self.ExpItem01NumLabel.text='X'..count
	--local itemData = require"StaticData/Item":GetData(TreeLevelUpData:GetNeedType())
	

	local PropUtility = require "Utils.PropUtility"
	local gametool = require "Utils.GameTools"

	local _,data,_,icon = gametool.GetItemDataById(TreeLevelUpData:GetNeedType())
	local color = data:GetColor()
	debug_print(icon," ++++++++++++++++++ ")
	PropUtility.AutoSetColor(self.ExpItem01Color,color)
	utility.LoadSpriteFromPath(icon,self.ExpItem01IconImage)
end

function Include(value, tab)
    for k,v in ipairs(tab) do
      if v == value then
          return true
      end
    end
    return false
end
--计算属性
function TreeLevelUpCls:CalculateAttribute()
	local TreeLevelUpData = require"StaticData/Factory/TreeLevelUp"
	local powersType = {}
	debug_print(self.level)
	for i=0,self.level do
		local data = TreeLevelUpData:GetData(i)	
		local types = data:GetPowerType()
		local nums = data:GetPowerNum()
		for i=1,#types do
			if types[i]~=nil then
				if Include(types[i],powers) then				
					
				else
					powersType[#powersType+1]=types[i]
				end
			end
		end
	end
	for i=1,#powersType do
		debug_print("powersType",powersType[i])
	end

end



function TreeLevelUpCls:RegisterControlEvents()
	-- 注册 RetrunButton 的事件
	self.__event_button_onRetrunButtonClicked__ = UnityEngine.Events.UnityAction(self.OnRetrunButtonClicked, self)
	self.RetrunButton.onClick:AddListener(self.__event_button_onRetrunButtonClicked__)

	-- 注册 ExpItem01Icon 的事件
	self.__event_button_onExpItem01IconClicked__ = UnityEngine.Events.UnityAction(self.OnExpItem01IconClicked, self)
	self.ExpItem01Icon.onClick:AddListener(self.__event_button_onExpItem01IconClicked__)

	self._event_button_onExpItem01IconRepeatClicked = UnityEngine.Events.UnityAction(self.OnExpItem01IconRepeatClicked, self)
    self.ExpItem01Icon.m_OnRepeat:AddListener(self._event_button_onExpItem01IconRepeatClicked)

    -- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnRetrunButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

end

function TreeLevelUpCls:UnregisterControlEvents()
	-- 取消注册 RetrunButton 的事件
	if self.__event_button_onRetrunButtonClicked__ then
		self.RetrunButton.onClick:RemoveListener(self.__event_button_onRetrunButtonClicked__)
		self.__event_button_onRetrunButtonClicked__ = nil
	end

	-- 取消注册 ExpItem01Icon 的事件
	if self.__event_button_onExpItem01IconClicked__ then
		self.ExpItem01Icon.onClick:RemoveListener(self.__event_button_onExpItem01IconClicked__)
		self.__event_button_onExpItem01IconClicked__ = nil
	end

		-- 取消注册 ExpItem01Icon 的事件
	if self._event_button_onExpItem01IconRepeatClicked then
		
		self.ExpItem01Icon.m_OnRepeat:RemoveListener(self._event_button_onExpItem01IconRepeatClicked)
		self._event_button_onExpItem01IconRepeatClicked = nil
	end

	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end

end

function TreeLevelUpCls:RegisterNetworkEvents()
	self:GetGame():RegisterMsgHandler(net.S2CRobTreeLevelUpResult, self, self.RobTreeLevelUpResult)

end

function TreeLevelUpCls:UnregisterNetworkEvents()

	self:GetGame():UnRegisterMsgHandler(net.S2CRobTreeLevelUpResult, self, self.RobTreeLevelUpResult)

end
function TreeLevelUpCls:RobTreeLevelUpResult(msg)
	debug_print("RobTreeLevelUpResult",msg.level,msg.exp)
	self.level=msg.level
	self.exp=msg.exp
	self:InitViews()

	-- local UserDataType = require "Framework.UserDataType"
 --    local userData = self:GetCachedData(UserDataType.PlayerData)
	-- debug_print(userData:GetTreeLevel(),"GetTreeLevel")
	--utility.GetTreeUpAddProperty(msg.level)
end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function TreeLevelUpCls:OnRetrunButtonClicked()
	--RetrunButton控件的点击事件处理
	self.callback:Invoke()
	utility.GetGame():GetSystemGuideManager():SetNeetSystemGuideID(kSystem_Guide[1].systemGuideID,self)
	
	self:Close()
end
function TreeLevelUpCls:OnExpItem01IconRepeatClicked()
	--ExpItem01Icon控件的点击事件处理
	debug_print("OnExpItem01IconClicked")
	self:GetGame():SendNetworkMessage(require "Network.ServerService".RobTreeLevelUpRequest())

end

function TreeLevelUpCls:OnExpItem01IconClicked()
	--ExpItem01Icon控件的点击事件处理
	debug_print("OnExpItem01IconClicked")
	self:GetGame():SendNetworkMessage(require "Network.ServerService".RobTreeLevelUpRequest())

end

return TreeLevelUpCls
