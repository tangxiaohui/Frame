-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf.protobuf"
local ProtocolId = require("Network.PB.ProtocolId")
local HeadMessage = require("Network.PB.HeadMessage")
module('Network.PB.S2CGenreQueryResult')


local __PBTABLE__ = {}

local GENREAWARDRANKSTATE = protobuf.Descriptor();
_M.GENREAWARDRANKSTATE = GENREAWARDRANKSTATE

__PBTABLE__.GENREAWARDRANKSTATE_AWARDRANKID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.GENREAWARDRANKSTATE_AWARDRANKSTATE_FIELD = protobuf.FieldDescriptor();
local GENRESTATE = protobuf.Descriptor();
_M.GENRESTATE = GENRESTATE

__PBTABLE__.GENRESTATE_GENREID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.GENRESTATE_GENREAWARDRANKSTATE_FIELD = protobuf.FieldDescriptor();
local GENREQUERYRESULTMESSAGE = protobuf.Descriptor();
_M.GENREQUERYRESULTMESSAGE = GENREQUERYRESULTMESSAGE

__PBTABLE__.GENREQUERYRESULTMESSAGE_ID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.GENREQUERYRESULTMESSAGE_HEAD_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.GENREQUERYRESULTMESSAGE_GENRESTATE_FIELD = protobuf.FieldDescriptor();

__PBTABLE__.GENREAWARDRANKSTATE_AWARDRANKID_FIELD.name = "awardRankId"
__PBTABLE__.GENREAWARDRANKSTATE_AWARDRANKID_FIELD.full_name = ".PB.GenreAwardRankState.awardRankId"
__PBTABLE__.GENREAWARDRANKSTATE_AWARDRANKID_FIELD.number = 1
__PBTABLE__.GENREAWARDRANKSTATE_AWARDRANKID_FIELD.index = 0
__PBTABLE__.GENREAWARDRANKSTATE_AWARDRANKID_FIELD.label = 1
__PBTABLE__.GENREAWARDRANKSTATE_AWARDRANKID_FIELD.has_default_value = false
__PBTABLE__.GENREAWARDRANKSTATE_AWARDRANKID_FIELD.default_value = 0
__PBTABLE__.GENREAWARDRANKSTATE_AWARDRANKID_FIELD.type = 5
__PBTABLE__.GENREAWARDRANKSTATE_AWARDRANKID_FIELD.cpp_type = 1

__PBTABLE__.GENREAWARDRANKSTATE_AWARDRANKSTATE_FIELD.name = "awardRankState"
__PBTABLE__.GENREAWARDRANKSTATE_AWARDRANKSTATE_FIELD.full_name = ".PB.GenreAwardRankState.awardRankState"
__PBTABLE__.GENREAWARDRANKSTATE_AWARDRANKSTATE_FIELD.number = 2
__PBTABLE__.GENREAWARDRANKSTATE_AWARDRANKSTATE_FIELD.index = 1
__PBTABLE__.GENREAWARDRANKSTATE_AWARDRANKSTATE_FIELD.label = 1
__PBTABLE__.GENREAWARDRANKSTATE_AWARDRANKSTATE_FIELD.has_default_value = false
__PBTABLE__.GENREAWARDRANKSTATE_AWARDRANKSTATE_FIELD.default_value = 0
__PBTABLE__.GENREAWARDRANKSTATE_AWARDRANKSTATE_FIELD.type = 5
__PBTABLE__.GENREAWARDRANKSTATE_AWARDRANKSTATE_FIELD.cpp_type = 1

GENREAWARDRANKSTATE.name = "GenreAwardRankState"
GENREAWARDRANKSTATE.full_name = ".PB.GenreAwardRankState"
GENREAWARDRANKSTATE.nested_types = {}
GENREAWARDRANKSTATE.enum_types = {}
GENREAWARDRANKSTATE.fields = {__PBTABLE__.GENREAWARDRANKSTATE_AWARDRANKID_FIELD, __PBTABLE__.GENREAWARDRANKSTATE_AWARDRANKSTATE_FIELD}
GENREAWARDRANKSTATE.is_extendable = false
GENREAWARDRANKSTATE.extensions = {}
__PBTABLE__.GENRESTATE_GENREID_FIELD.name = "genreId"
__PBTABLE__.GENRESTATE_GENREID_FIELD.full_name = ".PB.GenreState.genreId"
__PBTABLE__.GENRESTATE_GENREID_FIELD.number = 1
__PBTABLE__.GENRESTATE_GENREID_FIELD.index = 0
__PBTABLE__.GENRESTATE_GENREID_FIELD.label = 1
__PBTABLE__.GENRESTATE_GENREID_FIELD.has_default_value = false
__PBTABLE__.GENRESTATE_GENREID_FIELD.default_value = 0
__PBTABLE__.GENRESTATE_GENREID_FIELD.type = 5
__PBTABLE__.GENRESTATE_GENREID_FIELD.cpp_type = 1

__PBTABLE__.GENRESTATE_GENREAWARDRANKSTATE_FIELD.name = "genreAwardRankState"
__PBTABLE__.GENRESTATE_GENREAWARDRANKSTATE_FIELD.full_name = ".PB.GenreState.genreAwardRankState"
__PBTABLE__.GENRESTATE_GENREAWARDRANKSTATE_FIELD.number = 2
__PBTABLE__.GENRESTATE_GENREAWARDRANKSTATE_FIELD.index = 1
__PBTABLE__.GENRESTATE_GENREAWARDRANKSTATE_FIELD.label = 3
__PBTABLE__.GENRESTATE_GENREAWARDRANKSTATE_FIELD.has_default_value = false
__PBTABLE__.GENRESTATE_GENREAWARDRANKSTATE_FIELD.default_value = {}
__PBTABLE__.GENRESTATE_GENREAWARDRANKSTATE_FIELD.message_type = GENREAWARDRANKSTATE or GenreAwardRankState.GENREAWARDRANKSTATE
__PBTABLE__.GENRESTATE_GENREAWARDRANKSTATE_FIELD.type = 11
__PBTABLE__.GENRESTATE_GENREAWARDRANKSTATE_FIELD.cpp_type = 10

