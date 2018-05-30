local BaseNodeClass = require "GUI.ScrollContentBase.ScrollContentBase"
local utility = require "Utils.Utility"
require "Collection.OrderedDictionary"

local ScrollCls = Class(BaseNodeClass)

function ScrollCls:Ctor(parent,ctable,func)
	print("*******ScrollCls")
	self.parent = parent
	
	-- Item 点击回调
	self.ctable = ctable
	self.func = func


	-- 固定行数
	self.rowCount = 2
	-- 固定列数
	self.columnCount = 6
	-- 横间距
	self.spacint_X = 24
	-- 纵间距
	self.spacint_Y = 72
	-- 物品宽
	self.ItemWidth = 113
	-- 物品高
	self.itemHigh = 113
	-- 边框
	local border = {}
	border.Top = 40
	border.Bottom = 30
	border.Left = 50
	border.Right = 50
	self.border = border

	self.dataCount = 0
end


function ScrollCls:OnInit()
	local itemCls = require "GUI.Knapsack.ItemBase"

	ScrollCls.base.OnInit(self,self.parent,self.rowCount,self.columnCount,self.spacint_X,self.spacint_Y,
		self.ItemWidth,self.itemHigh,self.border,itemCls,self.ctable,self.func)

	-- 出售列表中选中状态
	self.sellSelecterDict = OrderedDictionary.New()
end

function ScrollCls:OnResume()
	ScrollCls.base.OnResume(self)

end
function ScrollCls:OnPause()
	-- 界面隐藏时调用
	ScrollCls.base.OnPause(self)	
end

function ScrollCls:UpdateItem()
	-- 设置选中状态
	ScrollCls.base.UpdateItem(self)
	self:SetItemSelecetdState()
end


function ScrollCls:SetAllItemSelecetdState()
	-- 设置item 全部清除选中状态
	local spwanedPool = ScrollCls.base.GetSpawnedInstances(self)

 	local nodeKeys = spwanedPool:GetKeys()
 	local nodeLength = #nodeKeys

 	for  i = 1 ,nodeLength do
 		local key = nodeKeys[i]
 		local node = spwanedPool:GetEntryByKey(key)
 		node:SetSelecredState(false)
 	end
end

function ScrollCls:SetItemSelecetdState()
	-- 设置item选中状态
	local spwanedPool = ScrollCls.base.GetSpawnedInstances(self)
	
	local nodeKeys = spwanedPool:GetKeys()
	local nodeLength = #nodeKeys

	for  i = 1 ,nodeLength do
 		local key = nodeKeys[i] 		
 		local node = spwanedPool:GetEntryByKey(key)

 		local active = self:GetNodeActive(key)
 		
 		node:SetSelecredState(active)
 	end
 	
end

------------------处理选中状态--------------------------------
function ScrollCls:ClearSellData()
	-- 清空出售列表中 选中的状态
	self.sellSelecterDict:Clear()
end

function ScrollCls:AddSellData(key,active)
	-- 添加出售列表中 选中的状态
	self.sellSelecterDict:Add(key,active)
end

function ScrollCls:RemoveSellData(key)
	self.sellSelecterDict:Remove(key)
end

function ScrollCls:GetNodeActive(key)
	local active =self.sellSelecterDict:GetEntryByKey(key)
	return active
end
------------------------------------------------------------------


local function DelayUpdateScrollContent(self,count,data)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	ScrollCls.base.UpdateContent(self,count,data)
end



function ScrollCls:UpdateScrollContent(count,data)
	-- coroutine.start(DelayUpdateScrollContent,self,count,data)
	self:StartCoroutine(DelayUpdateScrollContent, count,data)
end


local function DelayOnInitItemInfoDis(self)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	
	ScrollCls.base.OnInitItemInfoDis(self)
end

function ScrollCls:OnInitItemInfoDis()
	-- 初始化背包数据展示
	-- coroutine.start(DelayOnInitItemInfoDis,self)
	self:StartCoroutine(DelayOnInitItemInfoDis)
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------


return ScrollCls