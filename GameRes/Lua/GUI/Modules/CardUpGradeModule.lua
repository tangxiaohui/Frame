-----------------------------------------------------------------------
---卡牌升级面板
-----------------------------------------------------------------------
local WindowNodeClass = require "Framework.Base.WindowNode"
local windowUtility = require "Framework.Window.WindowUtility"
local utility = require "Utils.Utility"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"
local CardUpGradeModule = Class(WindowNodeClass)
local RolePromote = require "StaticData.RolePromote"
local UserDataType = require "Framework.UserDataType"

-- # 设置为唯一
windowUtility.SetMutex(CardUpGradeModule, true)

function CardUpGradeModule:Ctor()
end

function CardUpGradeModule:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/CardUpGrade', function(go)
		self:BindComponent(go)
	end)
end

-- 指定为Module层!
function CardUpGradeModule:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end

function CardUpGradeModule:OnWillShow(heroData)
	self.heroData = heroData
	self.currRoleLv = self.heroData:GetLv()
end


function CardUpGradeModule:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

local function SetExpBattery(self,i,num)
	--- 设置经验电池数量
	if i == 1 then
	    self.ExpItemNumLabels[i].text = num
	elseif i == 2 then
		self.ExpItemNumLabels[i].text = num
	elseif i == 3 then
		self.ExpItemNumLabels[i].text = num
	end
end

local function ReloadNames(self, name)
    local StringUtility = require "Utils.StringUtility"
    local nameGroupCount = #self.nameGroupObjects
    local nameArray = StringUtility.CreateArray(name)
    local nameLength = math.min(nameGroupCount, #nameArray)
    for i = 1, nameGroupCount do
        local show = i <= nameLength
        self.nameGroupObjects[i]:SetActive(show)
        if show then
            self.nameGroupLabels[i].text = nameArray[i]
        end
    end
end

local function SetCardInfo(self)
	--- 设置卡牌信息
	ReloadNames(self,self.heroData:GetInfo())

	local roleLv = self.heroData:GetLv()
	self.CardBasisHeroListLvLabel.text = string.format("%s%s","Lv",roleLv)
	if roleLv > self.currRoleLv then
		self.currRoleLv = roleLv
		if not self.levelUpEffect.isPlaying then
			self.levelUpEffect:Play()
		end
	end

	local nextLv = math.min(roleLv+1,kMaxPlayerLevelNum)
	local promoteData = RolePromote:GetData(nextLv)
    if roleLv+1 > kMaxPlayerLevelNum then
        self.CardUpGradeExpNumLabel.text = '满级'
        self.CardUpGradeExpSlider.fillAmount = 1
        self.CardBasisHeroListLvLabel.text = string.format("%s%s","Lv",nextLv)
    else
	    local expPerLevel = promoteData:GetExpLevel()
	    local curExp = self.heroData:GetExp()
	    
	    if curExp >= expPerLevel then
	    	curExp = expPerLevel
	    end

    	self.CardUpGradeExpNumLabel.text = curExp..'/'..expPerLevel
        self.CardUpGradeExpSlider.fillAmount = curExp/expPerLevel
    end
	-- 加载图片
  	local roleID = self.heroData:GetId()
  	print("加载图片",roleID)
  	utility.LoadRolePortraitImage(roleID,self.CharactPortrait)
	
	--- 设置力敏智
	local attributeIndex, attributeText = self.heroData:GetMajorAttr()
    local attributeColor = require "Utils.GameTools".GetMajorAttrColor(attributeIndex)
    self.attributeLabel.text = attributeText
    self.attributeLabel.color = attributeColor

	utility.LoadRaceIcon(self.heroData:GetRace(),self.raceIconImage)

	local color = self.heroData:GetColor()
	local stage = self.heroData:GetStage()
	local PropUtility = require "Utils.PropUtility"
    self.qualityRankImage.color = PropUtility.GetColorValue(color)
    if stage <= 0 then
        self.qualityRankText.text = Color[color]
    else
        self.qualityRankText.text = string.format("%s +%d", Color[color], stage)
    end
end


function CardUpGradeModule:OnResume()
	-- 界面显示时调用
	CardUpGradeModule.base.OnResume(self)
	
	require "Utils.GameAnalysisUtils".RecordLocalAction(kTrackingId_CardPowerUpView)

	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	--- 淡入效果
	self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)
        transform.localScale = Vector3(s, s, s)
    end)
	
	
	----------------------初始化界面----------------------------
	SetCardInfo(self)
	self:GetItemBagData()
	self:InitExpColor()


	----新手引导----------
	local guideMgr = utility.GetGame():GetGuideManager()
	guideMgr:AddGuideEvnt(kGuideEvnt_HeroLevelupWindowtips)
	guideMgr:AddGuideEvnt(kGuideEvnt_DoHeroLevelup)
	guideMgr:AddGuideEvnt(kGuideEvnt_GreatWork4HeroLevelup)
	guideMgr:AddGuideEvnt(kGuideEvnt_HeroLevelupWindowOff)
	guideMgr:SortGuideEvnt()
	guideMgr:ShowGuidance()
