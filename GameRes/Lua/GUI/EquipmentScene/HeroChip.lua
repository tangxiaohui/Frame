local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "System.LuaDelegate"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"
local HeroChipCls = Class(BaseNodeClass)

function HeroChipCls:Ctor(parent,pos)
	self.parentTransform = parent
	--self.listTrans = parent:Find('Viewport/Content/CurrentHeroGridList')
	 self.callback = LuaDelegate.New()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------

function HeroChipCls:OnInit()
	-- 加载界面(只走一次)
	 -- 加载界面(只走一次)
    utility.LoadNewGameObjectAsync('UI/Prefabs/CardChipView', function(go)
        self:BindComponent(go, false)
    end)
end

function HeroChipCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parentTransform)
	self:InitControls()
end

function HeroChipCls:OnResume()
	-- 界面显示时调用
	HeroChipCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
end

function HeroChipCls:OnPause()
	-- 界面隐藏时调用
	HeroChipCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function HeroChipCls:OnEnter()
	-- Node Enter时调用
	HeroChipCls.base.OnEnter(self)
end

function HeroChipCls:OnExit()
	-- Node Exit时调用
	HeroChipCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 回调
-----------------------------------------------------------------------
function HeroChipCls:SetCallback(table, func)
    self.callback:Set(table, func)
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function HeroChipCls:InitControls()
	 local transform = self:GetUnityTransform()
	 self.contentTrans = transform:Find('Viewport/Content/CurrentHeroGridList')
	 --transform.localPosition = self.pos
	 self.items = {}
	 self:InitCardChipBagView()

end


function HeroChipCls:RegisterControlEvents()
	
end

function HeroChipCls:UnregisterControlEvents()
	
end

function HeroChipCls:RegisterNetworkEvents()
	utility:GetGame():RegisterMsgHandler(net.S2CCardSuipianFlush,self,self.OnCardChipBagFlush)
	utility:GetGame():RegisterMsgHandler(net.S2CCardSuipianBuildResult,self,self.OnCardSuipianBuildResponse)
	
end

function HeroChipCls:UnregisterNetworkEvents()
	utility:GetGame():UnRegisterMsgHandler(net.S2CCardSuipianFlush,self,self.OnCardChipBagFlush)
	utility:GetGame():UnRegisterMsgHandler(net.S2CCardSuipianBuildResult,self,self.OnCardSuipianBuildResponse)
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------

function HeroChipCls:InitCardChipBagView()
	-- 初始化卡牌碎片包
	local HeroChipItemNodeClass = require "GUI.EquipmentScene.HeroChipItemNode"

    local UserDataType = require "Framework.UserDataType"

    local cardChipBagData = self:GetCachedData(UserDataType.CardChipBagData)
    local count = cardChipBagData:GetCount()
    --local items = {}

    for i = 1, count do
        local node = HeroChipItemNodeClass.New(cardChipBagData:GetDataByIndex(i), self.contentTrans)
       
        node:SetCallback(self, self.OnCardClicked)
        self:AddChild(node)
        self.items[#self.items + 1] = node
    end

end

local function RefreshCardChipItem(self)
	local UserDataType = require "Framework.UserDataType"
	local CardChipBagData = self:GetCachedData(UserDataType.CardChipBagData)
	
	for i = 1,#self.items do
		local data = CardChipBagData:GetDataByIndex(i)
		if data == nil then
			self:RemoveChild(self.items[i])
			return
		end
		self.items[i]:RefresheChipData(data)
	end
end


function HeroChipCls:OnCardChipBagFlush(msg)
	RefreshCardChipItem(self)
end

function HeroChipCls:OnCardSuipianBuildResponse(msg)
	local windowManager = utility:GetGame():GetWindowManager()
    windowManager:Show(require "GUI.GeneralCard.GetCardWin",msg.cardSuipianID)
end


--------------------------------------------------------------------
function HeroChipCls:OnCardClicked(monolog,portraitImage)
	self.callback:Invoke(monolog,portraitImage)
end


return HeroChipCls