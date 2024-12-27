extends PlayerState


func sm_enter(msg: Dictionary = {}) -> void:
	if msg.has("doJump"):
		player.velocity.y = 0
		player.velocity.y += player.JUMP_VELOCITY

func sm_input(event: InputEvent) -> void:
	pass

func sm_process(delta: float) -> void:
	if player.is_on_floor():
		state_machine.transition_to("Idle")

func sm_physics_process(delta: float) -> void:
	player.velocity.y += player.get_gravity().y * delta
	player.move_and_slide()

func sm_exit() -> void:
	pass
