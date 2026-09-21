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

## Runtime attachment identity. The item remains the authoritative instance.
var attachment_id: String = ""
var attachment_type: String = ""
var attachment_side: String = ""

func setup(definition: XRGptItemDefinition, owner: String, amount: int = 1) -> void:
	if definition == null or definition.item_id.is_empty():
		definition_id = ""
		return
	definition_id = definition.item_id
	display_name = definition.display_name
	category = definition.category
	rarity = definition.rarity
	quantity = clampi(amount, 1, definition.max_stack)
	durability = 1.0
	owner_id = owner
	first_claim_available = definition.first_claim_relinquishable
	clear_attachment_state()

func clear_attachment_state() -> void:
	attachment_id = ""
	attachment_type = ""
	attachment_side = ""
