-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf.protobuf"
local ProtocolId = require("Network.PB.ProtocolId")
local HeadMessage = require("Network.PB.HeadMessage")
module('Network.PB.S2CCardSuipianFlush')


local __PBTABLE__ = {}

__PBTABLE__.CARDBAG_OPT_MOD = protobuf.EnumDescriptor();
_M.CARDBAG_OPT_MOD = __PBTABLE__.CARDBAG_OPT_MOD

__PBTABLE__.CARDBAG_OPT_MOD_ADD_ENUM = protobuf.EnumValueDescriptor();
__PBTABLE__.CARDBAG_OPT_MOD_DEL_ENUM = protobuf.EnumValueDescriptor();
__PBTABLE__.CARDBAG_OPT_MOD_UPDATE_ENUM = protobuf.EnumValueDescriptor();
__PBTABLE__.CARDBAG_OPT_MOD_SHIZHUANGDEL_ENUM = protobuf.EnumValueDescriptor();
__PBTABLE__.CARDBAG_OPT_MOD_SHIZHUANGADD_ENUM = protobuf.EnumValueDescriptor();
local ONECARDSUIPIANITEM = protobuf.Descriptor();
_M.ONECARDSUIPIANITEM = ONECARDSUIPIANITEM

__PBTABLE__.ONECARDSUIPIANITEM_CARDSUIPIANID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ONECARDSUIPIANITEM_NUMBER_FIELD = protobuf.FieldDescriptor();
local CARDSUIPIANFLUSH = protobuf.Descriptor();
_M.CARDSUIPIANFLUSH = CARDSUIPIANFLUSH

__PBTABLE__.CARDSUIPIANFLUSH_ID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.CARDSUIPIANFLUSH_HEAD_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.CARDSUIPIANFLUSH_CARDSUIPIAN_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.CARDSUIPIANFLUSH_MOD_FIELD = protobuf.FieldDescriptor();

__PBTABLE__.CARDBAG_OPT_MOD_ADD_ENUM.name = "add"
__PBTABLE__.CARDBAG_OPT_MOD_ADD_ENUM.index = 0
__PBTABLE__.CARDBAG_OPT_MOD_ADD_ENUM.number = 0
__PBTABLE__.CARDBAG_OPT_MOD_DEL_ENUM.name = "del"
__PBTABLE__.CARDBAG_OPT_MOD_DEL_ENUM.index = 1
__PBTABLE__.CARDBAG_OPT_MOD_DEL_ENUM.number = 1
__PBTABLE__.CARDBAG_OPT_MOD_UPDATE_ENUM.name = "update"
__PBTABLE__.CARDBAG_OPT_MOD_UPDATE_ENUM.index = 2
__PBTABLE__.CARDBAG_OPT_MOD_UPDATE_ENUM.number = 2
__PBTABLE__.CARDBAG_OPT_MOD_SHIZHUANGDEL_ENUM.name = "shizhuangDel"
__PBTABLE__.CARDBAG_OPT_MOD_SHIZHUANGDEL_ENUM.index = 3
__PBTABLE__.CARDBAG_OPT_MOD_SHIZHUANGDEL_ENUM.number = 3
__PBTABLE__.CARDBAG_OPT_MOD_SHIZHUANGADD_ENUM.name = "shizhuangAdd"
__PBTABLE__.CARDBAG_OPT_MOD_SHIZHUANGADD_ENUM.index = 4
__PBTABLE__.CARDBAG_OPT_MOD_SHIZHUANGADD_ENUM.number = 4
__PBTABLE__.CARDBAG_OPT_MOD.name = "CARDBAG_OPT_MOD"
__PBTABLE__.CARDBAG_OPT_MOD.full_name = ".PB.CARDBAG_OPT_MOD"
__PBTABLE__.CARDBAG_OPT_MOD.values = {__PBTABLE__.CARDBAG_OPT_MOD_ADD_ENUM,__PBTABLE__.CARDBAG_OPT_MOD_DEL_ENUM,__PBTABLE__.CARDBAG_OPT_MOD_UPDATE_ENUM,__PBTABLE__.CARDBAG_OPT_MOD_SHIZHUANGDEL_ENUM,__PBTABLE__.CARDBAG_OPT_MOD_SHIZHUANGADD_ENUM}
__PBTABLE__.ONECARDSUIPIANITEM_CARDSUIPIANID_FIELD.name = "cardSuipianID"
__PBTABLE__.ONECARDSUIPIANITEM_CARDSUIPIANID_FIELD.full_name = ".PB.OneCardSuipianItem.cardSuipianID"
__PBTABLE__.ONECARDSUIPIANITEM_CARDSUIPIANID_FIELD.number = 1
__PBTABLE__.ONECARDSUIPIANITEM_CARDSUIPIANID_FIELD.index = 0
__PBTABLE__.ONECARDSUIPIANITEM_CARDSUIPIANID_FIELD.label = 1
__PBTABLE__.ONECARDSUIPIANITEM_CARDSUIPIANID_FIELD.has_default_value = false
__PBTABLE__.ONECARDSUIPIANITEM_CARDSUIPIANID_FIELD.default_value = 0
__PBTABLE__.ONECARDSUIPIANITEM_CARDSUIPIANID_FIELD.type = 5
__PBTABLE__.ONECARDSUIPIANITEM_CARDSUIPIANID_FIELD.cpp_type = 1

