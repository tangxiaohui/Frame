-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf.protobuf"
local ProtocolId = require("Network.PB.ProtocolId")
local HeadMessage = require("Network.PB.HeadMessage")
module('Network.PB.C2SGodChooseTenRequest')


local __PBTABLE__ = {}

local GODCHOOSETENREQUEST = protobuf.Descriptor();
_M.GODCHOOSETENREQUEST = GODCHOOSETENREQUEST

__PBTABLE__.GODCHOOSETENREQUEST_ID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.GODCHOOSETENREQUEST_HEAD_FIELD = protobuf.FieldDescriptor();

__PBTABLE__.GODCHOOSETENREQUEST_ID_FIELD.name = "id"
__PBTABLE__.GODCHOOSETENREQUEST_ID_FIELD.full_name = ".PB.GodChooseTenRequest.id"
__PBTABLE__.GODCHOOSETENREQUEST_ID_FIELD.number = 1
__PBTABLE__.GODCHOOSETENREQUEST_ID_FIELD.index = 0
__PBTABLE__.GODCHOOSETENREQUEST_ID_FIELD.label = 1
__PBTABLE__.GODCHOOSETENREQUEST_ID_FIELD.has_default_value = true
__PBTABLE__.GODCHOOSETENREQUEST_ID_FIELD.default_value = "ACT_HUODONG_GOD_TEN_CHOOSE_REQUEST_MESSAGE"
__PBTABLE__.GODCHOOSETENREQUEST_ID_FIELD.enum_type = PROTOCOLID or ProtocolId.PROTOCOLID
__PBTABLE__.GODCHOOSETENREQUEST_ID_FIELD.type = 14
__PBTABLE__.GODCHOOSETENREQUEST_ID_FIELD.cpp_type = 8

__PBTABLE__.GODCHOOSETENREQUEST_HEAD_FIELD.name = "head"
__PBTABLE__.GODCHOOSETENREQUEST_HEAD_FIELD.full_name = ".PB.GodChooseTenRequest.head"
__PBTABLE__.GODCHOOSETENREQUEST_HEAD_FIELD.number = 2
__PBTABLE__.GODCHOOSETENREQUEST_HEAD_FIELD.index = 1
__PBTABLE__.GODCHOOSETENREQUEST_HEAD_FIELD.label = 1
__PBTABLE__.GODCHOOSETENREQUEST_HEAD_FIELD.has_default_value = false
__PBTABLE__.GODCHOOSETENREQUEST_HEAD_FIELD.default_value = nil
__PBTABLE__.GODCHOOSETENREQUEST_HEAD_FIELD.message_type = HEADMESSAGE or HeadMessage.HEADMESSAGE
__PBTABLE__.GODCHOOSETENREQUEST_HEAD_FIELD.type = 11
__PBTABLE__.GODCHOOSETENREQUEST_HEAD_FIELD.cpp_type = 10

GODCHOOSETENREQUEST.name = "GodChooseTenRequest"
GODCHOOSETENREQUEST.full_name = ".PB.GodChooseTenRequest"
GODCHOOSETENREQUEST.nested_types = {}
GODCHOOSETENREQUEST.enum_types = {}
GODCHOOSETENREQUEST.fields = {__PBTABLE__.GODCHOOSETENREQUEST_ID_FIELD, __PBTABLE__.GODCHOOSETENREQUEST_HEAD_FIELD}
GODCHOOSETENREQUEST.is_extendable = false
GODCHOOSETENREQUEST.extensions = {}

GodChooseTenRequest = protobuf.Message(GODCHOOSETENREQUEST)

