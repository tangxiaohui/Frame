--
-- User: fbmly
-- Date: 3/3/17
-- Time: 2:12 PM
--

require "Object.LuaObject"
local utility = require "Utils.Utility"

OrderedDictionary = Class(LuaObject)

function OrderedDictionary:Ctor()
    self.dataDict = {}
    self.orderedKeys = {}
end

function OrderedDictionary:Set(key, value)
    if key == nil then error('key is nil') end
    if value == nil then error('value is nil') end

    if not self:Contains(key) then
        self.orderedKeys[#self.orderedKeys + 1] = key
    end
    self.dataDict[key] = value
end

function OrderedDictionary:Add(key, value)
    if key == nil then error('key is nil') end
    if value == nil then error('value is nil') end

    if self.dataDict[key] ~= nil then
        error(string.format('duplicate key: %s', tostring(key)))
    end

    self.dataDict[key] = value
    self.orderedKeys[#self.orderedKeys + 1] = key
end

function OrderedDictionary:Remove(key)
    if self.dataDict[key] ~= nil then
        for i = 1, #self.orderedKeys do
            if self.orderedKeys[i] == key then
                table.remove(self.orderedKeys, i)
                self.dataDict[key] = nil
                return true
            end
        end
    end
    return false
end

function OrderedDictionary:RemoveByIndex(index)
    local key = self.orderedKeys[index]
    if self.dataDict[key] ~= nil then
        table.remove(self.orderedKeys, index)
        self.dataDict[key] = nil
        return true
    end
    return false
end

function OrderedDictionary:Clear()
    for i = 1, #self.orderedKeys do
        local key = self.orderedKeys[i]
        self.dataDict[key] = nil
    end
    utility.ClearArrayTableContent(self.orderedKeys)
end

function OrderedDictionary:Contains(key)
    if key == nil then return false end
    return self.dataDict[key] ~= nil
end

function OrderedDictionary:Sort(func)
    table.sort(self.orderedKeys, function(key1, key2)
        return func(
            self.dataDict[key1],
            self.dataDict[key2]
        )
    end)
end

function OrderedDictionary:SortTemporarily(func)
    local retList = {}

    -- 先拷贝一遍
    for i = 1, #self.orderedKeys do
        retList[i] = self.orderedKeys[i]
    end

    -- 再执行排序
    table.sort(retList, function(key1, key2)
        return func(
            self.dataDict[key1],
            self.dataDict[key2]
        )
    end)

    return retList
end

function OrderedDictionary:GetKeysWithoutOrder()
    local ret = {}
    local key
    for i = 1, #self.orderedKeys do
        key = self.orderedKeys[i]
        ret[key] = self.dataDict[key]
    end
    return ret
end

function OrderedDictionary:GetKeys()
    local ret = {}
    for i = 1, #self.orderedKeys do
        ret[i] = self.orderedKeys[i]
    end
    return ret
end

function OrderedDictionary:Count()
    return #self.orderedKeys
end

function OrderedDictionary:GetEntryByKey(key)
    return self.dataDict[key]
end

function OrderedDictionary:GetEntryByIndex(index)
    if index >= 1 and index <= self:Count() then
        local key = self.orderedKeys[index]
        return self.dataDict[key]
    end
    return nil
end

function OrderedDictionary:GetKeyFromIndex(index)
    return self.orderedKeys[index]
end

function OrderedDictionary:Reverse()
    local i = 1
    local j = #self.orderedKeys
    local temp

    while(i < j)
    do
        temp = self.orderedKeys[i]
        self.orderedKeys[i] = self.orderedKeys[j]
        self.orderedKeys[j] = temp

        i = i + 1
        j = j - 1
    end
end

function OrderedDictionary:Test()
    print('>>>>>>>>>> test ordered dictionary start <<<<<<<<<<')

    -- self:Set(1, 1)

    -- utility.ASSERT(self:GetEntryByKey(1) == 1, "key为1 value不为1")

    -- self:Set(1, 2)

    -- utility.ASSERT(self:GetEntryByKey(1) == 2, "key为1 value不为2")

    -- utility.ASSERT(self:Count() == 1, "count不能为1!")

--    self:Add(1, 1)
--    self:Add(2, 5)
--    self:Add(3, 3)
--    self:Add(4, 2)
--    self:Add(5, 8)
--
--    print(">>>>>>>>>> before <<<<<<<<<<<")
--
--        local count = self:Count()
--        for i = 1, self:Count() do
--            print(self:GetEntryByIndex(i))
--        end
--
--    local list = self:SortTemporarily(function(n1, n2)
--        return n1 < n2
--    end)
--
--        local count = self:Count()
--        for i = 1, self:Count() do
--            print(self:GetEntryByIndex(i))
--        end
--
--    print(">>>>>>>>>>> after <<<<<<<<<<<<<<")
--
--    for i = 1, #list do
--        print(self:GetEntryByKey(list[i]))
--    end


--    local count = self:Count()
--    for i = 1, self:Count() do
--        print(self:GetEntryByIndex(i))
--    end



--    self:Sort(function(n1, n2)
--        return n1 < n2
--    end)
--
--    print(">>>>>>>>>> after <<<<<<<<<<<")
--    local count = self:Count()
--    for i = 1, self:Count() do
--        print(self:GetEntryByIndex(i))
--    end

--    utility.ASSERT(self:Count() == 0, '字典数量应该为 0')
--
--    -- add
--    self:Add(1, 'a')
--
--    utility.ASSERT(self:Count() == 1, '字典数量应该为 1')
--    utility.ASSERT(self:GetEntryByKey(1) == 'a', '字典 key为1的值应该为 a')
--    utility.ASSERT(self:Contains(1) == true, '字典key为1 应该存在!')
--    utility.ASSERT(self:GetEntryByIndex(1) == 'a', '索引1的位置的值 应该为 a')
--
--    -- remove error
--    local b = self:Remove(0)
--    utility.ASSERT(b == false, '应该删除失败了 才对!')
--    utility.ASSERT(self:Count() == 1, '字典数量应该为 1')
--
--    -- remove ok!
--    local c = self:Remove(1)
--    utility.ASSERT(c == true, '应该删除成功了 才对!')
--    utility.ASSERT(self:Count() == 0, '字典数量应该为 0')
--    utility.ASSERT(self:Contains(1) == false, '字典key为1 应该没了 才对!!')
--    utility.ASSERT(self:GetEntryByIndex(1) == nil, '索引为1的位置 因该为nil 因为没了')
--
--    -- add double
--    self:Add(1, 'a')
--    self:Add(2, 'b')
--    utility.ASSERT(self:Count() == 2, '字典数量应该为 2')
--    utility.ASSERT(self:GetEntryByIndex(1) == 'a', '索引为1的位置 应该为 a')
--
--    -- remove 1
--    self:Remove(1)
--    utility.ASSERT(self:Count() == 1, '字典数量应该为 1')
--    utility.ASSERT(self:GetEntryByIndex(1) == 'b', '索引为1的位置 应该为 b')
--
--    -- clear all
--    self:Clear()
--    utility.ASSERT(self:Count() == 0, '字典数量应该为 0')
--    utility.ASSERT(self:Contains(1) == false, '字典key为1 应该没了 才对!!')
--    utility.ASSERT(self:Contains(2) == false, '字典key为2 应该没了 才对!!')

    print('>>>>>>>>>> test ordered dictionary  end　<<<<<<<<<<')
end