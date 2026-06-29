class_name StateComponent
extends Node


enum State
{
	IDLE,
	PATROL,
	SEARCH,
	CHASE,
	ATTACK,
	DEAD
}

signal changed(old_state,new_state)

var current := State.IDLE


func set_state(value:State):

	if value == current:
		return

	var old = current
	current = value

	changed.emit(old,current)
