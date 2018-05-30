local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
-----------------------------------------------------------------------
local SourceWinCls = Class(BaseNodeClass)
windowUtility.SetMutex(SourceWinCls, true)

function SourceWinCls:Ctor()
end

function SourceWinCls:OnWillShow(id)
	self.id = id
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function SourceWinCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/Source', function(go)
		self:BindComponent(go)
	end)
end

function SourceWinCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function SourceWinCls:OnResume()
	-- 界面显示时调用
	SourceWinCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:ResetView()
	self:FadeIn(function(self, t,finished)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
        if finished then
        	self.ScrollRect.enabled = true
        end
    end)
end

function SourceWinCls:OnPause()
	-- 界面隐藏时调用
	SourceWinCls.base.OnPause(self)
	self:UnregisterControlEvents()
end

function SourceWinCls:OnEnter()
	-- Node Enter时调用
	SourceWinCls.base.OnEnter(self)
end

function SourceWinCls:OnExit()
	-- Node Exit时调用
	SourceWinCls.base.OnExit(self)
end

function SourceWinCls:IsTransition()
    return true
end

function SourceWinCls:OnExitTransitionDidStart(immediately)
	SourceWinCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function SourceWinCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function SourceWinCls:InitControls()
	local transform = self:GetUnityTransform()

	self.RetrunButton = transform:Find("TweenObject/RetrunButton"):GetComponent(typeof(UnityEngine.UI.Button))
	self.tweenObjectTrans = transform:Find("TweenObject")
	
	self.iconImage = transform:Find('TweenObject/MyGeneralItem/ItemIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.itemColorFrame = transform:Find('TweenObject/MyGeneralItem/Frame')
	self.DebrisIconObj = transform:Find('TweenObject/MyGeneralItem/DebrisIcon').gameObject
	self.DebrisCornerObj = transform:Find('TweenObject/MyGeneralItem/DebrisCorner').gameObject
	self.FlagObj = transform:Find('TweenObject/MyGeneralItem/Flag').gameObject

	self.countLabel = transform:Find('TweenObject/Deberis/CountLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Deberis = transform:Find('TweenObject/Deberis').gameObject
	self.nameLabel = transform:Find('TweenObject/MyGeneralItem/ItemNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ScrollRect = transform:Find('TweenObject/Scroll View'):GetComponent(typeof(UnityEngine.UI.ScrollRect))
	self.ScrollRect.enabled = false

	self.itemLayout = transform:Find('TweenObject/Scroll View/Viewport/Content')

	--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))
end

function SourceWinCls:RegisterControlEvents()
	self.__event_button_onRetrunButtonClicked__ = UnityEngine.Events.UnityAction(self.OnRetrunButtonClicked, self)
	self.RetrunButton.onClick:AddListener(self.__event_button_onRetrunButtonClicked__)

	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnRetrunButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)
end

function SourceWinCls:UnregisterControlEvents()
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

local function SetCount(self,itemType)
	if itemType == "RoleChip" then
		--@1.查询卡包是否拥有
		local roleId =  require"StaticData.RoleCrap":GetData(self.id):GetRoleId()
		local UserDataType = require "Framework.UserDataType"
		local cardBagData = self:GetCachedData(UserDataType.CardBagData)
		local roleData = cardBagData:GetRoleById(roleId)
		if roleData == nil then
			self.Deberis.gameObject:SetActive(false)
		else
			--@2.查询碎片数量
			local cardChipBagData = self:GetCachedData(UserDataType.CardChipBagData)
			local count = cardChipBagData:GetCardChipCount(self.id)
			--@3.查询进阶到下一阶碎片数量
			local stage = roleData:GetStage()
			if stage < 6 then
				local improveStaticData = require "StaticData.RoleImprove"
				local nextCount = improveStaticData:GetData(stage):GetNeedCardSuipianNum()
				self.countLabel.text = string.format("%s/%s",count,nextCount)
			else
				self.countLabel.text = count
			end
		end
	end
end

local function SetSourceItem(self)
	 local StaticData = require"StaticData.Source.SourceData":GetData(self.id)
	 local index = StaticData:GetIndex() * 100
	 local indexNum = StaticData:GetIndexNum()
	 local itemCls = require "GUI.ItemSource.SourceItem"
	 for i = 1 ,indexNum do
	 	local id = index + i
	 	local node = itemCls.New(self.itemLayout,id)
	 	self:AddChild(node)
	 end
end

local function SetItemInfo(self)
	local gameTool = require "Utils.GameTools"
	local PropUtility = require "Utils.PropUtility"
	local _,data,name,icon,itemType = gameTool.GetItemDataById(self.id)
	utility.LoadSpriteFromPath(icon,self.iconImage)
	local color = gameTool.GetItemColorByType(itemType,data)
	PropUtility.AutoSetRGBColor(self.itemColorFrame,color)
	hintActive = false
	if itemType == "Equip" then
		local isTaozhuang = data:GetTaozhuangID()
		self.FlagObj:SetActive(isTaozhuang ~= 0)
	elseif itemType == "RoleChip" or itemType == "EquipChip" then
		self.DebrisIconObj:SetActive(true)
		self.DebrisCornerObj:SetActive(true)
		hintActive = true
		name = string.format("%s%s",name,"碎片")
	end
	self.nameLabel.text = name
	self.Deberis:SetActive(hintActive)
	SetCount(self,itemType)
	SetSourceItem(self)
end

local function DelayResetView(self)
	 while (not self:IsReady()) do
		coroutine.step(1)
	end
	SetItemInfo(self)
end

function SourceWinCls:ResetView()
	self:StartCoroutine(DelayResetView)
end

function SourceWinCls:OnRetrunButtonClicked()
	self:Close()
end

return SourceWinCls