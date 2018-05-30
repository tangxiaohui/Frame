require "Collection.OrderedDictionary"
require "Collection.DataStack"
require "Collection.DataQueue"

-- 检查列表
local PrevDisplayIndexCls = Class(LuaObject)

function PrevDisplayIndexCls:Ctor()
    self.PrevDisplayIndexDict = OrderedDictionary.New()
    
end

function PrevDisplayIndexCls:GetInstance()
	return self.PrevDisplayIndexDict
end


-- 当前展示索引列表
local CurrDisplayIndexCls = Class(LuaObject)

function CurrDisplayIndexCls:Ctor()
    self.CurrDisplayIndexDict = OrderedDictionary.New()
    
end

function CurrDisplayIndexCls:GetInstance()
	return self.CurrDisplayIndexDict
end

-- 创建表
local CreateListCls = Class(LuaObject)

function CreateListCls:Ctor()
    self.CreateListDict = OrderedDictionary.New()
    
end

function CreateListCls:GetInstance()
	return self.CreateListDict
end

-- 回收表
local RecycleListCls = Class(LuaObject)

function RecycleListCls:Ctor()
    self.RecycleListDict = OrderedDictionary.New()
    
end

function RecycleListCls:GetInstance()
	return self.RecycleListDict
end

-- 使用中的Item 表
local SpawnedInstancesCls = Class(LuaObject)

function SpawnedInstancesCls:Ctor()
    self.SpawnedInstancesDict = OrderedDictionary.New()
    
end

function SpawnedInstancesCls:GetInstance()
	return self.SpawnedInstancesDict
end



-------------------------------------------------------------------
 -- 池子

local ItemPoolCls = Class(LuaObject)

function ItemPoolCls:Ctor()
    self.ItemPoolClsStack = DataStack.New()
    --self.ItemPoolClsDict = {}
end

function ItemPoolCls:GetInstance()
	return self.ItemPoolClsStack
end

function ItemPoolCls:Get()

	if self.ItemPoolClsStack:Count() > 0 then
		
		local item = self.ItemPoolClsStack:Pop()
		return item
	else
		return nil
	end
end

function ItemPoolCls:Create(cls,parent,itemWidth,itemHigh,ctable,func)
	
	local node = cls.New(parent,itemWidth,itemHigh)
	if node.SetCallback ~= nil then
	--node:SetParent(parent)
		node:SetCallback(ctable,func)
	end
	return node
end

function ItemPoolCls:Push(node)
	self.ItemPoolClsStack:Push(node)
end

--------------------------------------------------------------------
local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local ScrollBaseCls = Class(BaseNodeClass)

function ScrollBaseCls:Ctor()
	-- 选中的物品字典
	self.OnSelectedStateDict = OrderedDictionary.New()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function ScrollBaseCls:OnInit(parent,rowCount,columnCount,spacint_X,spacint_Y,ItemWidth,itemHigh,border,itemCls,ctable,func)
	-- 加载界面(只走一次)

	-- 父组件
	self.parent = parent
	-- 固定行数
	self.rowCount = rowCount
	-- 固定列数
	self.columnCount = columnCount
	-- 横间距
	self.spacint_X = spacint_X
	-- 纵间距
	self.spacint_Y = spacint_Y
	-- 物品宽
	self.itemWidth = ItemWidth
	-- 物品高
	self.itemHigh = itemHigh
	-- 边框
	self.borderTop = border.Top
	self.borderBottom = border.Bottom
	self.borderLeft = border.Left
	self.borderRight = border.Right

	-- 物品类
	self.itemCls = itemCls

	-- item 点击回调
	self.callbackTable = ctable
	self.callBackFunc = func


	utility.LoadNewGameObjectAsync('UI/Prefabs/ScrollContent', function(go)
		self:BindComponent(go)
	end)
end

function ScrollBaseCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	--self:LinkComponent(self.parent)
	self:InitControls()
end

function ScrollBaseCls:OnResume()
	-- 界面显示时调用
	ScrollBaseCls.base.OnResume(self)
	self:RegisterControlEvents()
	--self:RegisterNetworkEvents()
