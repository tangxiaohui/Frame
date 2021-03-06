-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf.protobuf"
local ProtocolId = require("Network.PB.ProtocolId")
local WorldBossData = require("Network.PB.WorldBossData")
module('Network.PB.S2CWBossListResult')


local __PBTABLE__ = {}

local HEADMESSAGE = protobuf.Descriptor();
_M.HEADMESSAGE = HEADMESSAGE

__PBTABLE__.HEADMESSAGE_SID_FIELD = protobuf.FieldDescriptor();
local WBOSSLISTRESULTMESSAGE = protobuf.Descriptor();
_M.WBOSSLISTRESULTMESSAGE = WBOSSLISTRESULTMESSAGE

__PBTABLE__.WBOSSLISTRESULTMESSAGE_ID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.WBOSSLISTRESULTMESSAGE_HEAD_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.WBOSSLISTRESULTMESSAGE_WORLDBOSSDATA_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.WBOSSLISTRESULTMESSAGE_CHALLENGETIMES_FIELD = protobuf.FieldDescriptor();

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
__PBTABLE__.WBOSSLISTRESULTMESSAGE_ID_FIELD.name = "id"
__PBTABLE__.WBOSSLISTRESULTMESSAGE_ID_FIELD.full_name = ".PB.WBossListResultMessage.id"
__PBTABLE__.WBOSSLISTRESULTMESSAGE_ID_FIELD.number = 1
__PBTABLE__.WBOSSLISTRESULTMESSAGE_ID_FIELD.index = 0
__PBTABLE__.WBOSSLISTRESULTMESSAGE_ID_FIELD.label = 1
__PBTABLE__.WBOSSLISTRESULTMESSAGE_ID_FIELD.has_default_value = true
__PBTABLE__.WBOSSLISTRESULTMESSAGE_ID_FIELD.default_value = "SND_WORLD_BOSS_LIST_RESULT_MESSAGE"
__PBTABLE__.WBOSSLISTRESULTMESSAGE_ID_FIELD.enum_type = PROTOCOLID or ProtocolId.PROTOCOLID
__PBTABLE__.WBOSSLISTRESULTMESSAGE_ID_FIELD.type = 14
__PBTABLE__.WBOSSLISTRESULTMESSAGE_ID_FIELD.cpp_type = 8

__PBTABLE__.WBOSSLISTRESULTMESSAGE_HEAD_FIELD.name = "head"
__PBTABLE__.WBOSSLISTRESULTMESSAGE_HEAD_FIELD.full_name = ".PB.WBossListResultMessage.head"
__PBTABLE__.WBOSSLISTRESULTMESSAGE_HEAD_FIELD.number = 2
__PBTABLE__.WBOSSLISTRESULTMESSAGE_HEAD_FIELD.index = 1
__PBTABLE__.WBOSSLISTRESULTMESSAGE_HEAD_FIELD.label = 1
__PBTABLE__.WBOSSLISTRESULTMESSAGE_HEAD_FIELD.has_default_value = false
__PBTABLE__.WBOSSLISTRESULTMESSAGE_HEAD_FIELD.default_value = nil
__PBTABLE__.WBOSSLISTRESULTMESSAGE_HEAD_FIELD.message_type = HEADMESSAGE or HeadMessage.HEADMESSAGE
__PBTABLE__.WBOSSLISTRESULTMESSAGE_HEAD_FIELD.type = 11
__PBTABLE__.WBOSSLISTRESULTMESSAGE_HEAD_FIELD.cpp_type = 10

__PBTABLE__.WBOSSLISTRESULTMESSAGE_WORLDBOSSDATA_FIELD.name = "worldBossData"
__PBTABLE__.WBOSSLISTRESULTMESSAGE_WORLDBOSSDATA_FIELD.full_name = ".PB.WBossListResultMessage.worldBossData"
__PBTABLE__.WBOSSLISTRESULTMESSAGE_WORLDBOSSDATA_FIELD.number = 3
__PBTABLE__.WBOSSLISTRESULTMESSAGE_WORLDBOSSDATA_FIELD.index = 2
__PBTABLE__.WBOSSLISTRESULTMESSAGE_WORLDBOSSDATA_FIELD.label = 3
__PBTABLE__.WBOSSLISTRESULTMESSAGE_WORLDBOSSDATA_FIELD.has_default_value = false
__PBTABLE__.WBOSSLISTRESULTMESSAGE_WORLDBOSSDATA_FIELD.default_value = {}
__PBTABLE__.WBOSSLISTRESULTMESSAGE_WORLDBOSSDATA_FIELD.message_type = WORLDBOSSDATA or WorldBossData.WORLDBOSSDATA
__PBTABLE__.WBOSSLISTRESULTMESSAGE_WORLDBOSSDATA_FIELD.type = 11
__PBTABLE__.WBOSSLISTRESULTMESSAGE_WORLDBOSSDATA_FIELD.cpp_type = 10

__PBTABLE__.WBOSSLISTRESULTMESSAGE_CHALLENGETIMES_FIELD.name = "challengeTimes"
__PBTABLE__.WBOSSLISTRESULTMESSAGE_CHALLENGETIMES_FIELD.full_name = ".PB.WBossListResultMessage.challengeTimes"
__PBTABLE__.WBOSSLISTRESULTMESSAGE_CHALLENGETIMES_FIELD.number = 4
__PBTABLE__.WBOSSLISTRESULTMESSAGE_CHALLENGETIMES_FIELD.index = 3
__PBTABLE__.WBOSSLISTRESULTMESSAGE_CHALLENGETIMES_FIELD.label = 1
__PBTABLE__.WBOSSLISTRESULTMESSAGE_CHALLENGETIMES_FIELD.has_default_value = false
__PBTABLE__.WBOSSLISTRESULTMESSAGE_CHALLENGETIMES_FIELD.default_value = 0
__PBTABLE__.WBOSSLISTRESULTMESSAGE_CHALLENGETIMES_FIELD.type = 5
__PBTABLE__.WBOSSLISTRESULTMESSAGE_CHALLENGETIMES_FIELD.cpp_type = 1

WBOSSLISTRESULTMESSAGE.name = "WBossListResultMessage"
WBOSSLISTRESULTMESSAGE.full_name = ".PB.WBossListResultMessage"
WBOSSLISTRESULTMESSAGE.nested_types = {}
WBOSSLISTRESULTMESSAGE.enum_types = {}
WBOSSLISTRESULTMESSAGE.fields = {__PBTABLE__.WBOSSLISTRESULTMESSAGE_ID_FIELD, __PBTABLE__.WBOSSLISTRESULTMESSAGE_HEAD_FIELD, __PBTABLE__.WBOSSLISTRESULTMESSAGE_WORLDBOSSDATA_FIELD, __PBTABLE__.WBOSSLISTRESULTMESSAGE_CHALLENGETIMES_FIELD}
WBOSSLISTRESULTMESSAGE.is_extendable = false
WBOSSLISTRESULTMESSAGE.extensions = {}

HeadMessage = protobuf.Message(HEADMESSAGE)
WBossListResultMessage = protobuf.Message(WBOSSLISTRESULTMESSAGE)

