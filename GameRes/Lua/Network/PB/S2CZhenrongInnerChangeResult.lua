-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf.protobuf"
local ProtocolId = require("Network.PB.ProtocolId")
local HeadMessage = require("Network.PB.HeadMessage")
module('Network.PB.S2CZhenrongInnerChangeResult')


local __PBTABLE__ = {}

local ZHENRONGINNERCHANGERESULT = protobuf.Descriptor();
_M.ZHENRONGINNERCHANGERESULT = ZHENRONGINNERCHANGERESULT

__PBTABLE__.ZHENRONGINNERCHANGERESULT_ID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ZHENRONGINNERCHANGERESULT_HEAD_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ZHENRONGINNERCHANGERESULT_TYPE_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ZHENRONGINNERCHANGERESULT_STATE_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ZHENRONGINNERCHANGERESULT_FROMPOS_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ZHENRONGINNERCHANGERESULT_TOPOS_FIELD = protobuf.FieldDescriptor();

__PBTABLE__.ZHENRONGINNERCHANGERESULT_ID_FIELD.name = "id"
__PBTABLE__.ZHENRONGINNERCHANGERESULT_ID_FIELD.full_name = ".PB.ZhenrongInnerChangeResult.id"
__PBTABLE__.ZHENRONGINNERCHANGERESULT_ID_FIELD.number = 1
__PBTABLE__.ZHENRONGINNERCHANGERESULT_ID_FIELD.index = 0
__PBTABLE__.ZHENRONGINNERCHANGERESULT_ID_FIELD.label = 1
__PBTABLE__.ZHENRONGINNERCHANGERESULT_ID_FIELD.has_default_value = true
__PBTABLE__.ZHENRONGINNERCHANGERESULT_ID_FIELD.default_value = "SND_ZHENRONG_ZHENRONG_INNER_CHANGE_RESULT_MESSAGE"
__PBTABLE__.ZHENRONGINNERCHANGERESULT_ID_FIELD.enum_type = PROTOCOLID or ProtocolId.PROTOCOLID
__PBTABLE__.ZHENRONGINNERCHANGERESULT_ID_FIELD.type = 14
__PBTABLE__.ZHENRONGINNERCHANGERESULT_ID_FIELD.cpp_type = 8

__PBTABLE__.ZHENRONGINNERCHANGERESULT_HEAD_FIELD.name = "head"
__PBTABLE__.ZHENRONGINNERCHANGERESULT_HEAD_FIELD.full_name = ".PB.ZhenrongInnerChangeResult.head"
__PBTABLE__.ZHENRONGINNERCHANGERESULT_HEAD_FIELD.number = 2
__PBTABLE__.ZHENRONGINNERCHANGERESULT_HEAD_FIELD.index = 1
__PBTABLE__.ZHENRONGINNERCHANGERESULT_HEAD_FIELD.label = 1
__PBTABLE__.ZHENRONGINNERCHANGERESULT_HEAD_FIELD.has_default_value = false
__PBTABLE__.ZHENRONGINNERCHANGERESULT_HEAD_FIELD.default_value = nil
__PBTABLE__.ZHENRONGINNERCHANGERESULT_HEAD_FIELD.message_type = HEADMESSAGE or HeadMessage.HEADMESSAGE
__PBTABLE__.ZHENRONGINNERCHANGERESULT_HEAD_FIELD.type = 11
__PBTABLE__.ZHENRONGINNERCHANGERESULT_HEAD_FIELD.cpp_type = 10

__PBTABLE__.ZHENRONGINNERCHANGERESULT_TYPE_FIELD.name = "type"
__PBTABLE__.ZHENRONGINNERCHANGERESULT_TYPE_FIELD.full_name = ".PB.ZhenrongInnerChangeResult.type"
__PBTABLE__.ZHENRONGINNERCHANGERESULT_TYPE_FIELD.number = 3
__PBTABLE__.ZHENRONGINNERCHANGERESULT_TYPE_FIELD.index = 2
__PBTABLE__.ZHENRONGINNERCHANGERESULT_TYPE_FIELD.label = 1
__PBTABLE__.ZHENRONGINNERCHANGERESULT_TYPE_FIELD.has_default_value = false
__PBTABLE__.ZHENRONGINNERCHANGERESULT_TYPE_FIELD.default_value = 0
__PBTABLE__.ZHENRONGINNERCHANGERESULT_TYPE_FIELD.type = 5
__PBTABLE__.ZHENRONGINNERCHANGERESULT_TYPE_FIELD.cpp_type = 1