end

function ScrollBaseCls:OnPause()
	-- 界面隐藏时调用
	ScrollBaseCls.base.OnPause(self)
	self:UnregisterControlEvents()
	--self:UnregisterNetworkEvents()
end

function ScrollBaseCls:OnEnter()
	-- Node Enter时调用
	ScrollBaseCls.base.OnEnter(self)
end

function ScrollBaseCls:OnExit()
	-- Node Exit时调用
	ScrollBaseCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function ScrollBaseCls:InitControls()
	local transform = self:GetUnityTransform()
	
	-- 重置位置
	transform:SetParent(self.parent)
	transform.localPosition = Vector3(0,0,0)
	
	-- 滑动组件
	self.ScrollRect = transform:GetComponent(typeof(UnityEngine.UI.ScrollRect))
	
	-- 显示组件
	self.contentTrans = transform:Find('Viewport/Content')
	self.container = self.contentTrans:GetComponent(typeof(UnityEngine.RectTransform))
	
	-- 重置显示区域
	self.ScrollRectTrans = transform:GetComponent(typeof(UnityEngine.RectTransform))
	local ScrollRectTransWidth = self.columnCount * self.itemWidth + (self.columnCount -1 ) * self.spacint_X + self.borderLeft + self.borderRight
	local ScrollRectTransHigh = self.rowCount * self.itemHigh + (self.rowCount - 1) * self.spacint_Y + self.borderTop + self.borderBottom
	self.ScrollRectTrans.sizeDelta = Vector2(ScrollRectTransWidth,ScrollRectTransHigh)

	

	-- 垂直偏移
	self.verticalOffset = 0
	-- 开始索引
	self.startIndex = 0

	-- 检查索引列表
	self.PrevDisplayIndex = PrevDisplayIndexCls.New():GetInstance()
	-- 当前展示索引列表
	self.CurrDisplayIndex = CurrDisplayIndexCls.New():GetInstance()	
	-- 使用中的表
	self.SpawnedInstances = SpawnedInstancesCls.New():GetInstance()

	-- Item池子
	self.ItemPool = ItemPoolCls.New()

end


function ScrollBaseCls:RegisterControlEvents()
	-- 注册 _TestScroll 的事件
	self.__event_scrollrect_on_ScrollValueChanged__ = UnityEngine.Events.UnityAction_UnityEngine_Vector2(self.OnScrollValueChanged, self)
	self.ScrollRect.onValueChanged:AddListener(self.__event_scrollrect_on_ScrollValueChanged__)

end

function ScrollBaseCls:UnregisterControlEvents()
	-- 取消注册 _TestScroll 的事件
	if self.__event_scrollrect_on_ScrollValueChanged__ then
		self.ScrollRect.onValueChanged:RemoveListener(self.__event_scrollrect_on_ScrollValueChanged__)
		self.__event_scrollrect_on_ScrollValueChanged__ = nil
	end

end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function ScrollBaseCls:UpdateContent(count,data,args)
	-- self.contentTrans.localPosition = Vector3(0,0,0)
	-- 调用方法 更新数据显示
	self.args = args
	self:ResetSpawnPool()
	self:RecalculateContentSize(count,data)
	self:UpdateItem()
end

function ScrollBaseCls:GetContentData()
	-- 获取数据
	return self.data
end

function ScrollBaseCls:OnInitItemInfoDis()
	-- 初始化第一个 item信息展示
	local count = self.SpawnedInstances:Count()

	if count > 0 then
		local node = self.SpawnedInstances:GetEntryByIndex(1)

		local data = self.data:GetEntryByIndex(1)
		local id = node:GetItemID(data)
		node:ItemClickedCallback(itemType,id,data)
	end
end

function ScrollBaseCls:ResetSpawnPool()
	
	self.PrevDisplayIndex:Clear()
	local count = self.SpawnedInstances:Count()
	
	--- TODO:待优化
	for i = 1,count do
		local item = self.SpawnedInstances:GetEntryByIndex(i)
		self.ItemPool:Push(item)
		self:RemoveChild(item)
	end
	self.SpawnedInstances:Clear()
