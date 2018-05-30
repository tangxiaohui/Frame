local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "Const"
require "LUT.StringTable"

local EquipPowerupStatus = Class(BaseNodeClass)

function EquipPowerupStatus:Ctor(parent,index)
	self.parent = parent

end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function EquipPowerupStatus:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/EquipPowerupStatus', function(go)
		self:BindComponent(go,false)
	end)
end

function EquipPowerupStatus:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()
end

function EquipPowerupStatus:OnResume()
	-- 界面显示时调用
	EquipPowerupStatus.base.OnResume(self)
end

function EquipPowerupStatus:OnPause()
	-- 界面隐藏时调用
	EquipPowerupStatus.base.OnPause(self)
end

function EquipPowerupStatus:OnEnter()
	-- Node Enter时调用
	EquipPowerupStatus.base.OnEnter(self)
end

function EquipPowerupStatus:OnExit()
	-- Node Exit时调用
	EquipPowerupStatus.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------


-- # 控件绑定
function EquipPowerupStatus:InitControls()
	local transform = self:GetUnityTransform()
	self.transform = transform

	self.attNameLabel = transform:Find('EquipPowerupStatus1NameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.PowerupArrow = transform:Find('EquipPowerupStatusBase1/PowerupArrow').gameObject
	self.oldAttLabel = transform:Find('EquipPowerupStatusBase1/EquipPowerupOldStatus1'):GetComponent(typeof(UnityEngine.UI.Text))
	self.newAttLabel = transform:Find('EquipPowerupStatusBase1/EquipPowerupNewStatus1'):GetComponent(typeof(UnityEngine.UI.Text))
end

-----------------------------------------------------------------------
local function DelayRefreshItem(self,attId,AttValue,mainID,addtionValue)
	while (not self:IsReady()) do
		coroutine.step(1)
	end

	local gametool = require "Utils.GameTools"
	local AttValue = gametool.UpdatePropValue(attId,AttValue)
	local addtionValue = gametool.UpdatePropValue(mainID,addtionValue)

	self.attNameLabel.text = EquipStringTable[attId]
	self.oldAttLabel.text = AttValue
	if attId == mainID then
		self.PowerupArrow:SetActive(true)
		self.newAttLabel.gameObject:SetActive(true)
		self.newAttLabel.text = addtionValue
		self.transform:SetAsFirstSibling()
	end
end

function EquipPowerupStatus:RefreshItem(attId,AttValue,mainID,addtionValue)
	-- 刷新显示
	-- coroutine.start(DelayRefreshItem,self,attId,AttValue,mainID,addtionValue)
	self:StartCoroutine(DelayRefreshItem, attId,AttValue,mainID,addtionValue)
end

function EquipPowerupStatus:SetActive(active)
	self.active = active
end

function EquipPowerupStatus:GetActive()
	return self.active
end




return EquipPowerupStatus