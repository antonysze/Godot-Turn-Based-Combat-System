class_name TBCombatSetting
extends Resource

enum CombatMode {
    IndividualPrioritized = 0
    TeamPrioritized = 1,
    TeamSwitch = 2,
}

export(CombatMode) var combat_mode
export(float) var max_action_point = -1
export(bool) var character_act_once = false
export(bool) var auto_end_turn = true


func using_action_point() -> bool:
    return max_action_point >= 0
