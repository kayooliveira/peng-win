extends CanvasLayer

@onready var coins_label: Label = $Root/CoinsLabel


func set_coins(amount: int) -> void:
	coins_label.text = "x%d" % amount
