extends CharacterBody2D

signal shoot

const START_SPEED : int = 200
const BOOST_SPEED : int = 400
const NORMAL_SHOT : float = 0.5
const FAST_SHOT : float = 0.1
const BULLET_SCENE_PATH = "res://scenes/bullet.tscn"

var bullet_scene = preload(BULLET_SCENE_PATH)
var speed : int
var can_shoot : bool
var screen_size : Vector2
@export var fire_type : int = 2  # 1-normal, 2-shotgun, 3-laser
var laser_active : bool = false

func _ready():
	screen_size = get_viewport_rect().size
	reset()

func reset():
	can_shoot = true
	position = screen_size / 2
	speed = START_SPEED
	$ShotTimer.wait_time = NORMAL_SHOT

func get_input():
	# Keyboard input for movement
	var input_dir = Input.get_vector("left", "right", "up", "down")
	velocity = input_dir.normalized() * speed
	
	# Mouse clicks for shooting
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if fire_type == 3:
			if not laser_active:  # Only activate if it's not already active
				#laser_fire()
				laser_active = true

	# Fire normal or shotgun when the mouse button is just pressed
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and can_shoot:
		if fire_type == 1 or fire_type == 2:
			fire()  # Normal or shotgun fire
			can_shoot = false
			$ShotTimer.start()
	
	# Stop the laser when the mouse button is released
	if Input.is_action_just_released("mouse_left") and laser_active:
		stop_laser()
		laser_active = false
	
	# Key input for switching fire types
	if Input.is_action_just_pressed("fire_normal"):  # Set this in Input Map
		fire_type = 1
		print("Switched to Normal Fire")
	elif Input.is_action_just_pressed("fire_shotgun"):  # Set this in Input Map
		fire_type = 2
		print("Switched to Shotgun Fire")
	elif Input.is_action_just_pressed("fire_laser"):  # Set this in Input Map
		fire_type = 3
		print("Switched to Laser Fire")

func laser_fire():
	$RayCast2D.enabled = true  # Enable the RayCast2D for the laser
	$RayCast2D.visible = true  # Make the RayCast2D visible
	var mouse_position = get_global_mouse_position()  # Get the mouse position
	var direction = (mouse_position - global_position).normalized()  # Calculate the direction to the mouse
	
	# Set the RayCast2D's target position
	$RayCast2D.target_position = direction * 1000  # Adjust length as needed
	$RayCast2D.force_raycast_update()  # Update the RayCast position
	
	# Rotate only the laser node
	$RayCast2D.rotation = direction.angle()  # Replace $LaserNode with the actual path to your laser node



func stop_laser():
	$RayCast2D.enabled = false
	$RayCast2D.visible = false

func fire():
	if fire_type == 1:
		# Normal fire
		var mouse_position = get_global_mouse_position()
		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position
		bullet.direction = (mouse_position - global_position).normalized()
		get_tree().get_root().add_child(bullet)
	elif fire_type == 2:
		# Shotgun fire
		var times = 5  # Number of bullets for shotgun fire
		for i in range(times):
			var bullet = bullet_scene.instantiate()
			bullet.global_position = global_position
			var mouse_position = get_global_mouse_position()
			var base_direction = (mouse_position - global_position).normalized()
			var spread_angle = deg_to_rad(10)  # Adjust spread as needed
			var angle_variation = randf_range(-spread_angle, spread_angle)
			bullet.direction = base_direction.rotated(angle_variation)
			get_tree().get_root().add_child(bullet)

func _physics_process(_delta):
	# Player movement
	get_input()
	move_and_slide()
	
	# Limit movement to window size
	position = position.clamp(Vector2.ZERO, screen_size)
	
	# Player rotation
	var mouse = get_local_mouse_position()
	var angle = snappedf(mouse.angle(), PI / 4) / (PI / 4)
	angle = wrapi(int(angle), 0, 8)
	
	$AnimatedSprite2D.animation = "walk" + str(angle)
	
	# Player animation
	if velocity.length() != 0:
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		$AnimatedSprite2D.frame = 1

func boost():
	$BoostTimer.start()
	speed = BOOST_SPEED
	laser_fire()

func quick_fire():
	$FastFireTimer.start()
	$ShotTimer.wait_time = FAST_SHOT

func _on_shot_timer_timeout():
	can_shoot = true

func _on_boost_timer_timeout():
	speed = START_SPEED

func _on_fast_fire_timer_timeout():
	$ShotTimer.wait_time = NORMAL_SHOT


func _on_laser_timer_timeout() -> void:
	pass # Replace with function body.
