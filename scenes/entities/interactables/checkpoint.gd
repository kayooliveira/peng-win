extends Area2D

const LevelScript = preload("res://scenes/levels/level.gd")

@onready var respawn_point: Marker2D = $RespawnPoint
@onready var sprite: Sprite2D = $Sprite2D

const ACTIVE_GLOW := Color(1.55, 1.45, 1.1)

var activated := false
var original_sprite_y: float


func _ready() -> void:
	original_sprite_y = sprite.position.y
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	var level := LevelScript.find_from(self)
	if level:
		level.set_checkpoint(respawn_point)

	if activated:
		return

	activated = true
	_play_activate_feedback(body)


func _play_activate_feedback(body: Node2D) -> void:
	if body.has_method("shake_camera"):
		body.shake_camera(1.8)

	sprite.modulate = ACTIVE_GLOW

	var tween := create_tween()
	tween.tween_property(sprite, "position:y", original_sprite_y - 7.0, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "position:y", original_sprite_y, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
