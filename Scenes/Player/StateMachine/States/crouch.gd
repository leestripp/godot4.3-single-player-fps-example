extends PlayerState

@onready var collision_shape_3d: CollisionShape3D = $"../../CollisionShape3D"

func sm_enter(msg: Dictionary = {}) -> void:
	collision_shape_3d.shape.height = 1.0

func sm_input(event: InputEvent) -> void:
	if Input.is_action_just_released("crouch"):
		state_machine.transition_to("Idle")

func sm_process(delta: float) -> void:
	pass

func sm_physics_process(delta: float) -> void:
	player.velocity.x = lerp(player.velocity.x, player.inputDirection.x * player.WALK_SPEED * player.CROUCH_SPEED, player.FRICTION)
	player.velocity.z = lerp(player.velocity.z, player.inputDirection.z * player.WALK_SPEED * player.CROUCH_SPEED, player.FRICTION)
	# Gravity
	player.velocity.y += player.get_gravity().y * delta
	player.move_and_slide()

func sm_exit() -> void:
	collision_shape_3d.shape.height = 2.0
