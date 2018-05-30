
require "Object.LuaObject"
local utility = require "Utils.Utility"

-----------------------------------------------------------------------
--- 通知对象
-----------------------------------------------------------------------
local NotificationObject = Class(LuaObject)

function NotificationObject:Ctor(name, target, func, cipher)
	self.name = name
	self.target = target
	self.func = func
	self.cipher = cipher
end

function NotificationObject:GetName()
	return self.name
end

function NotificationObject:GetTarget()
	return self.target
end

function NotificationObject:GetFunction()
	return self.func
end

function NotificationObject:GetCipher()
	return self.cipher
end

function NotificationObject:Perform(cipher, ...)
	if self.target ~= nil then
		if cipher == nil or self.cipher == cipher then
			self.func(self.target, ...)
		end
	end
end

-- 匹配, 如果 nil 直接按 true , 否则比较 是否相等
function NotificationObject:CanRemove(target, func, cipher)
	if target ~= nil and target ~= self.target then
		return false
	end

	if func ~= nil and func ~= self.func then
		return false
	end

	if cipher ~= nil and cipher ~= self.cipher then
		return false
	end

	return true
end

-----------------------------------------------------------------------
--- 通知对象列表
-----------------------------------------------------------------------
local NotificationObjectList = Class(LuaObject)

function NotificationObjectList:Ctor()
	self.data = {}
end

