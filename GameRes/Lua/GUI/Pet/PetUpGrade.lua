local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
require "LUT.StringTable"
require "Const"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local PetUpGrade = Class(BaseNodeClass)

function PetUpGrade:Ctor()
end

-----------------------------------------------------------------------
--- 场景状态     进阶
-----------------------------------------------------------------------
function PetUpGrade:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/PetUpGrade', function(go)
		self:BindComponent(go)
	end)
end
function PetUpGrade:OnWillShow(cardID,itemID)
	print(itemID)
	self.itemID=itemID
	self.cardID=cardID
end
function PetUpGrade:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function PetUpGrade:OnResume()
	-- 界面显示时调用
	PetUpGrade.base.OnResume(self)
	self:RegisterControlEvents()
	self:InitViews()
	--self:RegisterNetworkEvents()
end

function PetUpGrade:OnPause()
	-- 界面隐藏时调用
	PetUpGrade.base.OnPause(self)
	self:UnregisterControlEvents()
	--self:UnregisterNetworkEvents()
end

function PetUpGrade:OnEnter()
	-- Node Enter时调用
	PetUpGrade.base.OnEnter(self)
end

function PetUpGrade:OnExit()
	-- Node Exit时调用
	PetUpGrade.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function PetUpGrade:InitControls()
	local transform = self:GetUnityTransform()
	--返回按钮
	self.WingsReturnButton = transform:Find('WingsReturnButton'):GetComponent(typeof(UnityEngine.UI.Button))
	--头像
	self.WingsCardInfoCardFace = transform:Find('WingsCardInfo/WingsCardInfoCardFace'):GetComponent(typeof(UnityEngine.UI.Image))
	--名字
	self.WingsCardInfoNameLabel = transform:Find('WingsCardInfo/WingsCardInfoNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--增加
	self.WingsCardInfoPowerupLabe = transform:Find('WingsCardInfo/WingsCardInfoPowerupLabe'):GetComponent(typeof(UnityEngine.UI.Text))
	--宠物类型
	self.WingsCardInfoTypeLi = transform:Find('WingsCardInfo/WingsCardInfoType'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsCardInfoTypeLi.enabled=false
	self.WingsCardInfoTypeZhi = transform:Find('WingsCardInfo/WingsCardInfoType (1)'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsCardInfoTypeZhi.enabled=false
	self.WingsCardInfoTypeMin = transform:Find('WingsCardInfo/WingsCardInfoType (2)'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsCardInfoTypeMin.enabled=false
	--星级
	self.starIcon={}
	self.starIcon[1] = transform:Find('WingsCardInfo/WingsCardInfoRankLayout/WingsCardInfoStarIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.starIcon[2] = transform:Find('WingsCardInfo/WingsCardInfoRankLayout/WingsCardInfoStarIcon (1)'):GetComponent(typeof(UnityEngine.UI.Image))
	self.starIcon[3] = transform:Find('WingsCardInfo/WingsCardInfoRankLayout/WingsCardInfoStarIcon (2)'):GetComponent(typeof(UnityEngine.UI.Image))
	self.starIcon[4] = transform:Find('WingsCardInfo/WingsCardInfoRankLayout/WingsCardInfoStarIcon (3)'):GetComponent(typeof(UnityEngine.UI.Image))
	self.starIcon[5] = transform:Find('WingsCardInfo/WingsCardInfoRankLayout/WingsCardInfoStarIcon (4)'):GetComponent(typeof(UnityEngine.UI.Image))
	for i=1,#self.starIcon do
		self.starIcon[i].enabled=false
	end


	--等级
	self.WingsCardInfoLvNuLabel = transform:Find('WingsCardInfo/WingsCardInfoLv/WingsCardInfoLvNuLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	
	--生命
	self.CardHp = transform:Find('WingsCardInfo/WingsCardInfoStatusLabel/Scroll View/Viewport/Content/01Life/01LifeWingsCardInfoStatusLifeLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.CardHpImage = transform:Find('WingsCardInfo/WingsCardInfoStatusLabel/Scroll View/Viewport/Content/01Life/01LifeSlider'):GetComponent(typeof(UnityEngine.UI.Image))
	
	--攻击
	self.CradAttack = transform:Find('WingsCardInfo/WingsCardInfoStatusLabel/Scroll View/Viewport/Content/02Attack/02AttackWingsCardInfoStatusAttackLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.CradAttackImage = transform:Find('WingsCardInfo/WingsCardInfoStatusLabel/Scroll View/Viewport/Content/02Attack/02AttackSlider'):GetComponent(typeof(UnityEngine.UI.Image))
	--防御
	self.CardDefense = transform:Find('WingsCardInfo/WingsCardInfoStatusLabel/Scroll View/Viewport/Content/03Defense/03DefenseWingsCardInfoStatusDefenseLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.CardDefenseImage = transform:Find('WingsCardInfo/WingsCardInfoStatusLabel/Scroll View/Viewport/Content/03Defense/03DefenseSlider'):GetComponent(typeof(UnityEngine.UI.Image))
	--速度
	self.CardSpeedImage = transform:Find('WingsCardInfo/WingsCardInfoStatusLabel/Scroll View/Viewport/Content/04Speed/04SpeedSlider'):GetComponent(typeof(UnityEngine.UI.Image))
	self.CardSpeed = transform:Find('WingsCardInfo/WingsCardInfoStatusLabel/Scroll View/Viewport/Content/04Speed/04SpeedWingsCardInfoStatusSpeedLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--暴击
	self.CardCrit = transform:Find('WingsCardInfo/WingsCardInfoStatusLabel/Scroll View/Viewport/Content/05Crit/05CritWingsCardInfoStatusCritLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.CardCritImage = transform:Find('WingsCardInfo/WingsCardInfoStatusLabel/Scroll View/Viewport/Content/05Crit/05CritSlider'):GetComponent(typeof(UnityEngine.UI.Image))
	--暴抗
	self.CardResistCrit = transform:Find('WingsCardInfo/WingsCardInfoStatusLabel/Scroll View/Viewport/Content/06ResistCrit/06ResistCritWingsCardInfoStatusResistLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.CardResistCritImage = transform:Find('WingsCardInfo/WingsCardInfoStatusLabel/Scroll View/Viewport/Content/06ResistCrit/06ResistCritSlider'):GetComponent(typeof(UnityEngine.UI.Image))
	--命中
	self.CardHitRate = transform:Find('WingsCardInfo/WingsCardInfoStatusLabel/Scroll View/Viewport/Content/07HitRate/07HitRateWingsCardInfoStatusHitRateLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.CardHitRateImage = transform:Find('WingsCardInfo/WingsCardInfoStatusLabel/Scroll View/Viewport/Content/07HitRate/07HitRateSlider'):GetComponent(typeof(UnityEngine.UI.Image))
	--闪避
	self.CardDodge = transform:Find('WingsCardInfo/WingsCardInfoStatusLabel/Scroll View/Viewport/Content/08Dodge/08DodgeWingsCardInfoStatusDodgeLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.CardDodgeImage = transform:Find('WingsCardInfo/WingsCardInfoStatusLabel/Scroll View/Viewport/Content/08Dodge/08DodgeSlider'):GetComponent(typeof(UnityEngine.UI.Image))


	self.WingsUpgradeEquipInfoBase1 = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase1'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsUpgradeEquipInfobox = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase1/WingsUpgradeEquipInfobox'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsUpgradeEquipInfoside1 = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase1/WingsUpgradeEquipInfobox/WingsUpgradeEquipInfoside1'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsUpgradeEquipInfoside2 = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase1/WingsUpgradeEquipInfobox/WingsUpgradeEquipInfoside2'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsUpgradeEquipInfoboxItself = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase1/WingsUpgradeEquipInfobox/WingsUpgradeEquipInfoboxItself'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsUpgradeEquipInfoDecoration1 = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase1/WingsUpgradeEquipInfobox/WingsUpgradeEquipInfoDecoration1'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsUpgradeEquipInfoDecoration2 = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase1/WingsUpgradeEquipInfobox/WingsUpgradeEquipInfoDecoration2'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsUpgradeEquipInfoGeneralItemBase = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase1/WingsUpgradeEquipInfoGeneralItem /WingsUpgradeEquipInfoGeneralItemBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsUpgradeEquipInfoGeneralItemFarme012 = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase1/WingsUpgradeEquipInfoGeneralItem /WingsUpgradeEquipInfoFarme/WingsUpgradeEquipInfoGeneralItemFarme012'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsUpgradeEquipInfoGeneralItemFarme023 = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase1/WingsUpgradeEquipInfoGeneralItem /WingsUpgradeEquipInfoFarme/WingsUpgradeEquipInfoGeneralItemFarme023'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsUpgradeEquipInfoGeneralItemFarme033 = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase1/WingsUpgradeEquipInfoGeneralItem /WingsUpgradeEquipInfoFarme/WingsUpgradeEquipInfoGeneralItemFarme033'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsUpgradeEquipInfoGeneralItemFarme043 = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase1/WingsUpgradeEquipInfoGeneralItem /WingsUpgradeEquipInfoFarme/WingsUpgradeEquipInfoGeneralItemFarme043'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsUpgradeEquipInfoFrame = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase1/WingsUpgradeEquipInfoMaterialNuSlider/WingsUpgradeEquipInfoFrame'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsUpgradeEquipInfoMaterialNuSliderMask = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase1/WingsUpgradeEquipInfoMaterialNuSlider/WingsUpgradeEquipInfoMaterialNuSliderMask'):GetComponent(typeof(UnityEngine.UI.Mask))
	self.WingsUpgradeEquipInfoBase2 = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase2'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsUpgradeEquipInfoShadowBaseforTypenName = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase2/WingsUpgradeEquipInfoUpgradeOldWings/WingsUpgradeEquipInfoShadowBaseforTypenName'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsUpgradeEquipInfoTypeOldWings = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase2/WingsUpgradeEquipInfoUpgradeOldWings/WingsUpgradeEquipInfoShadowBaseforTypenName/WingsUpgradeEquipInfoTypeOldWings'):GetComponent(typeof(UnityEngine.UI.Image))
	
	--进阶所需物品的名字
	self.WingsUpgradeEquipInfoMaterialyouNeed = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase1/WingsUpgradeEquipInfoMaterialyouNeed'):GetComponent(typeof(UnityEngine.UI.Text))
	--进阶所需物品的数量
	self.WingsUpgradeEquipInfoMaterialNuLabel = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase1/WingsUpgradeEquipInfoMaterialNuSlider/WingsUpgradeEquipInfoMaterialNuLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	---进阶所需物品颜色
	self.WingsUpgradeEquipInfoGeneralItemNeedFarme= transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase1/WingsUpgradeEquipInfoGeneralItem /WingsUpgradeEquipInfoFarme')
	--进阶为物品的Icon
	self.WingsUpgradeEquipInfoGeneralItemIcon2 = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase1/WingsUpgradeEquipInfoGeneralItem /WingsUpgradeEquipInfoGeneralItemIcon2'):GetComponent(typeof(UnityEngine.UI.Image))
	--进阶为物品的slider
	self.WingsUpgradeEquipInfoFillFrame = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase1/WingsUpgradeEquipInfoMaterialNuSlider/WingsUpgradeEquipInfoMaterialNuSliderMask/WingsUpgradeEquipInfoFillFrame'):GetComponent(typeof(UnityEngine.UI.Image))


	--宠物名字
	self.WingsUpgradeEquipInfoWingOldName = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase2/WingsUpgradeEquipInfoUpgradeOldWings/WingsUpgradeEquipInfoShadowBaseforTypenName/WingsUpgradeEquipInfoWingOldName'):GetComponent(typeof(UnityEngine.UI.Text))
	--宠物描述
	self.WingsUpgradeEquipInfoWingsOldStatusLabel = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase2/WingsUpgradeEquipInfoUpgradeOldWings/WingsUpgradeEquipInfoShadowBox/WingsUpgradeEquipInfoWingsOldStatusLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--宠物星级
	self.WingsUpgradeEquipInfoItemRank = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase2/WingsUpgradeEquipInfoUpgradeOldWings/WingsUpgradeEquipInfoBigItemIcon/WingsUpgradeEquipInfoItemRank')
	--宠物当前颜色等级
	self.WingsUpgradeOldEquipInfoFrameBase = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase2/WingsUpgradeEquipInfoUpgradeOldWings/WingsUpgradeEquipInfoBigItemIcon/WingsUpgradeEquipInfoFarme2')

	--宠物进阶之后的名称
	self.WingsUpgradeEquipInfoWingNewName = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase2/WingsUpgradeEquipInfoUpgradeNewWings/WingsUpgradeEquipInfoShadowBaseforTypenName1/WingsUpgradeEquipInfoWingNewName'):GetComponent(typeof(UnityEngine.UI.Text))
		--宠物进阶之后的头像
	self.WingsUpgradeEquipInfoGeneralItemIcon = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase2/WingsUpgradeEquipInfoUpgradeNewWings/WingsUpgradeEquipInfoBigNewItemIcon/WingsUpgradeEquipInfoGeneralItemIcon'):GetComponent(typeof(UnityEngine.UI.Image))


	--宠物进阶之后的颜色
	self.WingsUpgradeEquipInfoGeneralNewFarme = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase2/WingsUpgradeEquipInfoUpgradeNewWings/WingsUpgradeEquipInfoBigNewItemIcon/WingsUpgradeEquipInfoFarme1')
	--宠物进阶之后的星级
	self.WingsUpgradeEquipInfoItemRank1 = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase2/WingsUpgradeEquipInfoUpgradeNewWings/WingsUpgradeEquipInfoBigNewItemIcon/WingsUpgradeEquipInfoItemRank1')

	--宠物进阶之后的描述
	self.WingsUpgradeEquipInfoWingsNewStatusLabel = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase2/WingsUpgradeEquipInfoUpgradeNewWings/WingsUpgradeEquipInfoShadowBox1/WingsUpgradeEquipInfoWingsNewStatusLabel'):GetComponent(typeof(UnityEngine.UI.Text))


	self.WingsUpgradeEquipInfoBase = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase2/WingsUpgradeEquipInfoUpgradeOldWings/WingsUpgradeEquipInfoBigItemIcon/WingsUpgradeEquipInfoBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsUpgradeEquipInfoGeneralItemIcon1 = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase2/WingsUpgradeEquipInfoUpgradeOldWings/WingsUpgradeEquipInfoBigItemIcon/WingsUpgradeEquipInfoGeneralItemIcon1'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsUpgradeEquipInfoGeneralItemFarme013 = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase2/WingsUpgradeEquipInfoUpgradeOldWings/WingsUpgradeEquipInfoBigItemIcon/WingsUpgradeEquipInfoFarme2/WingsUpgradeEquipInfoGeneralItemFarme013'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsUpgradeEquipInfoGeneralItemFarme022 = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase2/WingsUpgradeEquipInfoUpgradeOldWings/WingsUpgradeEquipInfoBigItemIcon/WingsUpgradeEquipInfoFarme2/WingsUpgradeEquipInfoGeneralItemFarme022'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsUpgradeEquipInfoGeneralItemFarme032 = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase2/WingsUpgradeEquipInfoUpgradeOldWings/WingsUpgradeEquipInfoBigItemIcon/WingsUpgradeEquipInfoFarme2/WingsUpgradeEquipInfoGeneralItemFarme032'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsUpgradeEquipInfoGeneralItemFarme042 = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase2/WingsUpgradeEquipInfoUpgradeOldWings/WingsUpgradeEquipInfoBigItemIcon/WingsUpgradeEquipInfoFarme2/WingsUpgradeEquipInfoGeneralItemFarme042'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsUpgradeEquipInfoStar = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase2/WingsUpgradeEquipInfoUpgradeOldWings/WingsUpgradeEquipInfoBigItemIcon/WingsUpgradeEquipInfoItemRank/WingsUpgradeEquipInfoStar'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsUpgradeEquipInfoStar__1_ = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase2/WingsUpgradeEquipInfoUpgradeOldWings/WingsUpgradeEquipInfoBigItemIcon/WingsUpgradeEquipInfoItemRank/WingsUpgradeEquipInfoStar (1)'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsUpgradeEquipInfoStar__2_ = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase2/WingsUpgradeEquipInfoUpgradeOldWings/WingsUpgradeEquipInfoBigItemIcon/WingsUpgradeEquipInfoItemRank/WingsUpgradeEquipInfoStar (2)'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsUpgradeEquipInfoStar__3_ = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase2/WingsUpgradeEquipInfoUpgradeOldWings/WingsUpgradeEquipInfoBigItemIcon/WingsUpgradeEquipInfoItemRank/WingsUpgradeEquipInfoStar (3)'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsUpgradeEquipInfoStar__4_ = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase2/WingsUpgradeEquipInfoUpgradeOldWings/WingsUpgradeEquipInfoBigItemIcon/WingsUpgradeEquipInfoItemRank/WingsUpgradeEquipInfoStar (4)'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsUpgradeEquipInfoShadowBox = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase2/WingsUpgradeEquipInfoUpgradeOldWings/WingsUpgradeEquipInfoShadowBox'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsUpgradeEquipInfoArrowShowResult = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase2/WingsUpgradeEquipInfoArrowShowResult'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsUpgradeEquipInfoShadowBaseforTypenName1 = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase2/WingsUpgradeEquipInfoUpgradeNewWings/WingsUpgradeEquipInfoShadowBaseforTypenName1'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsUpgradeEquipInfoTypeNewWings = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase2/WingsUpgradeEquipInfoUpgradeNewWings/WingsUpgradeEquipInfoShadowBaseforTypenName1/WingsUpgradeEquipInfoTypeNewWings'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsUpgradeEquipInfoBigItemIconBase = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase2/WingsUpgradeEquipInfoUpgradeNewWings/WingsUpgradeEquipInfoBigNewItemIcon/WingsUpgradeEquipInfoBigItemIconBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsUpgradeEquipInfoGeneralItemFarme011 = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase2/WingsUpgradeEquipInfoUpgradeNewWings/WingsUpgradeEquipInfoBigNewItemIcon/WingsUpgradeEquipInfoFarme1/WingsUpgradeEquipInfoGeneralItemFarme011'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsUpgradeEquipInfoGeneralItemFarme021 = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase2/WingsUpgradeEquipInfoUpgradeNewWings/WingsUpgradeEquipInfoBigNewItemIcon/WingsUpgradeEquipInfoFarme1/WingsUpgradeEquipInfoGeneralItemFarme021'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsUpgradeEquipInfoGeneralItemFarme031 = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase2/WingsUpgradeEquipInfoUpgradeNewWings/WingsUpgradeEquipInfoBigNewItemIcon/WingsUpgradeEquipInfoFarme1/WingsUpgradeEquipInfoGeneralItemFarme031'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsUpgradeEquipInfoGeneralItemFarme041 = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase2/WingsUpgradeEquipInfoUpgradeNewWings/WingsUpgradeEquipInfoBigNewItemIcon/WingsUpgradeEquipInfoFarme1/WingsUpgradeEquipInfoGeneralItemFarme041'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsUpgradeEquipInfoStar1 = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase2/WingsUpgradeEquipInfoUpgradeNewWings/WingsUpgradeEquipInfoBigNewItemIcon/WingsUpgradeEquipInfoItemRank1/WingsUpgradeEquipInfoStar1'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsUpgradeEquipInfoStar__1_1 = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase2/WingsUpgradeEquipInfoUpgradeNewWings/WingsUpgradeEquipInfoBigNewItemIcon/WingsUpgradeEquipInfoItemRank1/WingsUpgradeEquipInfoStar (1)1'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsUpgradeEquipInfoStar__2_1 = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase2/WingsUpgradeEquipInfoUpgradeNewWings/WingsUpgradeEquipInfoBigNewItemIcon/WingsUpgradeEquipInfoItemRank1/WingsUpgradeEquipInfoStar (2)1'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsUpgradeEquipInfoStar__3_1 = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase2/WingsUpgradeEquipInfoUpgradeNewWings/WingsUpgradeEquipInfoBigNewItemIcon/WingsUpgradeEquipInfoItemRank1/WingsUpgradeEquipInfoStar (3)1'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsUpgradeEquipInfoStar__4_1 = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase2/WingsUpgradeEquipInfoUpgradeNewWings/WingsUpgradeEquipInfoBigNewItemIcon/WingsUpgradeEquipInfoItemRank1/WingsUpgradeEquipInfoStar (4)1'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsUpgradeEquipInfoShadowBox1 = transform:Find('WingsUpgradeEquipInfo/WingsUpgradeEquipInfoBase2/WingsUpgradeEquipInfoUpgradeNewWings/WingsUpgradeEquipInfoShadowBox1'):GetComponent(typeof(UnityEngine.UI.Image))
	self.CoinYouNeedText = transform:Find('WingsGetupPrice/CoinYouNeedText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.CoinIcon = transform:Find('WingsGetupPrice/CoinIcon'):GetComponent(typeof(UnityEngine.UI.Image))

	---升级所需要的金钱数目
	self.WingsGetupPriceLabel = transform:Find('WingsGetupPrice/WingsGetupPriceLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.GetupButtonBase = transform:Find('GetupButtonBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.UpgradeButton = transform:Find('UpgradeButton'):GetComponent(typeof(UnityEngine.UI.Button))
end
-----------------
--初始化显示-----
-----------------
function PetUpGrade:InitViews()
	-- local role = require"StaticData/Role":GetData(self.cardID)
	-- print(role:GetStar(),"++++++++++++++++++++++++++++++++++++++")

	-- local _,data,itemName =  require "Utils.GameTools".GetItemDataById(self.cardID)
	self:InitCardInfo()
	self:InitPetInfo()
end

--初始化宠物显示
function PetUpGrade:InitPetInfo()

	self:InitPetCurrentInfo()
	self:InitPetUpGradeInfo()
	self:InitPetUpGradeNeedInfo()

end

--初始化进阶之后显示
function PetUpGrade:InitPetUpGradeInfo()
	-- body	
	local gameTool = require "Utils.GameTools"
	local AtlasesLoader = require "Utils.AtlasesLoader"
	local PropUtility = require "Utils.PropUtility" 
	self.staticData = require "StaticData.EquipPetsUp":GetData(self.currentColor+1)
	local equipData = require "StaticData.Equip":GetData(self.staticData:GetDisplayId())



	if self.currentColor<4 then
	
		--升级之后的ID
		local upGradeId = self.staticData:GetDisplayId()
		-- local equipInfoData = require "StaticData.EquipInfo":GetData(upGradeId)
		-- print(equipData:GetInfo())
		
		local infodata,data,name,itemIconPath,ItemType = gameTool.GetItemDataById(upGradeId)
		--print(equipInfoData:GetDesc(),equipInfoData:GetName())
		--进阶之后的名字
		self.WingsUpgradeEquipInfoWingNewName.text=':'..name--equipInfoData:GetName()		
		--进阶花费
		self.WingsGetupPriceLabel.text=self.staticData:GetCost()
		--进阶之后的描述
		self.WingsUpgradeEquipInfoWingsNewStatusLabel.text="随机宠物"
	 	utility.LoadSpriteFromPath(itemIconPath,self.WingsUpgradeEquipInfoGeneralItemIcon)
	 	--进阶之后的星级
	 	local star = equipData:GetStarID()
	 	gameTool.AutoSetStar(self.WingsUpgradeEquipInfoItemRank1,star)
	 	--进阶之后的颜色
	 	local color = equipData:GetColorID()
	 	PropUtility.AutoSetColor(self.WingsUpgradeEquipInfoGeneralNewFarme,color)

	 	---------------------------进阶需要的物品--------------------------------
	 	local needItemId =self.staticData:GetItemId()
	 	local needInfodata,needData,needName,needNtemIconPath,needItemType = gameTool.GetItemDataById(needItemId)
		self.WingsUpgradeEquipInfoMaterialyouNeed.text=needName

		local UserDataType = require "Framework.UserDataType"	
	
		local itemBagData = self:GetCachedData(UserDataType.ItemBagData)
		local needNum = self.staticData:GetNeedNum()
		local ownNum = itemBagData:GetItemCountById(needItemId)
		self.WingsUpgradeEquipInfoMaterialNuLabel.text=ownNum..'/'..needNum
		self.WingsUpgradeEquipInfoFillFrame.fillAmount=ownNum/needNum

		
		equipData=require "StaticData.Item":GetData(needItemId)
		--进阶所需物品的颜色
	 	local color = equipData:GetColor()
	 	PropUtility.AutoSetColor(self.WingsUpgradeEquipInfoGeneralItemNeedFarme,color)
	 	--进阶所需物品的Icon
	 	utility.LoadSpriteFromPath(needNtemIconPath,self.WingsUpgradeEquipInfoGeneralItemIcon2)



		else
			self.WingsGetupPriceLabel.text=""
			self.WingsUpgradeEquipInfoWingsNewStatusLabel.text="已经达到满阶"
			print("当前宠物已经进阶满")
			self.UpgradeButton.interactable=false
		end


	
end

--初始化进阶需要的物品
function PetUpGrade:InitPetUpGradeNeedInfo(itemID,num)
	-- body
	
	-- if self.currentColor<4 then
	-- 	local staticData = require "StaticData.EquipPetsUp":GetData(self.currentColor+1)
	-- 	print(staticData:GetColor(),staticData:GetCost())
	-- 	self.WingsGetupPriceLabel.text=staticData:GetCost()

	-- 	local equipData = require "StaticData.Equip":GetData(staticData:GetDisplayId())
	-- 	print(equipData:GetInfo())

		

	-- 	local equipInfoData = require "StaticData.EquipInfo":GetData(staticData:GetDisplayId())
	-- 	print(equipInfoData:GetDesc(),equipInfoData:GetName())


	-- else
	-- 	self.WingsGetupPriceLabel.text=""
	-- 	print("当前宠物已经进阶满")
	-- end

end


--初始化宠物当前信息显示
function PetUpGrade:InitPetCurrentInfo()

	local UserDataType = require "Framework.UserDataType"	
	local data,count
	local tempData = self:GetCachedData(UserDataType.EquipBagData)
    data = tempData:RetrievalByResultFunc(function(item)
       local itemType = item:GetEquipType()
	 
       if  itemType == KEquipType_EquipPet then
	  
          local uid = item:GetEquipUID()
		   print(uid,"/////////++++++++++")
          return true,uid
        end

        return nil 
      end,itemDataDict)

--	print(data:GetKeyFromIndex(1))
----------暂时取第一个宠物--------------

 	 local bagData = self:GetCachedData(UserDataType.EquipBagData)
	 local petData = bagData:GetItem(data:GetKeyFromIndex(1))
	 print(petData:GetName(),petData:GetEquipID())
	 self.WingsUpgradeEquipInfoWingOldName.text=petData:GetName()
	---设置装被属性
	 local attributeDict = petData:GetEquipAttribute()
	 self:SetItemDisInfoText(attributeDict,petData:GetEquipID())
	 -----设置头像------
	local gameTool = require "Utils.GameTools"
	local AtlasesLoader = require "Utils.AtlasesLoader"
	 local PropUtility = require "Utils.PropUtility" 

	local infodata,data,name,itemIconPath,ItemType = gameTool.GetItemDataById(petData:GetEquipID())
 	utility.LoadSpriteFromPath(itemIconPath,self.WingsUpgradeEquipInfoGeneralItemIcon1)

 	local star = petData:GetStar()
 	gameTool.AutoSetStar(self.WingsUpgradeEquipInfoItemRank,star)

 	self.currentColor = gameTool.GetItemColorByType(ItemType,data)
 	PropUtility.AutoSetColor(self.WingsUpgradeOldEquipInfoFrameBase,self.currentColor)

	print(color,";;;;;;;;;;;;;;;;;;;;;;;;")
	


end

local function UpdatePropValue(key,value)
  -- 判断是否为百分比
  local temp 
  if key == kPropertyID_CritRate or key == kPropertyID_DecritRate or key == kPropertyID_HitRate
           or key == kPropertyID_AvoidRate or key == kPropertyID_CritDamageRate then
    temp = value.."%" 
  else
    temp = value
  end

  return temp
end
function PetUpGrade:SetItemDisInfoText(currItemAttributeDict,id)
	-- 设置item 属性信息文字
	
	-- 显示Str
	local str = ""
	-- 固定Str
	local fixedStr
  local fixedAddStr = EquipStringTable[0]
  local fixedSubStr = EquipStringTable[16]

	local keys = currItemAttributeDict:GetKeys()
	
	for i = 1 ,#keys do

		local key = keys[i]
		local additionValue = currItemAttributeDict:GetEntryByKey(key)

		local tempStr = EquipStringTable[key]
    if additionValue >= 0 then
      fixedStr = fixedAddStr
    else
      fixedStr = fixedSubStr
    end
    
    additionValue = UpdatePropValue(key,additionValue)

		local tempHintStr = string.format(fixedStr,tempStr,additionValue)

		str = str..tempHintStr	
		print(str)
	end

	print(id)
  local staticData = require "StaticData.Equip":GetData(id)
  print("888888888888888888888888888888888888888888888888888888")
  -- 是否有种族加成
  local raceAdd = staticData:GetRaceAdd()
  if raceAdd ~= 0 then
    local raceStaticData = require "StaticData.EquipRace":GetData(id)
    local raceID = raceStaticData:GetRaceID()
    local raceName = Race[raceID]
    local addPropID = raceStaticData:GetAddPropID()
    local propName = EquipStringTable[addPropID]
    local value = raceStaticData:GetAddPropValue()
    local propValue = UpdatePropValue(addPropID,value)
    local tempStr = string.format(EquipStringTable[27],raceName,propName,propValue)
    str = str..tempStr
  end

  -- 是否有羁绊英雄
  local comrade = staticData:GetZhuanyou()
  if comrade ~= 0 then
    local comradeStaticData = require "StaticData.EquipExclusive":GetData(id)
    local jibanCardID = comradeStaticData:GetJibanCardID()

    local nameStr = ""
    local roleInfoStaticDataCls = require "StaticData.RoleInfo"

    for i = 0 ,jibanCardID.Count -1 do
      local name = roleInfoStaticDataCls:GetData(jibanCardID[i]):GetName()
      nameStr = string.format("%s%s",nameStr,name)
      
      if i < jibanCardID.Count -1 then
        nameStr = string.format("%s%s",nameStr,",")
      end
    end

    local addPropID = comradeStaticData:GetJibanAddPropID()
    local addPropStr = EquipStringTable[addPropID]

    local addValue = comradeStaticData:GetAddPropValue()
    local tempStr = string.format(EquipStringTable[27],nameStr,addPropStr,addValue)
    str = str..tempStr
  end

  -- 是否禁止怒气释放
  local stopJigong = staticData:GetStopJigong()
  if stopJigong ~= 0 then
    local tempStr = EquipStringTable[30]
    str = str..tempStr
  end

  self.WingsUpgradeEquipInfoWingsOldStatusLabel.text = str
end




--初始化卡牌显示
function PetUpGrade:InitCardInfo()
	
    local UserDataType = require "Framework.UserDataType"
    local cardBagData = self:GetCachedData(UserDataType.CardBagData)
    local userRoleData = cardBagData:GetRoleById(self.cardID)
    require "Game.Role"
    if userRoleData == nil then
        userRoleData = Role.New()
        userRoleData:UpdateForStatic(data:GetId(), 1, 1)
    end
   	
	self.heroData = userRoleData
   --print(self.heroData,self.heroData:GetLv(),self.heroData:GetStage(),self.heroData:GetPortraitImage())

	utility.LoadRolePortraitImage(
		self.heroData:GetId(),
		self.WingsCardInfoCardFace
	)

    for i=1,self.heroData:GetStar() do
    	self.starIcon[i].enabled=true
    end
    self.WingsCardInfoNameLabel.text=self.heroData:GetInfo()
    --等级
	self.WingsCardInfoLvNuLabel.text=self.heroData:GetLv()

	
	--人物品节
	self.WingsCardInfoPowerupLabe.text=self.heroData:GetStage()
	--显示力智敏
	self:UpdateCardAttributeIcon()
	self:UpdateCardBasisInfo()

end
-------------------------------------------------
---------更新人物血条等
-----------------------------------------------------
function PetUpGrade:UpdateCardBasisInfo()
	--获取任务信息常量 
	local mgr = require "StaticData.SystemConfig.SystemConfig"
	self.lifeMax = mgr:GetData(1001):GetParameNum()[0]
	self.apMax = mgr:GetData(1002):GetParameNum()[0]
	self.dpMax = mgr:GetData(1003):GetParameNum()[0]
	--self.dpMax = 1000
	self.speedMax = mgr:GetData(1004):GetParameNum()[0]

	self.critMax = mgr:GetData(1005):GetParameNum()[0]
	self.resistCritMax = mgr:GetData(1006):GetParameNum()[0]
	self.hitRateMax = mgr:GetData(1007):GetParameNum()[0]
	--self.dpMax = 1000
	self.dodgeMax = mgr:GetData(1008):GetParameNum()[0]
	--生命
	local hp = self.heroData:GetHp()
	self.CardHp.text =hp
	self.CardHpImage.fillAmount =hp/self.lifeMax	
	--攻击
	local ap = self.heroData:GetAp()
	self.CradAttack.text =ap
	self.CradAttackImage.fillAmount =ap/self.apMax	
	--防御
	local dp = self.heroData:GetDp()
	self.CardDefense.text = dp
	self.CardDefenseImage.fillAmount =dp/self.dpMax	
	--速度
	local speed = self.heroData:GetSpeed()
	self.CardSpeed.text =speed
	self.CardSpeedImage.fillAmount =speed/self.speedMax	
	--暴击
	local crit = self.heroData:GetCritRate()
	self.CardCrit.text =crit.."%"
	self.CardCritImage.fillAmount =crit/(self.critMax/100)	
	--暴抗
	local resistCrit = self.heroData:GetDecritRate()
	self.CardResistCrit.text =resistCrit .. "%"
	self.CardResistCritImage.fillAmount =resistCrit/(self.resistCritMax/100)	
	--命中
	local hitRate = self.heroData:GetHitRate()
	self.CardHitRate.text = (hitRate - 100) .. "%"
	self.CardHitRateImage.fillAmount =(hitRate-100)/(self.hitRateMax/100)	
	--闪避
	local dodge = self.heroData:GetAvoidRate()
	self.CardDodge.text=dodge .. "%"
	self.CardDodgeImage.fillAmount =dodge/(self.dodgeMax/100)	
end
---------------------------------------------------
---------更新力智敏
-----------------------------------------------------
function PetUpGrade:UpdateCardAttributeIcon()
	  local attr = self.heroData:GetMajorAttr()
	  if attr==0 then

		self.WingsCardInfoTypeLi.enabled=true

	  elseif attr==1 then
	  	self.WingsCardInfoTypeMin.enabled=false
	  	
	  else
		self.WingsCardInfoTypeZhi.enabled=true
	  end
end

---------------------------------------------------
---------更新宠物信息
---------------------------------------------------

 function PetUpGrade:UpdatePetInfo()
	


	
end

function PetUpGrade:RegisterControlEvents()
	-- 注册 WingsReturnButton 的事件
	self.__event_button_onWingsReturnButtonClicked__ = UnityEngine.Events.UnityAction(self.OnWingsReturnButtonClicked, self)
	self.WingsReturnButton.onClick:AddListener(self.__event_button_onWingsReturnButtonClicked__)

	-- -- 注册 Scroll_View 的事件
	-- self.__event_scrollrect_onScroll_ViewValueChanged__ = UnityEngine.Events.UnityAction_UnityEngine_Vector2(self.OnScroll_ViewValueChanged, self)
	-- self.Scroll_View.onValueChanged:AddListener(self.__event_scrollrect_onScroll_ViewValueChanged__)

	-- 注册 UpgradeButton 的事件
	self.__event_button_onUpgradeButtonClicked__ = UnityEngine.Events.UnityAction(self.OnUpgradeButtonClicked, self)
	self.UpgradeButton.onClick:AddListener(self.__event_button_onUpgradeButtonClicked__)
end

function PetUpGrade:UnregisterControlEvents()
	-- 取消注册 WingsReturnButton 的事件
	if self.__event_button_onWingsReturnButtonClicked__ then
		self.WingsReturnButton.onClick:RemoveListener(self.__event_button_onWingsReturnButtonClicked__)
		self.__event_button_onWingsReturnButtonClicked__ = nil
	end

	-- -- 取消注册 Scroll_View 的事件
	-- if self.__event_scrollrect_onScroll_ViewValueChanged__ then
	-- 	self.Scroll_View.onValueChanged:RemoveListener(self.__event_scrollrect_onScroll_ViewValueChanged__)
	-- 	self.__event_scrollrect_onScroll_ViewValueChanged__ = nil
	-- end

	-- 取消注册 UpgradeButton 的事件
	if self.__event_button_onUpgradeButtonClicked__ then
		self.UpgradeButton.onClick:RemoveListener(self.__event_button_onUpgradeButtonClicked__)
		self.__event_button_onUpgradeButtonClicked__ = nil
	end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function PetUpGrade:OnWingsReturnButtonClicked()
	--WingsReturnButton控件的点击事件处理
	self:Close()
end

-- function PetUpGrade:OnScroll_ViewValueChanged(posXY)
-- 	--Scroll_View控件的点击事件处理
-- end

function PetUpGrade:OnUpgradeButtonClicked()
	--UpgradeButton控件的点击事件处理

	local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)

  	 if  userData:GetLevel()>=self.staticData:GetLevelLimit() then

	else
		 utility.ShowErrorDialog("请先将人物升级到"..self.staticData:GetLevelLimit().."!")
	end
end


return PetUpGrade

