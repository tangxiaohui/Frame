local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local PetPowerUpCls = Class(BaseNodeClass)

function PetPowerUpCls:Ctor()
end

-----------------------------------------------------------------------
--- 场景状态   强化
-----------------------------------------------------------------------
function PetPowerUpCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/PetPowerUp', function(go)
		self:BindComponent(go)
	end)
end

function PetPowerUpCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function PetPowerUpCls:OnWillShow(cardID,itemUID)
	print(itemID)
	self.itemUID=itemUID
	self.cardID=cardID


end
function PetPowerUpCls:OnResume()
	-- 界面显示时调用
	PetPowerUpCls.base.OnResume(self)
	self:RegisterControlEvents()
	--self:RegisterNetworkEvents()
	self:InitViews()
end

function PetPowerUpCls:OnPause()
	-- 界面隐藏时调用
	PetPowerUpCls.base.OnPause(self)
	self:UnregisterControlEvents()
	--self:UnregisterNetworkEvents()
end

function PetPowerUpCls:OnEnter()
	-- Node Enter时调用
	PetPowerUpCls.base.OnEnter(self)
end

function PetPowerUpCls:OnExit()
	-- Node Exit时调用
	PetPowerUpCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function PetPowerUpCls:InitControls()
	local transform = self:GetUnityTransform()
	self.WindowBase = transform:Find('WindowBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.UpperDecoration = transform:Find('UpperDecoration'):GetComponent(typeof(UnityEngine.UI.Image))
	self.DownerDecoration = transform:Find('DownerDecoration'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Wing_Title = transform:Find('Wing_Title'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsReturnButton = transform:Find('WingsReturnButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.WingsCardInfoColorBase = transform:Find('WingsCardInfo/WingsCardInfoColorBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsCardInfoCardFace = transform:Find('WingsCardInfo/WingsCardInfoCardFace'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsCardInfoBase = transform:Find('WingsCardInfo/WingsCardInfoBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.NameBlackBase = transform:Find('WingsCardInfo/NameBlackBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsCardInfoNameLabel = transform:Find('WingsCardInfo/WingsCardInfoNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.WingsCardInfoPowerupLabe = transform:Find('WingsCardInfo/WingsCardInfoPowerupLabe'):GetComponent(typeof(UnityEngine.UI.Text))
		--宠物类型
	self.WingsCardInfoTypeLi = transform:Find('WingsCardInfo/WingsCardInfoType'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsCardInfoTypeLi.enabled=false
	self.WingsCardInfoTypeZhi = transform:Find('WingsCardInfo/WingsCardInfoType (1)'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsCardInfoTypeZhi.enabled=false
	self.WingsCardInfoTypeMin = transform:Find('WingsCardInfo/WingsCardInfoType (2)'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsCardInfoTypeMin.enabled=false

	--
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







	self.WingsCardInfoLvNuLabel = transform:Find('WingsCardInfo/WingsCardInfoLv/WingsCardInfoLvNuLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Scroll_View = transform:Find('WingsCardInfo/WingsCardInfoStatusLabel/Scroll View'):GetComponent(typeof(UnityEngine.UI.ScrollRect))
	self.Viewport = transform:Find('WingsCardInfo/WingsCardInfoStatusLabel/Scroll View/Viewport'):GetComponent(typeof(UnityEngine.UI.Mask))
	self.WingsPowerupEquipInfoBase1 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase1'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsPowerupEquipInfobox = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase1/WingsPowerupEquipInfobox'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsPowerupEquipInfoside1 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase1/WingsPowerupEquipInfobox/WingsPowerupEquipInfoside1'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsPowerupEquipInfoside2 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase1/WingsPowerupEquipInfobox/WingsPowerupEquipInfoside2'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsPowerupEquipInfoboxItself = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase1/WingsPowerupEquipInfobox/WingsPowerupEquipInfoboxItself'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsPowerupEquipInfoDecoration1 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase1/WingsPowerupEquipInfobox/WingsPowerupEquipInfoDecoration1'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsPowerupEquipInfoDecoration2 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase1/WingsPowerupEquipInfobox/WingsPowerupEquipInfoDecoration2'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsPowerupEquipInfoBase = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase1/MaterialItem1/WingsPowerupEquipInfoBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsPowerupEquipInfoGeneralItemIcon = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase1/MaterialItem1/WingsPowerupEquipInfoGeneralItemIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsPowerupEquipInfoGeneralItemFarme01 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase1/MaterialItem1/WingsPowerupEquipInfoFarme/WingsPowerupEquipInfoGeneralItemFarme01'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsPowerupEquipInfoGeneralItemFarme02 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase1/MaterialItem1/WingsPowerupEquipInfoFarme/WingsPowerupEquipInfoGeneralItemFarme02'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsPowerupEquipInfoGeneralItemFarme03_03 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase1/MaterialItem1/WingsPowerupEquipInfoFarme/WingsPowerupEquipInfoGeneralItemFarme03_03'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsPowerupEquipInfoGeneralItemFarme04 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase1/MaterialItem1/WingsPowerupEquipInfoFarme/WingsPowerupEquipInfoGeneralItemFarme04'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsPowerupEquipInfoBase3 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase1/MaterialItem2/WingsPowerupEquipInfoBase3'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsPowerupEquipInfoGeneralItemIcon1 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase1/MaterialItem2/WingsPowerupEquipInfoGeneralItemIcon1'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsPowerupEquipInfoGeneralItemFarme01_01 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase1/MaterialItem2/WingsPowerupEquipInfoFarme1/WingsPowerupEquipInfoGeneralItemFarme01_01'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsPowerupEquipInfoGeneralItemFarme02_02 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase1/MaterialItem2/WingsPowerupEquipInfoFarme1/WingsPowerupEquipInfoGeneralItemFarme02_02'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsPowerupEquipInfoGeneralItemFarme03 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase1/MaterialItem2/WingsPowerupEquipInfoFarme1/WingsPowerupEquipInfoGeneralItemFarme03'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsPowerupEquipInfoGeneralItemFarme04_04 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase1/MaterialItem2/WingsPowerupEquipInfoFarme1/WingsPowerupEquipInfoGeneralItemFarme04_04'):GetComponent(typeof(UnityEngine.UI.Image))
	self.MaterialItem3Base = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase1/MaterialItem3/MaterialItem3Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.MaterialItem3GeneralItemIcon = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase1/MaterialItem3/MaterialItem3GeneralItemIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.MaterialItem3GeneralItemFarme01 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase1/MaterialItem3/MaterialItem3Farme/MaterialItem3GeneralItemFarme01'):GetComponent(typeof(UnityEngine.UI.Image))
	self.MaterialItem3GeneralItemFarme02 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase1/MaterialItem3/MaterialItem3Farme/MaterialItem3GeneralItemFarme02'):GetComponent(typeof(UnityEngine.UI.Image))
	self.MaterialItem3GeneralItemFarme03 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase1/MaterialItem3/MaterialItem3Farme/MaterialItem3GeneralItemFarme03'):GetComponent(typeof(UnityEngine.UI.Image))
	self.MaterialItem3GeneralItemFarme04 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase1/MaterialItem3/MaterialItem3Farme/MaterialItem3GeneralItemFarme04'):GetComponent(typeof(UnityEngine.UI.Image))
	self.AddMaterialItemBase = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase1/AddMaterialItem/AddMaterialItemBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.AddMaterialItemGeneralItemIcon = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase1/AddMaterialItem/AddMaterialItemGeneralItemIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.AddMaterialItemGeneralItemFarme01 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase1/AddMaterialItem/AddMaterialItemFarme/AddMaterialItemGeneralItemFarme01'):GetComponent(typeof(UnityEngine.UI.Image))
	self.AddMaterialItemGeneralItemFarme02 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase1/AddMaterialItem/AddMaterialItemFarme/AddMaterialItemGeneralItemFarme02'):GetComponent(typeof(UnityEngine.UI.Image))
	self.AddMaterialItemGeneralItemFarme03 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase1/AddMaterialItem/AddMaterialItemFarme/AddMaterialItemGeneralItemFarme03'):GetComponent(typeof(UnityEngine.UI.Image))
	self.AddMaterialItemGeneralItemFarme04 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase1/AddMaterialItem/AddMaterialItemFarme/AddMaterialItemGeneralItemFarme04'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsPowerupEquipInfoBase2 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ShadowBaseforTitle1 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/ShadowBaseforTitle1'):GetComponent(typeof(UnityEngine.UI.Image))
	self.EquipInfoTitle1 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/EquipInfoTitle1'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ShadowBaseforTypenName1 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/ShadowBaseforTypenName1'):GetComponent(typeof(UnityEngine.UI.Image))
	self.TypeWings1 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/TypeWings1'):GetComponent(typeof(UnityEngine.UI.Image))
	self.LvShadowBase1 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/WingsLV1/LvShadowBase1'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsLvIcon1 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/WingsLV1/WingsLvIcon1'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsLvNuLabel1 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/WingsLV1/WingsLvNuLabel1'):GetComponent(typeof(UnityEngine.UI.Text))
	self.BigItemIcon1Base = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/BigItemIcon1/BigItemIcon1Base'):GetComponent(typeof(UnityEngine.UI.Image))
	
	--宠物名字
	self.WingNameLabel1 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/WingNameLabel1'):GetComponent(typeof(UnityEngine.UI.Text))

	--宠物大图标
	self.BigItemIcon1GeneralItemIcon = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/BigItemIcon1/BigItemIcon1GeneralItemIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	--宠物星级
	self.ItemRank1 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/BigItemIcon1/ItemRank1')

	--宠物颜色
	self.BigItemIcon1GeneralItemFarmeBase= transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/BigItemIcon1/BigItemIcon1Farme')	


	self.BigItemIcon1GeneralItemFarme01 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/BigItemIcon1/BigItemIcon1Farme/BigItemIcon1GeneralItemFarme01'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BigItemIcon1GeneralItemFarme02 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/BigItemIcon1/BigItemIcon1Farme/BigItemIcon1GeneralItemFarme02'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BigItemIcon1GeneralItemFarme03 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/BigItemIcon1/BigItemIcon1Farme/BigItemIcon1GeneralItemFarme03'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BigItemIcon1GeneralItemFarme04 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/BigItemIcon1/BigItemIcon1Farme/BigItemIcon1GeneralItemFarme04'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsPowerupEquipInfoStar = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/BigItemIcon1/ItemRank1/WingsPowerupEquipInfoStar'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsPowerupEquipInfoStar__1_ = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/BigItemIcon1/ItemRank1/WingsPowerupEquipInfoStar (1)'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsPowerupEquipInfoStar__2_ = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/BigItemIcon1/ItemRank1/WingsPowerupEquipInfoStar (2)'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsPowerupEquipInfoStar__3_ = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/BigItemIcon1/ItemRank1/WingsPowerupEquipInfoStar (3)'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsPowerupEquipInfoStar__4_ = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/BigItemIcon1/ItemRank1/WingsPowerupEquipInfoStar (4)'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsPowerupEquipInfoside1_1 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/WingsPowerupEquipInfobox1/WingsPowerupEquipInfoside1_1'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsPowerupEquipInfoside2_1 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/WingsPowerupEquipInfobox1/WingsPowerupEquipInfoside2_1'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsPowerupEquipInfoboxItself1 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/WingsPowerupEquipInfobox1/WingsPowerupEquipInfoboxItself1'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsPowerupEquipInfoDecoration11 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/WingsPowerupEquipInfobox1/WingsPowerupEquipInfoDecoration11'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsPowerupEquipInfoDecoration21 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/WingsPowerupEquipInfobox1/WingsPowerupEquipInfoDecoration21'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsPowerupEquipInfoFrame = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/ShowPowerupResultSlider/WingsPowerupEquipInfoFrame'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ShowPowerupResultSliderMask = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/ShowPowerupResultSlider/ShowPowerupResultSliderMask'):GetComponent(typeof(UnityEngine.UI.Mask))
	self.ShowPowerupResultLabel = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/ShowPowerupResultSlider/ShowPowerupResultLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ShowPowerupPlusLabel = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/ShowPowerupResultSlider/ShowPowerupPlusLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.LineAbove1 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/LineAbove1'):GetComponent(typeof(UnityEngine.UI.Image))
	self.PowerupPreviewText = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/PowerupPreviewText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.PreviewLevelText = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/PowerupLevel/PreviewLevelText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.PowerUpResultFrame1 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/PowerupLevel/PowerUpResultFrame1'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ArrowtoPowerup1 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/PowerupLevel/ArrowtoPowerup1'):GetComponent(typeof(UnityEngine.UI.Image))
	self.PowerupOldLevelLabel = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/PowerupLevel/PowerupOldLevelLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.PowerupNewLevelLabel_ = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/PowerupLevel/PowerupNewLevelLabel '):GetComponent(typeof(UnityEngine.UI.Text))
	self.PreviewStatusText = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/PowerupStatus/PreviewStatusText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.PowerUpResultFrame2 = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/PowerupStatus/PowerUpResultFrame2'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ArrowtoPowerup = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/PowerupStatus/ArrowtoPowerup'):GetComponent(typeof(UnityEngine.UI.Image))
	self.PowerupOldStatusLabel = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/PowerupStatus/PowerupOldStatusLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.PowerupNewStatusLabel_ = transform:Find('WingsPowerupEquipInfo/WingsPowerupEquipInfoBase2/PowerupStatus/PowerupNewStatusLabel '):GetComponent(typeof(UnityEngine.UI.Text))
	self.CoinYouNeedText = transform:Find('WingsGetupPrice/CoinYouNeedText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.CoinIcon = transform:Find('WingsGetupPrice/CoinIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.WingsGetupPriceLabel = transform:Find('WingsGetupPrice/WingsGetupPriceLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.GetupButtonBase = transform:Find('GetupButtonBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.PowerupButton = transform:Find('PowerupButton'):GetComponent(typeof(UnityEngine.UI.Button))
end
function PetPowerUpCls:InitViews()
	-- local role = require"StaticData/Role":GetData(self.cardID)
	-- print(role:GetStar(),"++++++++++++++++++++++++++++++++++++++")

	-- local _,data,itemName =  require "Utils.GameTools".GetItemDataById(self.cardID)
	self:InitCardInfo()
	self:InitPetInfo()
end

--初始化宠物显示
function PetPowerUpCls:InitPetInfo()
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

	local gameTool = require "Utils.GameTools"
	local AtlasesLoader = require "Utils.AtlasesLoader"
	local PropUtility = require "Utils.PropUtility" 

 	local bagData = self:GetCachedData(UserDataType.EquipBagData)
	local petData = bagData:GetItem(data:GetKeyFromIndex(1))

	local infodata,data,name,itemIconPath,ItemType = gameTool.GetItemDataById(petData:GetEquipID())
 	utility.LoadSpriteFromPath(itemIconPath,self.BigItemIcon1GeneralItemIcon)

 	self.WingNameLabel1.text=name

 	local star = petData:GetStar()
 	gameTool.AutoSetStar(self.ItemRank1,star)

 	local color = gameTool.GetItemColorByType(ItemType,data)
 	PropUtility.AutoSetColor(self.BigItemIcon1GeneralItemFarmeBase,color)

 	


  		

end


--初始化卡牌显示
function PetPowerUpCls:InitCardInfo()
	
    local UserDataType = require "Framework.UserDataType"
    local cardBagData = self:GetCachedData(UserDataType.CardBagData)
    local userRoleData = cardBagData:GetRoleById(self.cardID)
    require "Game.Role"
    if userRoleData == nil then
        userRoleData = Role.New()
        userRoleData:UpdateForStatic(data:GetId(), 1, 1)
    end
   self.heroData=userRoleData
   
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
function PetPowerUpCls:UpdateCardBasisInfo()
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


function PetPowerUpCls:UpdateCardAttributeIcon()
	  local attr = self.heroData:GetMajorAttr()
	  if attr==0 then

		self.WingsCardInfoTypeLi.enabled=true

	  elseif attr==1 then
	  	self.WingsCardInfoTypeMin.enabled=false
	  	
	  else
		self.WingsCardInfoTypeZhi.enabled=true
	  end



end
 

function PetPowerUpCls:RegisterControlEvents()
	-- 注册 WingsReturnButton 的事件
	self.__event_button_onWingsReturnButtonClicked__ = UnityEngine.Events.UnityAction(self.OnWingsReturnButtonClicked, self)
	self.WingsReturnButton.onClick:AddListener(self.__event_button_onWingsReturnButtonClicked__)

	-- 注册 Scroll_View 的事件
	self.__event_scrollrect_onScroll_ViewValueChanged__ = UnityEngine.Events.UnityAction_UnityEngine_Vector2(self.OnScroll_ViewValueChanged, self)
	self.Scroll_View.onValueChanged:AddListener(self.__event_scrollrect_onScroll_ViewValueChanged__)

	-- 注册 PowerupButton 的事件
	self.__event_button_onPowerupButtonClicked__ = UnityEngine.Events.UnityAction(self.OnPowerupButtonClicked, self)
	self.PowerupButton.onClick:AddListener(self.__event_button_onPowerupButtonClicked__)
end

function PetPowerUpCls:UnregisterControlEvents()
	-- 取消注册 WingsReturnButton 的事件
	if self.__event_button_onWingsReturnButtonClicked__ then
		self.WingsReturnButton.onClick:RemoveListener(self.__event_button_onWingsReturnButtonClicked__)
		self.__event_button_onWingsReturnButtonClicked__ = nil
	end

	-- 取消注册 Scroll_View 的事件
	if self.__event_scrollrect_onScroll_ViewValueChanged__ then
		self.Scroll_View.onValueChanged:RemoveListener(self.__event_scrollrect_onScroll_ViewValueChanged__)
		self.__event_scrollrect_onScroll_ViewValueChanged__ = nil
	end

	-- 取消注册 PowerupButton 的事件
	if self.__event_button_onPowerupButtonClicked__ then
		self.PowerupButton.onClick:RemoveListener(self.__event_button_onPowerupButtonClicked__)
		self.__event_button_onPowerupButtonClicked__ = nil
	end
end



-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function PetPowerUpCls:OnWingsReturnButtonClicked()
	--WingsReturnButton控件的点击事件处理
	self:Close()
end

function PetPowerUpCls:OnScroll_ViewValueChanged(posXY)
	--Scroll_View控件的点击事件处理
end

function PetPowerUpCls:OnPowerupButtonClicked()
	--PowerupButton控件的点击事件处理
end


return PetPowerUpCls

