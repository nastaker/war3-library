library UnitMaxState initializer Initialize requires optional AbilityPreload, optional xepreload

globals
    private constant integer RAWCODE_LIFE = 'ZxL0'
    private constant integer RAWCODE_MANA = 'ZxM0'
    
    public constant integer ABILITY_COUNT = 5
    private constant boolean PRELOAD_ABILITIES = true
    
    private integer array POWERS_OF_2
endglobals

private function ErrorMsg takes string s returns nothing
    debug call BJDebugMsg("SetUnitMaxState: " + s)
endfunction

function SetUnitMaxState takes unit target, unitstate state, real targetValue returns nothing
    local integer difference
    local integer rawcode
    
    local integer abilityId
    local integer abilityLevel
    
    local integer currentAbility
    
    if state == UNIT_STATE_MAX_LIFE then
        set rawcode = RAWCODE_LIFE
        
        if targetValue < 1 then
            call ErrorMsg("You can not set a unit's max life to below 1")
            return
        endif
    elseif state == UNIT_STATE_MAX_MANA then
        set rawcode = RAWCODE_MANA
        
        if targetValue < 0 then
            call ErrorMsg("You can not set a unit's max mana to below 0")
            return
        endif
    else
        call SetUnitState(target, state, targetValue)
        return
    endif
    
    set difference = R2I(targetValue) - R2I(GetUnitState(target, state))
    
    if difference < 0 then
        set difference = -difference
        set rawcode = rawcode + ABILITY_COUNT
    endif
    
    set abilityId = ABILITY_COUNT - 1
    set abilityLevel = 4
    set currentAbility = rawcode + abilityId
    loop
        exitwhen difference == 0
        
        if difference >= POWERS_OF_2[abilityId * 3 + (abilityLevel - 2)] then
            call UnitAddAbility(target, currentAbility)
            call SetUnitAbilityLevel(target, currentAbility, abilityLevel)
            call UnitRemoveAbility(target, currentAbility)
            
            set difference = difference - POWERS_OF_2[abilityId * 3 + (abilityLevel - 2)]
        else
            set abilityLevel = abilityLevel - 1
            if abilityLevel <= 1 then
                set abilityId = abilityId - 1
                set abilityLevel = 4
                set currentAbility = rawcode + abilityId
            endif
        endif
    endloop
endfunction

function AddUnitMaxState takes unit target, unitstate state, real additionalValue returns nothing
    call SetUnitMaxState(target, state, GetUnitState(target, state) + additionalValue)
endfunction

//! textmacro UnitMaxState_Preload takes RAWCODE
    set i = 0
    loop
        exitwhen i == ABILITY_COUNT * 2 - 1
        
        static if LIBRARY_AbilityPreload then
            call AbilityPreload($RAWCODE$ + i)
        elseif LIBRARY_xepreload then
            call XE_PreloadAbility($RAWCODE$ + i)
        endif
        
        set i = i + 1
    endloop
//! endtextmacro

private function Initialize takes nothing returns nothing
    local integer i
    local integer k
    
    set i = 1
    set POWERS_OF_2[0] = 1
    loop
        exitwhen i == ABILITY_COUNT * 2 * 2 * 3 + 1
        
        set POWERS_OF_2[i] = POWERS_OF_2[i - 1] * 2
        set i = i + 1
    endloop
    
    static if DEBUG_MODE and PRELOAD_ABILITIES and not LIBRARY_AbilityPreload and not LIBRARY_xepreload then
        call ErrorMsg("Ability preloading was enabled, but neither of the supported preload libraries are present")
    elseif PRELOAD_ABILITIES then
        //! runtextmacro UnitMaxState_Preload("RAWCODE_LIFE")
        //! runtextmacro UnitMaxState_Preload("RAWCODE_MANA")
    endif
endfunction
endlibrary