__PBTABLE__.ONECARDSUIPIANITEM_NUMBER_FIELD.name = "number"
__PBTABLE__.ONECARDSUIPIANITEM_NUMBER_FIELD.full_name = ".PB.OneCardSuipianItem.number"
__PBTABLE__.ONECARDSUIPIANITEM_NUMBER_FIELD.number = 2
__PBTABLE__.ONECARDSUIPIANITEM_NUMBER_FIELD.index = 1
__PBTABLE__.ONECARDSUIPIANITEM_NUMBER_FIELD.label = 1
__PBTABLE__.ONECARDSUIPIANITEM_NUMBER_FIELD.has_default_value = false
__PBTABLE__.ONECARDSUIPIANITEM_NUMBER_FIELD.default_value = 0
__PBTABLE__.ONECARDSUIPIANITEM_NUMBER_FIELD.type = 5
__PBTABLE__.ONECARDSUIPIANITEM_NUMBER_FIELD.cpp_type = 1

ONECARDSUIPIANITEM.name = "OneCardSuipianItem"
ONECARDSUIPIANITEM.full_name = ".PB.OneCardSuipianItem"
ONECARDSUIPIANITEM.nested_types = {}
ONECARDSUIPIANITEM.enum_types = {}
ONECARDSUIPIANITEM.fields = {__PBTABLE__.ONECARDSUIPIANITEM_CARDSUIPIANID_FIELD, __PBTABLE__.ONECARDSUIPIANITEM_NUMBER_FIELD}
ONECARDSUIPIANITEM.is_extendable = false
ONECARDSUIPIANITEM.extensions = {}
__PBTABLE__.CARDSUIPIANFLUSH_ID_FIELD.name = "id"
__PBTABLE__.CARDSUIPIANFLUSH_ID_FIELD.full_name = ".PB.CardSuipianFlush.id"
__PBTABLE__.CARDSUIPIANFLUSH_ID_FIELD.number = 1
__PBTABLE__.CARDSUIPIANFLUSH_ID_FIELD.index = 0
__PBTABLE__.CARDSUIPIANFLUSH_ID_FIELD.label = 1
__PBTABLE__.CARDSUIPIANFLUSH_ID_FIELD.has_default_value = true
__PBTABLE__.CARDSUIPIANFLUSH_ID_FIELD.default_value = "SND_ZHENRONG_CARD_SUIPIAN_FLUSH_MESSAGE"
__PBTABLE__.CARDSUIPIANFLUSH_ID_FIELD.enum_type = PROTOCOLID or ProtocolId.PROTOCOLID
__PBTABLE__.CARDSUIPIANFLUSH_ID_FIELD.type = 14
__PBTABLE__.CARDSUIPIANFLUSH_ID_FIELD.cpp_type = 8

