local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "LUT.StringTable"
local KizunaInfoCls = Class(BaseNodeClass)

function KizunaInfoCls:Ctor(parent)
	self.parent = parent
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function KizunaInfoCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/KizunaInfo', function(go)
		self:BindComponent(go,false)
	end)
end

function KizunaInfoCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()
end

function KizunaInfoCls:OnResume()
	-- 界面显示时调用
	KizunaInfoCls.base.OnResume(self)
end

function KizunaInfoCls:OnPause()
	-- 界面隐藏时调用
	KizunaInfoCls.base.OnPause(self)
end

function KizunaInfoCls:OnEnter()
	-- Node Enter时调用
	KizunaInfoCls.base.OnEnter(self)
end

function KizunaInfoCls:OnExit()
	-- Node Exit时调用
	KizunaInfoCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function KizunaInfoCls:InitControls()
	local transform = self:GetUnityTransform()
	self.kizunaLevelLabel = transform:Find('KizunaLevel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.levelLimitLabel = transform:Find('LevelLimitLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.additionImage1 = transform:Find('Status1/Icon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.additionLabel1 = transform:Find('Status1/Text'):GetComponent(typeof(UnityEngine.UI.Text))
	self.additionImage2 = transform:Find('Status2/Icon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.additionLabel2 = transform:Find('Status2/Text'):GetComponent(typeof(UnityEngine.UI.Text))
	self.KizunaImage = transform:Find('Kizuna'):GetComponent(typeof(UnityEngine.UI.Image))
end
-----------------------------------------------------------------------
function DelayResetView(self,kizunaLevel,levelLimitArray,AddIdArray,ValueArray,openedLevel)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	self.kizunaLevelLabel.text = kizunaLevel
	self.levelLimitLabel.text = string.format("上述皮肤分别达到%s级、%s级和%s级时",levelLimitArray[0],levelLimitArray[1],levelLimitArray[2])	
	local gametool = require "Utils.GameTools"
	local value1 = gametool.UpdatePropValue(AddIdArray[0],ValueArray[0] * kizunaLevel)
	local value2 = gametool.UpdatePropValue(AddIdArray[1],ValueArray[1] * kizunaLevel)
	local costumStr = string.gsub(EquipStringTable[0],":","")
	self.additionLabel1.text = string.format(costumStr,EquipStringTable[AddIdArray[0]],value1)
	self.additionLabel2.text = string.format(costumStr,EquipStringTable[AddIdArray[1]],value2)

	local isOpen = openedLevel == kizunaLevel
	if not isOpen then
		local grayMaterial = utility.GetGrayMaterial(true)
		local imageMaterial = utility.GetGrayMaterial()
		self.KizunaImage.material = imageMaterial
		self.additionImage1.material = imageMaterial
		self.additionImage2.material = imageMaterial
		self.additionLabel1.material = grayMaterial
		self.additionLabel2.material = grayMaterial
	end
end


function KizunaInfoCls:ResetView(kizunaLevel,levelLimitArray,AddIdArray,ValueArray,openedLevel)
	self:StartCoroutine(DelayResetView,kizunaLevel,levelLimitArray,AddIdArray,ValueArray,openedLevel)
end



return KizunaInfoCls