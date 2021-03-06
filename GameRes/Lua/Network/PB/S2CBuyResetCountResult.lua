-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf.protobuf"
local ProtocolId = require("Network.PB.ProtocolId")
local HeadMessage = require("Network.PB.HeadMessage")
module('Network.PB.S2CBuyResetCountResult')


local __PBTABLE__ = {}

local BUYRESETCOUNTRESULT = protobuf.Descriptor();
_M.BUYRESETCOUNTRESULT = BUYRESETCOUNTRESULT

__PBTABLE__.BUYRESETCOUNTRESULT_ID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.BUYRESETCOUNTRESULT_HEAD_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.BUYRESETCOUNTRESULT_SURPLUSFREERESETCOUNT_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.BUYRESETCOUNTRESULT_ALREAYBUYCOUNT_FIELD = protobuf.FieldDescriptor();

__PBTABLE__.BUYRESETCOUNTRESULT_ID_FIELD.name = "id"
__PBTABLE__.BUYRESETCOUNTRESULT_ID_FIELD.full_name = ".PB.BuyResetCountResult.id"
__PBTABLE__.BUYRESETCOUNTRESULT_ID_FIELD.number = 1
__PBTABLE__.BUYRESETCOUNTRESULT_ID_FIELD.index = 0
__PBTABLE__.BUYRESETCOUNTRESULT_ID_FIELD.label = 1
__PBTABLE__.BUYRESETCOUNTRESULT_ID_FIELD.has_default_value = true
__PBTABLE__.BUYRESETCOUNTRESULT_ID_FIELD.default_value = "SND_TOWER_BUY_RESETCOUNT_RESULT_MESSAGE"
__PBTABLE__.BUYRESETCOUNTRESULT_ID_FIELD.enum_type = PROTOCOLID or ProtocolId.PROTOCOLID
__PBTABLE__.BUYRESETCOUNTRESULT_ID_FIELD.type = 14
__PBTABLE__.BUYRESETCOUNTRESULT_ID_FIELD.cpp_type = 8

__PBTABLE__.BUYRESETCOUNTRESULT_HEAD_FIELD.name = "head"
__PBTABLE__.BUYRESETCOUNTRESULT_HEAD_FIELD.full_name = ".PB.BuyResetCountResult.head"
__PBTABLE__.BUYRESETCOUNTRESULT_HEAD_FIELD.number = 2
__PBTABLE__.BUYRESETCOUNTRESULT_HEAD_FIELD.index = 1
__PBTABLE__.BUYRESETCOUNTRESULT_HEAD_FIELD.label = 1
__PBTABLE__.BUYRESETCOUNTRESULT_HEAD_FIELD.has_default_value = false
__PBTABLE__.BUYRESETCOUNTRESULT_HEAD_FIELD.default_value = nil
__PBTABLE__.BUYRESETCOUNTRESULT_HEAD_FIELD.message_type = HEADMESSAGE or HeadMessage.HEADMESSAGE
__PBTABLE__.BUYRESETCOUNTRESULT_HEAD_FIELD.type = 11
__PBTABLE__.BUYRESETCOUNTRESULT_HEAD_FIELD.cpp_type = 10

__PBTABLE__.BUYRESETCOUNTRESULT_SURPLUSFREERESETCOUNT_FIELD.name = "surplusFreeResetCount"
__PBTABLE__.BUYRESETCOUNTRESULT_SURPLUSFREERESETCOUNT_FIELD.full_name = ".PB.BuyResetCountResult.surplusFreeResetCount"
__PBTABLE__.BUYRESETCOUNTRESULT_SURPLUSFREERESETCOUNT_FIELD.number = 3
__PBTABLE__.BUYRESETCOUNTRESULT_SURPLUSFREERESETCOUNT_FIELD.index = 2
__PBTABLE__.BUYRESETCOUNTRESULT_SURPLUSFREERESETCOUNT_FIELD.label = 1
__PBTABLE__.BUYRESETCOUNTRESULT_SURPLUSFREERESETCOUNT_FIELD.has_default_value = false
__PBTABLE__.BUYRESETCOUNTRESULT_SURPLUSFREERESETCOUNT_FIELD.default_value = 0
__PBTABLE__.BUYRESETCOUNTRESULT_SURPLUSFREERESETCOUNT_FIELD.type = 5
__PBTABLE__.BUYRESETCOUNTRESULT_SURPLUSFREERESETCOUNT_FIELD.cpp_type = 1

__PBTABLE__.BUYRESETCOUNTRESULT_ALREAYBUYCOUNT_FIELD.name = "alreayBuyCount"
__PBTABLE__.BUYRESETCOUNTRESULT_ALREAYBUYCOUNT_FIELD.full_name = ".PB.BuyResetCountResult.alreayBuyCount"
__PBTABLE__.BUYRESETCOUNTRESULT_ALREAYBUYCOUNT_FIELD.number = 4
__PBTABLE__.BUYRESETCOUNTRESULT_ALREAYBUYCOUNT_FIELD.index = 3
__PBTABLE__.BUYRESETCOUNTRESULT_ALREAYBUYCOUNT_FIELD.label = 1
__PBTABLE__.BUYRESETCOUNTRESULT_ALREAYBUYCOUNT_FIELD.has_default_value = false
__PBTABLE__.BUYRESETCOUNTRESULT_ALREAYBUYCOUNT_FIELD.default_value = 0
__PBTABLE__.BUYRESETCOUNTRESULT_ALREAYBUYCOUNT_FIELD.type = 5
__PBTABLE__.BUYRESETCOUNTRESULT_ALREAYBUYCOUNT_FIELD.cpp_type = 1

BUYRESETCOUNTRESULT.name = "BuyResetCountResult"
BUYRESETCOUNTRESULT.full_name = ".PB.BuyResetCountResult"
BUYRESETCOUNTRESULT.nested_types = {}
BUYRESETCOUNTRESULT.enum_types = {}
BUYRESETCOUNTRESULT.fields = {__PBTABLE__.BUYRESETCOUNTRESULT_ID_FIELD, __PBTABLE__.BUYRESETCOUNTRESULT_HEAD_FIELD, __PBTABLE__.BUYRESETCOUNTRESULT_SURPLUSFREERESETCOUNT_FIELD, __PBTABLE__.BUYRESETCOUNTRESULT_ALREAYBUYCOUNT_FIELD}
BUYRESETCOUNTRESULT.is_extendable = false
BUYRESETCOUNTRESULT.extensions = {}

BuyResetCountResult = protobuf.Message(BUYRESETCOUNTRESULT)

