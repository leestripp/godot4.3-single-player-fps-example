extends Resource
class_name WeaponResource

@export var weapon_name : String
# anims
@export var activate_anim : String
@export var deactivate_anim : String
@export var reload_anim : String
@export var shoot_anim : String

# Ammo
@export var current_ammo : int
@export var reserve_ammo : int
@export var magazine : int
@export var auto_fire : bool
@export var max_ammo : int

# weapon stats
@export_flags("hitscan", "projectile") var type
@export var weapon_range : int
@export var damage : int
@export var projectile_to_load : PackedScene
@export var projectile_velocity : int

@export var weapon_drop : PackedScene
