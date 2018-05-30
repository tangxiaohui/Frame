-----------------------------------------------------------------------
---卡牌升级面板
-----------------------------------------------------------------------
local BaseNodeClass = require "Framework.Base.Node"
local utility = require "Utils.Utility"
local net = require "Network.Net"
local SkinLevelUp = Class(BaseNodeClass)
local RolePromote = require "StaticData.RolePromote"
local UserDataType = require "Framework.UserDataType"


function SkinLevelUp:Ctor(transform)
	self:BindComponent(transform.gameObject, true)
	self:InitControls()
end

local function SetExpBattery(self,i,num)
	--- 设置经验电池数量
	if i == 1 then
	    self.ExpItemNumLabels[i].text = num
	elseif i == 2 then
		self.ExpItemNumLabels[i].text = num
	elseif i == 3 then
		self.ExpItemNumLabels[i].text = num
	elseif i == 4 then
		self.ExpItemNumLabels[i].text = num
	end
end


function SkinLevelUp:OnResume()
	-- 界面显示时调用
	SkinLevelUp.base.OnResume(self)
	
	-- require "Utils.GameAnalysisUtils".RecordLocalAction(kTrackingId_CardPowerUpView)

	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	
	
	----------------------初始化界面----------------------------
	self:GetItemBagData()
	self:InitExpColor()
end

function SkinLevelUp:OnPause()
	-- 界面隐藏时调用
    SkinLevelUp.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function SkinLevelUp:OnEnter()
	-- Node Enter时调用
    SkinLevelUp.base.OnEnter(self)
    self.transform.gameObject:SetActive(false)
end

function SkinLevelUp:OnExit()
	-- Node Exit时调用
    SkinLevelUp.base.OnExit(self)
	
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
local function ResetCanvasRect(uiCanvas)
	uiCanvas.anchorMax = Vector2(1,1)
	uiCanvas.anchorMin = Vector2(0,0)
	uiCanvas.offsetMax = Vector2(0,0)
	uiCanvas.offsetMin = Vector2(0,0)
end

