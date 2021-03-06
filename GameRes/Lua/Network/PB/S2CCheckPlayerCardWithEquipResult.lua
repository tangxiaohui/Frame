-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf.protobuf"
local ProtocolId = require("Network.PB.ProtocolId")
local HeadMessage = require("Network.PB.HeadMessage")
module('Network.PB.S2CCheckPlayerCardWithEquipResult')


local __PBTABLE__ = {}

local ONECARDITEM = protobuf.Descriptor();
_M.ONECARDITEM = ONECARDITEM

__PBTABLE__.ONECARDITEM_ID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ONECARDITEM_UID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ONECARDITEM_POS_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ONECARDITEM_COLOR_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ONECARDITEM_LEVEL_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ONECARDITEM_EXP_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ONECARDITEM_STAGE_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ONECARDITEM_TALENT1_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ONECARDITEM_TALENT2_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ONECARDITEM_TALENTA_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ONECARDITEM_TALENTB_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ONECARDITEM_TALENTC_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ONECARDITEM_PLAYERID_FIELD = protobuf.FieldDescriptor();
local EQUIPONCARDSTRUCT = protobuf.Descriptor();
_M.EQUIPONCARDSTRUCT = EQUIPONCARDSTRUCT

__PBTABLE__.EQUIPONCARDSTRUCT_ID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.EQUIPONCARDSTRUCT_POS_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.EQUIPONCARDSTRUCT_LEVEL_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.EQUIPONCARDSTRUCT_COLOR_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.EQUIPONCARDSTRUCT_GEMID_FIELD = protobuf.FieldDescriptor();
local CHECKPLAYERCARDWITHEQUIPRESULT = protobuf.Descriptor();
_M.CHECKPLAYERCARDWITHEQUIPRESULT = CHECKPLAYERCARDWITHEQUIPRESULT

__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_ID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_HEAD_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_CARD_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_EQUIPS_FIELD = protobuf.FieldDescriptor();

__PBTABLE__.ONECARDITEM_ID_FIELD.name = "id"
__PBTABLE__.ONECARDITEM_ID_FIELD.full_name = ".PB.OneCardItem.id"
__PBTABLE__.ONECARDITEM_ID_FIELD.number = 1
__PBTABLE__.ONECARDITEM_ID_FIELD.index = 0
__PBTABLE__.ONECARDITEM_ID_FIELD.label = 2
__PBTABLE__.ONECARDITEM_ID_FIELD.has_default_value = false
__PBTABLE__.ONECARDITEM_ID_FIELD.default_value = 0
__PBTABLE__.ONECARDITEM_ID_FIELD.type = 5
__PBTABLE__.ONECARDITEM_ID_FIELD.cpp_type = 1

__PBTABLE__.ONECARDITEM_UID_FIELD.name = "uid"
__PBTABLE__.ONECARDITEM_UID_FIELD.full_name = ".PB.OneCardItem.uid"
__PBTABLE__.ONECARDITEM_UID_FIELD.number = 2
__PBTABLE__.ONECARDITEM_UID_FIELD.index = 1
__PBTABLE__.ONECARDITEM_UID_FIELD.label = 1
__PBTABLE__.ONECARDITEM_UID_FIELD.has_default_value = false
__PBTABLE__.ONECARDITEM_UID_FIELD.default_value = ""
__PBTABLE__.ONECARDITEM_UID_FIELD.type = 9
__PBTABLE__.ONECARDITEM_UID_FIELD.cpp_type = 9

__PBTABLE__.ONECARDITEM_POS_FIELD.name = "pos"
__PBTABLE__.ONECARDITEM_POS_FIELD.full_name = ".PB.OneCardItem.pos"
__PBTABLE__.ONECARDITEM_POS_FIELD.number = 3
__PBTABLE__.ONECARDITEM_POS_FIELD.index = 2
__PBTABLE__.ONECARDITEM_POS_FIELD.label = 3
__PBTABLE__.ONECARDITEM_POS_FIELD.has_default_value = false
__PBTABLE__.ONECARDITEM_POS_FIELD.default_value = {}
__PBTABLE__.ONECARDITEM_POS_FIELD.type = 5
__PBTABLE__.ONECARDITEM_POS_FIELD.cpp_type = 1