end

local function DelayResetVerticalOffset(self,offset)
	while (not self:IsReady()) do
		coroutine.step(1)
	end
	
	self.ScrollRect.verticalNormalizedPosition = offset
end


function ScrollBaseCls:ResetVerticalOffset(offset)
	-- 重置滑动偏移量
	-- coroutine.start(DelayResetVerticalOffset,self,offset)
	self:StartCoroutine(DelayResetVerticalOffset, offset)
end
-----------------------------------------------------------------------
function ScrollBaseCls:OnScrollValueChanged(posXY)
	--self:GetItemStartIndex()
	if self.VerticalHiddenLength == nil then
		print("****************数据没有准备好")
		return
	end
	self:UpdateItem()
	
end

function ScrollBaseCls:RecalculateContentSize(count,data)
	-- 重置content size  
	--arg: count,数据长度 
	self.dataCount = count
	local dataRowCountTemp = self.dataCount / self.columnCount
	self.dataRowCount = math.ceil(dataRowCountTemp)

	self.data = data
	local sizeDelta = self.container.sizeDelta

	-- 数据行数
	local dataRowCount =  math.ceil(count / self.columnCount)

	-- 内容长度
	self.VerticalContentLength = dataRowCount  * self.itemHigh + (dataRowCount - 1) * self.spacint_Y + self.borderTop + self.borderBottom
	-- 内容宽度
	self.HonrizantolContentLength = self.columnCount * self.itemWidth + (self.columnCount - 1) * self.spacint_X + self.borderLeft + self.borderRight
	-- 显示区长度
	self.VerticalDisContentLength = self.rowCount * self.itemHigh + (self.rowCount - 1) * self.spacint_Y + self.borderTop + self.borderBottom
	-- 未显示区长度
	self.VerticalHiddenLength = self.VerticalContentLength - self.VerticalDisContentLength

	sizeDelta.y = self.VerticalContentLength
	self.container.sizeDelta = sizeDelta

	local IsCanMove = count > (self.rowCount * self.columnCount)
	
	self.ScrollRect.vertical = IsCanMove
	--print("重置content size ",count,self.VerticalContentLength,self.HonrizantolContentLength,self.VerticalHiddenLength)
 end


function ScrollBaseCls:UpdateItem()
	-- 重置Item
	
	-- 创建表
	local createList = CreateListCls.New():GetInstance()
	-- 回收表
	local recycleList = RecycleListCls.New():GetInstance()

	local normalized = self.ScrollRect.normalizedPosition
	
	self.verticalOffset = (1 - normalized.y) * self.VerticalHiddenLength

	local indexTemp = self.verticalOffset / (self.itemHigh + self.spacint_Y)
	local temp = math.max(0,indexTemp -1)

	self.startIndex = math.ceil(temp)
	
	for i = 0 ,self.rowCount do
		
		for j = 0 ,(self.columnCount - 1) do
			
			-- 显示的索引
			if self.startIndex < 0 or self.startIndex > self.dataRowCount - 1 then
				break
			end
			
			local realIndex = (self.startIndex + i) * self.columnCount + j + 1
			
			if realIndex < 0 or realIndex > self.dataCount  then
				break
			end
			
			if (not self.PrevDisplayIndex:Contains(realIndex)) then
				createList:Add(realIndex,realIndex)
				--createList:Enqueue(realIndex)
			end
			
			self.CurrDisplayIndex:Add(realIndex,realIndex)
			
		end
		
	end

	-- 检查是否删除
	local PrevDisplayIndexKeys = self.PrevDisplayIndex:GetKeys()
	
	for i = 1 ,#PrevDisplayIndexKeys do
		--print("检查是否删除")	
		local key = PrevDisplayIndexKeys[i]
		if not self.CurrDisplayIndex:Contains(key) then
			
			recycleList:Add(key,key)
			--recycleList:Enqueue(key)
		end
	end

	-- 回收
	
	local recycleListKeys = recycleList:GetKeys()

	for i = 1 ,#recycleListKeys do
		--print("回收")
		
		local key = recycleListKeys[i]
		local item = self.SpawnedInstances:GetEntryByKey(key)
		
		self:RemoveChild(item)
		self.SpawnedInstances:Remove(key)
		self.ItemPool:Push(item)
	end
	
	local createListKeys = createList:GetKeys()

	for i = 1 ,#createListKeys do
		--print("显示")
		local key = createListKeys[i]
		local item = self:GetItem(self.itemCls,key)
		
		local position = self:GetItemPosition(key)
		item:ResetPosition(position)
		self.SpawnedInstances:Add(key,item)		
	end

	self.PrevDisplayIndex:Clear()
	local keys = self.CurrDisplayIndex:GetKeys()
	for i = 1 ,#keys do
		local key = keys[i]
		local value = self.CurrDisplayIndex:GetEntryByKey(key)
	
		self.PrevDisplayIndex:Add(key,value)
	end

	self.CurrDisplayIndex:Clear()

