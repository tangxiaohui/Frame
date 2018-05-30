-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf.protobuf"
local ProtocolId = require("Network.PB.ProtocolId")
local HeadMessage = require("Network.PB.HeadMessage")
module('Network.PB.S2CCardSkinBagQueryResult')


local __PBTABLE__ = {}

local CARDSKINITEM = protobuf.Descriptor();
_M.CARDSKINITEM = CARDSKINITEM

__PBTABLE__.CARDSKINITEM_CARDSKINID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.CARDSKINITEM_CARDSKINLEVEL_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.CARDSKINITEM_CARDSKINEXP_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.CARDSKINITEM_CARDSKINUID_FIELD = protobuf.FieldDescriptor();
local CARDITEM = protobuf.Descriptor();
_M.CARDITEM = CARDITEM

__PBTABLE__.CARDITEM_CARDID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.CARDITEM_CURRSKINID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.CARDITEM_CARDSKIN_FIELD = protobuf.FieldDescriptor();
local CARDSKINBAGQUERYRESULTMESSAGE = protobuf.Descriptor();
_M.CARDSKINBAGQUERYRESULTMESSAGE = CARDSKINBAGQUERYRESULTMESSAGE

__PBTABLE__.CARDSKINBAGQUERYRESULTMESSAGE_ID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.CARDSKINBAGQUERYRESULTMESSAGE_HEAD_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.CARDSKINBAGQUERYRESULTMESSAGE_CARDS_FIELD = protobuf.FieldDescriptor();

__PBTABLE__.CARDSKINITEM_CARDSKINID_FIELD.name = "cardSkinId"
__PBTABLE__.CARDSKINITEM_CARDSKINID_FIELD.full_name = ".PB.CardSkinItem.cardSkinId"
__PBTABLE__.CARDSKINITEM_CARDSKINID_FIELD.number = 1
__PBTABLE__.CARDSKINITEM_CARDSKINID_FIELD.index = 0
__PBTABLE__.CARDSKINITEM_CARDSKINID_FIELD.label = 1
__PBTABLE__.CARDSKINITEM_CARDSKINID_FIELD.has_default_value = false
__PBTABLE__.CARDSKINITEM_CARDSKINID_FIELD.default_value = 0
__PBTABLE__.CARDSKINITEM_CARDSKINID_FIELD.type = 5
__PBTABLE__.CARDSKINITEM_CARDSKINID_FIELD.cpp_type = 1

__PBTABLE__.CARDSKINITEM_CARDSKINLEVEL_FIELD.name = "cardSkinLevel"
__PBTABLE__.CARDSKINITEM_CARDSKINLEVEL_FIELD.full_name = ".PB.CardSkinItem.cardSkinLevel"
__PBTABLE__.CARDSKINITEM_CARDSKINLEVEL_FIELD.number = 2
__PBTABLE__.CARDSKINITEM_CARDSKINLEVEL_FIELD.index = 1
__PBTABLE__.CARDSKINITEM_CARDSKINLEVEL_FIELD.label = 1
__PBTABLE__.CARDSKINITEM_CARDSKINLEVEL_FIELD.has_default_value = false
__PBTABLE__.CARDSKINITEM_CARDSKINLEVEL_FIELD.default_value = 0
__PBTABLE__.CARDSKINITEM_CARDSKINLEVEL_FIELD.type = 5
__PBTABLE__.CARDSKINITEM_CARDSKINLEVEL_FIELD.cpp_type = 1

__PBTABLE__.CARDSKINITEM_CARDSKINEXP_FIELD.name = "cardSkinExp"
__PBTABLE__.CARDSKINITEM_CARDSKINEXP_FIELD.full_name = ".PB.CardSkinItem.cardSkinExp"
__PBTABLE__.CARDSKINITEM_CARDSKINEXP_FIELD.number = 3
__PBTABLE__.CARDSKINITEM_CARDSKINEXP_FIELD.index = 2
__PBTABLE__.CARDSKINITEM_CARDSKINEXP_FIELD.label = 1
__PBTABLE__.CARDSKINITEM_CARDSKINEXP_FIELD.has_default_value = false
__PBTABLE__.CARDSKINITEM_CARDSKINEXP_FIELD.default_value = 0
__PBTABLE__.CARDSKINITEM_CARDSKINEXP_FIELD.type = 5
__PBTABLE__.CARDSKINITEM_CARDSKINEXP_FIELD.cpp_type = 1

