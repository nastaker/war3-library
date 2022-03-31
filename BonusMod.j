library BonusMod initializer OnInit requires optional AbilityPreload, optional xepreload
private keyword AbilityBonus

globals
    private constant boolean PRELOAD_ABILITIES = true
endglobals

//! runtextmacro BonusMod_BeginBonuses()
//                                    |     NAME     |ABILITY|PREFIX|RAWCODE|RAWCODE| HERO  
//                                    |              | COUNT |      |  BEGIN|    END| ONLY
//! runtextmacro BonusMod_DeclareBonus("ARMOR",        "18",  "ZxD",     "a",    "0", "false")
//! runtextmacro BonusMod_DeclareBonus("DAMAGE",       "18",  "ZxZ",     "a",    "0", "false")
//! runtextmacro BonusMod_DeclareBonus("LIFE_REGEN",   "15",  "ZxR",     "a",    "0", "false")
//! runtextmacro BonusMod_DeclareBonus("STRENGTH",     "10",  "ZxQ",     "a",    "0", "true")
//! runtextmacro BonusMod_DeclareBonus("AGILITY",      "10",  "ZxW",     "a",    "0", "true")
//! runtextmacro BonusMod_DeclareBonus("INTELLIGENCE", "10",  "ZxE",     "a",    "0", "true")

//                                           |     NAME          |ABILITY|PREFIX|RAWCODE|RAWCODE| HERO   
//                                           |                   | COUNT |      |  BEGIN|    END| ONLY
//! runtextmacro BonusMod_DeclarePercentBonus("ATTACK_SPEED",       "10", "ZxT",     "a",    "0", "false")
//! runtextmacro BonusMod_DeclarePercentBonus("MANA_REGEN_PERCENT", "10", "ZxY",     "a",    "0", "false")

//! runtextmacro BonusMod_EndBonuses()

//==============================================================================
// End of configuration
//==============================================================================
//! textmacro BonusMod_BeginBonuses
private function Setup takes nothing returns nothing
//! endtextmacro

//! textmacro BonusMod_DeclareBonus takes NAME, ABILITY_COUNT, RAWCODE_PREFIX, RAWCODE_BEGIN, RAWCODE_END, HERO_ONLY
  globals
      Bonus BONUS_$NAME$
  endglobals
  set BONUS_$NAME$ = AbilityBonus.create('$RAWCODE_PREFIX$$RAWCODE_BEGIN$', $ABILITY_COUNT$, '$RAWCODE_PREFIX$$RAWCODE_END$', $HERO_ONLY$)
//! endtextmacro

//! textmacro BonusMod_DeclarePercentBonus takes NAME, ABILITY_COUNT, RAWCODE_PREFIX, RAWCODE_BEGIN, RAWCODE_END, HERO_ONLY
  globals
      Bonus BONUS_$NAME$
  endglobals
  set BONUS_$NAME$ = AbilityBonus.create('$RAWCODE_PREFIX$$RAWCODE_BEGIN$', $ABILITY_COUNT$, '$RAWCODE_PREFIX$$RAWCODE_END$', $HERO_ONLY$)
//! endtextmacro

//! textmacro BonusMod_EndBonuses
endfunction
//! endtextmacro

// ===
//  Precomputed integer powers of 2
// ===

globals
    private integer array powersOf2
    private integer powersOf2Count = 0
endglobals

// ===
//  Utility functions
// ===

private function ErrorMsg takes string func, string s returns nothing
    call BJDebugMsg("|cffFF0000BonusMod Error|r|cffFFFF00:|r |cff8080FF" + func + "|r|cffFFFF00:|r " + s)
endfunction

private function LoadAbility takes integer abilityId returns nothing
    static if PRELOAD_ABILITIES then
        static if LIBRARY_xepreload then
            call XE_PreloadAbility(abilityId)
        else
            static if LIBRARY_AbilityPreload then
                call AbilityPreload(abilityId)
            endif
        endif
    endif
endfunction

// ===
//  Bonus Types
// ===

private interface BonusInterface
    integer minBonus = 0
    integer maxBonus = 0
    private method destroy takes nothing returns nothing defaults nothing
endinterface

private keyword isBonusObject

struct Bonus extends BonusInterface
    boolean isBonusObject = false
    
    public static method create takes nothing returns thistype
        local thistype this = thistype.allocate()
        
        set this.isBonusObject = true
        
        return this
    endmethod
    
    stub method setBonus takes unit u, integer amount returns integer
        debug call ErrorMsg("Bonus.setBonus()", "I have no idea how or why you did this, but don't do it.")
        return 0
    endmethod
    
    stub method getBonus takes unit u returns integer
        debug call ErrorMsg("Bonus.getBonus()", "I have no idea how or why you did this, but don't do it.")
        return 0
    endmethod
    
    stub method removeBonus takes unit u returns nothing
        call this.setBonus(u, 0)
    endmethod
    
    stub method isValidBonus takes unit u, integer value returns boolean
        return true
    endmethod
    
    method operator min takes nothing returns integer
        return this.minBonus
    endmethod
    
    method operator max takes nothing returns integer
        return this.maxBonus
    endmethod
