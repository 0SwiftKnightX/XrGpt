class_name XRGptItemDefinition
extends Resource

@export_category("Identity")
@export var item_id: String = ""
@export var display_name: String = ""
@export var category: String = "Misc"
@export var subcategory: String = ""
## Keep the default capability data literal so this definition resource does not
## introduce an unnecessary global-class initialization dependency during import.
@export var capabilities: Array[String] = ["inspectable"]
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
## Keep this property Resource-typed to avoid a script-class cycle:
## ItemDefinition -> AttachmentProfile -> AttachmentPoint -> ItemDefinition.
## Consumers cast it to XRGptAttachmentProfile at the system boundary.
@export var attachment_profile: Resource
