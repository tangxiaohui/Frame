local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local CardRiseShowCls = Class(BaseNodeClass)
windowUtility.SetMutex(CardRiseShowCls, true)
function CardRiseShowCls:Ctor()
end

function CardRiseShowCls:OnWillShow(showType,cardData,oldInfo,newInfo)

    self.showType = showType
    self.cardData = cardData
    self.oldInfo = oldInfo
    self.newInfo = newInfo

    self:OnResetView()

end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function CardRiseShowCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/HeroUPgradeShow', function(go)
		self:BindComponent(go)
	end)
end

function CardRiseShowCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function CardRiseShowCls:OnResume()
	-- 界面显示时调用
	CardRiseShowCls.base.OnResume(self)
	self:RegisterControlEvents()
end

function CardRiseShowCls:OnPause()
	-- 界面隐藏时调用
	CardRiseShowCls.base.OnPause(self)
	self:UnregisterControlEvents()
end

function CardRiseShowCls:OnEnter()
	-- Node Enter时调用
	CardRiseShowCls.base.OnEnter(self)
end

function CardRiseShowCls:OnExit()
	-- Node Exit时调用
	CardRiseShowCls.base.OnExit(self)
end

function CardRiseShowCls:GetRootHangingPoint()
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
function CardRiseShowCls:InitControls()
	local transform = self:GetUnityTransform()

	self.CardRiseShowConfirmButton = transform:Find('CanvasUI/CardDrawResultBackButton'):GetComponent(typeof(UnityEngine.UI.Button))

	-- 头像
	self.oldHeadImage = transform:Find('CanvasUI/HeroCardItemOld/Base/CharacterIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.newHeadImage = transform:Find('CanvasUI/HeroCardItemNew/Base/CharacterIcon'):GetComponent(typeof(UnityEngine.UI.Image))

	-- 颜色
	self.oldColorFrame = transform:Find('CanvasUI/HeroCardItemOld/Base/Frame')
	self.newColorFrame = transform:Find('CanvasUI/HeroCardItemNew/Base/Frame')

	-- 等级
	self.oldLevelLabel = transform:Find('CanvasUI/HeroCardItemOld/Base/LeftBase/LevelLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.newLevelLabel = transform:Find('CanvasUI/HeroCardItemNew/Base/LeftBase/LevelLabel'):GetComponent(typeof(UnityEngine.UI.Text))

	-- 种族
	self.oldRaceImage = transform:Find('CanvasUI/HeroCardItemOld/Base/RaceIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.newRaceImage = transform:Find('CanvasUI/HeroCardItemNew/Base/RaceIcon'):GetComponent(typeof(UnityEngine.UI.Image))

	-- 星级
	self.oldStarFrame = transform:Find('CanvasUI/HeroCardItemNew/Base/CharacterStars')
	self.newStarFrame = transform:Find('CanvasUI/HeroCardItemNew/Base/CharacterStars')

	-- 生命
	self.oldLifeLabel = transform:Find('CanvasUI/StatusGroup/LifeLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.newLifeLabel = transform:Find('CanvasUI/StatusGroup/LifePlusLabel'):GetComponent(typeof(UnityEngine.UI.Text))

	-- 攻击
	self.oldApLabel = transform:Find('CanvasUI/StatusGroup/AttackLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.newApLabel = transform:Find('CanvasUI/StatusGroup/AttackPlusLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	
	-- 防御
	self.oldDpLabel = transform:Find('CanvasUI/StatusGroup/DEFLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.newDpLabel = transform:Find('CanvasUI/StatusGroup/DEFPlusLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	
	-- 速度
	self.oldSpeedLabel = transform:Find('CanvasUI/StatusGroup/SPDLabe'):GetComponent(typeof(UnityEngine.UI.Text))
	self.newSpeedLabel = transform:Find('CanvasUI/StatusGroup/SPDPlusLabel'):GetComponent(typeof(UnityEngine.UI.Text))

	-- 品阶
	self.oldStageLabel = transform:Find('CanvasUI/HeroCardItemOld/Base/EnhancedLabe'):GetComponent(typeof(UnityEngine.UI.Text))
	self.newStageLabel = transform:Find('CanvasUI/HeroCardItemNew/Base/EnhancedLabe'):GetComponent(typeof(UnityEngine.UI.Text))

	-- 
	local effectCanvas = transform:Find('Canvas_EffectFaZhen'):GetComponent(typeof(UnityEngine.RectTransform))
	utility.SetRectDefaut(effectCanvas)
end


function CardRiseShowCls:RegisterControlEvents()
	-- 注册 CardRiseShowConfirmButton 的事件
	self.__event_button_onCardRiseShowConfirmButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCardRiseShowConfirmButtonClicked, self)
	self.CardRiseShowConfirmButton.onClick:AddListener(self.__event_button_onCardRiseShowConfirmButtonClicked__)
end

function CardRiseShowCls:UnregisterControlEvents()
	-- 取消注册 CardRiseShowConfirmButton 的事件
	if self.__event_button_onCardRiseShowConfirmButtonClicked__ then
		self.CardRiseShowConfirmButton.onClick:RemoveListener(self.__event_button_onCardRiseShowConfirmButtonClicked__)
		self.__event_button_onCardRiseShowConfirmButtonClicked__ = nil
	end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function CardRiseShowCls:OnCardRiseShowConfirmButtonClicked()
	--CardRiseShowConfirmButton控件的点击事件处理
	self:Close()
end

local function OnDelayResetView(self)
	while (not self:IsReady()) do
		coroutine.step(1)
	end

	local oldStage = ""
	local newStage = 1
	if self.showType == 1 then
		--self.TilteLabel.text = "完成进阶"
		oldStage = self.oldInfo.stage
		newStage = self.newInfo.nextStage
	else
		--self.TilteLabel.text = "完成升品"
	end

	if oldStage ~= 0 then
		oldStage = string.format("%s%s","+",oldStage)
	end

	self.oldStageLabel.text = oldStage
	self.newStageLabel.text = string.format("%s%s","+",newStage)

	local gametool = require "Utils.GameTools"
	local PropUtility = require "Utils.PropUtility"

	local id = self.cardData:GetId()
	local _,sateticData,_,iconPath = gametool.GetItemDataById(id)

	utility.LoadSpriteFromPath(iconPath,self.oldHeadImage)
	utility.LoadSpriteFromPath(iconPath,self.newHeadImage)

	PropUtility.AutoSetColor(self.oldColorFrame,self.oldInfo.color)
	PropUtility.AutoSetColor(self.newColorFrame,self.newInfo.color)

	local rece = sateticData:GetRace()
	utility.LoadRaceIcon(rece,self.oldRaceImage)
	utility.LoadRaceIcon(rece, self.newRaceImage)

	local star = sateticData:GetStar()
	gametool.AutoSetStar(self.oldStarFrame,star)
	gametool.AutoSetStar(self.newStarFrame,star)

	local level = self.cardData:GetLv()
	self.oldLevelLabel.text = level
	self.newLevelLabel.text = level

	self.oldLifeLabel.text = string.format("%s%s","生命： ",self.oldInfo.life)
	self.newLifeLabel.text = self.newInfo.life

	self.oldApLabel.text = string.format("%s%s","攻击： ",self.oldInfo.ap)
	self.newApLabel.text = self.newInfo.ap

	self.oldDpLabel.text = string.format("%s%s","防御： ",self.oldInfo.dp)
	self.newDpLabel.text = self.newInfo.dp

	self.oldSpeedLabel.text = string.format("%s%s","速度： ",self.oldInfo.speed)
	self.newSpeedLabel.text = self.newInfo.speed
end


function CardRiseShowCls:OnResetView()
	-- coroutine.start(OnDelayResetView,self)
	self:StartCoroutine(OnDelayResetView)
end



return CardRiseShowCls