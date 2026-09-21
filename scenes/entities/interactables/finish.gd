extends Area2D

var triggered := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if triggered:
		return
	if not body.is_in_group("player"):
		return
	if not body.has_method("change_state"):
		return

	triggered = true
	body.change_state(body.PlayerState.DANCING)
	if body.has_method("complete_level"):
		body.complete_level()
