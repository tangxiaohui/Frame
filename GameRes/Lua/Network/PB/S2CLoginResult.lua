-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf.protobuf"
local ProtocolId = require("Network.PB.ProtocolId")
local HeadMessage = require("Network.PB.HeadMessage")
module('Network.PB.S2CLoginResult')


local __PBTABLE__ = {}

local S2CLOGINRESULT = protobuf.Descriptor();
_M.S2CLOGINRESULT = S2CLOGINRESULT

__PBTABLE__.S2CLOGINRESULT_ID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.S2CLOGINRESULT_HEAD_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.S2CLOGINRESULT_RESULT_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.S2CLOGINRESULT_SYSTIME_FIELD = protobuf.FieldDescriptor();

__PBTABLE__.S2CLOGINRESULT_ID_FIELD.name = "id"
__PBTABLE__.S2CLOGINRESULT_ID_FIELD.full_name = ".PB.S2CLoginResult.id"
__PBTABLE__.S2CLOGINRESULT_ID_FIELD.number = 1
__PBTABLE__.S2CLOGINRESULT_ID_FIELD.index = 0
__PBTABLE__.S2CLOGINRESULT_ID_FIELD.label = 1
__PBTABLE__.S2CLOGINRESULT_ID_FIELD.has_default_value = true
__PBTABLE__.S2CLOGINRESULT_ID_FIELD.default_value = "SND_ACCOUNT_LOGIN_RESULT_MESSAGE"
__PBTABLE__.S2CLOGINRESULT_ID_FIELD.enum_type = PROTOCOLID or ProtocolId.PROTOCOLID
__PBTABLE__.S2CLOGINRESULT_ID_FIELD.type = 14
__PBTABLE__.S2CLOGINRESULT_ID_FIELD.cpp_type = 8

__PBTABLE__.S2CLOGINRESULT_HEAD_FIELD.name = "head"
__PBTABLE__.S2CLOGINRESULT_HEAD_FIELD.full_name = ".PB.S2CLoginResult.head"
__PBTABLE__.S2CLOGINRESULT_HEAD_FIELD.number = 2
__PBTABLE__.S2CLOGINRESULT_HEAD_FIELD.index = 1
__PBTABLE__.S2CLOGINRESULT_HEAD_FIELD.label = 1
__PBTABLE__.S2CLOGINRESULT_HEAD_FIELD.has_default_value = false
__PBTABLE__.S2CLOGINRESULT_HEAD_FIELD.default_value = nil
__PBTABLE__.S2CLOGINRESULT_HEAD_FIELD.message_type = HEADMESSAGE or HeadMessage.HEADMESSAGE
__PBTABLE__.S2CLOGINRESULT_HEAD_FIELD.type = 11
__PBTABLE__.S2CLOGINRESULT_HEAD_FIELD.cpp_type = 10

__PBTABLE__.S2CLOGINRESULT_RESULT_FIELD.name = "result"
__PBTABLE__.S2CLOGINRESULT_RESULT_FIELD.full_name = ".PB.S2CLoginResult.result"
__PBTABLE__.S2CLOGINRESULT_RESULT_FIELD.number = 3
__PBTABLE__.S2CLOGINRESULT_RESULT_FIELD.index = 2
__PBTABLE__.S2CLOGINRESULT_RESULT_FIELD.label = 1
__PBTABLE__.S2CLOGINRESULT_RESULT_FIELD.has_default_value = false
__PBTABLE__.S2CLOGINRESULT_RESULT_FIELD.default_value = 0
__PBTABLE__.S2CLOGINRESULT_RESULT_FIELD.type = 5
__PBTABLE__.S2CLOGINRESULT_RESULT_FIELD.cpp_type = 1

__PBTABLE__.S2CLOGINRESULT_SYSTIME_FIELD.name = "sysTime"
__PBTABLE__.S2CLOGINRESULT_SYSTIME_FIELD.full_name = ".PB.S2CLoginResult.sysTime"
__PBTABLE__.S2CLOGINRESULT_SYSTIME_FIELD.number = 4
__PBTABLE__.S2CLOGINRESULT_SYSTIME_FIELD.index = 3
__PBTABLE__.S2CLOGINRESULT_SYSTIME_FIELD.label = 1
__PBTABLE__.S2CLOGINRESULT_SYSTIME_FIELD.has_default_value = false
__PBTABLE__.S2CLOGINRESULT_SYSTIME_FIELD.default_value = 0
__PBTABLE__.S2CLOGINRESULT_SYSTIME_FIELD.type = 3
__PBTABLE__.S2CLOGINRESULT_SYSTIME_FIELD.cpp_type = 2

S2CLOGINRESULT.name = "S2CLoginResult"
S2CLOGINRESULT.full_name = ".PB.S2CLoginResult"
S2CLOGINRESULT.nested_types = {}
S2CLOGINRESULT.enum_types = {}
S2CLOGINRESULT.fields = {__PBTABLE__.S2CLOGINRESULT_ID_FIELD, __PBTABLE__.S2CLOGINRESULT_HEAD_FIELD, __PBTABLE__.S2CLOGINRESULT_RESULT_FIELD, __PBTABLE__.S2CLOGINRESULT_SYSTIME_FIELD}
S2CLOGINRESULT.is_extendable = false
S2CLOGINRESULT.extensions = {}

S2CLoginResult = protobuf.Message(S2CLOGINRESULT)

