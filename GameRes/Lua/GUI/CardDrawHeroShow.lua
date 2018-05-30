local BasClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local TweenUtility = require "Utils.TweenUtility"
require "LUT.StringTable"
--local net = require "Network.Net"
--local messageManager = require "Network.MessageManager"

--local CameraEndPos = Vector3(0,5.43,-19.76)

local CameraEndPos = Vector3(0,5.47,-25.7)

--local CameraHeadPos = Vector3(0,0,-7.9)
local CameraHeadPos = Vector3(0,8.53,-16.32)

-- 显示类型
local CardDrawPanel = 1
local CardBuildPanel = 2

local CardDrawHeroShowCls = Class(BasClass)
windowUtility.SetMutex(CardDrawHeroShowCls, true)

function CardDrawHeroShowCls:Ctor()
end

function CardDrawHeroShowCls:OnWillShow(id,ctype,args,addCardDict)

    self.itemID = id

    self.ctype = ctype
    self.args = args
    self.addCardDict = addCardDict
    self:OnResetView()
    self:OnDelayRefreshPanel()
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function CardDrawHeroShowCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/CardDrawHeroShow', function(go)
		self:BindComponent(go)
	end)
end

function CardDrawHeroShowCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function CardDrawHeroShowCls:OnResume()
	-- 界面显示时调用
	CardDrawHeroShowCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()

	self.showTime = false
end

function CardDrawHeroShowCls:OnPause()
	-- 界面隐藏时调用
	CardDrawHeroShowCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()

	self:DestroyModel(self.model)
end

function CardDrawHeroShowCls:OnEnter()
	-- Enter时调用
	CardDrawHeroShowCls.base.OnEnter(self)
end

function CardDrawHeroShowCls:OnExit()
	-- Exit时调用
	CardDrawHeroShowCls.base.OnExit(self)
end

function CardDrawHeroShowCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
local function ResetCanvas(uiCanvas)
	uiCanvas.anchorMax = Vector2(1,1)
	uiCanvas.anchorMin = Vector2(0,0)
	uiCanvas.offsetMax = Vector2(0,0)
	uiCanvas.offsetMin = Vector2(0,0)
end

-- # 控件绑定
function CardDrawHeroShowCls:InitControls()
	local transform = self:GetUnityTransform()
	local CanvasBottom = transform:Find("CanvasBottom"):GetComponent(typeof(UnityEngine.RectTransform))
	local CanvasMidle = transform:Find("CanvasMidle"):GetComponent(typeof(UnityEngine.RectTransform))
	utility.SetRectDefaut(CanvasBottom)
	utility.SetRectDefaut(CanvasMidle)

	self.myGame = utility:GetGame()

 	-- 抽卡次数
 	self.remainObj = transform:Find('CanvasMidle/Remain').gameObject
 	self.remainCountLabel = transform:Find('CanvasMidle/Remain/CountLabel'):GetComponent(typeof(UnityEngine.UI.Text))

 	self.ConfirmButton = transform:Find('CanvasMidle/CardDrawResultBackButton'):GetComponent(typeof(UnityEngine.UI.Button))

    local nameGroup1 = transform:Find("CanvasMidle/HeroCharacter/HeroNameGroup1")
    local nameGroup2 = transform:Find("CanvasMidle/HeroCharacter/HeroNameGroup2")
    local nameGroup3 = transform:Find("CanvasMidle/HeroCharacter/HeroNameGroup3")
    local nameGroup4 = transform:Find("CanvasMidle/HeroCharacter/HeroNameGroup4")
    local nameGroup5 = transform:Find("CanvasMidle/HeroCharacter/HeroNameGroup5")

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

    -- 等级
    self.levelLabel = transform:Find('CanvasMidle/HeroCharacter/CardPreInfo/LevelBase/Text'):GetComponent(typeof(UnityEngine.UI.Text))
    -- 力敏智
    self.attributeLabel = transform:Find('CanvasMidle/HeroCharacter/CardPreInfo/CardTypeBase/Text'):GetComponent(typeof(UnityEngine.UI.Text))
    -- 种族
    self.raceIconImage = transform:Find('CanvasMidle/HeroCharacter/CardPreInfo/RaceIcon'):GetComponent(typeof(UnityEngine.UI.Image))
 	-- 品阶
 	self.qualityRankImage = transform:Find('CanvasMidle/HeroCharacter/QualityGroup/QualityRank'):GetComponent(typeof(UnityEngine.UI.Image))
	self.qualityRankText = transform:Find('CanvasMidle/HeroCharacter/QualityGroup/QualityRank/Text'):GetComponent(typeof(UnityEngine.UI.Text))   
	-- 星星
	self.starParent = transform:Find('CanvasMidle/CardDrawHeroShowStarList/CardDrawHeroShowStar')

	-- 模型挂点
	self.modlePoint = transform:Find('CanvasMidle/MoldPoint')
	-- 碎片提示
	self.HintLabel = transform:Find('CanvasMidle/HintLabel'):GetComponent(typeof(UnityEngine.UI.Text))   

	-- 信息
	self.roleObj = transform:Find('CanvasMidle/HeroCharacter').gameObject
	self.titleBaseObj = transform:Find('CanvasMidle/TitleBase').gameObject
	self.TitleObj = transform:Find('CanvasMidle/Title').gameObject
	self.starObj = transform:Find('CanvasMidle/CardDrawHeroShowStarList').gameObject
end


function CardDrawHeroShowCls:RegisterControlEvents()
	-- 注册 ConfirmButton 的事件
	self.__event_button_onConfirmButtonClicked__ = UnityEngine.Events.UnityAction(self.OnConfirmButtonClicked, self)
	self.ConfirmButton.onClick:AddListener(self.__event_button_onConfirmButtonClicked__)
