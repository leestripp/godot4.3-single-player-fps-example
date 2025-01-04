extends RigidBody3D


# set by weapon or Enemy
var damage := 0


func _on_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Targets") and body.has_method("hit_sucessful"):
		body.hit_sucessful(Game.BulletTypes.PROJECTILE, damage, linear_velocity.normalized(), global_position)
	queue_free()
