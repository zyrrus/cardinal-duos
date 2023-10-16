extends Node
class_name Client


var multiplayer_peer := ENetMultiplayerPeer.new()
var connected_peer_ids: Array[int] = []
var Player = preload("res://scenes/entities/player/Player.tscn")


func start_client(address: String, port: int) -> void:
	multiplayer_peer.create_client(address, port)
	multiplayer.multiplayer_peer = multiplayer_peer


func _add_player_character(peer_id: int) -> void:
	connected_peer_ids.append(peer_id)
	var player = Player.instantiate() 
	player.set_multiplayer_authority(peer_id)
	add_child(player)


@rpc
func add_newly_connected_player_character(new_peer_id: int) -> void:
	_add_player_character(new_peer_id)


@rpc
func add_previously_connected_player_characters(peer_ids: Array[int]) -> void:
	for peer_id in peer_ids:
		_add_player_character(peer_id)
