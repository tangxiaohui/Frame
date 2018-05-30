local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "LUT.StringTable"

local ProgressChargeText = Class(BaseNodeClass)

local rowCount = 5
local hight = 50
local width = 100
function  ProgressChargeText:Ctor(parent,id,index,name,number)
	self.parent = parent
	self.id = id
	self.name = name
	self.number = number
	self.index = index
end

function  ProgressChargeText:OnInit()
	utility.LoadNewGameObjectAsync("UI/Prefabs/ProgressText",function(go)
		self:BindComponent(go)
	end)
end

function ProgressChargeText:OnComponentReady()
	self:InitControls()
	self:LinkComponent(self.parent)
end

function ProgressChargeText:OnResume()
	ProgressChargeText.base.OnResume(self)
	-- self:Show(self.name,self.number)
end

function ProgressChargeText:OnPause()
	ProgressChargeText.base.OnPause(self)
end

function ProgressChargeText:OnEnter()
	ProgressChargeText.base.OnEnter(self)
	-- self.transform.sizeDelta =Vector2(width,hight)
	self:Show(self.name,self.number,self.index,self.id)
end

function ProgressChargeText:OnExit()
	ProgressChargeText.base.OnExit(self)
end

function ProgressChargeText:InitControls()
	local transform = self:GetUnityTransform()
	self.transform = transform
	self.nameLabel = transform:Find("Rank"):GetComponent(typeof(UnityEngine.UI.Text))
	self.numberLabel = transform:Find("Rankawrd"):GetComponent(typeof(UnityEngine.UI.Text))
end

function ProgressChargeText:Show(name,number,index,id)
	-- debug_print(string.format(ActivityStringTable[3],name))
	local data = require "StaticData.Activity.ProgressChargeInfo":GetData(id)
	if index == 2 then
		local title = data:GetTitle()
		self.numberLabel.gameObject:SetActive(false)
		name = string.format(ActivityStringTable[6],name,title,number)
		self.nameLabel.text = name
		self.nameLabel.transform.sizeDelta =Vector2(700,50)
	else
		local rate = data:GetRate()
		local title = data:GetTitle()
		self.numberLabel.gameObject:SetActive(true)
		self.nameLabel.text = title
		self.numberLabel.text = rate
		self.nameLabel.transform.sizeDelta =Vector2(100,50)
	end
end


return ProgressChargeText