extends TBCombatCharacterController


export(String, FILE) var skill_controller_prefab = ""
export(NodePath) var skill_holder_path
export(Array, NodePath) var preset_skill_controller


onready var _skill_holder = get_node(skill_holder_path)
var _skill_controllers = []


func _ready():
	for path in preset_skill_controller:
		var controller = get_node(path)
		_skill_controllers.append(controller)


func init_character(data, combat_controller):
	.init_character(data, combat_controller)
	init_skills(data.skills, data.combat_id, combat_controller)


func init_skills(skills: Array, character_id, cast_node):
	var prefab = null
	if skill_controller_prefab != "":
		prefab = load(skill_controller_prefab)

	for i in skills.size():
		if _skill_controllers.size() <= i:
			if prefab != null:
				var instance = prefab.instance()
				_skill_controllers.append(instance)
				_skill_holder.add_child(instance)
			else:
				printerr("Cannot create skill controller without prefab")
				break
		_skill_controllers[i].init_skill(skills[i], character_id, cast_node, -1)


func update_skills(skills: Array, ap):
	for i in _skill_controllers.size():
		_skill_controllers[i].update_skill(skills[i], ap)



func enable_control(enable: bool):
	for skill in _skill_controllers:
		skill.enable_control(enable)
