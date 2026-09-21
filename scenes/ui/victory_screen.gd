extends CanvasLayer

signal retry_pressed

@onready var coins_label: Label = $Root/Panel/CoinsLabel
@onready var retry_button: Button = $Root/Panel/RetryButton


func _ready() -> void:
	visible = false
	retry_button.pressed.connect(func() -> void: retry_pressed.emit())


func show_victory(coins: int) -> void:
	coins_label.text = "Moedas: %d" % coins
	visible = true
	retry_button.grab_focus()
