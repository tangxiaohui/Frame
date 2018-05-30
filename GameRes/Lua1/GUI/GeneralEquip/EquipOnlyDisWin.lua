local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
-----------------------------------------------------------------------
local EquipOnlyDisWinCls = Class(BaseNodeClass)
windowUtility.SetMutex(EquipOnlyDisWinCls, true)

function EquipOnlyDisWinCls:Ctor()
end

function EquipOnlyDisWinCls:OnWillShow(equipId,isGeted)
	self.equipId = equipId
	self.isGeted = isGeted
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function EquipOnlyDisWinCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/EquipOnlyDisWin', function(go)
		self:BindComponent(go)
	end)
end

function EquipOnlyDisWinCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function EquipOnlyDisWinCls:OnResume()
	-- 界面显示时调用
	EquipOnlyDisWinCls.base.OnResume(self)
	self:RegisterControlEvents()

	self:AddNode()

	self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
end

function EquipOnlyDisWinCls:OnPause()
	-- 界面隐藏时调用
	EquipOnlyDisWinCls.base.OnPause(self)
	self:UnregisterControlEvents()
end

function EquipOnlyDisWinCls:OnEnter()
	-- Node Enter时调用
	EquipOnlyDisWinCls.base.OnEnter(self)
end

function EquipOnlyDisWinCls:OnExit()
	-- Node Exit时调用
	EquipOnlyDisWinCls.base.OnExit(self)
end

function EquipOnlyDisWinCls:IsTransition()
    return true
end

function EquipOnlyDisWinCls:OnExitTransitionDidStart(immediately)
	EquipOnlyDisWinCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function EquipOnlyDisWinCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function EquipOnlyDisWinCls:InitControls()
	local transform = self:GetUnityTransform()

	self.RetrunButton = transform:Find("Base"):GetComponent(typeof(UnityEngine.UI.Button))
	self.tweenObjectTrans = transform:Find("TweenObject")
	self.cardPoint = transform:Find("TweenObject/Point")
	self.effect = transform:Find('TweenObject/Effect').gameObject
	local hintObj = transform:Find('TweenObject/HintLabel').gameObject
	hintObj:SetActive(self.isGeted)
end


function EquipOnlyDisWinCls:RegisterControlEvents()
	-- 注册 ShopRetrunButton 的事件
	self.__event_button_onRetrunButtonClicked__ = UnityEngine.Events.UnityAction(self.OnRetrunButtonClicked, self)
	self.RetrunButton.onClick:AddListener(self.__event_button_onRetrunButtonClicked__)
end

function EquipOnlyDisWinCls:UnregisterControlEvents()
	-- 取消注册 ShopRetrunButton 的事件
	if self.__event_button_onRetrunButtonClicked__ then
		self.RetrunButton.onClick:RemoveListener(self.__event_button_onRetrunButtonClicked__)
		self.__event_button_onRetrunButtonClicked__ = nil
	end
end

local function SetNode(self,node)
	local gameTool = require "Utils.GameTools"
	local infoData,equipData,name,iconPath,etype = gameTool.GetItemDataById(self.equipId)

	node:SetId(self.equipId)
	node:SetIcon(iconPath)
	node:SetName(name)
	node:SetStar(equipData:GetStarID())
	node:SetRarity(equipData:GetRarity())
	node:SetColor(equipData:GetColorID())
	local etype = equipData:GetType()
	node:SetEtype(etype)
	local mainId = equipData:GetMainPropID()
	node:SetMainAttrID(mainId)
	local _,mainStr = equipData:GetBasisValue(mainId)
	node:SetMainAttrStr(mainStr)
	node:SetDesc(infoData:GetDesc())

	local dict,mainPropID = equipData:GetEquipAttribute()
	local leftStr,rightStr = gameTool.GetEquipInfoStr(dict,mainPropID)
	local addStr = gameTool.GetEquipPrivateInfoStr(self.equipId)
	node:SetLeftAttr(string.format("%s%s",leftStr,addStr))
	node:SetRightAttr(rightStr)
	node:SetScale(Vector3(0.97,0.97,0.97))
end

function EquipOnlyDisWinCls:AddNode()
	local node = require "GUI.GeneralEquip.GeneralEquiItem".New(self.cardPoint,true)
	SetNode(self,node)
	self:AddChild(node)
	self.effect:SetActive(self.isGeted)
end

function EquipOnlyDisWinCls:OnRetrunButtonClicked()
	self:Close()
end

return EquipOnlyDisWinCls