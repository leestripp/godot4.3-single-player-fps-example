extends PlayerState


func sm_enter(msg: Dictionary = {}) -> void:
	pass

func sm_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("InAir", {"doJump":true})
	if Input.is_action_pressed("crouch"):
		state_machine.transition_to("Crouch")

func sm_process(delta: float) -> void:
	if player.inputDirection.is_zero_approx():
		state_machine.transition_to("Idle")
	elif !player.is_on_floor():
		state_machine.transition_to("InAir")
	elif player.isRunning:
		state_machine.transition_to("Run")

func sm_physics_process(delta: float) -> void:
	player.velocity.x = lerp(player.velocity.x, player.inputDirection.x * player.WALK_SPEED, player.FRICTION)
	player.velocity.z = lerp(player.velocity.z, player.inputDirection.z * player.WALK_SPEED, player.FRICTION)
	player.move_and_slide()

func sm_exit() -> void:
	pass
