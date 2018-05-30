local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"
require "Const"
require "LUT.StringTable"
local messageGuids = require "Framework.Business.MessageGuids"
local calculateRed = require"Utils.CalculateRed"


-- 基础属性
local BaseInfoPanelState	= KEquipWinShowType_BaseInfo
-- 合成
local CombinePanelState		= KEquipWinShowType_Combine
-- 升级
local PowerupPanelState		= KEquipWinShowType_Powerup
-- 进阶
local UpgradePanelState		= KEquipWinShowType_Upgrade

-- button 选中颜色
local ButtonSelectedImageColor = UnityEngine.Color(1,1,1,1)
local ButtonNormalImageColor = UnityEngine.Color(0.537254,0.537254,0.537254,1)

-----------------------------------------------------------------------
local EquipmentWindowCls = Class(BaseNodeClass)
windowUtility.SetMutex(EquipmentWindowCls, true)

function EquipmentWindowCls:Ctor()
end
--解绑是否可以点击
function EquipmentWindowCls:OnWillShow(uid,id,stype,RoleUid,isDebris,canDid)
	self.uid = uid
	self.id = id
	self.stype = stype
	self.RoleUid = RoleUid
	self.isDebris = isDebris
	debug_print(canDid,"canDid",isDebris)
	self.canDid=canDid
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function EquipmentWindowCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/EquipmentWindow', function(go)
		self:BindComponent(go)
	end)
end

function EquipmentWindowCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
	self:LoadWindowNode()
	self:InitWinTheme()
end

function EquipmentWindowCls:OnResume()
	-- 界面显示时调用
	EquipmentWindowCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:RegisterEventMonitor()

	self:StateChangeCtrl(self.stype)


	self:FadeIn(function(self, t,finished)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)

        if finished then
        	if self.currActiveNode ~= nil then
				self.currActiveNode:ResetScrollRect(true)
			end
		end
    end)
		local guideMgr = utility.GetGame():GetGuideManager()

			guideMgr:AddGuideEvnt(kGuideEvnt_ClickweaponPowerupTag)
			guideMgr:AddGuideEvnt(kGuideEvnt_ClickweaponPowerupButton)
			
			guideMgr:SortGuideEvnt()
			guideMgr:ShowGuidance()

		

	self:SetEquipmentUpgrade()
 	self:RegisterEvent(messageGuids.LocalRedDotChanged, self.LocalRedDotChanged)
 	self:LocalRedDotChanged()

end

function EquipmentWindowCls:OnPause()
	-- 界面隐藏时调用
	EquipmentWindowCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
	self:UnregisterEventMonitor()
	self:UnregisterEvent(messageGuids.LocalRedDotChanged, self.LocalRedDotChanged)

end

function EquipmentWindowCls:OnEnter()
	-- Node Enter时调用
	EquipmentWindowCls.base.OnEnter(self)
end

function EquipmentWindowCls:OnExit()
	-- Node Exit时调用
	EquipmentWindowCls.base.OnExit(self)
end


function EquipmentWindowCls:IsTransition()
    return true
end

