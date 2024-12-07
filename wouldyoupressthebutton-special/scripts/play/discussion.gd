extends CanvasLayer

@onready var promptReader = $"../PromptReader"

@onready var progressBar = $"../ProgressBar"
@onready var timer = $"../Timer"
@onready var title = $"../title"
@onready var prompt = $"../prompt"
@onready var instructions = $"../instructions"

@onready var skipButton = $SkipButton

@onready var voteCanvas = $"../Voting"
@onready var voteButton = $"../Voting/YesButton"
@onready var noButton = $"../Voting/NoButton"
@export var initialWeight = 10 # Default weight for each player

@export var rankTiddle: PackedScene


var numRounds = 2*(Global.playerNames.size())
var player_weights = {}
var stageNum = 1
var currentRound = 1
var roles_assigned = {}
var currentPlayer: String = ""
var hasVoted = []
var finalVotes = {}

var chosenPrompt
var persuader; var opposer
var points = {} # ex: {a:2, b:0, c:1, d:5, e:2}

@onready var prompts = promptReader.get_text_list()

func _ready() -> void:
	# get randomized array of prompts
	randomize()
	prompts.shuffle()
	print(numRounds)
	# Initialize player weights
	reset_player_weights()
	
	# Initialize points array
	for i in Global.playerNames:
		points[i] = 0
	
	# Initialize the buttons
	skipButton.visible = false
	skipButton.connect("pressed", Callable(self, "on_skip_button_pressed"))

	voteCanvas.visible = false
	voteButton.connect("pressed", Callable(self, "on_vote_button_pressed"))
	noButton.connect("pressed", Callable(self, "on_no_button_pressed"))
	
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
			title.visible = false
			instructions.visible = false
			chosenPrompt = prompts[currentRound - 1]
			prompt.text = chosenPrompt
			time = 4
		2: # Assign roles to players
			title.text = "Stage 2: Becoming Czar"
			title.visible = true
			assign_roles()
			time = 5
		3: # Discussion phase
			title.text = "Stage 3: Discussion Phase"
			instructions.visible = true
			instructions.text = chosenPrompt
			prompt.text = "%s, convince people to press" % [persuader]
			skipButton.visible = true
			time = Global.discussTime
		4:
			title.text = "Stage 3: Discussion Phase 2"
			instructions.visible = true
			instructions.text = chosenPrompt
			prompt.text = "%s, convince people NOT to press!" % [opposer]
			skipButton.visible = true
			time = Global.discussTime
		5: # voting
			title.text = "Stage 4: Final Voting Round"
			skipButton.visible = false
			await start_voting_phase()
			time = 1
		6: # Scoring and preparation for the next round
			calculate_scores()
			time = 3
			currentRound += 1
			if currentRound > numRounds:
				end_game()
				return
			stageNum = 0 # Reset stage for the next round
	stageNum += 1

	timer.wait_time = max(time, 0.1)
	timer.timeout.connect(Callable(self, "stage")) # Reconnect the signal
	timer.start()

func start_voting_phase() -> void:
	# Reset voting data
	hasVoted.clear()
	finalVotes = {}
	currentPlayer = "" # Reset the current player

	# Show the voting canvas
	voteCanvas.visible = true
	instructions.visible = true
	prompt.text = chosenPrompt

	# Each player votes in turn
	for i in range(Global.playerNames.size()):
		var player = Global.playerNames[i]
		currentPlayer = player # Set the current player
		if currentPlayer == persuader or player == opposer:
			continue
		print("Player Turn:", player) # Debugging output
		instructions.text = "%s, press or don't" % player
		
		timer.wait_time = Global.voteTime
		timer.start()

		await timer.timeout

	# Hide the voting button and stop the timer
	voteCanvas.visible = false
	timer.stop()
	print("Voting phase complete. Total votes:", hasVoted.size())

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
	hasVoted.append(currentPlayer)
	finalVotes[currentPlayer] = 1
	print("Player %s voted. Total votes: %d" % [currentPlayer, hasVoted.size()])
	
	# After voting, reset currentPlayer to null
	currentPlayer = ""
	
	timer.stop()
	timer.emit_signal("timeout")
	
