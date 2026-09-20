class_name XRGptItemDefinition
extends Resource

@export var item_id: String = ""
@export var display_name: String = ""
@export var category: String = "Misc"
@export var rarity: String = "Common"
@export_multiline var description: String = ""
@export var max_stack: int = 99
@export var auto_collect: bool = false
@export var first_claim_relinquishable: bool = false
@export var mailbox_on_full: bool = true
@export var tradeable: bool = true
@export var stealable: bool = false
