extends Area2D

var heading = 0
var dig_progress = 0
var zoom = 1.5

@onready var camera: Camera2D = get_tree().get_current_scene().get_node("Camera2D")

func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	pass

func _process(delta):
	var w = Vector2.ZERO
	if Input.is_action_pressed("forward"):
		w.x += 16 * 5
	if Input.is_action_pressed("reverse"):
		w.x -= 16 * 5

	var tilemap = get_tree().get_current_scene().get_node("TileMap")
	var map_p = tilemap.local_to_map(transform.get_origin())
	#print(map_p)

	var main_tiledata: TileData = tilemap.get_cell_tile_data(0, map_p)
	var main_custom_data = main_tiledata.get_custom_data("type") if main_tiledata else null
	#print(main_tiledata)
	#print(main_custom_data)

	var stone_tiledata: TileData = tilemap.get_cell_tile_data(1, map_p)
	var stone_custom_data = stone_tiledata.get_custom_data("type") if stone_tiledata else null
	#print(stone_tiledata)
	#print(stone_custom_data)

	if stone_custom_data != null and stone_custom_data != 0:
		w *= 0.0
		dig_progress += delta
		if dig_progress >= 0.5:
			tilemap.dig_stone(map_p)
			dig_progress = 0

	elif main_custom_data != null and main_custom_data != 0:
		#w *= 0.2
		#tilemap.dig_dirt(map_p)
		w *= 0.0
		dig_progress += delta
		if dig_progress >= 0.1:
			tilemap.dig_dirt(map_p)
			dig_progress = 0

	var v = w.rotated(heading)
	position += v * delta

	var heading_control = 0
	if Input.is_action_pressed("left"):
		heading_control -= PI * 2 * delta * 0.5
	if Input.is_action_pressed("right"):
		heading_control += PI * 2 * delta * 0.5

	heading += heading_control

	# Snap to straight headings when steer buttons are not being pressed
	if heading_control == 0:
		var i = int((-heading + (PI*2) + (PI*2/16)) / (PI*2/8)) % 8
		var straight_heading = -(i * PI / 4)
		heading = straight_heading

	if v.x != 0 or v.y != 0:
		# Snap to middle of tile when moving vertically or horizontally
		print(v)
		if abs(v.x) < 0.001 and abs(v.y) > 0.001:
			print("snapping x")
			position.x = int((position.x) / 16) * 16 + 8
			print(position)
		if abs(v.y) < 0.001 and abs(v.x) > 0.001:
			print("snapping y")
			position.y = int((position.y) / 16) * 16 + 8
			print(position)

	# This is dumb
	while heading < 0:
		heading += PI*2
	while heading > PI*2:
		heading -= PI*2

	var i = int((-heading + (PI*2) + (PI*2/16)) / (PI*2/8)) % 8
	$Sprite2D.texture.region = Rect2(i * 20, 0, 20, 20)

	var zoom_multiply = 1
	if Input.is_action_just_pressed("zoom_in"):
		zoom_multiply *= 1.5
	if Input.is_action_just_pressed("zoom_out"):
		zoom_multiply /= 1.5
	zoom *= zoom_multiply

	camera.position = position
	camera.zoom = Vector2(zoom, zoom)
	
