local BaseNodeClass = require "GUI.ScrollContentBase.ScrollContentBase"
local utility = require "Utils.Utility"

local AchievementScorllNodeCls = Class(BaseNodeClass)

function AchievementScorllNodeCls:Ctor(parent,ctable,func)
	self.parent = parent
	
	-- Item 点击回调
	self.ctable = ctable
	self.func = func


	-- 固定行数
	self.rowCount = 3
	-- 固定列数
	self.columnCount = 1
	-- 横间距
	self.spacint_X = 0
	-- 纵间距
	self.spacint_Y = 5
	-- 物品宽
	self.ItemWidth = 600
	-- 物品高
	self.itemHigh = 150
	-- 边框
	-- 边框
	local border = {}
	border.Top = 10
	border.Bottom = 10
	border.Left = 10
	border.Right = 10
	self.border = border

	self.dataCount = 0
end


function AchievementScorllNodeCls:OnInit()
	local itemCls = require "GUI.Achievement.AchievementItemNodeCls"

	AchievementScorllNodeCls.base.OnInit(self,self.parent,self.rowCount,self.columnCount,self.spacint_X,self.spacint_Y,
	self.ItemWidth,self.itemHigh,self.border,itemCls,self.ctable,self.func)
end

function AchievementScorllNodeCls:OnResume()
	AchievementScorllNodeCls.base.OnResume(self)

end
function AchievementScorllNodeCls:OnPause()
	-- 界面隐藏时调用
	AchievementScorllNodeCls.base.OnPause(self)	
end


local function DelayUpdateScrollContent(self,count,data,args)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	AchievementScorllNodeCls.base.UpdateContent(self,count,data,args)
end

function AchievementScorllNodeCls:UpdateScrollContent(count,data,args)
	coroutine.start(DelayUpdateScrollContent,self,count,data,args)
end

function AchievementScorllNodeCls:UpdateItem()
	-- 设置选中状态
	AchievementScorllNodeCls.base.UpdateItem(self)
	--AchievementScorllNodeCls.base.SetItemSelecetdState(self)
end


-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------


return AchievementScorllNodeCls