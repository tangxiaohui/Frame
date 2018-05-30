local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local BossListCls = Class(BaseNodeClass)

function BossListCls:Ctor()



end
function BossListCls:OnWillShow(table,callback)
	self.table=table
	debug_print("*******************************************")
	if callback ~=nil then
		debug_print(callback)
        self.func=LuaDelegate.New()
        self.func:Set(table, callback)
        debug_print(self.func)
    end

end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function BossListCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/BossList', function(go)
		self:BindComponent(go)
	end)
end

function BossListCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function BossListCls:OnResume()
	-- 界面显示时调用
	BossListCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self.game:SendNetworkMessage(require "Network.ServerService".WBossListRequest())

end

function BossListCls:OnPause()
	-- 界面隐藏时调用
	BossListCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function BossListCls:OnEnter()
	-- Node Enter时调用
	BossListCls.base.OnEnter(self)
end

function BossListCls:OnExit()
	-- Node Exit时调用
	BossListCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function BossListCls:InitControls()
	self.game = utility:GetGame()
	local transform = self:GetUnityTransform()
	--self.TranslucentLayer = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Image))
	--self.Base = transform:Find('Base/Base'):GetComponent(typeof(UnityEngine.UI.Image))
	--self.Base1 = transform:Find('Base/Base'):GetComponent(typeof(UnityEngine.UI.Image))
	--self.UpperDecoration = transform:Find('Base/UpperDecoration'):GetComponent(typeof(UnityEngine.UI.Image))
	--self.DownerDecoration = transform:Find('Base/DownerDecoration'):GetComponent(typeof(UnityEngine.UI.Image))
	self.CrossButton = transform:Find('Base/CrossButton'):GetComponent(typeof(UnityEngine.UI.Button))
	--self.Scroll_View = transform:Find('Base/Scroll View'):GetComponent(typeof(UnityEngine.UI.ScrollRect))
	--self.Viewport = transform:Find('Base/Scroll View/Viewport'):GetComponent(typeof(UnityEngine.UI.Mask))
	--self.Title = transform:Find('Base/Title'):GetComponent(typeof(UnityEngine.UI.Image))
	--self.TitleText = transform:Find('Base/Times/TitleText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.TimesLabel = transform:Find('Base/Times/TimesLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.layout=transform:Find('Base/Scroll View/Viewport/Content')
		--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))
	
	self.bossItems={}
end


function BossListCls:RegisterControlEvents()
	-- 注册 CrossButton 的事件
	self.__event_button_onCrossButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCrossButtonClicked, self)
	self.CrossButton.onClick:AddListener(self.__event_button_onCrossButtonClicked__)
		-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCrossButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)
end

function BossListCls:UnregisterControlEvents()
	-- 取消注册 CrossButton 的事件
	if self.__event_button_onCrossButtonClicked__ then
		self.CrossButton.onClick:RemoveListener(self.__event_button_onCrossButtonClicked__)
		self.__event_button_onCrossButtonClicked__ = nil
	end
	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end
end

function BossListCls:RegisterNetworkEvents()

	self.game:RegisterMsgHandler(net.S2CWBossListResult, self, self.WBossListResult)

end

function BossListCls:UnregisterNetworkEvents()

	self.game:UnRegisterMsgHandler(net.S2CWBossListResult, self, self.WBossListResult)

end


function BossListCls:IsHave(id)

	for i=1,#self.bossItems do
		if self.bossItems[i].shareID == id then
			return true
		end
	end

	return false

end
function BossListCls:BattleCallBack(self,bossData,bossLevel)	
 debug_print(self.func)
	debug_print("BossListCls:CallBack()	", self.func)
	self.func:Invoke(self.table,bossData,bossLevel)
end
function BossListCls:WBossListResult(msg)
	self.maxKey=msg.challengeTimes
	self.TimesLabel.text=msg.challengeTimes
	debug_print("WBossListResult",msg.challengeTimes,"剩余挑战次数")
	for i=1,#msg.worldBossData do
		debug_print("sharerId",msg.worldBossData[i].sharerId,
			"bossId",msg.worldBossData[i].bossId,
			"bossLevel",msg.worldBossData[i].bossLevel,
			"maxHp",msg.worldBossData[i].maxHp,
			"hp",msg.worldBossData[i].hp,
			"validTime",msg.worldBossData[i].validTime
		)
	end

	for i=1,#msg.worldBossData do
		local tempItem = require 'GUI.Boss.BossItem'.New(msg.worldBossData[i],self.layout,self.maxKey,self,self.BattleCallBack)
	    self:AddChild(tempItem)
	    self.bossItems[#self.bossItems]=tempItem
	end


end


-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function BossListCls:OnCrossButtonClicked()
	--CrossButton控件的点击事件处理
	self:Close()
end

function BossListCls:OnScroll_ViewValueChanged(posXY)
	--Scroll_View控件的点击事件处理
end

return BossListCls
