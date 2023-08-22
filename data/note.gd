extends Resource

enum Direction {
	North,
	East,
	South,
	West,
}

@export var text: String
@export var done: bool
@export var direction := Direction.North

