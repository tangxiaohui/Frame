-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf.protobuf"
local ProtocolId = require("Network.PB.ProtocolId")
local HeadMessage = require("Network.PB.HeadMessage")
module('Network.PB.C2SZhenrongInnerChangeRequest')


local __PBTABLE__ = {}

local ZHENRONGINNERCHANGEREQUEST = protobuf.Descriptor();
_M.ZHENRONGINNERCHANGEREQUEST = ZHENRONGINNERCHANGEREQUEST

__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_ID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_HEAD_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_TYPE_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_FROMPOS_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_TOPOS_FIELD = protobuf.FieldDescriptor();

__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_ID_FIELD.name = "id"
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_ID_FIELD.full_name = ".PB.ZhenrongInnerChangeRequest.id"
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_ID_FIELD.number = 1
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_ID_FIELD.index = 0
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_ID_FIELD.label = 1
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_ID_FIELD.has_default_value = true
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_ID_FIELD.default_value = "ACT_ZHENRONG_ZHENRONG_INNER_CHANGE_REQUEST_MESSAGE"
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_ID_FIELD.enum_type = PROTOCOLID or ProtocolId.PROTOCOLID
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_ID_FIELD.type = 14
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_ID_FIELD.cpp_type = 8

__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_HEAD_FIELD.name = "head"
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_HEAD_FIELD.full_name = ".PB.ZhenrongInnerChangeRequest.head"
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_HEAD_FIELD.number = 2
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_HEAD_FIELD.index = 1
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_HEAD_FIELD.label = 1
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_HEAD_FIELD.has_default_value = false
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_HEAD_FIELD.default_value = nil
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_HEAD_FIELD.message_type = HEADMESSAGE or HeadMessage.HEADMESSAGE
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_HEAD_FIELD.type = 11
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_HEAD_FIELD.cpp_type = 10

__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_TYPE_FIELD.name = "type"
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_TYPE_FIELD.full_name = ".PB.ZhenrongInnerChangeRequest.type"
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_TYPE_FIELD.number = 3
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_TYPE_FIELD.index = 2
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_TYPE_FIELD.label = 1
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_TYPE_FIELD.has_default_value = false
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_TYPE_FIELD.default_value = 0
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_TYPE_FIELD.type = 5
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_TYPE_FIELD.cpp_type = 1

__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_FROMPOS_FIELD.name = "fromPos"
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_FROMPOS_FIELD.full_name = ".PB.ZhenrongInnerChangeRequest.fromPos"
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_FROMPOS_FIELD.number = 4
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_FROMPOS_FIELD.index = 3
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_FROMPOS_FIELD.label = 1
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_FROMPOS_FIELD.has_default_value = false
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_FROMPOS_FIELD.default_value = 0
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_FROMPOS_FIELD.type = 5
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_FROMPOS_FIELD.cpp_type = 1

__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_TOPOS_FIELD.name = "toPos"
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_TOPOS_FIELD.full_name = ".PB.ZhenrongInnerChangeRequest.toPos"
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_TOPOS_FIELD.number = 5
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_TOPOS_FIELD.index = 4
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_TOPOS_FIELD.label = 1
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_TOPOS_FIELD.has_default_value = false
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_TOPOS_FIELD.default_value = 0
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_TOPOS_FIELD.type = 5
__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_TOPOS_FIELD.cpp_type = 1

ZHENRONGINNERCHANGEREQUEST.name = "ZhenrongInnerChangeRequest"
ZHENRONGINNERCHANGEREQUEST.full_name = ".PB.ZhenrongInnerChangeRequest"
ZHENRONGINNERCHANGEREQUEST.nested_types = {}
ZHENRONGINNERCHANGEREQUEST.enum_types = {}
ZHENRONGINNERCHANGEREQUEST.fields = {__PBTABLE__.ZHENRONGINNERCHANGEREQUEST_ID_FIELD, __PBTABLE__.ZHENRONGINNERCHANGEREQUEST_HEAD_FIELD, __PBTABLE__.ZHENRONGINNERCHANGEREQUEST_TYPE_FIELD, __PBTABLE__.ZHENRONGINNERCHANGEREQUEST_FROMPOS_FIELD, __PBTABLE__.ZHENRONGINNERCHANGEREQUEST_TOPOS_FIELD}
ZHENRONGINNERCHANGEREQUEST.is_extendable = false
ZHENRONGINNERCHANGEREQUEST.extensions = {}

ZhenrongInnerChangeRequest = protobuf.Message(ZHENRONGINNERCHANGEREQUEST)

