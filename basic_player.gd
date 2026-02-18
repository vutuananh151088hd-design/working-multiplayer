extends CharacterBody2D
@onready var name_label = $PlayerName
func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _physics_process(delta):
	if is_multiplayer_authority():
		velocity = Input.get_vector("ui_left","ui_right","ui_up", "ui_down") * 300
		move_and_slide()
func _ready() -> void:
	# Cập nhật Text của Label bằng ID của Player
	# 'name' ở đây chính là ID (1, 28374...) mà bạn đã đặt ở hàm _add_player
	name_label.text = "Player: " + str(name)
	
	# Nếu là chính mình, bạn có thể đổi màu để dễ phân biệt
	if is_multiplayer_authority():
		name_label.modulate = Color.GREEN
		name_label.text = name_label.text + " (You)"
	else:
		name_label.modulate = Color.RED
		if has_node("Camera2D"):
			get_node("Camera2D").queue_free()
