extends RigidBody3D

# bullet types
enum {NULL, HITSCAN, PROJECTILE}

var health = 10
# physics
var hit_factor = 2

func hit_sucessful(bullet_type, damage, _direction:= Vector3.ZERO, _position:= Vector3.ZERO):
	match bullet_type:
		NULL:
			pass
		HITSCAN:
			var hit_position = _position - global_transform.origin
			if _direction != Vector3.ZERO:
				apply_impulse((_direction * damage * hit_factor), hit_position)
				# print("Target apply impulse : ", _direction * damage)
		PROJECTILE:
			var hit_position = _position + global_transform.origin
			if _direction != Vector3.ZERO:
				apply_impulse((_direction * damage * hit_factor), hit_position)
	health -= damage
	print("Target HIT, health : ", health)
	if health <= 0:
		queue_free()