function EquipmentWindowCls:OnExitTransitionDidStart(immediately)
	EquipmentWindowCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function EquipmentWindowCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function EquipmentWindowCls:InitControls()
	local transform = self:GetUnityTransform()

	self.tweenObjectTrans = transform:Find('Base')
	
	-- 返回按钮
	self.ReturnButton = transform:Find('Base/CrossButton'):GetComponent(typeof(UnityEngine.UI.Button))
	
	-- 信息按钮
	self.BaseInfoButton = transform:Find('Base/Layout/InformationButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.BaseInfoRedDot = transform:Find('Base/Layout/InformationButton/RedDot'):GetComponent(typeof(UnityEngine.UI.Image))

	-- 强化按钮
	self.PowerUpButton = transform:Find('Base/Layout/PowerupButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.PowerUpRedDot = transform:Find('Base/Layout/PowerupButton/RedDot'):GetComponent(typeof(UnityEngine.UI.Image))

	-- 进阶按钮
	self.UpgradeButton = transform:Find('Base/Layout/UpgradeButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.UpgradeRedDot = transform:Find('Base/Layout/UpgradeButton/RedDot'):GetComponent(typeof(UnityEngine.UI.Image))

	-- 信息挂点
	self.baseInfoPoint = transform:Find('Base/EquipmentBasicInfoPoint')
	-- 合成挂点
	self.CombinePoint = transform:Find('Base/CombinePoint')
	-- 强化挂点
	self.PowerupPoint = transform:Find('Base/PowerupPoint')
	-- 进阶挂点
	self.UpgradePoint = transform:Find('Base/UpgradePoint')

	--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))

	--- @ 功能按钮

	-- 卸下
	self.ctrlTakeoffWearingButton = transform:Find('Base/CtrlButtons/TakeoffWearingButton'):GetComponent(typeof(UnityEngine.UI.Button))

	-- 换装
	self.ctrlChangewearingButton  = transform:Find('Base/CtrlButtons/ChangewearingButton'):GetComponent(typeof(UnityEngine.UI.Button))

	-- 自动强化
	self.ctrlWeaponAutoPowerupButton = transform:Find('Base/CtrlButtons/WeaponAutoPowerupButton'):GetComponent(typeof(UnityEngine.UI.Button))

	-- 强化
	self.ctrlWeaponPowerupButton = transform:Find('Base/CtrlButtons/WeaponPowerupButton'):GetComponent(typeof(UnityEngine.UI.Button))
	--宠物一键 强化
	self.ctrlPetPowerupAutoButton = transform:Find('Base/CtrlButtons/PetPowerupAutoButton'):GetComponent(typeof(UnityEngine.UI.Button))

	-- 进阶
	self.ctrlUpgradeButton = transform:Find('Base/CtrlButtons/UpgradeButton'):GetComponent(typeof(UnityEngine.UI.Button))

	-- 合成
	self.ctrlCombineButton = transform:Find('Base/CtrlButtons/CombineButton'):GetComponent(typeof(UnityEngine.UI.Button))

	-- 重铸
	self.ctrlReformButton = transform:Find('Base/CtrlButtons/ReformButton'):GetComponent(typeof(UnityEngine.UI.Button))

	-- 背景1
	--self.BoXImage_1 = transform:Find("Base/Box").gameObject
	-- 背景2
	--self.BoXImage_2 = transform:Find("Base/Box2").gameObject
	self.BaseInfoRedDot.enabled=false
	self.PowerUpRedDot.enabled=false 
	self.UpgradeRedDot.enabled=false 


end


function EquipmentWindowCls:RegisterControlEvents()
	-- 注册 返回按钮 的事件
    self.__event_button_onReturnButtonClicked__ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked, self)
    self.ReturnButton.onClick:AddListener(self.__event_button_onReturnButtonClicked__)

	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

    -- 注册 信息按钮 的事件
    self.__event_button_onBaseInfoButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBaseInfoButtonClicked, self)
    self.BaseInfoButton.onClick:AddListener(self.__event_button_onBaseInfoButtonClicked__)

    -- 注册 强化按钮 的事件
    self.__event_button_onPowerUpButtonClicked__ = UnityEngine.Events.UnityAction(self.OnPowerUpButtonClicked, self)
    self.PowerUpButton.onClick:AddListener(self.__event_button_onPowerUpButtonClicked__)

    -- 注册 进阶按钮 的事件
    self.__event_button_onUpgradeButtonClicked__ = UnityEngine.Events.UnityAction(self.OnUpgradeButtonClicked, self)
    self.UpgradeButton.onClick:AddListener(self.__event_button_onUpgradeButtonClicked__)
end