__PBTABLE__.ZHENRONGINNERCHANGERESULT_STATE_FIELD.name = "state"
__PBTABLE__.ZHENRONGINNERCHANGERESULT_STATE_FIELD.full_name = ".PB.ZhenrongInnerChangeResult.state"
__PBTABLE__.ZHENRONGINNERCHANGERESULT_STATE_FIELD.number = 4
__PBTABLE__.ZHENRONGINNERCHANGERESULT_STATE_FIELD.index = 3
__PBTABLE__.ZHENRONGINNERCHANGERESULT_STATE_FIELD.label = 1
__PBTABLE__.ZHENRONGINNERCHANGERESULT_STATE_FIELD.has_default_value = false
__PBTABLE__.ZHENRONGINNERCHANGERESULT_STATE_FIELD.default_value = 0
__PBTABLE__.ZHENRONGINNERCHANGERESULT_STATE_FIELD.type = 5
__PBTABLE__.ZHENRONGINNERCHANGERESULT_STATE_FIELD.cpp_type = 1

__PBTABLE__.ZHENRONGINNERCHANGERESULT_FROMPOS_FIELD.name = "fromPos"
__PBTABLE__.ZHENRONGINNERCHANGERESULT_FROMPOS_FIELD.full_name = ".PB.ZhenrongInnerChangeResult.fromPos"
__PBTABLE__.ZHENRONGINNERCHANGERESULT_FROMPOS_FIELD.number = 5
__PBTABLE__.ZHENRONGINNERCHANGERESULT_FROMPOS_FIELD.index = 4
__PBTABLE__.ZHENRONGINNERCHANGERESULT_FROMPOS_FIELD.label = 1
__PBTABLE__.ZHENRONGINNERCHANGERESULT_FROMPOS_FIELD.has_default_value = false
__PBTABLE__.ZHENRONGINNERCHANGERESULT_FROMPOS_FIELD.default_value = 0
__PBTABLE__.ZHENRONGINNERCHANGERESULT_FROMPOS_FIELD.type = 5
__PBTABLE__.ZHENRONGINNERCHANGERESULT_FROMPOS_FIELD.cpp_type = 1

__PBTABLE__.ZHENRONGINNERCHANGERESULT_TOPOS_FIELD.name = "toPos"
__PBTABLE__.ZHENRONGINNERCHANGERESULT_TOPOS_FIELD.full_name = ".PB.ZhenrongInnerChangeResult.toPos"
__PBTABLE__.ZHENRONGINNERCHANGERESULT_TOPOS_FIELD.number = 6
__PBTABLE__.ZHENRONGINNERCHANGERESULT_TOPOS_FIELD.index = 5
__PBTABLE__.ZHENRONGINNERCHANGERESULT_TOPOS_FIELD.label = 1
__PBTABLE__.ZHENRONGINNERCHANGERESULT_TOPOS_FIELD.has_default_value = false
__PBTABLE__.ZHENRONGINNERCHANGERESULT_TOPOS_FIELD.default_value = 0
__PBTABLE__.ZHENRONGINNERCHANGERESULT_TOPOS_FIELD.type = 5
__PBTABLE__.ZHENRONGINNERCHANGERESULT_TOPOS_FIELD.cpp_type = 1

ZHENRONGINNERCHANGERESULT.name = "ZhenrongInnerChangeResult"
ZHENRONGINNERCHANGERESULT.full_name = ".PB.ZhenrongInnerChangeResult"
ZHENRONGINNERCHANGERESULT.nested_types = {}
ZHENRONGINNERCHANGERESULT.enum_types = {}
ZHENRONGINNERCHANGERESULT.fields = {__PBTABLE__.ZHENRONGINNERCHANGERESULT_ID_FIELD, __PBTABLE__.ZHENRONGINNERCHANGERESULT_HEAD_FIELD, __PBTABLE__.ZHENRONGINNERCHANGERESULT_TYPE_FIELD, __PBTABLE__.ZHENRONGINNERCHANGERESULT_STATE_FIELD, __PBTABLE__.ZHENRONGINNERCHANGERESULT_FROMPOS_FIELD, __PBTABLE__.ZHENRONGINNERCHANGERESULT_TOPOS_FIELD}
ZHENRONGINNERCHANGERESULT.is_extendable = false
ZHENRONGINNERCHANGERESULT.extensions = {}

ZhenrongInnerChangeResult = protobuf.Message(ZHENRONGINNERCHANGERESULT)