end


function ScrollBaseCls:GetSpawnedInstances( )
	return self.SpawnedInstances
end

function ScrollBaseCls:GetItemPool()
	return self.ItemPool
end


function ScrollBaseCls:GetItem(cls,index)
	-- 获取Item

	local item 
	item = self.ItemPool:Get()

	if item == nil then	 
		item = self.ItemPool:Create(cls,self.contentTrans,self.itemWidth,self.itemHigh,self.callbackTable,self.callBackFunc)
	end
	
	

	---  数据绑定 子Item 需要有OnBind方法 arg : data 数据 dataType 数据类型
	local data = self.data:GetEntryByIndex(index)
	--local dataType = self.data:GetType()
	item:OnBind(data,index,self.args)

	self:AddChild(item)
	
	return item
end


function ScrollBaseCls:GetItemPosition(dataIndex)
	-- 重新计算Item生成的位置
	
	local index = dataIndex - 1
	local rowIndex = math.floor(index / self.columnCount)
	local columnIndex = index % self.columnCount
	
	local x = (-self.HonrizantolContentLength + self.itemWidth) * 0.5 + columnIndex * (self.itemWidth + self.spacint_X) + self.borderLeft
	local y = (self.VerticalContentLength - self.itemHigh) * 0.5 - rowIndex * (self.itemHigh + self.spacint_Y)  - self.borderTop

	return Vector2(x,y)


end
--------------处理item 选中状态--------------------------------
function ScrollBaseCls:ClearAllItemSelecetdState()
	-- 设置item 全部清除选中状态
	local spwanedPool = self.SpawnedInstances

 	local nodeKeys = spwanedPool:GetKeys()
 	local nodeLength = #nodeKeys

 	for  i = 1 ,nodeLength do
 		local key = nodeKeys[i]
 		local node = spwanedPool:GetEntryByKey(key)
 		node:SetSelectedState(false)
 	end
end

function ScrollBaseCls:SetItemSelecetdState()
	-- 设置item选中状态
	local spwanedPool = self.SpawnedInstances
	
	local nodeKeys = spwanedPool:GetKeys()
	local nodeLength = #nodeKeys

	for  i = 1 ,nodeLength do
 		local key = nodeKeys[i] 		
 		local node = spwanedPool:GetEntryByKey(key)

 		local active = self:GetNodeActive(key)
 		node:SetSelectedState(active)

 		if not active then
 			self.OnSelectedStateDict:Remove(key)
 		end
 	end
 	
end

function ScrollBaseCls:ClearSelectedState()
	-- 清空选中的状态列表
	self.OnSelectedStateDict:Clear()
end

function ScrollBaseCls:AddSelectedState(key,active)
	if self.OnSelectedStateDict:Contains(key) then
		self.OnSelectedStateDict:Remove(key)
	end

	self.OnSelectedStateDict:Add(key,active)
end

function ScrollBaseCls:RemoveSelectedState(key)
	self.OnSelectedStateDict:Remove(key)
end

function ScrollBaseCls:GetNodeActive(key)
	local active =self.OnSelectedStateDict:GetEntryByKey(key)
	if active == nil then
		active = false
	end
	return active
end

return ScrollBaseCls