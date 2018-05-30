local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"
local EquipUpGradeCls = Class(BaseNodeClass)
require "LUT.StringTable"
require "Const"



-- 属性最大值对应ID
local hpLimitStaticID 	= 1001   		-- 生命
local gongjiliStaticID 	= 1002 			-- 攻击
local fangyuStaticID 	= 1003    		-- 防御
local speedStaticID 	= 1004			-- 速度
local baojilvStaticID 	= 1005			-- 暴击
local kangbaoPropStaticID 	= 1006 		-- 抗暴
local mingzhongPropStaticID = 1007		-- 命中
local shanbiPropStaticID = 1008			-- 闪避

local fixedRatio = 100 					-- 固定比率

local maxEquipLevel = 80 				-- 装备最大级别

-- 装备类型路径
local itemTagFixedPath = "UI/Atlases/ItemTypeTagIcon/"
local itemTagPath = {
		"TagIcon_Weapon","TagIcon_Equip","TagIcon_Acces","Shoes","TagIcon_Wings","TagIcon_Crystal","TagIcon_Wear",
		"TagIcon_Badge","TagIcon_Pets","TagIcon_Gem","TagIcon_Items"
	}

----------------------------------------------------------------------
function EquipUpGradeCls:Ctor()
end

function EquipUpGradeCls:OnWillShow(roleID,equipID)
	self.roleID = roleID
	self.equipID = equipID
	print("***************",roleID,equipID)

end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function EquipUpGradeCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/EquipUpGrade', function(go)
		self:BindComponent(go)
	end)
end

function EquipUpGradeCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function EquipUpGradeCls:OnResume()
	-- 界面显示时调用
	EquipUpGradeCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()

	self:ResetRolePanel()
	self:ResetEquipPanel()

	self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
end

function EquipUpGradeCls:OnPause()
	-- 界面隐藏时调用
	EquipUpGradeCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function EquipUpGradeCls:OnEnter()
	-- Node Enter时调用
	EquipUpGradeCls.base.OnEnter(self)
end

function EquipUpGradeCls:OnExit()
	-- Node Exit时调用
	EquipUpGradeCls.base.OnExit(self)
end


function EquipUpGradeCls:IsTransition()
    return false
end

