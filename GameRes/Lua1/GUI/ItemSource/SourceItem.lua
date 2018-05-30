local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "System.LuaDelegate"
local SourceItemCls = Class(BaseNodeClass)

function SourceItemCls:Ctor(parent,id)
	self.parent = parent
	self.id = id
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function SourceItemCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/SourceItem', function(go)
		self:BindComponent(go,false)
	end)
end

function SourceItemCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()
end

function SourceItemCls:OnResume()
	-- 界面显示时调用
	SourceItemCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:ResetView()
end

function SourceItemCls:OnPause()
	-- 界面隐藏时调用
	SourceItemCls.base.OnPause(self)
	self:UnregisterControlEvents()
end

function SourceItemCls:OnEnter()
	-- Node Enter时调用
	SourceItemCls.base.OnEnter(self)
end

function SourceItemCls:OnExit()
	-- Node Exit时调用
	SourceItemCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function SourceItemCls:InitControls()
	local transform = self:GetUnityTransform()
	self.goButton = transform:Find('Button'):GetComponent(typeof(UnityEngine.UI.Button))
	self.goButtonImage = transform:Find('Button'):GetComponent(typeof(UnityEngine.UI.Image))

	self.label = transform:Find('Label'):GetComponent(typeof(UnityEngine.UI.Text))

	self.myGame = utility:GetGame()
end


function SourceItemCls:RegisterControlEvents()
	-- 注册 Base 的事件
	self.__event_button_onGoClicked__ = UnityEngine.Events.UnityAction(self.OnGoClicked, self)
	self.goButton.onClick:AddListener(self.__event_button_onGoClicked__)
end

function SourceItemCls:UnregisterControlEvents()
	-- 取消注册 Base 的事件
	if self.__event_button_onGoClicked__ then
		self.goButton.onClick:RemoveListener(self.__event_button_onGoClicked__)
		self.__event_button_onGoClicked__ = nil
	end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function SourceItemCls:OnGoClicked()
	--Base控件的点击事件处理
	local windowManager = self:GetGame():GetWindowManager()
	windowManager:CloseAll()

	local sceneManager = self:GetGame():GetSceneManager()
	local scenecount = sceneManager:GetStackCount()
	local CheckpointSceneClass = require "Scenes.CheckpointScene"
	if scenecount > 1 then
		sceneManager:ReplaceScene(CheckpointSceneClass.New(self.dungeonId))
	else
		sceneManager:PushScene(CheckpointSceneClass.New(self.dungeonId))
	end
end


------------------------------------------------------------------------
local function SetItemGray(self)
	local graymaterial = utility:GetGrayMaterial()

end

local function CheckCanGo(self,id)
	local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    local playerlever = userData:GetLevel()
    return require "Utils.ChapterLevelUtils".CanPlayTheLevel(id,playerlever)
end

local function DelayResetView(self)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	local SourceSetStaticData = require"StaticData.Source.SourceSetData":GetData(self.id)
	local sourceType = SourceSetStaticData:GetSourceType()
	local hintStr
	local canGo
	if sourceType == 1 then		
		local dungeonId = SourceSetStaticData:GetDungeonId()
		local ChapeterLevelStaticData = require"StaticData.ChapterLevel":GetData(dungeonId)
		local chapterId = ChapeterLevelStaticData:GetChapterId()
		local leverlInfoStaticData = ChapeterLevelStaticData:GetLevelInfo()
		local chapterInfoStaticData = require"StaticData.ChapterInfo":GetData(chapterId)
		local chapterNum = chapterInfoStaticData:GetNumText()
		local chapterName = chapterInfoStaticData:GetName()
		local levelName = leverlInfoStaticData:GetName()
		hintStr = string.format("%s %s - %s",chapterNum,chapterName,levelName)
		self.dungeonId = dungeonId
		canGo = CheckCanGo(self,dungeonId)
	elseif sourceType == 2 then
		canGo = false
		hintStr = SourceSetStaticData:GetInfoDesc()
	end

	self.label.text = hintStr
	if canGo then
		self.goButton.gameObject:SetActive(true)
		self.goButtonImage.material=nil
		self.goButton.enabled=true

	else
		if sourceType == 2 then
		
		self.goButton.gameObject:SetActive(false)
		end
		self.goButton.enabled=false
		self.goButtonImage.material=utility:GetGrayMaterial()

		
	end
	
end

function SourceItemCls:ResetView()
	-- 刷新显示
	self:StartCoroutine(DelayResetView)
end

return SourceItemCls