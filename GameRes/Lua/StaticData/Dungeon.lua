--
-- User: fbmly
-- Date: 2/6/17
-- Time: 6:43 PM
--

require "StaticData.Manager"
local levelInfoMgr = require "StaticData.LevelInfo"

DungeonData = Class(LuaObject)

local function CheckValidL(self)
    local roles = self.data.role
    local positions = self.data.position
    local colors = self.data.color
    local levels = self.data.level

    -- 拿 roles 的数量当基准!
    local count = roles.Count

    -- 检测 positions
    if positions.Count ~= count then
        error(
            string.format(
                '地牢id为 %d 的参数数量不一样, role的数量为 %d, position的数量为 %d',
                self:GetId(), roles.Count, positions.Count
            )
        )
    end

    -- 检测 colors
    if colors.Count ~= count then
        error(
            string.format(
                '地牢id为 %d 的参数数量不一样, role的数量为 %d, color的数量为 %d',
                self:GetId(), roles.Count, colors.Count
            )
        )
    end

    -- 检测 levels
    if levels.Count ~= count then
        error(
            string.format(
                '地牢id为 %d 的参数数量不一样, role的数量为 %d, level的数量为 %d',
                self:GetId(), roles.Count, levels.Count
            )
        )
    end
end

function DungeonData:Ctor(id)
    local dungeonMgr = Data.Dungeon.Manager.Instance()
    self.data = dungeonMgr:GetObject(id)
    if self.data == nil then
        error(string.format("地牢不存在，ID: %s 不存在", id))
        return
    end

    -- 关卡信息
--    self.levelInfo = levelInfoMgr:GetData(self.data.info)

    -- 解析其他信息
    CheckValidL(self)
end

function DungeonData:GetId()
    return self.data.id
end

function DungeonData:GetLevelInfo()
    return self.levelInfo
end

function DungeonData:GetRoles()
    return self.data.role
end

function DungeonData:GetPositions()
    return self.data.position
end

function DungeonData:GetColors()
    return self.data.color
end

function DungeonData:GetLevels()
    return self.data.level
end

function DungeonData:Test()
    print('******************** start *********************')

    print('id', self:GetId())
    print('info.id', self.levelInfo:GetId())
    print('info.name', self.levelInfo:GetName())
    print('info.desc', self.levelInfo:GetDesc())

    print('roles', self:GetRoles().Count)
    for i = 0, self:GetRoles().Count - 1 do
        local roleId = self:GetRoles()[i]
        print('role id', roleId)
    end

    print('positions', self:GetPositions().Count)
    for i = 0, self:GetPositions().Count - 1 do
        local posId = self:GetPositions()[i]
        print('pos id', posId)
    end

    print('colors', self:GetColors().Count)
    for i = 0, self:GetColors().Count - 1 do
        local colorV = self:GetColors()[i]
        print('color value', colorV)
    end

    print('levels', self:GetLevels().Count)
    for i = 0, self:GetLevels().Count - 1 do
        local levelValue = self:GetLevels()[i]
        print('level value', levelValue)
    end

    print('********************  end  *********************')
end

local dungeonManagerCls = Class(DataManager)
return dungeonManagerCls.New(DungeonData)

