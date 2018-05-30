-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf.protobuf"
local ProtocolId = require("Network.PB.ProtocolId")
local HeadMessage = require("Network.PB.HeadMessage")
module('Network.PB.C2SCardSuipianBuildRequest')


local __PBTABLE__ = {}

local CARDSUIPIANBUILDREQUEST = protobuf.Descriptor();
_M.CARDSUIPIANBUILDREQUEST = CARDSUIPIANBUILDREQUEST

__PBTABLE__.CARDSUIPIANBUILDREQUEST_ID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.CARDSUIPIANBUILDREQUEST_HEAD_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.CARDSUIPIANBUILDREQUEST_CARDSUIPIANID_FIELD = protobuf.FieldDescriptor();

__PBTABLE__.CARDSUIPIANBUILDREQUEST_ID_FIELD.name = "id"
__PBTABLE__.CARDSUIPIANBUILDREQUEST_ID_FIELD.full_name = ".PB.CardSuipianBuildRequest.id"
__PBTABLE__.CARDSUIPIANBUILDREQUEST_ID_FIELD.number = 1
__PBTABLE__.CARDSUIPIANBUILDREQUEST_ID_FIELD.index = 0
__PBTABLE__.CARDSUIPIANBUILDREQUEST_ID_FIELD.label = 1
__PBTABLE__.CARDSUIPIANBUILDREQUEST_ID_FIELD.has_default_value = true
__PBTABLE__.CARDSUIPIANBUILDREQUEST_ID_FIELD.default_value = "ACT_CARDPRO_CARD_SUIPIAN_BUILD_REQUEST_MESSAGE"
__PBTABLE__.CARDSUIPIANBUILDREQUEST_ID_FIELD.enum_type = PROTOCOLID or ProtocolId.PROTOCOLID
__PBTABLE__.CARDSUIPIANBUILDREQUEST_ID_FIELD.type = 14
__PBTABLE__.CARDSUIPIANBUILDREQUEST_ID_FIELD.cpp_type = 8

__PBTABLE__.CARDSUIPIANBUILDREQUEST_HEAD_FIELD.name = "head"
__PBTABLE__.CARDSUIPIANBUILDREQUEST_HEAD_FIELD.full_name = ".PB.CardSuipianBuildRequest.head"
__PBTABLE__.CARDSUIPIANBUILDREQUEST_HEAD_FIELD.number = 2
__PBTABLE__.CARDSUIPIANBUILDREQUEST_HEAD_FIELD.index = 1
__PBTABLE__.CARDSUIPIANBUILDREQUEST_HEAD_FIELD.label = 1
__PBTABLE__.CARDSUIPIANBUILDREQUEST_HEAD_FIELD.has_default_value = false
__PBTABLE__.CARDSUIPIANBUILDREQUEST_HEAD_FIELD.default_value = nil
__PBTABLE__.CARDSUIPIANBUILDREQUEST_HEAD_FIELD.message_type = HEADMESSAGE or HeadMessage.HEADMESSAGE
__PBTABLE__.CARDSUIPIANBUILDREQUEST_HEAD_FIELD.type = 11
__PBTABLE__.CARDSUIPIANBUILDREQUEST_HEAD_FIELD.cpp_type = 10

__PBTABLE__.CARDSUIPIANBUILDREQUEST_CARDSUIPIANID_FIELD.name = "cardSuipianID"
__PBTABLE__.CARDSUIPIANBUILDREQUEST_CARDSUIPIANID_FIELD.full_name = ".PB.CardSuipianBuildRequest.cardSuipianID"
__PBTABLE__.CARDSUIPIANBUILDREQUEST_CARDSUIPIANID_FIELD.number = 3
__PBTABLE__.CARDSUIPIANBUILDREQUEST_CARDSUIPIANID_FIELD.index = 2
__PBTABLE__.CARDSUIPIANBUILDREQUEST_CARDSUIPIANID_FIELD.label = 1
__PBTABLE__.CARDSUIPIANBUILDREQUEST_CARDSUIPIANID_FIELD.has_default_value = false
__PBTABLE__.CARDSUIPIANBUILDREQUEST_CARDSUIPIANID_FIELD.default_value = 0
__PBTABLE__.CARDSUIPIANBUILDREQUEST_CARDSUIPIANID_FIELD.type = 5
__PBTABLE__.CARDSUIPIANBUILDREQUEST_CARDSUIPIANID_FIELD.cpp_type = 1

CARDSUIPIANBUILDREQUEST.name = "CardSuipianBuildRequest"
CARDSUIPIANBUILDREQUEST.full_name = ".PB.CardSuipianBuildRequest"
CARDSUIPIANBUILDREQUEST.nested_types = {}
CARDSUIPIANBUILDREQUEST.enum_types = {}
CARDSUIPIANBUILDREQUEST.fields = {__PBTABLE__.CARDSUIPIANBUILDREQUEST_ID_FIELD, __PBTABLE__.CARDSUIPIANBUILDREQUEST_HEAD_FIELD, __PBTABLE__.CARDSUIPIANBUILDREQUEST_CARDSUIPIANID_FIELD}
CARDSUIPIANBUILDREQUEST.is_extendable = false
CARDSUIPIANBUILDREQUEST.extensions = {}

CardSuipianBuildRequest = protobuf.Message(CARDSUIPIANBUILDREQUEST)
