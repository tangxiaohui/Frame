--
-- User: fbmly
-- Date: 4/11/17
-- Time: 4:06 PM
--
local BaseNodeClass = require "Framework.Base.Node"
local utility = require "Utils.Utility"
require "System.LuaDelegate"
require "Collection.OrderedDictionary"
local ProtocolId = require "Network.PB.ProtocolId"

-----------------------------------------------------------------------
--- 所存的网络状态
-----------------------------------------------------------------------
local NetworkBatchEntry = Class()

function NetworkBatchEntry:Ctor(processing, responsePrototype, requestMsg, requestPrototype)
    self.processing = processing

    self.responsePrototype = responsePrototype
    self.requestMsg = requestMsg
    self.requestPrototype = requestPrototype

    self.passed = false
end

function NetworkBatchEntry:GetResponsePrototype()
    return self.responsePrototype
end

function NetworkBatchEntry:GetRequestParameters()
    return self.requestMsg, self.requestPrototype
end

function NetworkBatchEntry:HasPassed()
    return self.passed
end

function NetworkBatchEntry:Pass()
    self.passed = true
end


-----------------------------------------------------------------------
--- 网络批处理
-----------------------------------------------------------------------
local NetworkBatchProcessing = Class(BaseNodeClass)

function NetworkBatchProcessing:Ctor()
    self.protocols = OrderedDictionary.New()
    self.started = false
    self.callback = LuaDelegate.New()

    self.passedCount = 0
end

local function OnMsgReceive(self, msg)
    if self:IsReady() then
        --error("批处理已经完成了, 不可能打出这句话!")
        return
    end

    local id = ProtocolId[msg.id]
    --debug_print("received...",id)
    local entry = self.protocols:GetEntryByKey(id)
    if entry:HasPassed() then
        -- error(string.format("id为 %d 的任务 已经完成了 可是又走了一次!", id))
        -- 已不再监听中, 可以放过去!
        return
    end

    entry:Pass()

    self.passedCount = self.passedCount + 1
    if self:IsReady() then
        self.started = false
        -- finished!
        self.callback:Invoke()
    end
end

function NetworkBatchProcessing:SetCallback(table, func)
    self.callback:Set(table, func)
end

function NetworkBatchProcessing:Add(responsePrototype, requestMsg, requestPrototype)
    utility.ASSERT(responsePrototype ~= nil, "responsePrototype参数不能是nil")
    utility.ASSERT(requestMsg ~= nil, "msg参数不能为nil")
    utility.ASSERT(requestPrototype ~= nil, "prototype参数不能为nil")

    local messageManager = require "Network.MessageManager"
    local responseId = messageManager:GetProtocolId(responsePrototype)

    self.protocols:Add(responseId, NetworkBatchEntry.New(self, responsePrototype, requestMsg, requestPrototype))
end

function NetworkBatchProcessing:Start()
    if self:Count() == 0 then
        error("必须至少设置一个Response协议")
    end

    if self.started then
        return
    end

    local game = self:GetGame()
    local count = self:Count()

    self.passedCount = 0

    --= 重置并设置回调 =--
    for i = 1, count do
        local entry = self.protocols:GetEntryByIndex(i)
        local msg, prototype = entry:GetRequestParameters()

        game:UnRegisterMsgHandler(entry:GetResponsePrototype(), self, OnMsgReceive)
        game:RegisterMsgHandler(entry:GetResponsePrototype(), self, OnMsgReceive)

        game:SendNetworkMessage(msg, prototype)
    end
end

function NetworkBatchProcessing:IsReady()
    return self.passedCount == self:Count()
end

function NetworkBatchProcessing:Close()
    self.passedCount = 0
    local game = self:GetGame()
    local count = self:Count()

    for i = 1, count do
        local entry = self.protocols:GetEntryByIndex(i)
        game:UnRegisterMsgHandler(entry:GetResponsePrototype(), self, OnMsgReceive)
    end
    self.started = false
end

function NetworkBatchProcessing:Count()
    return self.protocols:Count()
end

return NetworkBatchProcessing

