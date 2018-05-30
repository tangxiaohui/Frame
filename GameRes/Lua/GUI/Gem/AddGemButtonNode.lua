local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
local AddGemButtonNode = Class(BaseNodeClass)
require "System.LuaDelegate"


function AddGemButtonNode:Ctor(parent)
	self.parent = parent
	self.callback = LuaDelegate.New()
end


function AddGemButtonNode:SetCallback(ctable,func)
	 self.callback:Set(ctable,func)
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function AddGemButtonNode:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/GemCombineAddGemButton', function(go)
		self:BindComponent(go,false)
	end)
end

function AddGemButtonNode:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent,true)
	self:InitControls()
end

function AddGemButtonNode:OnResume()
	-- 界面显示时调用
	AddGemButtonNode.base.OnResume(self)
	self:RegisterControlEvents()
end

function AddGemButtonNode:OnPause()
	-- 界面隐藏时调用
	AddGemButtonNode.base.OnPause(self)
	self:UnregisterControlEvents()
end

function AddGemButtonNode:OnEnter()
	-- Node Enter时调用
	AddGemButtonNode.base.OnEnter(self)
end

function AddGemButtonNode:OnExit()
	-- Node Exit时调用
	AddGemButtonNode.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function AddGemButtonNode:InitControls()
	local transform = self:GetUnityTransform()
	self.colorFrame = transform:Find('Farme')
	self.gemIcon = transform:Find('Button/GeneralItemIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.defaulgemIcon = self.gemIcon.sprite
	self.Button = transform:Find('Button'):GetComponent(typeof(UnityEngine.UI.Button))
end


function AddGemButtonNode:RegisterControlEvents()
	-- 注册 Button 的事件
	self.__event_button_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnButtonClicked, self)
	self.Button.onClick:AddListener(self.__event_button_onButtonClicked__)
end

function AddGemButtonNode:UnregisterControlEvents()
	-- 取消注册 Button 的事件
	if self.__event_button_onButtonClicked__ then
		self.Button.onClick:RemoveListener(self.__event_button_onButtonClicked__)
		self.__event_button_onButtonClicked__ = nil
	end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function AddGemButtonNode:OnButtonClicked()
	--Button控件的点击事件处理
	self.callback:Invoke()
end


function AddGemButtonNode:ResetButtonState(state,uid)
	-- 重置按钮选中的状态
	if state then
		self:SetGemTheme(uid)
	else
		self:SetDefautTheme()
	end
end

--------------------------------------------------------------------------
function AddGemButtonNode:SetDefautTheme()
	-- 设置默认
	local gametool = require "Utils.GameTools"
	--gametool.OnLoadSprite(self.gemIcon,self.defaulgemIcon)
	self.gemIcon.sprite = self.defaulgemIcon

	local PropUtility = require "Utils.PropUtility"
	PropUtility.AutoSetColor(self.colorFrame,0)
end

function AddGemButtonNode:SetGemTheme(id,data)
	-- 设置宝石选中的状态

	--local UserDataType = require "Framework.UserDataType"
    --bagData = self:GetCachedData(UserDataType.EquipBagData)

   -- local data = bagData:GetItem(uid)

    --local id = data:GetEquipID()

	local gametool = require "Utils.GameTools"

	-- 设置图标
	local _,_,_,iconPath = gametool.GetItemDataById(id)
	utility.LoadSpriteFromPath(iconPath,self.gemIcon)

	-- 设置颜色
	local color = data:GetColor()
	local PropUtility = require "Utils.PropUtility"
	PropUtility.AutoSetColor(self.colorFrame,color)
end


return AddGemButtonNode