__PBTABLE__.ONECARDITEM_COLOR_FIELD.name = "color"
__PBTABLE__.ONECARDITEM_COLOR_FIELD.full_name = ".PB.OneCardItem.color"
__PBTABLE__.ONECARDITEM_COLOR_FIELD.number = 4
__PBTABLE__.ONECARDITEM_COLOR_FIELD.index = 3
__PBTABLE__.ONECARDITEM_COLOR_FIELD.label = 1
__PBTABLE__.ONECARDITEM_COLOR_FIELD.has_default_value = false
__PBTABLE__.ONECARDITEM_COLOR_FIELD.default_value = 0
__PBTABLE__.ONECARDITEM_COLOR_FIELD.type = 5
__PBTABLE__.ONECARDITEM_COLOR_FIELD.cpp_type = 1

__PBTABLE__.ONECARDITEM_LEVEL_FIELD.name = "level"
__PBTABLE__.ONECARDITEM_LEVEL_FIELD.full_name = ".PB.OneCardItem.level"
__PBTABLE__.ONECARDITEM_LEVEL_FIELD.number = 5
__PBTABLE__.ONECARDITEM_LEVEL_FIELD.index = 4
__PBTABLE__.ONECARDITEM_LEVEL_FIELD.label = 1
__PBTABLE__.ONECARDITEM_LEVEL_FIELD.has_default_value = false
__PBTABLE__.ONECARDITEM_LEVEL_FIELD.default_value = 0
__PBTABLE__.ONECARDITEM_LEVEL_FIELD.type = 5
__PBTABLE__.ONECARDITEM_LEVEL_FIELD.cpp_type = 1

__PBTABLE__.ONECARDITEM_EXP_FIELD.name = "exp"
__PBTABLE__.ONECARDITEM_EXP_FIELD.full_name = ".PB.OneCardItem.exp"
__PBTABLE__.ONECARDITEM_EXP_FIELD.number = 6
__PBTABLE__.ONECARDITEM_EXP_FIELD.index = 5
__PBTABLE__.ONECARDITEM_EXP_FIELD.label = 1
__PBTABLE__.ONECARDITEM_EXP_FIELD.has_default_value = false
__PBTABLE__.ONECARDITEM_EXP_FIELD.default_value = 0
__PBTABLE__.ONECARDITEM_EXP_FIELD.type = 5
__PBTABLE__.ONECARDITEM_EXP_FIELD.cpp_type = 1

__PBTABLE__.ONECARDITEM_STAGE_FIELD.name = "stage"
__PBTABLE__.ONECARDITEM_STAGE_FIELD.full_name = ".PB.OneCardItem.stage"
__PBTABLE__.ONECARDITEM_STAGE_FIELD.number = 7
__PBTABLE__.ONECARDITEM_STAGE_FIELD.index = 6
__PBTABLE__.ONECARDITEM_STAGE_FIELD.label = 1
__PBTABLE__.ONECARDITEM_STAGE_FIELD.has_default_value = false
__PBTABLE__.ONECARDITEM_STAGE_FIELD.default_value = 0
__PBTABLE__.ONECARDITEM_STAGE_FIELD.type = 5
__PBTABLE__.ONECARDITEM_STAGE_FIELD.cpp_type = 1

