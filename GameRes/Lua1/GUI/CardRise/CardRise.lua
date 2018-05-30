local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"
require "Const"

local CardRiseCls = Class(BaseNodeClass)
windowUtility.SetMutex(CardRiseCls, true)

function CardRiseCls:Ctor()
end


function CardRiseCls:OnWillShow(data)
	self.cardData = data
	self.cardUid = self.cardData:GetUid()
	print("************",self.cardData:GetInfo())
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function CardRiseCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/CardRise', function(go)
		self:BindComponent(go)
	end)
end

function CardRiseCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function CardRiseCls:OnResume()
	-- 界面显示时调用
	CardRiseCls.base.OnResume(self)

	require "Utils.GameAnalysisUtils".RecordLocalAction(kTrackingId_CardUpgradeView)

	self:RegisterControlEvents()
	self:RegisterNetworkEvents()

	self:RefreshCardAttribute()

	self:FadeIn(function(self, t,finished)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
        if finished then
			
        end
    end)

    local guideMgr = utility.GetGame():GetGuideManager()
			guideMgr:AddGuideEvnt(kGuideEvnt_2ndCardUpgradeDone)
			guideMgr:SortGuideEvnt()
			guideMgr:ShowGuidance()
	



end

function CardRiseCls:OnPause()
	-- 界面隐藏时调用
	CardRiseCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
	
	self:HideCardNeedView()
end

function CardRiseCls:OnEnter()
	-- Node Enter时调用
	CardRiseCls.base.OnEnter(self)
end

function CardRiseCls:OnExit()
	-- Node Exit时调用
	CardRiseCls.base.OnExit(self)
end

function CardRiseCls:IsTransition()
    return false
end

function CardRiseCls:OnExitTransitionDidStart(immediately)
    CardRiseCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function CardRiseCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
local function GetStars(list,trans)
	-- 遍历星星
	local count = trans.childCount

	for i=0,count-1 do
		list[i+1] = trans:GetChild(i).gameObject;
	end
end