__PBTABLE__.CARDSKINITEM_CARDSKINUID_FIELD.name = "cardSkinUID"
__PBTABLE__.CARDSKINITEM_CARDSKINUID_FIELD.full_name = ".PB.CardSkinItem.cardSkinUID"
__PBTABLE__.CARDSKINITEM_CARDSKINUID_FIELD.number = 4
__PBTABLE__.CARDSKINITEM_CARDSKINUID_FIELD.index = 3
__PBTABLE__.CARDSKINITEM_CARDSKINUID_FIELD.label = 1
__PBTABLE__.CARDSKINITEM_CARDSKINUID_FIELD.has_default_value = false
__PBTABLE__.CARDSKINITEM_CARDSKINUID_FIELD.default_value = ""
__PBTABLE__.CARDSKINITEM_CARDSKINUID_FIELD.type = 9
__PBTABLE__.CARDSKINITEM_CARDSKINUID_FIELD.cpp_type = 9

CARDSKINITEM.name = "CardSkinItem"
CARDSKINITEM.full_name = ".PB.CardSkinItem"
CARDSKINITEM.nested_types = {}
CARDSKINITEM.enum_types = {}
CARDSKINITEM.fields = {__PBTABLE__.CARDSKINITEM_CARDSKINID_FIELD, __PBTABLE__.CARDSKINITEM_CARDSKINLEVEL_FIELD, __PBTABLE__.CARDSKINITEM_CARDSKINEXP_FIELD, __PBTABLE__.CARDSKINITEM_CARDSKINUID_FIELD}
CARDSKINITEM.is_extendable = false
CARDSKINITEM.extensions = {}
__PBTABLE__.CARDITEM_CARDID_FIELD.name = "cardId"
__PBTABLE__.CARDITEM_CARDID_FIELD.full_name = ".PB.CardItem.cardId"
__PBTABLE__.CARDITEM_CARDID_FIELD.number = 1
__PBTABLE__.CARDITEM_CARDID_FIELD.index = 0
__PBTABLE__.CARDITEM_CARDID_FIELD.label = 1
__PBTABLE__.CARDITEM_CARDID_FIELD.has_default_value = false
__PBTABLE__.CARDITEM_CARDID_FIELD.default_value = 0
__PBTABLE__.CARDITEM_CARDID_FIELD.type = 5
__PBTABLE__.CARDITEM_CARDID_FIELD.cpp_type = 1

__PBTABLE__.CARDITEM_CURRSKINID_FIELD.name = "currSkinId"
__PBTABLE__.CARDITEM_CURRSKINID_FIELD.full_name = ".PB.CardItem.currSkinId"
__PBTABLE__.CARDITEM_CURRSKINID_FIELD.number = 2
__PBTABLE__.CARDITEM_CURRSKINID_FIELD.index = 1
__PBTABLE__.CARDITEM_CURRSKINID_FIELD.label = 1
__PBTABLE__.CARDITEM_CURRSKINID_FIELD.has_default_value = false
__PBTABLE__.CARDITEM_CURRSKINID_FIELD.default_value = 0
__PBTABLE__.CARDITEM_CURRSKINID_FIELD.type = 5
__PBTABLE__.CARDITEM_CURRSKINID_FIELD.cpp_type = 1

__PBTABLE__.CARDITEM_CARDSKIN_FIELD.name = "cardSkin"
__PBTABLE__.CARDITEM_CARDSKIN_FIELD.full_name = ".PB.CardItem.cardSkin"
__PBTABLE__.CARDITEM_CARDSKIN_FIELD.number = 3
__PBTABLE__.CARDITEM_CARDSKIN_FIELD.index = 2
__PBTABLE__.CARDITEM_CARDSKIN_FIELD.label = 3
__PBTABLE__.CARDITEM_CARDSKIN_FIELD.has_default_value = false
__PBTABLE__.CARDITEM_CARDSKIN_FIELD.default_value = {}
__PBTABLE__.CARDITEM_CARDSKIN_FIELD.message_type = CARDSKINITEM or CardSkinItem.CARDSKINITEM
__PBTABLE__.CARDITEM_CARDSKIN_FIELD.type = 11
__PBTABLE__.CARDITEM_CARDSKIN_FIELD.cpp_type = 10

CARDITEM.name = "CardItem"
CARDITEM.full_name = ".PB.CardItem"
CARDITEM.nested_types = {}
CARDITEM.enum_types = {}
CARDITEM.fields = {__PBTABLE__.CARDITEM_CARDID_FIELD, __PBTABLE__.CARDITEM_CURRSKINID_FIELD, __PBTABLE__.CARDITEM_CARDSKIN_FIELD}
CARDITEM.is_extendable = false
CARDITEM.extensions = {}
__PBTABLE__.CARDSKINBAGQUERYRESULTMESSAGE_ID_FIELD.name = "id"
__PBTABLE__.CARDSKINBAGQUERYRESULTMESSAGE_ID_FIELD.full_name = ".PB.CardSkinBagQueryResultMessage.id"
__PBTABLE__.CARDSKINBAGQUERYRESULTMESSAGE_ID_FIELD.number = 1
__PBTABLE__.CARDSKINBAGQUERYRESULTMESSAGE_ID_FIELD.index = 0
__PBTABLE__.CARDSKINBAGQUERYRESULTMESSAGE_ID_FIELD.label = 1
__PBTABLE__.CARDSKINBAGQUERYRESULTMESSAGE_ID_FIELD.has_default_value = true
__PBTABLE__.CARDSKINBAGQUERYRESULTMESSAGE_ID_FIELD.default_value = "SND_CARDPRO_CARD_SKIN_BAG_QUERY_RESULT_MESSAGE"
__PBTABLE__.CARDSKINBAGQUERYRESULTMESSAGE_ID_FIELD.enum_type = PROTOCOLID or ProtocolId.PROTOCOLID
__PBTABLE__.CARDSKINBAGQUERYRESULTMESSAGE_ID_FIELD.type = 14
__PBTABLE__.CARDSKINBAGQUERYRESULTMESSAGE_ID_FIELD.cpp_type = 8

