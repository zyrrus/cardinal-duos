extends Node
class_name Server


const MAX_PLAYERS = 4

var multiplayer_peer := ENetMultiplayerPeer.new()
var connected_peer_ids: Array[int] = []
var Player = preload("res://scenes/entities/player/Player.tscn")


func start_server(port: int) -> void:
	multiplayer_peer.create_server(port, MAX_PLAYERS)
	multiplayer.multiplayer_peer = multiplayer_peer
	
	multiplayer_peer.peer_connected.connect(_on_peer_connected)


func _on_peer_connected(new_peer_id: int) -> void:
	await get_tree().create_timer(1).timeout
	add_previously_connected_player_characters.rpc_id(new_peer_id, connected_peer_ids)

	add_newly_connected_player_character.rpc(new_peer_id)
	_add_player_character(new_peer_id)


func _add_player_character(peer_id: int) -> void:
	connected_peer_ids.append(peer_id)
	var player = Player.instantiate() 
	player.set_multiplayer_authority(peer_id)
	add_child(player)


@rpc("call_remote")
func add_newly_connected_player_character(new_peer_id: int) -> void:
	pass


@rpc("call_remote")
func add_previously_connected_player_characters(peer_ids: Array[int]) -> void:
	pass
