extends Node2D

@onready var bg = $Background
@onready var canvas = $Background/Canvas
@onready var tiles = $Tiles
@onready var empty_tile_scene = preload("res://scenes/empty_tile.tscn")
@onready var tile_scene = preload("res://scenes/tile.tscn")
@onready var timer = $CreationTimer

const FOUR_ODDS: int = 20 # 1 / X
@export var TILE_MARGIN: int = 10
@export var TILE_SIZE: int = 50
const SLIDE_SPEED: float = 0.1

enum DIRS {
	UP,
	DOWN,
	LEFT,
	RIGHT,
}

signal add_points(points: int)
signal game_over()

var grid = []
var allow_input = true

func _ready():
	randomize()
	timer.wait_time = SLIDE_SPEED + 0.1
	create_bg()

func new_game():
	self.grid = [
		[null, null, null, null],
		[null, null, null, null],
		[null, null, null, null],
		[null, null, null, null],
	]
	create_tile()

func calc_tile_pos(x: int, y: int) -> Vector2:
	return Vector2(
		TILE_MARGIN + x * (TILE_SIZE + TILE_MARGIN),
		TILE_MARGIN + y * (TILE_SIZE + TILE_MARGIN)
	)
	
func check_gameover() -> bool:
	for x in range(0, 3):
		for y in range(0, 3):
			if not self.grid[y][x] or not self.grid[y + 1][x] or not self.grid[y][x + 1]:
				return false
			var val = self.grid[y][x].get_value()
			if self.grid[y + 1][x].get_value() == val or self.grid[y][x + 1].get_value() == val:
				return false
	return true
	
func create_bg():
	var size = Vector2(TILE_SIZE, TILE_SIZE)
	for x in range(0, 4):
		for y in range(0, 4):
			var tile = empty_tile_scene.instantiate()
			var pos = calc_tile_pos(x, y)
			tile.size = size
			tile.position = pos
			bg.add_child(tile)

func create_tile():
	var x_range = range(0, 4)
	var y_range = range(0, 4)
	x_range.shuffle()
	y_range.shuffle()
	for x in x_range:
		for y in y_range:
			if not self.grid[y][x]:
				var tile = tile_scene.instantiate()
				# Note: This is equal to 4 and 2
				var val = 2 if randi() % FOUR_ODDS == 0 else 1
				tile.call_deferred("set_value", val)
				tile.call_deferred("set_size", TILE_SIZE)
				var pos = calc_tile_pos(x, y)
				tile.position = pos
				self.grid[y][x] = tile
				tiles.add_child(tile)
				return
	assert(false, "Shouldn't be able to reach here")
	
func shift(direction: DIRS):
	if not allow_input:
		return
	var shifted: bool
	match direction:
		DIRS.UP:
			shifted = shift_up()
		DIRS.DOWN:
			shifted = shift_down()
		DIRS.LEFT:
			shifted = shift_left()
		DIRS.RIGHT:
			shifted = shift_right()
	if shifted:
		self.allow_input = false
		timer.start()

func shift_up() -> bool:
	var shifted = false
	for x in range(0, 4):
		for y in range(0, 3):
			for dy in range(y + 1, 4):
				if not self.grid[dy][x]:
					continue
				elif not self.grid[y][x]:
					shifted = true
					move_tile(x, dy, x, y, false)
				elif self.grid[dy][x].get_value() == self.grid[y][x].get_value():
					shifted = true
					move_tile(x, dy, x, y, true)
					break
				else:
					break
	return shifted

func shift_down() -> bool:
	var shifted = false
	for x in range(0, 4):
		for y in range(3, 0, -1):
			for dy in range(y - 1, -1, -1):
				if not self.grid[dy][x]:
					continue
				elif not self.grid[y][x]:
					shifted = true
					move_tile(x, dy, x, y, false)
				elif self.grid[dy][x].get_value() == self.grid[y][x].get_value():
					shifted = true
					move_tile(x, dy, x, y, true)
					break
				else:
					break
	return shifted

func shift_left() -> bool:
	var shifted = false
	for y in range(0, 4):
		for x in range(0, 3):
			for dx in range(x + 1, 4):
				if not self.grid[y][dx]:
					continue
				elif not self.grid[y][x]:
					shifted = true
					move_tile(dx, y, x, y, false)
				elif self.grid[y][dx].get_value() == self.grid[y][x].get_value():
					shifted = true
					move_tile(dx, y, x, y, true)
					break
				else:
					break
	return shifted
	
func shift_right() -> bool:
	var shifted = false
	for y in range(0, 4):
		for x in range(3, 0, -1):
			for dx in range(x - 1, -1, -1):
				if not self.grid[y][dx]:
					continue
				elif not self.grid[y][x]:
					shifted = true
					move_tile(dx, y, x, y, false)
				elif self.grid[y][dx].get_value() == self.grid[y][x].get_value():
					shifted = true
					move_tile(dx, y, x, y, true)
					break
				else:
					break
	return shifted

func move_tile(start_x: int, start_y: int, end_x: int, end_y: int, promote: bool):
	if promote:
		self.grid[start_y][start_x].promote()
		self.grid[end_y][end_x].queue_free()
		add_points.emit(2 ** self.grid[start_y][start_x].get_value())
	self.grid[end_y][end_x] = self.grid[start_y][start_x]
	self.grid[start_y][start_x] = null
	var tween = create_tween()
	var pos = calc_tile_pos(end_x, end_y)
	tween.tween_property(self.grid[end_y][end_x], "position", pos, SLIDE_SPEED)
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT_IN)

func _on_creation_timer_timeout():
	create_tile()
	if check_gameover():
		game_over.emit()
		return
	self.allow_input = true
