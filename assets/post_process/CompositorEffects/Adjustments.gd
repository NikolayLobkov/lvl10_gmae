@tool
extends CompositorEffect
class_name Adjustments

@export_range(0.0, 2.0, 0.01)
var brightness: float = 1.0

@export_range(0.0, 2.0, 0.01)
var saturation: float = 1.0

var rd: RenderingDevice
var shader: RID
var pipeline: RID

func _init() -> void:
	RenderingServer.call_on_render_thread(initialize_shader)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if pipeline.is_valid():
			RenderingServer.free_rid(pipeline)

		if shader.is_valid():
			RenderingServer.free_rid(shader)


func initialize_shader() -> void:
	rd = RenderingServer.get_rendering_device()

	if rd == null:
		push_error("RenderingDevice not found.")
		return

	var shader_file: RDShaderFile = load("uid://dm6w12rufl872")
	if shader_file == null:
		push_error("Shader file not found.")
		return

	shader = rd.shader_create_from_spirv(shader_file.get_spirv())

	if !shader.is_valid():
		push_error("Failed to create shader.")
		return

	pipeline = rd.compute_pipeline_create(shader)

	if !pipeline.is_valid():
		push_error("Failed to create compute pipeline.")


func _render_callback(_effect_callback_type: int, render_data: RenderData) -> void:
	if rd == null or !pipeline.is_valid():
		return

	var scene_buffers := render_data.get_render_scene_buffers() as RenderSceneBuffersRD
	if scene_buffers == null:
		return

	var size := scene_buffers.get_internal_size()

	if size.x == 0 or size.y == 0:
		return

	var x_groups := (size.x + 15) / 16
	var y_groups := (size.y + 15) / 16

	var push_constants := PackedFloat32Array([
		brightness,
		saturation
	])

	var push_bytes := push_constants.to_byte_array()

	for view in range(scene_buffers.get_view_count()):
		var screen_tex := scene_buffers.get_color_layer(view)

		var uniform := RDUniform.new()
		uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
		uniform.binding = 0
		uniform.add_id(screen_tex)

		var uniform_set := UniformSetCacheRD.get_cache(shader, 0, [uniform])

		var compute_list := rd.compute_list_begin()
		rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
		rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
		rd.compute_list_set_push_constant(compute_list, push_bytes, push_bytes.size())
		rd.compute_list_dispatch(compute_list, x_groups, y_groups, 1)
		rd.compute_list_end()