GENRESTATE.name = "GenreState"
GENRESTATE.full_name = ".PB.GenreState"
GENRESTATE.nested_types = {}
GENRESTATE.enum_types = {}
GENRESTATE.fields = {__PBTABLE__.GENRESTATE_GENREID_FIELD, __PBTABLE__.GENRESTATE_GENREAWARDRANKSTATE_FIELD}
GENRESTATE.is_extendable = false
GENRESTATE.extensions = {}
__PBTABLE__.GENREQUERYRESULTMESSAGE_ID_FIELD.name = "id"
__PBTABLE__.GENREQUERYRESULTMESSAGE_ID_FIELD.full_name = ".PB.GenreQueryResultMessage.id"
__PBTABLE__.GENREQUERYRESULTMESSAGE_ID_FIELD.number = 1
__PBTABLE__.GENREQUERYRESULTMESSAGE_ID_FIELD.index = 0
__PBTABLE__.GENREQUERYRESULTMESSAGE_ID_FIELD.label = 1
__PBTABLE__.GENREQUERYRESULTMESSAGE_ID_FIELD.has_default_value = true
__PBTABLE__.GENREQUERYRESULTMESSAGE_ID_FIELD.default_value = "SND_GENRE_QUERY_RESULT_MESSAGE"
__PBTABLE__.GENREQUERYRESULTMESSAGE_ID_FIELD.enum_type = PROTOCOLID or ProtocolId.PROTOCOLID
__PBTABLE__.GENREQUERYRESULTMESSAGE_ID_FIELD.type = 14
__PBTABLE__.GENREQUERYRESULTMESSAGE_ID_FIELD.cpp_type = 8

__PBTABLE__.GENREQUERYRESULTMESSAGE_HEAD_FIELD.name = "head"
__PBTABLE__.GENREQUERYRESULTMESSAGE_HEAD_FIELD.full_name = ".PB.GenreQueryResultMessage.head"
__PBTABLE__.GENREQUERYRESULTMESSAGE_HEAD_FIELD.number = 2
__PBTABLE__.GENREQUERYRESULTMESSAGE_HEAD_FIELD.index = 1
__PBTABLE__.GENREQUERYRESULTMESSAGE_HEAD_FIELD.label = 1
__PBTABLE__.GENREQUERYRESULTMESSAGE_HEAD_FIELD.has_default_value = false
__PBTABLE__.GENREQUERYRESULTMESSAGE_HEAD_FIELD.default_value = nil
__PBTABLE__.GENREQUERYRESULTMESSAGE_HEAD_FIELD.message_type = HEADMESSAGE or HeadMessage.HEADMESSAGE
__PBTABLE__.GENREQUERYRESULTMESSAGE_HEAD_FIELD.type = 11
__PBTABLE__.GENREQUERYRESULTMESSAGE_HEAD_FIELD.cpp_type = 10

__PBTABLE__.GENREQUERYRESULTMESSAGE_GENRESTATE_FIELD.name = "genreState"
__PBTABLE__.GENREQUERYRESULTMESSAGE_GENRESTATE_FIELD.full_name = ".PB.GenreQueryResultMessage.genreState"
__PBTABLE__.GENREQUERYRESULTMESSAGE_GENRESTATE_FIELD.number = 3
__PBTABLE__.GENREQUERYRESULTMESSAGE_GENRESTATE_FIELD.index = 2
__PBTABLE__.GENREQUERYRESULTMESSAGE_GENRESTATE_FIELD.label = 3
__PBTABLE__.GENREQUERYRESULTMESSAGE_GENRESTATE_FIELD.has_default_value = false
__PBTABLE__.GENREQUERYRESULTMESSAGE_GENRESTATE_FIELD.default_value = {}
__PBTABLE__.GENREQUERYRESULTMESSAGE_GENRESTATE_FIELD.message_type = GENRESTATE or GenreState.GENRESTATE
__PBTABLE__.GENREQUERYRESULTMESSAGE_GENRESTATE_FIELD.type = 11
__PBTABLE__.GENREQUERYRESULTMESSAGE_GENRESTATE_FIELD.cpp_type = 10

GENREQUERYRESULTMESSAGE.name = "GenreQueryResultMessage"
GENREQUERYRESULTMESSAGE.full_name = ".PB.GenreQueryResultMessage"
GENREQUERYRESULTMESSAGE.nested_types = {}
GENREQUERYRESULTMESSAGE.enum_types = {}
GENREQUERYRESULTMESSAGE.fields = {__PBTABLE__.GENREQUERYRESULTMESSAGE_ID_FIELD, __PBTABLE__.GENREQUERYRESULTMESSAGE_HEAD_FIELD, __PBTABLE__.GENREQUERYRESULTMESSAGE_GENRESTATE_FIELD}
GENREQUERYRESULTMESSAGE.is_extendable = false
GENREQUERYRESULTMESSAGE.extensions = {}

GenreAwardRankState = protobuf.Message(GENREAWARDRANKSTATE)
GenreQueryResultMessage = protobuf.Message(GENREQUERYRESULTMESSAGE)
GenreState = protobuf.Message(GENRESTATE)