end

function CardUpGradeModule:OnPause()
	-- 界面隐藏时调用
    CardUpGradeModule.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function CardUpGradeModule:OnEnter()
	-- Node Enter时调用
    CardUpGradeModule.base.OnEnter(self)
end

function CardUpGradeModule:OnExit()
	-- Node Exit时调用
    CardUpGradeModule.base.OnExit(self)
	
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
local function ResetCanvasRect(uiCanvas)
	uiCanvas.anchorMax = Vector2(1,1)
	uiCanvas.anchorMin = Vector2(0,0)
	uiCanvas.offsetMax = Vector2(0,0)
	uiCanvas.offsetMin = Vector2(0,0)
end

function CardUpGradeModule:InitControls()
	local transform = self:GetUnityTransform()

	---关闭按钮
	self.CardUpGradeRetrunButton = transform:Find('TweenObj/CardUpGradeRetrunButton'):GetComponent(typeof(UnityEngine.UI.Button))
	--- 卡牌等级  啦啦啦
	self.CardBasisHeroListLvLabel = transform:Find('TweenObj/HeroCharacter/CardPreInfo/LevelBase/Text'):GetComponent(typeof(UnityEngine.UI.Text))

	--- 卡牌经验条
	self.CardUpGradeExpSlider = transform:Find('TweenObj/CardUpGradeExpSlider/CardUpGradeExpSliderMask/FillFrame'):GetComponent(typeof(UnityEngine.UI.Image))
	
	--- 经验数字
	self.CardUpGradeExpNumLabel = transform:Find('TweenObj/CardUpGradeExpSlider/CardUpGradeExpNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))

	--- 经验电池 图标，颜色，按钮，数量，，，名字，，，
	self.ExpItemIcons = {
	    transform:Find('TweenObj/ExpItemLayout/ExpItem01/ExpItem01Icon'):GetComponent(typeof(UnityEngine.UI.Image)),
	    transform:Find('TweenObj/ExpItemLayout/ExpItem02/ExpItem02Icon'):GetComponent(typeof(UnityEngine.UI.Image)),
	    transform:Find('TweenObj/ExpItemLayout/ExpItem03/ExpItem03Icon'):GetComponent(typeof(UnityEngine.UI.Image)),
	}
	
	self.ExpItemColors = {
	    transform:Find('TweenObj/ExpItemLayout/ExpItem01/ExpItem01Color'),
		transform:Find('TweenObj/ExpItemLayout/ExpItem02/ExpItem02Color'),
		transform:Find('TweenObj/ExpItemLayout/ExpItem03/ExpItem03Color'),
	}
	
	self.ExpItemBtns = {
    	transform:Find('TweenObj/ExpItemLayout/ExpItem01/ExpItem01Icon'):GetComponent(typeof(UnityEngine.UI.RepeatButton)),
		transform:Find('TweenObj/ExpItemLayout/ExpItem02/ExpItem02Icon'):GetComponent(typeof(UnityEngine.UI.RepeatButton)),
		transform:Find('TweenObj/ExpItemLayout/ExpItem03/ExpItem03Icon'):GetComponent(typeof(UnityEngine.UI.RepeatButton)),
	}
	
	self.ExpItemNumLabels = {
	    transform:Find('TweenObj/ExpItemLayout/ExpItem01/ExpItem01NumLabel'):GetComponent(typeof(UnityEngine.UI.Text)),
		transform:Find('TweenObj/ExpItemLayout/ExpItem02/ExpItem02NumLabel'):GetComponent(typeof(UnityEngine.UI.Text)),
		transform:Find('TweenObj/ExpItemLayout/ExpItem03/ExpItem03NumLabel'):GetComponent(typeof(UnityEngine.UI.Text)),
	}

	local EffectCanvasTable = {
		transform:Find('TweenObj/ExpItemLayout/ExpItem01/EffectCanvas'):GetComponent(typeof(UnityEngine.RectTransform)),
		transform:Find('TweenObj/ExpItemLayout/ExpItem02/EffectCanvas'):GetComponent(typeof(UnityEngine.RectTransform)),
		transform:Find('TweenObj/ExpItemLayout/ExpItem03/EffectCanvas'):GetComponent(typeof(UnityEngine.RectTransform)),
	}
	ResetCanvasRect(EffectCanvasTable[1])
	ResetCanvasRect(EffectCanvasTable[2])
	ResetCanvasRect(EffectCanvasTable[3])

	self.ExpItemEffectTable = {
		transform:Find('TweenObj/ExpItemLayout/ExpItem01/EffectCanvas/UI_jueseshengji_1/Glow'):GetComponent(typeof(UnityEngine.ParticleSystem)),
		transform:Find('TweenObj/ExpItemLayout/ExpItem02/EffectCanvas/UI_jueseshengji_1/Glow'):GetComponent(typeof(UnityEngine.ParticleSystem)),
		transform:Find('TweenObj/ExpItemLayout/ExpItem03/EffectCanvas/UI_jueseshengji_1/Glow'):GetComponent(typeof(UnityEngine.ParticleSystem)),
	}
	
	--- 提示文字
	--self.Text = transform:Find('TweenObj/Text'):GetComponent(typeof(UnityEngine.UI.Text))
	
	--- 动画root
	self.tweenObjectTrans = transform:Find('TweenObj')
		--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))
	
	self.myGame = utility:GetGame()
	-- 经验电池
	self.expbatteryIdTable = {kItemId_NormalEnergyExpBattery,kItemId_HighEnergyExpBattery,kItemId_SuperEnergyExpBattery}

	 -- 名字组 --
    local nameGroup1 = transform:Find("TweenObj/HeroCharacter/HeroNameGroup1")
    local nameGroup2 = transform:Find("TweenObj/HeroCharacter/HeroNameGroup2")
    local nameGroup3 = transform:Find("TweenObj/HeroCharacter/HeroNameGroup3")
    local nameGroup4 = transform:Find("TweenObj/HeroCharacter/HeroNameGroup4")
    local nameGroup5 = transform:Find("TweenObj/HeroCharacter/HeroNameGroup5")

    self.nameGroupObjects = {
        nameGroup1.gameObject,
        nameGroup2.gameObject,
        nameGroup3.gameObject,
        nameGroup4.gameObject,
        nameGroup5.gameObject,
    }

    self.nameGroupLabels = {
        nameGroup1:Find("HeroCharacter/Text"):GetComponent(typeof(UnityEngine.UI.Text)),
        nameGroup2:Find("HeroCharacter/Text"):GetComponent(typeof(UnityEngine.UI.Text)),
        nameGroup3:Find("HeroCharacter/Text"):GetComponent(typeof(UnityEngine.UI.Text)),
        nameGroup4:Find("HeroCharacter/Text"):GetComponent(typeof(UnityEngine.UI.Text)),
        nameGroup5:Find("HeroCharacter/Text"):GetComponent(typeof(UnityEngine.UI.Text)),
    }

     self.raceIconImage = transform:Find("TweenObj/HeroCharacter/CardPreInfo/RaceIcon"):GetComponent(typeof(UnityEngine.UI.Image))
     self.attributeLabel = transform:Find("TweenObj/HeroCharacter/CardPreInfo/CardTypeBase/Text"):GetComponent(typeof(UnityEngine.UI.Text))
	
	local qualityRank = transform:Find("TweenObj/HeroCharacter/QualityGroup/QualityRank")
    self.qualityRankImage = qualityRank:GetComponent(typeof(UnityEngine.UI.Image))
    self.qualityRankText = qualityRank:Find("Text"):GetComponent(typeof(UnityEngine.UI.Text))

    -- 立绘
    self.CharactPortrait = transform:Find("TweenObj/CharactPortrait"):GetComponent(typeof(UnityEngine.UI.Image))

    -- 升级特效
    self.levelUpEffect = transform:Find('TweenObj/CardUpGradeExpSlider/LevelCanvas/UI_jueseshengji_2/Levelup'):GetComponent(typeof(UnityEngine.ParticleSystem))
    local levelUpEffectRect = transform:Find('TweenObj/CardUpGradeExpSlider/LevelCanvas'):GetComponent(typeof(UnityEngine.RectTransform))
    ResetCanvasRect(levelUpEffectRect)