function SkinLevelUp:InitControls()
	local transform = self:GetUnityTransform()
	self.transform = transform

	self.levelUpReturnButton = transform:Find("Return"):GetComponent(typeof(UnityEngine.UI.Button))
	--- 经验电池 图标，颜色，按钮，数量，，，名字，，，
	self.ExpItemIcons = {
	    transform:Find('ExpItemLayout/ExpItem01/Base/Icon'):GetComponent(typeof(UnityEngine.UI.Image)),
	    transform:Find('ExpItemLayout/ExpItem02/Base/Icon'):GetComponent(typeof(UnityEngine.UI.Image)),
	    transform:Find('ExpItemLayout/ExpItem03/Base/Icon'):GetComponent(typeof(UnityEngine.UI.Image)),
	    transform:Find('ExpItemLayout/ExpItem04/Base/Icon'):GetComponent(typeof(UnityEngine.UI.Image)),
	}
	
	self.ExpItemColors = {
	    transform:Find('ExpItemLayout/ExpItem01/Frame'),
		transform:Find('ExpItemLayout/ExpItem02/Frame'),
		transform:Find('ExpItemLayout/ExpItem03/Frame'),
		transform:Find('ExpItemLayout/ExpItem04/Frame'),
	}
	
	self.ExpItemBtns = {
    	transform:Find('ExpItemLayout/ExpItem01/Frame'):GetComponent(typeof(UnityEngine.UI.RepeatButton)),
		transform:Find('ExpItemLayout/ExpItem02/Frame'):GetComponent(typeof(UnityEngine.UI.RepeatButton)),
		transform:Find('ExpItemLayout/ExpItem03/Frame'):GetComponent(typeof(UnityEngine.UI.RepeatButton)),
		transform:Find('ExpItemLayout/ExpItem04/Frame'):GetComponent(typeof(UnityEngine.UI.RepeatButton)),
	}

	self.ExpItemNumLabels = {
	    transform:Find('ExpItemLayout/ExpItem01/NumLabel'):GetComponent(typeof(UnityEngine.UI.Text)),
		transform:Find('ExpItemLayout/ExpItem02/NumLabel'):GetComponent(typeof(UnityEngine.UI.Text)),
		transform:Find('ExpItemLayout/ExpItem03/NumLabel'):GetComponent(typeof(UnityEngine.UI.Text)),
		transform:Find('ExpItemLayout/ExpItem04/NumLabel'):GetComponent(typeof(UnityEngine.UI.Text)),
	}

	local EffectCanvasTable = {
		transform:Find('ExpItemLayout/ExpItem01/EffectCanvas'):GetComponent(typeof(UnityEngine.RectTransform)),
		transform:Find('ExpItemLayout/ExpItem02/EffectCanvas'):GetComponent(typeof(UnityEngine.RectTransform)),
		transform:Find('ExpItemLayout/ExpItem03/EffectCanvas'):GetComponent(typeof(UnityEngine.RectTransform)),
		transform:Find('ExpItemLayout/ExpItem04/EffectCanvas'):GetComponent(typeof(UnityEngine.RectTransform)),
	}
	ResetCanvasRect(EffectCanvasTable[1])
	ResetCanvasRect(EffectCanvasTable[2])
	ResetCanvasRect(EffectCanvasTable[3])
	ResetCanvasRect(EffectCanvasTable[4])

	self.ExpItemEffectTable = {
		transform:Find('ExpItemLayout/ExpItem01/EffectCanvas/UI_jueseshengji_1/Glow'):GetComponent(typeof(UnityEngine.ParticleSystem)),
		transform:Find('ExpItemLayout/ExpItem02/EffectCanvas/UI_jueseshengji_1/Glow'):GetComponent(typeof(UnityEngine.ParticleSystem)),
		transform:Find('ExpItemLayout/ExpItem03/EffectCanvas/UI_jueseshengji_1/Glow'):GetComponent(typeof(UnityEngine.ParticleSystem)),
		transform:Find('ExpItemLayout/ExpItem04/EffectCanvas/UI_jueseshengji_1/Glow'):GetComponent(typeof(UnityEngine.ParticleSystem)),
	}
	
	
	
	self.myGame = utility:GetGame()
	-- 经验电池
	self.expbatteryIdTable = {10300131,10300132,10300133,10300134}
end


