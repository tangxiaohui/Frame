--
-- User: fbmly
-- Date: 4/25/17
-- Time: 11:21 PM
--

require "Object.LuaObject"
local utility = require "Utils.Utility"

DataQueue = Class(LuaObject)

function DataQueue:Ctor(dataArray)
    self.dataList = dataArray or {}
end

function DataQueue:Enqueue(data)
    if data ~= nil then
        self.dataList[#self.dataList + 1] = data
    end
end

function DataQueue:Dequeue()
    local count = self:Count()
    if count > 0 then
        local retn = self.dataList[1]
        table.remove(self.dataList, 1) -- 顺序不能变
        return retn
    end
    return nil
end

function DataQueue:Front()
    return self.dataList[1]
end

function DataQueue:Back()
    return self.dataList[#self.dataList]
end

function DataQueue:Remove(filterFunc)
    local count = self:Count()
    for i = count, 1, -1 do
        if filterFunc(self.dataList[i]) then
            table.remove(self.dataList, i)
            return true
        end
    end
    return false
end

function DataQueue:Clear()
    utility.ClearArrayTableContent(self.dataList)
end

function DataQueue:Foreach(func)
    local count = self:Count()
    for i = 1, count do
        func(self.dataList[i], i)
    end
end

function DataQueue:Exists(findFunc)
    local count = self:Count()
    for i = 1, count do
        if findFunc(self.dataList[i]) then
            return true
        end
    end
    return false
end

function DataQueue:Count()
    return #self.dataList
end

function DataQueue:Test()
    print('>>>>>>>>>> test data queue start <<<<<<<<<<')

    utility.ASSERT(self:Count() == 0, '应该是没数据才对 可以现在有数据!')

    self:Enqueue(1) -- ##  放入1
    self:Enqueue(2) -- ##  放入2

    utility.ASSERT(self:Count() == 2, '数据长度为2 才对!')

    local v1 = self:Dequeue()
    utility.ASSERT(v1 == 1, '弹出的数据应该为1 才对!')

    utility.ASSERT(self:Count() == 1, '数据长度为1 才对!')

    self:Clear()

    utility.ASSERT(self:Count() == 0, '数据长度为0 才对!')

    print('>>>>>>>>>> test data queue end <<<<<<<<<<')
end