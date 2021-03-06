-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf.protobuf"
local ProtocolId = require("Network.PB.ProtocolId")
local HeadMessage = require("Network.PB.HeadMessage")
module('Network.PB.C2SStarQueryRequest')


local __PBTABLE__ = {}

local STARQUERYREQUESTMESSAGE = protobuf.Descriptor();
_M.STARQUERYREQUESTMESSAGE = STARQUERYREQUESTMESSAGE

__PBTABLE__.STARQUERYREQUESTMESSAGE_ID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.STARQUERYREQUESTMESSAGE_HEAD_FIELD = protobuf.FieldDescriptor();

__PBTABLE__.STARQUERYREQUESTMESSAGE_ID_FIELD.name = "id"
__PBTABLE__.STARQUERYREQUESTMESSAGE_ID_FIELD.full_name = ".PB.StarQueryRequestMessage.id"
__PBTABLE__.STARQUERYREQUESTMESSAGE_ID_FIELD.number = 1
__PBTABLE__.STARQUERYREQUESTMESSAGE_ID_FIELD.index = 0
__PBTABLE__.STARQUERYREQUESTMESSAGE_ID_FIELD.label = 1
__PBTABLE__.STARQUERYREQUESTMESSAGE_ID_FIELD.has_default_value = true
__PBTABLE__.STARQUERYREQUESTMESSAGE_ID_FIELD.default_value = "ACT_STAR_QUERY_REQUEST_MESSAGE"
__PBTABLE__.STARQUERYREQUESTMESSAGE_ID_FIELD.enum_type = PROTOCOLID or ProtocolId.PROTOCOLID
__PBTABLE__.STARQUERYREQUESTMESSAGE_ID_FIELD.type = 14
__PBTABLE__.STARQUERYREQUESTMESSAGE_ID_FIELD.cpp_type = 8

__PBTABLE__.STARQUERYREQUESTMESSAGE_HEAD_FIELD.name = "head"
__PBTABLE__.STARQUERYREQUESTMESSAGE_HEAD_FIELD.full_name = ".PB.StarQueryRequestMessage.head"
__PBTABLE__.STARQUERYREQUESTMESSAGE_HEAD_FIELD.number = 2
__PBTABLE__.STARQUERYREQUESTMESSAGE_HEAD_FIELD.index = 1
__PBTABLE__.STARQUERYREQUESTMESSAGE_HEAD_FIELD.label = 1
__PBTABLE__.STARQUERYREQUESTMESSAGE_HEAD_FIELD.has_default_value = false
__PBTABLE__.STARQUERYREQUESTMESSAGE_HEAD_FIELD.default_value = nil
__PBTABLE__.STARQUERYREQUESTMESSAGE_HEAD_FIELD.message_type = HEADMESSAGE or HeadMessage.HEADMESSAGE
__PBTABLE__.STARQUERYREQUESTMESSAGE_HEAD_FIELD.type = 11
__PBTABLE__.STARQUERYREQUESTMESSAGE_HEAD_FIELD.cpp_type = 10

STARQUERYREQUESTMESSAGE.name = "StarQueryRequestMessage"
STARQUERYREQUESTMESSAGE.full_name = ".PB.StarQueryRequestMessage"
STARQUERYREQUESTMESSAGE.nested_types = {}
STARQUERYREQUESTMESSAGE.enum_types = {}
STARQUERYREQUESTMESSAGE.fields = {__PBTABLE__.STARQUERYREQUESTMESSAGE_ID_FIELD, __PBTABLE__.STARQUERYREQUESTMESSAGE_HEAD_FIELD}
STARQUERYREQUESTMESSAGE.is_extendable = false
STARQUERYREQUESTMESSAGE.extensions = {}

StarQueryRequestMessage = protobuf.Message(STARQUERYREQUESTMESSAGE)