function SkinLevelUp:RegisterControlEvents()
	-- 注册 levelUpReturnButton 的事件
	self._event_button_onLevelUpReturnButtonClicked_ = UnityEngine.Events.UnityAction(self.OnLevelUpReturnButtonClicked,self)
	self.levelUpReturnButton.onClick:AddListener(self._event_button_onLevelUpReturnButtonClicked_)

   self._event_button_onExpBatteryButton1Clicked = UnityEngine.Events.UnityAction(self.OnExpBatteryButton1Clicked, self)
   self.ExpItemBtns[1].onClick:AddListener(self._event_button_onExpBatteryButton1Clicked)
	--长按
    self._event_button_onExpBatteryButton1RepeatClicked = UnityEngine.Events.UnityAction(self.OnExpBatteryButton1RepeatClicked, self)
    self.ExpItemBtns[1].m_OnRepeat:AddListener(self._event_button_onExpBatteryButton1RepeatClicked)

    self._event_button_onExpBatteryButton1PointerDown = UnityEngine.Events.UnityAction(self.OnExpBatteryButton1PointerDown, self)
    self.ExpItemBtns[1].m_OnPointerDown:AddListener(self._event_button_onExpBatteryButton1PointerDown)

    self._event_button_onExpBatteryButtonPointerUp = UnityEngine.Events.UnityAction(self.OnExpBatteryButtonPointerUp, self)
    self.ExpItemBtns[1].m_OnPointerUp:AddListener(self._event_button_onExpBatteryButtonPointerUp)

	self._event_button_onExpBatteryButton2Clicked = UnityEngine.Events.UnityAction(self.OnExpBatteryButton2Clicked, self)
    self.ExpItemBtns[2].onClick:AddListener(self._event_button_onExpBatteryButton2Clicked)
	--长按
	self._event_button_onExpBatteryButton2RepeatClicked = UnityEngine.Events.UnityAction(self.OnExpBatteryButton2RepeatClicked, self)
    self.ExpItemBtns[2].m_OnRepeat:AddListener(self._event_button_onExpBatteryButton2RepeatClicked)

    self._event_button_onExpBatteryButton2PointerDown = UnityEngine.Events.UnityAction(self.OnExpBatteryButton2PointerDown, self)
    self.ExpItemBtns[2].m_OnPointerDown:AddListener(self._event_button_onExpBatteryButton2PointerDown)

    self.ExpItemBtns[2].m_OnPointerUp:AddListener(self._event_button_onExpBatteryButtonPointerUp)

	self._event_button_onExpBatteryButton3Clicked = UnityEngine.Events.UnityAction(self.OnExpBatteryButton3Clicked, self)
    self.ExpItemBtns[3].onClick:AddListener(self._event_button_onExpBatteryButton3Clicked)
    --长按
    self._event_button_onExpBatteryButton3RepeatClicked = UnityEngine.Events.UnityAction(self.OnExpBatteryButton3RepeatClicked, self)
    self.ExpItemBtns[3].m_OnRepeat:AddListener(self._event_button_onExpBatteryButton3RepeatClicked)

    self._event_button_onExpBatteryButton3PointerDown = UnityEngine.Events.UnityAction(self.OnExpBatteryButton3PointerDown, self)
    self.ExpItemBtns[3].m_OnPointerDown:AddListener(self._event_button_onExpBatteryButton3PointerDown)

    self.ExpItemBtns[3].m_OnPointerUp:AddListener(self._event_button_onExpBatteryButtonPointerUp)

    self._event_button_onExpBatteryButton4Clicked = UnityEngine.Events.UnityAction(self.OnExpBatteryButton4Clicked, self)
    self.ExpItemBtns[4].onClick:AddListener(self._event_button_onExpBatteryButton4Clicked)
    --长按
    self._event_button_onExpBatteryButton4RepeatClicked = UnityEngine.Events.UnityAction(self.OnExpBatteryButton4RepeatClicked, self)
    self.ExpItemBtns[4].m_OnRepeat:AddListener(self._event_button_onExpBatteryButton4RepeatClicked)

    self._event_button_onExpBatteryButton4PointerDown = UnityEngine.Events.UnityAction(self.OnExpBatteryButton4PointerDown, self)
    self.ExpItemBtns[4].m_OnPointerDown:AddListener(self._event_button_onExpBatteryButton4PointerDown)

    self.ExpItemBtns[4].m_OnPointerUp:AddListener(self._event_button_onExpBatteryButtonPointerUp)

end

function SkinLevelUp:OnExpBatteryButton1PointerDown()
	local UserDataType = require "Framework.UserDataType"
	local data = self:GetCachedData(UserDataType.ItemBagData)
	local count = data:GetItemCountById(self.expbatteryIdTable[1])
	if  count > 0 and (not self.ExpItemEffectTable[1].isPlaying) then
		self.ExpItemEffectTable[1]:Play()
	end	
end

function SkinLevelUp:OnExpBatteryButton2PointerDown()
	local UserDataType = require "Framework.UserDataType"
	local data = self:GetCachedData(UserDataType.ItemBagData)
	local count = data:GetItemCountById(self.expbatteryIdTable[2])
	if  count > 0 and (not self.ExpItemEffectTable[2].isPlaying) then
		self.ExpItemEffectTable[2]:Play()
	end
end

