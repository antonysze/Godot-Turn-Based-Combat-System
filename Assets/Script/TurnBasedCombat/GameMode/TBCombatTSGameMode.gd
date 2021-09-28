class_name TBCombatTSGameMode
extends TBCombatBaseGameMode


var ally_turn: bool


func _init(combat_manager).(combat_manager):
	ally_turn = true


func start_turn():
	for node in manager.get_members_from_team(ally_turn):
		node.start_turn()
	if ally_turn:
		manager.recover_action_point()


func end_turn():
	for node in manager.get_members_from_team(ally_turn):
		node.end_turn()
	ally_turn = !ally_turn
	start_turn()


func check_turn_end(last_action_caster) -> bool:
	var team_members = manager.get_members_from_team(last_action_caster.is_ally)
	for member in team_members:
		if !member.turn_finished:
			return false
	return true
