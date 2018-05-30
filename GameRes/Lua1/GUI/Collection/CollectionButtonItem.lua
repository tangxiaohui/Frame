local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"
require "System.LuaDelegate"

local CollectionButtonCls = Class(BaseNodeClass)

function CollectionButtonCls:Ctor(parent,id,index,red)
	self.parent = parent
	self.id = id 
	self.index = index
	self.red = red
	self.callback = LuaDelegate.New()
end

function CollectionButtonCls:SetCallback(ctable,func)
	 self.callback:Set(ctable,func)
end


-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function CollectionButtonCls:OnInit()
	--加载界面
	utility.LoadNewGameObjectAsync("UI/Prefabs/CollectionButton",function(go)
		self:BindComponent(go)
	end)
end

function CollectionButtonCls:OnComponentReady()
	--界面加载完成
	self:LinkComponent(self.parent)
	self:InitControls()
end

function CollectionButtonCls:OnResume()
	CollectionButtonCls.base.OnResume(self)
	self:RegisterControEvents()
	self:Show(self.id)
	self:SetRedDot(self.red)
end

function CollectionButtonCls:OnPause()
	CollectionButtonCls.base.OnPause(self)
	self:UnregisterControlEvents()
end

function CollectionButtonCls:OnEnter()
	CollectionButtonCls.base.OnEnter(self)
end

function CollectionButtonCls:OnExit()
	CollectionButtonCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function CollectionButtonCls:InitControls()
	local transform = self:GetUnityTransform()
	self.base = transform:Find("Base")
	self.infoButton = self.base:Find("Button"):GetComponent(typeof(UnityEngine.UI.Button))
	self.nameLabel = self.base:Find("TittleLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.clickeedObj = self.base:Find("Image").gameObject
	self.redDotImage = self.base:Find("RedDotImage").gameObject
	self.myGame = utility:GetGame()
end

function CollectionButtonCls:RegisterControEvents()
	self._event_button_onInfoButtonClicked_ = UnityEngine.Events.UnityAction(self.OnInfoButtonClicked,self)
	self.infoButton.onClick:AddListener(self._event_button_onInfoButtonClicked_)
end

function CollectionButtonCls:UnregisterControlEvents()
	if self._event_button_onInfoButtonClicked_ then
		self.infoButton.onClick:RemoveListener(self._event_button_onInfoButtonClicked_)
		self._event_button_onInfoButtonClicked_ = nil
	end
end

function  CollectionButtonCls:OnInfoButtonClicked()
	self.callback:Invoke(self.index,self.id)
end


function CollectionButtonCls:Show(id)
	if id ~= nil or id ~= "" then
		local libraryDataCls = require "StaticData.BigLibrary.BigLibrary"
		self.nameLabel.text =  libraryDataCls:GetData(id):GetName()
		if self.index == 1 then
			self.clickeedObj:SetActive(true)
		end
	end
end

function CollectionButtonCls:SelectButton(index)
	if index == self.index then
		self.clickeedObj:SetActive(true)
	else
		self.clickeedObj:SetActive(false)
	end
end

function CollectionButtonCls:SetRedDot(red)
	self.redDotImage:SetActive(red == 1)
end

return CollectionButtonCls