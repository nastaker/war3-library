library BooleanExpr
  function BoolepxrAllyOrEnemy takes nothing returns boolean
    if GetUnitState(GetFilterUnit(),UNIT_STATE_LIFE) < 0.405 then
      return false
    endif
    if IsUnitType(GetFilterUnit(),UNIT_TYPE_STRUCTURE)==true then
      return false
    endif
    if IsUnitType(GetFilterUnit(),UNIT_TYPE_MECHANICAL)==true then
      return false
    endif
    if IsUnitType(GetFilterUnit(),UNIT_TYPE_MAGIC_IMMUNE)==true then
      return false
    endif
    if GetFilterUnit() == GetTriggerUnit() then
      return false
    endif
    return true
  endfunction

  function BoolepxrAllyUnit takes nothing returns boolean
    if GetUnitState(GetFilterUnit(),UNIT_STATE_LIFE) < 0.405 then
      return false
    endif
    if IsUnitType(GetFilterUnit(),UNIT_TYPE_STRUCTURE)==true then
      return false
    endif
    if IsUnitType(GetFilterUnit(),UNIT_TYPE_MECHANICAL)==true then
      return false
    endif
    if IsUnitType(GetFilterUnit(),UNIT_TYPE_MAGIC_IMMUNE)==true then
      return false
    endif
    if IsUnitAlly(GetFilterUnit(), Player(0)) then
      return false
    endif
    return true
  endfunction

  function BoolepxrEnemyUnit takes nothing returns boolean
    if GetUnitState(GetFilterUnit(),UNIT_STATE_LIFE) < 0.405 then
      return false
    endif
    if IsUnitType(GetFilterUnit(),UNIT_TYPE_STRUCTURE)==true then
      return false
    endif
    if IsUnitType(GetFilterUnit(),UNIT_TYPE_MECHANICAL)==true then
      return false
    endif
    if IsUnitType(GetFilterUnit(),UNIT_TYPE_MAGIC_IMMUNE)==true then
      return false
    endif
    if IsUnitAlly(GetFilterUnit(), Player(0)) then
      return false
    endif
    return true
  endfunction

  function BoolepxrEnemyUnitNoTarget takes nothing returns boolean
    if GetUnitState(GetFilterUnit(),UNIT_STATE_LIFE) < 0.405 then
      return false
    endif
    if GetFilterUnit() == GetSpellTargetUnit() then
      return false
    endif
    if IsUnitType(GetFilterUnit(),UNIT_TYPE_STRUCTURE)==true then
      return false
    endif
    if IsUnitType(GetFilterUnit(),UNIT_TYPE_MECHANICAL)==true then
      return false
    endif
    if IsUnitType(GetFilterUnit(),UNIT_TYPE_MAGIC_IMMUNE)==true then
      return false
    endif
    if IsUnitAlly(GetFilterUnit(), GetOwningPlayer(GetTriggerUnit())) then
      return false
    endif
    return true
  endfunction

  function BoolepxrAliveAllyOrUndeadEnemy takes nothing returns boolean
    if GetUnitState(GetFilterUnit(),UNIT_STATE_LIFE) < 0.405 then
      return false
    endif
    if IsUnitType(GetFilterUnit(),UNIT_TYPE_STRUCTURE)==true then
      return false
    endif
    if IsUnitType(GetFilterUnit(),UNIT_TYPE_MECHANICAL)==true then
      return false
    endif
    if IsUnitType(GetFilterUnit(),UNIT_TYPE_MAGIC_IMMUNE)==true then
      return false
    endif
    if IsUnitAlly(GetFilterUnit(), GetOwningPlayer(GetTriggerUnit())) then
      if IsUnitType(GetFilterUnit(), UNIT_TYPE_UNDEAD) then
        return false
      endif
    else
      if not IsUnitType(GetFilterUnit(), UNIT_TYPE_UNDEAD) then
        return false
      endif
    endif
    return true
  endfunction

  function BoolepxrUndeadAllyOrAliveEnemy takes nothing returns boolean
  if GetUnitState(GetFilterUnit(),UNIT_STATE_LIFE) < 0.405 then
    return false
  endif
  if IsUnitType(GetFilterUnit(),UNIT_TYPE_STRUCTURE)==true then
    return false
  endif
  if IsUnitType(GetFilterUnit(),UNIT_TYPE_MECHANICAL)==true then
    return false
  endif
  if IsUnitType(GetFilterUnit(),UNIT_TYPE_MAGIC_IMMUNE)==true then
    return false
  endif
  if IsUnitAlly(GetFilterUnit(), GetOwningPlayer(GetTriggerUnit())) then
    if not IsUnitType(GetFilterUnit(), UNIT_TYPE_UNDEAD) then
      return false
    endif
  else
    if IsUnitType(GetFilterUnit(), UNIT_TYPE_UNDEAD) then
      return false
    endif
  endif
  return true
  endfunction

  function BoolepxrAllMoveEnemy takes nothing returns boolean
    if GetUnitState(GetFilterUnit(),UNIT_STATE_LIFE) < 0.405 then
      return false
    endif
    if IsUnitType(GetFilterUnit(),UNIT_TYPE_STRUCTURE)==true then
      return false
    endif
    if IsUnitAlly(GetFilterUnit(), Player(0)) then
      return false
    endif
    return true
  endfunction

  function BoolepxrEnemyUnitNoFly takes nothing returns boolean
    if GetUnitState(GetFilterUnit(),UNIT_STATE_LIFE) < 0.405 then
      return false
    endif
    if IsUnitType(GetFilterUnit(),UNIT_TYPE_STRUCTURE)==true then
      return false
    endif
    if IsUnitType(GetFilterUnit(),UNIT_TYPE_MECHANICAL)==true then
      return false
    endif
    if IsUnitType(GetFilterUnit(),UNIT_TYPE_MAGIC_IMMUNE)==true then
      return false
    endif
    if IsUnitAlly(GetFilterUnit(), Player(0)) then
      return false
    endif
    if IsUnitType(GetFilterUnit(), UNIT_TYPE_FLYING) then
      return false
    endif
    return true
  endfunction
endlibrary