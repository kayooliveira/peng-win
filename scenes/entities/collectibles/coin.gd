extends Area2D

@onready var sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var sprite: AnimatedSprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var available := true


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not available or not body.is_in_group("player"):
		return

	available = false
	collision_shape.set_deferred("disabled", true)

	if body.has_method("add_coin"):
		body.add_coin()
	else:
		body.coins += 1

	sfx.pitch_scale = randf_range(0.7, 1.0)
	sfx.play()

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "scale", Vector2(1.45, 1.45), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "position:y", sprite.position.y - 10.0, 0.18)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.18)

	await tween.finished
	if sfx.playing:
		await sfx.finished
	queue_free()
