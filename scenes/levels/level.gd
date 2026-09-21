class_name Level
extends Node2D

@onready var initial_respawn_point: Marker2D = $RespawnPoint

var player: CharacterBody2D
var current_respawn_point: Marker2D
var is_respawning := false


func _ready() -> void:
	add_to_group("level")
	if initial_respawn_point:
		current_respawn_point = initial_respawn_point


func setup(player_reference: CharacterBody2D) -> void:
	player = player_reference


func set_checkpoint(marker: Marker2D) -> void:
	current_respawn_point = marker


func respawn_player() -> void:
	if is_respawning or player == null:
		return
	if player.has_method("is_invulnerable") and player.is_invulnerable():
		return

	is_respawning = true
	await player.die()
	if current_respawn_point:
		player.global_position = current_respawn_point.global_position
	player.velocity = Vector2.ZERO
	if player.has_method("start_iframes"):
		player.start_iframes()
	is_respawning = false


## Sobe a árvore até achar um nó no grupo "level" (funciona com Scene Collection).
static func find_from(node: Node) -> Node:
	var n := node.get_parent()
	while n:
		if n.is_in_group("level"):
			return n
		n = n.get_parent()
	return null
