-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf.protobuf"
local ProtocolId = require("Network.PB.ProtocolId")
local HeadMessage = require("Network.PB.HeadMessage")
module('Network.PB.C2SShopQueryRequest')


local __PBTABLE__ = {}

local SHOPQUERYREQUEST = protobuf.Descriptor();
_M.SHOPQUERYREQUEST = SHOPQUERYREQUEST

__PBTABLE__.SHOPQUERYREQUEST_ID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.SHOPQUERYREQUEST_HEAD_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.SHOPQUERYREQUEST_TYPE_FIELD = protobuf.FieldDescriptor();

__PBTABLE__.SHOPQUERYREQUEST_ID_FIELD.name = "id"
__PBTABLE__.SHOPQUERYREQUEST_ID_FIELD.full_name = ".PB.ShopQueryRequest.id"
__PBTABLE__.SHOPQUERYREQUEST_ID_FIELD.number = 1
__PBTABLE__.SHOPQUERYREQUEST_ID_FIELD.index = 0
__PBTABLE__.SHOPQUERYREQUEST_ID_FIELD.label = 1
__PBTABLE__.SHOPQUERYREQUEST_ID_FIELD.has_default_value = true
__PBTABLE__.SHOPQUERYREQUEST_ID_FIELD.default_value = "ACT_SHOP_SHOP_QUERY_REQUEST_MESSAGE"
__PBTABLE__.SHOPQUERYREQUEST_ID_FIELD.enum_type = PROTOCOLID or ProtocolId.PROTOCOLID
__PBTABLE__.SHOPQUERYREQUEST_ID_FIELD.type = 14
__PBTABLE__.SHOPQUERYREQUEST_ID_FIELD.cpp_type = 8

__PBTABLE__.SHOPQUERYREQUEST_HEAD_FIELD.name = "head"
__PBTABLE__.SHOPQUERYREQUEST_HEAD_FIELD.full_name = ".PB.ShopQueryRequest.head"
__PBTABLE__.SHOPQUERYREQUEST_HEAD_FIELD.number = 2
__PBTABLE__.SHOPQUERYREQUEST_HEAD_FIELD.index = 1
__PBTABLE__.SHOPQUERYREQUEST_HEAD_FIELD.label = 1
__PBTABLE__.SHOPQUERYREQUEST_HEAD_FIELD.has_default_value = false
__PBTABLE__.SHOPQUERYREQUEST_HEAD_FIELD.default_value = nil
__PBTABLE__.SHOPQUERYREQUEST_HEAD_FIELD.message_type = HEADMESSAGE or HeadMessage.HEADMESSAGE
__PBTABLE__.SHOPQUERYREQUEST_HEAD_FIELD.type = 11
__PBTABLE__.SHOPQUERYREQUEST_HEAD_FIELD.cpp_type = 10

__PBTABLE__.SHOPQUERYREQUEST_TYPE_FIELD.name = "type"
__PBTABLE__.SHOPQUERYREQUEST_TYPE_FIELD.full_name = ".PB.ShopQueryRequest.type"
__PBTABLE__.SHOPQUERYREQUEST_TYPE_FIELD.number = 3
__PBTABLE__.SHOPQUERYREQUEST_TYPE_FIELD.index = 2
__PBTABLE__.SHOPQUERYREQUEST_TYPE_FIELD.label = 1
__PBTABLE__.SHOPQUERYREQUEST_TYPE_FIELD.has_default_value = false
__PBTABLE__.SHOPQUERYREQUEST_TYPE_FIELD.default_value = 0
__PBTABLE__.SHOPQUERYREQUEST_TYPE_FIELD.type = 5
__PBTABLE__.SHOPQUERYREQUEST_TYPE_FIELD.cpp_type = 1

SHOPQUERYREQUEST.name = "ShopQueryRequest"
SHOPQUERYREQUEST.full_name = ".PB.ShopQueryRequest"
SHOPQUERYREQUEST.nested_types = {}
SHOPQUERYREQUEST.enum_types = {}
SHOPQUERYREQUEST.fields = {__PBTABLE__.SHOPQUERYREQUEST_ID_FIELD, __PBTABLE__.SHOPQUERYREQUEST_HEAD_FIELD, __PBTABLE__.SHOPQUERYREQUEST_TYPE_FIELD}
SHOPQUERYREQUEST.is_extendable = false
SHOPQUERYREQUEST.extensions = {}

ShopQueryRequest = protobuf.Message(SHOPQUERYREQUEST)

