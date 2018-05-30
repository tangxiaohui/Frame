-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf.protobuf"
local ProtocolId = require("Network.PB.ProtocolId")
local HeadMessage = require("Network.PB.HeadMessage")
module('Network.PB.C2SGuideRedRequest')


local __PBTABLE__ = {}

local GUIDEREDREQUEST = protobuf.Descriptor();
_M.GUIDEREDREQUEST = GUIDEREDREQUEST

__PBTABLE__.GUIDEREDREQUEST_ID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.GUIDEREDREQUEST_HEAD_FIELD = protobuf.FieldDescriptor();

__PBTABLE__.GUIDEREDREQUEST_ID_FIELD.name = "id"
__PBTABLE__.GUIDEREDREQUEST_ID_FIELD.full_name = ".PB.GuideRedRequest.id"
__PBTABLE__.GUIDEREDREQUEST_ID_FIELD.number = 1
__PBTABLE__.GUIDEREDREQUEST_ID_FIELD.index = 0
__PBTABLE__.GUIDEREDREQUEST_ID_FIELD.label = 1
__PBTABLE__.GUIDEREDREQUEST_ID_FIELD.has_default_value = true
__PBTABLE__.GUIDEREDREQUEST_ID_FIELD.default_value = "ACT_GUIDE_GUIDE_RED_REQUEST_MESSAGE"
__PBTABLE__.GUIDEREDREQUEST_ID_FIELD.enum_type = PROTOCOLID or ProtocolId.PROTOCOLID
__PBTABLE__.GUIDEREDREQUEST_ID_FIELD.type = 14
__PBTABLE__.GUIDEREDREQUEST_ID_FIELD.cpp_type = 8

__PBTABLE__.GUIDEREDREQUEST_HEAD_FIELD.name = "head"
__PBTABLE__.GUIDEREDREQUEST_HEAD_FIELD.full_name = ".PB.GuideRedRequest.head"
__PBTABLE__.GUIDEREDREQUEST_HEAD_FIELD.number = 2
__PBTABLE__.GUIDEREDREQUEST_HEAD_FIELD.index = 1
__PBTABLE__.GUIDEREDREQUEST_HEAD_FIELD.label = 1
__PBTABLE__.GUIDEREDREQUEST_HEAD_FIELD.has_default_value = false
__PBTABLE__.GUIDEREDREQUEST_HEAD_FIELD.default_value = nil
__PBTABLE__.GUIDEREDREQUEST_HEAD_FIELD.message_type = HEADMESSAGE or HeadMessage.HEADMESSAGE
__PBTABLE__.GUIDEREDREQUEST_HEAD_FIELD.type = 11
__PBTABLE__.GUIDEREDREQUEST_HEAD_FIELD.cpp_type = 10

GUIDEREDREQUEST.name = "GuideRedRequest"
GUIDEREDREQUEST.full_name = ".PB.GuideRedRequest"
GUIDEREDREQUEST.nested_types = {}
GUIDEREDREQUEST.enum_types = {}
GUIDEREDREQUEST.fields = {__PBTABLE__.GUIDEREDREQUEST_ID_FIELD, __PBTABLE__.GUIDEREDREQUEST_HEAD_FIELD}
GUIDEREDREQUEST.is_extendable = false
GUIDEREDREQUEST.extensions = {}

GuideRedRequest = protobuf.Message(GUIDEREDREQUEST)
