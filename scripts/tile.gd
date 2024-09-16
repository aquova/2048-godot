extends Node2D

@onready var rect = $ColorRect
@onready var label = $Label

const COLORS: Array[Color] = [
	Color.BLACK, 			# Unused
	Color.LIGHT_SKY_BLUE,   # 2
	Color.SKY_BLUE, 		# 4
	Color.DEEP_SKY_BLUE, 	# 8
	Color.AQUA, 			# 16
	Color.DODGER_BLUE, 		# 32
	Color.BLUE, 			# 64
	Color.MEDIUM_BLUE, 		# 128
	Color.NAVY_BLUE, 		# 256
	Color.MIDNIGHT_BLUE, 	# 1024
	Color.DARK_GREEN, 		# 2048
	Color.SEA_GREEN, 		# 4096
]

# The value of the tile will be 2^value
var value: int

func get_value() -> int:
	return self.value

func promote():
	var promoted = self.value + 1
	self.set_value(promoted)

func set_value(v: int):
	self.value = v
	label.text = str(2 ** v)
	rect.color = COLORS[self.value]

func set_size(size: int):
	var size_vec = Vector2(size, size)
	rect.size = size_vec
	label.size = size_vec
