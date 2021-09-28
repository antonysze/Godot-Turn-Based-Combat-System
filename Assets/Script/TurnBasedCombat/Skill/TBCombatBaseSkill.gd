class_name TBCombatBaseSkill
extends Reference


var skill_id
var skill_name
var skill_description
var cast_cost = 0
var cooldown := 0
var target_type

var current_cooldown := 0

enum TargetType {
	None,
	Self,
	SingleAny,
	SingleAlly,
	SingleEnemy,
	AllAlly,
	AllEnemy,
	Everyone,
}


func can_cast(action_point = -1) -> bool:
	return current_cooldown <= 0 and \
		(action_point < 0 or (action_point >= 0 and cast_cost <= action_point))


func cast(from, target = []):
	current_cooldown = cooldown
	for tmp in target:
		_cast_on_target(from, tmp)

		
func _cast_on_target(from, target):
	pass


func cast_log(caster, targets) -> String:    
	return "%s casted %s on %s" % [caster.name, skill_name, get_target_name(targets)]


func get_target_name(targets):
	var names = ""
	for node in targets:
		if node.name == null or node.name == "":
			continue
		if names != "":
			names += ", "
		names += node.name


func reduce_cooldown(turn = 1):
	current_cooldown = max(0, current_cooldown - turn)


func is_no_target_selection() -> bool:
	return target_type == TargetType.AllAlly \
		or target_type == TargetType.AllEnemy \
		or target_type == TargetType.Everyone