func on_no_button_pressed() -> void:
	currentPlayer = ""
	timer.stop()
	timer.emit_signal("timeout")

func assign_roles() -> void:
	# Weighted random selection for persuader
	persuader = weighted_random_pick()
	
	# Weighted random selection for opposer (ensure it's not the same as persuader)
	opposer = weighted_random_pick([persuader])
	
	# Assign roles
	roles_assigned["Persuader"] = persuader
	roles_assigned["Opposer"] = opposer
	
	# Update weights (decrease for selected players)
	player_weights[persuader] -= 2
	player_weights[opposer] -= 2
	
	# Update prompt
	prompt.text = "Prepare Yourselves:\n
		%s must convince the group to press the button\n
		%s must convince the group NOT to press the button" % [persuader, opposer]

func on_skip_button_pressed():
	timer.stop()
	timer.emit_signal("timeout")

func calculate_scores() -> void:
	# Placeholder for scoring logic
	prompt.text = "Calculating scores..."
	var pressVotes = 0
	var dontPressVotes = 0
	
	instructions.visible = false

	# Count final votes and track changes
	for player in Global.playerNames:
		if player == persuader or player == opposer:
			continue
		var finalVote = finalVotes.get(player, 0) # Default to 0 if not voted
		if finalVote:
			points[persuader] += 1
			pressVotes += 1
		else:
			points[opposer] += 1
			dontPressVotes += 1

	# Determine the winner
	var winner = ""
	if pressVotes > dontPressVotes:
		winner = persuader
	elif dontPressVotes > pressVotes:
		winner = opposer
	else:
		winner = "Tie"

	# Display results
	prompt.text = "Pressed: %d, Didn't Press: %d\nWinner: %s" % [
		pressVotes, dontPressVotes, winner
	]

func end_game() -> void:
	prompt.text = "Game Over! Thanks for playing!"
	rankings()
	timer.stop()

func reset_player_weights() -> void:
	# Reset all player weights to the initial weight
	for player in Global.playerNames:
		player_weights[player] = initialWeight

func weighted_random_pick(exclude: Array = []) -> String:
	# Filter eligible players manually
	var eligible_players = []
	for player in Global.playerNames:
		if not exclude.has(player):
			eligible_players.append(player)
	
	# Create a cumulative weight list
	var total_weight = 0
	var cumulative_weights = []
	for player in eligible_players:
		total_weight += player_weights.get(player, initialWeight)
		cumulative_weights.append(total_weight)
	
	# Pick a random number in the range of total weight
	var rand_value = randi() % total_weight
	
	# Find the player corresponding to the random value
	for i in range(cumulative_weights.size()):
		if rand_value < cumulative_weights[i]:
			return eligible_players[i]
	
	return eligible_players[0] # Fallback (should not occur)

func rankings():
	var ranking = ""
	
	var maxTiddleHeight = get_viewport().size.y - 200

	var count = 0
	for name in Global.playerNames:
		var tiddle = rankTiddle.instantiate()
		var x = get_viewport().size.x / 2 - ((Global.playerNames.size() * 90) / 2) + (count*90)
		tiddle.position = Vector2(x, 450)
		tiddle.get_node("bar").scale.y = maxTiddleHeight - (maxTiddleHeight - points[name] * 15)
		tiddle.get_node("score").text = str(points[name])
		tiddle.get_node("name").text = name
		add_child(tiddle)
		count += 1
	
	# Display the ranking list
	prompt.text = ranking

func compare_scores(a: String, b: String) -> int:
	# Custom comparison function for sorting (descending order)
	return player_weights[b] - player_weights[a]
