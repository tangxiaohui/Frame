-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf.protobuf"
local ProtocolId = require("Network.PB.ProtocolId")
local HeadMessage = require("Network.PB.HeadMessage")
module('Network.PB.S2CGHQuitResult')


local __PBTABLE__ = {}

local GHQUITRESULT = protobuf.Descriptor();
_M.GHQUITRESULT = GHQUITRESULT

__PBTABLE__.GHQUITRESULT_ID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.GHQUITRESULT_HEAD_FIELD = protobuf.FieldDescriptor();

__PBTABLE__.GHQUITRESULT_ID_FIELD.name = "id"
__PBTABLE__.GHQUITRESULT_ID_FIELD.full_name = ".PB.GHQuitResult.id"
__PBTABLE__.GHQUITRESULT_ID_FIELD.number = 1
__PBTABLE__.GHQUITRESULT_ID_FIELD.index = 0
__PBTABLE__.GHQUITRESULT_ID_FIELD.label = 1
__PBTABLE__.GHQUITRESULT_ID_FIELD.has_default_value = true
__PBTABLE__.GHQUITRESULT_ID_FIELD.default_value = "SND_GONGHUI_G_H_QUIT_RESULT_MESSAGE"
__PBTABLE__.GHQUITRESULT_ID_FIELD.enum_type = PROTOCOLID or ProtocolId.PROTOCOLID
__PBTABLE__.GHQUITRESULT_ID_FIELD.type = 14
__PBTABLE__.GHQUITRESULT_ID_FIELD.cpp_type = 8

__PBTABLE__.GHQUITRESULT_HEAD_FIELD.name = "head"
__PBTABLE__.GHQUITRESULT_HEAD_FIELD.full_name = ".PB.GHQuitResult.head"
__PBTABLE__.GHQUITRESULT_HEAD_FIELD.number = 2
__PBTABLE__.GHQUITRESULT_HEAD_FIELD.index = 1
__PBTABLE__.GHQUITRESULT_HEAD_FIELD.label = 1
__PBTABLE__.GHQUITRESULT_HEAD_FIELD.has_default_value = false
__PBTABLE__.GHQUITRESULT_HEAD_FIELD.default_value = nil
__PBTABLE__.GHQUITRESULT_HEAD_FIELD.message_type = HEADMESSAGE or HeadMessage.HEADMESSAGE
__PBTABLE__.GHQUITRESULT_HEAD_FIELD.type = 11
__PBTABLE__.GHQUITRESULT_HEAD_FIELD.cpp_type = 10

GHQUITRESULT.name = "GHQuitResult"
GHQUITRESULT.full_name = ".PB.GHQuitResult"
GHQUITRESULT.nested_types = {}
GHQUITRESULT.enum_types = {}
GHQUITRESULT.fields = {__PBTABLE__.GHQUITRESULT_ID_FIELD, __PBTABLE__.GHQUITRESULT_HEAD_FIELD}
GHQUITRESULT.is_extendable = false
GHQUITRESULT.extensions = {}

GHQuitResult = protobuf.Message(GHQUITRESULT)
