require "Const"
require "Object.LuaObject"

local PlayerData = Class(LuaObject)

function PlayerData:Ctor()
    self.state = true
end

-----------------------------------------------------------------------
--- 根据不同业务 写的更新函数
-----------------------------------------------------------------------
function PlayerData:Update(data)
    self.playerUID = data.playerUID
    self.headID = data.headID
    self.headColor = data.headColor
    self.playerLevel = data.playerLevel
    self.playerName = data.playerName
    self.zhanli = data.zhanli
    self.data = data
end

function PlayerData:UpdateState(state)
    self.state = state
end

function PlayerData:UpdateByDataModle(data)
    self.playerUID = data:GetUid()
    self.headID = data:GetHeadID()
    self.headColor = data:GetHeadColor()
    self.playerLevel = data:GetPlayerLevel()
    self.playerName = data:GetPlayerName()
    self.zhanli = data:GetZhanli()
    self.data = data:GetData()
end
-----------------------------------------------------------------------
--- 获取函数
-----------------------------------------------------------------------

function PlayerData:GetUid()
    return self.playerUID
end

function PlayerData:GetHeadID()
    return self.headID
end

function PlayerData:GetHeadColor()
    return self.headColor
end

function PlayerData:GetPlayerLevel()
    return self.playerLevel
end

function PlayerData:GetPlayerName()
    return self.playerName
end

function PlayerData:GetZhanli()
    return self.zhanli
end

function PlayerData:GetState()
    return self.state
end

function PlayerData:GetData()
    return self.data
end

return PlayerData