__PBTABLE__.CARDSKINBAGQUERYRESULTMESSAGE_HEAD_FIELD.name = "head"
__PBTABLE__.CARDSKINBAGQUERYRESULTMESSAGE_HEAD_FIELD.full_name = ".PB.CardSkinBagQueryResultMessage.head"
__PBTABLE__.CARDSKINBAGQUERYRESULTMESSAGE_HEAD_FIELD.number = 2
__PBTABLE__.CARDSKINBAGQUERYRESULTMESSAGE_HEAD_FIELD.index = 1
__PBTABLE__.CARDSKINBAGQUERYRESULTMESSAGE_HEAD_FIELD.label = 1
__PBTABLE__.CARDSKINBAGQUERYRESULTMESSAGE_HEAD_FIELD.has_default_value = false
__PBTABLE__.CARDSKINBAGQUERYRESULTMESSAGE_HEAD_FIELD.default_value = nil
__PBTABLE__.CARDSKINBAGQUERYRESULTMESSAGE_HEAD_FIELD.message_type = HEADMESSAGE or HeadMessage.HEADMESSAGE
__PBTABLE__.CARDSKINBAGQUERYRESULTMESSAGE_HEAD_FIELD.type = 11
__PBTABLE__.CARDSKINBAGQUERYRESULTMESSAGE_HEAD_FIELD.cpp_type = 10

__PBTABLE__.CARDSKINBAGQUERYRESULTMESSAGE_CARDS_FIELD.name = "cards"
__PBTABLE__.CARDSKINBAGQUERYRESULTMESSAGE_CARDS_FIELD.full_name = ".PB.CardSkinBagQueryResultMessage.cards"
__PBTABLE__.CARDSKINBAGQUERYRESULTMESSAGE_CARDS_FIELD.number = 3
__PBTABLE__.CARDSKINBAGQUERYRESULTMESSAGE_CARDS_FIELD.index = 2
__PBTABLE__.CARDSKINBAGQUERYRESULTMESSAGE_CARDS_FIELD.label = 3
__PBTABLE__.CARDSKINBAGQUERYRESULTMESSAGE_CARDS_FIELD.has_default_value = false
__PBTABLE__.CARDSKINBAGQUERYRESULTMESSAGE_CARDS_FIELD.default_value = {}
__PBTABLE__.CARDSKINBAGQUERYRESULTMESSAGE_CARDS_FIELD.message_type = CARDITEM or CardItem.CARDITEM
__PBTABLE__.CARDSKINBAGQUERYRESULTMESSAGE_CARDS_FIELD.type = 11
__PBTABLE__.CARDSKINBAGQUERYRESULTMESSAGE_CARDS_FIELD.cpp_type = 10

CARDSKINBAGQUERYRESULTMESSAGE.name = "CardSkinBagQueryResultMessage"
CARDSKINBAGQUERYRESULTMESSAGE.full_name = ".PB.CardSkinBagQueryResultMessage"
CARDSKINBAGQUERYRESULTMESSAGE.nested_types = {}
CARDSKINBAGQUERYRESULTMESSAGE.enum_types = {}
CARDSKINBAGQUERYRESULTMESSAGE.fields = {__PBTABLE__.CARDSKINBAGQUERYRESULTMESSAGE_ID_FIELD, __PBTABLE__.CARDSKINBAGQUERYRESULTMESSAGE_HEAD_FIELD, __PBTABLE__.CARDSKINBAGQUERYRESULTMESSAGE_CARDS_FIELD}
CARDSKINBAGQUERYRESULTMESSAGE.is_extendable = false
CARDSKINBAGQUERYRESULTMESSAGE.extensions = {}

CardItem = protobuf.Message(CARDITEM)
CardSkinBagQueryResultMessage = protobuf.Message(CARDSKINBAGQUERYRESULTMESSAGE)
CardSkinItem = protobuf.Message(CARDSKINITEM)
