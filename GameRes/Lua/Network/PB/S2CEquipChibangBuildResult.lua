-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf.protobuf"
local ProtocolId = require("Network.PB.ProtocolId")
local HeadMessage = require("Network.PB.HeadMessage")
module('Network.PB.S2CEquipChibangBuildResult')


local __PBTABLE__ = {}

local EQUIPCHIBANGBUILDRESULT = protobuf.Descriptor();
_M.EQUIPCHIBANGBUILDRESULT = EQUIPCHIBANGBUILDRESULT

__PBTABLE__.EQUIPCHIBANGBUILDRESULT_ID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.EQUIPCHIBANGBUILDRESULT_HEAD_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.EQUIPCHIBANGBUILDRESULT_CHIBANGID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.EQUIPCHIBANGBUILDRESULT_CARDUID_FIELD = protobuf.FieldDescriptor();

__PBTABLE__.EQUIPCHIBANGBUILDRESULT_ID_FIELD.name = "id"
__PBTABLE__.EQUIPCHIBANGBUILDRESULT_ID_FIELD.full_name = ".PB.EquipChibangBuildResult.id"
__PBTABLE__.EQUIPCHIBANGBUILDRESULT_ID_FIELD.number = 1
__PBTABLE__.EQUIPCHIBANGBUILDRESULT_ID_FIELD.index = 0
__PBTABLE__.EQUIPCHIBANGBUILDRESULT_ID_FIELD.label = 1
__PBTABLE__.EQUIPCHIBANGBUILDRESULT_ID_FIELD.has_default_value = true
__PBTABLE__.EQUIPCHIBANGBUILDRESULT_ID_FIELD.default_value = "SND_EQUIP_EQUIP_CHIBANG_BUILD_RESULT_MESSAGE"
__PBTABLE__.EQUIPCHIBANGBUILDRESULT_ID_FIELD.enum_type = PROTOCOLID or ProtocolId.PROTOCOLID
__PBTABLE__.EQUIPCHIBANGBUILDRESULT_ID_FIELD.type = 14
__PBTABLE__.EQUIPCHIBANGBUILDRESULT_ID_FIELD.cpp_type = 8

__PBTABLE__.EQUIPCHIBANGBUILDRESULT_HEAD_FIELD.name = "head"
__PBTABLE__.EQUIPCHIBANGBUILDRESULT_HEAD_FIELD.full_name = ".PB.EquipChibangBuildResult.head"
__PBTABLE__.EQUIPCHIBANGBUILDRESULT_HEAD_FIELD.number = 2
__PBTABLE__.EQUIPCHIBANGBUILDRESULT_HEAD_FIELD.index = 1
__PBTABLE__.EQUIPCHIBANGBUILDRESULT_HEAD_FIELD.label = 1
__PBTABLE__.EQUIPCHIBANGBUILDRESULT_HEAD_FIELD.has_default_value = false
__PBTABLE__.EQUIPCHIBANGBUILDRESULT_HEAD_FIELD.default_value = nil
__PBTABLE__.EQUIPCHIBANGBUILDRESULT_HEAD_FIELD.message_type = HEADMESSAGE or HeadMessage.HEADMESSAGE
__PBTABLE__.EQUIPCHIBANGBUILDRESULT_HEAD_FIELD.type = 11
__PBTABLE__.EQUIPCHIBANGBUILDRESULT_HEAD_FIELD.cpp_type = 10

__PBTABLE__.EQUIPCHIBANGBUILDRESULT_CHIBANGID_FIELD.name = "chibangID"
__PBTABLE__.EQUIPCHIBANGBUILDRESULT_CHIBANGID_FIELD.full_name = ".PB.EquipChibangBuildResult.chibangID"
__PBTABLE__.EQUIPCHIBANGBUILDRESULT_CHIBANGID_FIELD.number = 3
__PBTABLE__.EQUIPCHIBANGBUILDRESULT_CHIBANGID_FIELD.index = 2
__PBTABLE__.EQUIPCHIBANGBUILDRESULT_CHIBANGID_FIELD.label = 1
__PBTABLE__.EQUIPCHIBANGBUILDRESULT_CHIBANGID_FIELD.has_default_value = false
__PBTABLE__.EQUIPCHIBANGBUILDRESULT_CHIBANGID_FIELD.default_value = 0
__PBTABLE__.EQUIPCHIBANGBUILDRESULT_CHIBANGID_FIELD.type = 5
__PBTABLE__.EQUIPCHIBANGBUILDRESULT_CHIBANGID_FIELD.cpp_type = 1

__PBTABLE__.EQUIPCHIBANGBUILDRESULT_CARDUID_FIELD.name = "cardUID"
__PBTABLE__.EQUIPCHIBANGBUILDRESULT_CARDUID_FIELD.full_name = ".PB.EquipChibangBuildResult.cardUID"
__PBTABLE__.EQUIPCHIBANGBUILDRESULT_CARDUID_FIELD.number = 4
__PBTABLE__.EQUIPCHIBANGBUILDRESULT_CARDUID_FIELD.index = 3
__PBTABLE__.EQUIPCHIBANGBUILDRESULT_CARDUID_FIELD.label = 1
__PBTABLE__.EQUIPCHIBANGBUILDRESULT_CARDUID_FIELD.has_default_value = false
__PBTABLE__.EQUIPCHIBANGBUILDRESULT_CARDUID_FIELD.default_value = ""
__PBTABLE__.EQUIPCHIBANGBUILDRESULT_CARDUID_FIELD.type = 9
__PBTABLE__.EQUIPCHIBANGBUILDRESULT_CARDUID_FIELD.cpp_type = 9

EQUIPCHIBANGBUILDRESULT.name = "EquipChibangBuildResult"
EQUIPCHIBANGBUILDRESULT.full_name = ".PB.EquipChibangBuildResult"
EQUIPCHIBANGBUILDRESULT.nested_types = {}
EQUIPCHIBANGBUILDRESULT.enum_types = {}
EQUIPCHIBANGBUILDRESULT.fields = {__PBTABLE__.EQUIPCHIBANGBUILDRESULT_ID_FIELD, __PBTABLE__.EQUIPCHIBANGBUILDRESULT_HEAD_FIELD, __PBTABLE__.EQUIPCHIBANGBUILDRESULT_CHIBANGID_FIELD, __PBTABLE__.EQUIPCHIBANGBUILDRESULT_CARDUID_FIELD}
EQUIPCHIBANGBUILDRESULT.is_extendable = false
EQUIPCHIBANGBUILDRESULT.extensions = {}

EquipChibangBuildResult = protobuf.Message(EQUIPCHIBANGBUILDRESULT)
