-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf.protobuf"
local ProtocolId = require("Network.PB.ProtocolId")
local HeadMessage = require("Network.PB.HeadMessage")
module('Network.PB.S2CActivitySevenDayHappyResult')


local __PBTABLE__ = {}

local CONSUMEACTIVITY = protobuf.Descriptor();
_M.CONSUMEACTIVITY = CONSUMEACTIVITY

__PBTABLE__.CONSUMEACTIVITY_ID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.CONSUMEACTIVITY_STATUS_FIELD = protobuf.FieldDescriptor();
local ACTIVITYSEVENDAYHAPPYRESULTMESSAGE = protobuf.Descriptor();
_M.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE = ACTIVITYSEVENDAYHAPPYRESULTMESSAGE

__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_ID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_HEAD_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_SEVENDAY_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_SEVENDAYLIBAO_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_SEVENDAYPROGRESS_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_DAY_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_COUNTDOWN_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_PROGRES_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_HID_FIELD = protobuf.FieldDescriptor();

__PBTABLE__.CONSUMEACTIVITY_ID_FIELD.name = "id"
__PBTABLE__.CONSUMEACTIVITY_ID_FIELD.full_name = ".PB.ConsumeActivity.id"
__PBTABLE__.CONSUMEACTIVITY_ID_FIELD.number = 1
__PBTABLE__.CONSUMEACTIVITY_ID_FIELD.index = 0
__PBTABLE__.CONSUMEACTIVITY_ID_FIELD.label = 1
__PBTABLE__.CONSUMEACTIVITY_ID_FIELD.has_default_value = false
__PBTABLE__.CONSUMEACTIVITY_ID_FIELD.default_value = 0
__PBTABLE__.CONSUMEACTIVITY_ID_FIELD.type = 5
__PBTABLE__.CONSUMEACTIVITY_ID_FIELD.cpp_type = 1

__PBTABLE__.CONSUMEACTIVITY_STATUS_FIELD.name = "status"
__PBTABLE__.CONSUMEACTIVITY_STATUS_FIELD.full_name = ".PB.ConsumeActivity.status"
__PBTABLE__.CONSUMEACTIVITY_STATUS_FIELD.number = 2
__PBTABLE__.CONSUMEACTIVITY_STATUS_FIELD.index = 1
__PBTABLE__.CONSUMEACTIVITY_STATUS_FIELD.label = 1
__PBTABLE__.CONSUMEACTIVITY_STATUS_FIELD.has_default_value = false
__PBTABLE__.CONSUMEACTIVITY_STATUS_FIELD.default_value = 0
__PBTABLE__.CONSUMEACTIVITY_STATUS_FIELD.type = 5
__PBTABLE__.CONSUMEACTIVITY_STATUS_FIELD.cpp_type = 1

CONSUMEACTIVITY.name = "ConsumeActivity"
CONSUMEACTIVITY.full_name = ".PB.ConsumeActivity"
CONSUMEACTIVITY.nested_types = {}
CONSUMEACTIVITY.enum_types = {}
CONSUMEACTIVITY.fields = {__PBTABLE__.CONSUMEACTIVITY_ID_FIELD, __PBTABLE__.CONSUMEACTIVITY_STATUS_FIELD}
CONSUMEACTIVITY.is_extendable = false
CONSUMEACTIVITY.extensions = {}
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_ID_FIELD.name = "id"
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_ID_FIELD.full_name = ".PB.ActivitySevenDayHappyResultMessage.id"
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_ID_FIELD.number = 1
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_ID_FIELD.index = 0
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_ID_FIELD.label = 1
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_ID_FIELD.has_default_value = true
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_ID_FIELD.default_value = "SND_HUODONG_SEVENDAY_QUERY_RESULT_MESSAGE"
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_ID_FIELD.enum_type = PROTOCOLID or ProtocolId.PROTOCOLID
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_ID_FIELD.type = 14
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_ID_FIELD.cpp_type = 8

__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_HEAD_FIELD.name = "head"
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_HEAD_FIELD.full_name = ".PB.ActivitySevenDayHappyResultMessage.head"
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_HEAD_FIELD.number = 2
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_HEAD_FIELD.index = 1
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_HEAD_FIELD.label = 1
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_HEAD_FIELD.has_default_value = false
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_HEAD_FIELD.default_value = nil
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_HEAD_FIELD.message_type = HEADMESSAGE or HeadMessage.HEADMESSAGE
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_HEAD_FIELD.type = 11
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_HEAD_FIELD.cpp_type = 10

__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_SEVENDAY_FIELD.name = "sevenDay"
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_SEVENDAY_FIELD.full_name = ".PB.ActivitySevenDayHappyResultMessage.sevenDay"
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_SEVENDAY_FIELD.number = 3
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_SEVENDAY_FIELD.index = 2
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_SEVENDAY_FIELD.label = 3
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_SEVENDAY_FIELD.has_default_value = false
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_SEVENDAY_FIELD.default_value = {}
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_SEVENDAY_FIELD.message_type = CONSUMEACTIVITY or ConsumeActivity.CONSUMEACTIVITY
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_SEVENDAY_FIELD.type = 11
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_SEVENDAY_FIELD.cpp_type = 10

