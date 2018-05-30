local BaseNodeClass = require "GUI.ScrollContentBase.ScrollContentBase"
local utility = require "Utils.Utility"

local InlayGemBagScrollNodeCls = Class(BaseNodeClass)

function InlayGemBagScrollNodeCls:Ctor(parent,ctable,func)
	self.parent = parent
	
	-- Item 点击回调
	self.ctable = ctable
	self.func = func


	-- 固定行数
	self.rowCount = 3
	-- 固定列数
	self.columnCount = 3
	-- 横间距
	self.spacint_X = 50
	-- 纵间距
	self.spacint_Y = 55
	-- 物品宽
	self.ItemWidth = 80
	-- 物品高
	self.itemHigh = 80
	
	-- 边框
	local border = {}
	border.Top = 15
	border.Bottom = 45
	border.Left = 15
	border.Right = 15
	self.border = border

	self.dataCount = 0
end


function InlayGemBagScrollNodeCls:OnInit()
	local itemCls = require "GUI.Gem.GemBagItemNode"

	InlayGemBagScrollNodeCls.base.OnInit(self,self.parent,self.rowCount,self.columnCount,self.spacint_X,self.spacint_Y,
	self.ItemWidth,self.itemHigh,self.border,itemCls,self.ctable,self.func)
end

function InlayGemBagScrollNodeCls:OnResume()
	InlayGemBagScrollNodeCls.base.OnResume(self)

end
function InlayGemBagScrollNodeCls:OnPause()
	-- 界面隐藏时调用
	InlayGemBagScrollNodeCls.base.OnPause(self)	
end


local function DelayUpdateScrollContent(self,count,data)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	InlayGemBagScrollNodeCls.base.UpdateContent(self,count,data)
end

function InlayGemBagScrollNodeCls:UpdateScrollContent(count,data)
	-- coroutine.start(DelayUpdateScrollContent,self,count,data)
	self:StartCoroutine(DelayUpdateScrollContent, count,data)
end

function InlayGemBagScrollNodeCls:UpdateItem()
	-- 设置选中状态
	InlayGemBagScrollNodeCls.base.UpdateItem(self)
	InlayGemBagScrollNodeCls.base.SetItemSelecetdState(self)
end


-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------


return InlayGemBagScrollNodeCls