function SkinLevelUp:OnExpBatteryButton3PointerDown()
	local UserDataType = require "Framework.UserDataType"
	local data = self:GetCachedData(UserDataType.ItemBagData)
	local count = data:GetItemCountById(self.expbatteryIdTable[3])
	if  count > 0 and (not self.ExpItemEffectTable[3].isPlaying) then
		self.ExpItemEffectTable[3]:Play()
	end
end

function SkinLevelUp:OnExpBatteryButton3PointerDown()
	local UserDataType = require "Framework.UserDataType"
	local data = self:GetCachedData(UserDataType.ItemBagData)
	local count = data:GetItemCountById(self.expbatteryIdTable[4])
	if  count > 0 and (not self.ExpItemEffectTable[4].isPlaying) then
		self.ExpItemEffectTable[4]:Play()
	end
end


function SkinLevelUp:OnExpBatteryButtonPointerUp( )
	self.ExpItemEffectTable[1]:Stop()
	self.ExpItemEffectTable[2]:Stop()
	self.ExpItemEffectTable[3]:Stop()
	self.ExpItemEffectTable[4]:Stop()
end

function SkinLevelUp:UnregisterControlEvents()
	-- 取消注册 levelButton 的事件
	if self._event_button_onLevelButtonClicked_ then
		self.levelButton.onClick:RemoveListener(self._event_button_onLevelButtonClicked_)
		self._event_button_onLevelButtonClicked_ = nil
	end
	if self._event_button_onExpBatteryButton1Clicked then
		self.ExpItemBtns[1].onClick:RemoveListener(self._event_button_onExpBatteryButton1Clicked)
		self.ExpItemBtns[1].m_OnRepeat:RemoveListener(self._event_button_onExpBatteryButton1RepeatClicked)
		self._event_button_onExpBatteryButton1Clicked = nil
	end

	if self._event_button_onExpBatteryButton2Clicked then
		self.ExpItemBtns[2].onClick:RemoveListener(self._event_button_onExpBatteryButton2Clicked)
		self.ExpItemBtns[2].m_OnRepeat:RemoveListener(self._event_button_onExpBatteryButton2RepeatClicked)
		self._event_button_onExpBatteryButton2Clicked = nil
	end

	if self._event_button_onExpBatteryButton3Clicked then
		self.ExpItemBtns[3].onClick:RemoveListener(self._event_button_onExpBatteryButton3Clicked)
		self.ExpItemBtns[3].m_OnRepeat:RemoveListener(self._event_button_onExpBatteryButton3RepeatClicked)
		self._event_button_onExpBatteryButton3Clicked = nil
	end

	if self._event_button_onExpBatteryButton4Clicked then
		self.ExpItemBtns[4].onClick:RemoveListener(self._event_button_onExpBatteryButton4Clicked)
		self.ExpItemBtns[4].m_OnRepeat:RemoveListener(self._event_button_onExpBatteryButton4RepeatClicked)
		self._event_button_onExpBatteryButton4Clicked = nil
	end

	if self.OnExpBatteryButton1PointerDown then
		self.ExpItemBtns[1].m_OnPointerDown:RemoveListener(self._event_button_onExpBatteryButton1PointerDown)
	end

	if self.OnExpBatteryButton2PointerDown then
		self.ExpItemBtns[2].m_OnPointerDown:RemoveListener(self._event_button_onExpBatteryButton2PointerDown)
	end

	if self.OnExpBatteryButton3PointerDown then
		self.ExpItemBtns[3].m_OnPointerDown:RemoveListener(self._event_button_onExpBatteryButton3PointerDown)
	end

	if self.OnExpBatteryButton43PointerDown then
		self.ExpItemBtns[4].m_OnPointerDown:RemoveListener(self._event_button_onExpBatteryButton4PointerDown)
	end

	if self.OnExpBatteryButtonPointerUp then
		self.ExpItemBtns[1].m_OnPointerUp:RemoveListener(self._event_button_onExpBatteryButtonPointerUp)
		self.ExpItemBtns[2].m_OnPointerUp:RemoveListener(self._event_button_onExpBatteryButtonPointerUp)
		self.ExpItemBtns[3].m_OnPointerUp:RemoveListener(self._event_button_onExpBatteryButtonPointerUp)
		self.ExpItemBtns[4].m_OnPointerUp:RemoveListener(self._event_button_onExpBatteryButtonPointerUp)
	end

