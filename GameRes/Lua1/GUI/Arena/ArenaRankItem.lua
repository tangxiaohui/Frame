local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local ArenaRankCls = Class(BaseNodeClass)
require "Const"

function ArenaRankCls:Ctor(parent,index)
	self.parent = parent
	self.index = index
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
local function GetPrefabNameByIndex(index)
	local temp
	if index == 1 then
		temp = "01"
	elseif index == 2 then
		temp = "02"
	elseif index == 3 then
		temp = "03"
	elseif index % 2 == 0 then
		temp = "Even"
	elseif index % 2 == 1 then
		temp = "Singular"
	end
	return string.format("%s%s","UI/Prefabs/ArenaRank",temp)
end

function ArenaRankCls:OnInit()
	-- 加载界面(只走一次)
	local path = GetPrefabNameByIndex(self.index)
	utility.LoadNewGameObjectAsync(path, function(go)
		self:BindComponent(go,false)
	end)
end

function ArenaRankCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()
end

function ArenaRankCls:OnResume()
	-- 界面显示时调用
	ArenaRankCls.base.OnResume(self)
	self:RegisterControlEvents()
	--self:RegisterNetworkEvents()
end

function ArenaRankCls:OnPause()
	-- 界面隐藏时调用
	ArenaRankCls.base.OnPause(self)
	self:UnregisterControlEvents()
	--self:UnregisterNetworkEvents()
end

function ArenaRankCls:OnEnter()
	-- Node Enter时调用
	ArenaRankCls.base.OnEnter(self)
end

function ArenaRankCls:OnExit()
	-- Node Exit时调用
	ArenaRankCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function ArenaRankCls:InitControls()
	local transform = self:GetUnityTransform()
	self.Base = transform:Find('Base'):GetComponent(typeof(UnityEngine.UI.Image))
	--self.GrayBase = transform:Find('GrayBase'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Title = transform:Find('Title').gameObject
	self.TitleLabel = transform:Find('Title/TitleLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ArenaRankNameLabel = transform:Find('Strength/NameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.HeadIcon = transform:Find('Head/Mask/HeadIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.HeadButton = transform:Find('Head/Mask/HeadIcon'):GetComponent(typeof(UnityEngine.UI.Button))
	self.LvImage = transform:Find('Lv/LvImage'):GetComponent(typeof(UnityEngine.UI.Image))
	self.LvNumLabel = transform:Find('Lv/LvNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.StrengthLabel = transform:Find('Strength/StrengthLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.StrengthNumLabel = transform:Find('Strength/StrengthNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Strength = transform:Find('Strength')
	self.PointLabel = self.Strength:Find('PointLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	-- 排名
	if self.index > 3 then
		self.RankLabel = transform:Find('RankLabel'):GetComponent(typeof(UnityEngine.UI.Text))
		self.RankLabel.text = self.index
	end
	--self.RankingNumImage = transform:Find('RankingNumImage'):GetComponent(typeof(UnityEngine.UI.Image))

	self.myGame = utility:GetGame()
	self.pos = self.Title.transform.localPosition
	self.transform = transform
end


function ArenaRankCls:RegisterControlEvents()
	-- self.__event_button_OnHeadButtonClicked__ = UnityEngine.Events.UnityAction(self.OnHeadButtonClicked, self)
	-- self.HeadButton.onClick:AddListener(self.__event_button_OnHeadButtonClicked__)
end

function ArenaRankCls:UnregisterControlEvents()
	-- if self.__event_button_OnHeadButtonClicked__ then
		-- self.HeadButton.onClick:RemoveListener(self.__event_button_OnHeadButtonClicked__)
		-- self.__event_button_OnHeadButtonClicked__ = nil
	-- end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function ArenaRankCls:ToDoConfirmButton()
	-- todo 确定按钮点击事件
end
function ArenaRankCls:OnHeadButtonClicked()
	local windowManager = self.myGame:GetWindowManager()
    windowManager:Show(require "GUI.Formation.ArenaEnemyFormation",self.playerUID,nil,nil,self.ToDoConfirmButton,self)
end

function ArenaRankCls:ResetView(info,rankState)
	-- 刷新显示界面
	if info == nil then
		-- self.transform.gameObject:SetActive(false)
		return
	else
		-- self.transform.gameObject:SetActive(true)
	end
	self.playerUID = info.playerUID
	-- name
	self.ArenaRankNameLabel.text = info.playerName

	-- Lv
	self.LvNumLabel.text = info.playerLevel
	
	-- 军衔
	if rankState == kArenaRank then
		-- self.Strength.localPosition = Vector2(self.pos.x + 110,-87)
		--rank
		self.StrengthNumLabel.text = info.zhanli
		self.Title:SetActive(true)
		self.PointLabel.gameObject:SetActive(false)
		self.StrengthLabel.gameObject:SetActive(true)
		local arenaTitleData = require "StaticData.Arena.ArenaTitleData"
		self.TitleLabel.text = arenaTitleData:GetData(info.junxian):GetName()
	elseif rankState == kGuildFightRank then
		--rank
		self.StrengthNumLabel.text = info.score
		-- self.Strength.localPosition = Vector2(self.pos.x + 50,-87)
		self.PointLabel.gameObject:SetActive(true)
		self.PointLabel.text = "积分："
		self.StrengthLabel.gameObject:SetActive(false)
		self.Title:SetActive(false)
	elseif rankState == kTowerRank then
		self.StrengthNumLabel.text = info.maxStar
		self.PointLabel.gameObject:SetActive(true)
		self.PointLabel.text = "星级："
		self.StrengthLabel.gameObject:SetActive(false)
		self.Title:SetActive(false)
	end
	if rankState ~= kTowerRank then
	-- 设置头像
		utility.LoadPlayerHeadIcon(info.headCardID,self.HeadIcon)
	else
		utility.LoadPlayerHeadIcon(info.headID,self.HeadIcon)
	end
end


return ArenaRankCls