function EquipmentWindowCls:UnregisterControlEvents()
	-- 取消注册 返回按钮 的事件
    if self.__event_button_onReturnButtonClicked__ then
        self.ReturnButton.onClick:RemoveListener(self.__event_button_onReturnButtonClicked__)
        self.__event_button_onReturnButtonClicked__ = nil
    end

    -- 取消注册 信息按钮 的事件
    if self.__event_button_onBaseInfoButtonClicked__ then
        self.BaseInfoButton.onClick:RemoveListener(self.__event_button_onBaseInfoButtonClicked__)
        self.__event_button_onBaseInfoButtonClicked__ = nil
    end

    -- 取消注册 强化按钮 的事件
    if self.__event_button_onPowerUpButtonClicked__ then
        self.PowerUpButton.onClick:RemoveListener(self.__event_button_onPowerUpButtonClicked__)
        self.__event_button_onPowerUpButtonClicked__ = nil
    end

    -- 取消注册 进阶按钮 的事件
    if self.__event_button_onUpgradeButtonClicked__ then
        self.UpgradeButton.onClick:RemoveListener(self.__event_button_onUpgradeButtonClicked__)
        self.__event_button_onUpgradeButtonClicked__ = nil
    end

    -- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end


end

function EquipmentWindowCls:RegisterNetworkEvents()
	utility:GetGame():RegisterMsgHandler(net.S2CEquipAdvancedResult, self, self.EquipAdvancedResult)
end

function EquipmentWindowCls:UnregisterNetworkEvents()
	utility:GetGame():UnRegisterMsgHandler(net.S2CEquipAdvancedResult, self, self.EquipAdvancedResult)
end

function EquipmentWindowCls:RegisterEventMonitor()
	print("添加注册  RegisterEventMonitor")
	self:RegisterEvent(messageGuids.CloseEquipWindow,self.OnReturnButtonClicked)
end

function EquipmentWindowCls:UnregisterEventMonitor()
	print("取消注册  UnregisterEventMonitor")
	self:UnregisterEvent(messageGuids.CloseEquipWindow,self.OnReturnButtonClicked)
end
-----------------------------------------------------------------------
--- 网络处理
-----------------------------------------------------------------------



-----------------------------------------------------------------------
local function SetComponentActive(obj,active)
	-- 设置对象显示状态
	obj.gameObject:SetActive(active)
end

function EquipmentWindowCls:LoadWindowNode()
	-- 加载node
	self.BaseInfoNode = require "GUI.EquipmentWindow.EquipmentWinBaseInfoNode".New(self.baseInfoPoint,self.ctrlTakeoffWearingButton,
									self.ctrlChangewearingButton,self.ctrlReformButton) 
	self.CombineNode = require "GUI.EquipmentWindow.EquipmentWinCombineNode".New(self.CombinePoint,self.ctrlCombineButton) 
	self.PowerupNode = require "GUI.EquipmentWindow.EquipmentWinPowerupNode".New(self.PowerupPoint,self.ctrlWeaponPowerupButton,self.ctrlWeaponAutoPowerupButton,self.ctrlPetPowerupAutoButton) 
	self.UpgradeNode = require "GUI.EquipmentWindow.EquipmentWinUpgradeNode".New(self.UpgradePoint,self.ctrlUpgradeButton) 
	self.EquipUpgradeNode = require "GUI.EquipmentWindow.EquipUpgradeNode".New(self.UpgradePoint) 
end

function EquipmentWindowCls:InitWinTheme()
	-- 初始化界面样式
	local staticData
	local itype
	if not self.isDebris then
		staticData = require "StaticData.Equip":GetData(self.id)
		itype = staticData:GetType()
	end
	
	-- 强化
	local canPowerup = false
	-- 进阶
	local canUpgrade = false

	---@ 功能按钮

	-- 卸下
	local canCtrlTakeoff  
	-- 换装
	local canCtrlChange
	-- 自动强化
	local canCtrlAutoPowerup
	-- 强化
	local canCtrlPowerup
	-- 进阶
	local canCtrlUpgrade

	if itype == KEquipType_EquipWeapon	or itype == KEquipType_EquipArmor or itype == KEquipType_EquipFashion  then
		canPowerup = true
	elseif itype == KEquipType_EquipPet then
		canPowerup = true
		canUpgrade = true
	elseif itype == KEquipType_EquipWing then
		if self.uid ~= nil then
			canPowerup = true
			canUpgrade = true
		end
	elseif self.isDebris then
		canPowerup = false
		canUpgrade = false
	end

	self.PowerUpButton.gameObject:SetActive(canPowerup)
	self.UpgradeButton.gameObject:SetActive(canUpgrade)
	print("强化",canPowerup,"进阶",canUpgrade)
	local baseActive = (canPowerup == false and canUpgrade == false)
	self.BaseInfoButton.gameObject:SetActive(not baseActive)

