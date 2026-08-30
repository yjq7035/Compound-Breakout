globals
//globals from YDTriggerSaveLoadSystem:
constant boolean LIBRARY_YDTriggerSaveLoadSystem=true
hashtable YDHT
hashtable YDLOC
//endglobals from YDTriggerSaveLoadSystem
trigger gg_trg_main= null

trigger l__library_init

//JASSHelper struct globals:

endglobals


//library YDTriggerSaveLoadSystem:
//#  define YDTRIGGER_handle(SG)                          YDTRIGGER_HT##SG##(HashtableHandle)
    function YDTriggerSaveLoadSystem___Init takes nothing returns nothing
            set YDHT=InitHashtable()
        set YDLOC=InitHashtable()
    endfunction

//library YDTriggerSaveLoadSystem ends
//===========================================================================
//*
//*  Global variables
//*
//===========================================================================
function InitGlobals takes nothing returns nothing
 local integer i= 0
endfunction
function InitRandomGroups takes nothing returns nothing
 local integer curset
endfunction
function InitSounds takes nothing returns nothing
endfunction
function CreateDestructables takes nothing returns nothing
 local destructable d
 local trigger t
 local real life
endfunction
function CreateItems takes nothing returns nothing
 local integer itemID
endfunction
function CreateUnits takes nothing returns nothing
 local unit u
 local integer unitID
 local trigger t
 local real life
endfunction
function CreateRegions takes nothing returns nothing
 local weathereffect we
endfunction
function CreateCameras takes nothing returns nothing
endfunction
//TESH.scrollpos=0
//TESH.alwaysfold=0
function InitTrig_main takes nothing returns nothing
    call Cheat("exec-lua: TG_main")
endfunction
//===========================================================================
function InitCustomTriggers takes nothing returns nothing
	call InitTrig_main()