__PBTABLE__.ONECARDITEM_TALENT1_FIELD.name = "talent1"
__PBTABLE__.ONECARDITEM_TALENT1_FIELD.full_name = ".PB.OneCardItem.talent1"
__PBTABLE__.ONECARDITEM_TALENT1_FIELD.number = 8
__PBTABLE__.ONECARDITEM_TALENT1_FIELD.index = 7
__PBTABLE__.ONECARDITEM_TALENT1_FIELD.label = 1
__PBTABLE__.ONECARDITEM_TALENT1_FIELD.has_default_value = false
__PBTABLE__.ONECARDITEM_TALENT1_FIELD.default_value = 0
__PBTABLE__.ONECARDITEM_TALENT1_FIELD.type = 5
__PBTABLE__.ONECARDITEM_TALENT1_FIELD.cpp_type = 1

__PBTABLE__.ONECARDITEM_TALENT2_FIELD.name = "talent2"
__PBTABLE__.ONECARDITEM_TALENT2_FIELD.full_name = ".PB.OneCardItem.talent2"
__PBTABLE__.ONECARDITEM_TALENT2_FIELD.number = 9
__PBTABLE__.ONECARDITEM_TALENT2_FIELD.index = 8
__PBTABLE__.ONECARDITEM_TALENT2_FIELD.label = 1
__PBTABLE__.ONECARDITEM_TALENT2_FIELD.has_default_value = false
__PBTABLE__.ONECARDITEM_TALENT2_FIELD.default_value = 0
__PBTABLE__.ONECARDITEM_TALENT2_FIELD.type = 5
__PBTABLE__.ONECARDITEM_TALENT2_FIELD.cpp_type = 1

__PBTABLE__.ONECARDITEM_TALENTA_FIELD.name = "talentA"
__PBTABLE__.ONECARDITEM_TALENTA_FIELD.full_name = ".PB.OneCardItem.talentA"
__PBTABLE__.ONECARDITEM_TALENTA_FIELD.number = 10
__PBTABLE__.ONECARDITEM_TALENTA_FIELD.index = 9
__PBTABLE__.ONECARDITEM_TALENTA_FIELD.label = 1
__PBTABLE__.ONECARDITEM_TALENTA_FIELD.has_default_value = false
__PBTABLE__.ONECARDITEM_TALENTA_FIELD.default_value = 0
__PBTABLE__.ONECARDITEM_TALENTA_FIELD.type = 5
__PBTABLE__.ONECARDITEM_TALENTA_FIELD.cpp_type = 1

__PBTABLE__.ONECARDITEM_TALENTB_FIELD.name = "talentB"
__PBTABLE__.ONECARDITEM_TALENTB_FIELD.full_name = ".PB.OneCardItem.talentB"
__PBTABLE__.ONECARDITEM_TALENTB_FIELD.number = 11
__PBTABLE__.ONECARDITEM_TALENTB_FIELD.index = 10
__PBTABLE__.ONECARDITEM_TALENTB_FIELD.label = 1
__PBTABLE__.ONECARDITEM_TALENTB_FIELD.has_default_value = false
__PBTABLE__.ONECARDITEM_TALENTB_FIELD.default_value = 0
__PBTABLE__.ONECARDITEM_TALENTB_FIELD.type = 5
__PBTABLE__.ONECARDITEM_TALENTB_FIELD.cpp_type = 1

__PBTABLE__.ONECARDITEM_TALENTC_FIELD.name = "talentC"
__PBTABLE__.ONECARDITEM_TALENTC_FIELD.full_name = ".PB.OneCardItem.talentC"
__PBTABLE__.ONECARDITEM_TALENTC_FIELD.number = 12
__PBTABLE__.ONECARDITEM_TALENTC_FIELD.index = 11
__PBTABLE__.ONECARDITEM_TALENTC_FIELD.label = 1
__PBTABLE__.ONECARDITEM_TALENTC_FIELD.has_default_value = false
__PBTABLE__.ONECARDITEM_TALENTC_FIELD.default_value = 0
__PBTABLE__.ONECARDITEM_TALENTC_FIELD.type = 5
__PBTABLE__.ONECARDITEM_TALENTC_FIELD.cpp_type = 1

