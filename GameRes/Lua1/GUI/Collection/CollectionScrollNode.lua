local BaseNodeClass = require "GUI.ScrollContentBase.ScrollContentBase"
local utility = require "Utils.Utility"

local CollectionScorllNodeCls = Class(BaseNodeClass)

function CollectionScorllNodeCls:Ctor(parent,ctable)
	self.parent = parent
	
	-- Item 点击回调
	self.ctable = ctable


	-- 固定行数
	self.rowCount = 3
	-- 固定列数
	self.columnCount = 4
	-- 横间距
	self.spacint_X = 20
	-- 纵间距
	self.spacint_Y = 30
	-- 物品宽
	self.ItemWidth = 140
	-- 物品高
	self.itemHigh = 135
	-- 边框
	-- 边框
	local border = {}
	border.Top = 10
	border.Bottom = 25
	border.Left = 10
	border.Right = 10
	self.border = border

	self.dataCount = 0
end


function CollectionScorllNodeCls:OnInit()
	local itemCls = require "GUI.Collection.CollectionItemNode"

	CollectionScorllNodeCls.base.OnInit(self,self.parent,self.rowCount,self.columnCount,self.spacint_X,self.spacint_Y,
	self.ItemWidth,self.itemHigh,self.border,itemCls,self.ctable,nil)
end

function CollectionScorllNodeCls:OnResume()
	CollectionScorllNodeCls.base.OnResume(self)

end
function CollectionScorllNodeCls:OnPause()
	-- 界面隐藏时调用
	CollectionScorllNodeCls.base.OnPause(self)	
end


local function DelayUpdateScrollContent(self,count,data,args)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	CollectionScorllNodeCls.base.UpdateContent(self,count,data,args)
end

function CollectionScorllNodeCls:UpdateScrollContent(count,data,args)
	-- coroutine.start(DelayUpdateScrollContent,self,count,data,args)
	self:StartCoroutine(DelayUpdateScrollContent, count,data,args)
end

function CollectionScorllNodeCls:UpdateItem()
	-- 设置选中状态
	CollectionScorllNodeCls.base.UpdateItem(self)
	--CollectionScorllNodeCls.base.SetItemSelecetdState(self)
end


-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------


return CollectionScorllNodeCls