endfunction
//===========================================================================
function RunInitializationTriggers takes nothing returns nothing
endfunction
function InitCustomPlayerSlots takes nothing returns nothing
	call SetPlayerStartLocation(Player(0), 0)
	call ForcePlayerStartLocation(Player(0), 0)
	call SetPlayerColor(Player(0), ConvertPlayerColor(0))
	call SetPlayerRacePreference(Player(0), RACE_PREF_HUMAN)
	call SetPlayerRaceSelectable(Player(0), false)
	call SetPlayerController(Player(0), MAP_CONTROL_USER)
	call SetPlayerStartLocation(Player(1), 1)
	call ForcePlayerStartLocation(Player(1), 1)
	call SetPlayerColor(Player(1), ConvertPlayerColor(1))
	call SetPlayerRacePreference(Player(1), RACE_PREF_ORC)
	call SetPlayerRaceSelectable(Player(1), false)
	call SetPlayerController(Player(1), MAP_CONTROL_USER)
	call SetPlayerStartLocation(Player(2), 2)
	call ForcePlayerStartLocation(Player(2), 2)
	call SetPlayerColor(Player(2), ConvertPlayerColor(2))
	call SetPlayerRacePreference(Player(2), RACE_PREF_UNDEAD)
	call SetPlayerRaceSelectable(Player(2), false)
	call SetPlayerController(Player(2), MAP_CONTROL_USER)
	call SetPlayerStartLocation(Player(3), 3)
	call ForcePlayerStartLocation(Player(3), 3)
	call SetPlayerColor(Player(3), ConvertPlayerColor(3))
	call SetPlayerRacePreference(Player(3), RACE_PREF_NIGHTELF)
	call SetPlayerRaceSelectable(Player(3), false)
	call SetPlayerController(Player(3), MAP_CONTROL_USER)
	call SetPlayerStartLocation(Player(4), 4)
	call SetPlayerColor(Player(4), ConvertPlayerColor(4))
	call SetPlayerRacePreference(Player(4), RACE_PREF_HUMAN)
	call SetPlayerRaceSelectable(Player(4), false)
	call SetPlayerController(Player(4), MAP_CONTROL_COMPUTER)
	call SetPlayerStartLocation(Player(5), 5)
	call SetPlayerColor(Player(5), ConvertPlayerColor(5))
	call SetPlayerRacePreference(Player(5), RACE_PREF_ORC)
	call SetPlayerRaceSelectable(Player(5), false)
	call SetPlayerController(Player(5), MAP_CONTROL_COMPUTER)
	call SetPlayerStartLocation(Player(6), 6)
	call SetPlayerColor(Player(6), ConvertPlayerColor(6))
	call SetPlayerRacePreference(Player(6), RACE_PREF_UNDEAD)
	call SetPlayerRaceSelectable(Player(6), false)
	call SetPlayerController(Player(6), MAP_CONTROL_COMPUTER)
	call SetPlayerStartLocation(Player(7), 7)
	call SetPlayerColor(Player(7), ConvertPlayerColor(7))
	call SetPlayerRacePreference(Player(7), RACE_PREF_NIGHTELF)
	call SetPlayerRaceSelectable(Player(7), false)
	call SetPlayerController(Player(7), MAP_CONTROL_COMPUTER)
	call SetPlayerStartLocation(Player(8), 8)
	call SetPlayerColor(Player(8), ConvertPlayerColor(8))
	call SetPlayerRacePreference(Player(8), RACE_PREF_HUMAN)
	call SetPlayerRaceSelectable(Player(8), false)
	call SetPlayerController(Player(8), MAP_CONTROL_COMPUTER)
	call SetPlayerStartLocation(Player(9), 9)
	call SetPlayerColor(Player(9), ConvertPlayerColor(9))
	call SetPlayerRacePreference(Player(9), RACE_PREF_ORC)
	call SetPlayerRaceSelectable(Player(9), false)
	call SetPlayerController(Player(9), MAP_CONTROL_COMPUTER)
	call SetPlayerStartLocation(Player(10), 10)
	call SetPlayerColor(Player(10), ConvertPlayerColor(10))
	call SetPlayerRacePreference(Player(10), RACE_PREF_UNDEAD)
	call SetPlayerRaceSelectable(Player(10), false)
	call SetPlayerController(Player(10), MAP_CONTROL_COMPUTER)
	call SetPlayerStartLocation(Player(11), 11)
	call SetPlayerColor(Player(11), ConvertPlayerColor(11))
	call SetPlayerRacePreference(Player(11), RACE_PREF_NIGHTELF)
	call SetPlayerRaceSelectable(Player(11), false)
	call SetPlayerController(Player(11), MAP_CONTROL_COMPUTER)
