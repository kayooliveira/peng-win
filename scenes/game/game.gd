extends Node2D

@onready var player: CharacterBody2D = $"Player/Player"
@onready var hud = $HUD
@onready var victory_screen = $VictoryScreen

var level_completed := false


func _ready() -> void:
	var level := get_tree().get_first_node_in_group("level")
	if level and level.has_method("setup"):
		level.setup(player)
	else:
		push_warning("Game: nenhum nó no grupo 'level' encontrado.")

	if player.has_signal("coins_changed"):
		player.coins_changed.connect(_on_coins_changed)
	if player.has_signal("level_completed"):
		player.level_completed.connect(_on_level_completed)

	hud.set_coins(player.coins)
	victory_screen.retry_pressed.connect(_on_retry_pressed)


func _on_coins_changed(amount: int) -> void:
	hud.set_coins(amount)


func _on_level_completed(coins: int) -> void:
	if level_completed:
		return
	level_completed = true
	victory_screen.show_victory(coins)


func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()
