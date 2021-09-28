extends Control


export(NodePath) var name_node_path
export(NodePath) var cost_node_path
export(NodePath) var cooldown_node_path
export(NodePath) var cast_button_path


onready var _name_text = get_node_or_null(name_node_path)
onready var _cost_text = get_node_or_null(cost_node_path)
onready var _cooldown_text = get_node_or_null(cooldown_node_path)
onready var _cast_button = get_node_or_null(cast_button_path)


var skill_id
var able_to_control: bool
var castable: bool


func init_skill(skill, character_id, cast_node):
	enable_control(false)
	update_skill(skill)
	_cast_button.connect("pressed", cast_node, "_on_cast_skill", [character_id, skill_id])


func update_skill(skill):
	skill_id = skill.skill_id
	update_name(skill.skill_name)
	update_can_cast(skill.can_cast())
	update_cost(skill.cast_cost)
	update_cooldown(skill.current_cooldown)


func update_name(name: String):
	_name_text.text = name


func update_can_cast(can_cast: bool):
	castable = can_cast
	update_cast_button()


func update_cost(cost):
	if _cost_text != null:
		_cost_text.text = String(cost)


func update_cooldown(cooldown):
	if _cooldown_text != null:
		_cooldown_text.text = String(cooldown)


func enable_control(enable: bool):
	able_to_control = enable
	update_cast_button()


func update_cast_button():
	if _cast_button != null:
		_cast_button.disabled = !able_to_control or !castable
