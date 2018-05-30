local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"
local UserDataType = require "Framework.UserDataType"

-----------------------------------------------------------------------
local DisplayOneCardSkinCls = Class(BaseNodeClass)
windowUtility.SetMutex(DisplayOneCardSkinCls, true)

function DisplayOneCardSkinCls:Ctor()
end
function DisplayOneCardSkinCls:OnWillShow(id,isHad)
	self.id = id
	self.isHad = isHad
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function DisplayOneCardSkinCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/SkinInfo', function(go)
		self:BindComponent(go)
	end)
end

function DisplayOneCardSkinCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitVariable()
	self:InitControls()
end

function DisplayOneCardSkinCls:OnResume()
	-- 界面显示时调用
	DisplayOneCardSkinCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()

	self:InitView()

	self:FadeIn(function(self, t,finished)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
        if finished then
        	self.kizunaScrollRect.enabled = true
       	end
    end)
end

function DisplayOneCardSkinCls:OnPause()
	-- 界面隐藏时调用
	DisplayOneCardSkinCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function DisplayOneCardSkinCls:OnEnter()
	-- Node Enter时调用
	DisplayOneCardSkinCls.base.OnEnter(self)
end

function DisplayOneCardSkinCls:OnExit()
	-- Node Exit时调用
	DisplayOneCardSkinCls.base.OnExit(self)
end


function DisplayOneCardSkinCls:IsTransition()
    return true
end

function DisplayOneCardSkinCls:OnExitTransitionDidStart(immediately)
	DisplayOneCardSkinCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function DisplayOneCardSkinCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function DisplayOneCardSkinCls:InitControls()
	local transform = self:GetUnityTransform()

	self.tweenObjectTrans = transform:Find('Base')
	-- 返回按钮
 	self.RetrunButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))
 	self.itemPoint = transform:Find('Base/SkinItemPoint')

 	local baseTranform = transform:Find('Base/Scroll View/Viewport/Content/NormalInfo')
 	self.skinNameLabel = baseTranform:Find('CardName'):GetComponent(typeof(UnityEngine.UI.Text))
 	self.skinLevelLabel = baseTranform:Find('LvLabel'):GetComponent(typeof(UnityEngine.UI.Text))
 	self.skinColorLabel = baseTranform:Find('Racial/RankLabel'):GetComponent(typeof(UnityEngine.UI.Text))
 	self.skinExpLabel = baseTranform:Find('Bar/EXPLabel'):GetComponent(typeof(UnityEngine.UI.Text))
 	self.skinExpFillImage = baseTranform:Find('Bar/Frame/Fill'):GetComponent(typeof(UnityEngine.UI.Image))
 	self.skinDesLaebl = baseTranform:Find('Notice'):GetComponent(typeof(UnityEngine.UI.Text))
 	self.skinAddHpLabel = baseTranform:Find('Status/Life/StatusLabel'):GetComponent(typeof(UnityEngine.UI.Text))
 	self.skinAddAdLabel = baseTranform:Find('Status/Atk/StatusLabel'):GetComponent(typeof(UnityEngine.UI.Text))
 	self.RacialBaseImage = baseTranform:Find('Racial/RankBase'):GetComponent(typeof(UnityEngine.UI.Image))
 	self.RacialIconImage = baseTranform:Find('Racial/RacialIcon'):GetComponent(typeof(UnityEngine.UI.Image))

 	local kizunaTransform = transform:Find('Base/Scroll View/Viewport/Content/KizunaInfo')
 	self.kizunaHintLabel = kizunaTransform:Find('NoKizunaNotice'):GetComponent(typeof(UnityEngine.UI.Text))
 	self.kuzunaSkinHeadPoint = kizunaTransform:Find('Layout')
 	self.kununaLayout = kizunaTransform:Find('KizunaLayout')
 	self.kizunaScrollRect = transform:Find('Base/Scroll View'):GetComponent(typeof(UnityEngine.UI.ScrollRect))
 	self.kizunaScrollRect.enabled = false
 	self.KizunaInfoLayout = kizunaTransform:GetComponent(typeof(UnityEngine.UI.LayoutElement))
 	self.hintRoleNameLabel = kizunaTransform:Find('Notice'):GetComponent(typeof(UnityEngine.UI.Text))

 	if self.isHad ~= nil then
 		self.infoAnimator = transform:Find('Base'):GetComponent(typeof(UnityEngine.Animator))
 	end
end

function DisplayOneCardSkinCls:InitVariable()
	self.myGame = utility:GetGame()
end


function DisplayOneCardSkinCls:RegisterControlEvents()
	-- 注册 RetrunButton 的事件
	self.__event_button_onRetrunButtonClicked__ = UnityEngine.Events.UnityAction(self.OnRetrunButtonClicked, self)
	self.RetrunButton.onClick:AddListener(self.__event_button_onRetrunButtonClicked__)

end

function DisplayOneCardSkinCls:UnregisterControlEvents()
	-- 取消注册 RetrunButton 的事件
	if self.__event_button_onRetrunButtonClicked__ then
		self.RetrunButton.onClick:RemoveListener(self.__event_button_onRetrunButtonClicked__)
		self.__event_button_onRetrunButtonClicked__ = nil
	end

end

function DisplayOneCardSkinCls:RegisterNetworkEvents()
	--self.myGame:RegisterMsgHandler(net.S2CTaskQueryResult, self, self.OnTaskQueryResponse)
end