endfunction
function InitCustomTeams takes nothing returns nothing
	// Force: TRIGSTR_006
	call SetPlayerTeam(Player(0), 0)
	call SetPlayerTeam(Player(1), 0)
	call SetPlayerTeam(Player(2), 0)
	call SetPlayerTeam(Player(3), 0)
	call SetPlayerAllianceStateAllyBJ(Player(0), Player(1), true)
	call SetPlayerAllianceStateVisionBJ(Player(0), Player(1), true)
	call SetPlayerAllianceStateAllyBJ(Player(0), Player(2), true)
	call SetPlayerAllianceStateVisionBJ(Player(0), Player(2), true)
	call SetPlayerAllianceStateAllyBJ(Player(0), Player(3), true)
	call SetPlayerAllianceStateVisionBJ(Player(0), Player(3), true)
	call SetPlayerAllianceStateAllyBJ(Player(1), Player(0), true)
	call SetPlayerAllianceStateVisionBJ(Player(1), Player(0), true)
	call SetPlayerAllianceStateAllyBJ(Player(1), Player(2), true)
	call SetPlayerAllianceStateVisionBJ(Player(1), Player(2), true)
	call SetPlayerAllianceStateAllyBJ(Player(1), Player(3), true)
	call SetPlayerAllianceStateVisionBJ(Player(1), Player(3), true)
	call SetPlayerAllianceStateAllyBJ(Player(2), Player(0), true)
	call SetPlayerAllianceStateVisionBJ(Player(2), Player(0), true)
	call SetPlayerAllianceStateAllyBJ(Player(2), Player(1), true)
	call SetPlayerAllianceStateVisionBJ(Player(2), Player(1), true)
	call SetPlayerAllianceStateAllyBJ(Player(2), Player(3), true)
	call SetPlayerAllianceStateVisionBJ(Player(2), Player(3), true)
	call SetPlayerAllianceStateAllyBJ(Player(3), Player(0), true)
	call SetPlayerAllianceStateVisionBJ(Player(3), Player(0), true)
	call SetPlayerAllianceStateAllyBJ(Player(3), Player(1), true)
	call SetPlayerAllianceStateVisionBJ(Player(3), Player(1), true)
	call SetPlayerAllianceStateAllyBJ(Player(3), Player(2), true)
	call SetPlayerAllianceStateVisionBJ(Player(3), Player(2), true)
	// Force: TRIGSTR_007
	call SetPlayerTeam(Player(4), 1)
	call SetPlayerTeam(Player(5), 1)
	call SetPlayerTeam(Player(6), 1)
	call SetPlayerTeam(Player(7), 1)
	call SetPlayerTeam(Player(8), 1)
	call SetPlayerTeam(Player(9), 1)
	call SetPlayerTeam(Player(10), 1)
	call SetPlayerTeam(Player(11), 1)
	call SetPlayerAllianceStateAllyBJ(Player(4), Player(5), true)
	call SetPlayerAllianceStateVisionBJ(Player(4), Player(5), true)
	call SetPlayerAllianceStateAllyBJ(Player(4), Player(6), true)
	call SetPlayerAllianceStateVisionBJ(Player(4), Player(6), true)
	call SetPlayerAllianceStateAllyBJ(Player(4), Player(7), true)
	call SetPlayerAllianceStateVisionBJ(Player(4), Player(7), true)
	call SetPlayerAllianceStateAllyBJ(Player(4), Player(8), true)
	call SetPlayerAllianceStateVisionBJ(Player(4), Player(8), true)
	call SetPlayerAllianceStateAllyBJ(Player(4), Player(9), true)
	call SetPlayerAllianceStateVisionBJ(Player(4), Player(9), true)
	call SetPlayerAllianceStateAllyBJ(Player(4), Player(10), true)
	call SetPlayerAllianceStateVisionBJ(Player(4), Player(10), true)
	call SetPlayerAllianceStateAllyBJ(Player(4), Player(11), true)
	call SetPlayerAllianceStateVisionBJ(Player(4), Player(11), true)
	call SetPlayerAllianceStateAllyBJ(Player(5), Player(4), true)
	call SetPlayerAllianceStateVisionBJ(Player(5), Player(4), true)
	call SetPlayerAllianceStateAllyBJ(Player(5), Player(6), true)
	call SetPlayerAllianceStateVisionBJ(Player(5), Player(6), true)
	call SetPlayerAllianceStateAllyBJ(Player(5), Player(7), true)
	call SetPlayerAllianceStateVisionBJ(Player(5), Player(7), true)
	call SetPlayerAllianceStateAllyBJ(Player(5), Player(8), true)
	call SetPlayerAllianceStateVisionBJ(Player(5), Player(8), true)
	call SetPlayerAllianceStateAllyBJ(Player(5), Player(9), true)
	call SetPlayerAllianceStateVisionBJ(Player(5), Player(9), true)
	call SetPlayerAllianceStateAllyBJ(Player(5), Player(10), true)
	call SetPlayerAllianceStateVisionBJ(Player(5), Player(10), true)
	call SetPlayerAllianceStateAllyBJ(Player(5), Player(11), true)
	call SetPlayerAllianceStateVisionBJ(Player(5), Player(11), true)
	call SetPlayerAllianceStateAllyBJ(Player(6), Player(4), true)
	call SetPlayerAllianceStateVisionBJ(Player(6), Player(4), true)
	call SetPlayerAllianceStateAllyBJ(Player(6), Player(5), true)
	call SetPlayerAllianceStateVisionBJ(Player(6), Player(5), true)
	call SetPlayerAllianceStateAllyBJ(Player(6), Player(7), true)
	call SetPlayerAllianceStateVisionBJ(Player(6), Player(7), true)
	call SetPlayerAllianceStateAllyBJ(Player(6), Player(8), true)
	call SetPlayerAllianceStateVisionBJ(Player(6), Player(8), true)
	call SetPlayerAllianceStateAllyBJ(Player(6), Player(9), true)
	call SetPlayerAllianceStateVisionBJ(Player(6), Player(9), true)
	call SetPlayerAllianceStateAllyBJ(Player(6), Player(10), true)
	call SetPlayerAllianceStateVisionBJ(Player(6), Player(10), true)
	call SetPlayerAllianceStateAllyBJ(Player(6), Player(11), true)
	call SetPlayerAllianceStateVisionBJ(Player(6), Player(11), true)
	call SetPlayerAllianceStateAllyBJ(Player(7), Player(4), true)
	call SetPlayerAllianceStateVisionBJ(Player(7), Player(4), true)
	call SetPlayerAllianceStateAllyBJ(Player(7), Player(5), true)
	call SetPlayerAllianceStateVisionBJ(Player(7), Player(5), true)
	call SetPlayerAllianceStateAllyBJ(Player(7), Player(6), true)
	call SetPlayerAllianceStateVisionBJ(Player(7), Player(6), true)
	call SetPlayerAllianceStateAllyBJ(Player(7), Player(8), true)
	call SetPlayerAllianceStateVisionBJ(Player(7), Player(8), true)
	call SetPlayerAllianceStateAllyBJ(Player(7), Player(9), true)
	call SetPlayerAllianceStateVisionBJ(Player(7), Player(9), true)
	call SetPlayerAllianceStateAllyBJ(Player(7), Player(10), true)
	call SetPlayerAllianceStateVisionBJ(Player(7), Player(10), true)
	call SetPlayerAllianceStateAllyBJ(Player(7), Player(11), true)
	call SetPlayerAllianceStateVisionBJ(Player(7), Player(11), true)
	call SetPlayerAllianceStateAllyBJ(Player(8), Player(4), true)
	call SetPlayerAllianceStateVisionBJ(Player(8), Player(4), true)
	call SetPlayerAllianceStateAllyBJ(Player(8), Player(5), true)
	call SetPlayerAllianceStateVisionBJ(Player(8), Player(5), true)
	call SetPlayerAllianceStateAllyBJ(Player(8), Player(6), true)
	call SetPlayerAllianceStateVisionBJ(Player(8), Player(6), true)
	call SetPlayerAllianceStateAllyBJ(Player(8), Player(7), true)
	call SetPlayerAllianceStateVisionBJ(Player(8), Player(7), true)
	call SetPlayerAllianceStateAllyBJ(Player(8), Player(9), true)
	call SetPlayerAllianceStateVisionBJ(Player(8), Player(9), true)
	call SetPlayerAllianceStateAllyBJ(Player(8), Player(10), true)
	call SetPlayerAllianceStateVisionBJ(Player(8), Player(10), true)
	call SetPlayerAllianceStateAllyBJ(Player(8), Player(11), true)
	call SetPlayerAllianceStateVisionBJ(Player(8), Player(11), true)
	call SetPlayerAllianceStateAllyBJ(Player(9), Player(4), true)
	call SetPlayerAllianceStateVisionBJ(Player(9), Player(4), true)
	call SetPlayerAllianceStateAllyBJ(Player(9), Player(5), true)
	call SetPlayerAllianceStateVisionBJ(Player(9), Player(5), true)
	call SetPlayerAllianceStateAllyBJ(Player(9), Player(6), true)
	call SetPlayerAllianceStateVisionBJ(Player(9), Player(6), true)
	call SetPlayerAllianceStateAllyBJ(Player(9), Player(7), true)
	call SetPlayerAllianceStateVisionBJ(Player(9), Player(7), true)
	call SetPlayerAllianceStateAllyBJ(Player(9), Player(8), true)
	call SetPlayerAllianceStateVisionBJ(Player(9), Player(8), true)
	call SetPlayerAllianceStateAllyBJ(Player(9), Player(10), true)
	call SetPlayerAllianceStateVisionBJ(Player(9), Player(10), true)
	call SetPlayerAllianceStateAllyBJ(Player(9), Player(11), true)
	call SetPlayerAllianceStateVisionBJ(Player(9), Player(11), true)
	call SetPlayerAllianceStateAllyBJ(Player(10), Player(4), true)
	call SetPlayerAllianceStateVisionBJ(Player(10), Player(4), true)
	call SetPlayerAllianceStateAllyBJ(Player(10), Player(5), true)
	call SetPlayerAllianceStateVisionBJ(Player(10), Player(5), true)
	call SetPlayerAllianceStateAllyBJ(Player(10), Player(6), true)
	call SetPlayerAllianceStateVisionBJ(Player(10), Player(6), true)
	call SetPlayerAllianceStateAllyBJ(Player(10), Player(7), true)
	call SetPlayerAllianceStateVisionBJ(Player(10), Player(7), true)
	call SetPlayerAllianceStateAllyBJ(Player(10), Player(8), true)
	call SetPlayerAllianceStateVisionBJ(Player(10), Player(8), true)
	call SetPlayerAllianceStateAllyBJ(Player(10), Player(9), true)
	call SetPlayerAllianceStateVisionBJ(Player(10), Player(9), true)
	call SetPlayerAllianceStateAllyBJ(Player(10), Player(11), true)
	call SetPlayerAllianceStateVisionBJ(Player(10), Player(11), true)
	call SetPlayerAllianceStateAllyBJ(Player(11), Player(4), true)
	call SetPlayerAllianceStateVisionBJ(Player(11), Player(4), true)
	call SetPlayerAllianceStateAllyBJ(Player(11), Player(5), true)
	call SetPlayerAllianceStateVisionBJ(Player(11), Player(5), true)
	call SetPlayerAllianceStateAllyBJ(Player(11), Player(6), true)
	call SetPlayerAllianceStateVisionBJ(Player(11), Player(6), true)
	call SetPlayerAllianceStateAllyBJ(Player(11), Player(7), true)
	call SetPlayerAllianceStateVisionBJ(Player(11), Player(7), true)
	call SetPlayerAllianceStateAllyBJ(Player(11), Player(8), true)
	call SetPlayerAllianceStateVisionBJ(Player(11), Player(8), true)
	call SetPlayerAllianceStateAllyBJ(Player(11), Player(9), true)
	call SetPlayerAllianceStateVisionBJ(Player(11), Player(9), true)
	call SetPlayerAllianceStateAllyBJ(Player(11), Player(10), true)
	call SetPlayerAllianceStateVisionBJ(Player(11), Player(10), true)
