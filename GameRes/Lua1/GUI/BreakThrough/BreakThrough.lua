local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"
local BreakThroughCls = Class(BaseNodeClass)


function BreakThroughCls:Ctor()
end

function BreakThroughCls:OnWillShow(data)
	self.cardData = data
	self.cardUid = self.cardData:GetUid()

	self.MaxBreakLevelNum = 10

	self.oldLife = self.cardData:GetHp()
	self.oldAp = self.cardData:GetAp()
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function BreakThroughCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/BreakThrough', function(go)
		self:BindComponent(go)
	end)
end

function BreakThroughCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function BreakThroughCls:OnResume()
	-- 界面显示时调用
	BreakThroughCls.base.OnResume(self)

	--记录行为
	--require "Utils.GameAnalysisUtils".RecordLocalAction(kTrackingId_CardBreakThrough)



	self:RegisterControlEvents()
	self:RegisterNetworkEvents()

	--初始化面板信息
    self:InitViews()
	self:GetGame():SendNetworkMessage(require "Network.ServerService".CardBreakRequest(self.cardData:GetId(), 0,1))


end

function BreakThroughCls:OnPause()
	-- 界面隐藏时调用
	BreakThroughCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function BreakThroughCls:OnEnter()
	-- Node Enter时调用
	BreakThroughCls.base.OnEnter(self)
end

function BreakThroughCls:OnExit()
	-- Node Exit时调用
	BreakThroughCls.base.OnExit(self)
end

function BreakThroughCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function BreakThroughCls:InitControls()
	local transform = self:GetUnityTransform()

	--返回
	self.BreakReturnButton = transform:Find('BreakReturnButton'):GetComponent(typeof(UnityEngine.UI.Button))
	--人物
	self.Stature = transform:Find('CardInfo/Stature'):GetComponent(typeof(UnityEngine.UI.Image))
	
	--Old突破数据
	self.PropertyImage = transform:Find('WindowBase/BreakLevel/Left/Property1/PropertyImage'):GetComponent(typeof(UnityEngine.UI.Image))
	self.PropertyText = transform:Find('WindowBase/BreakLevel/Left/Property1/PropertyText'):GetComponent(typeof(UnityEngine.UI.Text))
	--生命数值
	self.PropertyNumberText = transform:Find('WindowBase/BreakLevel/Left/Property1/PropertyNumberText'):GetComponent(typeof(UnityEngine.UI.Text))
	--突破等级
	self.BreakText = transform:Find('WindowBase/BreakLevel/Left/BreakText'):GetComponent(typeof(UnityEngine.UI.Text))

	self.PropertyImage1 = transform:Find('WindowBase/BreakLevel/Left/Property2/PropertyImage'):GetComponent(typeof(UnityEngine.UI.Image))
	self.PropertyText1 = transform:Find('WindowBase/BreakLevel/Left/Property2/PropertyText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.PropertyNumberText1 = transform:Find('WindowBase/BreakLevel/Left/Property2/PropertyNumberText'):GetComponent(typeof(UnityEngine.UI.Text))

	--清零提示
	self.BreakThroughPrompt = transform:Find('BreakThroughPrompt'):GetComponent(typeof(UnityEngine.UI.Text))

	--New突破数据
	self.PropertyImage2 = transform:Find('WindowBase/BreakLevel/Right/Property1/PropertyImage'):GetComponent(typeof(UnityEngine.UI.Image))
	self.PropertyText2 = transform:Find('WindowBase/BreakLevel/Right/Property1/PropertyText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.PropertyNumberText2 = transform:Find('WindowBase/BreakLevel/Right/Property1/PropertyNumberText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.BreakText1 = transform:Find('WindowBase/BreakLevel/Right/BreakText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.PropertyImage3 = transform:Find('WindowBase/BreakLevel/Right/Property2/PropertyImage'):GetComponent(typeof(UnityEngine.UI.Image))
	self.PropertyText3 = transform:Find('WindowBase/BreakLevel/Right/Property2/PropertyText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.PropertyNumberText3 = transform:Find('WindowBase/BreakLevel/Right/Property2/PropertyNumberText'):GetComponent(typeof(UnityEngine.UI.Text))
	
	-- self.BackgroundImage = transform:Find('WindowBase/BreakNumberPanel/BackgroundImage'):GetComponent(typeof(UnityEngine.UI.Image))
	
	--突破值 字
	self.TitleText = transform:Find('WindowBase/BreakNumberPanel/TitleText'):GetComponent(typeof(UnityEngine.UI.Text))
	-- self.ProgressBar = transform:Find('WindowBase/BreakNumberPanel/ProgressBar'):GetComponent(typeof(UnityEngine.UI.Image))
	--突破进度条
	self.FillImage = transform:Find('WindowBase/BreakNumberPanel/ProgressBar/FillImage'):GetComponent(typeof(UnityEngine.UI.Image))
	--百分比
	self.PercentText = transform:Find('WindowBase/BreakNumberPanel/PercentText'):GetComponent(typeof(UnityEngine.UI.Text))
	--真实数值比
	self.ProgressText = transform:Find('WindowBase/BreakNumberPanel/ProgressText'):GetComponent(typeof(UnityEngine.UI.Text))
	--突破按钮
	self.BreakThroughButton = transform:Find('WindowBase/BreakThroughButton'):GetComponent(typeof(UnityEngine.UI.RepeatButton))
	--突破 字
	self.BreakThroughButtonText = transform:Find('WindowBase/BreakThroughButton/Text'):GetComponent(typeof(UnityEngine.UI.Text))
	--突破十连Tooggle
	self.TenChooseToggle = transform:Find('WindowBase/TenChooseToggle'):GetComponent(typeof(UnityEngine.UI.Toggle))
	self.TenChooseToggleText = transform:Find('WindowBase/TenChooseToggle/TenBreak'):GetComponent(typeof(UnityEngine.UI.Text))

	-- 材料组件布局
	self.ItemLayout = transform:Find('WindowBase/MaterialLayout')
	--消耗品显示
	self.UseText = transform:Find('WindowBase/UseUp/UseText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.UseNumberText = transform:Find('WindowBase/UseUp/UseText/UseNumberText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.CardNameLabel=transform:Find("HeroCharacter/QualityGroup/QualityRank/Text"):GetComponent(typeof(UnityEngine.UI.Text))
    -- 品级颜色 --
    local qualityRank = transform:Find("HeroCharacter/QualityGroup/QualityRank")
    self.qualityRankImage = qualityRank:GetComponent(typeof(UnityEngine.UI.Image))
    self.raceIconImage=transform:Find("HeroCharacter/CardPreInfo/CardTypeBase"):GetComponent(typeof(UnityEngine.UI.Image))

	  -- 名字组 --
    local nameGroup1 = transform:Find("HeroCharacter/HeroNameGroup1")
    local nameGroup2 = transform:Find("HeroCharacter/HeroNameGroup2")
    local nameGroup3 = transform:Find("HeroCharacter/HeroNameGroup3")
    local nameGroup4 = transform:Find("HeroCharacter/HeroNameGroup4")
    local nameGroup5 = transform:Find("HeroCharacter/HeroNameGroup5")

    self.nameGroupObjects = {
        nameGroup1.gameObject,
        nameGroup2.gameObject,
        nameGroup3.gameObject,
        nameGroup4.gameObject,
        nameGroup5.gameObject,
    }

    self.nameGroupLabels = {
        nameGroup1:Find("HeroCharacter/Text"):GetComponent(typeof(UnityEngine.UI.Text)),
        nameGroup2:Find("HeroCharacter/Text"):GetComponent(typeof(UnityEngine.UI.Text)),
        nameGroup3:Find("HeroCharacter/Text"):GetComponent(typeof(UnityEngine.UI.Text)),
        nameGroup4:Find("HeroCharacter/Text"):GetComponent(typeof(UnityEngine.UI.Text)),
        nameGroup5:Find("HeroCharacter/Text"):GetComponent(typeof(UnityEngine.UI.Text)),
    }

    self.chipNode = nil

	self.TitleText.text = BreakTroughString[7]
	self.BreakThroughButtonText.text = BreakTroughString[5]
	self.TenChooseToggleText.text = BreakTroughString[3]
	self.UseText = BreakTroughString[6]
end

function BreakThroughCls:InitViews()

    utility.LoadRolePortraitImage(
		self.cardData:GetId(),
		self.Stature
	)
    --固定信息刷新
	local PropUtility = require "Utils.PropUtility"
	local color = self.cardData:GetColor()
    self.qualityRankImage.color = PropUtility.GetColorValue(color)
    local stage = self.cardData:GetStage()
    if stage <= 0 then
        self.CardNameLabel.text = Color[color]
    else
        self.CardNameLabel.text = string.format("%s +%d", Color[color], stage)
    end
	self:ReloadNames(self,self.cardData:GetInfo())
	utility.LoadRaceIcon(self.cardData:GetRace(),self.raceIconImage)


	--当前卡牌应包含的数值
	self.CurbreakLevel = self.cardData.breakLevel

	--debug_print("break ......  ", self.cardData.breakLevel, self.cardData.breakExp)

	-----------获取突破规则信息------
	local staticThrough = require("StaticData.BreakThrough.BreakTrough")
	self.curBreakThrough = staticThrough:GetData(self.CurbreakLevel)
	self:InitNeedItem(self.curBreakThrough)
	local nextLv = math.min(self.CurbreakLevel + 1, self.MaxBreakLevelNum)
	self.nextBreakThrough = staticThrough:GetData(nextLv)

	local UserDataType = require "Framework.UserDataType"
    local equipBagData = self:GetCachedData(UserDataType.ItemBagData)
    --local itemData = equipBagData:GetItem(10300250) -- --
	--debug_print("count", equipBagData:GetItemCountById(self.curBreakThrough:GetNeedType()))
	-----------从背包中获取突破石数量----
	self.breakStoneNumber = equipBagData:GetItemCountById(self.curBreakThrough:GetNeedType())

	--self:InitBreakThroughShowItem()

end

function BreakThroughCls:InitBreakThroughShowItem()
	--界面刷新
    local curData = self.curBreakThrough
    local nextData = self.nextBreakThrough
    local curBreakNum = self.cardData.breakExp
    local curBreakCloneNum = self.breakStoneNumber

    --debug_print("curBreakNum..." , curBreakNum)
    --消耗品
	self:InitNeedItem(curData)
	self.BreakText.text = curData:GetName() 

	--当前突破级别的附加属性
	self.PropertyNumberText.text = curData:GetStatusNum()[0].."%"
	self.PropertyNumberText1.text = curData:GetStatusNum()[1].."%"
	self.BreakText1.text = nextData:GetName() 
	self.PropertyNumberText2.text = nextData:GetStatusNum()[0].."%"
	self.PropertyNumberText3.text = nextData:GetStatusNum()[1].."%"

	--进度条
	local percent
	if curData:GetId() >= self.MaxBreakLevelNum then
		self.PercentText.text = "MAX"
		self.ProgressText.text = "MAX"
		self.FillImage.fillAmount = 1
		percent = 100
	else
		percent = curBreakNum * 100 / curData:GetMaxExp()
		self.PercentText.text = string.format("%d", percent).."%"
		self.ProgressText.text = curBreakNum..'/'..curData:GetMaxExp()
		self.FillImage.fillAmount = curBreakNum / curData:GetMaxExp()
	end

	

    --十连抽
	local needNumber = curData:GetMinAdd()
	if self.TenChooseToggle.isOn then
		needNumber = needNumber * 10
	end
 --    if(curBreakCloneNum >= needNumber * 10) then
 --    	needNumber = needNumber * 10
	-- 	self.TenChooseToggle.isOn = true
	-- else
	-- 	self.TenChooseToggle.isOn = false
 --    end

    --消耗品数量，背包中不足时显示红色
    self.UseNumberText.text = curBreakCloneNum..'/'..needNumber
	if needNumber <= curBreakCloneNum then
		self.UseNumberText.color = UnityEngine.Color(1, 1, 1, 1)
	else
		self.UseNumberText.color = UnityEngine.Color(1, 0, 0, 1)
    end

	--突破信息提示(当前进度大于60%时，提示较大概率成功)
    if percent >= 60 then
		self.BreakThroughPrompt.text = BreakTroughString[1]
	else
		self.BreakThroughPrompt.text = BreakTroughString[0]
		--end
    end
end

function BreakThroughCls:InitNeedItem(curData)

	local gameTool = require "Utils.GameTools"
	local _,data,name,icon,itemType = gameTool.GetItemDataById(curData:GetNeedType())
	local color = gameTool.GetItemColorByType(itemType,data)

	if self.chipNode == nil then
		self.chipNode = require "GUI.Item.GeneralItem".New(self.ItemLayout, curData:GetNeedType(), curData:GetMinAdd(), color)
	else
		self:RemoveChild(self.chipNode)
		self.chipNode:Set(self.ItemLayout, curData:GetNeedType(), curData:GetMinAdd(), color)
	end
	self:AddChild(self.chipNode)
end

function BreakThroughCls:ReloadNames(self, name)
    local StringUtility = require "Utils.StringUtility"
    local nameGroupCount = #self.nameGroupObjects
    local nameArray = StringUtility.CreateArray(name)
    local nameLength = math.min(nameGroupCount, #nameArray)
    for i = 1, nameGroupCount do
        local show = i <= nameLength
        self.nameGroupObjects[i]:SetActive(show)
        if show then
            self.nameGroupLabels[i].text = nameArray[i]
        end
    end
end


function BreakThroughCls:OnCardGradeUpResponse(msg)

	--level  exp cardId
	--突破成功
	local oldInfo,newInfo = self:GetInfo(self)
	self.riseType = 3

	local windowManager = self:GetGame():GetWindowManager()
    windowManager:Show(require "GUI.GeneralCard.CardUpGradeResult",self.riseType,self.cardData,oldInfo,newInfo)

end

function BreakThroughCls:GetInfo(self)
	local oldInfo = {}
	-- 当前的
	oldInfo.life = self.oldLife
	oldInfo.ap = self.oldAp
	oldInfo.dp = self.cardData:GetDp()
	oldInfo.speed = self.cardData:GetSpeed()

    --计算方式
	--local hpRateOffset = self.nextBreakThrough:GetStatusNum()[0] - self.curBreakThrough:GetStatusNum()[0]
	--local apRateOffset = self.nextBreakThrough:GetStatusNum()[1] - self.curBreakThrough:GetStatusNum()[1]
	--newInfo.life = math.floor(self.cardData:GetHpValue() * (self.cardData:GetHpRate() + hpRateOffset) * 0.01)
	--newInfo.ap = math.floor(self.cardData:GetApValue() * (self.cardData:GetApRate() + apRateOffset) * 0.01)
	--newInfo.dp = self.cardData:GetDp()
	--newInfo.speed = self.cardData:GetSpeed()

	local newInfo = {}
	newInfo.life = self.cardData:GetHp()
	newInfo.ap = self.cardData:GetAp()
	newInfo.dp = self.cardData:GetDp()
	newInfo.speed = self.cardData:GetSpeed()
	self.oldLife = self.cardData:GetHp()
	self.oldAp = self.cardData:GetAp()

	newInfo.stageStr = BreakTroughString[5]..'+'..self.nextBreakThrough:GetId()

	return oldInfo,newInfo
end


function BreakThroughCls:RegisterControlEvents()
	-- 注册 返回 的事件
	self.__event_button_onBreakReturnButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBreakReturnButtonClicked, self)
	self.BreakReturnButton.onClick:AddListener(self.__event_button_onBreakReturnButtonClicked__)

	-- 注册 突破按钮单击 的事件
	self.__event_button_onBreakThroughButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBreakThroughButtonClicked, self)
	self.BreakThroughButton.onClick:AddListener(self.__event_button_onBreakThroughButtonClicked__)

	-- 长按
	self._event_button_onBreakThroughButtonRepeatClicked = UnityEngine.Events.UnityAction(self.OnBreakThroughButtonRepeatClicked, self)
    self.BreakThroughButton.m_OnRepeat:AddListener(self._event_button_onBreakThroughButtonRepeatClicked)

    self._event_button_onBreakThroughButtonPointerDown = UnityEngine.Events.UnityAction(self.OnBreakThroughButtonPointerDown, self)
    self.BreakThroughButton.m_OnPointerDown:AddListener(self._event_button_onBreakThroughButtonPointerDown)

	self._event_button_onBreakThroughButtonPointerUp = UnityEngine.Events.UnityAction(self.OnBreakThroughButtonPointerUp, self)
    self.BreakThroughButton.m_OnPointerUp:AddListener(self._event_button_onBreakThroughButtonPointerUp)


	-- 注册 TenChooseToggle 的事件
	self.__event_toggle_onTenChooseToggleValueChanged__ = UnityEngine.Events.UnityAction_bool(self.OnTenChooseToggleValueChanged, self)
	self.TenChooseToggle.onValueChanged:AddListener(self.__event_toggle_onTenChooseToggleValueChanged__)

end

function BreakThroughCls:UnregisterControlEvents()
	-- 取消注册 返回按钮 的事件
	if self.__event_button_onBreakReturnButtonClicked__ then
		self.BreakReturnButton.onClick:RemoveListener(self.__event_button_onBreakReturnButtonClicked__)
		self.__event_button_onBreakReturnButtonClicked__ = nil
	end

	--取消注册 长按事件 的事件
	-- if self.OnBreakThroughButtonRepeatClicked then
	-- 	self.BreakThroughButton.m_OnRepeat:RemoveListener(self._event_button_onBreakThroughButtonRepeatClicked)
	-- end

	if self.OnBreakThroughButtonPointerDown then
		self.BreakThroughButton.m_OnPointerDown:RemoveListener(self._event_button_onBreakThroughButtonPointerDown)
	end

	if self.OnBreakThroughButtonPointerUp then
		self.BreakThroughButton.m_OnPointerUp:RemoveListener(self._event_button_onBreakThroughButtonPointerUp)
	end


	-- 取消注册 单击 的事件
	if self.__event_button_onBreakThroughButtonClicked__ then
		self.BreakThroughButton.onClick:RemoveListener(self.__event_button_onBreakThroughButtonClicked__)
		self.BreakThroughButton.m_OnRepeat:RemoveListener(self._event_button_onBreakThroughButtonRepeatClicked)
		self.__event_button_onBreakThroughButtonClicked__ = nil
	end

	-- 取消注册 TenChooseToggle 的事件
	if self.__event_toggle_onTenChooseToggleValueChanged__ then
		self.TenChooseToggle.onValueChanged:RemoveListener(self.__event_toggle_onTenChooseToggleValueChanged__)
		self.__event_toggle_onTenChooseToggleValueChanged__ = nil
	end

end

function BreakThroughCls:RegisterNetworkEvents()
	--- 注册网络事件
	self:GetGame():RegisterMsgHandler(net.S2CCardBreakResult,self,self.OnBreakThroughResult)
end

function BreakThroughCls:UnregisterNetworkEvents()
	--- 注销网络事件
	self:GetGame():UnRegisterMsgHandler(net.S2CCardBreakResult,self,self.OnBreakThroughResult)
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function BreakThroughCls:OnBreakReturnButtonClicked()
	--BreakReturnButton控件的点击事件处理
	self:Close()
end


function BreakThroughCls:OnBreakThroughButtonClicked()
	-- 发送突破协议  参数：是不是十连抽
	local times = self.TenChooseToggle.isOn and 10 or 1
	local isPaly = self:BreakThroughRequest(times)

	-- if isPaly then
	-- 	--返回协议
	-- 	--包含  消耗值 是否升级，卡牌信息
	-- end
end

function BreakThroughCls:OnBreakThroughButtonRepeatClicked()

	local times = self.TenChooseToggle.isOn and 10 or 1
	local isPaly = self:BreakThroughRequest(times)

	if isPaly then
		--返回协议
		--包含  消耗值 是否升级，卡牌信息
	end
end

function BreakThroughCls:OnBreakThroughButtonPointerDown()
	--debug_print("PointerDown")
end

function BreakThroughCls:OnBreakThroughButtonPointerUp()
	--debug_print("PointerUp")
end

function BreakThroughCls:OnTenChooseToggleValueChanged(isToggle)

	local needNumber = self.curBreakThrough:GetMinAdd()

	if isToggle then

		needNumber = isToggle and needNumber * 10 or needNumber

		if(self.breakStoneNumber >= needNumber) then
			self.TenChooseToggle.isOn = true
		else
			needNumber = self.curBreakThrough:GetMinAdd()
			self.TenChooseToggle.isOn = false
	    end
	else
		self.TenChooseToggle.isOn = false
	end
	self.UseNumberText.text = self.breakStoneNumber..'/'..needNumber
end


-----------------------------------------------------------------------
--- 网络处理
-----------------------------------------------------------------------
function BreakThroughCls:BreakThroughRequest(times)
	--- 发送请求

	local needNumber = self.curBreakThrough:GetMinAdd() * times
	local isPlaying
    	
    if self.CurbreakLevel >= self.MaxBreakLevelNum then
	   	self:ShowErrorTip(BreakTroughString[8])
    elseif self.breakStoneNumber < needNumber then
		self:ShowErrorTip(BreakTroughString[2])
	else
		--debug_print("Send ... ", self.cardData:GetId(), times)
		self:GetGame():SendNetworkMessage(require "Network.ServerService".CardBreakRequest(self.cardData:GetId(), times,0))
		-- local  msg ,prototype = require"Network/ServerService".CardBreakRequest(self.cardData:GetId(), times)--self.cardUid
	  
		isPlaying = true
    end

	return isPlaying
end


function BreakThroughCls:OnBreakThroughResult(msg)
	--debug_print("Result : ", self.cardData.breakLevel, self.cardData.breakExp)
	
	if self.cardData.breakLevel > self.CurbreakLevel then
		self.CurbreakLevel = self.cardData.breakLevel
		self:OnCardGradeUpResponse(msg)
	end

	local UserDataType = require "Framework.UserDataType"
    local equipBagData = self:GetCachedData(UserDataType.ItemBagData)
    self.breakStoneNumber = equipBagData:GetItemCountById(self.curBreakThrough:GetNeedType())

	local staticThrough = require("StaticData.BreakThrough.BreakTrough")
    self.curBreakThrough = staticThrough:GetData(self.CurbreakLevel)
	local nextLv = math.min(self.CurbreakLevel + 1, self.MaxBreakLevelNum)
	self.nextBreakThrough = staticThrough:GetData(nextLv)
	--更新界面
    self:InitBreakThroughShowItem()

end

function BreakThroughCls:ShowErrorTip(msg)
	--- 弹出提示框，，，
	local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
	local windowManager = self:GetGame():GetWindowManager()
   	windowManager:Show(ErrorDialogClass, msg)
end

return BreakThroughCls
