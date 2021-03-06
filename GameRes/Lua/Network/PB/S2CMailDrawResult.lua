-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf.protobuf"
local ProtocolId = require("Network.PB.ProtocolId")
local HeadMessage = require("Network.PB.HeadMessage")
module('Network.PB.S2CMailDrawResult')


local __PBTABLE__ = {}

local MAILAWARDITEM = protobuf.Descriptor();
_M.MAILAWARDITEM = MAILAWARDITEM

__PBTABLE__.MAILAWARDITEM_ITEMID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.MAILAWARDITEM_ITEMNUM_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.MAILAWARDITEM_ITEMCOLOR_FIELD = protobuf.FieldDescriptor();
local MAILDRAWRESULT = protobuf.Descriptor();
_M.MAILDRAWRESULT = MAILDRAWRESULT

__PBTABLE__.MAILDRAWRESULT_ID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.MAILDRAWRESULT_HEAD_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.MAILDRAWRESULT_MAILID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.MAILDRAWRESULT_AWARDS_FIELD = protobuf.FieldDescriptor();

__PBTABLE__.MAILAWARDITEM_ITEMID_FIELD.name = "itemID"
__PBTABLE__.MAILAWARDITEM_ITEMID_FIELD.full_name = ".PB.MailAwardItem.itemID"
__PBTABLE__.MAILAWARDITEM_ITEMID_FIELD.number = 1
__PBTABLE__.MAILAWARDITEM_ITEMID_FIELD.index = 0
__PBTABLE__.MAILAWARDITEM_ITEMID_FIELD.label = 1
__PBTABLE__.MAILAWARDITEM_ITEMID_FIELD.has_default_value = false
__PBTABLE__.MAILAWARDITEM_ITEMID_FIELD.default_value = 0
__PBTABLE__.MAILAWARDITEM_ITEMID_FIELD.type = 5
__PBTABLE__.MAILAWARDITEM_ITEMID_FIELD.cpp_type = 1

__PBTABLE__.MAILAWARDITEM_ITEMNUM_FIELD.name = "itemNum"
__PBTABLE__.MAILAWARDITEM_ITEMNUM_FIELD.full_name = ".PB.MailAwardItem.itemNum"
__PBTABLE__.MAILAWARDITEM_ITEMNUM_FIELD.number = 2
__PBTABLE__.MAILAWARDITEM_ITEMNUM_FIELD.index = 1
__PBTABLE__.MAILAWARDITEM_ITEMNUM_FIELD.label = 1
__PBTABLE__.MAILAWARDITEM_ITEMNUM_FIELD.has_default_value = false
__PBTABLE__.MAILAWARDITEM_ITEMNUM_FIELD.default_value = 0
__PBTABLE__.MAILAWARDITEM_ITEMNUM_FIELD.type = 5
__PBTABLE__.MAILAWARDITEM_ITEMNUM_FIELD.cpp_type = 1

__PBTABLE__.MAILAWARDITEM_ITEMCOLOR_FIELD.name = "itemColor"
__PBTABLE__.MAILAWARDITEM_ITEMCOLOR_FIELD.full_name = ".PB.MailAwardItem.itemColor"
__PBTABLE__.MAILAWARDITEM_ITEMCOLOR_FIELD.number = 3
__PBTABLE__.MAILAWARDITEM_ITEMCOLOR_FIELD.index = 2
__PBTABLE__.MAILAWARDITEM_ITEMCOLOR_FIELD.label = 1
__PBTABLE__.MAILAWARDITEM_ITEMCOLOR_FIELD.has_default_value = false
__PBTABLE__.MAILAWARDITEM_ITEMCOLOR_FIELD.default_value = 0
__PBTABLE__.MAILAWARDITEM_ITEMCOLOR_FIELD.type = 5
__PBTABLE__.MAILAWARDITEM_ITEMCOLOR_FIELD.cpp_type = 1

