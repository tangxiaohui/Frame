local BaseNodeClass = require "GUI.ScrollContentBase.ScrollContentBase"
local utility = require "Utils.Utility"

local ScrollSellAllCls = Class(BaseNodeClass)

function ScrollSellAllCls:Ctor(parent,ctable,func)
	self.parent = parent
	
	-- Item 点击回调
	self.ctable = ctable
	self.func = func


	-- 固定行数
	self.rowCount = 2
	-- 固定列数
	self.columnCount = 4
	-- 横间距
	self.spacint_X = 36
	-- 纵间距
	self.spacint_Y = 60
	-- 物品宽
	self.ItemWidth = 113
	-- 物品高
	self.itemHigh = 113
	-- 边框
	-- 边框
	local border = {}
	border.Top = 32
	border.Bottom = 30
	border.Left = 30
	border.Right = 30
	self.border = border

	self.dataCount = 0
end


function ScrollSellAllCls:OnInit()
	local itemCls = require "GUI.Knapsack.SellItemNode"

	ScrollSellAllCls.base.OnInit(self,self.parent,self.rowCount,self.columnCount,self.spacint_X,self.spacint_Y,
	self.ItemWidth,self.itemHigh,self.border,itemCls,self.ctable,self.func)
end

function ScrollSellAllCls:OnResume()
	ScrollSellAllCls.base.OnResume(self)

end
function ScrollSellAllCls:OnPause()
	-- 界面隐藏时调用
	ScrollSellAllCls.base.OnPause(self)	
end


local function DelayUpdateScrollContent(self,count,data)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	ScrollSellAllCls.base.UpdateContent(self,count,data)
end



function ScrollSellAllCls:UpdateScrollContent(count,data)
	-- coroutine.start(DelayUpdateScrollContent,self,count,data)
	self:StartCoroutine(DelayUpdateScrollContent, count,data)
end


local function DelayOnInitItemInfoDis(self)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	
	ScrollSellAllCls.base.OnInitItemInfoDis(self)
end

function ScrollSellAllCls:OnInitItemInfoDis()
	-- 初始化背包数据展示
	-- coroutine.start(DelayOnInitItemInfoDis,self)
	self:StartCoroutine(DelayOnInitItemInfoDis)
end


function ScrollSellAllCls:UpdateItem()
	-- 设置选中状态
	ScrollSellAllCls.base.UpdateItem(self)
	ScrollSellAllCls.base.SetItemSelecetdState(self)
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------


return ScrollSellAllCls