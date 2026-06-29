extends Resource
class_name DialogueLine

@export var speaker_id: StringName = "" ## Идентификатор говорящего (для логики, не для отображения)
@export var speaker_name: String = ""	## Имя/позывной, выводится в HUD
@export var portrait: Texture2D			## Иконка говорящего
@export_multiline var text: String = ""	## Текст реплики
@export var voice_clip: AudioStream		## Озвучка (опционально)
@export var min_duration: float = 1.5	## Минимальное время показа, если нет voice_clip
@export var duration_per_char: float = 0.05 ## Сек. на символ — для авторасчёта длительности по тексту
@export var tint: Color = Color.WHITE		## Цвет рамки/имени (например, свой/чужой, тип шифровки)

## возвращает длительность показа
func get_duration() -> float:
	if voice_clip:
		return voice_clip.get_length()
	return max(min_duration, text.length() * duration_per_char)