function NotificationObjectList:Add(notification)
	self.data[#self.data + 1] = notification
end

function NotificationObjectList:Get(pos)
	return self.data[pos]
end

function NotificationObjectList:RemoveAt(pos)
	self.data[pos] = self.data[#self.data]
	self.data[#self.data] = nil
end

function NotificationObjectList:Perform(cipher, ...)
	local count = self:Count()
	for i = 1, count do
		self.data[i]:Perform(cipher, ...)
	end
end

function NotificationObjectList:PerformReversely(cipher, ...)
	for i = self:Count(), 1, -1 do
		self.data[i]:Perform(cipher, ...)
	end
end

function NotificationObjectList:Count()
	return #self.data
end


-----------------------------------------------------------------------
--- 通知中心
-----------------------------------------------------------------------
NotificationCenter = Class(LuaObject)

function NotificationCenter:Ctor()
	self.notificationDict = {}    -- name => [notification]
	self.tableDependencies = {}	  -- table => [key]
end

function NotificationCenter:AddObserver(name, target, func, cipher)
	-- 先检查三个参数 是否正确, cipher为可选项
	utility.ASSERT(name ~= nil, "name should not be nil")
	utility.ASSERT(type(target) == "table", "target should be table!")
	utility.ASSERT(type(func) == "function", "func should be function")

	-- 然后创建 notification 
	local newNotification = NotificationObject.New(name, target, func, cipher)

	-- ##### 首先加到 notificationDict 中, 建立主要内容
	local notificationObjectList = self.notificationDict[name]
	if notificationObjectList == nil then
		notificationObjectList = NotificationObjectList.New()
		self.notificationDict[name] = notificationObjectList
	end

	-- # 加入新内容到 notificationObjectList 中
	notificationObjectList:Add(newNotification)


	-- ##### 然后加入 name 到 target 中 建立关联!
	local keyList = self.tableDependencies[target]
	if keyList == nil then
		keyList = {}
		self.tableDependencies[target] = keyList
	end

	-- # 加入到末尾即可, key可以重复, 和引用计数一个意思!
	keyList[#keyList + 1] = name
end

local function RemoveTableDependencies(self, name, target)
	local keyList = self.tableDependencies[target]
	if keyList ~= nil then

		-- 逆序循环
		for i = #keyList, 1, -1 do
			if keyList[i] == name then
				-- 移除
				keyList[i] = keyList[#keyList]
				keyList[#keyList] = nil

				-- 用光清空!
				if #keyList == 0 then
					self.tableDependencies[target] = nil
				end

				-- break 这个函数只清一个!
				break
			end
		end
	end
end

local function RemoveAllObservers(self, name, target, func, cipher)
	if name ~= nil then
		-- #### 以 name 为主导, 删除所有匹配的 ####

		-- # 拿到当前 name 中的 NotificationObjectList
		local notificationObjectList = self.notificationDict[name]
		
		-- # 如果有效
		if notificationObjectList ~= nil then

			-- # 获取当前 notification 的数量
			local notificationCount = notificationObjectList:Count()

			-- # 逆序循环遍历
			for i = notificationCount, 1, -1 do

				-- # 获取当前的 Notification 对象!
				local currentNotification = notificationObjectList:Get(i)

				-- # 检查是否可以删除
				if currentNotification:CanRemove(target, func, cipher) then
					-- # 可以就删除
					notificationObjectList:RemoveAt(i)

					-- # 删除 dependencies
					RemoveTableDependencies(self, name, currentNotification:GetTarget())
				end
			end

			-- # 循环完毕 , 判断是否用光了
			if notificationObjectList:Count() == 0 then
				self.notificationDict[name] = nil
			end
		end

	else
		-- 检查参数
		utility.ASSERT(target ~= nil, "target should not be nil")

		-- #### 以 table 为主导, 删除所有匹配的 ####
		local keyList = self.tableDependencies[target]
		if keyList ~= nil then
			local keyListCount = #keyList
			for i = keyListCount, 1, -1 do
				RemoveAllObservers(self, keyList[i], target, func, cipher)
			end
		end
	end
end

-- 移除不想加太多接口 乱, 所以部分参数为 nil 的, 会直接让条件为true
function NotificationCenter:RemoveObserver(name, target, func, cipher)
	RemoveAllObservers(self, name, target, func, cipher)
end

function NotificationCenter:PostNotification(name, cipher, ...)
	-- 先检查参数 是否正确, cipher为可选项
	utility.ASSERT(name ~= nil, "name should not be nil")

	local notificationObjectList = self.notificationDict[name]
	if notificationObjectList ~= nil then
		notificationObjectList:Perform(cipher, ...)
	end
end

function NotificationCenter:PostNotificationReversely(name, cipher, ...)
	-- 先检查参数 是否正确, cipher为可选项
	utility.ASSERT(name ~= nil, "name should not be nil")

	local notificationObjectList = self.notificationDict[name]
	if notificationObjectList ~= nil then
		notificationObjectList:PerformReversely(cipher, ...)
	end
end

-----------------------------------------------------------------------
--- 测试代码
-----------------------------------------------------------------------
function NotificationCenter:TestCallback(number)
	print('number is', number)
end

function NotificationCenter:TestCallback1(n)
	print('number1 is', n)
end

function NotificationCenter:Test()
	-- print('>>>>>>>>>>>>>>>>>>>> start <<<<<<<<<<<<<<<<<<<<')
	-- # 各种添加测试
	-- utility.ASSERT(self.notificationDict['Test1'] == nil, 'Test1 should not be exist!')

	-- self:AddObserver('Test1', self, self.TestCallback, nil)
	-- utility.ASSERT(self.notificationDict['Test1'] ~= nil, 'Test1 should be exist!')

	-- self:AddObserver('Test1', self, self.TestCallback1, 'mima123')
	-- self:AddObserver('Test2', self, self.TestCallback, nil)

	-- # 发送通知
	-- self:PostNotification('Test1', nil, 5) --不带暗号(已测)
	-- self:PostNotification('Test1', 'mima123', 10) --带暗号 (已测)

	-- self:PostNotificationReversely('Test1', nil, 20) -- 逆序发消息(已测)!

	-- # 各种移除测试

	-- self:RemoveObserver('Test1')   -- 已测

	-- utility.ASSERT(self.notificationDict['Test1'] == nil, 'Test1 should not be exist!')     -- 已测
	-- utility.ASSERT(self.tableDependencies[self] == nil, 'self table should not be exist!')  -- 已测

	-- self:RemoveObserver('Test1', self) -- 已测

	-- utility.ASSERT(self.notificationDict['Test1'] == nil, 'Test1 should not be exist!')     -- 已测
	-- utility.ASSERT(self.tableDependencies[self] == nil, 'self table should not be exist!')  -- 已测
	-- self:RemoveObserver('Test1', self, self.TestCallback, nil) -- 已测

	-- utility.ASSERT(self.notificationDict['Test1']:Count() == 1, 'count should be 1') -- 已测
	
	
	-- self:RemoveObserver('Test1', self, self.TestCallback1, 'mima123') -- 只删一个 (已测)
	-- utility.ASSERT(self.notificationDict['Test1'] ~= nil, 'Test1 should not be exist!')

	-- utility.ASSERT(self.notificationDict['Test1']:Count() == 2, 'count should be 2')     -- 已测
	-- utility.ASSERT(#self.tableDependencies[self] == 3, 'table count shoule be 3')  -- 已测

	-- self:RemoveObserver(nil, self, self.TestCallback1)  -- 只删匹配的通知(已测)

	-- utility.ASSERT(self.notificationDict['Test1']:Count() == 1, 'count should be 1')     -- 已测
	-- utility.ASSERT(#self.tableDependencies[self] == 2, 'table count shoule be 2')  -- 已测

	-- self:RemoveObserver(nil, self)  -- 只删匹配的通知2(已测)

	-- utility.ASSERT(self.notificationDict['Test1'] == nil, 'test2 should be nil') 
	-- utility.ASSERT(self.notificationDict['Test2'] == nil, 'test1 should be nil')
	-- utility.ASSERT(self.tableDependencies[self] == nil, 'table should be nil')

	-- print('>>>>>>>>>>>>>>>>>>>> done! <<<<<<<<<<<<<<<<<<<<')
end