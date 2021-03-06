-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf.protobuf"
local ProtocolId = require("Network.PB.ProtocolId")
local HeadMessage = require("Network.PB.HeadMessage")
module('Network.PB.S2CEquipPutOffResult')


local __PBTABLE__ = {}

local EQUIPPUTOFFRESULT = protobuf.Descriptor();
_M.EQUIPPUTOFFRESULT = EQUIPPUTOFFRESULT

__PBTABLE__.EQUIPPUTOFFRESULT_ID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.EQUIPPUTOFFRESULT_HEAD_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.EQUIPPUTOFFRESULT_CARDUID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.EQUIPPUTOFFRESULT_EQUIPUID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.EQUIPPUTOFFRESULT_STATE_FIELD = protobuf.FieldDescriptor();

__PBTABLE__.EQUIPPUTOFFRESULT_ID_FIELD.name = "id"
__PBTABLE__.EQUIPPUTOFFRESULT_ID_FIELD.full_name = ".PB.EquipPutOffResult.id"
__PBTABLE__.EQUIPPUTOFFRESULT_ID_FIELD.number = 1
__PBTABLE__.EQUIPPUTOFFRESULT_ID_FIELD.index = 0
__PBTABLE__.EQUIPPUTOFFRESULT_ID_FIELD.label = 1
__PBTABLE__.EQUIPPUTOFFRESULT_ID_FIELD.has_default_value = true
__PBTABLE__.EQUIPPUTOFFRESULT_ID_FIELD.default_value = "SND_EQUIP_EQUIP_PUT_OFF_RESULT_MESSAGE"
__PBTABLE__.EQUIPPUTOFFRESULT_ID_FIELD.enum_type = PROTOCOLID or ProtocolId.PROTOCOLID
__PBTABLE__.EQUIPPUTOFFRESULT_ID_FIELD.type = 14
__PBTABLE__.EQUIPPUTOFFRESULT_ID_FIELD.cpp_type = 8

__PBTABLE__.EQUIPPUTOFFRESULT_HEAD_FIELD.name = "head"
__PBTABLE__.EQUIPPUTOFFRESULT_HEAD_FIELD.full_name = ".PB.EquipPutOffResult.head"
__PBTABLE__.EQUIPPUTOFFRESULT_HEAD_FIELD.number = 2
__PBTABLE__.EQUIPPUTOFFRESULT_HEAD_FIELD.index = 1
__PBTABLE__.EQUIPPUTOFFRESULT_HEAD_FIELD.label = 1
__PBTABLE__.EQUIPPUTOFFRESULT_HEAD_FIELD.has_default_value = false
__PBTABLE__.EQUIPPUTOFFRESULT_HEAD_FIELD.default_value = nil
__PBTABLE__.EQUIPPUTOFFRESULT_HEAD_FIELD.message_type = HEADMESSAGE or HeadMessage.HEADMESSAGE
__PBTABLE__.EQUIPPUTOFFRESULT_HEAD_FIELD.type = 11
__PBTABLE__.EQUIPPUTOFFRESULT_HEAD_FIELD.cpp_type = 10

__PBTABLE__.EQUIPPUTOFFRESULT_CARDUID_FIELD.name = "cardUID"
__PBTABLE__.EQUIPPUTOFFRESULT_CARDUID_FIELD.full_name = ".PB.EquipPutOffResult.cardUID"
__PBTABLE__.EQUIPPUTOFFRESULT_CARDUID_FIELD.number = 3
__PBTABLE__.EQUIPPUTOFFRESULT_CARDUID_FIELD.index = 2
__PBTABLE__.EQUIPPUTOFFRESULT_CARDUID_FIELD.label = 1
__PBTABLE__.EQUIPPUTOFFRESULT_CARDUID_FIELD.has_default_value = false
__PBTABLE__.EQUIPPUTOFFRESULT_CARDUID_FIELD.default_value = ""
__PBTABLE__.EQUIPPUTOFFRESULT_CARDUID_FIELD.type = 9
__PBTABLE__.EQUIPPUTOFFRESULT_CARDUID_FIELD.cpp_type = 9

__PBTABLE__.EQUIPPUTOFFRESULT_EQUIPUID_FIELD.name = "equipUID"
__PBTABLE__.EQUIPPUTOFFRESULT_EQUIPUID_FIELD.full_name = ".PB.EquipPutOffResult.equipUID"
__PBTABLE__.EQUIPPUTOFFRESULT_EQUIPUID_FIELD.number = 4
__PBTABLE__.EQUIPPUTOFFRESULT_EQUIPUID_FIELD.index = 3
__PBTABLE__.EQUIPPUTOFFRESULT_EQUIPUID_FIELD.label = 1
__PBTABLE__.EQUIPPUTOFFRESULT_EQUIPUID_FIELD.has_default_value = false
__PBTABLE__.EQUIPPUTOFFRESULT_EQUIPUID_FIELD.default_value = ""
__PBTABLE__.EQUIPPUTOFFRESULT_EQUIPUID_FIELD.type = 9
__PBTABLE__.EQUIPPUTOFFRESULT_EQUIPUID_FIELD.cpp_type = 9

__PBTABLE__.EQUIPPUTOFFRESULT_STATE_FIELD.name = "state"
__PBTABLE__.EQUIPPUTOFFRESULT_STATE_FIELD.full_name = ".PB.EquipPutOffResult.state"
__PBTABLE__.EQUIPPUTOFFRESULT_STATE_FIELD.number = 5
__PBTABLE__.EQUIPPUTOFFRESULT_STATE_FIELD.index = 4
__PBTABLE__.EQUIPPUTOFFRESULT_STATE_FIELD.label = 1
__PBTABLE__.EQUIPPUTOFFRESULT_STATE_FIELD.has_default_value = false
__PBTABLE__.EQUIPPUTOFFRESULT_STATE_FIELD.default_value = 0
__PBTABLE__.EQUIPPUTOFFRESULT_STATE_FIELD.type = 5
__PBTABLE__.EQUIPPUTOFFRESULT_STATE_FIELD.cpp_type = 1

EQUIPPUTOFFRESULT.name = "EquipPutOffResult"
EQUIPPUTOFFRESULT.full_name = ".PB.EquipPutOffResult"
EQUIPPUTOFFRESULT.nested_types = {}
EQUIPPUTOFFRESULT.enum_types = {}
EQUIPPUTOFFRESULT.fields = {__PBTABLE__.EQUIPPUTOFFRESULT_ID_FIELD, __PBTABLE__.EQUIPPUTOFFRESULT_HEAD_FIELD, __PBTABLE__.EQUIPPUTOFFRESULT_CARDUID_FIELD, __PBTABLE__.EQUIPPUTOFFRESULT_EQUIPUID_FIELD, __PBTABLE__.EQUIPPUTOFFRESULT_STATE_FIELD}
EQUIPPUTOFFRESULT.is_extendable = false
EQUIPPUTOFFRESULT.extensions = {}

EquipPutOffResult = protobuf.Message(EQUIPPUTOFFRESULT)

