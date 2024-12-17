extends Node2D

signal beginMenu

@onready var promptReader = $PromptReader

@onready var timer = $Timer

@onready var mainCanvas = $MainCanvas
@onready var progressBar = $MainCanvas/ProgressBar
@onready var title = $"MainCanvas/title"
@onready var prompt = $"MainCanvas/prompt"
@onready var instructions = $"MainCanvas/instructions"

@onready var discussCanvas = $Discussion
@onready var skipButton = $Discussion/SkipButton

@onready var voteCanvas = $Voting
@onready var countdownText = $Voting/Countdown
@onready var voteButton = $Voting/YesButton
@onready var noButton = $"Voting/NoButton"

@onready var endCanvas = $"Game End"
@onready var winnerName = $"Game End/winner"

@export var rankTiddle: PackedScene

var numRounds = Global.playerNames.size()
var stageNum = 1
var currentRound = 1
var roles_assigned = {}
var currentPlayer: String = ""
var hasVoted = []
var finalVotes = {}
var current_role_index = 0 # Tracks the next player to assign a role

var chosenPrompt
var persuader; var opposer
var points = {} # ex: {a:2, b:0, c:1, d:5, e:2}

var prompts

func get_prompts():
	var load = promptReader.initialize_save(Global.file_path) # get dictionary
	var prompts = []
	if(load.keys().size() < numRounds): # if too few keys then get all custom prompt and then take from default
		for i in load.keys():
			prompts.append(load[i].prompt)
			load[i].chance = 0.1
		promptReader.save_game(Global.file_path, load)
		var defaultLoad = promptReader.initialize_save("default")
		while(prompts.size() < numRounds):
			for i in defaultLoad.keys():
				if(defaultLoad[i].chance >= randf_range(0, 1)):
					prompts.append(defaultLoad[i].prompt)
					defaultLoad[i].chance = 0.1
				else:
					defaultLoad[i].chance += 0.1
		promptReader.save_game("default", defaultLoad)
	else:
		while(prompts.size() < numRounds):
			for i in load.keys():
				if(load[i].chance >= randf_range(0, 1)):
					prompts.append(load[i].prompt)
					load[i].chance = 0.1
				else:
					load[i].chance += 0.1
	promptReader.save_game(Global.file_path, load)
	return prompts

func _ready() -> void:
	# Initialize points array
	for player in Global.playerNames:
		points[player] = 0
	
	mainCanvas.visible = true
	
	discussCanvas.visible = false
	skipButton.connect("pressed", Callable(self, "on_skip_button_pressed"))

	voteCanvas.visible = false
	voteButton.connect("pressed", Callable(self, "on_vote_button_pressed"))
	noButton.connect("pressed", Callable(self, "on_no_button_pressed"))
	
	endCanvas.visible = false
	
	# Shuffle prompts
	prompts = get_prompts()
	randomize()
	prompts.shuffle()
	
	stage()

func _process(_delta: float) -> void:
	progressBar.value = (timer.time_left / timer.wait_time) * 100

func stage() -> void:
	# Disconnect the signal to prevent duplicate connections
	if timer.is_connected("timeout", Callable(self, "stage")):
		timer.disconnect("timeout", Callable(self, "stage"))
	
	var time = 0
	match stageNum:
		1: # Show the initial prompt
			title.text = "Stage 1: Revealing Prompt"
			title.visible = true
			instructions.visible = false
			chosenPrompt = prompts[currentRound - 1]
			prompt.text = chosenPrompt
			time = 8
		2: # Assign roles to players
			title.text = "Stage 2: Assigning Roles"
			title.visible = true
			assign_roles()
			time = 7
		3: # Discussion phase
			title.text = "Stage 3: Discussion Phase 1"
			prompt.text = chosenPrompt
			instructions.visible = true
			instructions.text = "%s, convince the group to press" % [persuader]
			discussCanvas.visible = true
			time = Global.discussTime
		4:
			title.text = "Stage 3: Discussion Phase 2"
			prompt.text = chosenPrompt
			instructions.visible = true
			instructions.text = "%s, convince the group NOT to press!" % [opposer]
			discussCanvas.visible = true
			time = Global.discussTime
		5: # voting
			title.text = "Stage 4: Final Voting Round"
			discussCanvas.visible = false
			await start_voting_phase()
			title.visible = false
			prompt.text = "Calculating Scores"
			instructions.visible = false
			time = 1
		6: # Scoring and preparation for the next round
			title.text + "Stage 5: Revealing Scores"
			title.visible = true
			calculate_scores()
			time = 3
			currentRound += 1
			if currentRound > numRounds:
				timer.wait_time = time
				timer.start()
				end_game()
				return
			stageNum = 0 # Reset stage for the next round
	stageNum += 1
	
	timer.wait_time = time
	timer.timeout.connect(Callable(self, "stage")) # Reconnect the signal
	timer.start()

