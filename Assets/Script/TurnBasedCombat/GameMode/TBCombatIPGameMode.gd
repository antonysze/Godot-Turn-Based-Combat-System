class_name TBCombatIPGameMode
extends TBCombatBaseGameMode



func _init(combat_manager).(combat_manager):
    pass


func check_turn_end(last_action_caster) -> bool:
    return last_action_caster.turn_finished
