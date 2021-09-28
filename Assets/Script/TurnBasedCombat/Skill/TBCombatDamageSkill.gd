class_name TBCombatDamageSkill
extends TBCombatBaseSkill


var damage


func _cast_on_target(from, target):
    target.damage(damage)


func cast_log(caster, target) -> String:
    return "%s casted %s on %s deal %d damage" % [caster.name, skill_name, get_target_name(target), int(damage)]
