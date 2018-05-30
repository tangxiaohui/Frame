
local ServerData = Class()

function ServerData:Ctor(jsonData)
	self.id = jsonData.id
    self.ip = jsonData.ip
    self.port = jsonData.port
    self.name = jsonData.name
    self.is_inner = jsonData.is_inner
    self.limit = jsonData.limit
    self.serverState = jsonData.ServerState
    self.isNew = jsonData.IsNew
    self.is_recommendation = jsonData.Isrecommended
    self.platform = jsonData.plat
    self.content = jsonData.content -- 维护展现内容 --
end

-- 服务器ID
function ServerData:GetId()
	return self.id
end

-- 服务器IP
function ServerData:GetIp()
	return self.ip
end

-- 服务器端口
function ServerData:GetPort()
	return self.port
end

-- 是否为内网服 --
function ServerData:IsInner()
	return self.is_inner
end

-- 可视限制 --
function ServerData:GetLimit()
    return self.limit
end

-- 服务器状态 --
function ServerData:GetServerState()
    return self.serverState
end

-- 是否为新服 --
function ServerData:IsNew()
    return self.isNew
end

-- 是否推荐 --
function ServerData:IsRecommended()
    return self.is_recommendation
end

-- 平台 --
function ServerData:GetPlatform()
    return self.platform
end

-- 维护展现内容 --
function ServerData:GetContent()
    return self.content
end

function ServerData:ToString()
    local str = string.format(
        "id = %d, ip = %s, port = %d, name = %s, inner = %d, limit = %d, serverState = %d, isNew = %d, isrecommended = %d, platform = %s, content = %s",
        self.id,
        self.ip,
        self.port,
        self.name,
        self.is_inner,
        self.limit,
        self.serverState,
        self.isNew,
        self.is_recommendation,
        self.platform,
        self.content
    )
    return str
end

return ServerData