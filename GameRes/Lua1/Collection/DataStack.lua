--
-- User: fbmly
-- Date: 3/3/17
-- Time: 2:11 PM
--

require "Object.LuaObject"
local utility = require "Utils.Utility"

DataStack = Class(LuaObject)

function DataStack:Ctor()
    self.dataList = {}
end

function DataStack:Push(data)
    if data ~= nil then
        self.dataList[#self.dataList + 1] = data
    end
end

function DataStack:Pop()
    local count = self:Count()
    if count > 0 then
        local retn = self.dataList[count]
        self.dataList[count] = nil
        return retn
    end
    return nil
end

function DataStack:Peek()
    local count = self:Count()
    if count > 0 then
        return self.dataList[count]
    end
    return nil
end

function DataStack:Count()
    return #self.dataList
end

function DataStack:Clear()
    utility.ClearArrayTableContent(self.dataList)
end

function DataStack:Remove(filterFunc)
    local count = self:Count()
    for i = count, 1, -1 do
        if filterFunc(self.dataList[i]) then
            table.remove(self.dataList, i)
        end
    end
end

function DataStack:Test()
    print('>>>>>>>>>> test data stack start <<<<<<<<<<')
    utility.ASSERT(self:Count() == 0, '应该是没数据才对 可是现在有数据!')
    self:Push(1)
    utility.ASSERT(self:Count() == 1, '数据长度为1 才对!')
    self:Push(2)
    utility.ASSERT(self:Count() == 2, '数据长度为2 才对!')
    local v1 = self:Pop()
    utility.ASSERT(v1 == 2, '弹出的数据应该为2 才对!')
    utility.ASSERT(self:Count() == 1, '数据长度为1 才对!')

    local p1 = self:Peek()
    utility.ASSERT(p1 == 1, '顶层数据应该是1  才对!')
    utility.ASSERT(self:Count() == 1, '数据长度应该为1 才对!')

    self:Clear()
    utility.ASSERT(self:Count() == 0, '数据清除 应该是没数据才对!')

    local v2 = self:Pop()
    utility.ASSERT(v2 == nil, '数据是空的  所以返回应该是nil才对!')

    print('>>>>>>>>>> test data stack  end  <<<<<<<<<<')
end