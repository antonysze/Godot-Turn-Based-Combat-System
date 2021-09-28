class_name TBCombatCharacterNode
extends Reference


var name = ""
var combat_id
var is_ally: bool
var max_hp setget set_max_hp
var current_hp = 0
var turn_finished = false


var controller
var skills: Array


func is_dead() -> bool:
	return current_hp <= 0


func can_action() -> bool:
	return !turn_finished


func init(data): # TBCombatCharacterData
	self.max_hp = data.get_max_hp()
	set_hp(max_hp)


func set_max_hp(value):
	max_hp = value
	if current_hp > max_hp:
		current_hp = max_hp


func set_hp(amount):
	current_hp = clamp(amount, 0, max_hp)


func get_available_skills() -> Array:
	return skills


func get_skill_by_id(skill_id):
	for skill in skills:
		if skill.skill_id == skill_id:
			return skill
	return null


func damage(amount):
	set_hp(current_hp - amount)


func start_turn():
	turn_finished = false
	for skill in skills:
		skill.reduce_cooldown()
	if controller != null:
		controller.enable_control(true)
	

func end_turn():
	if controller != null:
		controller.enable_control(false)
