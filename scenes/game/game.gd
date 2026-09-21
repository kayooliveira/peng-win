extends Node2D

@onready var player: CharacterBody2D = $"Player/Player"


func _ready() -> void:
	var level := get_tree().get_first_node_in_group("level")
	if level and level.has_method("setup"):
		level.setup(player)
	else:
		push_warning("Game: nenhum nó no grupo 'level' encontrado.")
