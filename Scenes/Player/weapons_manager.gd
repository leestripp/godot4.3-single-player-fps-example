extends Node3D

# Anims
@onready var animation_player: AnimationPlayer = $"../FPS_Rig/AnimationPlayer"
# bullet start
@onready var bullet_point: Marker3D = $"../FPS_Rig/bullet_point"
# bullet hole
@onready var bullet_hole = preload("res://Assets/Decals/bullet_hole.tscn")
# pickups
@onready var WP_pickup = preload("res://Assets/Pickups/weapon_pickup.tscn")

var current_weapon = null
var weapon_stack = []
var next_weapon: String
var weapon_list = {}

@export var _weapon_resorses : Array[WeaponResource]
@export var start_weapons : Array[String]

enum {NULL, HITSCAN, PROJECTILE}

# Signals
signal weapon_changed
signal update_ammo
signal update_weapon_stack

var collision_exclusion = []

func _ready() -> void:
	initialize(start_weapons)

func initialize(start_weapons: Array):
	for weapon in _weapon_resorses:
		weapon_list[weapon.weapon_name] = weapon
	for i in start_weapons:
		weapon_stack.push_back(i)
	current_weapon = weapon_list[weapon_stack[0]]
	emit_signal("update_weapon_stack", weapon_stack)
	enter()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("weapon_down"):
		var getRef = weapon_stack.find(current_weapon.weapon_name)
		getRef = min(getRef+1, weapon_stack.size()-1)
		exit(weapon_stack[getRef])
	if event.is_action_pressed("weapon_up"):
		var getRef = weapon_stack.find(current_weapon.weapon_name)
		getRef = max(getRef-1, 0)
		exit(weapon_stack[getRef])
	if event.is_action_pressed("fire"):
		fire()
	if event.is_action_pressed("reload"):
		reload()
	if event.is_action_pressed("drop"):
		drop(current_weapon.weapon_name)

func drop(_name: String):
	if weapon_stack.size() > 1:
		var weapon_ref = weapon_stack.find(_name)
		if weapon_ref != -1:
			weapon_stack.pop_at(weapon_ref)
			emit_signal("update_weapon_stack", weapon_stack)
			var weapon_dropped = WP_pickup.instantiate()
			var world = get_tree().get_root()
			weapon_dropped.weap_name = _name
			weapon_dropped.global_transform = bullet_point.global_transform
			world.add_child(weapon_dropped)
			# Change wepon
			var getRef = weapon_stack.find(current_weapon.weapon_name)
			getRef = max(getRef, -1, 0)
			exit(weapon_stack[getRef])

func fire() -> void:
	if current_weapon.current_ammo > 0:
		if !animation_player.is_playing():
			animation_player.play(current_weapon.shoot_anim)
			current_weapon.current_ammo -= 1
			emit_signal("update_ammo", [current_weapon.current_ammo, current_weapon.reserve_ammo])
			# hitpoint
			var camera_collision = get_camera_collision()
			match current_weapon.type:
				NULL:
					print("Unknown weapon type")
				HITSCAN:
					hitscan_collision(camera_collision)
				PROJECTILE:
					launch_projectile(camera_collision)


func hitscan_collision(hitpoint):
	var bullet_direction = (hitpoint - bullet_point.get_global_transform().origin).normalized()
	var new_intersection = PhysicsRayQueryParameters3D.create(bullet_point.get_global_transform().origin, hitpoint + bullet_direction)
	var bullet_collision = get_world_3d().direct_space_state.intersect_ray(new_intersection)
	if bullet_collision:
		# print("Hitscan collision at : ", bullet_collision)
		var hit_indc = bullet_hole.instantiate()
		var world = get_tree().get_root()
		world.add_child(hit_indc)
		hit_indc.global_translate(bullet_collision.position)
		hitscan_damage(bullet_collision.collider, bullet_direction, bullet_collision.position)


func launch_projectile(hitpoint):
	var bullet_direction = (hitpoint - bullet_point.get_global_transform().origin).normalized()
	var projectile = current_weapon.projectile_to_load.instantiate()
	var projectile_RID = projectile.get_rid()
	collision_exclusion.push_back(projectile_RID)
	projectile.tree_exited.connect(remove_exclusion.bind(projectile.get_rid()))
	# add bullet
	bullet_point.add_child(projectile)
	projectile.damage = current_weapon.damage
	projectile.set_linear_velocity(bullet_direction * current_weapon.projectile_velocity)


func remove_exclusion(projectile_rid):
	collision_exclusion.erase(projectile_rid)


func hitscan_damage(collider, direction, collider_position):
	if collider.is_in_group("Targets") and collider.has_method("hit_sucessful"):
		collider.hit_sucessful(HITSCAN, current_weapon.damage, direction, collider_position)

# Calc the raycast end point based on weapon
func get_camera_collision() -> Vector3:
	var camera = get_viewport().get_camera_3d()
	var viewport = get_viewport().get_size()
	# raycast
	var ray_origin = camera.project_ray_origin(viewport/2)
	var ray_end = ray_origin + camera.project_ray_normal(viewport/2) * current_weapon.weapon_range
	var new_intersection = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	new_intersection.set_exclude(collision_exclusion)
	var intersection = get_world_3d().direct_space_state.intersect_ray(new_intersection)
	if not intersection.is_empty():
		var col_point = intersection.position
		return col_point
	else:
		return ray_end


func reload() -> void:
	if current_weapon.reserve_ammo > 0:
		if !animation_player.is_playing():
			animation_player.play(current_weapon.reload_anim)
			if current_weapon.reserve_ammo > current_weapon.magazine:
				current_weapon.reserve_ammo -= current_weapon.magazine
				current_weapon.current_ammo = current_weapon.magazine
			else:
				current_weapon.current_ammo = current_weapon.reserve_ammo
				current_weapon.reserve_ammo = 0
			emit_signal("update_ammo", [current_weapon.current_ammo, current_weapon.reserve_ammo])

func enter() -> void:
	animation_player.queue(current_weapon.activate_anim)
	emit_signal("weapon_changed", current_weapon.weapon_name)
	emit_signal("update_ammo", [current_weapon.current_ammo, current_weapon.reserve_ammo])

func exit(_next_weapon: String):
	if _next_weapon != current_weapon.weapon_name:
		if animation_player.get_current_animation() != current_weapon.deactivate_anim:
			animation_player.play(current_weapon.deactivate_anim)
			next_weapon = _next_weapon


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == current_weapon.deactivate_anim:
		change_weapon(next_weapon)
	if anim_name == current_weapon.shoot_anim and current_weapon.auto_fire:
		if Input.is_action_pressed("fire"):
			fire()

func change_weapon(weapon_name: String) -> void:
	current_weapon = weapon_list[weapon_name]
	next_weapon = ""
	enter()


func _on_pickup_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("PickupGroup"):
		if body.type == "Weapon" and body.pickup_ready:
			print(body)
			var weapon_in_stack = weapon_stack.find(body.weap_name)
			if weapon_in_stack == -1:
				var getRef = weapon_stack.find(current_weapon.weapon_name)
				weapon_stack.insert(getRef, body.weap_name)
				emit_signal("update_weapon_stack", weapon_stack)
				exit(body.weap_name)
				body.queue_free()
		elif body.type == "Ammo" and body.pickup_ready:
			print(body)
			if current_weapon.reserve_ammo + current_weapon.magazine < current_weapon.max_ammo:
				current_weapon.reserve_ammo += current_weapon.magazine
				emit_signal("update_ammo", [current_weapon.current_ammo, current_weapon.reserve_ammo])
				body.queue_free()