end


function CardUpGradeModule:RegisterControlEvents()
	-- 注册 CardUpGradeRetrunButton 的事件
	self.__event_button_onCardUpGradeRetrunButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCardUpGradeRetrunButtonClicked, self)
	self.CardUpGradeRetrunButton.onClick:AddListener(self.__event_button_onCardUpGradeRetrunButtonClicked__)

	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCardUpGradeRetrunButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

    self._event_button_onExpBatteryButton1Clicked = UnityEngine.Events.UnityAction(self.OnExpBatteryButton1Clicked, self)
    self.ExpItemBtns[1].onClick:AddListener(self._event_button_onExpBatteryButton1Clicked)
	--长按
    self._event_button_onExpBatteryButton1RepeatClicked = UnityEngine.Events.UnityAction(self.OnExpBatteryButton1RepeatClicked, self)
    self.ExpItemBtns[1].m_OnRepeat:AddListener(self._event_button_onExpBatteryButton1RepeatClicked)

    self._event_button_onExpBatteryButton1PointerDown = UnityEngine.Events.UnityAction(self.OnExpBatteryButton1PointerDown, self)
    self.ExpItemBtns[1].m_OnPointerDown:AddListener(self._event_button_onExpBatteryButton1PointerDown)

    self._event_button_onExpBatteryButtonPointerUp = UnityEngine.Events.UnityAction(self.OnExpBatteryButtonPointerUp, self)
    self.ExpItemBtns[1].m_OnPointerUp:AddListener(self._event_button_onExpBatteryButtonPointerUp)

	self._event_button_onExpBatteryButton2Clicked = UnityEngine.Events.UnityAction(self.OnExpBatteryButton2Clicked, self)
    self.ExpItemBtns[2].onClick:AddListener(self._event_button_onExpBatteryButton2Clicked)
	--长按
	self._event_button_onExpBatteryButton2RepeatClicked = UnityEngine.Events.UnityAction(self.OnExpBatteryButton2RepeatClicked, self)
    self.ExpItemBtns[2].m_OnRepeat:AddListener(self._event_button_onExpBatteryButton2RepeatClicked)

    self._event_button_onExpBatteryButton2PointerDown = UnityEngine.Events.UnityAction(self.OnExpBatteryButton2PointerDown, self)
    self.ExpItemBtns[2].m_OnPointerDown:AddListener(self._event_button_onExpBatteryButton2PointerDown)

    self.ExpItemBtns[2].m_OnPointerUp:AddListener(self._event_button_onExpBatteryButtonPointerUp)

	self._event_button_onExpBatteryButton3Clicked = UnityEngine.Events.UnityAction(self.OnExpBatteryButton3Clicked, self)
    self.ExpItemBtns[3].onClick:AddListener(self._event_button_onExpBatteryButton3Clicked)
    --长按
    self._event_button_onExpBatteryButton3RepeatClicked = UnityEngine.Events.UnityAction(self.OnExpBatteryButton3RepeatClicked, self)
    self.ExpItemBtns[3].m_OnRepeat:AddListener(self._event_button_onExpBatteryButton3RepeatClicked)

    self._event_button_onExpBatteryButton3PointerDown = UnityEngine.Events.UnityAction(self.OnExpBatteryButton3PointerDown, self)
    self.ExpItemBtns[3].m_OnPointerDown:AddListener(self._event_button_onExpBatteryButton3PointerDown)

    self.ExpItemBtns[3].m_OnPointerUp:AddListener(self._event_button_onExpBatteryButtonPointerUp)