func start_voting_phase() -> void:
	# Reset voting data
	hasVoted.clear()
	finalVotes = {}
	currentPlayer = "" # Reset the current player
	
	voteCanvas.visible = true
	prompt.visible = false
	instructions.visible = false
	
	await countdown()
	
	# Show voting canvas
	voteButton.visible = true
	noButton.visible = true
	prompt.visible = true
	prompt.text = chosenPrompt
	instructions.visible = true

	# Each player votes in turn
	for i in range(Global.playerNames.size()):
		var player = Global.playerNames[i]
		print(player)
		currentPlayer = player # Set the current player
		if currentPlayer == persuader or player == opposer:
			continue
		instructions.text = "%s, press or don't" % player
		
		timer.wait_time = Global.voteTime
		timer.start()
		await timer.timeout
	
	# Hide the voting button and stop the timer
	voteCanvas.visible = false
	voteButton.visible = false
	noButton.visible = false
	print("Voting phase complete. Total votes:", hasVoted.size())

func countdown():
	countdownText.visible = true
	countdownText.scale = Vector2(1, 1)
	var countdownTime = 3
	var time = countdownTime
	countdownText.text = str(ceil(time))
	for i in range(countdownTime):
		await get_tree().create_timer(0.8).timeout
		time -= 1
		countdownText.text = str((time))
		countdownText.scale *= 1.4
		countdownText.label_settings
	countdownText.visible = false

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
	# Assign roles sequentially
	persuader = Global.playerNames[current_role_index]
	current_role_index = (current_role_index + 1) % Global.playerNames.size()
	opposer = Global.playerNames[current_role_index]
	current_role_index = (current_role_index + 1) % Global.playerNames.size()
	
	# Assign roles
	roles_assigned["Persuader"] = persuader
	roles_assigned["Opposer"] = opposer
	
	# Update prompt
	prompt.text = "Prepare Yourselves:\n%s must convince the group to press the button\n%s must convince the group NOT to press the button" % [persuader, opposer]

func on_skip_button_pressed():
	timer.stop()
	timer.emit_signal("timeout")

func calculate_scores() -> void:
	# Placeholder for scoring logic
	prompt.visible = true
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

func rankings():
	var maxTiddleHeight = get_viewport().size.y - 400

	var count = 0
	var spacing = 100
	var totalPlayers = Global.playerNames.size()
	var leftSide = get_viewport().size.x / 2 - ((totalPlayers / 2) * spacing)

	# Adjust leftSide for even number of players so that the graph is centered
	if totalPlayers % 2 == 0:
		leftSide += spacing / 2  # Shift by half of the spacing to center the bars
	
	# find winner
	var tie: bool = false
	var winners = []
	var winnerPoints: float = 0
	for player_name in Global.playerNames:
		if (points[player_name] > winnerPoints):
			winners = []
			winners.append(player_name)
			winnerPoints = points[player_name]
		elif(points[player_name] == winnerPoints):
			tie = true
			winners.append(player_name)
	
	# tiddles are max height * points/max_points
	for player_name in Global.playerNames:
		var tiddle = rankTiddle.instantiate()
		var x = leftSide + (count * spacing)
		tiddle.position = Vector2(x, 570)
		tiddle.get_node("bar").size.y = maxTiddleHeight * (points[player_name] / winnerPoints)
		tiddle.get_node("score").text = str(points[player_name])
		tiddle.get_node("name").text = player_name
		if winners.has(player_name):
			tiddle.get_node("bar").color = Color(0.8, 0.8, 0.15, 1)
		add_child(tiddle)
		count += 1

	winnerName.text = "Winners:\n" if winners.size() > 1 else "Winner:\n"
	for name in winners:
		winnerName.text += name + " "

func end_game() -> void:
	mainCanvas.visible = false
	endCanvas.visible = true
	rankings()
	timer.stop()

func reset_game():
	# Initialize points array
	for player in Global.playerNames:
		points[player] = 0
	
	mainCanvas.visible = true
	discussCanvas.visible = false
	voteCanvas.visible = false
	endCanvas.visible = false
	
	# Shuffle prompts
	prompts = get_prompts()
	randomize()
	prompts.shuffle()
	
	currentRound = 0
	stage()