end


function SkinLevelUp:RegisterNetworkEvents()
	--- 注册网络事件
	self.myGame:RegisterMsgHandler(net.S2CCardSkinUpgradeResult,self,self.OnCardProResult)
end

function SkinLevelUp:UnregisterNetworkEvents()
	--- 注销网络事件
	self.myGame:UnRegisterMsgHandler(net.S2CCardSkinUpgradeResult,self,self.OnCardProResult)
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function SkinLevelUp:OnLevelUpReturnButtonClicked()
	self.transform.gameObject:SetActive(false)
	-- self:Hide(true)
end

local function ShowErrorTip(self,msg)
	--- 弹出提示框，，，
	local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
	local windowManager = self.myGame:GetWindowManager()
   	windowManager:Show(ErrorDialogClass, msg)
end

function SkinLevelUp:OnExpBatteryButton1Clicked()
	--- 经验电池点击事件处理
	local isPaly = self:CardProRequest(self.cardId ,1,0,0,0)
	if isPaly then
		self.showEffect = self.ExpItemEffectTable[1]
		self.showEffect:Play()
	end
end

function SkinLevelUp:OnExpBatteryButton2Clicked()
	--- 高能经验电池点击事件处理
	local isPaly = self:CardProRequest(self.cardId,0,1,0,0)
	if isPaly then
		self.showEffect = self.ExpItemEffectTable[2]
		self.showEffect:Play()
	end
end

function SkinLevelUp:OnExpBatteryButton3Clicked()
	--- 超能经验电池点击事件处理
	local isPaly = self:CardProRequest(self.cardId,0,0,1,0)
	if isPaly then
		self.showEffect = self.ExpItemEffectTable[3]
		self.showEffect:Play()
	end
end

function SkinLevelUp:OnExpBatteryButton4Clicked()
	--- 超能经验电池点击事件处理
	local isPaly = self:CardProRequest(self.cardId,0,0,0,1)
	if isPaly then
		self.showEffect = self.ExpItemEffectTable[4]
		self.showEffect:Play()
	end
end

function SkinLevelUp:OnExpBatteryButton1RepeatClicked()
	local isPaly = self:CardProRequest(self.cardId,1,0,0,0)
	if isPaly then
		self.showEffect = self.ExpItemEffectTable[1]
		self:PlayExpEffect()
	end
end

function SkinLevelUp:OnExpBatteryButton2RepeatClicked()
	local isPaly = self:CardProRequest(self.cardId,0,1,0,0)
	if isPaly then
		self.showEffect = self.ExpItemEffectTable[2]
		self:PlayExpEffect()
	end
end

function SkinLevelUp:OnExpBatteryButton3RepeatClicked()
	local isPaly = self:CardProRequest(self.cardId,0,0,1,0)
	if isPaly then
		self.showEffect = self.ExpItemEffectTable[3]
		self:PlayExpEffect()
	end
end

function SkinLevelUp:OnExpBatteryButton4RepeatClicked()
	local isPaly = self:CardProRequest(self.cardId,0,0,0,1)
	if isPaly then
		self.showEffect = self.ExpItemEffectTable[4]
		self:PlayExpEffect()
	end
end




local count = 0
function SkinLevelUp:PlayExpEffect()
	count = count + 1
	if count > 1 then
		count = 0
		self.showEffect:Play()
	end