endstruct

private struct AbilityBonus extends Bonus
    public integer count
    
    public integer rawcode
    public integer negativeRawcode
    
    public integer minBonus = 0
    public integer maxBonus = 0
    
    public boolean heroesOnly
    
    public static method create takes integer rawcode, integer count, integer negativeRawcode, boolean heroesOnly returns thistype
        local thistype bonus = thistype.allocate()
        local integer i
        debug local boolean error = false
        
        // Error messages
        static if DEBUG_MODE then
            if rawcode == 0 then
                call ErrorMsg("AbilityBonus.create()", "Bonus constructed with a rawcode of 0?!")
                call bonus.destroy()
                return 0
            endif
            
            if count < 0 or count == 0 then
                call ErrorMsg("AbilityBonus.create()", "Bonus constructed with an ability count <= 0?!")
                call bonus.destroy()
                return 0
            endif
        endif
        
        // Grow powers of 2
        if powersOf2Count < count then
            set i = powersOf2Count
            loop
                exitwhen i > count
                
                set powersOf2[i] = 2 * powersOf2[i - 1]

                set i = i + 1
            endloop
            set powersOf2Count = count
        endif
        
        // Preload this bonus' abilities
        static if PRELOAD_ABILITIES then
            set i = 0
            loop
                exitwhen i == count
                
                call LoadAbility(rawcode + i)
                
                set i = i + 1
            endloop
            
            if negativeRawcode != 0 then
                call LoadAbility(negativeRawcode)
            endif
        endif
        
        // Set up this bonus object
        set bonus.count = count
        set bonus.negativeRawcode = negativeRawcode
        set bonus.rawcode = rawcode
        set bonus.heroesOnly = heroesOnly
        
        // Calculate the minimum and maximum bonuses
        if negativeRawcode != 0 then
            set bonus.minBonus = -powersOf2[count]
        else
            set bonus.minBonus = 0
        endif
        set bonus.maxBonus = powersOf2[count] - 1
        
        // Return the bonus object
        return bonus
    endmethod
    
    // Interface methods:
    
    method setBonus takes unit u, integer amount returns integer
        return SetUnitBonus.evaluate(u, this, amount)
    endmethod
    
    method getBonus takes unit u returns integer
        return GetUnitBonus.evaluate(u, this)
    endmethod
    
    method removeBonus takes unit u returns nothing
        call RemoveUnitBonus.evaluate(u, this)
    endmethod
    
    public method isValidBonus takes unit u, integer value returns boolean
        return (value >= this.minBonus) and (value <= this.maxBonus)
    endmethod
endstruct

// ===
//  Public API
// ===

function IsBonusValid takes unit u, Bonus abstractBonus, integer value returns boolean
    local AbilityBonus bonus = AbilityBonus(abstractBonus)
    
    static if DEBUG_MODE then
        if not abstractBonus.isBonusObject then
            call ErrorMsg("IsBonusValid()", "Invalid bonus type given")
        endif
    endif
    
    if abstractBonus.min > value or abstractBonus.max < value then
        return false
    endif
    
    if abstractBonus.getType() != AbilityBonus.typeid then
        return abstractBonus.isValidBonus(u, value)
    endif
    
    if bonus.heroesOnly and not IsUnitType(u, UNIT_TYPE_HERO) then
        return false
    endif
    
    return (value >= bonus.minBonus) and (value <= bonus.maxBonus)
endfunction

function RemoveUnitBonus takes unit u, Bonus abstractBonus returns nothing
    local integer i = 0
    local AbilityBonus bonus = AbilityBonus(abstractBonus)

    static if DEBUG_MODE then
        if not abstractBonus.isBonusObject then
            call ErrorMsg("RemoveUnitBonus()", "Invalid bonus type given")
        endif
    endif
    
    if abstractBonus.getType() != AbilityBonus.typeid then
        call abstractBonus.removeBonus(u)
        return
    endif
    
    if bonus.heroesOnly and not IsUnitType(u, UNIT_TYPE_HERO) then
        debug call ErrorMsg("RemoveUnitBonus()", "Trying to remove a hero-only bonus from a non-hero unit")
        return
    endif
    
    call UnitRemoveAbility(u, bonus.negativeRawcode)
    
    loop
        exitwhen i == bonus.count
        
        call UnitRemoveAbility(u, bonus.rawcode + i)

        set i = i + 1
    endloop
