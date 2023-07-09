extends TileMap

var MAIN_LAYER = 0
var STONE_LAYER = 1

func _ready():
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.seed = randi()
	noise.fractal_octaves = 5
	noise.frequency = 1.0 / 50
	noise.fractal_lacunarity = 2.5

	var noise2 = FastNoiseLite.new()
	noise2.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise2.seed = randi()
	noise2.fractal_octaves = 3
	noise2.frequency = 1.0 / 20
	noise2.fractal_lacunarity = 2.5

	for x in range(0, 300):
		for y in range (0, 150):
			var p = Vector2i(x, y)
			var v = noise.get_noise_2d(x, y)
			if v < -0.2 or (x*x + y*y < 4*4):
				set_cell(MAIN_LAYER, p, 0, Vector2i(0, 0))
				erase_cell(STONE_LAYER, p)
			else:
				set_cell(MAIN_LAYER, p, 0, Vector2i(randi_range(0,1), 1))
				var d = 2.0 * max(1.0 - 2.0*abs(noise2.get_noise_2d(x, y)), 0)
				if v < 0.0:
					erase_cell(STONE_LAYER, p)
				elif v < 0.1*d:
					set_cell(STONE_LAYER, p, 0, Vector2i(0, 4))
				elif v < 0.2*d:
					set_cell(STONE_LAYER, p, 0, Vector2i(0, 3))
				else:					
					set_cell(STONE_LAYER, p, 0, Vector2i(0, 2))

#func _process(delta):
#	pass

func dig_stone(p):
	#set_cell(MAIN_LAYER, p, 0, Vector2i(0, 0))
	var stone_tiledata: TileData = get_cell_tile_data(1, p)
	var stone_custom_data = stone_tiledata.get_custom_data("type") if stone_tiledata else null
	if stone_custom_data == null or stone_custom_data >= 4:
		erase_cell(STONE_LAYER, p)
	else:
		set_cell(STONE_LAYER, p, 0, Vector2i(0, stone_custom_data + 1))

func dig_dirt(p):
	set_cell(MAIN_LAYER, p, 0, Vector2i(0, 0))
	#erase_cell(STONE_LAYER, p)
