extends Resource
class_name DialogueSequence

@export var id: StringName = ""				## возвращает длительность показа
@export var lines: Array[DialogueLine] = []	## возвращает длительность показа
@export var priority: int = 0           	## Чем выше — тем важнее. Используется при конфликте сеансов
@export var interrupt_current: bool = false	## Если true — всегда обрывает текущий сеанс, независимо от приоритета
@export var one_shot: bool = true       ## Сыграть только один раз за сессию (см. ограничения ниже)
@export var open_sfx: AudioStream       ## Звук открытия  канала
@export var close_sfx: AudioStream		## Звук закрытия канала
