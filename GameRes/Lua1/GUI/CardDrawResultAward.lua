local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local CardDrawResultAwardCls = Class(BaseNodeClass)

function CardDrawResultAwardCls:Ctor(parent)
	self.parent = parent
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function CardDrawResultAwardCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/CardDrawResultAward', function(go)
		self:BindComponent(go,false)
	end)
end

function CardDrawResultAwardCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()
end

function CardDrawResultAwardCls:OnResume()
	-- 界面显示时调用
	CardDrawResultAwardCls.base.OnResume(self)
	self:RegisterControlEvents()
	--self:RegisterNetworkEvents()
end

function CardDrawResultAwardCls:OnPause()
	-- 界面隐藏时调用
	CardDrawResultAwardCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:GetUnityTransform().localPosition = Vector3(0,0,0)
	self.CardDrawResultAwardName.text = ""
	--self:UnregisterNetworkEvents()
end

function CardDrawResultAwardCls:OnEnter()
	-- Node Enter时调用
	CardDrawResultAwardCls.base.OnEnter(self)
end

function CardDrawResultAwardCls:OnExit()
	-- Node Exit时调用
	CardDrawResultAwardCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function CardDrawResultAwardCls:InitControls()
	local transform = self:GetUnityTransform()

	self.Base = transform:Find('Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.CardDrawResultAwardIcon = transform:Find('CardDrawResultAwardIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.CardDrawResultAwardFrame = transform:Find('Frame')
	self.CardDrawResultAwardName = transform:Find('CardDrawResultAwardName'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ChipObj = transform:Find('Chip').gameObject

	self.frames = {}
	for i=0,self.CardDrawResultAwardFrame.childCount -1  do
		self.frames [#self.frames + 1] =  self.CardDrawResultAwardFrame:GetChild(i):GetComponent(typeof(UnityEngine.UI.Image))
	end

	self.myGame = utility:GetGame()

	self.itemTypeEnum = {Role = "Role",Equip = "Equip",Item = "Item",RoleCrap = "RoleCrap",EquipCrap = "EquipCrap"}

	self.transform = transform.gameObject
end


function CardDrawResultAwardCls:RegisterControlEvents()
end

function CardDrawResultAwardCls:UnregisterControlEvents()
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
-- local function OnLoadSprite(image,imagePath)
	-- 加载图片精灵
	-- local spriteLoader = require "Utils.AtlasesLoader"

	 -- local IconSprite = spriteLoader:LoadAtlasSprite(imagePath)
	 	
	 -- if IconSprite == nil then
	 	
	 	-- local temp = utility.Split(imagePath, '/')
	 	-- local path = string.format("UI/Atlases/Icon/PublicIcon/%s",temp[#temp])
	 	-- IconSprite = spriteLoader:LoadAtlasSprite(path)
	 -- end
	 
	 -- image.sprite = IconSprite
-- end



local function DelayOnResetInfo(self,msg,remainCount,addCardDict,func)
	local gameTools = require "Utils.GameTools"

	local  dataInfo,data,name,iconPath,itemTypeStr = gameTools.GetItemDataById(msg.itemID)

	-- 判断是否是整卡
	if itemTypeStr == "Role" then
		-- 跳转整卡显示页面
		self:ShowHero(msg,remainCount,addCardDict)
		func(true)
	else
		func(false)
	end

	while (not self:IsReady()) do
		coroutine.step(1)
	end

	-- 设置名称
	self.CardDrawResultAwardName.text = string.format("%s%s%d",name,"x",msg.itemNum)   -- tostring(name).."*"..tostring(msg.itemNum)

 	utility.LoadSpriteFromPath(iconPath,self.CardDrawResultAwardIcon)
	
 	-- 设置颜色
 	local color = gameTools.GetItemColorByType(itemTypeStr,data)
	local PropUtility = require "Utils.PropUtility"
    PropUtility.AutoSetColor(self.CardDrawResultAwardFrame, color)

    local unityColor = PropUtility.GetRGBColorValue(color)
    self.CardDrawResultAwardName.color = unityColor

    if itemTypeStr == "RoleChip" or itemTypeStr == "EquipChip" then
    	self.ChipObj:SetActive(true)
    else
    	self.ChipObj:SetActive(false)
    end
end

function CardDrawResultAwardCls:OnResetInfo(msg,remainCount,addCardDict,func)
	
	-- coroutine.start(DelayOnResetInfo,self,msg,remainCount,addCardDict,func)
	self:StartCoroutine(DelayOnResetInfo, msg,remainCount,addCardDict,func)
	---------------------------------------------------------------------------------------------
	
end

function CardDrawResultAwardCls:ShowHero(msg,remainCount,addCardDict)
	local windowManager = utility:GetGame():GetWindowManager()
    windowManager:Show(require "GUI.CardDrawHeroShow",msg.itemID,1,remainCount,addCardDict)
end

return CardDrawResultAwardCls