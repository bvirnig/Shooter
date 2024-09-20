extends Area2D

var speed : int = 500
var direction : Vector2
var shotgun : bool = false  # New variable to indicate if the bullet is part of a shotgun spread

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += speed * direction * delta

func _on_timer_timeout():
	queue_free()  # Remove bullet after a certain time

func _on_body_entered(body):
	if body.name == "World":
		queue_free()  # Remove bullet when hitting the world
	else:
		if body.alive:
			body.die()  # Call die method if the body is alive
			queue_free()  # Remove bullet after hitting a living target
