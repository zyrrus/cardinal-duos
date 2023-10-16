extends Control


@export var Client: Client


func _on_join_button_pressed():
	var address: String = $Menu/AddressInput.text
	var port: String = $Menu/PortInput.text
	
	if port.is_valid_int():
		Client.start_client(address, port.to_int())
		$Menu.visible = false
