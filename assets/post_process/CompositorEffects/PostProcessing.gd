@tool
extends CompositorEffect
class_name SimplePostProcess

@export_range(0.0, 2.0, 0.01) var brightness:float=1.0
@export_range(0.0, 2.0, 0.01) var saturation:float=1.0
@export_range(0, 256, 2, "prefer_slider") var pixel_size: float = 4
@export_range(0, 100, 0.01, "prefer_slider") var blur_radius: float = 4
var rd : RenderingDevice
var shader : RID
var pipeline : RID

func _init() -> void:
	RenderingServer.call_on_render_thread(initialize_shader)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if shader.is_valid():
			RenderingServer.free_rid(shader)

func initialize_shader() -> void:
	rd = RenderingServer.get_rendering_device()
	if not rd:
		print("❌ RenderingDevice не найден!")
		return
	
	var shader_file : RDShaderFile = load("uid://c3baoksx22gln")
	if not shader_file:
		print("❌ Шейдер не найден по пути: res://Shaders/ComputeShader/PostProcess.glsl")
		return
	
	shader = rd.shader_create_from_spirv(shader_file.get_spirv())
	if not shader.is_valid():
		print("❌ Ошибка создания шейдера на GPU")
		return
	
	pipeline = rd.compute_pipeline_create(shader)
	if not pipeline.is_valid():
		print("❌ Ошибка создания pipeline")
		return

func _render_callback(effect_callback_type: int, render_data: RenderData) -> void:
	if not rd or not pipeline.is_valid():
		return
	
	var scene_buffers : RenderSceneBuffersRD = render_data.get_render_scene_buffers()
	if not scene_buffers:
		return
	
	var size : Vector2i = scene_buffers.get_internal_size()
	if size.x == 0 or size.y == 0:
		return
	
	var x_groups : int = (size.x + 15) / 16
	var y_groups : int = (size.y + 15) / 16
	
	for view in scene_buffers.get_view_count():
		var screen_tex : RID = scene_buffers.get_color_layer(view)
		
		var uniform : RDUniform = RDUniform.new()
		uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
		uniform.binding = 0
		uniform.add_id(screen_tex)
		
		var screen_tex_set : RID = UniformSetCacheRD.get_cache(shader, 0, [uniform])

		var push_constants : PackedFloat32Array = PackedFloat32Array()
		push_constants.append(brightness)
		push_constants.append(saturation)
		push_constants.append(pixel_size)
		push_constants.append(blur_radius)

		var bytes = push_constants.to_byte_array()

		var compute_list : int = rd.compute_list_begin()
		rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
		rd.compute_list_bind_uniform_set(compute_list, screen_tex_set, 0)
		rd.compute_list_set_push_constant(compute_list, bytes, bytes.size())
		rd.compute_list_dispatch(compute_list, x_groups, y_groups, 1)
		rd.compute_list_end()
