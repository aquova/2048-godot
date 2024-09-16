extends Node2D

@onready var board = $Board
@onready var start_label = $CanvasLayer/StartLabel
@onready var points_label = $CanvasLayer/PointsLabel
@onready var gameover_label = $CanvasLayer/GameoverLabel
@onready var highscore_label = $CanvasLayer/HighscoreLabel

const SAVE_PATH = "user://2048.sav"

enum STATE {
	MENU,
	PLAYING,
}

var state = STATE.MENU
var points = 0
var highscore = 0

func _ready():
	highscore = load_game()
	highscore_label.text = "High Score: " + str(self.highscore)

func _process(_delta: float):
	match state:
		STATE.MENU:
			if Input.is_action_just_pressed("ui_accept"):
				state = STATE.PLAYING
				start_label.visible = false
				gameover_label.visible = false
				board.new_game()
		STATE.PLAYING:
			check_input()

func check_input():
	if Input.is_action_just_pressed("ui_up"):
		board.shift(board.DIRS.UP)
	elif Input.is_action_just_pressed("ui_down"):
		board.shift(board.DIRS.DOWN)
	elif Input.is_action_just_pressed("ui_left"):
		board.shift(board.DIRS.LEFT)
	elif Input.is_action_just_pressed("ui_right"):
		board.shift(board.DIRS.RIGHT)
		
func load_game() -> int:
	var file = ConfigFile.new()
	var err = file.load(SAVE_PATH)
	if err != OK:
		return 0
	return file.get_value("Player1", "score", 0)

func save_game(score: int):
	var file = ConfigFile.new()
	file.set_value("Player1", "score", score)
	file.save(SAVE_PATH)

func _on_board_add_points(new_points: int):
	self.points += new_points
	points_label.text = "Points: " + str(self.points)

func _on_board_game_over():
	self.state = STATE.MENU
	self.gameover_label.visible = true
	self.start_label.visible = true
	if self.points > self.highscore:
		self.highscore = self.points
		highscore_label.text = "High Score: " + str(self.highscore)
		save_game(self.points)
