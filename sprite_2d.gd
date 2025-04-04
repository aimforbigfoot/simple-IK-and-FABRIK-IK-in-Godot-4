extends CharacterBody2D



func _input(event: InputEvent) -> void:
	var b := Vector2.ZERO
	b = Vector2(
		-Input.get_action_strength("ui_left") + Input.get_action_strength("ui_right"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	velocity = b * 550.5


func _physics_process(delta: float) -> void:
	move_and_slide()