end

function CardUpGradeModule:OnExpBatteryButton1PointerDown()
	local UserDataType = require "Framework.UserDataType"
	local data = self:GetCachedData(UserDataType.ItemBagData)
	local count = data:GetItemCountById(self.expbatteryIdTable[1])
	if  count > 0 and (not self.ExpItemEffectTable[1].isPlaying) then
		self.ExpItemEffectTable[1]:Play()
	end	
end

function CardUpGradeModule:OnExpBatteryButton2PointerDown()
	local UserDataType = require "Framework.UserDataType"
	local data = self:GetCachedData(UserDataType.ItemBagData)
	local count = data:GetItemCountById(self.expbatteryIdTable[2])
	if  count > 0 and (not self.ExpItemEffectTable[2].isPlaying) then
		self.ExpItemEffectTable[2]:Play()
	end
end

function CardUpGradeModule:OnExpBatteryButton3PointerDown()
	local UserDataType = require "Framework.UserDataType"
	local data = self:GetCachedData(UserDataType.ItemBagData)
	local count = data:GetItemCountById(self.expbatteryIdTable[3])
	if  count > 0 and (not self.ExpItemEffectTable[3].isPlaying) then
		self.ExpItemEffectTable[3]:Play()
	end
end

function CardUpGradeModule:OnExpBatteryButtonPointerUp( )
	self.ExpItemEffectTable[1]:Stop()
	self.ExpItemEffectTable[2]:Stop()
	self.ExpItemEffectTable[3]:Stop()
