-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf.protobuf"
local ProtocolId = require("Network.PB.ProtocolId")
local HeadMessage = require("Network.PB.HeadMessage")
module('Network.PB.C2SShopHeishiForEverRequest')


local __PBTABLE__ = {}

local SHOPHEISHIFOREVERREQUEST = protobuf.Descriptor();
_M.SHOPHEISHIFOREVERREQUEST = SHOPHEISHIFOREVERREQUEST

__PBTABLE__.SHOPHEISHIFOREVERREQUEST_ID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.SHOPHEISHIFOREVERREQUEST_HEAD_FIELD = protobuf.FieldDescriptor();

__PBTABLE__.SHOPHEISHIFOREVERREQUEST_ID_FIELD.name = "id"
__PBTABLE__.SHOPHEISHIFOREVERREQUEST_ID_FIELD.full_name = ".PB.ShopHeishiForEverRequest.id"
__PBTABLE__.SHOPHEISHIFOREVERREQUEST_ID_FIELD.number = 1
__PBTABLE__.SHOPHEISHIFOREVERREQUEST_ID_FIELD.index = 0
__PBTABLE__.SHOPHEISHIFOREVERREQUEST_ID_FIELD.label = 1
__PBTABLE__.SHOPHEISHIFOREVERREQUEST_ID_FIELD.has_default_value = true
__PBTABLE__.SHOPHEISHIFOREVERREQUEST_ID_FIELD.default_value = "ACT_SHOP_SHOP_HEISHI_FOR_EVER_REQUEST_MESSAGE"
__PBTABLE__.SHOPHEISHIFOREVERREQUEST_ID_FIELD.enum_type = PROTOCOLID or ProtocolId.PROTOCOLID
__PBTABLE__.SHOPHEISHIFOREVERREQUEST_ID_FIELD.type = 14
__PBTABLE__.SHOPHEISHIFOREVERREQUEST_ID_FIELD.cpp_type = 8

__PBTABLE__.SHOPHEISHIFOREVERREQUEST_HEAD_FIELD.name = "head"
__PBTABLE__.SHOPHEISHIFOREVERREQUEST_HEAD_FIELD.full_name = ".PB.ShopHeishiForEverRequest.head"
__PBTABLE__.SHOPHEISHIFOREVERREQUEST_HEAD_FIELD.number = 2
__PBTABLE__.SHOPHEISHIFOREVERREQUEST_HEAD_FIELD.index = 1
__PBTABLE__.SHOPHEISHIFOREVERREQUEST_HEAD_FIELD.label = 1
__PBTABLE__.SHOPHEISHIFOREVERREQUEST_HEAD_FIELD.has_default_value = false
__PBTABLE__.SHOPHEISHIFOREVERREQUEST_HEAD_FIELD.default_value = nil
__PBTABLE__.SHOPHEISHIFOREVERREQUEST_HEAD_FIELD.message_type = HEADMESSAGE or HeadMessage.HEADMESSAGE
__PBTABLE__.SHOPHEISHIFOREVERREQUEST_HEAD_FIELD.type = 11
__PBTABLE__.SHOPHEISHIFOREVERREQUEST_HEAD_FIELD.cpp_type = 10

SHOPHEISHIFOREVERREQUEST.name = "ShopHeishiForEverRequest"
SHOPHEISHIFOREVERREQUEST.full_name = ".PB.ShopHeishiForEverRequest"
SHOPHEISHIFOREVERREQUEST.nested_types = {}
SHOPHEISHIFOREVERREQUEST.enum_types = {}
SHOPHEISHIFOREVERREQUEST.fields = {__PBTABLE__.SHOPHEISHIFOREVERREQUEST_ID_FIELD, __PBTABLE__.SHOPHEISHIFOREVERREQUEST_HEAD_FIELD}
SHOPHEISHIFOREVERREQUEST.is_extendable = false
SHOPHEISHIFOREVERREQUEST.extensions = {}

ShopHeishiForEverRequest = protobuf.Message(SHOPHEISHIFOREVERREQUEST)

