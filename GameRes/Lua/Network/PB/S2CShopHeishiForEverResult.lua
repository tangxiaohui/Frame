-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf.protobuf"
local ProtocolId = require("Network.PB.ProtocolId")
local HeadMessage = require("Network.PB.HeadMessage")
module('Network.PB.S2CShopHeishiForEverResult')


local __PBTABLE__ = {}

local SHOPHEISHIFOREVERRESULT = protobuf.Descriptor();
_M.SHOPHEISHIFOREVERRESULT = SHOPHEISHIFOREVERRESULT

__PBTABLE__.SHOPHEISHIFOREVERRESULT_ID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.SHOPHEISHIFOREVERRESULT_HEAD_FIELD = protobuf.FieldDescriptor();

__PBTABLE__.SHOPHEISHIFOREVERRESULT_ID_FIELD.name = "id"
__PBTABLE__.SHOPHEISHIFOREVERRESULT_ID_FIELD.full_name = ".PB.ShopHeishiForEverResult.id"
__PBTABLE__.SHOPHEISHIFOREVERRESULT_ID_FIELD.number = 1
__PBTABLE__.SHOPHEISHIFOREVERRESULT_ID_FIELD.index = 0
__PBTABLE__.SHOPHEISHIFOREVERRESULT_ID_FIELD.label = 1
__PBTABLE__.SHOPHEISHIFOREVERRESULT_ID_FIELD.has_default_value = true
__PBTABLE__.SHOPHEISHIFOREVERRESULT_ID_FIELD.default_value = "SND_SHOP_SHOP_HEISHI_FOR_EVER_RESULT_MESSAGE"
__PBTABLE__.SHOPHEISHIFOREVERRESULT_ID_FIELD.enum_type = PROTOCOLID or ProtocolId.PROTOCOLID
__PBTABLE__.SHOPHEISHIFOREVERRESULT_ID_FIELD.type = 14
__PBTABLE__.SHOPHEISHIFOREVERRESULT_ID_FIELD.cpp_type = 8

__PBTABLE__.SHOPHEISHIFOREVERRESULT_HEAD_FIELD.name = "head"
__PBTABLE__.SHOPHEISHIFOREVERRESULT_HEAD_FIELD.full_name = ".PB.ShopHeishiForEverResult.head"
__PBTABLE__.SHOPHEISHIFOREVERRESULT_HEAD_FIELD.number = 2
__PBTABLE__.SHOPHEISHIFOREVERRESULT_HEAD_FIELD.index = 1
__PBTABLE__.SHOPHEISHIFOREVERRESULT_HEAD_FIELD.label = 1
__PBTABLE__.SHOPHEISHIFOREVERRESULT_HEAD_FIELD.has_default_value = false
__PBTABLE__.SHOPHEISHIFOREVERRESULT_HEAD_FIELD.default_value = nil
__PBTABLE__.SHOPHEISHIFOREVERRESULT_HEAD_FIELD.message_type = HEADMESSAGE or HeadMessage.HEADMESSAGE
__PBTABLE__.SHOPHEISHIFOREVERRESULT_HEAD_FIELD.type = 11
__PBTABLE__.SHOPHEISHIFOREVERRESULT_HEAD_FIELD.cpp_type = 10

SHOPHEISHIFOREVERRESULT.name = "ShopHeishiForEverResult"
SHOPHEISHIFOREVERRESULT.full_name = ".PB.ShopHeishiForEverResult"
SHOPHEISHIFOREVERRESULT.nested_types = {}
SHOPHEISHIFOREVERRESULT.enum_types = {}
SHOPHEISHIFOREVERRESULT.fields = {__PBTABLE__.SHOPHEISHIFOREVERRESULT_ID_FIELD, __PBTABLE__.SHOPHEISHIFOREVERRESULT_HEAD_FIELD}
SHOPHEISHIFOREVERRESULT.is_extendable = false
SHOPHEISHIFOREVERRESULT.extensions = {}

ShopHeishiForEverResult = protobuf.Message(SHOPHEISHIFOREVERRESULT)