__PBTABLE__.ONECARDITEM_PLAYERID_FIELD.name = "playerID"
__PBTABLE__.ONECARDITEM_PLAYERID_FIELD.full_name = ".PB.OneCardItem.playerID"
__PBTABLE__.ONECARDITEM_PLAYERID_FIELD.number = 13
__PBTABLE__.ONECARDITEM_PLAYERID_FIELD.index = 12
__PBTABLE__.ONECARDITEM_PLAYERID_FIELD.label = 1
__PBTABLE__.ONECARDITEM_PLAYERID_FIELD.has_default_value = false
__PBTABLE__.ONECARDITEM_PLAYERID_FIELD.default_value = 0
__PBTABLE__.ONECARDITEM_PLAYERID_FIELD.type = 5
__PBTABLE__.ONECARDITEM_PLAYERID_FIELD.cpp_type = 1

ONECARDITEM.name = "OneCardItem"
ONECARDITEM.full_name = ".PB.OneCardItem"
ONECARDITEM.nested_types = {}
ONECARDITEM.enum_types = {}
ONECARDITEM.fields = {__PBTABLE__.ONECARDITEM_ID_FIELD, __PBTABLE__.ONECARDITEM_UID_FIELD, __PBTABLE__.ONECARDITEM_POS_FIELD, __PBTABLE__.ONECARDITEM_COLOR_FIELD, __PBTABLE__.ONECARDITEM_LEVEL_FIELD, __PBTABLE__.ONECARDITEM_EXP_FIELD, __PBTABLE__.ONECARDITEM_STAGE_FIELD, __PBTABLE__.ONECARDITEM_TALENT1_FIELD, __PBTABLE__.ONECARDITEM_TALENT2_FIELD, __PBTABLE__.ONECARDITEM_TALENTA_FIELD, __PBTABLE__.ONECARDITEM_TALENTB_FIELD, __PBTABLE__.ONECARDITEM_TALENTC_FIELD, __PBTABLE__.ONECARDITEM_PLAYERID_FIELD}
ONECARDITEM.is_extendable = false
ONECARDITEM.extensions = {}
__PBTABLE__.EQUIPONCARDSTRUCT_ID_FIELD.name = "id"
__PBTABLE__.EQUIPONCARDSTRUCT_ID_FIELD.full_name = ".PB.EquipOnCardStruct.id"
__PBTABLE__.EQUIPONCARDSTRUCT_ID_FIELD.number = 1
__PBTABLE__.EQUIPONCARDSTRUCT_ID_FIELD.index = 0
__PBTABLE__.EQUIPONCARDSTRUCT_ID_FIELD.label = 1
__PBTABLE__.EQUIPONCARDSTRUCT_ID_FIELD.has_default_value = false
__PBTABLE__.EQUIPONCARDSTRUCT_ID_FIELD.default_value = 0
__PBTABLE__.EQUIPONCARDSTRUCT_ID_FIELD.type = 5
__PBTABLE__.EQUIPONCARDSTRUCT_ID_FIELD.cpp_type = 1

__PBTABLE__.EQUIPONCARDSTRUCT_POS_FIELD.name = "pos"
__PBTABLE__.EQUIPONCARDSTRUCT_POS_FIELD.full_name = ".PB.EquipOnCardStruct.pos"
__PBTABLE__.EQUIPONCARDSTRUCT_POS_FIELD.number = 2
__PBTABLE__.EQUIPONCARDSTRUCT_POS_FIELD.index = 1
__PBTABLE__.EQUIPONCARDSTRUCT_POS_FIELD.label = 1
__PBTABLE__.EQUIPONCARDSTRUCT_POS_FIELD.has_default_value = false
__PBTABLE__.EQUIPONCARDSTRUCT_POS_FIELD.default_value = 0
__PBTABLE__.EQUIPONCARDSTRUCT_POS_FIELD.type = 5
__PBTABLE__.EQUIPONCARDSTRUCT_POS_FIELD.cpp_type = 1