end
 
function EquipmentWindowCls:OnBaseInfoPanelEnter()
	-- 基础信息Enter
	self:AddChild(self.BaseInfoNode)
	self.BaseInfoNode:RefreshItemInfo(self.uid,self.RoleUid,self.canDid)
	self.currActiveNode = self.BaseInfoNode
	--self.BoXImage_1.gameObject:SetActive(true)
end

function EquipmentWindowCls:OnCombinePanelEnter()
	-- 合成Enter
	self:AddChild(self.CombineNode)
	self.CombineNode:RefreshItem(self.id,self.RoleUid,self,self.OnCombineSucceed)
	--self.BoXImage_1.gameObject:SetActive(true)
end

function EquipmentWindowCls:OnPowerupPanelPanelEnter()
	-- 升级Enter
	self:AddChild(self.PowerupNode)
	self.PowerupNode:RefreshItem(self.uid)
	--self.BoXImage_2.gameObject:SetActive(true)
end

function EquipmentWindowCls:OnUpgradePanelEnter()
	-- 进阶Enter
	if self.equipUpID ~= nil then
		self:AddChild(self.EquipUpgradeNode)
		
		self.EquipUpgradeNode:RefreshItem(self.uid,self.id,self.equipUpID,self.equipData)
	else
		self:AddChild(self.UpgradeNode)
		self.UpgradeNode:RefreshItem(self.uid,self.RoleUid)
	end
	--self.BoXImage_2.gameObject:SetActive(true)
end

function EquipmentWindowCls:OnBaseInfoPanelExit()
	-- 基础信息Exit
	self:RemoveChild(self.BaseInfoNode)
	self.ctrlTakeoffWearingButton.gameObject:SetActive(false)
	self.ctrlChangewearingButton.gameObject:SetActive(false)
	self.ctrlReformButton.gameObject:SetActive(false)
	--self.BoXImage_1.gameObject:SetActive(false)
end

function EquipmentWindowCls:OnCombinePanelExit()
	-- 合成Exit
	self:RemoveChild(self.CombineNode)
	self.ctrlCombineButton.gameObject:SetActive(false)
	--self.BoXImage_1.gameObject:SetActive(false)
end

function EquipmentWindowCls:OnPowerupPanelPanelExit()
	-- 升级Exit
	self:RemoveChild(self.PowerupNode)
	self.ctrlWeaponPowerupButton.gameObject:SetActive(false)
	self.ctrlWeaponAutoPowerupButton.gameObject:SetActive(false)
	self.ctrlPetPowerupAutoButton.gameObject:SetActive(false)
	--self.BoXImage_2.gameObject:SetActive(false)
end

function EquipmentWindowCls:OnUpgradePanelExit()
	-- 进阶Exit
	if self.equipUpID ~= nil then
		self:RemoveChild(self.EquipUpgradeNode)
		self.ctrlUpgradeButton.gameObject:SetActive(false)
	else
		self:RemoveChild(self.UpgradeNode)
		self.ctrlUpgradeButton.gameObject:SetActive(false)
	end
	--self.BoXImage_2.gameObject:SetActive(false)
end

function EquipmentWindowCls:OnCombineSucceed(id,uid,RoleUid)
	if self.RoleUid == nil then
		self:OnReturnButtonClicked()
	else
		self:SetId(id)
		self:SetUid(uid)
		self:SetRoleId(RoleUid)
		self.stype = KEquipWinShowType_BaseInfo
		self:InitWinTheme()
		self:StateChangeCtrl(BaseInfoPanelState)
	end
end

function EquipmentWindowCls:SetId(id)
	self.id = id
end

function EquipmentWindowCls:SetUid(uid)
	self.uid = uid
end

function EquipmentWindowCls:SetRoleId(RoleUid)
	self.RoleUid = RoleUid
