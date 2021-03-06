-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf.protobuf"
local ProtocolId = require("Network.PB.ProtocolId")
local HeadMessage = require("Network.PB.HeadMessage")
module('Network.PB.S2CCardSuipianBuildResult')


local __PBTABLE__ = {}

local CARDSUIPIANBUILDRESULT = protobuf.Descriptor();
_M.CARDSUIPIANBUILDRESULT = CARDSUIPIANBUILDRESULT

__PBTABLE__.CARDSUIPIANBUILDRESULT_ID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.CARDSUIPIANBUILDRESULT_HEAD_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.CARDSUIPIANBUILDRESULT_CARDSUIPIANID_FIELD = protobuf.FieldDescriptor();

__PBTABLE__.CARDSUIPIANBUILDRESULT_ID_FIELD.name = "id"
__PBTABLE__.CARDSUIPIANBUILDRESULT_ID_FIELD.full_name = ".PB.CardSuipianBuildResult.id"
__PBTABLE__.CARDSUIPIANBUILDRESULT_ID_FIELD.number = 1
__PBTABLE__.CARDSUIPIANBUILDRESULT_ID_FIELD.index = 0
__PBTABLE__.CARDSUIPIANBUILDRESULT_ID_FIELD.label = 1
__PBTABLE__.CARDSUIPIANBUILDRESULT_ID_FIELD.has_default_value = true
__PBTABLE__.CARDSUIPIANBUILDRESULT_ID_FIELD.default_value = "SND_CARDPRO_CARD_SUIPIAN_BUILD_RESULT_MESSAGE"
__PBTABLE__.CARDSUIPIANBUILDRESULT_ID_FIELD.enum_type = PROTOCOLID or ProtocolId.PROTOCOLID
__PBTABLE__.CARDSUIPIANBUILDRESULT_ID_FIELD.type = 14
__PBTABLE__.CARDSUIPIANBUILDRESULT_ID_FIELD.cpp_type = 8

__PBTABLE__.CARDSUIPIANBUILDRESULT_HEAD_FIELD.name = "head"
__PBTABLE__.CARDSUIPIANBUILDRESULT_HEAD_FIELD.full_name = ".PB.CardSuipianBuildResult.head"
__PBTABLE__.CARDSUIPIANBUILDRESULT_HEAD_FIELD.number = 2
__PBTABLE__.CARDSUIPIANBUILDRESULT_HEAD_FIELD.index = 1
__PBTABLE__.CARDSUIPIANBUILDRESULT_HEAD_FIELD.label = 1
__PBTABLE__.CARDSUIPIANBUILDRESULT_HEAD_FIELD.has_default_value = false
__PBTABLE__.CARDSUIPIANBUILDRESULT_HEAD_FIELD.default_value = nil
__PBTABLE__.CARDSUIPIANBUILDRESULT_HEAD_FIELD.message_type = HEADMESSAGE or HeadMessage.HEADMESSAGE
__PBTABLE__.CARDSUIPIANBUILDRESULT_HEAD_FIELD.type = 11
__PBTABLE__.CARDSUIPIANBUILDRESULT_HEAD_FIELD.cpp_type = 10

__PBTABLE__.CARDSUIPIANBUILDRESULT_CARDSUIPIANID_FIELD.name = "cardSuipianID"
__PBTABLE__.CARDSUIPIANBUILDRESULT_CARDSUIPIANID_FIELD.full_name = ".PB.CardSuipianBuildResult.cardSuipianID"
__PBTABLE__.CARDSUIPIANBUILDRESULT_CARDSUIPIANID_FIELD.number = 3
__PBTABLE__.CARDSUIPIANBUILDRESULT_CARDSUIPIANID_FIELD.index = 2
__PBTABLE__.CARDSUIPIANBUILDRESULT_CARDSUIPIANID_FIELD.label = 1
__PBTABLE__.CARDSUIPIANBUILDRESULT_CARDSUIPIANID_FIELD.has_default_value = false
__PBTABLE__.CARDSUIPIANBUILDRESULT_CARDSUIPIANID_FIELD.default_value = 0
__PBTABLE__.CARDSUIPIANBUILDRESULT_CARDSUIPIANID_FIELD.type = 5
__PBTABLE__.CARDSUIPIANBUILDRESULT_CARDSUIPIANID_FIELD.cpp_type = 1

CARDSUIPIANBUILDRESULT.name = "CardSuipianBuildResult"
CARDSUIPIANBUILDRESULT.full_name = ".PB.CardSuipianBuildResult"
CARDSUIPIANBUILDRESULT.nested_types = {}
CARDSUIPIANBUILDRESULT.enum_types = {}
CARDSUIPIANBUILDRESULT.fields = {__PBTABLE__.CARDSUIPIANBUILDRESULT_ID_FIELD, __PBTABLE__.CARDSUIPIANBUILDRESULT_HEAD_FIELD, __PBTABLE__.CARDSUIPIANBUILDRESULT_CARDSUIPIANID_FIELD}
CARDSUIPIANBUILDRESULT.is_extendable = false
CARDSUIPIANBUILDRESULT.extensions = {}

CardSuipianBuildResult = protobuf.Message(CARDSUIPIANBUILDRESULT)