end

function CardUpGradeModule:UnregisterControlEvents()
	-- 取消注册 CardUpGradeRetrunButton 的事件
	if self.__event_button_onCardUpGradeRetrunButtonClicked__ then
		self.CardUpGradeRetrunButton.onClick:RemoveListener(self.__event_button_onCardUpGradeRetrunButtonClicked__)
		self.__event_button_onCardUpGradeRetrunButtonClicked__ = nil
	end
	if self._event_button_onExpBatteryButton1Clicked then
		self.ExpItemBtns[1].onClick:RemoveListener(self._event_button_onExpBatteryButton1Clicked)
		self.ExpItemBtns[1].m_OnRepeat:RemoveListener(self._event_button_onExpBatteryButton1RepeatClicked)
		self._event_button_onExpBatteryButton1Clicked = nil
	end

	if self._event_button_onExpBatteryButton2Clicked then
		self.ExpItemBtns[2].onClick:RemoveListener(self._event_button_onExpBatteryButton2Clicked)
		self.ExpItemBtns[2].m_OnRepeat:RemoveListener(self._event_button_onExpBatteryButton2RepeatClicked)
		self._event_button_onExpBatteryButton2Clicked = nil
	end

	if self._event_button_onExpBatteryButton3Clicked then
		self.ExpItemBtns[3].onClick:RemoveListener(self._event_button_onExpBatteryButton3Clicked)
		self.ExpItemBtns[3].m_OnRepeat:RemoveListener(self._event_button_onExpBatteryButton3RepeatClicked)
		self._event_button_onExpBatteryButton3Clicked = nil
	end

	if self.OnExpBatteryButton1PointerDown then
		self.ExpItemBtns[1].m_OnPointerDown:RemoveListener(self._event_button_onExpBatteryButton1PointerDown)
	end

	if self.OnExpBatteryButton2PointerDown then
		self.ExpItemBtns[2].m_OnPointerDown:RemoveListener(self._event_button_onExpBatteryButton2PointerDown)
	end

	if self.OnExpBatteryButton3PointerDown then
		self.ExpItemBtns[3].m_OnPointerDown:RemoveListener(self._event_button_onExpBatteryButton3PointerDown)
	end

	if self.OnExpBatteryButtonPointerUp then
		self.ExpItemBtns[1].m_OnPointerUp:RemoveListener(self._event_button_onExpBatteryButtonPointerUp)
		self.ExpItemBtns[2].m_OnPointerUp:RemoveListener(self._event_button_onExpBatteryButtonPointerUp)
		self.ExpItemBtns[3].m_OnPointerUp:RemoveListener(self._event_button_onExpBatteryButtonPointerUp)
	end

	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end

