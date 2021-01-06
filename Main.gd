extends Control

export var Ngram_max = 5
export var nacc_from = 10

onready var button_history = []
#onready var label_base = preload("res://Label.tscn")

var next_press 
var rng = RandomNumberGenerator.new()
var z_score = "Keep Pressing Buttons"
var p_value = "Keep Pressing Buttons"


# Number of history labels to show. 
var n_history_lab = 5
# format: vector of [line_reference (label node)]
var history_lab = []

var ngram_freq = {}

# [correct, total]
var accuracy = [0.0,0.0]

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	next_press = rng.randi_range(0,1)
	pass # Replace with function body.

func _process(delta):
	n_history_lab = $MarginContainer/Everything/OtherInfo/History.get_size().y/18
	while history_lab.size() > n_history_lab:
		history_lab[0].queue_free()
		history_lab.pop_front()


func get_curr_ngram(n):
	var last = button_history.slice(0,n-1)
	last.invert()
	return last

# function called after every key choice.
func register_choice(value):
	update_acc(value) # updates accuracy vector
	update_history(value) # updates history vector
	update_hist_labs(value) # updates history panel (front end)
	update_frequencies() # upates learned sequences and their frequencies
	next_press = predict_next()
	update_z()
	update_p_val()
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

func update_z():
	if accuracy[1]<10:
		return
	var z = (accuracy[0] - (accuracy[1]/2.0) + 0.5) / (sqrt(accuracy[1] * 0.25))
	z_score=String(z)

func update_p_val():
	if accuracy[1]<11:
		return
	var z = z_score
	if float(z) < 1:
		p_value = "> 0.15"
	if float(z) > 1:
		p_value = "<0.15"
	if float(z) > 1.3:
		p_value = "<0.10"
	if float(z) > 1.65:
		p_value = "<0.05"
	if float(z) > 2.33:
		p_value = "<0.01"
	if float(z) > 3.1:
		p_value = "<0.001"
	if float(z) > 3.7:
		p_value = "<0.0001"




func update_labels():
#	if button_history.size() < nacc_from+1:
#		return
	
	# Label of next prediction. Updated regardless if visible:
	if button_history.size() > nacc_from:
		$MarginContainer/Everything/Predictions/HBoxPred/NextPredLab.text = \
		"Next choice prediction: " + String(next_press)
	
	$MarginContainer/Everything/OtherInfo/StatsAbout/Stats/VBoxContainer/NCount.text = \
	"N: " + String(button_history.size())
	
	if button_history.size() > nacc_from+1:
		$MarginContainer/Everything/OtherInfo/StatsAbout/Stats/VBoxContainer/Accuracy.text = \
		"Accuracy: " + String(accuracy[0]/accuracy[1]*100) + "%"
	
	$MarginContainer/Everything/OtherInfo/StatsAbout/Stats/VBoxContainer/LearnedInfo.text = \
	"Learned sequences: " + String(ngram_freq.size())
	
	# Z score and p value:
	if button_history.size() > nacc_from+10:
		$MarginContainer/Everything/OtherInfo/StatsAbout/Stats/VBoxContainer/ZScore.text = \
		"Z score: " + z_score
		$MarginContainer/Everything/OtherInfo/StatsAbout/Stats/VBoxContainer/PVal.text = \
		"p-value: " + p_value

func update_hist_labs(value):
	var text = ""
	var label_base = Label.new()
	
	if button_history.size()> nacc_from+1:
		text = String(button_history.size()) + ". Choice: " + String(value) + \
		", Pred: " + String(next_press) 
	else:
		text = String(button_history.size()) + ". Choice: " + String(value)
	
	$MarginContainer/Everything/OtherInfo/History/HistoryBox.add_child(label_base)
	label_base.text = text
	
	history_lab.push_back(label_base)


func _on_Button_A_pressed():
#	print("Button A pressed")
	register_choice(0)
	pass # Replace with function body.


func _on_Button_B_pressed():
#	print("Button B pressed")
	register_choice(1)
	pass # Replace with function body.


func _on_ShowPredButton_toggled(button_pressed):
	$MarginContainer/Everything/Predictions/HBoxPred/NextPredLab.visible = button_pressed
	pass # Replace with function body.
