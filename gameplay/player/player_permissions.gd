class_name XRGptPlayerPermissions
extends RefCounted

enum Role {
	GUEST,
	HOST,
	MOD,
	ADMIN
}

var role: Role = Role.GUEST

func can_use_admin_tools() -> bool:
	return role == Role.MOD or role == Role.ADMIN

func can_use_creative() -> bool:
	return role == Role.MOD or role == Role.ADMIN

func set_role_authoritative(new_role: Role) -> void:
	role = new_role
