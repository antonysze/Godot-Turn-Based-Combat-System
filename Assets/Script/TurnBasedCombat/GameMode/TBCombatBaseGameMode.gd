class_name TBCombatBaseGameMode
extends Reference


var manager


func _init(combat_manager):
    manager = combat_manager


func check_turn_end(last_action_caster) -> bool:
    return true
