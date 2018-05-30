-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf.protobuf"
local ProtocolId = require("Network.PB.ProtocolId")
local HeadMessage = require("Network.PB.HeadMessage")
module('Network.PB.S2CVipDiamondBuyCoinQueryResult')


local __PBTABLE__ = {}

local VIPDIAMONDBUYCOINQUERYRESULT = protobuf.Descriptor();
_M.VIPDIAMONDBUYCOINQUERYRESULT = VIPDIAMONDBUYCOINQUERYRESULT

__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_ID_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_HEAD_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_SURPLUSBUYDONE_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_CURBUYNEEDDIAMONDS_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_CURATLEASTGETCOIN_FIELD = protobuf.FieldDescriptor();
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_CURBUYGETCOINNUMS_FIELD = protobuf.FieldDescriptor();

__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_ID_FIELD.name = "id"
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_ID_FIELD.full_name = ".PB.VipDiamondBuyCoinQueryResult.id"
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_ID_FIELD.number = 1
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_ID_FIELD.index = 0
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_ID_FIELD.label = 1
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_ID_FIELD.has_default_value = true
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_ID_FIELD.default_value = "SND_VIP_DIAMOND_BUY_COIN_QUERY_RESULT"
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_ID_FIELD.enum_type = PROTOCOLID or ProtocolId.PROTOCOLID
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_ID_FIELD.type = 14
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_ID_FIELD.cpp_type = 8

__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_HEAD_FIELD.name = "head"
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_HEAD_FIELD.full_name = ".PB.VipDiamondBuyCoinQueryResult.head"
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_HEAD_FIELD.number = 2
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_HEAD_FIELD.index = 1
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_HEAD_FIELD.label = 1
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_HEAD_FIELD.has_default_value = false
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_HEAD_FIELD.default_value = nil
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_HEAD_FIELD.message_type = HEADMESSAGE or HeadMessage.HEADMESSAGE
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_HEAD_FIELD.type = 11
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_HEAD_FIELD.cpp_type = 10

__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_SURPLUSBUYDONE_FIELD.name = "surplusBuyDone"
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_SURPLUSBUYDONE_FIELD.full_name = ".PB.VipDiamondBuyCoinQueryResult.surplusBuyDone"
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_SURPLUSBUYDONE_FIELD.number = 3
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_SURPLUSBUYDONE_FIELD.index = 2
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_SURPLUSBUYDONE_FIELD.label = 1
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_SURPLUSBUYDONE_FIELD.has_default_value = false
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_SURPLUSBUYDONE_FIELD.default_value = 0
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_SURPLUSBUYDONE_FIELD.type = 5
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_SURPLUSBUYDONE_FIELD.cpp_type = 1

__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_CURBUYNEEDDIAMONDS_FIELD.name = "curBuyNeedDiamonds"
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_CURBUYNEEDDIAMONDS_FIELD.full_name = ".PB.VipDiamondBuyCoinQueryResult.curBuyNeedDiamonds"
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_CURBUYNEEDDIAMONDS_FIELD.number = 4
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_CURBUYNEEDDIAMONDS_FIELD.index = 3
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_CURBUYNEEDDIAMONDS_FIELD.label = 1
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_CURBUYNEEDDIAMONDS_FIELD.has_default_value = false
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_CURBUYNEEDDIAMONDS_FIELD.default_value = 0
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_CURBUYNEEDDIAMONDS_FIELD.type = 5
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_CURBUYNEEDDIAMONDS_FIELD.cpp_type = 1

__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_CURATLEASTGETCOIN_FIELD.name = "curAtleastGetCoin"
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_CURATLEASTGETCOIN_FIELD.full_name = ".PB.VipDiamondBuyCoinQueryResult.curAtleastGetCoin"
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_CURATLEASTGETCOIN_FIELD.number = 5
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_CURATLEASTGETCOIN_FIELD.index = 4
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_CURATLEASTGETCOIN_FIELD.label = 1
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_CURATLEASTGETCOIN_FIELD.has_default_value = false
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_CURATLEASTGETCOIN_FIELD.default_value = 0
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_CURATLEASTGETCOIN_FIELD.type = 5
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_CURATLEASTGETCOIN_FIELD.cpp_type = 1

__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_CURBUYGETCOINNUMS_FIELD.name = "curBuyGetCoinNums"
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_CURBUYGETCOINNUMS_FIELD.full_name = ".PB.VipDiamondBuyCoinQueryResult.curBuyGetCoinNums"
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_CURBUYGETCOINNUMS_FIELD.number = 6
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_CURBUYGETCOINNUMS_FIELD.index = 5
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_CURBUYGETCOINNUMS_FIELD.label = 1
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_CURBUYGETCOINNUMS_FIELD.has_default_value = false
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_CURBUYGETCOINNUMS_FIELD.default_value = 0
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_CURBUYGETCOINNUMS_FIELD.type = 5
__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_CURBUYGETCOINNUMS_FIELD.cpp_type = 1

VIPDIAMONDBUYCOINQUERYRESULT.name = "VipDiamondBuyCoinQueryResult"
VIPDIAMONDBUYCOINQUERYRESULT.full_name = ".PB.VipDiamondBuyCoinQueryResult"
VIPDIAMONDBUYCOINQUERYRESULT.nested_types = {}
VIPDIAMONDBUYCOINQUERYRESULT.enum_types = {}
VIPDIAMONDBUYCOINQUERYRESULT.fields = {__PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_ID_FIELD, __PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_HEAD_FIELD, __PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_SURPLUSBUYDONE_FIELD, __PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_CURBUYNEEDDIAMONDS_FIELD, __PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_CURATLEASTGETCOIN_FIELD, __PBTABLE__.VIPDIAMONDBUYCOINQUERYRESULT_CURBUYGETCOINNUMS_FIELD}
VIPDIAMONDBUYCOINQUERYRESULT.is_extendable = false
VIPDIAMONDBUYCOINQUERYRESULT.extensions = {}

VipDiamondBuyCoinQueryResult = protobuf.Message(VIPDIAMONDBUYCOINQUERYRESULT)
