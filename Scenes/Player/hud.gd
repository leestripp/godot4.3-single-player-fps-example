extends CanvasLayer

@onready var weapon_label: Label = $HBox/Debug/weapon_label
@onready var ammo_label: Label = $HBox/Debug/ammo_label
@onready var weaponstack_label: Label = $HBox/Debug/weaponstack_label


func _on_weapons_manager_update_ammo(Ammo) -> void:
	ammo_label.set_text(str(Ammo[0]) + "/" + str(Ammo[1]))

func _on_weapons_manager_update_weapon_stack(weapon_stack) -> void:
	weaponstack_label.set_text("")
	for i in weapon_stack:
		weaponstack_label.text += i + "\n"

func _on_weapons_manager_weapon_changed(weapon_name) -> void:
	weapon_label.set_text(weapon_name)
