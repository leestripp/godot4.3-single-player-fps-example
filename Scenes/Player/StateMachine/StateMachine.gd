class_name StateMachine
extends Node

# signals
signal transitioned(state_name)

# state
@export var initialState := NodePath()
@onready var state = get_node(initialState)


func _ready() -> void:
	await owner.ready
	for child in get_children():
		child.state_machine = self
	state.sm_enter()


func _unhandled_input(event: InputEvent) -> void:
	state.sm_input(event)


func _process(delta: float) -> void:
	state.sm_process(delta)


func _physics_process(delta: float) -> void:
	state.sm_physics_process(delta)


func transition_to(new_state: String, msg: Dictionary = {}):
	assert(has_node(new_state), "Player State not found")
	state.sm_exit()
	state = get_node(new_state)
	state.sm_enter(msg)
	emit_signal("transitioned", new_state)
