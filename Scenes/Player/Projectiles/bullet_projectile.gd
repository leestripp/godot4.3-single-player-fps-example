extends RigidBody3D

# bullet type
enum {NULL, HITSCAN, PROJECTILE}

var damage := 0

func _on_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Targets") and body.has_method("hit_sucessful"):
		body.hit_sucessful(PROJECTILE, damage)
	queue_free()
