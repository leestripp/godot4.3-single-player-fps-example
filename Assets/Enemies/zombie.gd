extends CharacterBody3D
class_name Enemy

@onready var animation_player: AnimationPlayer = $Zombie/AnimationPlayer
@onready var enemy_projectile = preload("res://Assets/Enemies/enemy_projectile.tscn")

const GRAVITY := -9.8*2
var speed := 0.0
var health := 5
var projectile_velocity := 10

var detectedPlayer: Player
var damage := 10
var vel : Vector3
var roamDistance := 100
var current_state := EnemyState.IDLE

enum EnemyState{
	IDLE,
	ROAM,
	ATTACK
}


func _ready() -> void:
	rotation = Vector3.ZERO
	vel = Vector3.ZERO
	set_state(EnemyState.IDLE)


func set_state(value: EnemyState) -> void:
	current_state = value
	match current_state:
		EnemyState.IDLE:
			animation_player.play("Idle")
			speed = 0.001
			$moveTimer.start()
		EnemyState.ROAM:
			animation_player.play("Walk")
			speed = 2.0
		EnemyState.ATTACK:
			animation_player.play("Attack")
			var direction = ((detectedPlayer.global_position + Vector3(0,1,0)) - $Zombie/Armature/bullet_point.global_position).normalized()
			$Zombie/Armature.rotation.y = atan2(direction.x, direction.z)
			await get_tree().create_timer(1).timeout
			var zProjectile = enemy_projectile.instantiate()
			get_tree().get_root().add_child(zProjectile)
			zProjectile.global_position = $Zombie/Armature/bullet_point.global_position
			zProjectile.damage = damage
			zProjectile.enemy = self
			zProjectile.set_linear_velocity(direction * projectile_velocity)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		move_and_slide()
		return
	# move enemy
	velocity.y = 0
	match current_state:
		EnemyState.IDLE:
			calc_rotation(delta)
			calc_velocity()
			$NavigationAgent3D.set_velocity(vel)
		EnemyState.ROAM:
			calc_rotation(delta)
			calc_velocity()
			$NavigationAgent3D.set_velocity(vel)
		EnemyState.ATTACK:
			$NavigationAgent3D.set_velocity(Vector3.ZERO)
			# fire at end of anim
			if not animation_player.is_playing():
				set_state(EnemyState.ATTACK)
	move_and_slide()


func calc_rotation(delta: float) -> void:
	$Zombie/Armature.rotation.y = lerp_angle(
		$Zombie/Armature.rotation.y,
		atan2(vel.x, vel.z),
		10 * delta
	)


func calc_velocity() -> void:
	# calc next target
	var target = $NavigationAgent3D.get_next_path_position()
	var pos = get_global_transform().origin
	var n = Vector3.UP
	vel = (target - pos).slide(n).normalized() * speed


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	set_velocity(safe_velocity)


func _on_navigation_agent_3d_navigation_finished() -> void:
	set_state(EnemyState.IDLE)


func _on_move_timer_timeout() -> void:
	var square_point = get_random_pos_in_square(roamDistance)
	move_to(square_point)


func move_to(target_pos):
	set_state(EnemyState.ROAM)
	var closest_pos = NavigationServer3D.map_get_closest_point(get_world_3d().get_navigation_map(), target_pos)
	$NavigationAgent3D.set_target_position(closest_pos)


func _on_detect_player_area_body_entered(body: Node3D) -> void:
	if body is Player:
		# print("Player entered attack zone.")
		$moveTimer.stop()
		detectedPlayer = body
		set_state(EnemyState.ATTACK)



func _on_detect_player_area_body_exited(body: Node3D) -> void:
	if body is Player:
		print("Player exited attack zone.")
		set_state(EnemyState.IDLE)
		# _on_move_timer_timeout()


func hit_sucessful(bullet_type, damage, _direction:= Vector3.ZERO, _position:= Vector3.ZERO):
	health -= damage
	print("Enemy HIT, health : ", health)
	if health <= 0:
		queue_free()


func get_random_pos_in_square(_distance: float) -> Vector3:
	var random_pos = Vector3.ZERO
	random_pos.x = randi_range(-_distance, _distance)
	random_pos.z = randi_range(-_distance, _distance)
	return random_pos
