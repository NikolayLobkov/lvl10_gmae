#@icon('res://assets/editor_icons/performance.svg')
extends CanvasLayer


@onready var stats_container: Control = $StatsContainer

@onready var fps_label: Label = $StatsContainer/StatsDisplay/FPSLabel
@onready var memory_label: Label = $StatsContainer/StatsDisplay/MemoryLabel
@onready var objects_label: Label = $StatsContainer/StatsDisplay/ObjectsLabel
@onready var draw_label: Label = $StatsContainer/StatsDisplay/DrawLabel




func _ready() -> void:
	stats_container.hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(false)

func _process(_delta: float) -> void:
	fps_label.text = 'FPS: %.1f (%.2f ms)' % [
		Performance.get_monitor(Performance.TIME_FPS),
		Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	]
	
	memory_label.text = 'Memory: %s\nVideo memory: %s' % [
		format_memory(Performance.get_monitor(Performance.MEMORY_STATIC)),
		format_memory(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED))
	]
	
	objects_label.text = 'Objects: %d\nNodes: %d\nOrphan nodes: %d\nResources: %d' % [
		Performance.get_monitor(Performance.OBJECT_COUNT),
		Performance.get_monitor(Performance.OBJECT_NODE_COUNT),
		Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT),
		Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT),
	]
	
	draw_label.text = 'Primitives: %d\nDraw calls: %d' % [
		Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME),
		Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	]


func format_memory(bytes: float) -> String:
	if bytes < 1024:
		return '%d B' % bytes
	elif bytes < 1024 * 1024:
		return '%.1f KB' % [bytes / 1024]
	else:
		return '%.1f MB' % [bytes / (1024 * 1024)]



func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_F3 and event.is_pressed():
			stats_container.visible = not stats_container.visible


func _on_stats_container_visibility_changed() -> void:
	if not is_node_ready(): return
	set_process(stats_container.visible)
