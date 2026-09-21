extends Area2D

const LevelScript = preload("res://scenes/levels/level.gd")


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if body.has_method("is_invulnerable") and body.is_invulnerable():
		return

	var level := LevelScript.find_from(self)
	if level:
		level.respawn_player()
