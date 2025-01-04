extends RigidBody3D

var damage := 0
var enemy : Enemy

func _on_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node) -> void:
	if body is Player and body.has_method("hit_sucessful"):
		body.hit_sucessful(Game.BulletTypes.PROJECTILE, damage, linear_velocity * 0.5, global_position)
		queue_free()