endfunction

function SetUnitBonus takes unit u, Bonus abstractBonus, integer amount returns integer
    local integer i
    local integer output = 0
    local AbilityBonus bonus = AbilityBonus(abstractBonus)
    local boolean applyMinBonus = false
    
    static if DEBUG_MODE then
        if not abstractBonus.isBonusObject then
            call ErrorMsg("SetUnitBonus()", "Invalid bonus type given")
        endif
    endif
    
    if amount == 0 then
        call RemoveUnitBonus(u, bonus)
        return 0
    endif
    
    if abstractBonus.getType() != AbilityBonus.typeid then
        return abstractBonus.setBonus(u, amount)
    endif
    
    if bonus.heroesOnly and not IsUnitType(u, UNIT_TYPE_HERO) then
        debug call ErrorMsg("SetUnitBonus()", "Trying to set a hero-only bonus on a non-hero unit")
        return 0
    endif
    
    if amount < bonus.minBonus then
        debug call ErrorMsg("SetUnitBonus()", "Attempting to set a bonus to below its min value")
        set amount = bonus.minBonus
    elseif amount > bonus.maxBonus then
        debug call ErrorMsg("SetUnitBonus()", "Attempting to set a bonus to above its max value")
        set amount = bonus.maxBonus
    endif
    
    if amount < 0 then
        set amount = -(bonus.minBonus - amount)
        set applyMinBonus = true
    endif
    
    call UnitRemoveAbility(u, bonus.negativeRawcode)
    
    set i = bonus.count - 1
    loop
        exitwhen i < 0
        if amount >= powersOf2[i] then
            
            call UnitAddAbility(u, bonus.rawcode + i)
            call UnitMakeAbilityPermanent(u, true, bonus.rawcode + i)
            
            static if DEBUG_MODE then
                if GetUnitAbilityLevel(u, bonus.rawcode + i) <= 0 then
                    call ErrorMsg("SetUnitBonus()", "Failed to give the 2^" + I2S(i) + " ability to the unit!")
                endif
            endif
            
            set amount = amount - powersOf2[i]
            set output = output + powersOf2[i]
        else
            
            call UnitRemoveAbility(u, bonus.rawcode + i)
            static if DEBUG_MODE then
                if GetUnitAbilityLevel(u, bonus.rawcode + i) > 0 then
                    call ErrorMsg("SetUnitBonus()", "Unit still has the 2^" + I2S(i) + " ability after it was removed!")
                endif
            endif
        endif

        set i = i - 1
    endloop
    
    if applyMinBonus then
        call UnitAddAbility(u, bonus.negativeRawcode)
        call UnitMakeAbilityPermanent(u, true, bonus.negativeRawcode)
    else
        call UnitRemoveAbility(u, bonus.negativeRawcode)
    endif
    
    return output
endfunction

function GetUnitBonus takes unit u, Bonus abstractBonus returns integer
    local integer i = 0
    local integer amount = 0
    local AbilityBonus bonus = AbilityBonus(abstractBonus)

    static if DEBUG_MODE then
        if not abstractBonus.isBonusObject then
            call ErrorMsg("GetUnitBonus()", "Invalid bonus type given")
        endif
    endif
    
    if abstractBonus.getType() != AbilityBonus.typeid then
        return abstractBonus.getBonus(u)
    endif
    
    if bonus.heroesOnly and not IsUnitType(u, UNIT_TYPE_HERO) then
        debug call ErrorMsg("GetUnitBonus()", "Trying to get a hero-only bonus from a non-hero unit")
        return 0
    endif
    
    if GetUnitAbilityLevel(u, bonus.negativeRawcode) > 0 then
        set amount = bonus.minBonus
    endif

    loop
        exitwhen i == bonus.count
        
        if GetUnitAbilityLevel(u, bonus.rawcode + i) > 0 then
            set amount = amount + powersOf2[i]
        endif

        set i = i + 1
    endloop

    return amount
endfunction

function AddUnitBonus takes unit u, Bonus bonus, integer amount returns integer
    return SetUnitBonus(u, bonus, GetUnitBonus(u, bonus) + amount)
endfunction

// ===
//  Initialization
// ===

private function OnInit takes nothing returns nothing
    local integer i
    
    // Set up powers of 2
    set powersOf2[0] = 1
    set powersOf2Count = 1
    
    static if DEBUG_MODE and PRELOAD_ABILITIES and not LIBRARY_xepreload and not LIBRARY_AbilityPreload then
        call ErrorMsg("Initialization", "PRELOAD_ABILITIES is set to true, but neither usable preloading library is detected")
    endif
    
    // Setup bonuses
    call Setup()
endfunction
endlibrary