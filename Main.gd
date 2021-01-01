extends Control


onready var button_history = []
var next_press 
var rng = RandomNumberGenerator.new()

var ngram_history = {}

# [correct, total]
var accuracy = [0,0]

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	next_press = rng.randi_range(0,1)
	pass # Replace with function body.

# function called after every key choice.
func register_choice(value):
	update_history()
	

func update_history(keypress):
	button_history.push_front(keypress)
	$HBoxContainer/VBoxContainer2/ButtonHistory.text = "History of keypresses: " + \
	String(button_history)
	update_frequencies()
	next_press_likelihood()
	update_acc(keypress)

# Update ngram frequencies in Ngrams file
func update_frequencies():
	if button_history.size()<5:
		return
	var last_5 = button_history.slice(0,4)
	last_5.invert()
	$"HBoxContainer/VBoxContainer2/Last 5".text = "Last 5 presses: " + \
	String(last_5)
	Ngrams.ngram_5[last_5] = 1 + Ngrams.ngram_5[last_5] 
	$"HBoxContainer/VBoxContainer2/Frequency of last 5".text = "Frequency of last 5 ngrams: " +\
	String(Ngrams.ngram_5[last_5])

# takes last 4 pressess and predicts next keypress:
func next_press_likelihood():
	if button_history.size()<5:
		next_press = rng.randi_range(0,1)
		return
	var last_4 = button_history.slice(0,3)
	last_4.invert()
	
	var next_likelihood = [Ngrams.ngram_5[last_4 + [0]], \
	Ngrams.ngram_5[last_4 + [1]]]
	if Ngrams.ngram_5[last_4 + [0]] == Ngrams.ngram_5[last_4 + [1]]:
		next_press = rng.randi_range(0,1)
	if Ngrams.ngram_5[last_4 + [0]] > Ngrams.ngram_5[last_4 + [1]]:
		next_press = 0
	if Ngrams.ngram_5[last_4 + [0]] < Ngrams.ngram_5[last_4 + [1]]:
		next_press = 1
	$"HBoxContainer/VBoxContainer2/Next pred".text = String(next_likelihood) +\
	"\nNext prediction: " + String(next_press)

func update_acc(press):
	accuracy[1]+=1
	if next_press == press:
		accuracy[0]+=1
	print(accuracy)

func _on_Button_A_pressed():
	print("Button A pressed")
	update_history(0)
	pass # Replace with function body.


func _on_Button_B_pressed():
	print("Button B pressed")
	update_history(1)
	pass # Replace with function body.
