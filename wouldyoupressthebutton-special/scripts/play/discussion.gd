extends CanvasLayer

@onready var progressBar = $"../ProgressBar"
@onready var timer = $Timer
@onready var prompt = $prompt

@export var voteButton: Button

var stageNum = 1
var currentRound = 1
var roles_assigned = {}
var voteCount = 0 # Total votes for the current voting phase
var currentPlayer: String = "" # The player currently voting
var hasVoted = [] # Tracks which players have voted

func _ready() -> void:
	# Initialize the voteButton
	voteButton.visible = false
	voteButton.connect("pressed", Callable(self, "on_vote_button_pressed"))
	stage()

func _process(_delta: float) -> void:
	progressBar.value = (timer.time_left / timer.wait_time) * 100

func stage() -> void:
	# Disconnect the signal to prevent duplicate connections
	if timer.is_connected("timeout", Callable(self, "stage")):
		timer.disconnect("timeout", Callable(self, "stage"))
	
	var time = 0
	print("Stage Num:", stageNum)
	match stageNum:
		1: # Show the initial prompt
			prompt.text = "Prompt: Would you press the button?"
			time = 1
		2: # Each player votes on the prompt
			prompt.text = "Stage 1: Voting Round"
			await start_voting_phase()
		3: # Assign roles to players
			assign_roles()
			time = 5
		4: # Discussion phase
			prompt.text = "Stage 3: Discussion Phase"
			time = Global.discussTime
		5: # Second voting round
			prompt.text = "Stage 4: Final Voting Round"
			await start_voting_phase()
		6: # Scoring and preparation for the next round
			calculate_scores()
			currentRound += 1
			if currentRound > Global.numRounds:
				end_game()
				return
			prompt.text = "Scoring Complete! Starting next round..."
			time = 3 # Delay before next round
			stageNum = 0 # Reset stage for the next round
		_:
			prompt.text = "Default Stage"
			time = 2
	stageNum += 1

	timer.wait_time = time
	timer.timeout.connect(Callable(self, "stage")) # Reconnect the signal
	timer.start()

func start_voting_phase() -> void:
	# Reset voting data
	voteCount = 0
	hasVoted.clear()
	currentPlayer = "" # Reset the current player

	# Show the voting button
	voteButton.visible = true

	# Each player votes in turn
	for i in range(Global.playerNames.size()):
		var player = Global.playerNames[i]
		currentPlayer = player # Set the current player
		print("Player Turn:", player) # Debugging output
		prompt.text = "%s, press or don't" % player
		
		# Set timer wait time and start
		timer.wait_time = Global.voteTime# / Global.playerNames.size()
		timer.start()

		# Wait for the timer to finish
		await timer.timeout

	# Hide the voting button and stop the timer
	voteButton.visible = false
	timer.stop()
	print("Voting phase complete. Total votes:", voteCount)

func on_vote_button_pressed() -> void:
	# If currentPlayer is null, ignore the button press
	if currentPlayer == "":
		print("No player is currently voting.")
		return
	
	# Check if the player has already voted
	if hasVoted.has(currentPlayer):
		print("Player %s has already voted." % currentPlayer)
		return

	# Increment vote count and mark player as having voted
	voteCount += 1
	hasVoted.append(currentPlayer)
	print("Player %s voted. Total votes: %d" % [currentPlayer, voteCount])

	# After voting, reset currentPlayer to null
	currentPlayer = ""
	
func assign_roles() -> void:
	var persuader = Global.playerNames[randi() % Global.playerNames.size()]
	var opposer = Global.playerNames[randi() % Global.playerNames.size()]
	while opposer == persuader:
		opposer = Global.playerNames[randi() % Global.playerNames.size()]
	roles_assigned["Persuader"] = persuader
	roles_assigned["Opposer"] = opposer
	prompt.text = "%s must convince to press, %s must convince not to press!" % [persuader, opposer]

func calculate_scores() -> void:
	# Placeholder for scoring logic
	prompt.text = "Calculating scores..."

func end_game() -> void:
	prompt.text = "Game Over! Thanks for playing!"
	timer.stop()
