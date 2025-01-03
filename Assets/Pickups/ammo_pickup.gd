extends RigidBody3D

# type
var type := "Ammo"

@export_enum("ClipA") var ammo_name := "ClipA"

var pickup_ready := false

@onready var mesh_instance_3d: MeshInstance3D = $Node3D/MeshInstance3D
const CLIP_A = preload("res://Assets/Weapons/clipA.mesh")

func _ready() -> void:
	match ammo_name:
		"ClipA":
			mesh_instance_3d.set_mesh(CLIP_A)
	await get_tree().create_timer(1).timeout
	pickup_ready = true
