class_name XRGptItemInstance
extends RefCounted

var definition_id: String = ""
var display_name: String = ""
var category: String = ""
var rarity: String = ""
var quantity: int = 1
var durability: float = 1.0
var owner_id: String = ""
var first_claim_available: bool = false

func setup(definition: XRGptItemDefinition, owner: String, amount: int = 1) -> void:
	definition_id = definition.item_id
	display_name = definition.display_name
	category = definition.category
	rarity = definition.rarity
	quantity = amount
	owner_id = owner
	first_claim_available = definition.first_claim_relinquishable