end


function CardUpGradeModule:RegisterNetworkEvents()
	--- 注册网络事件
	self.myGame:RegisterMsgHandler(net.S2CCardProResult,self,self.OnCardProResult)
	self.myGame:RegisterMsgHandler(net.S2CCardBagFlush,self,self.OnCardBayFlush)
end

function CardUpGradeModule:UnregisterNetworkEvents()
	--- 注销网络事件
	self.myGame:UnRegisterMsgHandler(net.S2CCardProResult,self,self.OnCardProResult)
	self.myGame:UnRegisterMsgHandler(net.S2CCardBagFlush,self,self.OnCardBayFlush)
end

function CardUpGradeModule:IsTransition()
    return true
end

function CardUpGradeModule:OnExitTransitionDidStart(immediately)
    CardUpGradeModule.base.OnExitTransitionDidStart(self, immediately)
    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans
            local TweenUtility = require "Utils.TweenUtility"
            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function CardUpGradeModule:OnCardUpGradeRetrunButtonClicked()
	--CardUpGradeRetrunButton控件的点击事件处理
	self:Hide()
end

local function ShowErrorTip(self,msg)
	--- 弹出提示框，，，
	local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
	local windowManager = self.myGame:GetWindowManager()
   	windowManager:Show(ErrorDialogClass, msg)
end

function CardUpGradeModule:OnExpBatteryButton1Clicked()
	--- 经验电池点击事件处理
	local isPaly = self:CardProRequest(self.heroData:GetUid() ,1,0,0)
	if isPaly then
		self.showEffect = self.ExpItemEffectTable[1]
		self.showEffect:Play()
	end
end

function CardUpGradeModule:OnExpBatteryButton2Clicked()
	--- 高能经验电池点击事件处理
	local isPaly = self:CardProRequest(self.heroData:GetUid(),0,1,0)
	if isPaly then
		self.showEffect = self.ExpItemEffectTable[2]
		self.showEffect:Play()
	end
end

function CardUpGradeModule:OnExpBatteryButton3Clicked()
	--- 超能经验电池点击事件处理
	local isPaly = self:CardProRequest(self.heroData:GetUid(),0,0,1)
	if isPaly then
		self.showEffect = self.ExpItemEffectTable[3]
		self.showEffect:Play()
	end
end

function CardUpGradeModule:OnExpBatteryButton1RepeatClicked()
	local isPaly = self:CardProRequest(self.heroData:GetUid(),1,0,0)
	if isPaly then
		self.showEffect = self.ExpItemEffectTable[1]
		self:PlayExpEffect()
	end
end

function CardUpGradeModule:OnExpBatteryButton2RepeatClicked()
	local isPaly = self:CardProRequest(self.heroData:GetUid(),0,1,0)
	if isPaly then
		self.showEffect = self.ExpItemEffectTable[2]
		self:PlayExpEffect()
	end
end

function CardUpGradeModule:OnExpBatteryButton3RepeatClicked()
	local isPaly = self:CardProRequest(self.heroData:GetUid(),0,0,1)
	if isPaly then
		self.showEffect = self.ExpItemEffectTable[3]
		self:PlayExpEffect()
	end
end




local count = 0
function CardUpGradeModule:PlayExpEffect()
	count = count + 1
	if count > 1 then
		count = 0
		self.showEffect:Play()
	end
