-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf.protobuf"
local ProtocolId = require("Network.PB.ProtocolId")
module('Network.PB.S2CChangePlayerNameResult')


local __PBTABLE__ = {}

local HEADMESSAGE = protobuf.Descriptor();
_M.HEADMESSAGE = HEADMESSAGE

__PBTABLE__.HEADMESSAGE_SID_FIELD = protobuf.FieldDescriptor();
local CHANGEPLAYERNAMERESULT = protobuf.Descriptor();
_M.CHANGEPLAYERNAMERESULT = CHANGEPLAYERNAMERESULT

__PBTABLE__.CHANGEPLAYERNAMERESULT_ID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.CHANGEPLAYERNAMERESULT_HEAD_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.CHANGEPLAYERNAMERESULT_NEWNAME_FIELD = protobuf.FieldDescriptor();

__PBTABLE__.HEADMESSAGE_SID_FIELD.name = "sid"
__PBTABLE__.HEADMESSAGE_SID_FIELD.full_name = ".PB.HeadMessage.sid"
__PBTABLE__.HEADMESSAGE_SID_FIELD.number = 1
__PBTABLE__.HEADMESSAGE_SID_FIELD.index = 0
__PBTABLE__.HEADMESSAGE_SID_FIELD.label = 1
__PBTABLE__.HEADMESSAGE_SID_FIELD.has_default_value = false
__PBTABLE__.HEADMESSAGE_SID_FIELD.default_value = 0
__PBTABLE__.HEADMESSAGE_SID_FIELD.type = 5
__PBTABLE__.HEADMESSAGE_SID_FIELD.cpp_type = 1

HEADMESSAGE.name = "HeadMessage"
HEADMESSAGE.full_name = ".PB.HeadMessage"
HEADMESSAGE.nested_types = {}
HEADMESSAGE.enum_types = {}
HEADMESSAGE.fields = {__PBTABLE__.HEADMESSAGE_SID_FIELD}
HEADMESSAGE.is_extendable = false
HEADMESSAGE.extensions = {}
__PBTABLE__.CHANGEPLAYERNAMERESULT_ID_FIELD.name = "id"
__PBTABLE__.CHANGEPLAYERNAMERESULT_ID_FIELD.full_name = ".PB.ChangePlayerNameResult.id"
__PBTABLE__.CHANGEPLAYERNAMERESULT_ID_FIELD.number = 1
__PBTABLE__.CHANGEPLAYERNAMERESULT_ID_FIELD.index = 0
__PBTABLE__.CHANGEPLAYERNAMERESULT_ID_FIELD.label = 1
__PBTABLE__.CHANGEPLAYERNAMERESULT_ID_FIELD.has_default_value = true
__PBTABLE__.CHANGEPLAYERNAMERESULT_ID_FIELD.default_value = "SND_ACCOUNT_CHANGE_PLAYER_NAME_RESULT_MESSAGE"
__PBTABLE__.CHANGEPLAYERNAMERESULT_ID_FIELD.enum_type = PROTOCOLID or ProtocolId.PROTOCOLID
__PBTABLE__.CHANGEPLAYERNAMERESULT_ID_FIELD.type = 14
__PBTABLE__.CHANGEPLAYERNAMERESULT_ID_FIELD.cpp_type = 8

__PBTABLE__.CHANGEPLAYERNAMERESULT_HEAD_FIELD.name = "head"
__PBTABLE__.CHANGEPLAYERNAMERESULT_HEAD_FIELD.full_name = ".PB.ChangePlayerNameResult.head"
__PBTABLE__.CHANGEPLAYERNAMERESULT_HEAD_FIELD.number = 2
__PBTABLE__.CHANGEPLAYERNAMERESULT_HEAD_FIELD.index = 1
__PBTABLE__.CHANGEPLAYERNAMERESULT_HEAD_FIELD.label = 1
__PBTABLE__.CHANGEPLAYERNAMERESULT_HEAD_FIELD.has_default_value = false
__PBTABLE__.CHANGEPLAYERNAMERESULT_HEAD_FIELD.default_value = nil
__PBTABLE__.CHANGEPLAYERNAMERESULT_HEAD_FIELD.message_type = HEADMESSAGE or HeadMessage.HEADMESSAGE
__PBTABLE__.CHANGEPLAYERNAMERESULT_HEAD_FIELD.type = 11
__PBTABLE__.CHANGEPLAYERNAMERESULT_HEAD_FIELD.cpp_type = 10

__PBTABLE__.CHANGEPLAYERNAMERESULT_NEWNAME_FIELD.name = "newName"
__PBTABLE__.CHANGEPLAYERNAMERESULT_NEWNAME_FIELD.full_name = ".PB.ChangePlayerNameResult.newName"
__PBTABLE__.CHANGEPLAYERNAMERESULT_NEWNAME_FIELD.number = 3
__PBTABLE__.CHANGEPLAYERNAMERESULT_NEWNAME_FIELD.index = 2
__PBTABLE__.CHANGEPLAYERNAMERESULT_NEWNAME_FIELD.label = 1
__PBTABLE__.CHANGEPLAYERNAMERESULT_NEWNAME_FIELD.has_default_value = false
__PBTABLE__.CHANGEPLAYERNAMERESULT_NEWNAME_FIELD.default_value = ""
__PBTABLE__.CHANGEPLAYERNAMERESULT_NEWNAME_FIELD.type = 9
__PBTABLE__.CHANGEPLAYERNAMERESULT_NEWNAME_FIELD.cpp_type = 9

CHANGEPLAYERNAMERESULT.name = "ChangePlayerNameResult"
CHANGEPLAYERNAMERESULT.full_name = ".PB.ChangePlayerNameResult"
CHANGEPLAYERNAMERESULT.nested_types = {}
CHANGEPLAYERNAMERESULT.enum_types = {}
CHANGEPLAYERNAMERESULT.fields = {__PBTABLE__.CHANGEPLAYERNAMERESULT_ID_FIELD, __PBTABLE__.CHANGEPLAYERNAMERESULT_HEAD_FIELD, __PBTABLE__.CHANGEPLAYERNAMERESULT_NEWNAME_FIELD}
CHANGEPLAYERNAMERESULT.is_extendable = false
CHANGEPLAYERNAMERESULT.extensions = {}

ChangePlayerNameResult = protobuf.Message(CHANGEPLAYERNAMERESULT)
HeadMessage = protobuf.Message(HEADMESSAGE)