endfunction
function InitAllyPriorities takes nothing returns nothing
	call SetStartLocPrioCount(0, 3)
	call SetStartLocPrio(0, 0, 1, MAP_LOC_PRIO_HIGH)
	call SetStartLocPrio(0, 1, 2, MAP_LOC_PRIO_HIGH)
	call SetStartLocPrio(0, 2, 3, MAP_LOC_PRIO_HIGH)
	call SetStartLocPrioCount(1, 3)
	call SetStartLocPrio(1, 0, 0, MAP_LOC_PRIO_HIGH)
	call SetStartLocPrio(1, 1, 2, MAP_LOC_PRIO_HIGH)
	call SetStartLocPrio(1, 2, 3, MAP_LOC_PRIO_HIGH)
	call SetStartLocPrioCount(2, 3)
	call SetStartLocPrio(2, 0, 0, MAP_LOC_PRIO_HIGH)
	call SetStartLocPrio(2, 1, 1, MAP_LOC_PRIO_HIGH)
	call SetStartLocPrio(2, 2, 3, MAP_LOC_PRIO_HIGH)
	call SetStartLocPrioCount(3, 3)
	call SetStartLocPrio(3, 0, 0, MAP_LOC_PRIO_HIGH)
	call SetStartLocPrio(3, 1, 1, MAP_LOC_PRIO_HIGH)
	call SetStartLocPrio(3, 2, 2, MAP_LOC_PRIO_HIGH)
