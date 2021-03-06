-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf.protobuf"
local ProtocolId = require("Network.PB.ProtocolId")
local HeadMessage = require("Network.PB.HeadMessage")
module('Network.PB.S2CArenaTop50QueryResult')


local __PBTABLE__ = {}

local ARENARANKITEM = protobuf.Descriptor();
_M.ARENARANKITEM = ARENARANKITEM

__PBTABLE__.ARENARANKITEM_PLAYERUID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ARENARANKITEM_PLAYERNAME_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ARENARANKITEM_PLAYERLEVEL_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ARENARANKITEM_RANK_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ARENARANKITEM_HEADCARDID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ARENARANKITEM_HEADCARDCOLOR_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ARENARANKITEM_HONORID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ARENARANKITEM_JUNXIAN_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ARENARANKITEM_ZHANLI_FIELD = protobuf.FieldDescriptor();
local ARENATOP50QUERYRESULT = protobuf.Descriptor();
_M.ARENATOP50QUERYRESULT = ARENATOP50QUERYRESULT

__PBTABLE__.ARENATOP50QUERYRESULT_ID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ARENATOP50QUERYRESULT_HEAD_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ARENATOP50QUERYRESULT_RANKITEMS_FIELD = protobuf.FieldDescriptor();

__PBTABLE__.ARENARANKITEM_PLAYERUID_FIELD.name = "playerUID"
__PBTABLE__.ARENARANKITEM_PLAYERUID_FIELD.full_name = ".PB.ArenaRankItem.playerUID"
__PBTABLE__.ARENARANKITEM_PLAYERUID_FIELD.number = 1
__PBTABLE__.ARENARANKITEM_PLAYERUID_FIELD.index = 0
__PBTABLE__.ARENARANKITEM_PLAYERUID_FIELD.label = 1
__PBTABLE__.ARENARANKITEM_PLAYERUID_FIELD.has_default_value = false
__PBTABLE__.ARENARANKITEM_PLAYERUID_FIELD.default_value = ""
__PBTABLE__.ARENARANKITEM_PLAYERUID_FIELD.type = 9
__PBTABLE__.ARENARANKITEM_PLAYERUID_FIELD.cpp_type = 9

__PBTABLE__.ARENARANKITEM_PLAYERNAME_FIELD.name = "playerName"
__PBTABLE__.ARENARANKITEM_PLAYERNAME_FIELD.full_name = ".PB.ArenaRankItem.playerName"
__PBTABLE__.ARENARANKITEM_PLAYERNAME_FIELD.number = 2
__PBTABLE__.ARENARANKITEM_PLAYERNAME_FIELD.index = 1
__PBTABLE__.ARENARANKITEM_PLAYERNAME_FIELD.label = 1
__PBTABLE__.ARENARANKITEM_PLAYERNAME_FIELD.has_default_value = false
__PBTABLE__.ARENARANKITEM_PLAYERNAME_FIELD.default_value = ""
__PBTABLE__.ARENARANKITEM_PLAYERNAME_FIELD.type = 9
__PBTABLE__.ARENARANKITEM_PLAYERNAME_FIELD.cpp_type = 9

__PBTABLE__.ARENARANKITEM_PLAYERLEVEL_FIELD.name = "playerLevel"
__PBTABLE__.ARENARANKITEM_PLAYERLEVEL_FIELD.full_name = ".PB.ArenaRankItem.playerLevel"
__PBTABLE__.ARENARANKITEM_PLAYERLEVEL_FIELD.number = 3
__PBTABLE__.ARENARANKITEM_PLAYERLEVEL_FIELD.index = 2
__PBTABLE__.ARENARANKITEM_PLAYERLEVEL_FIELD.label = 1
__PBTABLE__.ARENARANKITEM_PLAYERLEVEL_FIELD.has_default_value = false
__PBTABLE__.ARENARANKITEM_PLAYERLEVEL_FIELD.default_value = 0
__PBTABLE__.ARENARANKITEM_PLAYERLEVEL_FIELD.type = 5
__PBTABLE__.ARENARANKITEM_PLAYERLEVEL_FIELD.cpp_type = 1

__PBTABLE__.ARENARANKITEM_RANK_FIELD.name = "rank"
__PBTABLE__.ARENARANKITEM_RANK_FIELD.full_name = ".PB.ArenaRankItem.rank"
__PBTABLE__.ARENARANKITEM_RANK_FIELD.number = 4
__PBTABLE__.ARENARANKITEM_RANK_FIELD.index = 3
__PBTABLE__.ARENARANKITEM_RANK_FIELD.label = 1
__PBTABLE__.ARENARANKITEM_RANK_FIELD.has_default_value = false
__PBTABLE__.ARENARANKITEM_RANK_FIELD.default_value = 0
__PBTABLE__.ARENARANKITEM_RANK_FIELD.type = 5
__PBTABLE__.ARENARANKITEM_RANK_FIELD.cpp_type = 1