function EquipUpGradeCls:OnExitTransitionDidStart(immediately)
	EquipUpGradeCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function EquipUpGradeCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function EquipUpGradeCls:InitControls()
	self.myGame = utility:GetGame()
	local transform = self:GetUnityTransform()
	self.tweenObjectTrans = transform:Find("Base")

	-- 返回按钮
	self.WingsReturnButton = transform:Find('Base/WingsReturnButton'):GetComponent(typeof(UnityEngine.UI.Button))

	-- 生命
	self.lifeLabel = transform:Find('Base/WingsCardInfo/WingsCardInfoStatusLabel/Scroll View/Viewport/Content/01Life/01LifeWingsCardInfoStatusLifeLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.lifeImage = transform:Find('Base/WingsCardInfo/WingsCardInfoStatusLabel/Scroll View/Viewport/Content/01Life/01LifeSlider'):GetComponent(typeof(UnityEngine.UI.Image))

	-- 攻击
	self.AttackLabel = transform:Find('Base/WingsCardInfo/WingsCardInfoStatusLabel/Scroll View/Viewport/Content/02Attack/02AttackWingsCardInfoStatusAttackLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.AttackImage = transform:Find('Base/WingsCardInfo/WingsCardInfoStatusLabel/Scroll View/Viewport/Content/02Attack/02AttackSlider'):GetComponent(typeof(UnityEngine.UI.Image))

	-- 防御
	self.defenseLabel = transform:Find('Base/WingsCardInfo/WingsCardInfoStatusLabel/Scroll View/Viewport/Content/03Defense/03DefenseWingsCardInfoStatusDefenseLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.defenseImage = transform:Find('Base/WingsCardInfo/WingsCardInfoStatusLabel/Scroll View/Viewport/Content/03Defense/03DefenseSlider'):GetComponent(typeof(UnityEngine.UI.Image))

	-- 速度 
	self.speedLabel = transform:Find('Base/WingsCardInfo/WingsCardInfoStatusLabel/Scroll View/Viewport/Content/04Speed/04SpeedWingsCardInfoStatusSpeedLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.speedImage = transform:Find('Base/WingsCardInfo/WingsCardInfoStatusLabel/Scroll View/Viewport/Content/04Speed/04SpeedSlider'):GetComponent(typeof(UnityEngine.UI.Image))

	-- 暴击
	self.critLabel = transform:Find('Base/WingsCardInfo/WingsCardInfoStatusLabel/Scroll View/Viewport/Content/05Crit/05CritWingsCardInfoStatusCritLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.critImage = transform:Find('Base/WingsCardInfo/WingsCardInfoStatusLabel/Scroll View/Viewport/Content/05Crit/05CritSlider'):GetComponent(typeof(UnityEngine.UI.Image))

	-- 暴抗
	self.resistCritLabel = transform:Find('Base/WingsCardInfo/WingsCardInfoStatusLabel/Scroll View/Viewport/Content/06ResistCrit/06ResistCritWingsCardInfoStatusResistLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.resistCritImage = transform:Find('Base/WingsCardInfo/WingsCardInfoStatusLabel/Scroll View/Viewport/Content/06ResistCrit/06ResistCritSlider'):GetComponent(typeof(UnityEngine.UI.Image))

	-- 命中
	self.hitRateLabel = transform:Find('Base/WingsCardInfo/WingsCardInfoStatusLabel/Scroll View/Viewport/Content/07HitRate/07HitRateWingsCardInfoStatusHitRateLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.hitRateImage = transform:Find('Base/WingsCardInfo/WingsCardInfoStatusLabel/Scroll View/Viewport/Content/07HitRate/07HitRateSlider'):GetComponent(typeof(UnityEngine.UI.Image))

	-- 闪避
	self.dodgeLabel = transform:Find('Base/WingsCardInfo/WingsCardInfoStatusLabel/Scroll View/Viewport/Content/08Dodge/08DodgeWingsCardInfoStatusDodgeLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.dodgeImage = transform:Find('Base/WingsCardInfo/WingsCardInfoStatusLabel/Scroll View/Viewport/Content/08Dodge/08DodgeSlider'):GetComponent(typeof(UnityEngine.UI.Image))
	
	-- 装备属性条
	self.EquipStatusLabelRect = transform:Find('Base/WingsGetupEquipInfo/Base2/EquipStatusLabelScrollView'):GetComponent(typeof(UnityEngine.UI.ScrollRect)) 
	self.EquipStatusLabel = transform:Find('Base/WingsGetupEquipInfo/Base2/EquipStatusLabelScrollView/Viewport/Content/EquipStatusLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	
	-- Role 等级 Label
	self.RoleLevelLabel = transform:Find('Base/WingsCardInfo/WingsCardInfoLv/WingsCardInfoLvNuLabel'):GetComponent(typeof(UnityEngine.UI.Text))

	-- 装备等级 Label
	self.EquipLevelLabel = transform:Find('Base/WingsGetupEquipInfo/Base2/WingsLV/WingsLvNuLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	
	-- 装备类型Icon
	self.EquipTypeIconImage = transform:Find('Base/WingsGetupEquipInfo/Base2/TypeWings'):GetComponent(typeof(UnityEngine.UI.Image))

	-- 装备名称
	self.EquipNameLabel = transform:Find('Base/WingsGetupEquipInfo/Base2/WingNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	
	-- 装备描述
	self.EquipDescLabel = transform:Find('Base/WingsGetupEquipInfo/Base2/EquipStatusDescLabel'):GetComponent(typeof(UnityEngine.UI.Text)) 

	-- 装备颜色
	self.ColorFrame = transform:Find('Base/WingsGetupEquipInfo/Base2/BigItemIcon/Farme')
	-- 装备星级
	self.StarFrame = transform:Find('Base/WingsGetupEquipInfo/Base2/BigItemIcon/ItemRank')
	-- 装备图片
	self.EquipIconImage = transform:Find('Base/WingsGetupEquipInfo/Base2/BigItemIcon/GeneralItemIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	
	-- 装备消升级耗
	self.upCostObj = transform:Find('Base/WingsGetupPrice').gameObject
	self.upCostLabel = transform:Find('Base/WingsGetupPrice/WingsGetupPriceLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	-- 装备顶级提示
	self.upCostHintObj = transform:Find('Base/MaxLevelHint').gameObject

	-- 强化按钮
	self.PowerupButton = transform:Find('Base/PowerupButton'):GetComponent(typeof(UnityEngine.UI.Button))
	
	-- 自动强化按钮
	self.AutoPowerupButton = transform:Find('Base/AutoPowerupButton'):GetComponent(typeof(UnityEngine.UI.Button))

end


function EquipUpGradeCls:RegisterControlEvents()	
	-- 注册 返回 的事件
	 self.__event_button_onWingsReturnButtonClicked__ = UnityEngine.Events.UnityAction(self.OnWingsReturnButtonClicked, self)
	 self.WingsReturnButton.onClick:AddListener(self.__event_button_onWingsReturnButtonClicked__)

	 -- 注册 强化按钮 的事件
	 self.__event_button_onPowerupButtonButtonClicked__ = UnityEngine.Events.UnityAction(self.OnPowerupButtonClicked, self)
	 self.PowerupButton.onClick:AddListener(self.__event_button_onPowerupButtonButtonClicked__)

	 -- 注册 自动强化按钮 的事件
	 self.__event_button_onAutoPowerupButtonClicked__ = UnityEngine.Events.UnityAction(self.OnAutoPowerupButtonClicked, self)
	 self.AutoPowerupButton.onClick:AddListener(self.__event_button_onAutoPowerupButtonClicked__)
end

function EquipUpGradeCls:UnregisterControlEvents()

	--取消注册 返回 的事件
	if self.__event_button_onWingsReturnButtonClicked__ then
		self.WingsReturnButton.onClick:RemoveListener(self.__event_button_onWingsReturnButtonClicked__)
		self.__event_button_onWingsReturnButtonClicked__ = nil
	end

	--取消注册 强化按钮 的事件
	if self.__event_button_onPowerupButtonButtonClicked__ then
		self.PowerupButton.onClick:RemoveListener(self.__event_button_onPowerupButtonButtonClicked__)
		self.__event_button_onPowerupButtonButtonClicked__ = nil
	end

	--取消注册 自动强化按钮 的事件
	if self.__event_button_onAutoPowerupButtonClicked__ then
		self.AutoPowerupButton.onClick:RemoveListener(self.__event_button_onAutoPowerupButtonClicked__)
		self.__event_button_onAutoPowerupButtonClicked__ = nil
	end
end

function EquipUpGradeCls:RegisterNetworkEvents()
	 self.myGame:RegisterMsgHandler(net.S2CEquipLevelUpResult, self, self.OnEquipLevelUpResponse)
	 self.myGame:RegisterMsgHandler(net.S2CEquipAutoLevelUpResult, self, self.OnEquipAutoLevelUpResponse)
end

function EquipUpGradeCls:UnregisterNetworkEvents()
	self.myGame:UnRegisterMsgHandler(net.S2CEquipLevelUpResult, self, self.OnEquipLevelUpResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CEquipAutoLevelUpResult, self, self.OnEquipAutoLevelUpResponse)
end
-----------------------------------------------------------------------
function EquipUpGradeCls:OnEquipLevelUpRequest(uid)
	self.myGame:SendNetworkMessage( require"Network/ServerService".EquipLevelUpRequest(uid))
end

function EquipUpGradeCls:OnEquipAutoLevelUpRequest(uid)
	self.myGame:SendNetworkMessage( require"Network/ServerService".EquipAutoLevelUpRequest(uid))
end

function EquipUpGradeCls:OnEquipLevelUpResponse(msg)
	-- 装备升级结果回调
	print("装备升级结果回调","state ",msg.state,"nowLevel ",msg.nowLevel)
	self:ResetEquipPanel()
end

function EquipUpGradeCls:OnEquipAutoLevelUpResponse()
	-- 装备自动升级结果
	print("装备自动升级结果")
	self:ResetEquipPanel()
end
-----------------------------------------------------------------------
function EquipUpGradeCls:ResetRolePanel(id)
	-- 重置卡牌信息

	-- 卡牌数据
	local UserDataType = require "Framework.UserDataType"
    local cardBagData = self:GetCachedData(UserDataType.CardBagData)
    local roleData = cardBagData:GetRoleByPos(1)

	local StaticData = require "StaticData.SystemConfig.SystemConfig"

	-- 生命
	local hpLimit = StaticData:GetData(hpLimitStaticID):GetParameNum()[0]
	local hp = roleData:GetHp()
	self.lifeLabel.text = hp
	self.lifeImage.fillAmount = hp / hpLimit

	-- 攻击
	local gongjili = StaticData:GetData(gongjiliStaticID):GetParameNum()[0]
	local attack = roleData:GetAp()
	self.AttackLabel.text = attack
	self.AttackImage.fillAmount = attack / gongjili

	-- 防御
	local fangyu = StaticData:GetData(fangyuStaticID):GetParameNum()[0]
	local dp = roleData:GetDp()
	self.defenseLabel.text = dp
	self.defenseImage.fillAmount = dp / fangyu

	-- 速度
	local speed = StaticData:GetData(speedStaticID):GetParameNum()[0]
	local sp = roleData:GetSpeed()
	self.speedLabel.text = sp
	self.speedImage.fillAmount = sp / speed

	-- 暴击
	local baojilvNum = StaticData:GetData(baojilvStaticID):GetParameNum()[0] 
	local crit = roleData:GetCritRate()
	print("暴击",crit,roleData:GetId())
	self.critLabel.text = crit .."%"
	self.critImage.fillAmount = crit / baojilvNum * fixedRatio

	-- 暴抗
	local kangbaoPropNum = StaticData:GetData(kangbaoPropStaticID):GetParameNum()[0]
	local resistCrit = roleData:GetDecritRate()
	self.resistCritLabel.text = resistCrit .."%"
	self.resistCritImage.fillAmount = resistCrit / kangbaoPropNum * fixedRatio

	-- 命中
	local mingzhongPropNum = StaticData:GetData(mingzhongPropStaticID):GetParameNum()[0]
	local hitRate = roleData:GetHitRate()
	self.hitRateLabel.text = hitRate / fixedRatio .."%"
	self.hitRateImage.fillAmount = hitRate / mingzhongPropNum 
	
	-- 闪避
	local shanbiPropNum = StaticData:GetData(shanbiPropStaticID):GetParameNum()[0]
	local dodge = roleData:GetHitRate()
	self.dodgeLabel.text = dodge / fixedRatio .."%" 
	self.dodgeImage.fillAmount = dodge / shanbiPropNum 

end


function EquipUpGradeCls:ResetEquipPanel(uid)
	-- 重置武器属性
	local gametool = require "Utils.GameTools"
	local propUtility = require "Utils.PropUtility"

	local UserDataType = require "Framework.UserDataType"
    local equipBagData = self:GetCachedData(UserDataType.EquipBagData)
    local equipData = equipBagData:GetDataByIndex(1)

    -- 当前装备等级
    local equipCurrLevel = equipData:GetLevel()
    print(equipData:GetEquipUID(),equipData:GetEquipID(),"UID,ID")

    -- 处理装备名字
	local equipName = equipData:GetName()
	self.EquipNameLabel.text = equipName

	-- 处理装备类型
	local equipType = equipData:GetEquipType()
	local iconPath = string.format("%s%s",itemTagFixedPath,itemTagPath[equipType])
	utility.LoadSpriteFromPath(iconPath,self.EquipTypeIconImage)

	-- 处理描述
	local desc = equipData:GetDesc()
	self.EquipDescLabel.text = desc

	-- 处理装备颜色
	local color = equipData:GetColor()
	propUtility.AutoSetColor(self.ColorFrame,color)

	-- 处理装备星级
	local star = equipData:GetStar()
	gametool.AutoSetStar(self.StarFrame,star)

	-- 处理装备图片
	local id = equipData:GetEquipID()
	local _,_,_,equipIconPath = gametool.GetItemDataById(id)
	utility.LoadSpriteFromPath(equipIconPath,self.EquipIconImage)

    -- 处理等级
    local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    
    local roleLevel = userData:GetLevel()
    self.RoleLevelLabel.text = roleLevel
    self.EquipLevelLabel.text = string.format("%s%s%s",equipCurrLevel,"/",roleLevel) --equipCurrLevel.."/"..roleLevel

    -- 是否可以升级 role 等级
    self.canUpWithRole = equipCurrLevel < roleLevel 
    
    -- 根据装备等级是否可以升级
    print(equipCurrLevel,maxEquipLevel,"******************")
    self.canUpWithlevel = equipCurrLevel < maxEquipLevel
    
    -- 是否可以升级
    local canUp = self.canUpWithRole and self.canUpWithlevel

    -- 处理装备属性面板
    local attributeDict = equipData:GetEquipAttribute()

    local StaticData = equipData:GetEquipStaticData()
    local mainPropID = StaticData:GetMainPropID()
    local addValue = StaticData:GetPromoteValue()
    
    local str = self:ResetItemDisInfoText(attributeDict,canUp,mainPropID,addValue)
	self.EquipStatusLabel.text = str
	self.EquipStatusLabelRect.verticalNormalizedPosition = 1

	-- 处理消耗
	if not self.canUpWithlevel then
		self.upCostObj:SetActive(false)
		self.upCostHintObj:SetActive(true)
		return
	end
	self.upCostHintObj:SetActive(false)
	self.upCostObj:SetActive(true)
	
	local costNeedID = math.min(equipCurrLevel,maxEquipLevel)
	local costStaticData = require "StaticData.EquipStrengthen":GetData(costNeedID)
	local costNeed 

	if equipType == KEquipType_EquipWeapon then 
		costNeed = costStaticData:GetAttackNeedCoin()
	elseif equipType == KEquipType_EquipArmor then
		costNeed = costStaticData:GetADefeneNeedCoin()
	end
	
	self.upCostLabel.text = costNeed


	--------------------------------------------
	self.equiUid = equipData:GetEquipUID()
end



local function UpdatePropValue(key,value)
    -- 判断是否为百分比
  local temp 
  value = string.format("%.0f",value)
  
  if key == kPropertyID_HpLimitRate or key == kPropertyID_DpRate or key == kPropertyID_ApRate or 
  	key == kPropertyID_CritRate or key == kPropertyID_DecritRate or key == kPropertyID_HitRate or 
  	key == kPropertyID_AvoidRate or key == kPropertyID_CritDamageRate then    
    temp = value.."%" 
  else
    temp = value
  end

  return temp
end


function EquipUpGradeCls:ResetItemDisInfoText(dict,isUp,mainID,addValue)
	-- 重置装备属性展示
	
	-- 显示Str
	local str = ""
	-- 固定Str
	local fixedStr
  	local fixedAddStr = EquipStringTable[0]
  	local fixedSubStr = EquipStringTable[16]

	local keys = dict:GetKeys()
	
	for i = 1 ,#keys do

		local key = keys[i]
		local additionValue = dict:GetEntryByKey(key)

		local tempStr = EquipStringTable[key]
   
   		if additionValue >= 0 then
      		fixedStr = fixedAddStr
    	else
      		fixedStr = fixedSubStr
    	end
        	
    	-- 处理升级后的数值
    	if mainID == key  then
    		if isUp then
    			additionValue = additionValue + addValue
    		end
    	end

    	additionValue = UpdatePropValue(key,additionValue)
		
    	local tempHintStr = string.format(fixedStr,tempStr,additionValue)
    	-- 处理升级后的添加数值
    	if mainID == key  then
    		if isUp then
    			local temp = string.format(EquipStringTable[16],"  +",addValue)
    			temp = string.gsub(temp,":","")
    			tempHintStr = string.gsub(tempHintStr,"\n",temp)
    		end
    	end

		if mainID == key then
			str = tempHintStr..str
		else
			str = str..tempHintStr
		end	
	end

	return str

end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function EquipUpGradeCls:OnWingsReturnButtonClicked()
	-- 返回控件的点击事件处理
	self:Close()
end

function EquipUpGradeCls:OnPowerupButtonClicked()
	--强化点击事件
	if not self.canUpWithlevel then
		local windowManager = self:GetWindowManager()
		local str = EquipStringTable[26]
		windowManager:Show(require "GUI.Dialogs.ErrorDialog",str)
		return 
	end
	
	self:OnEquipLevelUpRequest(self.equiUid)
	
	
end

function EquipUpGradeCls:OnAutoPowerupButtonClicked()
	--自动强化点击事件
	if not self.canUpWithlevel then
		local windowManager = self:GetWindowManager()
		local str = EquipStringTable[26]
		windowManager:Show(require "GUI.Dialogs.ErrorDialog",str)
		return 
	end
	
	self:OnEquipAutoLevelUpRequest(self.equiUid)
end




return EquipUpGradeCls