endfunction
//===========================================================================
//*
//*  Main Initialization
//*
//===========================================================================
function main takes nothing returns nothing
	call SetCameraBounds(- 15616.000000 + GetCameraMargin(CAMERA_MARGIN_LEFT), - 15872.000000 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 15616.000000 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 15360.000000 - GetCameraMargin(CAMERA_MARGIN_TOP), - 15616.000000 + GetCameraMargin(CAMERA_MARGIN_LEFT), 15360.000000 - GetCameraMargin(CAMERA_MARGIN_TOP), 15616.000000 - GetCameraMargin(CAMERA_MARGIN_RIGHT), - 15872.000000 + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
	call SetDayNightModels("Environment\\DNC\\DNCDalaran\\DNCDalaranTerrain\\DNCDalaranTerrain.mdl", "Environment\\DNC\\DNCDalaran\\DNCDalaranUnit\\DNCDalaranUnit.mdl")
	call NewSoundEnvironment("Default")
	call SetAmbientDaySound("DalaranRuinsDay")
	call SetAmbientNightSound("DalaranRuinsNight")
	call SetMapMusic("Music", true, 0)
	call InitSounds()
	call InitRandomGroups()
	call CreateRegions()
	call CreateCameras()
	call CreateDestructables()
	call CreateItems()
	call CreateUnits()
	call InitBlizzard()

call ExecuteFunc("YDTriggerSaveLoadSystem___Init")

	call InitGlobals()
	call InitCustomTriggers()
	call RunInitializationTriggers()
endfunction
//===========================================================================
//*
//*  Map Configuration
//*
//===========================================================================
function config takes nothing returns nothing
	call SetMapName("逃离园区")
	call SetMapDescription("没有说明")
	call SetPlayers(12)
	call SetTeams(12)
	call SetGamePlacement(MAP_PLACEMENT_TEAMS_TOGETHER)
	call DefineStartLocation(0, - 14400.000000, - 15616.000000)
	call DefineStartLocation(1, - 14400.000000, - 15616.000000)
	call DefineStartLocation(2, - 14400.000000, - 15616.000000)
	call DefineStartLocation(3, - 14400.000000, - 15616.000000)
	call DefineStartLocation(4, - 14400.000000, - 15616.000000)
	call DefineStartLocation(5, 12416.000000, 9472.000000)
	call DefineStartLocation(6, - 4544.000000, - 6464.000000)
	call DefineStartLocation(7, - 1536.000000, - 12672.000000)
	call DefineStartLocation(8, 5056.000000, 14336.000000)
	call DefineStartLocation(9, 8576.000000, 14272.000000)
	call DefineStartLocation(10, 192.000000, - 1088.000000)
	call DefineStartLocation(11, 192.000000, - 10688.000000)
	call InitCustomPlayerSlots()
	call InitCustomTeams()
	call InitAllyPriorities()
endfunction




//Struct method generated initializers/callers:

