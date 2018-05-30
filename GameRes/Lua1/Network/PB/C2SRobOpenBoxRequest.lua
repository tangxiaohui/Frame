-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf.protobuf"
local ProtocolId = require("Network.PB.ProtocolId")
local HeadMessage = require("Network.PB.HeadMessage")
module('Network.PB.C2SRobOpenBoxRequest')


local __PBTABLE__ = {}

local ROBOPENBOXREQUEST = protobuf.Descriptor();
_M.ROBOPENBOXREQUEST = ROBOPENBOXREQUEST

__PBTABLE__.ROBOPENBOXREQUEST_ID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ROBOPENBOXREQUEST_HEAD_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ROBOPENBOXREQUEST_REPAIRBOXUID_FIELD = protobuf.FieldDescriptor();

__PBTABLE__.ROBOPENBOXREQUEST_ID_FIELD.name = "id"
__PBTABLE__.ROBOPENBOXREQUEST_ID_FIELD.full_name = ".PB.RobOpenBoxRequest.id"
__PBTABLE__.ROBOPENBOXREQUEST_ID_FIELD.number = 1
__PBTABLE__.ROBOPENBOXREQUEST_ID_FIELD.index = 0
__PBTABLE__.ROBOPENBOXREQUEST_ID_FIELD.label = 1
__PBTABLE__.ROBOPENBOXREQUEST_ID_FIELD.has_default_value = true
__PBTABLE__.ROBOPENBOXREQUEST_ID_FIELD.default_value = "ACT_ROB_ROB_OPEN_BOX_REQUEST_MESSAGE"
__PBTABLE__.ROBOPENBOXREQUEST_ID_FIELD.enum_type = PROTOCOLID or ProtocolId.PROTOCOLID
__PBTABLE__.ROBOPENBOXREQUEST_ID_FIELD.type = 14
__PBTABLE__.ROBOPENBOXREQUEST_ID_FIELD.cpp_type = 8

__PBTABLE__.ROBOPENBOXREQUEST_HEAD_FIELD.name = "head"
__PBTABLE__.ROBOPENBOXREQUEST_HEAD_FIELD.full_name = ".PB.RobOpenBoxRequest.head"
__PBTABLE__.ROBOPENBOXREQUEST_HEAD_FIELD.number = 2
__PBTABLE__.ROBOPENBOXREQUEST_HEAD_FIELD.index = 1
__PBTABLE__.ROBOPENBOXREQUEST_HEAD_FIELD.label = 1
__PBTABLE__.ROBOPENBOXREQUEST_HEAD_FIELD.has_default_value = false
__PBTABLE__.ROBOPENBOXREQUEST_HEAD_FIELD.default_value = nil
__PBTABLE__.ROBOPENBOXREQUEST_HEAD_FIELD.message_type = HEADMESSAGE or HeadMessage.HEADMESSAGE
__PBTABLE__.ROBOPENBOXREQUEST_HEAD_FIELD.type = 11
__PBTABLE__.ROBOPENBOXREQUEST_HEAD_FIELD.cpp_type = 10

__PBTABLE__.ROBOPENBOXREQUEST_REPAIRBOXUID_FIELD.name = "repairBoxUID"
__PBTABLE__.ROBOPENBOXREQUEST_REPAIRBOXUID_FIELD.full_name = ".PB.RobOpenBoxRequest.repairBoxUID"
__PBTABLE__.ROBOPENBOXREQUEST_REPAIRBOXUID_FIELD.number = 3
__PBTABLE__.ROBOPENBOXREQUEST_REPAIRBOXUID_FIELD.index = 2
__PBTABLE__.ROBOPENBOXREQUEST_REPAIRBOXUID_FIELD.label = 1
__PBTABLE__.ROBOPENBOXREQUEST_REPAIRBOXUID_FIELD.has_default_value = false
__PBTABLE__.ROBOPENBOXREQUEST_REPAIRBOXUID_FIELD.default_value = ""
__PBTABLE__.ROBOPENBOXREQUEST_REPAIRBOXUID_FIELD.type = 9
__PBTABLE__.ROBOPENBOXREQUEST_REPAIRBOXUID_FIELD.cpp_type = 9

ROBOPENBOXREQUEST.name = "RobOpenBoxRequest"
ROBOPENBOXREQUEST.full_name = ".PB.RobOpenBoxRequest"
ROBOPENBOXREQUEST.nested_types = {}
ROBOPENBOXREQUEST.enum_types = {}
ROBOPENBOXREQUEST.fields = {__PBTABLE__.ROBOPENBOXREQUEST_ID_FIELD, __PBTABLE__.ROBOPENBOXREQUEST_HEAD_FIELD, __PBTABLE__.ROBOPENBOXREQUEST_REPAIRBOXUID_FIELD}
ROBOPENBOXREQUEST.is_extendable = false
ROBOPENBOXREQUEST.extensions = {}

RobOpenBoxRequest = protobuf.Message(ROBOPENBOXREQUEST)
