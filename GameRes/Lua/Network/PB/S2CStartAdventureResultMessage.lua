-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf.protobuf"
local ProtocolId = require("Network.PB.ProtocolId")
local HeadMessage = require("Network.PB.HeadMessage")
module('Network.PB.S2CStartAdventureResultMessage')


local __PBTABLE__ = {}

local STARTADVENTURERESULTMESSAGE = protobuf.Descriptor();
_M.STARTADVENTURERESULTMESSAGE = STARTADVENTURERESULTMESSAGE

__PBTABLE__.STARTADVENTURERESULTMESSAGE_ID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.STARTADVENTURERESULTMESSAGE_HEAD_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.STARTADVENTURERESULTMESSAGE_CHALLENGENUM_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.STARTADVENTURERESULTMESSAGE_RECOVERYTIME_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.STARTADVENTURERESULTMESSAGE_BUYTIMES_FIELD = protobuf.FieldDescriptor();

__PBTABLE__.STARTADVENTURERESULTMESSAGE_ID_FIELD.name = "id"
__PBTABLE__.STARTADVENTURERESULTMESSAGE_ID_FIELD.full_name = ".PB.StartAdventureResultMessage.id"
__PBTABLE__.STARTADVENTURERESULTMESSAGE_ID_FIELD.number = 1
__PBTABLE__.STARTADVENTURERESULTMESSAGE_ID_FIELD.index = 0
__PBTABLE__.STARTADVENTURERESULTMESSAGE_ID_FIELD.label = 1
__PBTABLE__.STARTADVENTURERESULTMESSAGE_ID_FIELD.has_default_value = true
__PBTABLE__.STARTADVENTURERESULTMESSAGE_ID_FIELD.default_value = "SND_ADVENTURE_START_RESULT_MESSAGE"
__PBTABLE__.STARTADVENTURERESULTMESSAGE_ID_FIELD.enum_type = PROTOCOLID or ProtocolId.PROTOCOLID
__PBTABLE__.STARTADVENTURERESULTMESSAGE_ID_FIELD.type = 14
__PBTABLE__.STARTADVENTURERESULTMESSAGE_ID_FIELD.cpp_type = 8

__PBTABLE__.STARTADVENTURERESULTMESSAGE_HEAD_FIELD.name = "head"
__PBTABLE__.STARTADVENTURERESULTMESSAGE_HEAD_FIELD.full_name = ".PB.StartAdventureResultMessage.head"
__PBTABLE__.STARTADVENTURERESULTMESSAGE_HEAD_FIELD.number = 2
__PBTABLE__.STARTADVENTURERESULTMESSAGE_HEAD_FIELD.index = 1
__PBTABLE__.STARTADVENTURERESULTMESSAGE_HEAD_FIELD.label = 1
__PBTABLE__.STARTADVENTURERESULTMESSAGE_HEAD_FIELD.has_default_value = false
__PBTABLE__.STARTADVENTURERESULTMESSAGE_HEAD_FIELD.default_value = nil
__PBTABLE__.STARTADVENTURERESULTMESSAGE_HEAD_FIELD.message_type = HEADMESSAGE or HeadMessage.HEADMESSAGE
__PBTABLE__.STARTADVENTURERESULTMESSAGE_HEAD_FIELD.type = 11
__PBTABLE__.STARTADVENTURERESULTMESSAGE_HEAD_FIELD.cpp_type = 10

__PBTABLE__.STARTADVENTURERESULTMESSAGE_CHALLENGENUM_FIELD.name = "challengeNum"
__PBTABLE__.STARTADVENTURERESULTMESSAGE_CHALLENGENUM_FIELD.full_name = ".PB.StartAdventureResultMessage.challengeNum"
__PBTABLE__.STARTADVENTURERESULTMESSAGE_CHALLENGENUM_FIELD.number = 3
__PBTABLE__.STARTADVENTURERESULTMESSAGE_CHALLENGENUM_FIELD.index = 2
__PBTABLE__.STARTADVENTURERESULTMESSAGE_CHALLENGENUM_FIELD.label = 1
__PBTABLE__.STARTADVENTURERESULTMESSAGE_CHALLENGENUM_FIELD.has_default_value = false
__PBTABLE__.STARTADVENTURERESULTMESSAGE_CHALLENGENUM_FIELD.default_value = 0
__PBTABLE__.STARTADVENTURERESULTMESSAGE_CHALLENGENUM_FIELD.type = 5
__PBTABLE__.STARTADVENTURERESULTMESSAGE_CHALLENGENUM_FIELD.cpp_type = 1