__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_SEVENDAYLIBAO_FIELD.name = "sevenDayLiBao"
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_SEVENDAYLIBAO_FIELD.full_name = ".PB.ActivitySevenDayHappyResultMessage.sevenDayLiBao"
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_SEVENDAYLIBAO_FIELD.number = 4
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_SEVENDAYLIBAO_FIELD.index = 3
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_SEVENDAYLIBAO_FIELD.label = 3
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_SEVENDAYLIBAO_FIELD.has_default_value = false
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_SEVENDAYLIBAO_FIELD.default_value = {}
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_SEVENDAYLIBAO_FIELD.message_type = CONSUMEACTIVITY or ConsumeActivity.CONSUMEACTIVITY
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_SEVENDAYLIBAO_FIELD.type = 11
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_SEVENDAYLIBAO_FIELD.cpp_type = 10

__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_SEVENDAYPROGRESS_FIELD.name = "sevenDayProgress"
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_SEVENDAYPROGRESS_FIELD.full_name = ".PB.ActivitySevenDayHappyResultMessage.sevenDayProgress"
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_SEVENDAYPROGRESS_FIELD.number = 5
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_SEVENDAYPROGRESS_FIELD.index = 4
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_SEVENDAYPROGRESS_FIELD.label = 3
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_SEVENDAYPROGRESS_FIELD.has_default_value = false
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_SEVENDAYPROGRESS_FIELD.default_value = {}
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_SEVENDAYPROGRESS_FIELD.message_type = CONSUMEACTIVITY or ConsumeActivity.CONSUMEACTIVITY
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_SEVENDAYPROGRESS_FIELD.type = 11
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_SEVENDAYPROGRESS_FIELD.cpp_type = 10

__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_DAY_FIELD.name = "day"
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_DAY_FIELD.full_name = ".PB.ActivitySevenDayHappyResultMessage.day"
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_DAY_FIELD.number = 6
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_DAY_FIELD.index = 5
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_DAY_FIELD.label = 1
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_DAY_FIELD.has_default_value = false
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_DAY_FIELD.default_value = 0
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_DAY_FIELD.type = 5
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_DAY_FIELD.cpp_type = 1

__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_COUNTDOWN_FIELD.name = "countDown"
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_COUNTDOWN_FIELD.full_name = ".PB.ActivitySevenDayHappyResultMessage.countDown"
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_COUNTDOWN_FIELD.number = 7
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_COUNTDOWN_FIELD.index = 6
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_COUNTDOWN_FIELD.label = 1
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_COUNTDOWN_FIELD.has_default_value = false
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_COUNTDOWN_FIELD.default_value = 0
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_COUNTDOWN_FIELD.type = 5
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_COUNTDOWN_FIELD.cpp_type = 1

__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_PROGRES_FIELD.name = "progres"
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_PROGRES_FIELD.full_name = ".PB.ActivitySevenDayHappyResultMessage.progres"
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_PROGRES_FIELD.number = 8
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_PROGRES_FIELD.index = 7
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_PROGRES_FIELD.label = 1
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_PROGRES_FIELD.has_default_value = false
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_PROGRES_FIELD.default_value = 0
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_PROGRES_FIELD.type = 5
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_PROGRES_FIELD.cpp_type = 1

__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_HID_FIELD.name = "hid"
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_HID_FIELD.full_name = ".PB.ActivitySevenDayHappyResultMessage.hid"
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_HID_FIELD.number = 9
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_HID_FIELD.index = 8
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_HID_FIELD.label = 1
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_HID_FIELD.has_default_value = false
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_HID_FIELD.default_value = 0
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_HID_FIELD.type = 5
__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_HID_FIELD.cpp_type = 1

ACTIVITYSEVENDAYHAPPYRESULTMESSAGE.name = "ActivitySevenDayHappyResultMessage"
ACTIVITYSEVENDAYHAPPYRESULTMESSAGE.full_name = ".PB.ActivitySevenDayHappyResultMessage"
ACTIVITYSEVENDAYHAPPYRESULTMESSAGE.nested_types = {}
ACTIVITYSEVENDAYHAPPYRESULTMESSAGE.enum_types = {}
ACTIVITYSEVENDAYHAPPYRESULTMESSAGE.fields = {__PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_ID_FIELD, __PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_HEAD_FIELD, __PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_SEVENDAY_FIELD, __PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_SEVENDAYLIBAO_FIELD, __PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_SEVENDAYPROGRESS_FIELD, __PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_DAY_FIELD, __PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_COUNTDOWN_FIELD, __PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_PROGRES_FIELD, __PBTABLE__.ACTIVITYSEVENDAYHAPPYRESULTMESSAGE_HID_FIELD}
ACTIVITYSEVENDAYHAPPYRESULTMESSAGE.is_extendable = false
ACTIVITYSEVENDAYHAPPYRESULTMESSAGE.extensions = {}

ActivitySevenDayHappyResultMessage = protobuf.Message(ACTIVITYSEVENDAYHAPPYRESULTMESSAGE)
ConsumeActivity = protobuf.Message(CONSUMEACTIVITY)

