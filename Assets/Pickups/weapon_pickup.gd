extends RigidBody3D

# type
var type := "Weapon"

@export_enum("BlasterA2", "BlasterK2") var weap_name := "BlasterK2"
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
var pickup_ready := false

const BLASTER_K = preload("res://Assets/Weapons/blasterK.mesh")
const BLASTER_A = preload("res://Assets/Weapons/blasterA.mesh")

func _ready() -> void:
	match weap_name:
		"BlasterA2":
			mesh_instance_3d.set_mesh(BLASTER_A)
		"BlasterK2":
			mesh_instance_3d.set_mesh(BLASTER_K)
	await get_tree().create_timer(1).timeout
	pickup_ready = true
