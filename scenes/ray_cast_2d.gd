extends RayCast2D

@onready var line = $Line2D
@onready var end = $end

var max_distance = 1000

func _ready():
	target_position = Vector2(max_distance, 0)

func _physics_process(delta):
	if is_colliding():
		var coll_point = get_collision_point()
		
		# Update the line's endpoint based on the collision point
		line.points[1] = to_local(coll_point)
		end.position = coll_point - Vector2(15, 0)  # Adjust end position

		# Check the collider for any enemies
		var collider = get_collider()
		if collider and collider.is_in_group("enemies"):
			if collider.has_method("die"):
				collider.die()  # Call the die method on the enemy
	else:
		# If not colliding, extend the line to the maximum distance
		line.points[1] = Vector2(max_distance, 0)
		end.position = Vector2(max_distance - 15, 0)  # Set end position to max distance
