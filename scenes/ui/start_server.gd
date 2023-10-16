extends Control


@export var Server: Server


func _on_start_button_pressed() -> void:
	var port: String = $Menu/PortInput.text
	
	if port.is_valid_int():
		Server.start_server(port.to_int())
		$Menu.visible = false
