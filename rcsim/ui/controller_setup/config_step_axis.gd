extends ConfigStepBase
class_name ConfigStepAxis


enum GamepadStick {
	LEFT,
	RIGHT,
}

enum GamepadStickDirection {
	HORIZONTAL,
	VERTICAL,
}


@export var stick: GamepadStick
@export var direction: GamepadStickDirection

func get_description() -> String:
	return "UNCONFIGURED"
