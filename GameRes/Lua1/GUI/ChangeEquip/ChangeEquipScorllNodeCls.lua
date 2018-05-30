local BaseNodeClass = require "GUI.ScrollContentBase.ScrollContentBase"
local utility = require "Utils.Utility"

local ChangeEquipScorllNodeCls = Class(BaseNodeClass)

function ChangeEquipScorllNodeCls:Ctor(parent,ctable,func)
	self.parent = parent
	
	-- Item 点击回调
	self.ctable = ctable
	self.func = func


	-- 固定行数
	self.rowCount = 2
	-- 固定列数
	self.columnCount = 4
	-- 横间距
	self.spacint_X = 60
	-- 纵间距
	self.spacint_Y = 55
	-- 物品宽
	self.ItemWidth = 96
	-- 物品高
	self.itemHigh = 128
	-- 边框
	self.border = {}
	self.border.Top = 18
	self.border.Bottom = 15
	self.border.Left = 50
	self.border.Right = 50
	self.borderBottom = 30

	self.dataCount = 0
end


function ChangeEquipScorllNodeCls:OnInit()
	local itemCls = require "GUI.ChangeEquip.EquipItem"

	ChangeEquipScorllNodeCls.base.OnInit(self,self.parent,self.rowCount,self.columnCount,self.spacint_X,self.spacint_Y,
	self.ItemWidth,self.itemHigh,self.border,itemCls,self.ctable,self.func)
end

function ChangeEquipScorllNodeCls:OnResume()
	ChangeEquipScorllNodeCls.base.OnResume(self)

end
function ChangeEquipScorllNodeCls:OnPause()
	-- 界面隐藏时调用
	ChangeEquipScorllNodeCls.base.OnPause(self)	
end


local function DelayUpdateScrollContent(self,count,data,args)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	ChangeEquipScorllNodeCls.base.UpdateContent(self,count,data,args)
end

function ChangeEquipScorllNodeCls:UpdateScrollContent(count,data,args)
	-- coroutine.start(DelayUpdateScrollContent,self,count,data,args)
	self:StartCoroutine(DelayUpdateScrollContent, count,data,args)
end

function ChangeEquipScorllNodeCls:UpdateItem()
	-- 设置选中状态
	ChangeEquipScorllNodeCls.base.UpdateItem(self)
	ChangeEquipScorllNodeCls.base.SetItemSelecetdState(self)
	
end


-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------


return ChangeEquipScorllNodeCls