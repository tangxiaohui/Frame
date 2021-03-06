-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf.protobuf"
local ProtocolId = require("Network.PB.ProtocolId")
local HeadMessage = require("Network.PB.HeadMessage")
module('Network.PB.S2CZhaoCaiCatActivityQueryResult')


local __PBTABLE__ = {}

local ZHAOCAICATACTIVITYQUERYRESULTMESSAGE = protobuf.Descriptor();
_M.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE = ZHAOCAICATACTIVITYQUERYRESULTMESSAGE

__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_ID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_HEAD_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_ZHAOCAICATID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_ACTIVITYSURPLUSTIME_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_CUMULATIVEGETDIAMONDS_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_CUMULATIVECONSUMEDIAMONDS_FIELD = protobuf.FieldDescriptor();

__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_ID_FIELD.name = "id"
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_ID_FIELD.full_name = ".PB.ZhaoCaiCatActivityQueryResultMessage.id"
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_ID_FIELD.number = 1
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_ID_FIELD.index = 0
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_ID_FIELD.label = 1
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_ID_FIELD.has_default_value = true
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_ID_FIELD.default_value = "SND_HUODONG_ZHAOCAICAT_ACTIVITY_QUERY_RESULT_MESSAGE"
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_ID_FIELD.enum_type = PROTOCOLID or ProtocolId.PROTOCOLID
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_ID_FIELD.type = 14
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_ID_FIELD.cpp_type = 8

__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_HEAD_FIELD.name = "head"
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_HEAD_FIELD.full_name = ".PB.ZhaoCaiCatActivityQueryResultMessage.head"
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_HEAD_FIELD.number = 2
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_HEAD_FIELD.index = 1
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_HEAD_FIELD.label = 1
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_HEAD_FIELD.has_default_value = false
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_HEAD_FIELD.default_value = nil
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_HEAD_FIELD.message_type = HEADMESSAGE or HeadMessage.HEADMESSAGE
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_HEAD_FIELD.type = 11
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_HEAD_FIELD.cpp_type = 10

__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_ZHAOCAICATID_FIELD.name = "zhaoCaiCatID"
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_ZHAOCAICATID_FIELD.full_name = ".PB.ZhaoCaiCatActivityQueryResultMessage.zhaoCaiCatID"
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_ZHAOCAICATID_FIELD.number = 3
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_ZHAOCAICATID_FIELD.index = 2
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_ZHAOCAICATID_FIELD.label = 1
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_ZHAOCAICATID_FIELD.has_default_value = false
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_ZHAOCAICATID_FIELD.default_value = 0
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_ZHAOCAICATID_FIELD.type = 5
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_ZHAOCAICATID_FIELD.cpp_type = 1

__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_ACTIVITYSURPLUSTIME_FIELD.name = "activitySurplusTime"
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_ACTIVITYSURPLUSTIME_FIELD.full_name = ".PB.ZhaoCaiCatActivityQueryResultMessage.activitySurplusTime"
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_ACTIVITYSURPLUSTIME_FIELD.number = 4
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_ACTIVITYSURPLUSTIME_FIELD.index = 3
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_ACTIVITYSURPLUSTIME_FIELD.label = 1
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_ACTIVITYSURPLUSTIME_FIELD.has_default_value = false
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_ACTIVITYSURPLUSTIME_FIELD.default_value = 0
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_ACTIVITYSURPLUSTIME_FIELD.type = 3
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_ACTIVITYSURPLUSTIME_FIELD.cpp_type = 2

__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_CUMULATIVEGETDIAMONDS_FIELD.name = "cumulativeGetDiamonds"
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_CUMULATIVEGETDIAMONDS_FIELD.full_name = ".PB.ZhaoCaiCatActivityQueryResultMessage.cumulativeGetDiamonds"
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_CUMULATIVEGETDIAMONDS_FIELD.number = 5
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_CUMULATIVEGETDIAMONDS_FIELD.index = 4
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_CUMULATIVEGETDIAMONDS_FIELD.label = 1
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_CUMULATIVEGETDIAMONDS_FIELD.has_default_value = false
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_CUMULATIVEGETDIAMONDS_FIELD.default_value = 0
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_CUMULATIVEGETDIAMONDS_FIELD.type = 5
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_CUMULATIVEGETDIAMONDS_FIELD.cpp_type = 1

__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_CUMULATIVECONSUMEDIAMONDS_FIELD.name = "cumulativeConsumeDiamonds"
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_CUMULATIVECONSUMEDIAMONDS_FIELD.full_name = ".PB.ZhaoCaiCatActivityQueryResultMessage.cumulativeConsumeDiamonds"
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_CUMULATIVECONSUMEDIAMONDS_FIELD.number = 6
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_CUMULATIVECONSUMEDIAMONDS_FIELD.index = 5
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_CUMULATIVECONSUMEDIAMONDS_FIELD.label = 1
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_CUMULATIVECONSUMEDIAMONDS_FIELD.has_default_value = false
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_CUMULATIVECONSUMEDIAMONDS_FIELD.default_value = 0
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_CUMULATIVECONSUMEDIAMONDS_FIELD.type = 5
__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_CUMULATIVECONSUMEDIAMONDS_FIELD.cpp_type = 1

ZHAOCAICATACTIVITYQUERYRESULTMESSAGE.name = "ZhaoCaiCatActivityQueryResultMessage"
ZHAOCAICATACTIVITYQUERYRESULTMESSAGE.full_name = ".PB.ZhaoCaiCatActivityQueryResultMessage"
ZHAOCAICATACTIVITYQUERYRESULTMESSAGE.nested_types = {}
ZHAOCAICATACTIVITYQUERYRESULTMESSAGE.enum_types = {}
ZHAOCAICATACTIVITYQUERYRESULTMESSAGE.fields = {__PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_ID_FIELD, __PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_HEAD_FIELD, __PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_ZHAOCAICATID_FIELD, __PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_ACTIVITYSURPLUSTIME_FIELD, __PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_CUMULATIVEGETDIAMONDS_FIELD, __PBTABLE__.ZHAOCAICATACTIVITYQUERYRESULTMESSAGE_CUMULATIVECONSUMEDIAMONDS_FIELD}
ZHAOCAICATACTIVITYQUERYRESULTMESSAGE.is_extendable = false
ZHAOCAICATACTIVITYQUERYRESULTMESSAGE.extensions = {}

ZhaoCaiCatActivityQueryResultMessage = protobuf.Message(ZHAOCAICATACTIVITYQUERYRESULTMESSAGE)

