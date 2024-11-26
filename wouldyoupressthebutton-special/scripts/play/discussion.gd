extends CanvasLayer

@onready var progressBar = $"../ProgressBar"
@onready var timer = $Timer
@onready var prompt = $prompt
var roundNum = 1

func _ready() -> void:
	stage()

func _process(delta: float) -> void:
	progressBar.value = (timer.time_left / timer.wait_time) * 100

func stage():
	var time = 0;
	match roundNum:
		1:
			prompt.text = "stage 1: show initial prompt"
			time = 1
		2:
			prompt.text = "stage 1: vote 1"
			time = 1#Global.voteTime
		3:
			prompt.text = "stage 2: divide roles"
			time = 1#Global.discussTime
		4:
			prompt.text = "stage 3: person A present"
			time = 1#Global.discussTime
		5:
			prompt.text = "stage 3: person B present"
			time = 1#Global.discussTime
		6:
			prompt.text = "stage 4: vote 2"
			time = 1#Global.voteTime
			roundNum = 1
		_:
			prompt.text = "default"
			time = 2
			roundNum = 1
	roundNum += 1
	timer.wait_time = time
	timer.timeout.connect(stage)
	timer.start()