__PBTABLE__.ARENARANKITEM_HEADCARDID_FIELD.name = "headCardID"
__PBTABLE__.ARENARANKITEM_HEADCARDID_FIELD.full_name = ".PB.ArenaRankItem.headCardID"
__PBTABLE__.ARENARANKITEM_HEADCARDID_FIELD.number = 5
__PBTABLE__.ARENARANKITEM_HEADCARDID_FIELD.index = 4
__PBTABLE__.ARENARANKITEM_HEADCARDID_FIELD.label = 1
__PBTABLE__.ARENARANKITEM_HEADCARDID_FIELD.has_default_value = false
__PBTABLE__.ARENARANKITEM_HEADCARDID_FIELD.default_value = 0
__PBTABLE__.ARENARANKITEM_HEADCARDID_FIELD.type = 5
__PBTABLE__.ARENARANKITEM_HEADCARDID_FIELD.cpp_type = 1

__PBTABLE__.ARENARANKITEM_HEADCARDCOLOR_FIELD.name = "headCardColor"
__PBTABLE__.ARENARANKITEM_HEADCARDCOLOR_FIELD.full_name = ".PB.ArenaRankItem.headCardColor"
__PBTABLE__.ARENARANKITEM_HEADCARDCOLOR_FIELD.number = 6
__PBTABLE__.ARENARANKITEM_HEADCARDCOLOR_FIELD.index = 5
__PBTABLE__.ARENARANKITEM_HEADCARDCOLOR_FIELD.label = 1
__PBTABLE__.ARENARANKITEM_HEADCARDCOLOR_FIELD.has_default_value = false
__PBTABLE__.ARENARANKITEM_HEADCARDCOLOR_FIELD.default_value = 0
__PBTABLE__.ARENARANKITEM_HEADCARDCOLOR_FIELD.type = 5
__PBTABLE__.ARENARANKITEM_HEADCARDCOLOR_FIELD.cpp_type = 1

__PBTABLE__.ARENARANKITEM_HONORID_FIELD.name = "honorID"
__PBTABLE__.ARENARANKITEM_HONORID_FIELD.full_name = ".PB.ArenaRankItem.honorID"
__PBTABLE__.ARENARANKITEM_HONORID_FIELD.number = 7
__PBTABLE__.ARENARANKITEM_HONORID_FIELD.index = 6
__PBTABLE__.ARENARANKITEM_HONORID_FIELD.label = 1
__PBTABLE__.ARENARANKITEM_HONORID_FIELD.has_default_value = false
__PBTABLE__.ARENARANKITEM_HONORID_FIELD.default_value = 0
__PBTABLE__.ARENARANKITEM_HONORID_FIELD.type = 5
__PBTABLE__.ARENARANKITEM_HONORID_FIELD.cpp_type = 1

__PBTABLE__.ARENARANKITEM_JUNXIAN_FIELD.name = "junxian"
__PBTABLE__.ARENARANKITEM_JUNXIAN_FIELD.full_name = ".PB.ArenaRankItem.junxian"
__PBTABLE__.ARENARANKITEM_JUNXIAN_FIELD.number = 8
__PBTABLE__.ARENARANKITEM_JUNXIAN_FIELD.index = 7
__PBTABLE__.ARENARANKITEM_JUNXIAN_FIELD.label = 1
__PBTABLE__.ARENARANKITEM_JUNXIAN_FIELD.has_default_value = false
__PBTABLE__.ARENARANKITEM_JUNXIAN_FIELD.default_value = 0
__PBTABLE__.ARENARANKITEM_JUNXIAN_FIELD.type = 5
__PBTABLE__.ARENARANKITEM_JUNXIAN_FIELD.cpp_type = 1

__PBTABLE__.ARENARANKITEM_ZHANLI_FIELD.name = "zhanli"
__PBTABLE__.ARENARANKITEM_ZHANLI_FIELD.full_name = ".PB.ArenaRankItem.zhanli"
__PBTABLE__.ARENARANKITEM_ZHANLI_FIELD.number = 9
__PBTABLE__.ARENARANKITEM_ZHANLI_FIELD.index = 8
__PBTABLE__.ARENARANKITEM_ZHANLI_FIELD.label = 1
__PBTABLE__.ARENARANKITEM_ZHANLI_FIELD.has_default_value = false
__PBTABLE__.ARENARANKITEM_ZHANLI_FIELD.default_value = 0
__PBTABLE__.ARENARANKITEM_ZHANLI_FIELD.type = 5
__PBTABLE__.ARENARANKITEM_ZHANLI_FIELD.cpp_type = 1

