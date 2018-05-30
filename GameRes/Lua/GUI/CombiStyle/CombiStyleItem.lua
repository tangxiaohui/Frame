local BaseNodeClass = require "Framework.Base.Node"
local utility = require "Utils.Utility"
local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local CombiStyleItemCls = Class(BaseNodeClass)

function CombiStyleItemCls:Ctor(GenreState,parent)
	self.genreState=GenreState
	self.parent=parent	
	debug_print(self.genreState.genreId,#self.genreState.genreAwardRankState)
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function CombiStyleItemCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/CombiStyleItem', function(go)
		self:BindComponent(go)
	end)
end

function CombiStyleItemCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function CombiStyleItemCls:OnResume()
	-- 界面显示时调用
	CombiStyleItemCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
end

function CombiStyleItemCls:OnPause()
	-- 界面隐藏时调用
	CombiStyleItemCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function CombiStyleItemCls:OnEnter()
	-- Node Enter时调用
	CombiStyleItemCls.base.OnEnter(self)
end

function CombiStyleItemCls:OnExit()
	-- Node Exit时调用
	CombiStyleItemCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function CombiStyleItemCls:InitControls()
	local transform = self:GetUnityTransform()
	transform:SetParent(self.parent)
	self.layout = transform:Find('LefetBase/ComibiLayout')
	self.itemLayout = transform:Find('RightBase/Layout')
	self.NameLabel = transform:Find('LefetBase/NameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.InfoButton = transform:Find('LefetBase/InfoButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.Base = transform:Find('RightBase/Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.MygeneralItem = transform:Find('RightBase/MygeneralItem'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ActiveButton = transform:Find('RightBase/ActiveButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ActiveButtonImage = transform:Find('RightBase/ActiveButton'):GetComponent(typeof(UnityEngine.UI.Image))
	self.finishTrans=transform:Find('RightBase/Image')
	self.PowerValue=transform:Find('RightBase/AddPower/PowerValue'):GetComponent(typeof(UnityEngine.UI.Text))
	self.PowerName=transform:Find('RightBase/AddPower/PowerName'):GetComponent(typeof(UnityEngine.UI.Text))
	self.finishTrans.gameObject:SetActive(false)
	self.ActiveButtonText=transform:Find('RightBase/ActiveButton/Text'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ActiveButton.enabled=false
	self.ActiveButtonImage.material=utility.GetGrayMaterial()
	

	self:InitView()
end
function CombiStyleItemCls:InitView()

	local UserDataType = require "Framework.UserDataType"
	local cardBagData = self:GetCachedData(UserDataType.CardBagData)

	local CombiItemCls = require "GUI.CombiStyle.CombiItem"
	local CombiStyleData = require "StaticData.CombiStyle.CombiStyle":GetData(self.genreState.genreId)
	self.heroItems={}
	local heroItemsId = CombiStyleData:GetCardId()
	self.stage=0
	for i=1,#heroItemsId do
		local roleData= cardBagData:GetRoleById(heroItemsId[i])
		local node = CombiItemCls.New(heroItemsId[i],self.layout)
		self.heroItems[#self.heroItems+1] = node
		self:AddChild(node)
	end
	self.PowerName.text=EquipStringTable[CombiStyleData:GetAddPowerId()]
	self.PowerValue.text="+"..CombiStyleData:GetAddPowerValue().."%"
	self.PowerName.color= UnityEngine.Color(140/255, 140/255, 140/255, 1)
	self.PowerValue.color= UnityEngine.Color(140/255, 140/255, 140/255, 1)
	--根据当前的进阶总和 看看达到那个级别
	self.ActiveButtonText.text="激活"
	self:Refresh(self.genreState.genreAwardRankState)

	local combiInfoData = require "StaticData.CombiStyle.CombiInfo"
	
	self.NameLabel.text=combiInfoData:GetData(self.genreState.genreId):GetTitle()
	
end

function CombiStyleItemCls:Refresh(genreAwardRankState)
	local CombiItemCls = require "GUI.CombiStyle.CombiItem"
	local CombiStyleData = require "StaticData.CombiStyle.CombiStyle":GetData(self.genreState.genreId)



	for i=1,#genreAwardRankState do
		if(genreAwardRankState[i].awardRankState==0) then
			debug_print(i,"已领取");

		elseif(genreAwardRankState[i].awardRankState==1) then
			
			local itemID,itemNum = CombiStyleData:GetAwardDataByIndex(i)
			debug_print(i,"可领取",itemID,itemNum );
			local awardItemCls = require "GUI.Item.GeneralItem"
			self.awardRankId=i
			if self.awardItem~=nil then
				self:RemoveChild(self.awardItem)
			end
			self.awardItem=awardItemCls.New(self.itemLayout,itemID,itemNum,itemColor)
			self:AddChild(self.awardItem)
			self.ActiveButton.enabled=true
			self.ActiveButtonImage.material=nil
			return

		elseif(genreAwardRankState[i].awardRankState==2) then
			debug_print(i,"未达成");
			local itemID,itemNum = CombiStyleData:GetAwardDataByIndex(i)
			if self.awardItem~=nil then
				self:RemoveChild(self.awardItem)
			end
			local awardItemCls = require "GUI.Item.GeneralItem"
			self.awardItem=awardItemCls.New(self.itemLayout,itemID,itemNum,itemColor)
			self:AddChild(self.awardItem)
			self.ActiveButton.enabled=false
			self.ActiveButtonImage.material=utility.GetGrayMaterial()			
			return

		end

	end
	if self.awardItem~=nil then
		self:RemoveChild(self.awardItem)
	end
	self.ActiveButtonText.text="已激活"
	self.finishTrans.gameObject:SetActive(true)
	self.PowerName.color= UnityEngine.Color(1, 1, 1, 1)
	self.PowerValue.color= UnityEngine.Color(69/255, 147/255, 52/255, 1)
end


function CombiStyleItemCls:RegisterControlEvents()
	-- 注册 InfoButton 的事件
	self.__event_button_onInfoButtonClicked__ = UnityEngine.Events.UnityAction(self.OnInfoButtonClicked, self)
	self.InfoButton.onClick:AddListener(self.__event_button_onInfoButtonClicked__)

	-- 注册 ActiveButton 的事件
	self.__event_button_onActiveButtonClicked__ = UnityEngine.Events.UnityAction(self.OnActiveButtonClicked, self)
	self.ActiveButton.onClick:AddListener(self.__event_button_onActiveButtonClicked__)

end

function CombiStyleItemCls:UnregisterControlEvents()
	-- 取消注册 InfoButton 的事件
	if self.__event_button_onInfoButtonClicked__ then
		self.InfoButton.onClick:RemoveListener(self.__event_button_onInfoButtonClicked__)
		self.__event_button_onInfoButtonClicked__ = nil
	end

	-- 取消注册 ActiveButton 的事件
	if self.__event_button_onActiveButtonClicked__ then
		self.ActiveButton.onClick:RemoveListener(self.__event_button_onActiveButtonClicked__)
		self.__event_button_onActiveButtonClicked__ = nil
	end

end

function CombiStyleItemCls:RegisterNetworkEvents()
	self:GetGame():RegisterMsgHandler(net.S2CGenreChangeStateResult, self, self.GenreChangeStateResult)
end

function CombiStyleItemCls:UnregisterNetworkEvents()
	self:GetGame():UnRegisterMsgHandler(net.S2CGenreChangeStateResult, self, self.GenreChangeStateResult)
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function CombiStyleItemCls:GenreChangeStateResult(msg)
	--if self.msg.state
	debug_print(msg.genreId)
	local items = {}
	for i=1,#msg.genreAward do
		items[i]={}
  		items[i].id=msg.genreAward[i].genreAwardId
  		items[i].count=msg.genreAward[i].genreAwardNum
  		items[i].color=nil
	end
	

  
   
	local windowManager = self:GetGame():GetWindowManager()
  	local AwardCls = require "GUI.Task.GetAwardItem"
  	windowManager:Show(AwardCls,items)


	if msg.genreId==self.genreState.genreId then

		self:Refresh(msg.genreAwardRankState)
	end

end
function CombiStyleItemCls:OnInfoButtonClicked()

	local combiInfoData = require "StaticData.CombiStyle.CombiInfo"
	
	local str=combiInfoData:GetData(self.genreState.genreId):GetDescription()
	-- local windowManager = utility:GetGame():GetWindowManager()
	-- local ConfirmDialogClass = require "GUI.Dialogs.NormalDialog"	
	-- windowManager:Show(ConfirmDialogClass,str)

	local windowManager = utility:GetGame():GetWindowManager()
    windowManager:Show(require "GUI.CommonDescriptionModule",str)
	
end
function CombiStyleItemCls:OnActiveButtonClicked()
	--ActiveButton控件的点击事件处理
	self:GetGame():SendNetworkMessage( require"Network/ServerService".GenreChangeStateRequest(self.genreState.genreId,self.awardRankId-1))

end

return CombiStyleItemCls
