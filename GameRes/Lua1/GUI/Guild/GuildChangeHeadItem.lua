local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
local GuildChangeHeadItemCls = Class(BaseNodeClass)
require "System.LuaDelegate"
local GuildCommonFunc = require "GUI.Guild.GuildCommonFunc"

function GuildChangeHeadItemCls:Ctor(parent, id, ghLevel)
	self.parent = parent
	self.id = id
	self.ghLevel = ghLevel
	self.callback = LuaDelegate.New()
end

function GuildChangeHeadItemCls:SetCallback(ctable, func)
	self.callback:Set(ctable,func)
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function GuildChangeHeadItemCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/GuildChangeHeadItem', function(go)
		self:BindComponent(go, false)
	end)
end

function GuildChangeHeadItemCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
	self:LinkComponent(self.parent)
end

function GuildChangeHeadItemCls:OnResume()
	-- 界面显示时调用
	GuildChangeHeadItemCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
end

function GuildChangeHeadItemCls:OnPause()
	-- 界面隐藏时调用
	GuildChangeHeadItemCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function GuildChangeHeadItemCls:OnEnter()
	-- Node Enter时调用
	GuildChangeHeadItemCls.base.OnEnter(self)
end

function GuildChangeHeadItemCls:OnExit()
	-- Node Exit时调用
	GuildChangeHeadItemCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function GuildChangeHeadItemCls:InitControls()
	local transform = self:GetUnityTransform()
	self.GuildChangeHeadItem = transform:Find(''):GetComponent(typeof(UnityEngine.UI.Button))
	self.Base = transform:Find('Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.GuildIcon = transform:Find('GuildIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.LevelLabel = transform:Find('LevelLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.HeadSelectBox = transform:Find('HeadSelectBox')

	self.hslMaterial = self.GuildChangeHeadItem:GetComponent(typeof(UnityEngine.UI.Image)).material
	self.grayMaterial = utility.GetGrayMaterial()

	self:InitView()
end

function GuildChangeHeadItemCls:InitView()
	local iconPath, iconColor, unlockLv = GuildCommonFunc.GetGuildIconInfo(self.id)
	utility.LoadSpriteFromPath(iconPath,self.GuildIcon)
	self.GuildChangeHeadItem:GetComponent(typeof(UnityEngine.UI.Image)).color = iconColor

	local locked = self.ghLevel < unlockLv
	self:SetGray(locked)
	if locked then
		self.LevelLabel.text = unlockLv.."级解锁"
	else
		self.LevelLabel.text = ""
	end
	
	self:DoUnselect()
end

function GuildChangeHeadItemCls:SetGray(bGray)
	self.GuildChangeHeadItem.enabled = not bGray
	if bGray then
		self.GuildChangeHeadItem:GetComponent(typeof(UnityEngine.UI.Image)).material = self.grayMaterial
		-- self.Base.material = self.grayMaterial
		self.GuildIcon.material = self.grayMaterial
	else
		self.GuildChangeHeadItem:GetComponent(typeof(UnityEngine.UI.Image)).material = self.hslMaterial
		-- self.Base.material = utility.GetCommonMaterial()
		self.GuildIcon.material = utility.GetCommonMaterial()
	end
end

function GuildChangeHeadItemCls:DoSelect()
	self.HeadSelectBox.gameObject:SetActive(true)
end

function GuildChangeHeadItemCls:DoUnselect()
	self.HeadSelectBox.gameObject:SetActive(false)
end

function GuildChangeHeadItemCls:RegisterControlEvents()
	-- 注册 GuildChangeHeadItem 的事件
	self.__event_button_onGuildChangeHeadItemClicked__ = UnityEngine.Events.UnityAction(self.OnGuildChangeHeadItemClicked, self)
	self.GuildChangeHeadItem.onClick:AddListener(self.__event_button_onGuildChangeHeadItemClicked__)
end

function GuildChangeHeadItemCls:UnregisterControlEvents()
	-- 取消注册 GuildChangeHeadItem 的事件
	if self.__event_button_onGuildChangeHeadItemClicked__ then
		self.GuildChangeHeadItem.onClick:RemoveListener(self.__event_button_onGuildChangeHeadItemClicked__)
		self.__event_button_onGuildChangeHeadItemClicked__ = nil
	end
end

function GuildChangeHeadItemCls:RegisterNetworkEvents()
end

function GuildChangeHeadItemCls:UnregisterNetworkEvents()
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function GuildChangeHeadItemCls:OnGuildChangeHeadItemClicked()
	self.callback:Invoke(self.id)
end

return GuildChangeHeadItemCls
