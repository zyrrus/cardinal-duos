extends Node3D

@onready var anim_player = $AnimationPlayer
@onready var muzzle_flash = $Gun/MuzzleFlash

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "shoot": 
		anim_player.play("idle")


func fire(raycast: RayCast3D): 
	if raycast.is_colliding():
		var hit_player = raycast.get_collider()
		hit_player.receive_damage.rpc_id(hit_player.get_multiplayer_authority())


func play_anim(name: String):
	if (!anim_player.current_animation == "shoot"):
		anim_player.play(name)


@rpc("call_local")
func play_shoot_effects():
	if (anim_player.current_animation != "shoot"):
		anim_player.stop()
		anim_player.play("shoot")
		muzzle_flash.restart()
		muzzle_flash.set_emitting(true)

