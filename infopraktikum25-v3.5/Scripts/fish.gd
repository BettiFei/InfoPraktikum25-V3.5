extends Area2D


signal caught # emitted when body in group "player" enters area2d of fish


# variables to sync animations and soundtrack
@export var bpm : float = 140.0
@export var beats_per_anim : float = 4.0
@export var animated_sprite : AnimatedSprite2D


# variables to determine fish movement behaviour
@export var move_distance : float = 5.0
@export var step_chance_towards_player : float = 0.4
@export var max_distance_from_player : float = 300.0

# arena boundaries
@export var arena_min : Vector2 = Vector2(0,0) # top left
@export var arena_max : Vector2 = Vector2(1024, 768) # bottom right


var player : CharacterBody2D # connect in main scene



func _ready():
	randomize()
	sync_animation_speed("jump")
	sync_animation_speed("swim")


func make_move():
	#print("fish moved.")
	if player == null:
		return
	
	# check distance to player
	var distance = global_position.distance_to(player.global_position)
	if distance > max_distance_from_player:
		#print("You're so slow. I'll wait.")
		$Label.text = "So slow... I can wait."
		$Label.show()
		animated_sprite.play("jump")
		return
	
	
	var direction = Vector2.ZERO
	$Label.hide()
	animated_sprite.play("swim")
	
	
	if randf() < step_chance_towards_player: # move towards player
		direction = (player.global_position - global_position).normalized()
	else: # move away from player
		var away = (global_position - player.global_position).normalized()
		
		# possible movement options
		var choices = [
			Vector2.LEFT,
			Vector2.RIGHT,
			Vector2.UP,
			Vector2.DOWN
		]
		
		# choose best movement option (away from player)
		var best = choices[0]
		var best_dot = -1.0
		for c in choices:
			var d = c.dot(away)
			if d > best_dot:
				best_dot = d
				best = c
		direction = best
		
		# check if in arena boundaries:
		var new_pos = position + direction * move_distance
		if new_pos.x < arena_min.x or new_pos.x > arena_max.x or new_pos.y < arena_min.y or new_pos.y > arena_max.y:
			# choose new direction within boundaries
			var alternatives = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
			alternatives.shuffle()
			for alt in alternatives:
				var alt_pos = position + alt * move_distance
				if alt_pos.x >= arena_min.x and alt_pos.x <= arena_max.x and alt_pos.y >= arena_min.y and alt_pos.y <= arena_max.y:
					direction = alt
					new_pos = alt_pos
					break
		
		# move
		position = new_pos
		
		# flip sprite
		if direction.x < 0:
			animated_sprite.flip_h = false
		elif direction.x > 0:
			animated_sprite.flip_h = true


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Cat caught the fish.")
		caught.emit()
		queue_free()
		get_parent().fish = null


func sync_animation_speed(anim_name : String):
	var frames = animated_sprite.sprite_frames.get_frame_count(anim_name)
	var fps = animated_sprite.sprite_frames.get_animation_speed(anim_name)
	var sec_per_beat = 60.0 / bpm
	var desired_duration = beats_per_anim * sec_per_beat
	
	var scale = (frames / fps) / desired_duration
	animated_sprite.speed_scale = scale
	#print(scale)