end

function CardDrawHeroShowCls:UnregisterControlEvents()
	-- 取消注册 ConfirmButton 的事件
	if self.__event_button_onConfirmButtonClicked__ then
		self.ConfirmButton.onClick:RemoveListener(self.__event_button_onConfirmButtonClicked__)
		self.__event_button_onConfirmButtonClicked__ = nil
	end
end

function CardDrawHeroShowCls:RegisterNetworkEvents()
	
end

function CardDrawHeroShowCls:UnregisterNetworkEvents()
	
end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function CardDrawHeroShowCls:OnConfirmButtonClicked()
	--ConfirmButton控件的点击事件处理
	if self.showTime then
		return
	end
	local eventMgr = self.myGame:GetEventManager()
    eventMgr:PostNotification('ResumeCoroutineState', nil,nil)
	self:Close()
end

local function ReloadNames(self, name)
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

local function DelayOnResetView(self)
	-- 展示
	while (not self:IsReady()) do
		coroutine.step(1)
	end

	-- 设置剩余抽取整卡次数
	local remainShow = false
	if self.ctype == CardDrawPanel then
		--self.remainObj:SetActive(true)
		remainShow = true
		self.remainCountLabel.text = string.format("%s%s%s",CardDrawStringTable[4],self.args,CardDrawStringTable[5])
	elseif self.ctype == CardBuildPanel then

	end
	self.remainShow = remainShow

	local gametool = require "Utils.GameTools"
	local _,data,itemName ,iconPath,ctype =  gametool.GetItemDataById(self.itemID)
    
    -- 设置名称
	ReloadNames(self,itemName)
	
	-- 等级
	self.levelLabel.text = "Lv1"

	--- 设置力敏智
	local attributeIndex, attributeText = data:GetMajorAttr()
    local attributeColor = gametool.GetMajorAttrColor(attributeIndex)
    self.attributeLabel.text = attributeText
    self.attributeLabel.color = attributeColor

    -- 种族
	utility.LoadRaceIcon(data:GetRace(),self.raceIconImage)
	
	-- 品阶
	local color = data:GetColorID()
	local PropUtility = require "Utils.PropUtility"
    self.qualityRankImage.color = PropUtility.GetColorValue(color)
    self.qualityRankText.text = Color[color]

    -- 星星
    local star = data:GetStar()
    gametool.AutoSetStar(self.starParent,star)
    
    -- 缩放比例
	local DarwShowPro = data:GetDarwShowPro()
	DarwShowPro = DarwShowPro * 20
	-- 设置模型
	local path = require"StaticData/ResPath":GetData(self.itemID):GetPath()

	utility.LoadNewGameObjectAsync(
        path,
        function(go)
            go.transform:SetParent(self.modlePoint)
            go.transform.localPosition = Vector3(0,0,0)
            go.transform.localRotation = Vector3(0,180,0)
          
            local newScale =  go.transform.localScale * DarwShowPro
            go.transform.localScale = newScale
            go.gameObject:AddComponent(typeof(AnimationEventListener))
            -- TODO : Const 模型渲染层
            local gos = go:GetComponentsInChildren(typeof(UnityEngine.Transform))
            for i =0,gos.Length -1 do
            	gos[i].gameObject.layer = 5
            end
            self.modelAnimator = go:GetComponent(typeof(UnityEngine.Animator))
            self.modelAnimator:SetTrigger("Breath2Show Off")

            self.model = go
        end
    )

     -- 判断是已经有此卡牌
	if self.addCardDict == nil then
		return
	end

	local hintShow = false
 	local RoleStaticData = require "StaticData.Role":GetData(self.itemID)
	if self.addCardDict:Contains(self.itemID) then
		self.addCardDict:Remove(self.itemID)
	else
		hintShow = true
		local count = RoleStaticData:GetDecomposeNum()
 		local str = string.format(CardDrawStringTable[8],count)
 		self.HintLabel.text = str
	end
	self.hintShow = hintShow
end

function CardDrawHeroShowCls:OnResetView()
	-- coroutine.start(DelayOnResetView,self)
	self:StartCoroutine(DelayOnResetView)
end

function CardDrawHeroShowCls:DestroyModel(model)
	-- 销毁模型
	UnityEngine.Object.Destroy(model)
end

local function SetGameObjectActive(target,active)
	local obj = target.gameObject
	if obj ~= nil then
		obj:SetActive(active)
	end
end

local function DelayRefreshPanel(self)
	coroutine.wait(2.5)
	SetGameObjectActive(self.remainObj,true)
	SetGameObjectActive(self.HintLabel,true)
	SetGameObjectActive(self.roleObj,true)
	SetGameObjectActive(self.titleBaseObj,true)
	SetGameObjectActive(self.TitleObj,true)
	SetGameObjectActive(self.starObj,true)
	SetGameObjectActive(self.ConfirmButton,true)

	-- self.remainObj:SetActive(self.remainShow)
	-- self.HintLabel.gameObject:SetActive(self.hintShow)

	-- self.roleObj:SetActive(true)
	-- self.titleBaseObj:SetActive(true)
	-- self.TitleObj:SetActive(true)
	-- self.starObj:SetActive(true)
	-- self.ConfirmButton.gameObject:SetActive(true)
	self.showTime = false
end

function CardDrawHeroShowCls:OnDelayRefreshPanel()
	-- 刷新模型
	--self.ConfirmButton.interactable = false
	self.showTime = true
	self:StartCoroutine(DelayRefreshPanel)
end

return CardDrawHeroShowCls