-- # 控件绑定
function CardRiseCls:InitControls()
	local transform = self:GetUnityTransform()
	self.TranslucentLayer = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BigWhiteBase = transform:Find('CardRiseBase/BigWindowBase/BigWhiteBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.LowerBorder = transform:Find('CardRiseBase/BigWindowBase/LowerBorder'):GetComponent(typeof(UnityEngine.UI.Image))
	self.UpperBorder = transform:Find('CardRiseBase/BigWindowBase/UpperBorder'):GetComponent(typeof(UnityEngine.UI.Image))
	self.CardRiseReturnButton = transform:Find('CardRiseBase/CardRiseReturnButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.GrayBase = transform:Find('CardRiseBase/GrayBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.FrameBase = transform:Find('CardRiseBase/Frame/FrameBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.LineGold = transform:Find('CardRiseBase/Frame/LineGold'):GetComponent(typeof(UnityEngine.UI.Image))
	self.LineOrange = transform:Find('CardRiseBase/Frame/LineOrange'):GetComponent(typeof(UnityEngine.UI.Image))
	self.FrameTitleImage = transform:Find('CardRiseBase/Frame/FrameTitleImage'):GetComponent(typeof(UnityEngine.UI.Image))
	self.CardRiseOldCardColorBase = transform:Find('CardRiseBase/OldCard/CardRiseOldCardColorBase'):GetComponent(typeof(UnityEngine.UI.Image))
	
	self.WhiteBaseOld = transform:Find('CardRiseBase/OldCard/WhiteBaseOld'):GetComponent(typeof(UnityEngine.UI.Image))
	self.NameBlackBaseOld = transform:Find('CardRiseBase/OldCard/NameBlackBaseOld'):GetComponent(typeof(UnityEngine.UI.Image))
	
	
	
	self.CardRiseOldCardStarIcon = transform:Find('CardRiseBase/OldCard/CardRiseOldCardStarLayout/CardRiseOldCardStarIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.OldLvBase = transform:Find('CardRiseBase/OldCard/OldLv/OldLvBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.OldLvImage = transform:Find('CardRiseBase/OldCard/OldLv/OldLvImage'):GetComponent(typeof(UnityEngine.UI.Image))
	
	self.LifeOldBase = transform:Find('CardRiseBase/OldCard/CardRiseOldCardPropertyLabel/LifeOld/LifeOldBase'):GetComponent(typeof(UnityEngine.UI.Image))
	
	
	self.AttackOldBase = transform:Find('CardRiseBase/OldCard/CardRiseOldCardPropertyLabel/AttackOld/AttackOldBase'):GetComponent(typeof(UnityEngine.UI.Image))
	
	
	self.DefenseOldBase = transform:Find('CardRiseBase/OldCard/CardRiseOldCardPropertyLabel/DefenseOld/DefenseOldBase'):GetComponent(typeof(UnityEngine.UI.Image))
	
	self.SpeedOldBase = transform:Find('CardRiseBase/OldCard/CardRiseOldCardPropertyLabel/SpeedOld/SpeedOldBase'):GetComponent(typeof(UnityEngine.UI.Image))
	
	self.OldStrengthTitleImage = transform:Find('CardRiseBase/OldStrength/OldStrengthTitleImage'):GetComponent(typeof(UnityEngine.UI.Image))
	
	self.ArrowImage = transform:Find('CardRiseBase/ArrowImage'):GetComponent(typeof(UnityEngine.UI.Image))
	self.CardRiseNewCardColorBase = transform:Find('CardRiseBase/NewCard/CardRiseNewCardColorBase'):GetComponent(typeof(UnityEngine.UI.Image))
	
	self.WhiteBaseNew = transform:Find('CardRiseBase/NewCard/WhiteBaseNew'):GetComponent(typeof(UnityEngine.UI.Image))
	self.NameBlackBaseNew = transform:Find('CardRiseBase/NewCard/NameBlackBaseNew'):GetComponent(typeof(UnityEngine.UI.Image))
	
	
	
	self.CardRiseNewCardStarIcon = transform:Find('CardRiseBase/NewCard/CardRiseNewCardStarLayout/CardRiseNewCardStarIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.NewLvBase = transform:Find('CardRiseBase/NewCard/NewLv/NewLvBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.NewLvImage = transform:Find('CardRiseBase/NewCard/NewLv/NewLvImage'):GetComponent(typeof(UnityEngine.UI.Image))
	
	self.LifeNewBase = transform:Find('CardRiseBase/NewCard/CardRiseNewCardPropertyLabel/LifeNew/LifeNewBase'):GetComponent(typeof(UnityEngine.UI.Image))
	
	
	
	
	self.AttackNewBase = transform:Find('CardRiseBase/NewCard/CardRiseNewCardPropertyLabel/AttackNew/AttackNewBase'):GetComponent(typeof(UnityEngine.UI.Image))
	
	
	
	self.DefenseNewBase = transform:Find('CardRiseBase/NewCard/CardRiseNewCardPropertyLabel/DefenseNew/DefenseNewBase'):GetComponent(typeof(UnityEngine.UI.Image))
	
	self.SpeedNewBase = transform:Find('CardRiseBase/NewCard/CardRiseNewCardPropertyLabel/SpeedNew/SpeedNewBase'):GetComponent(typeof(UnityEngine.UI.Image))
	
	self.NewStrengthTitleImage = transform:Find('CardRiseBase/NewStrength/NewStrengthTitleImage'):GetComponent(typeof(UnityEngine.UI.Image))
	
	
	
	self.ButtonBase = transform:Find('CardRiseBase/ButtonBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.CardRiseButtonImage = transform:Find('CardRiseBase/CardRiseButtonImage'):GetComponent(typeof(UnityEngine.UI.Button))
	--------------------------------------------------------------------
	-- 姓名
	self.CardRiseOldCardNameLabel = transform:Find('CardRiseBase/OldCard/CardRiseOldCardNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.CardRiseNewCardNameLabel = transform:Find('CardRiseBase/NewCard/CardRiseNewCardNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))

	-- 等级
	self.CardRiseOldCardLvNumLabel = transform:Find('CardRiseBase/OldCard/OldLv/CardRiseOldCardLvNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.CardRiseNewCardLvNumLabel = transform:Find('CardRiseBase/NewCard/NewLv/CardRiseNewCardLvNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))

	-- 生命值
	self.CardRiseOldCardPropertyLifeLabel = transform:Find('CardRiseBase/OldCard/CardRiseOldCardPropertyLabel/LifeOld/CardRiseOldCardPropertyLifeLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.LifeOldSlider = transform:Find('CardRiseBase/OldCard/CardRiseOldCardPropertyLabel/LifeOld/LifeOldSlider'):GetComponent(typeof(UnityEngine.UI.Scrollbar))
	
	self.CardRiseNewCardPropertyLifeLabel = transform:Find('CardRiseBase/NewCard/CardRiseNewCardPropertyLabel/LifeNew/CardRiseNewCardPropertyLifeLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.CardRiseNewCardPropertyAddLifeLabel = transform:Find('CardRiseBase/NewCard/CardRiseNewCardPropertyLabel/LifeNew/CardRiseNewCardPropertyAddLifeLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.LifeNewSliderOld = transform:Find('CardRiseBase/NewCard/CardRiseNewCardPropertyLabel/LifeNew/LifeNewSliderOld'):GetComponent(typeof(UnityEngine.UI.Scrollbar))
	self.LifeNewSliderNew = transform:Find('CardRiseBase/NewCard/CardRiseNewCardPropertyLabel/LifeNew/LifeNewSliderNew'):GetComponent(typeof(UnityEngine.UI.Scrollbar))

	-- 攻击
	self.CardRiseOldCardPropertyAttackLabel = transform:Find('CardRiseBase/OldCard/CardRiseOldCardPropertyLabel/AttackOld/CardRiseOldCardPropertyAttackLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.AttackOldSlider = transform:Find('CardRiseBase/OldCard/CardRiseOldCardPropertyLabel/AttackOld/AttackOldSlider'):GetComponent(typeof(UnityEngine.UI.Scrollbar))

	self.CardRiseNewCardPropertyAttackLabel = transform:Find('CardRiseBase/NewCard/CardRiseNewCardPropertyLabel/AttackNew/CardRiseNewCardPropertyAttackLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.CardRiseNewCardPropertyAddAttackLabel = transform:Find('CardRiseBase/NewCard/CardRiseNewCardPropertyLabel/AttackNew/CardRiseNewCardPropertyAddAttackLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.AttackNewSliderOld = transform:Find('CardRiseBase/NewCard/CardRiseNewCardPropertyLabel/AttackNew/AttackNewSliderOld'):GetComponent(typeof(UnityEngine.UI.Scrollbar))
	self.AttackNewSliderNew = transform:Find('CardRiseBase/NewCard/CardRiseNewCardPropertyLabel/AttackNew/AttackNewSliderNew'):GetComponent(typeof(UnityEngine.UI.Scrollbar))

	-- 防御
	self.DefenseOldSlider = transform:Find('CardRiseBase/OldCard/CardRiseOldCardPropertyLabel/DefenseOld/DefenseOldSlider'):GetComponent(typeof(UnityEngine.UI.Scrollbar))
	self.CardRiseOldCardPropertyDefenseLabel = transform:Find('CardRiseBase/OldCard/CardRiseOldCardPropertyLabel/DefenseOld/CardRiseOldCardPropertyDefenseLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	
	self.DefenseNewSliderNew = transform:Find('CardRiseBase/NewCard/CardRiseNewCardPropertyLabel/DefenseNew/DefenseNewSliderNew'):GetComponent(typeof(UnityEngine.UI.Scrollbar))
	self.DefenseNewSliderOld = transform:Find('CardRiseBase/NewCard/CardRiseNewCardPropertyLabel/DefenseNew/DefenseNewSliderOld'):GetComponent(typeof(UnityEngine.UI.Scrollbar))
	self.CardRiseNewCardPropertyDefenseLabel = transform:Find('CardRiseBase/NewCard/CardRiseNewCardPropertyLabel/DefenseNew/CardRiseNewCardPropertyDefenseLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.CardRiseNewCardPropertyAddDefenseLabel = transform:Find('CardRiseBase/NewCard/CardRiseNewCardPropertyLabel/DefenseNew/CardRiseNewCardPropertyAddDefenseLabel'):GetComponent(typeof(UnityEngine.UI.Text))

	--速度
	self.SpeedOldSlider = transform:Find('CardRiseBase/OldCard/CardRiseOldCardPropertyLabel/SpeedOld/SpeedOldSlider'):GetComponent(typeof(UnityEngine.UI.Scrollbar))
	self.CardRiseOldCardPropertySpeedLabel = transform:Find('CardRiseBase/OldCard/CardRiseOldCardPropertyLabel/SpeedOld/CardRiseOldCardPropertySpeedLabel'):GetComponent(typeof(UnityEngine.UI.Text))

	self.SpeedNewSliderNew = transform:Find('CardRiseBase/NewCard/CardRiseNewCardPropertyLabel/SpeedNew/SpeedNewSliderNew'):GetComponent(typeof(UnityEngine.UI.Scrollbar))
	self.SpeedNewSliderOld = transform:Find('CardRiseBase/NewCard/CardRiseNewCardPropertyLabel/SpeedNew/SpeedNewSliderOld'):GetComponent(typeof(UnityEngine.UI.Scrollbar))
	self.CardRiseNewCardPropertySpeedLabel = transform:Find('CardRiseBase/NewCard/CardRiseNewCardPropertyLabel/SpeedNew/CardRiseNewCardPropertySpeedLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.CardRiseNewCardPropertyAddSpeedLabel = transform:Find('CardRiseBase/NewCard/CardRiseNewCardPropertyLabel/SpeedNew/CardRiseNewCardPropertyAddSpeedLabel'):GetComponent(typeof(UnityEngine.UI.Text))

	-- 战斗力
	self.CardRiseOldStrengthNumLabel = transform:Find('CardRiseBase/OldStrength/CardRiseOldStrengthNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.CardRiseNewStrengthNumLabel = transform:Find('CardRiseBase/NewStrength/CardRiseNewStrengthNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))

	-- 金币
	self.CoinCost = transform:Find('CardRiseBase/Price/CoinCost'):GetComponent(typeof(UnityEngine.UI.Text))

	-- 品阶
	self.CardRiseOldCardEnhancedLabe = transform:Find('CardRiseBase/OldCard/CardRiseOldCardEnhancedLabe'):GetComponent(typeof(UnityEngine.UI.Text))
	self.CardRiseNewCardEnhancedLabe = transform:Find('CardRiseBase/NewCard/CardRiseNewCardEnhancedLabe'):GetComponent(typeof(UnityEngine.UI.Text))

	-- 材料组件布局
	self.ItemLayout = transform:Find('CardRiseBase/MaterialLayout')

	-- 旧 星星数组
	-- self.oldStars = {}
	-- self.oldStar = transform:Find('CardRiseBase/OldCard/CardRiseOldCardStarLayout')
	-- GetStars(self.oldStars,self.oldStar)
	
	-- 新星星数组
	-- self.newStars = {}
	-- self.newStar = transform:Find('CardRiseBase/NewCard/CardRiseNewCardStarLayout')
	-- GetStars(self.newStars,self.newStar)

	-- 属性
	self.CardRiseOldCardAttributes = transform:Find('CardRiseBase/OldCard/CardTypeBase/Text'):GetComponent(typeof(UnityEngine.UI.Text))
	self.CardRiseNewCardAttributes = transform:Find('CardRiseBase/NewCard/CardTypeBase/Text'):GetComponent(typeof(UnityEngine.UI.Text))

	-- 立绘
	self.CardRiseOldCardShow = transform:Find('CardRiseBase/OldCard/CardRiseOldCardShow'):GetComponent(typeof(UnityEngine.UI.Image))
	self.CardRiseNewCardShow = transform:Find('CardRiseBase/NewCard/CardRiseNewCardShow'):GetComponent(typeof(UnityEngine.UI.Image))

	-- 顶级提示文本
	self.maxStageHintLabel = transform:Find('CardRiseBase/StageMaxHint').gameObject

	self.CardRiseCurrencyIcon = transform:Find('CardRiseBase/Price').gameObject

	self.attributesIconPath = {"UI/Atlases/CardBasis/CardBasis_Power","UI/Atlases/CardBasis/CardBasis_Quick","UI/Atlases/CardBasis/CardBasis_Intelligence"}

	self.tweenObjectTrans = transform:Find('CardRiseBase')

	--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))

	self.myGame = utility:GetGame()

	self:GetMaxConst()
	self:InitNeedItem()
end


function CardRiseCls:GetMaxConst()
	-- 获取属性最大数值   TODO : Const 属性最大数值 参数ID
	local mgr = require "StaticData.SystemConfig.SystemConfig"
	self.lifeMax = mgr:GetData(1001):GetParameNum()[0]
	self.apMax = mgr:GetData(1002):GetParameNum()[0]
	self.dpMax = mgr:GetData(1003):GetParameNum()[0]
	self.dpMax = 1000
	self.speedMax = mgr:GetData(1004):GetParameNum()[0]
end

function CardRiseCls:RegisterControlEvents()
	-- 注册 CardRiseReturnButton 的事件
	self.__event_button_onCardRiseReturnButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCardRiseReturnButtonClicked, self)
	self.CardRiseReturnButton.onClick:AddListener(self.__event_button_onCardRiseReturnButtonClicked__)

	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCardRiseReturnButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

	-- 注册 LifeOldSlider 的事件
	self.__event_scrollbar_onLifeOldSliderValueChanged__ = UnityEngine.Events.UnityAction_float(self.OnLifeOldSliderValueChanged, self)
	self.LifeOldSlider.onValueChanged:AddListener(self.__event_scrollbar_onLifeOldSliderValueChanged__)

	-- 注册 AttackOldSlider 的事件
	self.__event_scrollbar_onAttackOldSliderValueChanged__ = UnityEngine.Events.UnityAction_float(self.OnAttackOldSliderValueChanged, self)
	self.AttackOldSlider.onValueChanged:AddListener(self.__event_scrollbar_onAttackOldSliderValueChanged__)

	-- 注册 DefenseOldSlider 的事件
	self.__event_scrollbar_onDefenseOldSliderValueChanged__ = UnityEngine.Events.UnityAction_float(self.OnDefenseOldSliderValueChanged, self)
	self.DefenseOldSlider.onValueChanged:AddListener(self.__event_scrollbar_onDefenseOldSliderValueChanged__)

	-- 注册 SpeedOldSlider 的事件
	self.__event_scrollbar_onSpeedOldSliderValueChanged__ = UnityEngine.Events.UnityAction_float(self.OnSpeedOldSliderValueChanged, self)
	self.SpeedOldSlider.onValueChanged:AddListener(self.__event_scrollbar_onSpeedOldSliderValueChanged__)

	-- 注册 LifeNewSliderNew 的事件
	self.__event_scrollbar_onLifeNewSliderNewValueChanged__ = UnityEngine.Events.UnityAction_float(self.OnLifeNewSliderNewValueChanged, self)
	self.LifeNewSliderNew.onValueChanged:AddListener(self.__event_scrollbar_onLifeNewSliderNewValueChanged__)

	-- 注册 LifeNewSliderOld 的事件
	self.__event_scrollbar_onLifeNewSliderOldValueChanged__ = UnityEngine.Events.UnityAction_float(self.OnLifeNewSliderOldValueChanged, self)
	self.LifeNewSliderOld.onValueChanged:AddListener(self.__event_scrollbar_onLifeNewSliderOldValueChanged__)

	-- 注册 AttackNewSliderOld 的事件
	self.__event_scrollbar_onAttackNewSliderOldValueChanged__ = UnityEngine.Events.UnityAction_float(self.OnAttackNewSliderOldValueChanged, self)
	self.AttackNewSliderOld.onValueChanged:AddListener(self.__event_scrollbar_onAttackNewSliderOldValueChanged__)

	-- 注册 AttackNewSliderNew 的事件
	self.__event_scrollbar_onAttackNewSliderNewValueChanged__ = UnityEngine.Events.UnityAction_float(self.OnAttackNewSliderNewValueChanged, self)
	self.AttackNewSliderNew.onValueChanged:AddListener(self.__event_scrollbar_onAttackNewSliderNewValueChanged__)

	-- 注册 DefenseNewSliderNew 的事件
	self.__event_scrollbar_onDefenseNewSliderNewValueChanged__ = UnityEngine.Events.UnityAction_float(self.OnDefenseNewSliderNewValueChanged, self)
	self.DefenseNewSliderNew.onValueChanged:AddListener(self.__event_scrollbar_onDefenseNewSliderNewValueChanged__)

	-- 注册 DefenseNewSliderOld 的事件
	self.__event_scrollbar_onDefenseNewSliderOldValueChanged__ = UnityEngine.Events.UnityAction_float(self.OnDefenseNewSliderOldValueChanged, self)
	self.DefenseNewSliderOld.onValueChanged:AddListener(self.__event_scrollbar_onDefenseNewSliderOldValueChanged__)

	-- 注册 SpeedNewSliderNew 的事件
	self.__event_scrollbar_onSpeedNewSliderNewValueChanged__ = UnityEngine.Events.UnityAction_float(self.OnSpeedNewSliderNewValueChanged, self)
	self.SpeedNewSliderNew.onValueChanged:AddListener(self.__event_scrollbar_onSpeedNewSliderNewValueChanged__)

	-- 注册 SpeedNewSliderOld 的事件
	self.__event_scrollbar_onSpeedNewSliderOldValueChanged__ = UnityEngine.Events.UnityAction_float(self.OnSpeedNewSliderOldValueChanged, self)
	self.SpeedNewSliderOld.onValueChanged:AddListener(self.__event_scrollbar_onSpeedNewSliderOldValueChanged__)

	-- 注册 CardRiseButtonImage 的事件
	self.__event_button_onCardRiseButtonImageClicked__ = UnityEngine.Events.UnityAction(self.OnCardRiseButtonImageClicked, self)
	self.CardRiseButtonImage.onClick:AddListener(self.__event_button_onCardRiseButtonImageClicked__)
end

function CardRiseCls:UnregisterControlEvents()
	-- 取消注册 CardRiseReturnButton 的事件
	if self.__event_button_onCardRiseReturnButtonClicked__ then
		self.CardRiseReturnButton.onClick:RemoveListener(self.__event_button_onCardRiseReturnButtonClicked__)
		self.__event_button_onCardRiseReturnButtonClicked__ = nil
	end

	-- 取消注册 LifeOldSlider 的事件
	if self.__event_scrollbar_onLifeOldSliderValueChanged__ then
		self.LifeOldSlider.onValueChanged:RemoveListener(self.__event_scrollbar_onLifeOldSliderValueChanged__)
		self.__event_scrollbar_onLifeOldSliderValueChanged__ = nil
	end

	-- 取消注册 AttackOldSlider 的事件
	if self.__event_scrollbar_onAttackOldSliderValueChanged__ then
		self.AttackOldSlider.onValueChanged:RemoveListener(self.__event_scrollbar_onAttackOldSliderValueChanged__)
		self.__event_scrollbar_onAttackOldSliderValueChanged__ = nil
	end

	-- 取消注册 DefenseOldSlider 的事件
	if self.__event_scrollbar_onDefenseOldSliderValueChanged__ then
		self.DefenseOldSlider.onValueChanged:RemoveListener(self.__event_scrollbar_onDefenseOldSliderValueChanged__)
		self.__event_scrollbar_onDefenseOldSliderValueChanged__ = nil
	end

	-- 取消注册 SpeedOldSlider 的事件
	if self.__event_scrollbar_onSpeedOldSliderValueChanged__ then
		self.SpeedOldSlider.onValueChanged:RemoveListener(self.__event_scrollbar_onSpeedOldSliderValueChanged__)
		self.__event_scrollbar_onSpeedOldSliderValueChanged__ = nil
	end

	-- 取消注册 LifeNewSliderNew 的事件
	if self.__event_scrollbar_onLifeNewSliderNewValueChanged__ then
		self.LifeNewSliderNew.onValueChanged:RemoveListener(self.__event_scrollbar_onLifeNewSliderNewValueChanged__)
		self.__event_scrollbar_onLifeNewSliderNewValueChanged__ = nil
	end

	-- 取消注册 LifeNewSliderOld 的事件
	if self.__event_scrollbar_onLifeNewSliderOldValueChanged__ then
		self.LifeNewSliderOld.onValueChanged:RemoveListener(self.__event_scrollbar_onLifeNewSliderOldValueChanged__)
		self.__event_scrollbar_onLifeNewSliderOldValueChanged__ = nil
	end

	-- 取消注册 AttackNewSliderOld 的事件
	if self.__event_scrollbar_onAttackNewSliderOldValueChanged__ then
		self.AttackNewSliderOld.onValueChanged:RemoveListener(self.__event_scrollbar_onAttackNewSliderOldValueChanged__)
		self.__event_scrollbar_onAttackNewSliderOldValueChanged__ = nil
	end

	-- 取消注册 AttackNewSliderNew 的事件
	if self.__event_scrollbar_onAttackNewSliderNewValueChanged__ then
		self.AttackNewSliderNew.onValueChanged:RemoveListener(self.__event_scrollbar_onAttackNewSliderNewValueChanged__)
		self.__event_scrollbar_onAttackNewSliderNewValueChanged__ = nil
	end

	-- 取消注册 DefenseNewSliderNew 的事件
	if self.__event_scrollbar_onDefenseNewSliderNewValueChanged__ then
		self.DefenseNewSliderNew.onValueChanged:RemoveListener(self.__event_scrollbar_onDefenseNewSliderNewValueChanged__)
		self.__event_scrollbar_onDefenseNewSliderNewValueChanged__ = nil
	end

	-- 取消注册 DefenseNewSliderOld 的事件
	if self.__event_scrollbar_onDefenseNewSliderOldValueChanged__ then
		self.DefenseNewSliderOld.onValueChanged:RemoveListener(self.__event_scrollbar_onDefenseNewSliderOldValueChanged__)
		self.__event_scrollbar_onDefenseNewSliderOldValueChanged__ = nil
	end

	-- 取消注册 SpeedNewSliderNew 的事件
	if self.__event_scrollbar_onSpeedNewSliderNewValueChanged__ then
		self.SpeedNewSliderNew.onValueChanged:RemoveListener(self.__event_scrollbar_onSpeedNewSliderNewValueChanged__)
		self.__event_scrollbar_onSpeedNewSliderNewValueChanged__ = nil
	end

	-- 取消注册 SpeedNewSliderOld 的事件
	if self.__event_scrollbar_onSpeedNewSliderOldValueChanged__ then
		self.SpeedNewSliderOld.onValueChanged:RemoveListener(self.__event_scrollbar_onSpeedNewSliderOldValueChanged__)
		self.__event_scrollbar_onSpeedNewSliderOldValueChanged__ = nil
	end

	-- 取消注册 CardRiseButtonImage 的事件
	if self.__event_button_onCardRiseButtonImageClicked__ then
		self.CardRiseButtonImage.onClick:RemoveListener(self.__event_button_onCardRiseButtonImageClicked__)
		self.__event_button_onCardRiseButtonImageClicked__ = nil
	end

	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end

end


function CardRiseCls:RegisterNetworkEvents()
	self.myGame:RegisterMsgHandler(net.S2CCardGradeUpResult, self, self.OnCardGradeUpResponse)
	self.myGame:RegisterMsgHandler(net.S2CCardStageUpResult, self, self.OnCardStageUpResponse)
end

function CardRiseCls:UnregisterNetworkEvents()
	self.myGame:UnRegisterMsgHandler(net.S2CCardGradeUpResult, self, self.OnCardGradeUpResponse)
	self.myGame:UnRegisterMsgHandler(net.S2CCardStageUpResult, self, self.OnCardStageUpResponse)
end



function CardRiseCls:OnCardGradeUpRequest(uid)
	self.myGame:SendNetworkMessage( require"Network/ServerService".CardGradeUpRequest(uid))
end

function CardRiseCls:OnCardStageUpRequest(uid)
	self.myGame:SendNetworkMessage( require"Network/ServerService".CardStageUpRequest(uid))
end

local function GetInfo(self)
	local oldInfo = {}
	oldInfo.stage = self.stage 
	oldInfo.color = self.oldColor
	oldInfo.life = self.oldLife
	oldInfo.ap = self.oldAp
	oldInfo.dp = self.oldDp
	oldInfo.speed = self.oldSpeed

	local newInfo = {}
	newInfo.nextStage = self.nextStage
	newInfo.color = self.newColor
	newInfo.life = self.NewLife
	newInfo.ap = self.NewAp
	newInfo.dp = self.NewDp
	newInfo.speed = self.NewSpeed

	return oldInfo,newInfo
end

function CardRiseCls:OnCardGradeUpResponse(msg)
	--  升品
	print("升品")
	self:HideCardNeedView()
	
	local oldInfo,newInfo = GetInfo(self)

	--local id = self.cardData:GetId()
	local windowManager = self.myGame:GetWindowManager()
    windowManager:Show(require "GUI.GeneralCard.CardUpGradeResult",self.riseType,self.cardData,oldInfo,newInfo)

    self:RefreshCardAttribute()
end

function CardRiseCls:OnCardStageUpResponse(msg)
	-- 进阶
	print("进阶")
	self:HideCardNeedView()
	--local id = self.cardData:GetId()
	local oldInfo,newInfo = GetInfo(self)

	local windowManager = self.myGame:GetWindowManager()
    windowManager:Show(require "GUI.GeneralCard.CardUpGradeResult",self.riseType,self.cardData,oldInfo,newInfo)

    self:RefreshCardAttribute()
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function CardRiseCls:OnCardRiseReturnButtonClicked()
	--CardRiseReturnButton控件的点击事件处理
	self:Close()
end

function CardRiseCls:OnLifeOldSliderValueChanged(value)
	--LifeOldSlider控件的点击事件处理
end

function CardRiseCls:OnAttackOldSliderValueChanged(value)
	--AttackOldSlider控件的点击事件处理
end

function CardRiseCls:OnDefenseOldSliderValueChanged(value)
	--DefenseOldSlider控件的点击事件处理
end

function CardRiseCls:OnSpeedOldSliderValueChanged(value)
	--SpeedOldSlider控件的点击事件处理
end

function CardRiseCls:OnLifeNewSliderNewValueChanged(value)
	--LifeNewSliderNew控件的点击事件处理
end

function CardRiseCls:OnLifeNewSliderOldValueChanged(value)
	--LifeNewSliderOld控件的点击事件处理
end

function CardRiseCls:OnAttackNewSliderOldValueChanged(value)
	--AttackNewSliderOld控件的点击事件处理
end

function CardRiseCls:OnAttackNewSliderNewValueChanged(value)
	--AttackNewSliderNew控件的点击事件处理
end

function CardRiseCls:OnDefenseNewSliderNewValueChanged(value)
	--DefenseNewSliderNew控件的点击事件处理
end

function CardRiseCls:OnDefenseNewSliderOldValueChanged(value)
	--DefenseNewSliderOld控件的点击事件处理
end

function CardRiseCls:OnSpeedNewSliderNewValueChanged(value)
	--SpeedNewSliderNew控件的点击事件处理
end

function CardRiseCls:OnSpeedNewSliderOldValueChanged(value)
	--SpeedNewSliderOld控件的点击事件处理
end

function CardRiseCls:OnCardRiseButtonImageClicked()
	--CardRiseButtonImage控件的点击事件处理
	if self.riseType == 1 then
		self:OnCardStageUpRequest(self.cardUid)
	elseif self.riseType == 2 then
		self:OnCardGradeUpRequest(self.cardUid)
	end
end

-------------------------------------------------------------------------
function CardRiseCls:InitNeedItem()
	-- 初始化材料列表  const MaxItemCount = 4
	
	self.itemList = {}
	
	for i=1,4 do
		local node = require "GUI.CardRise.CardRiseItem".New(self.ItemLayout)
		self.itemList[#self.itemList + 1] = node
	end

	-- 碎片
	self.chipNode = require "GUI.CardRise.CardRiseChip".New(self.ItemLayout)
end

function CardRiseCls:RefreshCardAttribute()
	-- 刷新卡牌信息
	
	self.color = self.cardData:GetColor()
	
	local oldColor
	local newColor

	if self.color >= KCardColorType_Purple then
		-- 进阶操作
		print("进阶操作")
		self.riseType = 1
		self:RefreshtCardStageNeedView()
		oldColor = self.color
		newColor = self.color
	else
		-- 升品操作
		print("升品操作")
		self.riseType = 2
		self:RefreshtCardGradeNeedView()
		oldColor = self.color
		newColor = oldColor + 1
	end
	
	print("***进阶***",self.riseType)
	self:RefreshOldCradAttribute(oldColor)
	self:RefreshNewCradAttribute(newColor)

	self.CoinCost.text = self.coinCost

	--
	self.oldColor = oldColor
	self.newColor = newColor
end

function CardRiseCls:RefreshtCardGradeNeedView()
	-- 刷新升品需要材料界面
	local mgr = require "StaticData.RoleUpQuality"
	local cardId = self.cardData:GetId()
	local cardColor = self.cardData:GetColor()

	local itemId = tonumber(string.format("%d%d",cardId,cardColor))

	local data = mgr:GetData(itemId)

	self.coinCost = data:GetCoin()

	for i=1,#self.itemList do
		self:AddChild(self.itemList[i])

		local needId,needCount = data:GetIdAndCount(i)
		self.itemList[i]:ResetView(needId,needCount)
	end

	self.CardRiseOldCardEnhancedLabe.gameObject:SetActive(false)
	self.CardRiseNewCardEnhancedLabe.gameObject:SetActive(false)
	self.maxStageHintLabel:SetActive(false)
	self.CardRiseButtonImage.interactable = true
	self.CardRiseCurrencyIcon:SetActive(true)

end

function CardRiseCls:RefreshtCardStageNeedView()
	-- 刷新进阶需要材料界面
	local mgr = require "StaticData.RoleImprove"
	
	local stage = self.cardData:GetStage()

	if stage > KCardStageMax then
		-- 达到顶阶
		if not self.maxStageHintLabel.activeSelf then
			self.maxStageHintLabel:SetActive(true)
		end

		self.CardRiseCurrencyIcon:SetActive(false)

		self.CardRiseButtonImage.interactable = false

		self.coinCost = ""

		--self:HideCardNeedView()
	else
		
		if self.maxStageHintLabel.activeSelf then
			self.maxStageHintLabel:SetActive(false)
		end

			self.CardRiseCurrencyIcon:SetActive(true)

		self.CardRiseButtonImage.interactable = true

		local count = mgr:GetData(stage):GetNeedCardSuipianNum()
		
		self.coinCost = mgr:GetData(stage):GetCoin()
	
		self:AddChild(self.chipNode)
		self.chipNode:ResetView(self.cardData,count)
	end

	self.CardRiseOldCardEnhancedLabe.gameObject:SetActive(true)
	self.CardRiseNewCardEnhancedLabe.gameObject:SetActive(true)

	local nextStage = math.min(stage+1,KCardStageMax+1)
	
	self.stage = stage
	self.nextStage = nextStage

	if stage == 0 then
		stage = ""
	else
		stage = string.format("%s%s","+",stage)
	end
	self.CardRiseOldCardEnhancedLabe.text = stage
	self.CardRiseNewCardEnhancedLabe.text = string.format("%s%s","+",nextStage)


end

function CardRiseCls:HideCardNeedView()
	-- 清除需要材料
	if self.riseType == 1 then
		
		self:RemoveChild(self.chipNode)
	elseif self.riseType == 2 then
		
		for i=1,#self.itemList do
			self:RemoveChild(self.itemList[i])
		end		
	end
end

local function SetStarShow(self,statList,starCount)
	-- 设置星星
	if starCount <= #statList then
		for i=1,starCount do

			statList[i]:SetActive(true)
		end

		for i=starCount + 1,#statList do
			
			statList[i]:SetActive(false)
		end
	end
end

local function SetMajorAttr(self,label)
	-- 属性
	local majorAttr,attributeText = self.cardData:GetMajorAttr()
    local attributeColor = require "Utils.GameTools".GetMajorAttrColor(majorAttr)
    label.text = attributeText
    label.color = attributeColor
end

local function SetCardPortraitImage(self,image)
	utility.LoadRolePortraitImage(
		self.cardData:GetId(),
		image
	)
end

function CardRiseCls:RefreshOldCradAttribute(color)
	-- 刷新旧属性面板
	local PropUtility = require "Utils.PropUtility"
	-- 颜色
	self.CardRiseOldCardColorBase.color = PropUtility.GetColorValue(color)

	-- 姓名
	self.CardRiseOldCardNameLabel.text = self.cardData:GetInfo()
	-- 等级
	self.CardRiseOldCardLvNumLabel.text = self.cardData:GetLv()
	-- 生命
	self.oldLife = self.cardData:GetHp()
	self.CardRiseOldCardPropertyLifeLabel.text = self.oldLife
	self.LifeOldSlider.size = self.oldLife / self.lifeMax
	-- 攻击
	self.oldAp = self.cardData:GetAp()
	self.CardRiseOldCardPropertyAttackLabel.text = self.oldAp
	self.AttackOldSlider.size = self.oldAp / self.apMax
	-- 防御
	self.oldDp = self.cardData:GetDp()
	self.CardRiseOldCardPropertyDefenseLabel.text = self.oldDp
	self.DefenseOldSlider.size = self.oldDp / self.dpMax
	-- 速度
	self.oldSpeed = self.cardData:GetSpeed()
	self.CardRiseOldCardPropertySpeedLabel.text = self.oldSpeed 
	self.SpeedOldSlider.size = self.oldSpeed / self.speedMax

	-- 战斗力
	self.oldPower = self.cardData:GetPower()
	self.CardRiseOldStrengthNumLabel.text = self.oldPower

	-- self.starCount = self.cardData:GetStar()
	-- SetStarShow(self,self.oldStars,self.starCount)

	SetMajorAttr(self,self.CardRiseOldCardAttributes)


	SetCardPortraitImage(self,self.CardRiseOldCardShow)

end

function CardRiseCls:RefreshNewCradAttribute(color)
	-- 刷新新属性面板
	local PropUtility = require "Utils.PropUtility"
	-- 颜色
	self.CardRiseNewCardColorBase.color = PropUtility.GetColorValue(color)

	-- 姓名
	self.CardRiseNewCardNameLabel.text = self.cardData:GetInfo()
	-- 等级
	self.CardRiseNewCardLvNumLabel.text = self.cardData:GetLv()

	local life,attack,defense,speed,power
	
	local addLife,addAttack,addDefense,addSpeed

	local stage = self.cardData:GetStage()

		if self.riseType == 1 then
			
			if stage > KCardStageMax then
				-- 达到顶阶		
				life = self.oldLife
				attack = self.oldAp
				defense = self.oldDp
				power = self.oldPower
			else

				life = self.cardData:GetNextStageHp()
				attack = self.cardData:GetNextStageAp()		
				defense = self.cardData:GetNextStageDp()
				power = self.cardData:GetNextStagePower()
			end
		elseif self.riseType == 2 then
		
			life = self.cardData:GetNextColorHp()
			attack = self.cardData:GetNextColorAp()
			defense = self.cardData:GetNextColorDp()
			power = self.cardData:GetNextColorPower()
		end


	speed = self.cardData:GetSpeed()

	self.CardRiseNewCardPropertyLifeLabel.text = life
	self.LifeNewSliderOld.size = self.oldLife / self.lifeMax

	self.CardRiseNewCardPropertyAttackLabel.text = attack
	self.AttackNewSliderOld.size = self.oldAp / self.apMax

	self.CardRiseNewCardPropertyDefenseLabel.text = defense
	self.DefenseNewSliderOld.size = self.oldDp / self.dpMax

	self.CardRiseNewCardPropertySpeedLabel.text = speed
	self.SpeedNewSliderOld.size = self.oldSpeed / self.speedMax


	-- 战斗力
	self.CardRiseNewStrengthNumLabel.text = power

	-- 增加的属性
	addLife = life  - self.oldLife
	addAttack = attack - self.oldAp
	addDefense = defense - self.oldDp
	
	self.addLife  = addLife
	self.addAttack = addAttack
	self.addDefense = addDefense
	self.addSpeed = 0

	if addLife > 0 then
		self.CardRiseNewCardPropertyAddLifeLabel.gameObject:SetActive(true)
		self.LifeNewSliderNew.gameObject:SetActive(true)
		self.CardRiseNewCardPropertyAddLifeLabel.text = addLife
		local percent = life / self.lifeMax
		self.LifeNewSliderNew.size = percent
	else
		self.CardRiseNewCardPropertyAddLifeLabel.gameObject:SetActive(false)
		self.LifeNewSliderNew.gameObject:SetActive(false)
	end

	if addAttack > 0 then
		self.CardRiseNewCardPropertyAddAttackLabel.gameObject:SetActive(true)
		self.AttackNewSliderNew.gameObject:SetActive(true)
		self.CardRiseNewCardPropertyAddAttackLabel.text = addAttack
		local percent = attack / self.apMax
		self.AttackNewSliderNew.size = percent
	else
		self.CardRiseNewCardPropertyAddAttackLabel.gameObject:SetActive(false)
		self.AttackNewSliderNew.gameObject:SetActive(false)
	end

	if addDefense > 0 then
		self.CardRiseNewCardPropertyAddDefenseLabel.gameObject:SetActive(true)
		self.DefenseNewSliderNew.gameObject:SetActive(true)
		self.CardRiseNewCardPropertyAddDefenseLabel.text = addDefense
		local percent = defense / self.dpMax
		self.DefenseNewSliderNew.size = percent
	else
		self.CardRiseNewCardPropertyAddDefenseLabel.gameObject:SetActive(false)
		self.DefenseNewSliderNew.gameObject:SetActive(false)
	end

	-- SetStarShow(self,self.newStars,self.starCount)
	SetMajorAttr(self,self.CardRiseNewCardAttributes)
	SetCardPortraitImage(self,self.CardRiseNewCardShow)

	----
	self.NewLife = life
	self.NewAp = attack
	self.NewDp = defense
	self.NewSpeed = speed
end


return CardRiseCls