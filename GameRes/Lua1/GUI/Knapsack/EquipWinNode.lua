local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"

require "Const"
require "LUT.StringTable"

-----------------------------------------------------------------------
local EquipWinCls = Class(BaseNodeClass)
windowUtility.SetMutex(EquipWinCls, true)

function EquipWinCls:Ctor()
end
function EquipWinCls:OnWillShow(id)
	self.ItemID = id
	print("<><><>",id)
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function EquipWinCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/SuitItem', function(go)
		self:BindComponent(go)
	end)
end

function EquipWinCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function EquipWinCls:OnResume()
	-- 界面显示时调用
	EquipWinCls.base.OnResume(self)
	self:RegisterControlEvents()

	self:RefreshItem(self.ItemID)

	self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
end

function EquipWinCls:OnPause()
	-- 界面隐藏时调用
	EquipWinCls.base.OnPause(self)
	self:UnregisterControlEvents()
end

function EquipWinCls:OnEnter()
	-- Node Enter时调用
	EquipWinCls.base.OnEnter(self)
end

function EquipWinCls:OnExit()
	-- Node Exit时调用
	EquipWinCls.base.OnExit(self)
end


function EquipWinCls:IsTransition()
    return false
end

function EquipWinCls:OnExitTransitionDidStart(immediately)
	EquipWinCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function EquipWinCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function EquipWinCls:InitControls()
	local transform = self:GetUnityTransform()
	self.tweenObjectTrans = transform:Find('Base')
	self.RetrunButton = transform:Find('Base/RetrunButton'):GetComponent(typeof(UnityEngine.UI.Button))
	--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))
	-- 名称
	self.nameLabel = transform:Find('Base/ItemNameBase/InfoItemNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	-- 颜色
	self.colorFrame = transform:Find('Base/ItemBox/ColorFrame')
	-- 图像
	self.itemIconImage = transform:Find('Base/ItemBox/EquipIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	-- 类型图
	self.itemTypeImage = transform:Find('Base/ItemNameBase/InfoItemTypeIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	-- 星级
	self.starFrame = transform:Find('Base/ItemBox/EquipStarLayout')
	-- 说明
	self.desLable = transform:Find('Base/EquipINfoTextLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	-- 属性信息
	self.rightInfoLabel = transform:Find('Base/rightInfoLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.leftInfoLabel = transform:Find('Base/leftInfoLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	
end

function EquipWinCls:RegisterControlEvents()
	-- 注册 RetrunButton 的事件
	self.__event_button_onRetrunButtonClicked__ = UnityEngine.Events.UnityAction(self.OnRetrunButtonClicked, self)
	self.RetrunButton.onClick:AddListener(self.__event_button_onRetrunButtonClicked__)

	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnRetrunButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)
end

function EquipWinCls:UnregisterControlEvents()
	-- 取消注册 RetrunButton 的事件
	if self.__event_button_onRetrunButtonClicked__ then
		self.RetrunButton.onClick:RemoveListener(self.__event_button_onRetrunButtonClicked__)
		self.__event_button_onRetrunButtonClicked__ = nil
	end

	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end
end

function EquipWinCls:RefreshItem(id)
	local staticData = require "StaticData.Equip":GetData(id)	

	local gametool = require "Utils.GameTools"
	local PropUtility = require "Utils.PropUtility"

	local infodata,data,name,iconPath,itype = gametool.GetItemDataById(id)
	-- 名字
	self.nameLabel.text = name
	-- 图标
	utility.LoadSpriteFromPath(iconPath,self.itemIconImage)
	-- 颜色
	local color = staticData:GetColorID()
	PropUtility.AutoSetColor(self.colorFrame,color)
	-- 星级
	local starCount = data:GetStarID()
	gametool.AutoSetStar(self.starFrame,starCount)
	-- 描述
	self.desLable.text = infodata:GetDesc()
	-- 类型标签
	local etype = data:GetType()
	local tagImagePath = gametool.GetEquipTagImagePath(etype)
	utility.LoadSpriteFromPath(tagImagePath,self.itemTypeImage)
	-- 属性信息
	local attDict,mainId = staticData:GetEquipAttribute()
	local leftStr,rightStr = gametool.GetEquipInfoStr(attDict,mainId)
	self.rightInfoLabel.text = rightStr
	-- 专属装备
	local equipPrivateStr = gametool.GetEquipPrivateInfoStr(id)
	leftStr = string.format("%s%s",leftStr,equipPrivateStr)
	self.leftInfoLabel.text = leftStr
end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function EquipWinCls:OnRetrunButtonClicked()
	self:Close()
end



return EquipWinCls