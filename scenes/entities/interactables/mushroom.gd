extends Area2D

@onready var sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var sprite: Sprite2D = $Sprite

var original_scale: Vector2
var original_position: Vector2


func _ready() -> void:
	body_entered.connect(_on_body_entered)

	original_scale = sprite.scale
	original_position = sprite.position


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.velocity.y = -400

		sfx.pitch_scale = randf_range(0.5, 1.0)
		sfx.play()

		if body.has_method("shake_camera"):
			body.shake_camera(2.5)

		_bounce()


func _bounce() -> void:
	var tween := create_tween()

	var squash_scale := original_scale
	squash_scale.y *= 0.8

	var stretch_scale := original_scale
	stretch_scale.y *= 1.02

	var squash_position := original_position
	squash_position.y += sprite.texture.get_height() * original_scale.y * 0.01

	tween.tween_property(
		sprite,
		"scale",
		squash_scale,
		0.06
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(
		sprite,
		"position",
		squash_position,
		0.06
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		sprite,
		"scale",
		stretch_scale,
		0.1
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(
		sprite,
		"position",
		original_position,
		0.1
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		sprite,
		"scale",
		original_scale,
		0.12
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
