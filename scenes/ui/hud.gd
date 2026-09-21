extends CanvasLayer

@onready var coins_label: Label = $Root/CoinBar/CoinsLabel
@onready var coin_icon: AnimatedSprite2D = $Root/CoinBar/CoinIcon
@onready var coin_bar: Control = $Root/CoinBar

var _displayed_coins := 0


func _ready() -> void:
	coin_icon.play("spin")
	set_coins(0)


func set_coins(amount: int) -> void:
	coins_label.text = "%02d" % amount
	if amount > _displayed_coins:
		_punch()
	_displayed_coins = amount


func _punch() -> void:
	coin_bar.scale = Vector2.ONE
	var tween := create_tween()
	tween.tween_property(coin_bar, "scale", Vector2(1.12, 1.12), 0.06).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(coin_bar, "scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
