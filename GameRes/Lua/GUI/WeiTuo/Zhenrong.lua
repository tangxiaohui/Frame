local BaseNodeClass = require "Framework.Base.UIScene"
local utility = require "Utils.Utility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local ZhenrongCls = Class(BaseNodeClass)

function ZhenrongCls:Ctor()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function ZhenrongCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/Zhenrong', function(go)
		self:BindComponent(go)
	end)
end

function ZhenrongCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function ZhenrongCls:OnResume()
	-- 界面显示时调用
	ZhenrongCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
end

function ZhenrongCls:OnPause()
	-- 界面隐藏时调用
	ZhenrongCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function ZhenrongCls:OnEnter()
	-- Node Enter时调用
	ZhenrongCls.base.OnEnter(self)
end

function ZhenrongCls:OnExit()
	-- Node Exit时调用
	ZhenrongCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function ZhenrongCls:InitControls()
	local transform = self:GetUnityTransform()
	self.BigBaseBase = transform:Find('BigBase/BigBaseBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Image = transform:Find('BigBase/Image'):GetComponent(typeof(UnityEngine.UI.Image))
	self.FrameAbove = transform:Find('BigBase/FrameAbove'):GetComponent(typeof(UnityEngine.UI.Image))
	self.RightBase = transform:Find('RightBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.LeftBase = transform:Find('LeftBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WhiteBase = transform:Find('HeroList/WhiteBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BlackSmallBase = transform:Find('HeroList/BlackSmallBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.TitleTextLabel = transform:Find('HeroList/TitleTextLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Frame = transform:Find('HeroList/Frame'):GetComponent(typeof(UnityEngine.UI.Image))
	self.HeroLayout = transform:Find('HeroList/HeroLayout'):GetComponent(typeof(UnityEngine.UI.ScrollRect))
	self.HeroLayoutContent = transform:Find('HeroList/HeroLayout'):GetComponent(typeof(UnityEngine.UI.ScrollRect))
	
	self.HeroLayoutViewport = transform:Find('HeroList/HeroLayout/HeroLayoutViewport/HeroLayoutContent')
	
	self.FormationIntelligenceButton = transform:Find('BookmarkButtonList/2/FormationIntelligenceButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.FormationAgileButton = transform:Find('BookmarkButtonList/3/FormationAgileButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.FormationPowerButton = transform:Find('BookmarkButtonList/4/FormationPowerButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.FormationAllHeroButton = transform:Find('BookmarkButtonList/5/FormationAllHeroButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.Title = transform:Find('ChoosePanel/Title'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Box1 = transform:Find('ChoosePanel/HeroListBase/Box1'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Box2 = transform:Find('ChoosePanel/HeroListBase/Box2'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Box3 = transform:Find('ChoosePanel/HeroListBase/Box3'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Box4 = transform:Find('ChoosePanel/HeroListBase/Box4'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Box5 = transform:Find('ChoosePanel/HeroListBase/Box5'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Box6 = transform:Find('ChoosePanel/HeroListBase/Box6'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Condition1Text = transform:Find('ChoosePanel/Condition/Condition1Text'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Condition2Text = transform:Find('ChoosePanel/Condition/Condition2Text'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Toggle1 = transform:Find('ChoosePanel/Time/Toggle1'):GetComponent(typeof(UnityEngine.UI.Toggle))
	self.Toggle2 = transform:Find('ChoosePanel/Time/Toggle2'):GetComponent(typeof(UnityEngine.UI.Toggle))
	self.Toggle3 = transform:Find('ChoosePanel/Time/Toggle3'):GetComponent(typeof(UnityEngine.UI.Toggle))
	self.Toggle4 = transform:Find('ChoosePanel/Time/Toggle4'):GetComponent(typeof(UnityEngine.UI.Toggle))
	self.Base = transform:Find('ChoosePanel/MyGeneralItem/Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BaseBg = transform:Find('ChoosePanel/MyGeneralItem/BaseBg'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ItemIcon = transform:Find('ChoosePanel/MyGeneralItem/ItemIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.DebrisIcon = transform:Find('ChoosePanel/MyGeneralItem/DebrisIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Image1 = transform:Find('ChoosePanel/MyGeneralItem/Frame/Image'):GetComponent(typeof(UnityEngine.UI.Image))
	self.DebrisCorner = transform:Find('ChoosePanel/MyGeneralItem/DebrisCorner'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ItemNameLabel = transform:Find('ChoosePanel/MyGeneralItem/ItemNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ItemSellInfoIcon = transform:Find('ChoosePanel/MyGeneralItem/ItemSellInfo/ItemSellInfoIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ItemSellInfoText = transform:Find('ChoosePanel/MyGeneralItem/ItemSellInfo/ItemSellInfoText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.OnSelectBase = transform:Find('ChoosePanel/MyGeneralItem/OnSelectState/OnSelectBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.OnSelectState = transform:Find('ChoosePanel/MyGeneralItem/OnSelectState/OnSelectState'):GetComponent(typeof(UnityEngine.UI.Image))
	self.GeneralItemNumLabel = transform:Find('ChoosePanel/MyGeneralItem/GeneralItemNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ItemLevelLabel = transform:Find('ChoosePanel/MyGeneralItem/ItemLevelLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Flag = transform:Find('ChoosePanel/MyGeneralItem/Flag'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Text = transform:Find('ChoosePanel/MyGeneralItem/Flag/Text'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Image2 = transform:Find('ChoosePanel/MyGeneralItem/OnMultiSelect/Image'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Coner1 = transform:Find('ChoosePanel/MyGeneralItem/OnMultiSelect/Coner1'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Coner2 = transform:Find('ChoosePanel/MyGeneralItem/OnMultiSelect/Coner2'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Coner3 = transform:Find('ChoosePanel/MyGeneralItem/OnMultiSelect/Coner3'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Coner4 = transform:Find('ChoosePanel/MyGeneralItem/OnMultiSelect/Coner4'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ItemAttributeLabel = transform:Find('ChoosePanel/MyGeneralItem/ItemAttributeLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.BindImage = transform:Find('ChoosePanel/MyGeneralItem/BindImage'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ItemInfoButton = transform:Find('ChoosePanel/MyGeneralItem/ItemInfoButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.Bottom = transform:Find('ChoosePanel/MyGeneralItem/Gems/ButtonBox/Gem1/Bottom'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Image3 = transform:Find('ChoosePanel/MyGeneralItem/Gems/ButtonBox/Gem1/Image'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Bottom1 = transform:Find('ChoosePanel/MyGeneralItem/Gems/ButtonBox/Gem2/Bottom'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Image4 = transform:Find('ChoosePanel/MyGeneralItem/Gems/ButtonBox/Gem2/Image'):GetComponent(typeof(UnityEngine.UI.Image))
	self.RaceIconImage = transform:Find('ChoosePanel/MyGeneralItem/RaceIconImage'):GetComponent(typeof(UnityEngine.UI.Image))
	self.RedDot = transform:Find('ChoosePanel/MyGeneralItem/RedDot'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Flag1 = transform:Find('ChoosePanel/MyGeneralItem/Flag1'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Text1 = transform:Find('ChoosePanel/MyGeneralItem/Flag1/Text'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Button = transform:Find('ChoosePanel/ChooseAcquire/General/Button'):GetComponent(typeof(UnityEngine.UI.Button))
	self.Button1 = transform:Find('ChoosePanel/ChooseAcquire/TwoAcquired/Button'):GetComponent(typeof(UnityEngine.UI.Button))
	self.LockButton = transform:Find('ChoosePanel/ChooseAcquire/TwoAcquired/LockButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.Text2 = transform:Find('ChoosePanel/ChooseAcquire/TwoAcquired/Text'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Button2 = transform:Find('ChoosePanel/ChooseAcquire/ThreeAcquired/Button'):GetComponent(typeof(UnityEngine.UI.Button))
	self.LockButton1 = transform:Find('ChoosePanel/ChooseAcquire/ThreeAcquired/LockButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.Text3 = transform:Find('ChoosePanel/ChooseAcquire/ThreeAcquired/Text'):GetComponent(typeof(UnityEngine.UI.Text))
	self.BlackStripes = transform:Find('Back/BlackStripes'):GetComponent(typeof(UnityEngine.UI.Image))
	self.TitleTitleImage = transform:Find('Back/TitleTitleImage'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ArenaReturnButton = transform:Find('Back/ArenaReturnButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.FrameBelow = transform:Find('FrameBelow'):GetComponent(typeof(UnityEngine.UI.Image))
	self.FormationFightButton = transform:Find('FormationFightButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self:LoadCardData()

end
function ZhenrongCls:OnBagCardClicked(uid,index,state)

end
function ZhenrongCls:LoadCardData()
	self.HeroCardList={}
	self.BagCardDict = OrderedDictionary.New()
	-- 力
	self.LiCardDict = OrderedDictionary.New()
	-- 敏
	self.MinCardDict = OrderedDictionary.New()
	-- 智力
	self.ZhiCardDict = OrderedDictionary.New()
	-- 雇佣军
	self.GYJCardDict = OrderedDictionary.New()


	-- 加载玩家卡牌数据
	local HeroCardItemNodeClass = require "GUI.Arena.FormationItem"
    local UserDataType = require "Framework.UserDataType"
    local cardBagData = self:GetCachedData(UserDataType.CardBagData)
    local count = cardBagData:RoleCount()

    for i =1 ,count do
    	local node = HeroCardItemNodeClass.New(self.HeroLayoutViewport,i)
    	node:SetCallback(self,self.OnBagCardClicked)
    	node:ResetView(cardBagData:GetRoleByPos(i))
    	self.HeroCardList[#self.HeroCardList + 1] = node
    end

    -- 排序 
   	table.sort(self.HeroCardList, function(node1, node2)
       	-- 等级优先  等级相同排颜色
       	if node1:GetLv() == node2:GetLv() then
       		return node1:GetColor() > node2:GetColor()
       	else
       		return node1:GetLv() > node2:GetLv()
       	end
    end)

   	-- 添加
   	for i = 1 ,#self.HeroCardList do
   		local node = self.HeroCardList[i]
   		
   		node:SetIndex(i)

   		local uid = node:GetUid()
   		self.BagCardDict:Add(uid,node)

   		local majorAttr = node:GetMajorAttr()
   		if majorAttr == 0 then
   			self.LiCardDict:Add(uid,node)
   		elseif majorAttr == 1 then
   			self.MinCardDict:Add(uid,node)
   		elseif majorAttr == 2 then
   			self.ZhiCardDict:Add(uid,node)
   		end
   	end

   	-- 已经上阵阵容
   	-- local default = cardBagData:GetTroopByLineup(self.fType)

   	-- for j = 1,#default do
   	-- 	local posUid = default[j]
   	-- 	if posUid ~= 0 then
   	-- 		self.FormationStateDict:Add(j,posUid)
   	-- 	end
   	-- end

end

function ZhenrongCls:RegisterControlEvents()
	-- 注册 HeroLayout 的事件
	self.__event_scrollrect_onHeroLayoutValueChanged__ = UnityEngine.Events.UnityAction_UnityEngine_Vector2(self.OnHeroLayoutValueChanged, self)
	self.HeroLayout.onValueChanged:AddListener(self.__event_scrollrect_onHeroLayoutValueChanged__)

	-- 注册 FormationIntelligenceButton 的事件
	self.__event_button_onFormationIntelligenceButtonClicked__ = UnityEngine.Events.UnityAction(self.OnFormationIntelligenceButtonClicked, self)
	self.FormationIntelligenceButton.onClick:AddListener(self.__event_button_onFormationIntelligenceButtonClicked__)

	-- 注册 FormationAgileButton 的事件
	self.__event_button_onFormationAgileButtonClicked__ = UnityEngine.Events.UnityAction(self.OnFormationAgileButtonClicked, self)
	self.FormationAgileButton.onClick:AddListener(self.__event_button_onFormationAgileButtonClicked__)

	-- 注册 FormationPowerButton 的事件
	self.__event_button_onFormationPowerButtonClicked__ = UnityEngine.Events.UnityAction(self.OnFormationPowerButtonClicked, self)
	self.FormationPowerButton.onClick:AddListener(self.__event_button_onFormationPowerButtonClicked__)

	-- 注册 FormationAllHeroButton 的事件
	self.__event_button_onFormationAllHeroButtonClicked__ = UnityEngine.Events.UnityAction(self.OnFormationAllHeroButtonClicked, self)
	self.FormationAllHeroButton.onClick:AddListener(self.__event_button_onFormationAllHeroButtonClicked__)

	-- 注册 Toggle1 的事件
	self.__event_toggle_onToggle1ValueChanged__ = UnityEngine.Events.UnityAction_bool(self.OnToggle1ValueChanged, self)
	self.Toggle1.onValueChanged:AddListener(self.__event_toggle_onToggle1ValueChanged__)

	-- 注册 Toggle2 的事件
	self.__event_toggle_onToggle2ValueChanged__ = UnityEngine.Events.UnityAction_bool(self.OnToggle2ValueChanged, self)
	self.Toggle2.onValueChanged:AddListener(self.__event_toggle_onToggle2ValueChanged__)

	-- 注册 Toggle3 的事件
	self.__event_toggle_onToggle3ValueChanged__ = UnityEngine.Events.UnityAction_bool(self.OnToggle3ValueChanged, self)
	self.Toggle3.onValueChanged:AddListener(self.__event_toggle_onToggle3ValueChanged__)

	-- 注册 Toggle4 的事件
	self.__event_toggle_onToggle4ValueChanged__ = UnityEngine.Events.UnityAction_bool(self.OnToggle4ValueChanged, self)
	self.Toggle4.onValueChanged:AddListener(self.__event_toggle_onToggle4ValueChanged__)

	-- 注册 ItemInfoButton 的事件
	self.__event_button_onItemInfoButtonClicked__ = UnityEngine.Events.UnityAction(self.OnItemInfoButtonClicked, self)
	self.ItemInfoButton.onClick:AddListener(self.__event_button_onItemInfoButtonClicked__)

	-- 注册 Button 的事件
	self.__event_button_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnButtonClicked, self)
	self.Button.onClick:AddListener(self.__event_button_onButtonClicked__)

	-- 注册 Button1 的事件
	self.__event_button_onButton1Clicked__ = UnityEngine.Events.UnityAction(self.OnButton1Clicked, self)
	self.Button1.onClick:AddListener(self.__event_button_onButton1Clicked__)

	-- 注册 LockButton 的事件
	self.__event_button_onLockButtonClicked__ = UnityEngine.Events.UnityAction(self.OnLockButtonClicked, self)
	self.LockButton.onClick:AddListener(self.__event_button_onLockButtonClicked__)

	-- 注册 Button2 的事件
	self.__event_button_onButton2Clicked__ = UnityEngine.Events.UnityAction(self.OnButton2Clicked, self)
	self.Button2.onClick:AddListener(self.__event_button_onButton2Clicked__)

	-- 注册 LockButton1 的事件
	self.__event_button_onLockButton1Clicked__ = UnityEngine.Events.UnityAction(self.OnLockButton1Clicked, self)
	self.LockButton1.onClick:AddListener(self.__event_button_onLockButton1Clicked__)

	-- 注册 ArenaReturnButton 的事件
	self.__event_button_onArenaReturnButtonClicked__ = UnityEngine.Events.UnityAction(self.OnArenaReturnButtonClicked, self)
	self.ArenaReturnButton.onClick:AddListener(self.__event_button_onArenaReturnButtonClicked__)

	-- 注册 FormationFightButton 的事件
	self.__event_button_onFormationFightButtonClicked__ = UnityEngine.Events.UnityAction(self.OnFormationFightButtonClicked, self)
	self.FormationFightButton.onClick:AddListener(self.__event_button_onFormationFightButtonClicked__)
end

function ZhenrongCls:UnregisterControlEvents()
	-- 取消注册 HeroLayout 的事件
	if self.__event_scrollrect_onHeroLayoutValueChanged__ then
		self.HeroLayout.onValueChanged:RemoveListener(self.__event_scrollrect_onHeroLayoutValueChanged__)
		self.__event_scrollrect_onHeroLayoutValueChanged__ = nil
	end

	-- 取消注册 FormationIntelligenceButton 的事件
	if self.__event_button_onFormationIntelligenceButtonClicked__ then
		self.FormationIntelligenceButton.onClick:RemoveListener(self.__event_button_onFormationIntelligenceButtonClicked__)
		self.__event_button_onFormationIntelligenceButtonClicked__ = nil
	end

	-- 取消注册 FormationAgileButton 的事件
	if self.__event_button_onFormationAgileButtonClicked__ then
		self.FormationAgileButton.onClick:RemoveListener(self.__event_button_onFormationAgileButtonClicked__)
		self.__event_button_onFormationAgileButtonClicked__ = nil
	end

	-- 取消注册 FormationPowerButton 的事件
	if self.__event_button_onFormationPowerButtonClicked__ then
		self.FormationPowerButton.onClick:RemoveListener(self.__event_button_onFormationPowerButtonClicked__)
		self.__event_button_onFormationPowerButtonClicked__ = nil
	end

	-- 取消注册 FormationAllHeroButton 的事件
	if self.__event_button_onFormationAllHeroButtonClicked__ then
		self.FormationAllHeroButton.onClick:RemoveListener(self.__event_button_onFormationAllHeroButtonClicked__)
		self.__event_button_onFormationAllHeroButtonClicked__ = nil
	end

	-- 取消注册 Toggle1 的事件
	if self.__event_toggle_onToggle1ValueChanged__ then
		self.Toggle1.onValueChanged:RemoveListener(self.__event_toggle_onToggle1ValueChanged__)
		self.__event_toggle_onToggle1ValueChanged__ = nil
	end

	-- 取消注册 Toggle2 的事件
	if self.__event_toggle_onToggle2ValueChanged__ then
		self.Toggle2.onValueChanged:RemoveListener(self.__event_toggle_onToggle2ValueChanged__)
		self.__event_toggle_onToggle2ValueChanged__ = nil
	end

	-- 取消注册 Toggle3 的事件
	if self.__event_toggle_onToggle3ValueChanged__ then
		self.Toggle3.onValueChanged:RemoveListener(self.__event_toggle_onToggle3ValueChanged__)
		self.__event_toggle_onToggle3ValueChanged__ = nil
	end

	-- 取消注册 Toggle4 的事件
	if self.__event_toggle_onToggle4ValueChanged__ then
		self.Toggle4.onValueChanged:RemoveListener(self.__event_toggle_onToggle4ValueChanged__)
		self.__event_toggle_onToggle4ValueChanged__ = nil
	end

	-- 取消注册 ItemInfoButton 的事件
	if self.__event_button_onItemInfoButtonClicked__ then
		self.ItemInfoButton.onClick:RemoveListener(self.__event_button_onItemInfoButtonClicked__)
		self.__event_button_onItemInfoButtonClicked__ = nil
	end

	-- 取消注册 Button 的事件
	if self.__event_button_onButtonClicked__ then
		self.Button.onClick:RemoveListener(self.__event_button_onButtonClicked__)
		self.__event_button_onButtonClicked__ = nil
	end

	-- 取消注册 Button1 的事件
	if self.__event_button_onButton1Clicked__ then
		self.Button1.onClick:RemoveListener(self.__event_button_onButton1Clicked__)
		self.__event_button_onButton1Clicked__ = nil
	end

	-- 取消注册 LockButton 的事件
	if self.__event_button_onLockButtonClicked__ then
		self.LockButton.onClick:RemoveListener(self.__event_button_onLockButtonClicked__)
		self.__event_button_onLockButtonClicked__ = nil
	end

	-- 取消注册 Button2 的事件
	if self.__event_button_onButton2Clicked__ then
		self.Button2.onClick:RemoveListener(self.__event_button_onButton2Clicked__)
		self.__event_button_onButton2Clicked__ = nil
	end

	-- 取消注册 LockButton1 的事件
	if self.__event_button_onLockButton1Clicked__ then
		self.LockButton1.onClick:RemoveListener(self.__event_button_onLockButton1Clicked__)
		self.__event_button_onLockButton1Clicked__ = nil
	end

	-- 取消注册 ArenaReturnButton 的事件
	if self.__event_button_onArenaReturnButtonClicked__ then
		self.ArenaReturnButton.onClick:RemoveListener(self.__event_button_onArenaReturnButtonClicked__)
		self.__event_button_onArenaReturnButtonClicked__ = nil
	end

	-- 取消注册 FormationFightButton 的事件
	if self.__event_button_onFormationFightButtonClicked__ then
		self.FormationFightButton.onClick:RemoveListener(self.__event_button_onFormationFightButtonClicked__)
		self.__event_button_onFormationFightButtonClicked__ = nil
	end
end

function ZhenrongCls:RegisterNetworkEvents()
end

function ZhenrongCls:UnregisterNetworkEvents()
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function ZhenrongCls:OnHeroLayoutValueChanged(posXY)
	--HeroLayout控件的点击事件处理
end

function ZhenrongCls:OnFormationIntelligenceButtonClicked()
	--FormationIntelligenceButton控件的点击事件处理
end

function ZhenrongCls:OnFormationAgileButtonClicked()
	--FormationAgileButton控件的点击事件处理
end

function ZhenrongCls:OnFormationPowerButtonClicked()
	--FormationPowerButton控件的点击事件处理
end

function ZhenrongCls:OnFormationAllHeroButtonClicked()
	--FormationAllHeroButton控件的点击事件处理
end

function ZhenrongCls:OnToggle1ValueChanged(isToggle)
	--Toggle1控件的点击事件处理
end

function ZhenrongCls:OnToggle2ValueChanged(isToggle)
	--Toggle2控件的点击事件处理
end

function ZhenrongCls:OnToggle3ValueChanged(isToggle)
	--Toggle3控件的点击事件处理
end

function ZhenrongCls:OnToggle4ValueChanged(isToggle)
	--Toggle4控件的点击事件处理
end

function ZhenrongCls:OnItemInfoButtonClicked()
	--ItemInfoButton控件的点击事件处理
end

function ZhenrongCls:OnButtonClicked()
	--Button控件的点击事件处理
end

function ZhenrongCls:OnButton1Clicked()
	--Button1控件的点击事件处理
end

function ZhenrongCls:OnLockButtonClicked()
	--LockButton控件的点击事件处理
end

function ZhenrongCls:OnButton2Clicked()
	--Button2控件的点击事件处理
end

function ZhenrongCls:OnLockButton1Clicked()
	--LockButton1控件的点击事件处理
end

function ZhenrongCls:OnArenaReturnButtonClicked()
	--ArenaReturnButton控件的点击事件处理
	local sceneManager =  utility:GetGame():GetSceneManager()
    sceneManager:PopScene()
end

function ZhenrongCls:OnFormationFightButtonClicked()
	--FormationFightButton控件的点击事件处理
end

return ZhenrongCls
