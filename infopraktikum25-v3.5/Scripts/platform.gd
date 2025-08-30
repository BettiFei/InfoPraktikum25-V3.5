extends AnimatableBody2D

@export var move_distance : float = 20.0
@export var direction : Vector2 = Vector2.UP
@export var max_steps : int = 2
@export var move_time : float = 0.3

var step_count : int = 0
var going_forward : bool = true
var tween : Tween = null

func make_move():
	# if tween is active --> abort:
	if tween != null and tween.is_running():
		return
	
	var offset = direction * move_distance
	if not going_forward:
		offset = -offset
	
	var target_pos = position + offset
	
	tween = create_tween()
	tween.tween_property(self, "position", target_pos, move_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	step_count += 1
	if step_count >= max_steps:
		going_forward = !going_forward
		step_count = 0
