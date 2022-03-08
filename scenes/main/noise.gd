tool
extends Sprite

export var width: int = 512
export var height: int = 512

export var noise: OpenSimplexNoise
export var noise_offset: Vector2 = Vector2.ZERO

export var range_correction: bool = true

export var add_threshold: bool = false
export var threshold: float = 0
export var threshold_color: Color = Color.red

export var generate: bool setget run_generate
export var delete: bool setget run_delete

func run_generate(_b):
	if Engine.is_editor_hint():
		var noise_grid = get_noise_grid()
		
		var img = Image.new()
		img.create(width, height, false, Image.FORMAT_RGB8)
		img.lock()
		for j in height:
			for i in width:
				var sample = noise_grid[j][i]
				if sample == -2:
					img.set_pixel(i, j, threshold_color)
				else:
					img.set_pixel(i, j, Color.from_hsv(0, 0, (sample + 1)/2))
		img.unlock()
		
		var tex = ImageTexture.new()
		tex.create_from_image(img)
		#tex.flags = ...
		
		texture = tex

func get_noise_grid() -> Array:
	var min_sample = 0
	var max_sample = 0
	
	var noise_grid = []
	for j in height:
		var noise_row = []
		for i in width:
			var sample = noise.get_noise_2d(i + noise_offset.x, j + noise_offset.y)
			if range_correction:
				min_sample = min(min_sample, sample)
				max_sample = max(max_sample, sample)
			noise_row.append(sample)
		noise_grid.append(noise_row)
		
	if range_correction:
		for j in height:
			for i in width:
				var current = noise_grid[j][i]
				noise_grid[j][i] = lerp_solver(min_sample, max_sample, -1, 1, current)
	
	if add_threshold:
		for j in height:
			for i in width:
				var current = noise_grid[j][i]
				if current <= threshold:
					noise_grid[j][i] = -2
	
	return noise_grid

func run_delete(_b):
	if Engine.is_editor_hint():
		texture = null

#for (a <= x <= b) linearly-mapped to (c <= y <= d), find y
func lerp_solver(a, b, c, d, x):
	var y = ((x-a)/(b-a))*(d-c)+c
	return y