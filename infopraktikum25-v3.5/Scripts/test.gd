extends Node2D


# Technical elements.
@export var midi_player : MidiPlayer
@export var countdown_timer : Timer
@export var countdown_label : Label
@export var fish_label : Label

# Game elements.
@export var player : CharacterBody2D
@export var fish : Area2D
@export var platform : AnimatableBody2D


# Save information.
var player_base_speed = 0.0
var player_base_jump_vel = 0.0

# Track movement status of game elements.
var moved_fish = false
var moved_platform = false


func _ready() -> void:
	# Save information from player and set movement to 0:
	player_base_speed = player.SPEED
	player_base_jump_vel = player.JUMP_VELOCITY
	player.SPEED = 0.0
	player.JUMP_VELOCITY = 0.0
	
	countdown_timer.start()


func _physics_process(delta: float) -> void:
	update_timer_label()


func update_timer_label():
	countdown_label.text = str(int(countdown_timer.time_left))


func _on_midi_player_midi_event(channel: Variant, event: Variant) -> void:
	if channel.number == 0:
		if event.type == 144:
			if moved_platform == false:
				platform.global_position.y += 20
				moved_platform = true
			elif moved_platform == true:
				platform.global_position.y -= 20
				moved_platform = false
	
	# Channel 1: main melody
	if channel.number == 1:
		# Event Type 144: audible note
		if event.type == 144:
			if moved_fish == false:
				fish.global_position.x += 20
				moved_fish = true
			elif moved_fish == true:
				fish.global_position.x -= 20
				moved_fish = false


func _on_countdown_timer_timeout() -> void:
	# Setup & start game.
	countdown_timer.stop()
	countdown_label.hide()
	fish_label.hide()
	fish.get_node("AnimatedSprite2D").flip_h = true
	fish.get_node("AnimatedSprite2D").play("swim")
	player.SPEED = player_base_speed
	player.JUMP_VELOCITY = player_base_jump_vel
	midi_player.play()
