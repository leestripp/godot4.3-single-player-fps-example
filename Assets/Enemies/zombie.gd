class_name Enemy
extends CharacterBody3D

@onready var animation_player: AnimationPlayer = $Zombie/AnimationPlayer
@onready var enemy_projectile = preload("res://Assets/Enemies/enemy_projectile.tscn")

var damage := 1
var speed := 0.0
var health := 5
var projectile_velocity := 10

enum {IDLE, ROAM, ATTACK}

var detectedPlayer: Player
var vel
var roamDistance := 5

var current_state := IDLE :
	set(value):
		current_state = value
		match value:
			IDLE:
				animation_player.play("Idle")
				speed = 0.001
				$moveTimer.start()
			ROAM:
				animation_player.play("Walk")
				speed = 2.0
			ATTACK:
				animation_player.play("Attack")
				var direction = (detectedPlayer.bullet_point.global_position - $Zombie/Armature/bullet_point.global_position).normalized()
				$Zombie/Armature.rotation.y = atan2(direction.x, direction.z)
				# fire at end of anim
				await animation_player.animation_finished
				var zProjectile = enemy_projectile.instantiate()
				get_tree().get_root().add_child(zProjectile)
				zProjectile.global_position = $Zombie/Armature/bullet_point.global_position
				zProjectile.damage = damage
				zProjectile.set_linear_velocity(direction * projectile_velocity)
				$moveTimer.start()
				$DetectPlayerArea/CollisionShape3D.set_deferred_thread_group("Disabled", true)
				$DetectPlayerArea/CollisionShape3D.set_deferred_thread_group("Disabled", false)
				

func _ready() -> void:
	rotation = Vector3.ZERO


func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity.y = -9.8
		move_and_slide()
		return
	var target = $NavigationAgent3D.get_next_path_position()
	var pos = get_global_transform().origin
	var n = $RayCast3D.get_collision_normal()
	if n.length_squared() < 0.001:
		n = Vector3(0, 1, 0)
	vel = (target - pos).slide(n).normalized() * speed
	if current_state != ATTACK:
		$Zombie/Armature.rotation.y = lerp_angle(
			$Zombie/Armature.rotation.y,
			atan2(vel.x, vel.z),
			10 * delta
		)
	$NavigationAgent3D.set_velocity(vel)
	if current_state == ATTACK:
		$NavigationAgent3D.set_velocity(Vector3.ZERO)
	move_and_slide()


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	set_velocity(safe_velocity)


func _on_navigation_agent_3d_navigation_finished() -> void:
	current_state = IDLE


func _on_move_timer_timeout() -> void:
	var square_point = get_random_pos_in_square(roamDistance)
	move_to(square_point)


func move_to(target_pos):
	current_state = ROAM
	var closest_pos = NavigationServer3D.map_get_closest_point(get_world_3d().get_navigation_map(), target_pos)
	$NavigationAgent3D.set_target_position(closest_pos)


func get_random_pos_in_square(_distance: float) -> Vector3:
	var random_pos = Vector3.ZERO
	random_pos.x = randi_range(-_distance, _distance)
	random_pos.z = randi_range(-_distance, _distance)
	return random_pos


func _on_detect_player_area_body_entered(body: Node3D) -> void:
	if body is Player:
		print("Player entered.")
		$moveTimer.stop()
		detectedPlayer = body
		current_state = ATTACK


func _on_detect_player_area_body_exited(body: Node3D) -> void:
	if body is Player:
		print("Player exited.")
		current_state = ROAM
		_on_move_timer_timeout()


func hit_sucessful(bullet_type, damage, _direction:= Vector3.ZERO, _position:= Vector3.ZERO):
	health -= damage
	print("Enemy HIT, health : ", health)
	if health <= 0:
		queue_free()
