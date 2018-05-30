local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "System.LuaDelegate"

local GemAddMaterialBoxCls = Class(BaseNodeClass)

function GemAddMaterialBoxCls:Ctor(parent)
	self.parent = parent
	self.callback = LuaDelegate.New()
end

function GemAddMaterialBoxCls:SetCallback(ctable,func)
	 self.callback:Set(ctable,func)
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function GemAddMaterialBoxCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/AddMaterialBox', function(go)
		self:BindComponent(go,false)
	end)
end

function GemAddMaterialBoxCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()
end

function GemAddMaterialBoxCls:OnResume()
	-- 界面显示时调用
	GemAddMaterialBoxCls.base.OnResume(self)
	self:RegisterControlEvents()
end

function GemAddMaterialBoxCls:OnPause()
	-- 界面隐藏时调用
	GemAddMaterialBoxCls.base.OnPause(self)
	self:UnregisterControlEvents()
end

function GemAddMaterialBoxCls:OnEnter()
	-- Node Enter时调用
	GemAddMaterialBoxCls.base.OnEnter(self)
end

function GemAddMaterialBoxCls:OnExit()
	-- Node Exit时调用
	GemAddMaterialBoxCls.base.OnExit(self)
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
function GemAddMaterialBoxCls:InitControls()
	local transform = self:GetUnityTransform()
	self.plusImageObj = transform:Find('PlusImage').gameObject
	self.GrayMaterial = self.plusImageObj:GetComponent(typeof(UnityEngine.UI.Image)).material
	self.IconImageObj = transform:Find('IconImage').gameObject
	self.IconImage = self.IconImageObj:GetComponent(typeof(UnityEngine.UI.Image))
	self.colorFrame = transform:Find('ColorFrame')
	self.fameImage = self.colorFrame:Find('Frame'):GetComponent(typeof(UnityEngine.UI.Image))
	self.HslMaterial = self.fameImage.material
	self.fameImage.material = self.GrayMaterial

	self.MainButton = transform:Find('baseAsAddMateriaButton'):GetComponent(typeof(UnityEngine.UI.Button))
end

function GemAddMaterialBoxCls:RegisterControlEvents()
	self.__event_button_onMainButtonClicked__ = UnityEngine.Events.UnityAction(self.OnMainButtonClicked, self)
	self.MainButton.onClick:AddListener(self.__event_button_onMainButtonClicked__)
end

function GemAddMaterialBoxCls:UnregisterControlEvents()
	if self.__event_button_onMainButtonClicked__ then
		self.MainButton.onClick:RemoveListener(self.__event_button_onMainButtonClicked__)
		self.__event_button_onMainButtonClicked__ = nil
	end
end

local function DelayResetItem(self,id,data)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	local gametool = require "Utils.GameTools"
	local PropUtility = require "Utils.PropUtility"

	local itemInfoData,itemData,name,iconPath,itemType = gametool.GetItemDataById(id)
	self.plusImageObj:SetActive(false)
	self.IconImageObj:SetActive(true)
	utility.LoadSpriteFromPath(iconPath,self.IconImage)

	local color = data:GetColor()
	self.fameImage.material = self.HslMaterial
	PropUtility.AutoSetColor(self.colorFrame,color)
end

function GemAddMaterialBoxCls:ResetItem(id,data)
	self.id = id
	-- coroutine.start(DelayResetItem,self,id,data)
	self:StartCoroutine(DelayResetItem, id,data)
end

function GemAddMaterialBoxCls:ResetDefaut()
	-- 默认
	self.plusImageObj:SetActive(true)
	self.IconImageObj:SetActive(false)
	self.fameImage.material = self.GrayMaterial
	self.fameImage.color = UnityEngine.Color(1,1,1,1)
end

function GemAddMaterialBoxCls:OnMainButtonClicked()
	if self.checkedState then
		self.callback:Invoke(self.id)
	end
end

function GemAddMaterialBoxCls:SetCheckedState(state)
	self.checkedState = state
end

function GemAddMaterialBoxCls:GetCheckedState()
	return self.checkedState
end

return GemAddMaterialBoxCls