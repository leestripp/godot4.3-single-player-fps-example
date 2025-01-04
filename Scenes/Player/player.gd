extends CharacterBody3D
class_name Player

@onready var head: Node3D = $Head
@onready var bullet_point: Marker3D = $Camera3D/Weapons_Manager/bullet_point

# Movement
const CROUCH_SPEED := 2.0
const WALK_SPEED := 4.0
const RUN_SPEED := 8.0
const JUMP_VELOCITY := 8.0
const GRAVITY := -9.8*2 # m/s squared
var isRunning := false
var isJump := false
# physics
var current_friction := 0.1
var inputDirection : Vector3

# mouse
var mouse_sens := 0.1
const MOUSE_LIMIT := deg_to_rad(88)
const MOUSE_LIMIT_NEG := deg_to_rad(-88)

var health := 100
var hit_velocity := Vector3.ZERO


func _ready() -> void:
	pass


func _input(event: InputEvent) -> void:
	# mouse look
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, MOUSE_LIMIT_NEG, MOUSE_LIMIT)
	# keys
	inputDirection = Vector3.ZERO
	inputDirection.x = Input.get_axis("left", "right")
	inputDirection.z = Input.get_axis("forward", "backward")
	inputDirection = inputDirection.rotated(Vector3.UP, rotation.y).normalized()
	# keys
	if Input.is_action_just_pressed("sprint"):
		isRunning = true
	if Input.is_action_just_released("sprint"):
		isRunning = false
	if Input.is_action_just_pressed("jump"):
		isJump = true


func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		move_and_slide()
		return
	velocity.y = 0
	var speed := WALK_SPEED
	if isRunning:
		speed = RUN_SPEED
	else:
		speed = WALK_SPEED
	velocity.x = lerp(velocity.x, inputDirection.x * speed, current_friction)
	velocity.z = lerp(velocity.z, inputDirection.z * speed, current_friction)
	velocity += hit_velocity
	hit_velocity = Vector3.ZERO
	# jump
	if isJump:
		velocity.y = JUMP_VELOCITY
		isJump = false
	move_and_slide()


func hit_sucessful(bullet_type, damage, _direction:= Vector3.ZERO, _position:= Vector3.ZERO):
	match bullet_type:
		Game.BulletTypes.HITSCAN:
			if not _direction.is_equal_approx(Vector3.ZERO):
				hit_velocity += _direction * damage
		Game.BulletTypes.PROJECTILE:
			if not _direction.is_equal_approx(Vector3.ZERO):
				hit_velocity += _direction * damage
	print("hit_velocity : ", hit_velocity)
	health -= damage
	print("Player health : ", health)
