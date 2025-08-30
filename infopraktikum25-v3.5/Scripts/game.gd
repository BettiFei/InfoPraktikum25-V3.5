extends Node2D


# Technical elements.
@export_group("Technical Elements")
@export var midi_player : MidiPlayer
@export var killzone : Area2D
@export var countdown_timer : Timer
@export var countdown_label : Label
@export var end_timer : Timer
@export var victory_label : Control

# Game elements.
@export_group("Gameplay Elements")
@export var player : CharacterBody2D
@export var fish : Area2D
@export var platform : AnimatableBody2D


# Save information.
var player_base_speed = 0.0
var player_base_jump_vel = 0.0
var player_start_position : Vector2
var fish_start_position : Vector2

# Track movement status of game elements.
var moved_platform = false

# Handle transition to end of game.
var victorious := false


func _ready() -> void:
	victory_label.hide()
	killzone.killzone_timer_timeout.connect(reset_positions)
	player_start_position = player.global_position
	fish_start_position = fish.global_position
	
	fish.player = player
	
	# Save information from player and set movement to 0:
	block_movement()

	
	countdown_timer.start()


func _physics_process(delta: float) -> void:
	update_timer_label()


func update_timer_label():
	if int(countdown_timer.time_left) > 0:
		countdown_label.text = str(int(countdown_timer.time_left))
	elif int(countdown_timer.time_left) == 0:
		countdown_label.text = "GO!"


func block_movement():
	player_base_speed = player.SPEED
	player_base_jump_vel = player.JUMP_VELOCITY
	player.SPEED = 0.0
	player.JUMP_VELOCITY = 0.0


func reset_positions():
	player.global_position = player_start_position
	fish.global_position = fish_start_position


# -- MIDIPLAYER STUFF --
func _on_midi_player_midi_event(channel: Variant, event: Variant) -> void:
	if channel.number == 1 and event.type == 144:		# channel 1 = main melody & event type 144 = audible note
		if is_instance_valid(fish):
			# Move fish.
			fish.make_move()
	
	
	if channel.number == 0:
		if event.type == 144:
			if moved_platform == false:
				platform.global_position.y += 20
				moved_platform = true
			elif moved_platform == true:
				platform.global_position.y -= 20
				moved_platform = false
	
func _on_midi_player_finished() -> void:
	end_timer.start()
	if victorious == false:
		player.get_node("SadMeow").play()
# -- MIDIPLAYER STUFF DONE --

# Setup & start game.
func _on_countdown_timer_timeout() -> void:
	countdown_timer.stop()
	countdown_label.hide()
	fish.get_node("Label").hide()
	fish.get_node("AnimatedSprite2D").flip_h = true
	fish.get_node("AnimatedSprite2D").play("swim")
	player.SPEED = player_base_speed
	player.JUMP_VELOCITY = player_base_jump_vel
	midi_player.play()

# Victory
func _on_fish_caught() -> void:
	end_timer.start()
	player.get_node("ContentMeow").play()
	block_movement()
	midi_player.stop()
	victory_label.show()
	victory_label.get_node("Confetti").emitting = true
	victorious = true


func _on_end_timer_timeout() -> void:
	if victorious == true:
		get_tree().change_scene_to_file("res://Scenes/victory.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/gameover.tscn")
