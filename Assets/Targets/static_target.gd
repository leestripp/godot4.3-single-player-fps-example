extends StaticBody3D

var health = 10

func hit_sucessful(bullet_type, damage, _direction:= Vector3.ZERO, _position:= Vector3.ZERO):
	health -= damage
	print("Static Target HIT, health : ", health)
	if health <= 0:
		queue_free()
