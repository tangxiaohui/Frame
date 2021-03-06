-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf.protobuf"
local ProtocolId = require("Network.PB.ProtocolId")
local HeadMessage = require("Network.PB.HeadMessage")
module('Network.PB.S2CGuideDoneResult')


local __PBTABLE__ = {}

local GUIDEDONERESULT = protobuf.Descriptor();
_M.GUIDEDONERESULT = GUIDEDONERESULT

__PBTABLE__.GUIDEDONERESULT_ID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.GUIDEDONERESULT_HEAD_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.GUIDEDONERESULT_STEP_FIELD = protobuf.FieldDescriptor();

__PBTABLE__.GUIDEDONERESULT_ID_FIELD.name = "id"
__PBTABLE__.GUIDEDONERESULT_ID_FIELD.full_name = ".PB.GuideDoneResult.id"
__PBTABLE__.GUIDEDONERESULT_ID_FIELD.number = 1
__PBTABLE__.GUIDEDONERESULT_ID_FIELD.index = 0
__PBTABLE__.GUIDEDONERESULT_ID_FIELD.label = 1
__PBTABLE__.GUIDEDONERESULT_ID_FIELD.has_default_value = true
__PBTABLE__.GUIDEDONERESULT_ID_FIELD.default_value = "SND_GUIDE_GUIDE_DONE_RESULT_MESSAGE"
__PBTABLE__.GUIDEDONERESULT_ID_FIELD.enum_type = PROTOCOLID or ProtocolId.PROTOCOLID
__PBTABLE__.GUIDEDONERESULT_ID_FIELD.type = 14
__PBTABLE__.GUIDEDONERESULT_ID_FIELD.cpp_type = 8

__PBTABLE__.GUIDEDONERESULT_HEAD_FIELD.name = "head"
__PBTABLE__.GUIDEDONERESULT_HEAD_FIELD.full_name = ".PB.GuideDoneResult.head"
__PBTABLE__.GUIDEDONERESULT_HEAD_FIELD.number = 2
__PBTABLE__.GUIDEDONERESULT_HEAD_FIELD.index = 1
__PBTABLE__.GUIDEDONERESULT_HEAD_FIELD.label = 1
__PBTABLE__.GUIDEDONERESULT_HEAD_FIELD.has_default_value = false
__PBTABLE__.GUIDEDONERESULT_HEAD_FIELD.default_value = nil
__PBTABLE__.GUIDEDONERESULT_HEAD_FIELD.message_type = HEADMESSAGE or HeadMessage.HEADMESSAGE
__PBTABLE__.GUIDEDONERESULT_HEAD_FIELD.type = 11
__PBTABLE__.GUIDEDONERESULT_HEAD_FIELD.cpp_type = 10

__PBTABLE__.GUIDEDONERESULT_STEP_FIELD.name = "step"
__PBTABLE__.GUIDEDONERESULT_STEP_FIELD.full_name = ".PB.GuideDoneResult.step"
__PBTABLE__.GUIDEDONERESULT_STEP_FIELD.number = 3
__PBTABLE__.GUIDEDONERESULT_STEP_FIELD.index = 2
__PBTABLE__.GUIDEDONERESULT_STEP_FIELD.label = 1
__PBTABLE__.GUIDEDONERESULT_STEP_FIELD.has_default_value = false
__PBTABLE__.GUIDEDONERESULT_STEP_FIELD.default_value = 0
__PBTABLE__.GUIDEDONERESULT_STEP_FIELD.type = 5
__PBTABLE__.GUIDEDONERESULT_STEP_FIELD.cpp_type = 1

GUIDEDONERESULT.name = "GuideDoneResult"
GUIDEDONERESULT.full_name = ".PB.GuideDoneResult"
GUIDEDONERESULT.nested_types = {}
GUIDEDONERESULT.enum_types = {}
GUIDEDONERESULT.fields = {__PBTABLE__.GUIDEDONERESULT_ID_FIELD, __PBTABLE__.GUIDEDONERESULT_HEAD_FIELD, __PBTABLE__.GUIDEDONERESULT_STEP_FIELD}
GUIDEDONERESULT.is_extendable = false
GUIDEDONERESULT.extensions = {}

GuideDoneResult = protobuf.Message(GUIDEDONERESULT)

