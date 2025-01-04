extends RigidBody3D

# type
var type := "Weapon"

@export_enum("BlasterA2", "BlasterK2") var weap_name := "BlasterK2"

@onready var node_3d: Node3D = $Node3D
var pickup_ready := false

const BLASTER_K = preload("res://Assets/Weapons/blaster_k.tscn")
const BLASTER_A = preload("res://Assets/Weapons/blaster_a.tscn")

func _ready() -> void:
	var mesh : Node3D
	match weap_name:
		"BlasterA2":
			mesh = BLASTER_A.instantiate()
		"BlasterK2":
			mesh = BLASTER_K.instantiate()
	node_3d.add_child(mesh)
	pickup_ready = true
