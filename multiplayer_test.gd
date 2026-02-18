extends Node2D

var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene
@onready var ui_container = $FirstUI
@onready var ip_input = $FirstUI/IPInput 
@onready var bugUI = $SecondUI/PrintBug

func _ready():
	# CHUYỂN CÁC KẾT NỐI VÀO ĐÂY ĐỂ TRÁNH LỖI DUPLICATE
	multiplayer.peer_connected.connect(_add_player)
	multiplayer.peer_disconnected.connect(_del_player)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	# Thêm cái này để báo lỗi nếu không tìm thấy Server (Timeout)
	multiplayer.connection_failed.connect(func(): 
		bugUI.text = "Error: Server not found or timed out!"
		_on_disconnect_pressed()
	)

func _on_host_pressed() -> void:
	# Đóng kết nối cũ nếu có để tránh lỗi 20 (Cổng bận)
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
		
	var error = peer.create_server(9999)
	if error != OK:
		bugUI.text = "Cannot make server: " + error_string(error)
		return
		
	multiplayer.multiplayer_peer = peer
	
	# Server tự thêm chính mình
	_add_player(multiplayer.get_unique_id())
	ui_container.hide()
	bugUI.text = "Hosted!"
	
	
	
	
func _on_join_pressed() -> void:
	if ip_input.text.strip_edges() == "":
		bugUI.text = "Please enter your IP!"
		return
	if not ip_input.text.strip_edges().is_valid_ip_address():
		bugUI.text = "Not correct format of IP!"
		return
	var error = peer.create_client(ip_input.text.strip_edges(), 9999)
	if error != OK:
		print("Cannot connect: ", error)
		bugUI.text = "Cannot connect: " + str(error)
		return
		
	multiplayer.multiplayer_peer = peer
	ui_container.hide()
	bugUI.text = ""

func _add_player(id: int):
	# Kiểm tra tránh tạo trùng node
	if get_node_or_null(str(id)):
		return
		
	var player = player_scene.instantiate()
	player.name = str(id)
	# Sử dụng add_child trực tiếp thay vì deferred nếu không ở trong physics callback
	add_child(player)
	
func _del_player(id: int):
	var player = get_node_or_null(str(id))
	if player:
		player.queue_free()


func _on_disconnect_pressed() -> void:
	if multiplayer.multiplayer_peer is ENetMultiplayerPeer:
		multiplayer.multiplayer_peer.close()
	
	# Luôn đưa về trạng thái null/offline để reset ID
	multiplayer.multiplayer_peer = null
	
	# Dọn dẹp nhân vật (nếu có)
	for child in get_children():
		if child.name.is_valid_int(): # Kiểm tra nếu tên node là ID số (nhân vật)
			child.queue_free()
	
	ui_container.show()


func _on_server_disconnected():
	_on_disconnect_pressed()
