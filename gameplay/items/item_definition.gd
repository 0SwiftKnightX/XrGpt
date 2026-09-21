class_name XRGptItemDefinition
extends Resource

@export_category("Identity")
@export var item_id: String = ""
@export var display_name: String = ""
@export var category: String = "Misc"
@export var rarity: String = "Common"
@export_multiline var description: String = ""

@export_category("Stacking")
@export var max_stack: int = 99

@export_category("Ownership")
@export var auto_collect: bool = false
@export var first_claim_relinquishable: bool = false
@export var mailbox_on_full: bool = true
@export var tradeable: bool = true
@export var stealable: bool = false

@export_category("Attachment")
## Item-side attachment contract. A null profile means the item is not attachable.
@export var attachment_profile: XRGptAttachmentProfile
