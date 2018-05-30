local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
local TowerItem = Class(BaseNodeClass)
require "LUT.StringTable"

function TowerItem:Ctor(parent,index)
	self.parent = parent
	self.index = index
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
local function GetPrefabNameByIndex(index)
	local temp
	if index == 1 then
		temp = "NormalLevel"
	elseif index == 2 then
		temp = "FinalLevel"
	end
	return string.format("%s%s","UI/Prefabs/",temp)
end

function TowerItem:OnInit()
	-- 加载界面(只走一次)
	local path = GetPrefabNameByIndex(self.index)
	utility.LoadNewGameObjectAsync(path, function(go)
		self:BindComponent(go,false)
	end)
end

function TowerItem:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()
end

function TowerItem:OnResume()
	-- 界面显示时调用
	TowerItem.base.OnResume(self)
	-- self:SetPanel()
end

function TowerItem:OnPause()
	-- 界面隐藏时调用
	TowerItem.base.OnPause(self)
end

function TowerItem:OnEnter()
	-- Node Enter时调用
	TowerItem.base.OnEnter(self)
end

function TowerItem:OnExit()
	-- Node Exit时调用
	TowerItem.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function TowerItem:InitControls()
	local transform = self:GetUnityTransform() 
	transform.localScale = Vector3(1,-1,1)
	--特效
	self.effect = transform:Find("Normal/Effect").gameObject

	self.PlayerFrame = transform:Find("PlayerFrame")
	self.LevelFrame = transform:Find("LevelFrame")
	--头像
	self.headIcon = self.PlayerFrame:Find("Head/Base/Icon"):GetComponent(typeof(UnityEngine.UI.Image))
	--战力
	self.powerLabel = self.PlayerFrame:Find("PowerLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	--层级
	self.levelLabel = self.LevelFrame:Find("LevelLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	--描述
	self.notice = self.LevelFrame:Find("Notice"):GetComponent(typeof(UnityEngine.UI.Text))
	self:SetPanel()
end

--设置界面加载
function TowerItem:SetPanel()
	if self.level ~= nil then
		self.PlayerFrame.gameObject:SetActive(true)
		self.LevelFrame.gameObject:SetActive(true)
		self.effect:SetActive(true)
		self:LoadPanel()
	else
		self.PlayerFrame.gameObject:SetActive(false)
		self.LevelFrame.gameObject:SetActive(false)
		self.effect:SetActive(false)
	end 
end

--加载界面
function TowerItem:LoadPanel()
	local UserDataType = require "Framework.UserDataType"
	local userData = self:GetCachedData(UserDataType.PlayerData)
	currentCardID=userData:GetHeadCardID()
	utility.LoadRoleHeadIcon(currentCardID , self.headIcon)
	self.powerLabel.text = self.power
	self.levelLabel.text = string.format(TowerString[1],self.level)
	local levelData = require "StaticData.Tower.TowerLevels":GetData(self.id)
	local descId = levelData:GetConditionInfo()
	local desc = require "StaticData.Tower.TowerConditionInfo":GetData(descId):GetContent()
	self.notice.text = desc
end

function TowerItem:SetPower(power,level,id)
	self.power = power
	self.level = level
	self.id = id
end

return TowerItem