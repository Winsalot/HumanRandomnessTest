extends Control

export var Ngram_max = 5
export var nacc_from = 10

onready var button_history = []
var next_press 
var rng = RandomNumberGenerator.new()


var ngram_freq = {}

# [correct, total]
var accuracy = [0.0,0.0]

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	next_press = rng.randi_range(0,1)
	pass # Replace with function body.

func get_curr_ngram(n):
	var last = button_history.slice(0,n-1)
	last.invert()
	return last

# function called after every key choice.
func register_choice(value):
	update_acc(value)
	update_history(value)
	update_frequencies()
	next_press = predict_next()
	update_labels()
	

func update_history(keypress):
	button_history.push_front(keypress)

func update_frequencies():
	for n in range(2, min(Ngram_max,button_history.size())+1):
		var last = get_curr_ngram(n)
		ngram_freq[last] = ngram_freq.get(last,0) + 1

# find the frequencies of next keypresses for specific ngram length.
# here n is ngram length for lookup
func next_freq(n):
	var last = get_curr_ngram(n-1)
	return [ngram_freq.get(last + [0], 0), ngram_freq.get(last+[1], 0)]

func prediction(freq):
	if freq[0] > freq[1]:
		return 0
	if freq[0] < freq[1]:
		return 1
	return rng.randi_range(0,1)

func predict_next():
	for n in range(min(Ngram_max,button_history.size()), 1, -1):
		var freq = next_freq(n)
		if freq == [0, 0]:
			# No data. Try smaller n-gram
			continue
		return prediction(freq)
	# return was not reached. predict randomly:
	return rng.randi_range(0,1)


func update_acc(press):
	if button_history.size()< nacc_from:
		return
	accuracy[1]+=1
	if next_press == press:
		accuracy[0]+=1



func update_labels():
	if button_history.size() < nacc_from+1:
		return
	
	$HBoxContainer/VBoxContainer2/Next_pred.text = "Next press prediction:" + \
	String(next_press)
	$HBoxContainer/VBoxContainer2/Acc.text = "Accuracy: " + \
	String(accuracy[0]/accuracy[1]) + \
	"\n Number of predictions: " + String(accuracy[1])

func _on_Button_A_pressed():
#	print("Button A pressed")
	register_choice(0)
	pass # Replace with function body.


func _on_Button_B_pressed():
#	print("Button B pressed")
	register_choice(1)
	pass # Replace with function body.
