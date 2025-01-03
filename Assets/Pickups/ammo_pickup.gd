extends RigidBody3D

# type
var type := "Ammo"

@export_enum("ClipA") var ammo_name := "ClipA"
@onready var node_3d: Node3D = $Node3D
var pickup_ready := false

@onready var mesh_instance_3d: MeshInstance3D = $Node3D/MeshInstance3D
const CLIP_A = preload("res://Assets/Ammo/Mags/clip_a.tscn")

func _ready() -> void:
	var mesh : Node3D
	match ammo_name:
		"ClipA":
			mesh = CLIP_A.instantiate()
	node_3d.add_child(mesh)
	pickup_ready = true
