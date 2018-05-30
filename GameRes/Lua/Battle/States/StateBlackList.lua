
require "Class"

-- @@ BlackEntryClass 类定义 @@ --
local BlackEntryClass = Class()

function BlackEntryClass:Ctor(id)
    self.id = id
    self.count = 1
end

function BlackEntryClass:AddRefCount()
    if self.count <= 0 then
        error(string.format('id <%d> 已经无效了, 无法添加引用计数!', self.id))
    end
    self.count = self.count + 1
end

function BlackEntryClass:RemoveRefCount()
    if self.count <= 0 then
        error(string.format('id <%d> 已经无效了, 无法删除引用计数!', self.id))
    end
    self.count = self.count - 1
end

function BlackEntryClass:IsGone()
    return self.count <= 0
end

-- @@ StateBlackList 类定义 @@ --
local StateBlackList = Class()

function StateBlackList:Ctor()
    self.entries = {}
end

function StateBlackList:Add(id)
    if self.entries[id] == nil then
        self.entries[id] = BlackEntryClass.New(id)
        return
    end
    self.entries[id]:AddRefCount()
end

function StateBlackList:Remove(id)
    if self.entries[id] ~= nil then
        local entry = self.entries[id]
        entry:RemoveRefCount()
        if entry:IsGone() then
            self.entries[id] = nil
        end
    end
end

function StateBlackList:Contains(id)
    return self.entries[id] ~= nil
end

return StateBlackList
