globals
//globals from YDTriggerSaveLoadSystem:
constant boolean LIBRARY_YDTriggerSaveLoadSystem=true
hashtable YDHT
hashtable YDLOC
//endglobals from YDTriggerSaveLoadSystem
trigger gg_trg_______u= null

trigger l__library_init

//JASSHelper struct globals:

endglobals


//library YDTriggerSaveLoadSystem:
//#  define YDTRIGGER_handle(SG)                          YDTRIGGER_HT##SG##(HashtableHandle)
    function YDTriggerSaveLoadSystem__Init takes nothing returns nothing
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
	set u=CreateUnit(Player(0), 'hpea', - 9477.8, - 13181.3, 195.8)
endfunction
function CreateRegions takes nothing returns nothing
 local weathereffect we
endfunction
function CreateCameras takes nothing returns nothing
endfunction
//===========================================================================
// Trigger: 简介
//===========================================================================
function Trig_______uActions takes nothing returns nothing
	//欢迎使用世界编辑器，开始你的地图创造之旅。
	//你可以从https://reckfeng.com/获取最新编辑器咨询。
	//当你的地图意外损坏时，你可以在backups目录找到你最近26次保存的地图。
	//任何疑问请加官方作者群：QQ433807374。
endfunction
//===========================================================================
function InitTrig_______u takes nothing returns nothing
	set gg_trg_______u=CreateTrigger()
	call TriggerAddAction(gg_trg_______u, function Trig_______uActions)
endfunction
//===========================================================================
function InitCustomTriggers takes nothing returns nothing
	call InitTrig_______u()
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

call ExecuteFunc("YDTriggerSaveLoadSystem__Init")

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
	call SetPlayers(5)
	call SetTeams(5)
	call SetGamePlacement(MAP_PLACEMENT_TEAMS_TOGETHER)
	call DefineStartLocation(0, - 14400.000000, - 15616.000000)
	call DefineStartLocation(1, - 14400.000000, - 15616.000000)
	call DefineStartLocation(2, - 14400.000000, - 15616.000000)
	call DefineStartLocation(3, - 14400.000000, - 15616.000000)
	call DefineStartLocation(4, - 14400.000000, - 15616.000000)
	call InitCustomPlayerSlots()
	call InitCustomTeams()
	call InitAllyPriorities()
endfunction




//Struct method generated initializers/callers:

