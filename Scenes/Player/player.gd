class_name Player
extends CharacterBody3D

# bullet type
enum {NULL, HITSCAN, PROJECTILE}

var health := 100

@onready var camera_3d: Camera3D = $Camera3D
@onready var origCamPos: Vector3 = camera_3d.position

# Movement
const CROUCH_SPEED := 0.25 # factor of walk
const WALK_SPEED := 5.0
const RUN_SPEED := 10.0
const JUMP_VELOCITY := 5.0
const FRICTION := 0.1
const INAIR_SPEED := 0.01
var isRunning := false
# mouse
var mouse_sens := 0.1
const MOUSE_LIMIT := deg_to_rad(88)
const MOUSE_LIMIT_NEG := deg_to_rad(-88)

# footstep distance
var distanceFootstep := 0.0
# adjust footstep sound, faster if lower.
var playFootstep := 3
var canMove := true

# movement
var inputDirection := Vector3.ZERO

@onready var bullet_point: Marker3D = $Camera3D/FPS_Rig/bullet_point


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		camera_3d.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, MOUSE_LIMIT_NEG, MOUSE_LIMIT)
	# keys
	inputDirection = Vector3.ZERO
	inputDirection.x = Input.get_axis("left", "right")
	inputDirection.z = Input.get_axis("forward", "backward")
	inputDirection = inputDirection.rotated(Vector3.UP, rotation.y).normalized()
	# Run
	if Input.is_action_just_pressed("sprint"):
		isRunning = true
	if Input.is_action_just_released("sprint"):
		isRunning = false

func _process(delta: float) -> void:
	$HUD/HBox/Debug/state_label.text = $StateMachine.state.name


func hit_sucessful(bullet_type, damage, _direction:= Vector3.ZERO, _position:= Vector3.ZERO):
	match bullet_type:
		NULL:
			pass
		HITSCAN:
			print("Player hit, health : ", health)
		PROJECTILE:
			print("Player hit, health : ", health)