ARENARANKITEM.name = "ArenaRankItem"
ARENARANKITEM.full_name = ".PB.ArenaRankItem"
ARENARANKITEM.nested_types = {}
ARENARANKITEM.enum_types = {}
ARENARANKITEM.fields = {__PBTABLE__.ARENARANKITEM_PLAYERUID_FIELD, __PBTABLE__.ARENARANKITEM_PLAYERNAME_FIELD, __PBTABLE__.ARENARANKITEM_PLAYERLEVEL_FIELD, __PBTABLE__.ARENARANKITEM_RANK_FIELD, __PBTABLE__.ARENARANKITEM_HEADCARDID_FIELD, __PBTABLE__.ARENARANKITEM_HEADCARDCOLOR_FIELD, __PBTABLE__.ARENARANKITEM_HONORID_FIELD, __PBTABLE__.ARENARANKITEM_JUNXIAN_FIELD, __PBTABLE__.ARENARANKITEM_ZHANLI_FIELD}
ARENARANKITEM.is_extendable = false
ARENARANKITEM.extensions = {}
__PBTABLE__.ARENATOP50QUERYRESULT_ID_FIELD.name = "id"
__PBTABLE__.ARENATOP50QUERYRESULT_ID_FIELD.full_name = ".PB.ArenaTop50QueryResult.id"
__PBTABLE__.ARENATOP50QUERYRESULT_ID_FIELD.number = 1
__PBTABLE__.ARENATOP50QUERYRESULT_ID_FIELD.index = 0
__PBTABLE__.ARENATOP50QUERYRESULT_ID_FIELD.label = 1
__PBTABLE__.ARENATOP50QUERYRESULT_ID_FIELD.has_default_value = true
__PBTABLE__.ARENATOP50QUERYRESULT_ID_FIELD.default_value = "SND_ARENA_ARENA_TOP50_QUERY_RESULT_MESSAGE"
__PBTABLE__.ARENATOP50QUERYRESULT_ID_FIELD.enum_type = PROTOCOLID or ProtocolId.PROTOCOLID
__PBTABLE__.ARENATOP50QUERYRESULT_ID_FIELD.type = 14
__PBTABLE__.ARENATOP50QUERYRESULT_ID_FIELD.cpp_type = 8

__PBTABLE__.ARENATOP50QUERYRESULT_HEAD_FIELD.name = "head"
__PBTABLE__.ARENATOP50QUERYRESULT_HEAD_FIELD.full_name = ".PB.ArenaTop50QueryResult.head"
__PBTABLE__.ARENATOP50QUERYRESULT_HEAD_FIELD.number = 2
__PBTABLE__.ARENATOP50QUERYRESULT_HEAD_FIELD.index = 1
__PBTABLE__.ARENATOP50QUERYRESULT_HEAD_FIELD.label = 1
__PBTABLE__.ARENATOP50QUERYRESULT_HEAD_FIELD.has_default_value = false
__PBTABLE__.ARENATOP50QUERYRESULT_HEAD_FIELD.default_value = nil
__PBTABLE__.ARENATOP50QUERYRESULT_HEAD_FIELD.message_type = HEADMESSAGE or HeadMessage.HEADMESSAGE
__PBTABLE__.ARENATOP50QUERYRESULT_HEAD_FIELD.type = 11
__PBTABLE__.ARENATOP50QUERYRESULT_HEAD_FIELD.cpp_type = 10

__PBTABLE__.ARENATOP50QUERYRESULT_RANKITEMS_FIELD.name = "rankItems"
__PBTABLE__.ARENATOP50QUERYRESULT_RANKITEMS_FIELD.full_name = ".PB.ArenaTop50QueryResult.rankItems"
__PBTABLE__.ARENATOP50QUERYRESULT_RANKITEMS_FIELD.number = 3
__PBTABLE__.ARENATOP50QUERYRESULT_RANKITEMS_FIELD.index = 2
__PBTABLE__.ARENATOP50QUERYRESULT_RANKITEMS_FIELD.label = 3
__PBTABLE__.ARENATOP50QUERYRESULT_RANKITEMS_FIELD.has_default_value = false
__PBTABLE__.ARENATOP50QUERYRESULT_RANKITEMS_FIELD.default_value = {}
__PBTABLE__.ARENATOP50QUERYRESULT_RANKITEMS_FIELD.message_type = ARENARANKITEM or ArenaRankItem.ARENARANKITEM
__PBTABLE__.ARENATOP50QUERYRESULT_RANKITEMS_FIELD.type = 11
__PBTABLE__.ARENATOP50QUERYRESULT_RANKITEMS_FIELD.cpp_type = 10

ARENATOP50QUERYRESULT.name = "ArenaTop50QueryResult"
ARENATOP50QUERYRESULT.full_name = ".PB.ArenaTop50QueryResult"
ARENATOP50QUERYRESULT.nested_types = {}
ARENATOP50QUERYRESULT.enum_types = {}
ARENATOP50QUERYRESULT.fields = {__PBTABLE__.ARENATOP50QUERYRESULT_ID_FIELD, __PBTABLE__.ARENATOP50QUERYRESULT_HEAD_FIELD, __PBTABLE__.ARENATOP50QUERYRESULT_RANKITEMS_FIELD}
ARENATOP50QUERYRESULT.is_extendable = false
ARENATOP50QUERYRESULT.extensions = {}

ArenaRankItem = protobuf.Message(ARENARANKITEM)
ArenaTop50QueryResult = protobuf.Message(ARENATOP50QUERYRESULT)

