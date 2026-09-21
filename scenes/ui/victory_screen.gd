extends CanvasLayer

signal retry_pressed

@onready var coins_label: Label = $Root/Panel/Content/CoinRow/CoinsLabel
@onready var coin_icon: AnimatedSprite2D = $Root/Panel/Content/CoinRow/CoinIcon
@onready var retry_button: Button = $Root/Panel/Content/RetryButton


func _ready() -> void:
	visible = false
	coin_icon.play("spin")
	retry_button.pressed.connect(func() -> void: retry_pressed.emit())


func show_victory(coins: int) -> void:
	coins_label.text = "%02d" % coins
	visible = true
	retry_button.grab_focus()