__PBTABLE__.STARTADVENTURERESULTMESSAGE_RECOVERYTIME_FIELD.name = "recoveryTime"
__PBTABLE__.STARTADVENTURERESULTMESSAGE_RECOVERYTIME_FIELD.full_name = ".PB.StartAdventureResultMessage.recoveryTime"
__PBTABLE__.STARTADVENTURERESULTMESSAGE_RECOVERYTIME_FIELD.number = 4
__PBTABLE__.STARTADVENTURERESULTMESSAGE_RECOVERYTIME_FIELD.index = 3
__PBTABLE__.STARTADVENTURERESULTMESSAGE_RECOVERYTIME_FIELD.label = 1
__PBTABLE__.STARTADVENTURERESULTMESSAGE_RECOVERYTIME_FIELD.has_default_value = false
__PBTABLE__.STARTADVENTURERESULTMESSAGE_RECOVERYTIME_FIELD.default_value = 0
__PBTABLE__.STARTADVENTURERESULTMESSAGE_RECOVERYTIME_FIELD.type = 3
__PBTABLE__.STARTADVENTURERESULTMESSAGE_RECOVERYTIME_FIELD.cpp_type = 2

__PBTABLE__.STARTADVENTURERESULTMESSAGE_BUYTIMES_FIELD.name = "buyTimes"
__PBTABLE__.STARTADVENTURERESULTMESSAGE_BUYTIMES_FIELD.full_name = ".PB.StartAdventureResultMessage.buyTimes"
__PBTABLE__.STARTADVENTURERESULTMESSAGE_BUYTIMES_FIELD.number = 5
__PBTABLE__.STARTADVENTURERESULTMESSAGE_BUYTIMES_FIELD.index = 4
__PBTABLE__.STARTADVENTURERESULTMESSAGE_BUYTIMES_FIELD.label = 1
__PBTABLE__.STARTADVENTURERESULTMESSAGE_BUYTIMES_FIELD.has_default_value = false
__PBTABLE__.STARTADVENTURERESULTMESSAGE_BUYTIMES_FIELD.default_value = 0
__PBTABLE__.STARTADVENTURERESULTMESSAGE_BUYTIMES_FIELD.type = 5
__PBTABLE__.STARTADVENTURERESULTMESSAGE_BUYTIMES_FIELD.cpp_type = 1

STARTADVENTURERESULTMESSAGE.name = "StartAdventureResultMessage"
STARTADVENTURERESULTMESSAGE.full_name = ".PB.StartAdventureResultMessage"
STARTADVENTURERESULTMESSAGE.nested_types = {}
STARTADVENTURERESULTMESSAGE.enum_types = {}
STARTADVENTURERESULTMESSAGE.fields = {__PBTABLE__.STARTADVENTURERESULTMESSAGE_ID_FIELD, __PBTABLE__.STARTADVENTURERESULTMESSAGE_HEAD_FIELD, __PBTABLE__.STARTADVENTURERESULTMESSAGE_CHALLENGENUM_FIELD, __PBTABLE__.STARTADVENTURERESULTMESSAGE_RECOVERYTIME_FIELD, __PBTABLE__.STARTADVENTURERESULTMESSAGE_BUYTIMES_FIELD}
STARTADVENTURERESULTMESSAGE.is_extendable = false
STARTADVENTURERESULTMESSAGE.extensions = {}

StartAdventureResultMessage = protobuf.Message(STARTADVENTURERESULTMESSAGE)
