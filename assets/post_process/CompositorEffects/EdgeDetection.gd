@tool
extends CompositorEffect
class_name EdgeDetection

@export_range(0.0, 1.0, 0.01) var edge_threshold_min: float = 0.1
@export_range(0.0, 1.0, 0.01) var edge_threshold_max: float = 0.3
@export_range(0.5, 5.0, 0.5) var edge_width: float = 1.0
@export_range(1.0, 100.0, 5.0) var edge_strength: float = 1.0
@export var edge_color: Color = Color.WHITE
@export var background_color: Color = Color.BLACK
var rd : RenderingDevice
var shader : RID
var pipeline : RID
var linear_sampler : RID

func _init() -> void:
	set_needs_normal_roughness(true)
	RenderingServer.call_on_render_thread(initialize_shader)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if shader.is_valid():
			RenderingServer.free_rid(shader)
		if linear_sampler.is_valid():
			RenderingServer.free_rid(linear_sampler)

func initialize_shader() -> void:
	rd = RenderingServer.get_rendering_device()
	if not rd:
		print("❌ RenderingDevice не найден!")
		return
	
	var shader_file : RDShaderFile = load("uid://n1u0cj1qoyh3")
	if not shader_file:
		print("❌ Шейдер не найден по пути: res://Shaders/ComputeShader/EdgeDetection.glsl")
		return
	
	shader = rd.shader_create_from_spirv(shader_file.get_spirv())
	if not shader.is_valid():
		print("❌ Ошибка создания шейдера на GPU")
		return
	
	pipeline = rd.compute_pipeline_create(shader)
	if not pipeline.is_valid():
		print("❌ Ошибка создания pipeline")
		return
	
	var sampler_state : RDSamplerState = RDSamplerState.new()
	sampler_state.min_filter = RenderingDevice.SAMPLER_FILTER_LINEAR
	sampler_state.mag_filter = RenderingDevice.SAMPLER_FILTER_LINEAR
	linear_sampler = rd.sampler_create(sampler_state)

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
		
		# Сначала создай uniform для screen_tex
		var uniform : RDUniform = RDUniform.new()
		uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
		uniform.binding = 0
		uniform.add_id(screen_tex)

		var screen_tex_set : RID = UniformSetCacheRD.get_cache(shader, 0, [uniform])

		var normal_roughness_tex : RID = render_data.get_render_scene_buffers().get_texture("forward_clustered", "normal_roughness")

		if not normal_roughness_tex.is_valid():
			print("❌ normal_roughness_tex не найден!")
			return

		var normal_uniform : RDUniform = RDUniform.new()
		normal_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
		normal_uniform.binding = 0
		normal_uniform.add_id(linear_sampler)
		normal_uniform.add_id(normal_roughness_tex)

		var normal_uniform_set : RID = UniformSetCacheRD.get_cache(shader, 1, [normal_uniform])
		
		var push_constants : PackedFloat32Array = PackedFloat32Array()
		push_constants.append(edge_threshold_min)
		push_constants.append(edge_threshold_max)
		push_constants.append(edge_width)
		push_constants.append(edge_strength)
		push_constants.append(edge_color.r)
		push_constants.append(edge_color.g)
		push_constants.append(edge_color.b)
		push_constants.append(edge_color.a)
		push_constants.append(background_color.r)
		push_constants.append(background_color.g)
		push_constants.append(background_color.b)
		push_constants.append(background_color.a)
		
		var bytes = push_constants.to_byte_array()
		
		# Потом bind оба
		var compute_list : int = rd.compute_list_begin()
		rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
		rd.compute_list_bind_uniform_set(compute_list, screen_tex_set, 0)  # ВАЖНО: set 0
		rd.compute_list_bind_uniform_set(compute_list, normal_uniform_set, 1)
		rd.compute_list_set_push_constant(compute_list, bytes, bytes.size())
		rd.compute_list_dispatch(compute_list, x_groups, y_groups, 1)
		rd.compute_list_end()
