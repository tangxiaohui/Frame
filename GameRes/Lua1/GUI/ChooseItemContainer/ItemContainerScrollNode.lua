local BaseNodeClass = require "GUI.ScrollContentBase.ScrollContentBase"
local utility = require "Utils.Utility"

local ItemContainerScrollNode = Class(BaseNodeClass)

function ItemContainerScrollNode:Ctor(parent,ctable,func,itemCls)
	self.parent = parent
	
	-- Item 点击回调
	self.ctable = ctable
	self.func = func


	-- 固定行数
	self.rowCount = 2
	-- 固定列数
	self.columnCount = 4
	-- 横间距
	self.spacint_X = 20
	-- 纵间距
	self.spacint_Y = 60
	-- 物品宽
	self.ItemWidth = 117
	-- 物品高
	self.itemHigh = 117
	-- 边框
	-- 边框
	local border = {}
	border.Top = 42
	border.Bottom = 30
	border.Left = 30
	border.Right = 30
	self.border = border

	self.dataCount = 0
	self.itemCls = itemCls
end


function ItemContainerScrollNode:OnInit()
	ItemContainerScrollNode.base.OnInit(self,self.parent,self.rowCount,self.columnCount,self.spacint_X,self.spacint_Y,
	self.ItemWidth,self.itemHigh,self.border,self.itemCls,self.ctable,self.func)
end

function ItemContainerScrollNode:OnResume()
	ItemContainerScrollNode.base.OnResume(self)

end
function ItemContainerScrollNode:OnPause()
	-- 界面隐藏时调用
	ItemContainerScrollNode.base.OnPause(self)	
end


local function DelayUpdateScrollContent(self,count,data)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	ItemContainerScrollNode.base.UpdateContent(self,count,data)
end



function ItemContainerScrollNode:UpdateScrollContent(count,data)
	-- coroutine.start(DelayUpdateScrollContent,self,count,data)
	self:StartCoroutine(DelayUpdateScrollContent, count,data)
end


local function DelayOnInitItemInfoDis(self)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	
	ItemContainerScrollNode.base.OnInitItemInfoDis(self)
end

function ItemContainerScrollNode:OnInitItemInfoDis()
	-- 初始化背包数据展示
	-- coroutine.start(DelayOnInitItemInfoDis,self)
	self:StartCoroutine(DelayOnInitItemInfoDis)
end


function ItemContainerScrollNode:UpdateItem()
	-- 设置选中状态
	ItemContainerScrollNode.base.UpdateItem(self)
	ItemContainerScrollNode.base.SetItemSelecetdState(self)
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------


return ItemContainerScrollNode