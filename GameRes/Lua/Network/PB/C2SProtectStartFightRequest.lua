-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf.protobuf"
local ProtocolId = require("Network.PB.ProtocolId")
local HeadMessage = require("Network.PB.HeadMessage")
local FightRecordMessage = require("Network.PB.FightRecordMessage")
module('Network.PB.C2SProtectStartFightRequest')


local __PBTABLE__ = {}

local PROTECTSTARTFIGHTREQUEST = protobuf.Descriptor();
_M.PROTECTSTARTFIGHTREQUEST = PROTECTSTARTFIGHTREQUEST

__PBTABLE__.PROTECTSTARTFIGHTREQUEST_ID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.PROTECTSTARTFIGHTREQUEST_HEAD_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.PROTECTSTARTFIGHTREQUEST_GATE_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.PROTECTSTARTFIGHTREQUEST_FIGHTRECORD_FIELD = protobuf.FieldDescriptor();

__PBTABLE__.PROTECTSTARTFIGHTREQUEST_ID_FIELD.name = "id"
__PBTABLE__.PROTECTSTARTFIGHTREQUEST_ID_FIELD.full_name = ".PB.ProtectStartFightRequest.id"
__PBTABLE__.PROTECTSTARTFIGHTREQUEST_ID_FIELD.number = 1
__PBTABLE__.PROTECTSTARTFIGHTREQUEST_ID_FIELD.index = 0
__PBTABLE__.PROTECTSTARTFIGHTREQUEST_ID_FIELD.label = 1
__PBTABLE__.PROTECTSTARTFIGHTREQUEST_ID_FIELD.has_default_value = true
__PBTABLE__.PROTECTSTARTFIGHTREQUEST_ID_FIELD.default_value = "ACT_PROTECT_PROTECT_START_FIGHT_REQUEST_MESSAGE"
__PBTABLE__.PROTECTSTARTFIGHTREQUEST_ID_FIELD.enum_type = PROTOCOLID or ProtocolId.PROTOCOLID
__PBTABLE__.PROTECTSTARTFIGHTREQUEST_ID_FIELD.type = 14
__PBTABLE__.PROTECTSTARTFIGHTREQUEST_ID_FIELD.cpp_type = 8

__PBTABLE__.PROTECTSTARTFIGHTREQUEST_HEAD_FIELD.name = "head"
__PBTABLE__.PROTECTSTARTFIGHTREQUEST_HEAD_FIELD.full_name = ".PB.ProtectStartFightRequest.head"
__PBTABLE__.PROTECTSTARTFIGHTREQUEST_HEAD_FIELD.number = 2
__PBTABLE__.PROTECTSTARTFIGHTREQUEST_HEAD_FIELD.index = 1
__PBTABLE__.PROTECTSTARTFIGHTREQUEST_HEAD_FIELD.label = 1
__PBTABLE__.PROTECTSTARTFIGHTREQUEST_HEAD_FIELD.has_default_value = false
__PBTABLE__.PROTECTSTARTFIGHTREQUEST_HEAD_FIELD.default_value = nil
__PBTABLE__.PROTECTSTARTFIGHTREQUEST_HEAD_FIELD.message_type = HEADMESSAGE or HeadMessage.HEADMESSAGE
__PBTABLE__.PROTECTSTARTFIGHTREQUEST_HEAD_FIELD.type = 11
__PBTABLE__.PROTECTSTARTFIGHTREQUEST_HEAD_FIELD.cpp_type = 10

__PBTABLE__.PROTECTSTARTFIGHTREQUEST_GATE_FIELD.name = "gate"
__PBTABLE__.PROTECTSTARTFIGHTREQUEST_GATE_FIELD.full_name = ".PB.ProtectStartFightRequest.gate"
__PBTABLE__.PROTECTSTARTFIGHTREQUEST_GATE_FIELD.number = 3
__PBTABLE__.PROTECTSTARTFIGHTREQUEST_GATE_FIELD.index = 2
__PBTABLE__.PROTECTSTARTFIGHTREQUEST_GATE_FIELD.label = 1
__PBTABLE__.PROTECTSTARTFIGHTREQUEST_GATE_FIELD.has_default_value = false
__PBTABLE__.PROTECTSTARTFIGHTREQUEST_GATE_FIELD.default_value = 0
__PBTABLE__.PROTECTSTARTFIGHTREQUEST_GATE_FIELD.type = 5
__PBTABLE__.PROTECTSTARTFIGHTREQUEST_GATE_FIELD.cpp_type = 1

__PBTABLE__.PROTECTSTARTFIGHTREQUEST_FIGHTRECORD_FIELD.name = "fightRecord"
__PBTABLE__.PROTECTSTARTFIGHTREQUEST_FIGHTRECORD_FIELD.full_name = ".PB.ProtectStartFightRequest.fightRecord"
__PBTABLE__.PROTECTSTARTFIGHTREQUEST_FIGHTRECORD_FIELD.number = 4
__PBTABLE__.PROTECTSTARTFIGHTREQUEST_FIGHTRECORD_FIELD.index = 3
__PBTABLE__.PROTECTSTARTFIGHTREQUEST_FIGHTRECORD_FIELD.label = 1
__PBTABLE__.PROTECTSTARTFIGHTREQUEST_FIGHTRECORD_FIELD.has_default_value = false
__PBTABLE__.PROTECTSTARTFIGHTREQUEST_FIGHTRECORD_FIELD.default_value = nil
__PBTABLE__.PROTECTSTARTFIGHTREQUEST_FIGHTRECORD_FIELD.message_type = FIGHTRECORDMESSAGE or FightRecordMessage.FIGHTRECORDMESSAGE
__PBTABLE__.PROTECTSTARTFIGHTREQUEST_FIGHTRECORD_FIELD.type = 11
__PBTABLE__.PROTECTSTARTFIGHTREQUEST_FIGHTRECORD_FIELD.cpp_type = 10

PROTECTSTARTFIGHTREQUEST.name = "ProtectStartFightRequest"
PROTECTSTARTFIGHTREQUEST.full_name = ".PB.ProtectStartFightRequest"
PROTECTSTARTFIGHTREQUEST.nested_types = {}
PROTECTSTARTFIGHTREQUEST.enum_types = {}
PROTECTSTARTFIGHTREQUEST.fields = {__PBTABLE__.PROTECTSTARTFIGHTREQUEST_ID_FIELD, __PBTABLE__.PROTECTSTARTFIGHTREQUEST_HEAD_FIELD, __PBTABLE__.PROTECTSTARTFIGHTREQUEST_GATE_FIELD, __PBTABLE__.PROTECTSTARTFIGHTREQUEST_FIGHTRECORD_FIELD}
PROTECTSTARTFIGHTREQUEST.is_extendable = false
PROTECTSTARTFIGHTREQUEST.extensions = {}

ProtectStartFightRequest = protobuf.Message(PROTECTSTARTFIGHTREQUEST)

