extends Node

signal sequence_started(sequence: DialogueSequence)		## Сеанс начался (первая реплика ещё не показана)
signal line_started(line: DialogueLine, index: int, total: int)	## Показана конкретная реплика
signal sequence_finished(sequence: DialogueSequence)			## Сеанс закончился (естественно или через прерывание)


var _queue: Array[DialogueSequence] = []
var _current_sequence: DialogueSequence
var _current_index: int = -1
var _line_timer: Timer
var _played_once: Dictionary = {}

func _ready() -> void:
	_line_timer = Timer.new()
	_line_timer.one_shot = true
	add_child(_line_timer)
	_line_timer.timeout.connect(_advance_line)

func play(sequence: DialogueSequence) -> void:
	if sequence == null or sequence.lines.is_empty():
		return
	if sequence.one_shot and _played_once.get(sequence.id, false):
		return

	if _current_sequence == null:
		_start_sequence(sequence)
		return

	if sequence.interrupt_current or sequence.priority > _current_sequence.priority:
		_start_sequence(sequence)  # текущая передача обрывается
	else:
		_queue.append(sequence)
		_queue.sort_custom(func(a, b): return a.priority > b.priority)

func _start_sequence(sequence: DialogueSequence) -> void:
	_current_sequence = sequence
	_current_index = -1
	_played_once[sequence.id] = true
	sequence_started.emit(sequence)
	_advance_line()

func _advance_line() -> void:
	_current_index += 1
	if _current_index >= _current_sequence.lines.size():
		_finish_sequence()
		return
	var line: DialogueLine = _current_sequence.lines[_current_index]
	line_started.emit(line, _current_index, _current_sequence.lines.size())
	_line_timer.start(line.get_duration())

func _finish_sequence() -> void:
	var finished := _current_sequence
	sequence_finished.emit(finished)
	_current_sequence = null
	if not _queue.is_empty():
		_start_sequence(_queue.pop_front())
