extends CharacterBody2D


# set player stats:
@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0

# variables to match animations and music:
@export var bpm : float = 140.0
@export var beats_per_anim : float = 2.0 # how long shall animation take
@export var animated_sprite : AnimatedSprite2D


func _ready() -> void:
	sync_animation_speed("run")
	sync_animation_speed("jump")


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction: 1 (right), 0 (no movement), -1 ( left)
	var direction := Input.get_axis("move_left", "move_right")
	
	# Flip sprite.
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	# Play animations.
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
	
	# Handle movement.
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func sync_animation_speed(anim_name : String):
	var frames = animated_sprite.sprite_frames.get_frame_count(anim_name)
	var fps = animated_sprite.sprite_frames.get_animation_speed(anim_name)
	var sec_per_beat = 60.0 / bpm
	var desired_duration = beats_per_anim * sec_per_beat
	
	var scale = (frames / fps) / desired_duration
	animated_sprite.speed_scale = scale
	#print(scale)
