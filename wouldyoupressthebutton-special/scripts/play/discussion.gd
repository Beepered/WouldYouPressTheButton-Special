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

@export var rankTiddle: PackedScene


var numRounds = 2*(Global.playerNames.size())
var player_weights = {}
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

@onready var prompts = promptReader.get_text_list()

func _ready() -> void:
	# Initialize points array
	for player in Global.playerNames:
		points[player] = 0
	
	# Initialize the buttons
	skipButton.visible = false
	skipButton.connect("pressed", Callable(self, "on_skip_button_pressed"))

	voteCanvas.visible = false
	voteButton.connect("pressed", Callable(self, "on_vote_button_pressed"))
	noButton.connect("pressed", Callable(self, "on_no_button_pressed"))
	
	# Shuffle prompts
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

	# Display pie chart
	display_pie_chart(pressVotes, Global.playerNames.size() - pressVotes)

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

	# Hide pie chart after a short delay
	await get_tree().create_timer(3.0).timeout
	# Remove all children from PieChart
	for child in $PieChart.get_children():
		$PieChart.remove_child(child)
		child.queue_free()  # Properly free the child nodes

func end_game() -> void:
	prompt.text = "Game Over! Thanks for playing!"
	rankings()
	timer.stop()

func rankings():
	var ranking = ""
	
	var maxTiddleHeight = get_viewport().size.y - 200

	var count = 0
	for player_name in Global.playerNames:
		var tiddle = rankTiddle.instantiate()
		var x = get_viewport().size.x / 2 - ((Global.playerNames.size() * 90) / 2) + (count*90)
		tiddle.position = Vector2(x, 450)
		tiddle.get_node("bar").scale.y = maxTiddleHeight - (maxTiddleHeight - points[player_name] * 15)
		tiddle.get_node("score").text = str(points[player_name])
		tiddle.get_node("name").text = player_name
		add_child(tiddle)
		count += 1
	
	# Display the ranking list
	prompt.text = ranking

func compare_scores(a: String, b: String) -> int:
	# Custom comparison function for sorting (descending order)
	return player_weights[b] - player_weights[a]
	
func display_pie_chart(voted_count: int, not_voted_count: int) -> void:
	# Remove previous pie chart slices manually
	for child in $PieChart.get_children():
		$PieChart.remove_child(child)
		child.queue_free()

	# Total votes
	var total = voted_count + not_voted_count
	if total == 0:
		return # Avoid division by zero
	
	# Calculate angles
	var voted_angle = (voted_count / total) * TAU # TAU = 2 * PI
	var not_voted_angle = TAU - voted_angle
	
	# Create polygons for pie slices
	var voted_slice = Polygon2D.new()
	var not_voted_slice = Polygon2D.new()
	
	# Define circle properties
	var center = Vector2(200, 200) # Center of the chart
	var radius = 100               # Radius of the chart
	var num_segments = 32          # Smoothness of the slices

	# Generate points for the voted slice
	var voted_points = [center]
	for i in range(num_segments + 1):
		var angle = i * (voted_angle / num_segments)
		voted_points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	voted_slice.polygon = voted_points
	voted_slice.color = Color(0.2, 0.8, 0.2) # Green for voted

	# Generate points for the not-voted slice
	var not_voted_points = [center]
	for i in range(num_segments + 1):
		var angle = voted_angle + i * (not_voted_angle / num_segments)
		not_voted_points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	not_voted_slice.polygon = not_voted_points
	not_voted_slice.color = Color(0.8, 0.2, 0.2) # Red for not voted

	$PieChart.add_child(voted_slice)
	$PieChart.add_child(not_voted_slice)

	# Position the PieChart slightly higher from the bottom
	var pie_chart_width = 400
	var pie_chart_height = 200
	var screen_center = get_viewport().size.x / 2
	var screen_bottom_offset = 250 # Adjust this to raise the pie chart

	# Set the position of the pie chart
	$PieChart.position = Vector2(screen_center - pie_chart_width / 2, get_viewport().size.y - pie_chart_height - screen_bottom_offset)