__PBTABLE__.EQUIPONCARDSTRUCT_LEVEL_FIELD.name = "level"
__PBTABLE__.EQUIPONCARDSTRUCT_LEVEL_FIELD.full_name = ".PB.EquipOnCardStruct.level"
__PBTABLE__.EQUIPONCARDSTRUCT_LEVEL_FIELD.number = 3
__PBTABLE__.EQUIPONCARDSTRUCT_LEVEL_FIELD.index = 2
__PBTABLE__.EQUIPONCARDSTRUCT_LEVEL_FIELD.label = 1
__PBTABLE__.EQUIPONCARDSTRUCT_LEVEL_FIELD.has_default_value = false
__PBTABLE__.EQUIPONCARDSTRUCT_LEVEL_FIELD.default_value = 0
__PBTABLE__.EQUIPONCARDSTRUCT_LEVEL_FIELD.type = 5
__PBTABLE__.EQUIPONCARDSTRUCT_LEVEL_FIELD.cpp_type = 1

__PBTABLE__.EQUIPONCARDSTRUCT_COLOR_FIELD.name = "color"
__PBTABLE__.EQUIPONCARDSTRUCT_COLOR_FIELD.full_name = ".PB.EquipOnCardStruct.color"
__PBTABLE__.EQUIPONCARDSTRUCT_COLOR_FIELD.number = 4
__PBTABLE__.EQUIPONCARDSTRUCT_COLOR_FIELD.index = 3
__PBTABLE__.EQUIPONCARDSTRUCT_COLOR_FIELD.label = 1
__PBTABLE__.EQUIPONCARDSTRUCT_COLOR_FIELD.has_default_value = false
__PBTABLE__.EQUIPONCARDSTRUCT_COLOR_FIELD.default_value = 0
__PBTABLE__.EQUIPONCARDSTRUCT_COLOR_FIELD.type = 5
__PBTABLE__.EQUIPONCARDSTRUCT_COLOR_FIELD.cpp_type = 1

__PBTABLE__.EQUIPONCARDSTRUCT_GEMID_FIELD.name = "gemId"
__PBTABLE__.EQUIPONCARDSTRUCT_GEMID_FIELD.full_name = ".PB.EquipOnCardStruct.gemId"
__PBTABLE__.EQUIPONCARDSTRUCT_GEMID_FIELD.number = 5
__PBTABLE__.EQUIPONCARDSTRUCT_GEMID_FIELD.index = 4
__PBTABLE__.EQUIPONCARDSTRUCT_GEMID_FIELD.label = 1
__PBTABLE__.EQUIPONCARDSTRUCT_GEMID_FIELD.has_default_value = false
__PBTABLE__.EQUIPONCARDSTRUCT_GEMID_FIELD.default_value = 0
__PBTABLE__.EQUIPONCARDSTRUCT_GEMID_FIELD.type = 5
__PBTABLE__.EQUIPONCARDSTRUCT_GEMID_FIELD.cpp_type = 1