function DisplayOneCardSkinCls:UnregisterNetworkEvents()
	--self.myGame:UnRegisterMsgHandler(net.S2CTaskQueryResult, self, self.OnTaskQueryResponse)
end
-----------------------------------------------------------------------
--- 网络处理
-----------------------------------------------------------------------
-- function DisplayOneCardSkinCls:OnTaskQueryRequest()
-- 	self.myGame:SendNetworkMessage( require"Network/ServerService".TaskQueryRequest())
-- end

function DisplayOneCardSkinCls:OnRetrunButtonClicked()
	self:Close()
end

function DisplayOneCardSkinCls:InitInfoView()
	local PropUtility = require "Utils.PropUtility"
	local staticData = require"StaticData.CardSkin.Skin":GetData(self.id)
	local cardId = staticData:GetRoleid()
    local cacheData = self:GetCachedData(UserDataType.CardSkinsData)
    local skinData = cacheData:GetOneSkinData(cardId,self.id)
   
   	-- 基础信息
    local name = staticData:GetName()
    local desc = staticData:GetDescription()
    self.skinNameLabel.text = name
    self.skinDesLaebl.text = desc
    local color = staticData:GetColor()
    self.skinColorLabel.color = PropUtility.GetRGBColorValue(color)
    self.skinColorLabel.text = Color[color]

    local lv = skinData:GetCardSkinLevel()
    local exp = skinData:GetCardSkinExp()
    local maxExp = require"StaticData.CardSkin.SkinLevel":GetData(lv):GetExp()
   	
   	local expStr = ""
   	local expPersent = 1
   	if lv < 5 then
   		local nextLv = math.min(lv+1,5)
    	local nextMaxExp = require"StaticData.CardSkin.SkinLevel":GetData(nextLv):GetExp()
    	local currExp = exp - maxExp 
   		local needExp = nextMaxExp - maxExp
   		expStr = string.format("%s%s%s",currExp,"/",needExp)
   		expPersent = currExp/needExp

   		debug_print("@@@@@卡牌经验 ：",exp,"  下个等级: ",nextLv,"  下个等级经验上限：",nextMaxExp," 当前经验上限：",maxExp,
   			" 当前经验： ",currExp," 需要经验 ：",needExp)
   	end
   	self.skinExpLabel.text = expStr
    self.skinExpFillImage.fillAmount = expPersent
    self.skinLevelLabel.text = string.format("%s%s","Lv.",lv)
    
    local CardSkinDataUtils = require "Utils.CardSkinUtils"
    local attack,hp = CardSkinDataUtils.GetSkinAddProperties(skinData)
    self.skinAddAdLabel.text = string.format("%s%s","+",attack)
    self.skinAddHpLabel.text = string.format("%s%s","+",hp)

	local roleStaticData = require"StaticData.Role":GetData(cardId)
	local roleName =  roleStaticData:GetInfo()
	self.hintRoleNameLabel.text = string.format("达成指定条件可解锁对 %s 的羁绊加成",roleName)

	local gameTool = require "Utils.GameTools"
	local _,roleData = gameTool.GetItemDataById(cardId)
	utility.LoadRaceIcon(roleData:GetRace(),self.RacialIconImage)
	utility.LoadCardSkinBaseIcon(color,self.RacialBaseImage)

    -- 羁绊
    local kizunaId = staticData:GetKizuna()
    if kizunaId ~= 0 then
    	self.kizunaHintLabel.text = ""
    	self.KizunaInfoLayout.preferredHeight = 630
    	local kizunaStaticData = require"StaticData.CardSkin.SkinKizuna":GetData(kizunaId)
    	local levelLimitTable = {kizunaStaticData:GetKizunalevel1(),kizunaStaticData:GetKizunalevel2(),kizunaStaticData:GetKizunalevel3()}
    	local idArray,valueArray = CardSkinDataUtils.GetBaseStateAdded(kizunaStaticData)
	  	local kizunaArray = kizunaStaticData:GetKizuna()
    	local result = CardSkinDataUtils.GetOpenedKizunaState(skinData,cardId)
    	local infoCls = require "GUI.SkinSystem.KizunaInfo"
    	for i = 1 ,3 do
    		local node = infoCls.New(self.kununaLayout)
    		local isOpen = (result >= i)
    		node:ResetView(i,levelLimitTable[i],idArray,valueArray,result)
    		self:AddChild(node)
    	end

    	-- 头像
    	local headItemCls = require "GUI.SkinSystem.CardSkinHeadItem"
    	for j = 0 ,kizunaArray.Count-1 do
    		local node = headItemCls.New(self.kuzunaSkinHeadPoint,cardId,kizunaArray[j])
    		node:SimpleShowHead()
    		self:AddChild(node)
    	end
    else
    	self.kizunaHintLabel.text = "该皮肤暂未开放羁绊"
    	self.KizunaInfoLayout.preferredHeight = 320
    end
end

function DisplayOneCardSkinCls:InitView()
    local skinItem = require "GUI.SkinSystem.CardSkinItem".New(self.itemPoint,self.id,true)
    skinItem:SetCallback(self,self.OnSkinItemClicked)
    self:AddChild(skinItem)
    if self.isHad then
    	self:InitInfoView()
    end
end

function DisplayOneCardSkinCls:OnSkinItemClicked()
	if self.isHad then
		if self.infoAnimator ~= nil then
			self.infoAnimator:SetTrigger("Show")
		end
	end
end

return DisplayOneCardSkinCls