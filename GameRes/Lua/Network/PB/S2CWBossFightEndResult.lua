-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf.protobuf"
local ProtocolId = require("Network.PB.ProtocolId")
module('Network.PB.S2CWBossFightEndResult')


local __PBTABLE__ = {}

local HEADMESSAGE = protobuf.Descriptor();
_M.HEADMESSAGE = HEADMESSAGE

__PBTABLE__.HEADMESSAGE_SID_FIELD = protobuf.FieldDescriptor();
local WORLDBOSSTOTALRESULTMESSAGE = protobuf.Descriptor();
_M.WORLDBOSSTOTALRESULTMESSAGE = WORLDBOSSTOTALRESULTMESSAGE

__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_ID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_HEAD_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_LASTBLOW_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_AWARD_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_COIN_FIELD = protobuf.FieldDescriptor();
local AWARDITEM = protobuf.Descriptor();
_M.AWARDITEM = AWARDITEM

__PBTABLE__.AWARDITEM_ITEMID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.AWARDITEM_ITEMNUM_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.AWARDITEM_ITEMCOLOR_FIELD = protobuf.FieldDescriptor();

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
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_ID_FIELD.name = "id"
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_ID_FIELD.full_name = ".PB.WorldBossTotalResultMessage.id"
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_ID_FIELD.number = 1
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_ID_FIELD.index = 0
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_ID_FIELD.label = 1
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_ID_FIELD.has_default_value = true
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_ID_FIELD.default_value = "SND_WORLD_BOSS_FIGHT_END_RESULT_MESSAGE"
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_ID_FIELD.enum_type = PROTOCOLID or ProtocolId.PROTOCOLID
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_ID_FIELD.type = 14
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_ID_FIELD.cpp_type = 8

__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_HEAD_FIELD.name = "head"
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_HEAD_FIELD.full_name = ".PB.WorldBossTotalResultMessage.head"
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_HEAD_FIELD.number = 2
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_HEAD_FIELD.index = 1
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_HEAD_FIELD.label = 1
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_HEAD_FIELD.has_default_value = false
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_HEAD_FIELD.default_value = nil
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_HEAD_FIELD.message_type = HEADMESSAGE or HeadMessage.HEADMESSAGE
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_HEAD_FIELD.type = 11
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_HEAD_FIELD.cpp_type = 10

__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_LASTBLOW_FIELD.name = "lastBlow"
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_LASTBLOW_FIELD.full_name = ".PB.WorldBossTotalResultMessage.lastBlow"
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_LASTBLOW_FIELD.number = 3
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_LASTBLOW_FIELD.index = 2
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_LASTBLOW_FIELD.label = 1
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_LASTBLOW_FIELD.has_default_value = false
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_LASTBLOW_FIELD.default_value = false
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_LASTBLOW_FIELD.type = 8
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_LASTBLOW_FIELD.cpp_type = 7

__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_AWARD_FIELD.name = "award"
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_AWARD_FIELD.full_name = ".PB.WorldBossTotalResultMessage.award"
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_AWARD_FIELD.number = 4
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_AWARD_FIELD.index = 3
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_AWARD_FIELD.label = 3
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_AWARD_FIELD.has_default_value = false
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_AWARD_FIELD.default_value = {}
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_AWARD_FIELD.message_type = AWARDITEM or AwardItem.AWARDITEM
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_AWARD_FIELD.type = 11
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_AWARD_FIELD.cpp_type = 10

__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_COIN_FIELD.name = "coin"
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_COIN_FIELD.full_name = ".PB.WorldBossTotalResultMessage.coin"
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_COIN_FIELD.number = 5
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_COIN_FIELD.index = 4
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_COIN_FIELD.label = 1
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_COIN_FIELD.has_default_value = false
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_COIN_FIELD.default_value = 0
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_COIN_FIELD.type = 5
__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_COIN_FIELD.cpp_type = 1

