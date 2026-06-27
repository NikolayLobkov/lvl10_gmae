@tool
extends CompositorEffect
class_name Ascii1

@export_range(4.0, 64.0, 2.0) var char_width: float = 8.0
@export_range(4.0, 64.0, 2.0) var char_height: float = 8.0
@export_range(1.0, 16.0, 1.0) var symbol_variety: float = 1.0
@export var font_texture_path: String = "res://Shaders/ComputeShader/CompositorEffects/ASCII.jpg"

var rd : RenderingDevice
var shader : RID
var pipeline : RID
var linear_sampler : RID
var font_texture : RID

func _init() -> void:
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
	
	var shader_file : RDShaderFile = load("uid://cobv6uorcqnxb")
	if not shader_file:
		print("❌ Шейдер не найден")
		return
	
	shader = rd.shader_create_from_spirv(shader_file.get_spirv())
	if not shader.is_valid():
		print("❌ Ошибка создания шейдера")
		return
	
	pipeline = rd.compute_pipeline_create(shader)
	if not pipeline.is_valid():
		print("❌ Ошибка создания pipeline")
		return
	
	# Создать sampler
	var sampler_state : RDSamplerState = RDSamplerState.new()
	sampler_state.min_filter = RenderingDevice.SAMPLER_FILTER_LINEAR
	sampler_state.mag_filter = RenderingDevice.SAMPLER_FILTER_LINEAR
	linear_sampler = rd.sampler_create(sampler_state)
	
	# Загрузить текстуру как Image и создать RID
	var font_img = load(font_texture_path)

	if font_img is CompressedTexture2D:
		font_img = font_img.get_image()

	if font_img is Image:
		# Убедись что формат RGBA8
		if font_img.get_format() != Image.FORMAT_RGBA8:
			font_img.convert(Image.FORMAT_RGBA8)
		
		var rd_format = RDTextureFormat.new()
		rd_format.format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM
		rd_format.width = font_img.get_width()
		rd_format.height = font_img.get_height()
		rd_format.usage_bits = RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
		
		var rd_view = RDTextureView.new()
		font_texture = rd.texture_create(rd_format, rd_view, [font_img.get_data()])
		print("✅ Font texture загружена: ", font_img.get_width(), "x", font_img.get_height())
	else:
		print("❌ Font texture не найдена: ", font_texture_path)

func _render_callback(effect_callback_type: int, render_data: RenderData) -> void:
	if not rd or not pipeline.is_valid() or not font_texture.is_valid():
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
		
		# Screen texture uniform
		var uniform : RDUniform = RDUniform.new()
		uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
		uniform.binding = 0
		uniform.add_id(screen_tex)
		var screen_tex_set : RID = UniformSetCacheRD.get_cache(shader, 0, [uniform])
		
		# Font texture uniform
		var font_uniform : RDUniform = RDUniform.new()
		font_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
		font_uniform.binding = 0
		font_uniform.add_id(linear_sampler)
		font_uniform.add_id(font_texture)
		var font_uniform_set : RID = UniformSetCacheRD.get_cache(shader, 1, [font_uniform])
		
		var push_constants : PackedFloat32Array = PackedFloat32Array([char_width, char_height, symbol_variety, 0.0])
		var bytes = push_constants.to_byte_array()
		
		var compute_list : int = rd.compute_list_begin()
		rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
		rd.compute_list_bind_uniform_set(compute_list, screen_tex_set, 0)
		rd.compute_list_bind_uniform_set(compute_list, font_uniform_set, 1)
		rd.compute_list_set_push_constant(compute_list, bytes, bytes.size())
		rd.compute_list_dispatch(compute_list, x_groups, y_groups, 1)
		rd.compute_list_end()
