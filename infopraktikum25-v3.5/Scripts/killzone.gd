extends Area2D

signal killzone_timer_timeout

@onready var timer: Timer = $Timer


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Ew. Water.")
		$AudioStreamPlayer2D.play()
		Engine.time_scale = 0.5
		timer.start()


func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
	killzone_timer_timeout.emit()