end
-----------------------------------------------------------------------
--- 网络处理
-----------------------------------------------------------------------
function SkinLevelUp:CardProRequest(id,num1,num2,num3,num4)
	--- 发送升级请求
	-- print(' card pro request----------------id ' .. id)
	local isPlaying

    local nextLv = self.skinInfo.cardSkinLevel + 1
    local keys = require "StaticData.CardSkin/SkinLevel":GetKeys()
    local maxLevel = keys[keys.Length - 1]
    nextLv = math.min(nextLv,maxLevel)
    if nextLv > maxLevel then
        ShowErrorTip(self,'皮肤等级已满')
    else
        local  msg ,prototype = require"Network/ServerService".CardSkinUpgradeRequest(id,num1,num2,num3,num4)
	    self.myGame:SendNetworkMessage(msg,prototype)
	    isPlaying = true
    end

	return isPlaying
end

function SkinLevelUp:InitExpColor()
	local PropUtility = require "Utils.PropUtility"
	local gametool = require "Utils.GameTools"

	for i = 1 ,#self.expbatteryIdTable do
		local _,data,_,icon = gametool.GetItemDataById(self.expbatteryIdTable[i])
		local color = data:GetColor()
		PropUtility.AutoSetColor(self.ExpItemColors[i],color)
		-- utility.LoadSpriteFromPath(icon,self.ExpItemIcons[i])
	end
end

function SkinLevelUp:GetItemBagData()
	local UserDataType = require "Framework.UserDataType"
	local data = self:GetCachedData(UserDataType.ItemBagData)

	SetExpBattery(self,1,0)
	SetExpBattery(self,2,0)
	SetExpBattery(self,3,0)
	SetExpBattery(self,4,0)

	local items = {}
	for i = 1 ,#self.expbatteryIdTable do
		local count = data:GetItemCountById(self.expbatteryIdTable[i])
		SetExpBattery(self,i,count)
	end
end

function SkinLevelUp:OnItemBagUpdate()
	
end

-- --- 获取背包数据请求
-- function CardUpGradeModule:ItemBagQueryRequest()
-- 	self.myGame:SendNetworkMessage( require"Network/ServerService".ItemBagQueryRequest())
-- end

-- --- 获取背包数据结果
-- function CardUpGradeModule:OnItemBagQueryResponse(msg)
	
-- 	for i=1,#msg.items do
-- 		print('id : ' .. msg.items[i].itemID..' num '.. msg.items[i].itemNum)
-- 		if msg.items[i].itemID == self.expBattery1Id then
-- 			SetExpBattery(self,1,msg.items[i].itemNum)
-- 		elseif msg.items[i].itemID == self.expBattery2Id then
-- 		    SetExpBattery(self,2,msg.items[i].itemNum)
-- 		elseif msg.items[i].itemID == self.expbattery3Id then
-- 		    SetExpBattery(self,3,msg.items[i].itemNum)
-- 		end
-- 	end
-- end

function SkinLevelUp:OnCardBayFlush (msg)
	 -- 同步 玩家数据
    local dataCacheMgr = self.myGame:GetDataCacheManager()

    -- 协议的命名很坑.. 说明下
    local oneCard = msg.cards

    dataCacheMgr:UpdateData(UserDataType.CardBagData, function(oldData)
        require "Data.CardBagData"
        if oldData == nil then
            oldData = CardBagData.New()
        end

        self.heroData = oldData:GetRoleByUid(self.heroData:GetUid())
		SetCardInfo(self)
        return oldData
    end)
	
end

function SkinLevelUp:OnCardProResult(msg)
	-- print(msg.cardUID.. " 状态 ".. msg.state)
	if msg.state == 0 then
	    --ShowErrorTip(self,'升级成功')
		---刷新经验电池数量，，，直接请求背包，，需优化
		
		
	else
		ShowErrorTip(self,'升级失败')
	end
	---更新经验等级，卡牌列表……怎么更新
	---
    ---
	self:GetItemBagData()
end


function SkinLevelUp:SetLevelUpPanel()
	self.transform.gameObject:SetActive(true)
end

function SkinLevelUp:GetSkinInfo(data)
	self.skinInfo = data
	--uid
	self.cardId = data.cardSkinUID
end

return SkinLevelUp