__PBTABLE__.CARDSUIPIANFLUSH_HEAD_FIELD.name = "head"
__PBTABLE__.CARDSUIPIANFLUSH_HEAD_FIELD.full_name = ".PB.CardSuipianFlush.head"
__PBTABLE__.CARDSUIPIANFLUSH_HEAD_FIELD.number = 2
__PBTABLE__.CARDSUIPIANFLUSH_HEAD_FIELD.index = 1
__PBTABLE__.CARDSUIPIANFLUSH_HEAD_FIELD.label = 1
__PBTABLE__.CARDSUIPIANFLUSH_HEAD_FIELD.has_default_value = false
__PBTABLE__.CARDSUIPIANFLUSH_HEAD_FIELD.default_value = nil
__PBTABLE__.CARDSUIPIANFLUSH_HEAD_FIELD.message_type = HEADMESSAGE or HeadMessage.HEADMESSAGE
__PBTABLE__.CARDSUIPIANFLUSH_HEAD_FIELD.type = 11
__PBTABLE__.CARDSUIPIANFLUSH_HEAD_FIELD.cpp_type = 10

__PBTABLE__.CARDSUIPIANFLUSH_CARDSUIPIAN_FIELD.name = "cardSuipian"
__PBTABLE__.CARDSUIPIANFLUSH_CARDSUIPIAN_FIELD.full_name = ".PB.CardSuipianFlush.cardSuipian"
__PBTABLE__.CARDSUIPIANFLUSH_CARDSUIPIAN_FIELD.number = 3
__PBTABLE__.CARDSUIPIANFLUSH_CARDSUIPIAN_FIELD.index = 2
__PBTABLE__.CARDSUIPIANFLUSH_CARDSUIPIAN_FIELD.label = 1
__PBTABLE__.CARDSUIPIANFLUSH_CARDSUIPIAN_FIELD.has_default_value = false
__PBTABLE__.CARDSUIPIANFLUSH_CARDSUIPIAN_FIELD.default_value = nil
__PBTABLE__.CARDSUIPIANFLUSH_CARDSUIPIAN_FIELD.message_type = ONECARDSUIPIANITEM or OneCardSuipianItem.ONECARDSUIPIANITEM
__PBTABLE__.CARDSUIPIANFLUSH_CARDSUIPIAN_FIELD.type = 11
__PBTABLE__.CARDSUIPIANFLUSH_CARDSUIPIAN_FIELD.cpp_type = 10

__PBTABLE__.CARDSUIPIANFLUSH_MOD_FIELD.name = "mod"
__PBTABLE__.CARDSUIPIANFLUSH_MOD_FIELD.full_name = ".PB.CardSuipianFlush.mod"
__PBTABLE__.CARDSUIPIANFLUSH_MOD_FIELD.number = 4
__PBTABLE__.CARDSUIPIANFLUSH_MOD_FIELD.index = 3
__PBTABLE__.CARDSUIPIANFLUSH_MOD_FIELD.label = 1
__PBTABLE__.CARDSUIPIANFLUSH_MOD_FIELD.has_default_value = false
__PBTABLE__.CARDSUIPIANFLUSH_MOD_FIELD.default_value = nil
__PBTABLE__.CARDSUIPIANFLUSH_MOD_FIELD.enum_type = CARDBAG_OPT_MOD or CARDBAG_OPT_MOD.CARDBAG_OPT_MOD
__PBTABLE__.CARDSUIPIANFLUSH_MOD_FIELD.type = 14
__PBTABLE__.CARDSUIPIANFLUSH_MOD_FIELD.cpp_type = 8

CARDSUIPIANFLUSH.name = "CardSuipianFlush"
CARDSUIPIANFLUSH.full_name = ".PB.CardSuipianFlush"
CARDSUIPIANFLUSH.nested_types = {}
CARDSUIPIANFLUSH.enum_types = {}
CARDSUIPIANFLUSH.fields = {__PBTABLE__.CARDSUIPIANFLUSH_ID_FIELD, __PBTABLE__.CARDSUIPIANFLUSH_HEAD_FIELD, __PBTABLE__.CARDSUIPIANFLUSH_CARDSUIPIAN_FIELD, __PBTABLE__.CARDSUIPIANFLUSH_MOD_FIELD}
CARDSUIPIANFLUSH.is_extendable = false
CARDSUIPIANFLUSH.extensions = {}

CardSuipianFlush = protobuf.Message(CARDSUIPIANFLUSH)
OneCardSuipianItem = protobuf.Message(ONECARDSUIPIANITEM)
add = 0
del = 1
shizhuangAdd = 4
shizhuangDel = 3
update = 2