MAILAWARDITEM.name = "MailAwardItem"
MAILAWARDITEM.full_name = ".PB.MailAwardItem"
MAILAWARDITEM.nested_types = {}
MAILAWARDITEM.enum_types = {}
MAILAWARDITEM.fields = {__PBTABLE__.MAILAWARDITEM_ITEMID_FIELD, __PBTABLE__.MAILAWARDITEM_ITEMNUM_FIELD, __PBTABLE__.MAILAWARDITEM_ITEMCOLOR_FIELD}
MAILAWARDITEM.is_extendable = false
MAILAWARDITEM.extensions = {}
__PBTABLE__.MAILDRAWRESULT_ID_FIELD.name = "id"
__PBTABLE__.MAILDRAWRESULT_ID_FIELD.full_name = ".PB.MailDrawResult.id"
__PBTABLE__.MAILDRAWRESULT_ID_FIELD.number = 1
__PBTABLE__.MAILDRAWRESULT_ID_FIELD.index = 0
__PBTABLE__.MAILDRAWRESULT_ID_FIELD.label = 1
__PBTABLE__.MAILDRAWRESULT_ID_FIELD.has_default_value = true
__PBTABLE__.MAILDRAWRESULT_ID_FIELD.default_value = "SND_MAIL_MAIL_DRAW_RESULT_MESSAGE"
__PBTABLE__.MAILDRAWRESULT_ID_FIELD.enum_type = PROTOCOLID or ProtocolId.PROTOCOLID
__PBTABLE__.MAILDRAWRESULT_ID_FIELD.type = 14
__PBTABLE__.MAILDRAWRESULT_ID_FIELD.cpp_type = 8

__PBTABLE__.MAILDRAWRESULT_HEAD_FIELD.name = "head"
__PBTABLE__.MAILDRAWRESULT_HEAD_FIELD.full_name = ".PB.MailDrawResult.head"
__PBTABLE__.MAILDRAWRESULT_HEAD_FIELD.number = 2
__PBTABLE__.MAILDRAWRESULT_HEAD_FIELD.index = 1
__PBTABLE__.MAILDRAWRESULT_HEAD_FIELD.label = 1
__PBTABLE__.MAILDRAWRESULT_HEAD_FIELD.has_default_value = false
__PBTABLE__.MAILDRAWRESULT_HEAD_FIELD.default_value = nil
__PBTABLE__.MAILDRAWRESULT_HEAD_FIELD.message_type = HEADMESSAGE or HeadMessage.HEADMESSAGE
__PBTABLE__.MAILDRAWRESULT_HEAD_FIELD.type = 11
__PBTABLE__.MAILDRAWRESULT_HEAD_FIELD.cpp_type = 10

__PBTABLE__.MAILDRAWRESULT_MAILID_FIELD.name = "mailId"
__PBTABLE__.MAILDRAWRESULT_MAILID_FIELD.full_name = ".PB.MailDrawResult.mailId"
__PBTABLE__.MAILDRAWRESULT_MAILID_FIELD.number = 3
__PBTABLE__.MAILDRAWRESULT_MAILID_FIELD.index = 2
__PBTABLE__.MAILDRAWRESULT_MAILID_FIELD.label = 1
__PBTABLE__.MAILDRAWRESULT_MAILID_FIELD.has_default_value = false
__PBTABLE__.MAILDRAWRESULT_MAILID_FIELD.default_value = ""
__PBTABLE__.MAILDRAWRESULT_MAILID_FIELD.type = 9
__PBTABLE__.MAILDRAWRESULT_MAILID_FIELD.cpp_type = 9

__PBTABLE__.MAILDRAWRESULT_AWARDS_FIELD.name = "awards"
__PBTABLE__.MAILDRAWRESULT_AWARDS_FIELD.full_name = ".PB.MailDrawResult.awards"
__PBTABLE__.MAILDRAWRESULT_AWARDS_FIELD.number = 4
__PBTABLE__.MAILDRAWRESULT_AWARDS_FIELD.index = 3
__PBTABLE__.MAILDRAWRESULT_AWARDS_FIELD.label = 3
__PBTABLE__.MAILDRAWRESULT_AWARDS_FIELD.has_default_value = false
__PBTABLE__.MAILDRAWRESULT_AWARDS_FIELD.default_value = {}
__PBTABLE__.MAILDRAWRESULT_AWARDS_FIELD.message_type = MAILAWARDITEM or MailAwardItem.MAILAWARDITEM
__PBTABLE__.MAILDRAWRESULT_AWARDS_FIELD.type = 11
__PBTABLE__.MAILDRAWRESULT_AWARDS_FIELD.cpp_type = 10

MAILDRAWRESULT.name = "MailDrawResult"
MAILDRAWRESULT.full_name = ".PB.MailDrawResult"
MAILDRAWRESULT.nested_types = {}
MAILDRAWRESULT.enum_types = {}
MAILDRAWRESULT.fields = {__PBTABLE__.MAILDRAWRESULT_ID_FIELD, __PBTABLE__.MAILDRAWRESULT_HEAD_FIELD, __PBTABLE__.MAILDRAWRESULT_MAILID_FIELD, __PBTABLE__.MAILDRAWRESULT_AWARDS_FIELD}
MAILDRAWRESULT.is_extendable = false
MAILDRAWRESULT.extensions = {}

MailAwardItem = protobuf.Message(MAILAWARDITEM)
MailDrawResult = protobuf.Message(MAILDRAWRESULT)

