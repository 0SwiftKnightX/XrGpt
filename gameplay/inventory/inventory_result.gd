class_name XRGptInventoryResult
extends RefCounted

const OK := "OK"
const INVALID_ITEM := "INVALID_ITEM"
const INVALID_CONTAINER := "INVALID_CONTAINER"
const ITEM_NOT_FOUND := "ITEM_NOT_FOUND"
const CAPACITY_FULL := "CAPACITY_FULL"
const INVALID_QUANTITY := "INVALID_QUANTITY"
const CATEGORY_REJECTED := "CATEGORY_REJECTED"
const CAPABILITY_MISSING := "CAPABILITY_MISSING"
const EQUIPMENT_REJECTED := "EQUIPMENT_REJECTED"
const SAME_LOCATION := "SAME_LOCATION"

var success: bool = false
var code: String = INVALID_ITEM
var message_key: String = ""
var item: XRGptItemInstance
var affected_container_id: String = ""

static func success_result(affected: XRGptItemInstance = null, container_id: String = "") -> XRGptInventoryResult:
	var result := XRGptInventoryResult.new()
	result.success = true
	result.code = OK
	result.item = affected
	result.affected_container_id = container_id
	return result

static func failure(result_code: String, key: String = "") -> XRGptInventoryResult:
	var result := XRGptInventoryResult.new()
	result.success = false
	result.code = result_code
	result.message_key = key
	return result