end
-----------------------------------------------------------------------
--- 网络处理
-----------------------------------------------------------------------
function CardUpGradeModule:CardProRequest(id,num1,num2,num3)
	--- 发送升级请求
	debug_print(' card pro request----------------id ' .. id)
	local isPlaying

	local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)

    local nextLv = self.heroData:GetLv()+1
    nextLv = math.min(nextLv,kMaxPlayerLevelNum)
    local promoteData = RolePromote:GetData(nextLv)
    if nextLv > kMaxPlayerLevelNum then
        ShowErrorTip(self,'卡牌已经满级')
    else
	    local expPerLevel = promoteData:GetExpLevel()
	    local curExp = self.heroData:GetExp()
	    if curExp >= expPerLevel and self.heroData:GetLv() == userData:GetLevel() then
            ShowErrorTip(self,'卡牌等级不能超过玩家等级')
	    else
            local  msg ,prototype = require"Network/ServerService".CardProRequest(id,num1,num2,num3)
	        self.myGame:SendNetworkMessage(msg,prototype)
	        isPlaying = true
	    end
    end

	return isPlaying
end

function CardUpGradeModule:InitExpColor()
	local PropUtility = require "Utils.PropUtility"
	local gametool = require "Utils.GameTools"

	for i = 1 ,#self.expbatteryIdTable do
		local _,data,_,icon = gametool.GetItemDataById(self.expbatteryIdTable[i])
		local color = data:GetColor()
		PropUtility.AutoSetColor(self.ExpItemColors[i],color)
		utility.LoadSpriteFromPath(icon,self.ExpItemIcons[i])
	end
end

function CardUpGradeModule:GetItemBagData()
	local UserDataType = require "Framework.UserDataType"
	local data = self:GetCachedData(UserDataType.ItemBagData)

	SetExpBattery(self,1,0)
	SetExpBattery(self,2,0)
	SetExpBattery(self,3,0)

	local items = {}
	for i = 1 ,#self.expbatteryIdTable do
		local count = data:GetItemCountById(self.expbatteryIdTable[i])
		SetExpBattery(self,i,count)
	end
end

function CardUpGradeModule:OnItemBagUpdate()
	
end

-- --- 获取背包数据请求
-- function CardUpGradeModule:ItemBagQueryRequest()
-- 	self.myGame:SendNetworkMessage( require"Network/ServerService".ItemBagQueryRequest())
-- end

-- --- 获取背包数据结果
-- function CardUpGradeModule:OnItemBagQueryResponse(msg)
	
-- 	for i=1,#msg.items do
-- 		print('id : ' .. msg.items[i].itemID..' num '.. msg.items[i].itemNum)
-- 		if msg.items[i].itemID == self.expBattery1Id then
-- 			SetExpBattery(self,1,msg.items[i].itemNum)
-- 		elseif msg.items[i].itemID == self.expBattery2Id then
-- 		    SetExpBattery(self,2,msg.items[i].itemNum)
-- 		elseif msg.items[i].itemID == self.expbattery3Id then
-- 		    SetExpBattery(self,3,msg.items[i].itemNum)
-- 		end
-- 	end
-- end

function CardUpGradeModule:OnCardBayFlush (msg)
	 -- 同步 玩家数据
    local dataCacheMgr = self.myGame:GetDataCacheManager()
	debug_print('OnCardBayFlush...................')
    -- 协议的命名很坑.. 说明下
    local oneCard = msg.cards

    dataCacheMgr:UpdateData(UserDataType.CardBagData, function(oldData)
        require "Data.CardBagData"
        if oldData == nil then
            oldData = CardBagData.New()
        end

        self.heroData = oldData:GetRoleByUid(self.heroData:GetUid())
		SetCardInfo(self)
        return oldData
    end)
	
end

function CardUpGradeModule:OnCardProResult(msg)
	debug_print(msg.cardUID.. " 状态 ".. msg.state)
	if msg.state == 0 then
	    --ShowErrorTip(self,'升级成功')
		---刷新经验电池数量，，，直接请求背包，，需优化
		
		
	else
		ShowErrorTip(self,'升级失败')
	end
	---更新经验等级，卡牌列表……怎么更新
	---
    ---
	self:GetItemBagData()
end


return CardUpGradeModule