WORLDBOSSTOTALRESULTMESSAGE.name = "WorldBossTotalResultMessage"
WORLDBOSSTOTALRESULTMESSAGE.full_name = ".PB.WorldBossTotalResultMessage"
WORLDBOSSTOTALRESULTMESSAGE.nested_types = {}
WORLDBOSSTOTALRESULTMESSAGE.enum_types = {}
WORLDBOSSTOTALRESULTMESSAGE.fields = {__PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_ID_FIELD, __PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_HEAD_FIELD, __PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_LASTBLOW_FIELD, __PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_AWARD_FIELD, __PBTABLE__.WORLDBOSSTOTALRESULTMESSAGE_COIN_FIELD}
WORLDBOSSTOTALRESULTMESSAGE.is_extendable = false
WORLDBOSSTOTALRESULTMESSAGE.extensions = {}
__PBTABLE__.AWARDITEM_ITEMID_FIELD.name = "itemID"
__PBTABLE__.AWARDITEM_ITEMID_FIELD.full_name = ".PB.AwardItem.itemID"
__PBTABLE__.AWARDITEM_ITEMID_FIELD.number = 1
__PBTABLE__.AWARDITEM_ITEMID_FIELD.index = 0
__PBTABLE__.AWARDITEM_ITEMID_FIELD.label = 1
__PBTABLE__.AWARDITEM_ITEMID_FIELD.has_default_value = false
__PBTABLE__.AWARDITEM_ITEMID_FIELD.default_value = 0
__PBTABLE__.AWARDITEM_ITEMID_FIELD.type = 5
__PBTABLE__.AWARDITEM_ITEMID_FIELD.cpp_type = 1

__PBTABLE__.AWARDITEM_ITEMNUM_FIELD.name = "itemNum"
__PBTABLE__.AWARDITEM_ITEMNUM_FIELD.full_name = ".PB.AwardItem.itemNum"
__PBTABLE__.AWARDITEM_ITEMNUM_FIELD.number = 2
__PBTABLE__.AWARDITEM_ITEMNUM_FIELD.index = 1
__PBTABLE__.AWARDITEM_ITEMNUM_FIELD.label = 1
__PBTABLE__.AWARDITEM_ITEMNUM_FIELD.has_default_value = false
__PBTABLE__.AWARDITEM_ITEMNUM_FIELD.default_value = 0
__PBTABLE__.AWARDITEM_ITEMNUM_FIELD.type = 5
__PBTABLE__.AWARDITEM_ITEMNUM_FIELD.cpp_type = 1

__PBTABLE__.AWARDITEM_ITEMCOLOR_FIELD.name = "itemColor"
__PBTABLE__.AWARDITEM_ITEMCOLOR_FIELD.full_name = ".PB.AwardItem.itemColor"
__PBTABLE__.AWARDITEM_ITEMCOLOR_FIELD.number = 3
__PBTABLE__.AWARDITEM_ITEMCOLOR_FIELD.index = 2
__PBTABLE__.AWARDITEM_ITEMCOLOR_FIELD.label = 1
__PBTABLE__.AWARDITEM_ITEMCOLOR_FIELD.has_default_value = false
__PBTABLE__.AWARDITEM_ITEMCOLOR_FIELD.default_value = 0
__PBTABLE__.AWARDITEM_ITEMCOLOR_FIELD.type = 5
__PBTABLE__.AWARDITEM_ITEMCOLOR_FIELD.cpp_type = 1

AWARDITEM.name = "AwardItem"
AWARDITEM.full_name = ".PB.AwardItem"
AWARDITEM.nested_types = {}
AWARDITEM.enum_types = {}
AWARDITEM.fields = {__PBTABLE__.AWARDITEM_ITEMID_FIELD, __PBTABLE__.AWARDITEM_ITEMNUM_FIELD, __PBTABLE__.AWARDITEM_ITEMCOLOR_FIELD}
AWARDITEM.is_extendable = false
AWARDITEM.extensions = {}

AwardItem = protobuf.Message(AWARDITEM)
HeadMessage = protobuf.Message(HEADMESSAGE)
WorldBossTotalResultMessage = protobuf.Message(WORLDBOSSTOTALRESULTMESSAGE)
