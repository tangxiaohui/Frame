local BaseNodeClass = require "GUI.ScrollContentBase.ScrollContentBase"
local utility = require "Utils.Utility"

local CollectionAwardScrollNodeCls = Class(BaseNodeClass)

function CollectionAwardScrollNodeCls:Ctor(parent,ctable)
	self.parent = parent
	
	-- Item 点击回调
	self.ctable = ctable


	-- 固定行数
	self.rowCount = 3
	-- 固定列数
	self.columnCount = 1
	-- 横间距
	self.spacint_X = 0
	-- 纵间距
	self.spacint_Y = 5
	-- 物品宽
	self.ItemWidth = 610
	-- 物品高
	self.itemHigh = 134
	-- 边框
	-- 边框
	local border = {}
	border.Top = 0
	border.Bottom = 0
	border.Left = 10
	border.Right = 10
	self.border = border

	self.dataCount = 0
end


function CollectionAwardScrollNodeCls:OnInit()
	local itemCls = require "GUI.Collection.CollectionAwardNode"

	CollectionAwardScrollNodeCls.base.OnInit(self,self.parent,self.rowCount,self.columnCount,self.spacint_X,self.spacint_Y,
	self.ItemWidth,self.itemHigh,self.border,itemCls,self.ctable,nil)
end

function CollectionAwardScrollNodeCls:OnResume()
	CollectionAwardScrollNodeCls.base.OnResume(self)
end
function CollectionAwardScrollNodeCls:OnPause()
	-- 界面隐藏时调用
	CollectionAwardScrollNodeCls.base.OnPause(self)	
end


local function DelayUpdateScrollContent(self,count,data,args)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	CollectionAwardScrollNodeCls.base.UpdateContent(self,count,data,args)
end

function CollectionAwardScrollNodeCls:UpdateScrollContent(count,data,args)
	-- coroutine.start(DelayUpdateScrollContent,self,count,data,args)
	self:StartCoroutine(DelayUpdateScrollContent, count,data,args)
end

function CollectionAwardScrollNodeCls:UpdateItem()
	-- 设置选中状态
	CollectionAwardScrollNodeCls.base.UpdateItem(self)
	--CollectionAwardScrollNodeCls.base.SetItemSelecetdState(self)
end


-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------


return CollectionAwardScrollNodeCls