end
-----------------------------------------------------------------------
--- 状态管理
-----------------------------------------------------------------------
function EquipmentWindowCls:StateChangeCtrl(state)
	-- 状态切换
	print(state,"状态切换")
	if self.currPanelState == state then		
		return 
	end

	if self.currPanelState ~= nil then
		self:OnPanelStateExit(self.currPanelState)
	end

	self:OnPanelStateEnter(state)
end

--设置装备进阶
function EquipmentWindowCls:SetEquipmentUpgrade()
	local UserDataType = require "Framework.UserDataType"
 	local tempData = self:GetCachedData(UserDataType.EquipBagData)
	self.equipData = tempData:GetItem(self.uid)
	if self.equipData ~= nil then
	if self.equipData:GetOnWhichCard() == "" or self.equipData:GetOnWhichCard() == nil then
	self.id = self.equipData:GetEquipID()
	local data = require "StaticData.Equip":GetData(self.id)
	local equipType = data:GetType()
	local equipUpData = require "StaticData.EquipUpBasic":GetData(equipType)
	self.equipUpID = equipUpData:GetID()
	if self.equipUpID ~= nil then
		local colors = equipUpData:GetColor()
		for i=0,colors.Count - 1 do
			if data:GetColorID() == colors[i] then
				self.UpgradeButton.gameObject:SetActive(true)
				self.BaseInfoButton.gameObject:SetActive(true)
			end
		end
	end
	end
end
end

function EquipmentWindowCls:SetB( ... )
	-- body
end

function EquipmentWindowCls:OnPanelStateEnter(state)
	-- 状态进入

	if state == BaseInfoPanelState then
		
		self:ChangeButtonTheme(self.BaseInfoButton)
		self:OnBaseInfoPanelEnter()
	elseif state == CombinePanelState then
		print("合成")
		self:ChangeButtonTheme(self.BaseInfoButton)
		self:OnCombinePanelEnter()
	elseif state == PowerupPanelState then
		
		self:ChangeButtonTheme(self.PowerUpButton)
		self:OnPowerupPanelPanelEnter()
	elseif state == UpgradePanelState then
		
		self:ChangeButtonTheme(self.UpgradeButton)
		self:OnUpgradePanelEnter()
	end

	self.currPanelState = state
end


function EquipmentWindowCls:OnPanelStateExit(state)
	-- 状态退出

	if state == BaseInfoPanelState then
		self:OnBaseInfoPanelExit()
	elseif state == CombinePanelState then
		self:OnCombinePanelExit()
	elseif state == PowerupPanelState then
		self:OnPowerupPanelPanelExit()
	elseif state == UpgradePanelState then
		self:OnUpgradePanelExit()
	end

	self.currPanelState = nil
	self.currActiveNode = nil
end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function EquipmentWindowCls:OnReturnButtonClicked()
	-- 返回
	self:Close()
end

function EquipmentWindowCls:EquipAdvancedResult(msg)
	if msg.success then
		self:DispatchEvent(messageGuids.UpdataKnapsackWindow,nil,KKnapsackItemType_EquipNormal)
		self:InitWinTheme()
		self:OnUpgradePanelExit()
		self.uid = msg.equipUID
		self:SetEquipmentUpgrade()
		-- print_debug(self.equipData:GetColor())
		if self.equipData ~= nil and self.equipData:GetColor() < 3 then
			self:OnUpgradePanelEnter()
		else
			self:ChangeButtonTheme(self.BaseInfoButton)
			self:OnBaseInfoPanelEnter()
		end
	end
end

function EquipmentWindowCls:OnBaseInfoButtonClicked()
	-- 信息
	self:StateChangeCtrl(self.stype)
end

function EquipmentWindowCls:OnPowerUpButtonClicked()
	-- 强化
	self:StateChangeCtrl(PowerupPanelState)
end

function EquipmentWindowCls:OnUpgradeButtonClicked()
	-- 进阶
	self:StateChangeCtrl(UpgradePanelState)
end