EQUIPONCARDSTRUCT.name = "EquipOnCardStruct"
EQUIPONCARDSTRUCT.full_name = ".PB.EquipOnCardStruct"
EQUIPONCARDSTRUCT.nested_types = {}
EQUIPONCARDSTRUCT.enum_types = {}
EQUIPONCARDSTRUCT.fields = {__PBTABLE__.EQUIPONCARDSTRUCT_ID_FIELD, __PBTABLE__.EQUIPONCARDSTRUCT_POS_FIELD, __PBTABLE__.EQUIPONCARDSTRUCT_LEVEL_FIELD, __PBTABLE__.EQUIPONCARDSTRUCT_COLOR_FIELD, __PBTABLE__.EQUIPONCARDSTRUCT_GEMID_FIELD}
EQUIPONCARDSTRUCT.is_extendable = false
EQUIPONCARDSTRUCT.extensions = {}
__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_ID_FIELD.name = "id"
__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_ID_FIELD.full_name = ".PB.CheckPlayerCardWithEquipResult.id"
__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_ID_FIELD.number = 1
__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_ID_FIELD.index = 0
__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_ID_FIELD.label = 1
__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_ID_FIELD.has_default_value = true
__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_ID_FIELD.default_value = "SND_ZHENRONG_CHECK_PLAYER_CARD_WITH_EQUIP_RESULT_MESSAGE"
__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_ID_FIELD.enum_type = PROTOCOLID or ProtocolId.PROTOCOLID
__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_ID_FIELD.type = 14
__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_ID_FIELD.cpp_type = 8

__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_HEAD_FIELD.name = "head"
__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_HEAD_FIELD.full_name = ".PB.CheckPlayerCardWithEquipResult.head"
__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_HEAD_FIELD.number = 2
__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_HEAD_FIELD.index = 1
__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_HEAD_FIELD.label = 1
__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_HEAD_FIELD.has_default_value = false
__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_HEAD_FIELD.default_value = nil
__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_HEAD_FIELD.message_type = HEADMESSAGE or HeadMessage.HEADMESSAGE
__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_HEAD_FIELD.type = 11
__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_HEAD_FIELD.cpp_type = 10

__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_CARD_FIELD.name = "card"
__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_CARD_FIELD.full_name = ".PB.CheckPlayerCardWithEquipResult.card"
__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_CARD_FIELD.number = 3
__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_CARD_FIELD.index = 2
__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_CARD_FIELD.label = 1
__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_CARD_FIELD.has_default_value = false
__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_CARD_FIELD.default_value = nil
__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_CARD_FIELD.message_type = ONECARDITEM or OneCardItem.ONECARDITEM
__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_CARD_FIELD.type = 11
__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_CARD_FIELD.cpp_type = 10

__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_EQUIPS_FIELD.name = "equips"
__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_EQUIPS_FIELD.full_name = ".PB.CheckPlayerCardWithEquipResult.equips"
__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_EQUIPS_FIELD.number = 4
__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_EQUIPS_FIELD.index = 3
__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_EQUIPS_FIELD.label = 3
__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_EQUIPS_FIELD.has_default_value = false
__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_EQUIPS_FIELD.default_value = {}
__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_EQUIPS_FIELD.message_type = EQUIPONCARDSTRUCT or EquipOnCardStruct.EQUIPONCARDSTRUCT
__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_EQUIPS_FIELD.type = 11
__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_EQUIPS_FIELD.cpp_type = 10

CHECKPLAYERCARDWITHEQUIPRESULT.name = "CheckPlayerCardWithEquipResult"
CHECKPLAYERCARDWITHEQUIPRESULT.full_name = ".PB.CheckPlayerCardWithEquipResult"
CHECKPLAYERCARDWITHEQUIPRESULT.nested_types = {}
CHECKPLAYERCARDWITHEQUIPRESULT.enum_types = {}
CHECKPLAYERCARDWITHEQUIPRESULT.fields = {__PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_ID_FIELD, __PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_HEAD_FIELD, __PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_CARD_FIELD, __PBTABLE__.CHECKPLAYERCARDWITHEQUIPRESULT_EQUIPS_FIELD}
CHECKPLAYERCARDWITHEQUIPRESULT.is_extendable = false
CHECKPLAYERCARDWITHEQUIPRESULT.extensions = {}

CheckPlayerCardWithEquipResult = protobuf.Message(CHECKPLAYERCARDWITHEQUIPRESULT)
EquipOnCardStruct = protobuf.Message(EQUIPONCARDSTRUCT)
OneCardItem = protobuf.Message(ONECARDITEM)