--红点
function EquipmentWindowCls:LocalRedDotChanged()
	if self.RoleUid== nil then
		return
	end
	local itype
	if not self.isDebris then
		local staticData = require "StaticData.Equip":GetData(self.id)
		itype = staticData:GetType()
		if itype == KEquipType_EquipWing then
			self.BaseInfoRedDot.enabled=false
			self.PowerUpRedDot.enabled=calculateRed.GetRoleEquipRedDataByIDAndPosAndIndex(self.RoleUid,10,1) 
			self.UpgradeRedDot.enabled=calculateRed.GetRoleEquipRedDataByIDAndPosAndIndex(self.RoleUid,10,2) 

			return
		end
	end


    local UserDataType = require "Framework.UserDataType"
    local tempData = self:GetCachedData(UserDataType.EquipBagData)
	local equipData = tempData:GetItem(self.uid)
	local equipType = equipData:GetEquipType()
	hzj_print(equipData:GetPos(),"Pos",equipType,self.RoleUid,equipData:GetOnWhichCard())
	if equipData:GetPos() == 0 then
		return
	end
	 --武器,防具
    if equipType == KEquipType_EquipWeapon or self.stype == KEquipType_EquipArmor then
    	self.BaseInfoRedDot.enabled=calculateRed.GetRoleEquipRedDataByIDAndPosAndIndex(self.RoleUid,equipData:GetPos(),2)
		self.PowerUpRedDot.enabled=calculateRed.GetRoleEquipRedDataByIDAndPosAndIndex(self.RoleUid,equipData:GetPos(),1) 
		self.UpgradeRedDot.enabled=false 
    --翅膀
    elseif equipType == KEquipType_EquipWing then
    --宠物
    elseif equipType == KEquipType_EquipPet then
    	self.UpgradeRedDot.enabled = calculateRed.GetRoleEquipRedDataByIDAndPosAndIndex(self.RoleUid,equipData:GetPos(),2)
		self.PowerUpRedDot.enabled = calculateRed.GetRoleEquipRedDataByIDAndPosAndIndex(self.RoleUid,equipData:GetPos(),1) 
		self.BaseInfoRedDot.enabled = false 
    else
       self.UpgradeRedDot.enabled = false
		self.PowerUpRedDot.enabled = false
		self.BaseInfoRedDot.enabled = false 
    end	

end

------------------------------------------------------------------------
---  改变button 样式
------------------------------------------------------------------------
local function ChangePosition(object,offset)
	-- 改变组件位置
	local transform = object.transform
	local tempPosition = transform.localPosition
	tempPosition.x = tempPosition.x + offset
	object.transform.localPosition = tempPosition
end

local function SetLabelTheme(label,OnShow)
	--设置文字样式
	local outLine = label:GetComponent(typeof(UnityEngine.UI.Outline))
	if OnShow then
		label.fontSize = 45
		label.color = UnityEngine.Color(1,1,1,1)
		outLine.enabled = true
	else
		label.fontSize = 36
		label.color = UnityEngine.Color(0,0,0,1)
		outLine.enabled = false
	end
end 

function EquipmentWindowCls:ChangeButtonTheme(targetButton)
	-- 更改button按钮选中主题
	if targetButton == self.OnSelectButton then
		return
	end
	local gameTool = require "Utils.GameTools"
	
	local buttonImage = targetButton.gameObject:GetComponent(typeof(UnityEngine.UI.Image))
	buttonImage.color = ButtonSelectedImageColor
	ChangePosition(targetButton,-30)
	local textLabel = targetButton.transform:Find('TextLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	SetLabelTheme(textLabel,true)

	if self.OnSelectButton ~= nil then
		local onSelectButtonImage = self.OnSelectButton.gameObject:GetComponent(typeof(UnityEngine.UI.Image))
		onSelectButtonImage.color = ButtonNormalImageColor
		ChangePosition(self.OnSelectButton,30)
		local textLabel = self.OnSelectButton.transform:Find('TextLabel'):GetComponent(typeof(UnityEngine.UI.Text))
		SetLabelTheme(textLabel,false)
	end

	self.OnSelectButton = targetButton
end

return EquipmentWindowCls