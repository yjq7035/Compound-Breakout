JassCommon = require "jass.common"
JassGlobals = require "jass.globals"
JassSlk = require "jass.slk"
JassJapi = require "jass.japi"


cj = {}
--- 字符串转技能ID | 参数: abilityIdString(string) | 返回: integer
cj.AbilityId = JassCommon["AbilityId"]
--- 技能ID转字符串 | 参数: abilityId(integer) | 返回: string
cj.AbilityId2String = JassCommon["AbilityId2String"]
--- 反余弦(弧度) [R] | 参数: x(real) | 返回: real
cj.Acos = JassCommon["Acos"]
--- 增加经验值 [R] | 参数: whichHero(unit), xpToAdd(integer), showEyeCandy(boolean)
cj.AddHeroXP = JassCommon["AddHeroXP"]
--- 闪动指示器(对单位) [R] | 参数: whichWidget(widget), red(integer), green(integer), blue(integer), alpha(integer)
cj.AddIndicator = JassCommon["AddIndicator"]
--- 添加物品(所有市场) | 参数: itemId(integer), currentStock(integer), stockMax(integer)
cj.AddItemToAllStock = JassCommon["AddItemToAllStock"]
--- 添加物品到商店库存 | 参数: whichUnit(unit), itemId(integer), currentStock(integer), stockMax(integer)
cj.AddItemToStock = JassCommon["AddItemToStock"]
--- 新建闪电效果 [R] | 参数: codeName(string), checkVisibility(boolean), x1(real), y1(real), x2(real), y2(real) | 返回: lightning
cj.AddLightning = JassCommon["AddLightning"]
--- 新建闪电效果(指定Z轴) [R] | 参数: codeName(string), checkVisibility(boolean), x1(real), y1(real), z1(real), x2(real), y2(real), z2(real) | 返回: lightning
cj.AddLightningEx = JassCommon["AddLightningEx"]
--- 增加科技等级 | 参数: whichPlayer(player), techid(integer), levels(integer)
cj.AddPlayerTechResearched = JassCommon["AddPlayerTechResearched"]
--- 增加资源数量 | 参数: whichUnit(unit), amount(integer)
cj.AddResourceAmount = JassCommon["AddResourceAmount"]
--- 新建特效(创建到坐标) [R] | 参数: modelName(string), x(real), y(real) | 返回: effect
cj.AddSpecialEffect = JassCommon["AddSpecialEffect"]
--- 新建特效(创建到点) [R] | 参数: modelName(string), where(location) | 返回: effect
cj.AddSpecialEffectLoc = JassCommon["AddSpecialEffectLoc"]
--- 新建特效(创建到单位) [R] | 参数: modelName(string), targetWidget(widget), attachPointName(string) | 返回: effect
cj.AddSpecialEffectTarget = JassCommon["AddSpecialEffectTarget"]
--- 新建特效(技能字符串，坐标) | 参数: abilityString(string), t(effecttype), x(real), y(real) | 返回: effect
cj.AddSpellEffect = JassCommon["AddSpellEffect"]
--- 新建特效(指定技能，创建到坐标) [R] | 参数: abilityId(integer), t(effecttype), x(real), y(real) | 返回: effect
cj.AddSpellEffectById = JassCommon["AddSpellEffectById"]
--- 新建特效(指定技能，创建到点) [R] | 参数: abilityId(integer), t(effecttype), where(location) | 返回: effect
cj.AddSpellEffectByIdLoc = JassCommon["AddSpellEffectByIdLoc"]
--- 新建特效(技能字符串，点) | 参数: abilityString(string), t(effecttype), where(location) | 返回: effect
cj.AddSpellEffectLoc = JassCommon["AddSpellEffectLoc"]
--- 新建特效(技能字符串，目标) | 参数: modelName(string), t(effecttype), targetWidget(widget), attachPoint(string) | 返回: effect
cj.AddSpellEffectTarget = JassCommon["AddSpellEffectTarget"]
--- 新建特效(指定技能，创建到单位) [R] | 参数: abilityId(integer), t(effecttype), targetWidget(widget), attachPoint(string) | 返回: effect
cj.AddSpellEffectTargetById = JassCommon["AddSpellEffectTargetById"]
--- 添加/删除 单位动画附加名 [R] | 参数: whichUnit(unit), animProperties(string), add(boolean)
cj.AddUnitAnimationProperties = JassCommon["AddUnitAnimationProperties"]
--- 添加单位(所有市场) | 参数: unitId(integer), currentStock(integer), stockMax(integer)
cj.AddUnitToAllStock = JassCommon["AddUnitToAllStock"]
--- 添加单位到商店库存 | 参数: whichUnit(unit), unitId(integer), currentStock(integer), stockMax(integer)
cj.AddUnitToStock = JassCommon["AddUnitToStock"]
--- 新建天气效果 [R] | 参数: where(rect), effectID(integer) | 返回: weathereffect
cj.AddWeatherEffect = JassCommon["AddWeatherEffect"]
--- 调整镜头属性(相对值) | 参数: whichField(camerafield), offset(real), duration(real)
cj.AdjustCameraField = JassCommon["AdjustCameraField"]
--- 逻辑与(条件表达式) | 参数: operandA(boolexpr), operandB(boolexpr) | 返回: boolexpr
cj.And = JassCommon["And"]
--- 反正弦(弧度) [R] | 参数: y(real) | 返回: real
cj.Asin = JassCommon["Asin"]
--- 反正切(弧度) [R] | 参数: x(real) | 返回: real
cj.Atan = JassCommon["Atan"]
--- 反正切(Y:X)(弧度) [R] | 参数: y(real), x(real) | 返回: real
cj.Atan2 = JassCommon["Atan2"]
--- 绑定单位 | 参数: soundHandle(sound), whichUnit(unit)
cj.AttachSoundToUnit = JassCommon["AttachSoundToUnit"]
--- 缓存玩家英雄数据 | 参数: whichPlayer(player)
cj.CachePlayerHeroData = JassCommon["CachePlayerHeroData"]
--- 设置镜头平滑参数 | 参数: factor(real)
cj.CameraSetSmoothingFactor = JassCommon["CameraSetSmoothingFactor"]
--- 设置镜头源扰动 | 参数: mag(real), velocity(real)
cj.CameraSetSourceNoise = JassCommon["CameraSetSourceNoise"]
--- 摇晃镜头源(所有玩家) [R] | 参数: mag(real), velocity(real), vertOnly(boolean)
cj.CameraSetSourceNoiseEx = JassCommon["CameraSetSourceNoiseEx"]
--- 设置镜头目标扰动 | 参数: mag(real), velocity(real)
cj.CameraSetTargetNoise = JassCommon["CameraSetTargetNoise"]
--- 摇晃镜头目标(所有玩家) [R] | 参数: mag(real), velocity(real), vertOnly(boolean)
cj.CameraSetTargetNoiseEx = JassCommon["CameraSetTargetNoiseEx"]
--- 应用镜头设置(平移) | 参数: whichSetup(camerasetup), doPan(boolean), panTimed(boolean)
cj.CameraSetupApply = JassCommon["CameraSetupApply"]
--- 应用镜头(所有玩家)(限时) [R] | 参数: whichSetup(camerasetup), doPan(boolean), forceDuration(real)
cj.CameraSetupApplyForceDuration = JassCommon["CameraSetupApplyForceDuration"]
--- 强制应用镜头设置(带Z轴延迟) | 参数: whichSetup(camerasetup), zDestOffset(real), forceDuration(real)
cj.CameraSetupApplyForceDurationWithZ = JassCommon["CameraSetupApplyForceDurationWithZ"]
--- 应用镜头设置(带Z轴) | 参数: whichSetup(camerasetup), zDestOffset(real)
cj.CameraSetupApplyWithZ = JassCommon["CameraSetupApplyWithZ"]
--- 镜头目标点 | 参数: whichSetup(camerasetup) | 返回: location
cj.CameraSetupGetDestPositionLoc = JassCommon["CameraSetupGetDestPositionLoc"]
--- 获取镜头设置目标点X坐标 | 参数: whichSetup(camerasetup) | 返回: real
cj.CameraSetupGetDestPositionX = JassCommon["CameraSetupGetDestPositionX"]
--- 获取镜头设置目标点Y坐标 | 参数: whichSetup(camerasetup) | 返回: real
cj.CameraSetupGetDestPositionY = JassCommon["CameraSetupGetDestPositionY"]
--- 镜头属性(指定镜头) [R] | 参数: whichSetup(camerasetup), whichField(camerafield) | 返回: real
cj.CameraSetupGetField = JassCommon["CameraSetupGetField"]
--- 设置镜头设置目标点位置 | 参数: whichSetup(camerasetup), x(real), y(real), duration(real)
cj.CameraSetupSetDestPosition = JassCommon["CameraSetupSetDestPosition"]
--- 设置镜头设置属性 | 参数: whichSetup(camerasetup), whichField(camerafield), value(real), duration(real)
cj.CameraSetupSetField = JassCommon["CameraSetupSetField"]
--- 切换关卡 [R] | 参数: newLevel(string), doScoreScreen(boolean)
cj.ChangeLevel = JassCommon["ChangeLevel"]
--- 输入作弊码 [R] | 参数: cheatStr(string)
cj.Cheat = JassCommon["Cheat"]
--- 随机等级中立单位类型 | 参数: level(integer) | 返回: integer
cj.ChooseRandomCreep = JassCommon["ChooseRandomCreep"]
--- 随机等级物品类型 [C] | 参数: level(integer) | 返回: integer
cj.ChooseRandomItem = JassCommon["ChooseRandomItem"]
--- 随机选取指定类型的物品 | 参数: whichType(itemtype), level(integer) | 返回: integer
cj.ChooseRandomItemEx = JassCommon["ChooseRandomItemEx"]
--- 随机中立建筑类型 | 返回: integer
cj.ChooseRandomNPBuilding = JassCommon["ChooseRandomNPBuilding"]
--- 清空背景音乐列表
cj.ClearMapMusic = JassCommon["ClearMapMusic"]
--- 清空选择(所有玩家)
cj.ClearSelection = JassCommon["ClearSelection"]
--- 清空文本信息(所有玩家) [R]
cj.ClearTextMessages = JassCommon["ClearTextMessages"]
--- 发送AI命令 | 参数: num(player), command(integer), data(integer)
cj.CommandAI = JassCommon["CommandAI"]
--- 创建条件表达式 | 参数: func(code) | 返回: conditionfunc
cj.Condition = JassCommon["Condition"]
--- 转换整型为AI难度类型 | 参数: i(integer) | 返回: aidifficulty
cj.ConvertAIDifficulty = JassCommon["ConvertAIDifficulty"]
--- 转换整型为联盟类型 | 参数: i(integer) | 返回: alliancetype
cj.ConvertAllianceType = JassCommon["ConvertAllianceType"]
--- 转换整型为攻击类型 | 参数: i(integer) | 返回: attacktype
cj.ConvertAttackType = JassCommon["ConvertAttackType"]
--- 转换整型为混合模式 | 参数: i(integer) | 返回: blendmode
cj.ConvertBlendMode = JassCommon["ConvertBlendMode"]
--- 转换整型为镜头属性 | 参数: i(integer) | 返回: camerafield
cj.ConvertCameraField = JassCommon["ConvertCameraField"]
--- 转换整型为伤害类型 | 参数: i(integer) | 返回: damagetype
cj.ConvertDamageType = JassCommon["ConvertDamageType"]
--- 转换整型为对话框事件 | 参数: i(integer) | 返回: dialogevent
cj.ConvertDialogEvent = JassCommon["ConvertDialogEvent"]
--- 转换整型为特效类型 | 参数: i(integer) | 返回: effecttype
cj.ConvertEffectType = JassCommon["ConvertEffectType"]
--- 转换整型为浮点游戏状态 | 参数: i(integer) | 返回: fgamestate
cj.ConvertFGameState = JassCommon["ConvertFGameState"]
--- 转换整型为迷雾状态 | 参数: i(integer) | 返回: fogstate
cj.ConvertFogState = JassCommon["ConvertFogState"]
--- 转换整型为游戏难度 | 参数: i(integer) | 返回: gamedifficulty
cj.ConvertGameDifficulty = JassCommon["ConvertGameDifficulty"]
--- 转换整型为游戏事件 | 参数: i(integer) | 返回: gameevent
cj.ConvertGameEvent = JassCommon["ConvertGameEvent"]
--- 转换整型为游戏速度 | 参数: i(integer) | 返回: gamespeed
cj.ConvertGameSpeed = JassCommon["ConvertGameSpeed"]
--- 转换整型为游戏类型 | 参数: i(integer) | 返回: gametype
cj.ConvertGameType = JassCommon["ConvertGameType"]
--- 转换整型为整数游戏状态 | 参数: i(integer) | 返回: igamestate
cj.ConvertIGameState = JassCommon["ConvertIGameState"]
--- 转换整型为物品类型 | 参数: i(integer) | 返回: itemtype
cj.ConvertItemType = JassCommon["ConvertItemType"]
--- 转换整型为比较操作符 | 参数: i(integer) | 返回: limitop
cj.ConvertLimitOp = JassCommon["ConvertLimitOp"]
--- 转换整型为地图控制方式 | 参数: i(integer) | 返回: mapcontrol
cj.ConvertMapControl = JassCommon["ConvertMapControl"]
--- 转换整型为地图密度 | 参数: i(integer) | 返回: mapdensity
cj.ConvertMapDensity = JassCommon["ConvertMapDensity"]
--- 转换整型为地图标记 | 参数: i(integer) | 返回: mapflag
cj.ConvertMapFlag = JassCommon["ConvertMapFlag"]
--- 转换整型为地图设置 | 参数: i(integer) | 返回: mapsetting
cj.ConvertMapSetting = JassCommon["ConvertMapSetting"]
--- 转换整型为地图可见性 | 参数: i(integer) | 返回: mapvisibility
cj.ConvertMapVisibility = JassCommon["ConvertMapVisibility"]
--- 转换整型为路径类型 | 参数: i(integer) | 返回: pathingtype
cj.ConvertPathingType = JassCommon["ConvertPathingType"]
--- 转换整型为放置方式 | 参数: i(integer) | 返回: placement
cj.ConvertPlacement = JassCommon["ConvertPlacement"]
--- 转换整型为玩家颜色 | 参数: i(integer) | 返回: playercolor
cj.ConvertPlayerColor = JassCommon["ConvertPlayerColor"]
--- 转换整型为玩家事件 | 参数: i(integer) | 返回: playerevent
cj.ConvertPlayerEvent = JassCommon["ConvertPlayerEvent"]
--- 转换整型为玩家游戏结果 | 参数: i(integer) | 返回: playergameresult
cj.ConvertPlayerGameResult = JassCommon["ConvertPlayerGameResult"]
--- 转换整型为玩家分数 | 参数: i(integer) | 返回: playerscore
cj.ConvertPlayerScore = JassCommon["ConvertPlayerScore"]
--- 转换整型为玩家槽位状态 | 参数: i(integer) | 返回: playerslotstate
cj.ConvertPlayerSlotState = JassCommon["ConvertPlayerSlotState"]
--- 转换整型为玩家状态 | 参数: i(integer) | 返回: playerstate
cj.ConvertPlayerState = JassCommon["ConvertPlayerState"]
--- 转换整型为玩家单位事件 | 参数: i(integer) | 返回: playerunitevent
cj.ConvertPlayerUnitEvent = JassCommon["ConvertPlayerUnitEvent"]
--- 转换整型为种族 | 参数: i(integer) | 返回: race
cj.ConvertRace = JassCommon["ConvertRace"]
--- 转换整型为种族偏好 | 参数: i(integer) | 返回: racepreference
cj.ConvertRacePref = JassCommon["ConvertRacePref"]
--- 转换整型为稀有度控制 | 参数: i(integer) | 返回: raritycontrol
cj.ConvertRarityControl = JassCommon["ConvertRarityControl"]
--- 转换整型为声音类型 | 参数: i(integer) | 返回: soundtype
cj.ConvertSoundType = JassCommon["ConvertSoundType"]
--- 转换整型为起始位置优先级 | 参数: i(integer) | 返回: startlocprio
cj.ConvertStartLocPrio = JassCommon["ConvertStartLocPrio"]
--- 转换整型为纹理映射标记 | 参数: i(integer) | 返回: texmapflags
cj.ConvertTexMapFlags = JassCommon["ConvertTexMapFlags"]
--- 转换整型为单位事件 | 参数: i(integer) | 返回: unitevent
cj.ConvertUnitEvent = JassCommon["ConvertUnitEvent"]
--- 转换整型为单位状态 | 参数: i(integer) | 返回: unitstate
cj.ConvertUnitState = JassCommon["ConvertUnitState"]
--- 转换整型为单位类型 | 参数: i(integer) | 返回: unittype
cj.ConvertUnitType = JassCommon["ConvertUnitType"]
--- 转换整型为版本 | 参数: i(integer) | 返回: version
cj.ConvertVersion = JassCommon["ConvertVersion"]
--- 转换整型为音量组 | 参数: i(integer) | 返回: volumegroup
cj.ConvertVolumeGroup = JassCommon["ConvertVolumeGroup"]
--- 转换整型为武器类型 | 参数: i(integer) | 返回: weapontype
cj.ConvertWeaponType = JassCommon["ConvertWeaponType"]
--- 转换整型为控件事件 | 参数: i(integer) | 返回: widgetevent
cj.ConvertWidgetEvent = JassCommon["ConvertWidgetEvent"]
--- 复制存档文件 | 参数: sourceSaveName(string), destSaveName(string) | 返回: boolean
cj.CopySaveGame = JassCommon["CopySaveGame"]
--- 余弦(弧度) [R] | 参数: radians(real) | 返回: real
cj.Cos = JassCommon["Cos"]
--- 新建不死族金矿 [R] | 参数: id(player), x(real), y(real), face(real) | 返回: unit
cj.CreateBlightedGoldmine = JassCommon["CreateBlightedGoldmine"]
--- 创建镜头设置 返回: camerasetup
cj.CreateCameraSetup = JassCommon["CreateCameraSetup"]
--- 新建尸体 [R] | 参数: whichPlayer(player), unitid(integer), x(real), y(real), face(real) | 返回: unit
cj.CreateCorpse = JassCommon["CreateCorpse"]
--- 创建已死亡的可破坏物 | 参数: objectid(integer), x(real), y(real), face(real), scale(real), variation(integer) | 返回: destructable
cj.CreateDeadDestructable = JassCommon["CreateDeadDestructable"]
--- 新建可破坏物(死亡的) [R] | 参数: objectid(integer), x(real), y(real), z(real), face(real), scale(real), variation(integer) | 返回: destructable
cj.CreateDeadDestructableZ = JassCommon["CreateDeadDestructableZ"]
--- 创建失败条件 | 返回: defeatcondition
cj.CreateDefeatCondition = JassCommon["CreateDefeatCondition"]
--- 创建可破坏物 | 参数: objectid(integer), x(real), y(real), face(real), scale(real), variation(integer) | 返回: destructable
cj.CreateDestructable = JassCommon["CreateDestructable"]
--- 新建可破坏物 [R] | 参数: objectid(integer), x(real), y(real), z(real), face(real), scale(real), variation(integer) | 返回: destructable
cj.CreateDestructableZ = JassCommon["CreateDestructableZ"]
--- 新建可见度修正器(圆范围) [R] | 参数: forWhichPlayer(player), whichState(fogstate), centerx(real), centerY(real), radius(real), useSharedVision(boolean), afterUnits(boolean) | 返回: fogmodifier
cj.CreateFogModifierRadius = JassCommon["CreateFogModifierRadius"]
--- 创建迷雾修改器(圆形范围，点) | 参数: forWhichPlayer(player), whichState(fogstate), center(location), radius(real), useSharedVision(boolean), afterUnits(boolean) | 返回: fogmodifier
cj.CreateFogModifierRadiusLoc = JassCommon["CreateFogModifierRadiusLoc"]
--- 新建可见度修正器(矩形区域) [R] | 参数: forWhichPlayer(player), whichState(fogstate), where(rect), useSharedVision(boolean), afterUnits(boolean) | 返回: fogmodifier
cj.CreateFogModifierRect = JassCommon["CreateFogModifierRect"]
--- 新建玩家组 [R] | 返回: force
cj.CreateForce = JassCommon["CreateForce"]
--- 创建单位组 [C] | 返回: group
cj.CreateGroup = JassCommon["CreateGroup"]
--- 新建图像 [R] | 参数: file(string), sizeX(real), sizeY(real), sizeZ(real), posX(real), posY(real), posZ(real), originX(real), originY(real), originZ(real), imageType(integer) | 返回: image
cj.CreateImage = JassCommon["CreateImage"]
--- 创建 | 参数: itemid(integer), x(real), y(real) | 返回: item
cj.CreateItem = JassCommon["CreateItem"]
--- 新建物品池 [R] | 返回: itempool
cj.CreateItemPool = JassCommon["CreateItemPool"]
--- 新建排行榜 [R] | 返回: leaderboard
cj.CreateLeaderboard = JassCommon["CreateLeaderboard"]
--- 创建MIDI音乐 [new] | 参数: soundLabel(string), fadeInRate(integer), fadeOutRate(integer) | 返回: sound
cj.CreateMIDISound = JassCommon["CreateMIDISound"]
--- 新建多面板 [R] | 返回: multiboard
cj.CreateMultiboard = JassCommon["CreateMultiboard"]
--- 新建任务 [R] | 返回: quest
cj.CreateQuest = JassCommon["CreateQuest"]
--- 新建区域 [R] | 返回: region
cj.CreateRegion = JassCommon["CreateRegion"]
--- 创建声音 [new] | 参数: fileName(string), looping(boolean), is3D(boolean), stopwhenoutofrange(boolean), fadeInRate(integer), fadeOutRate(integer), eaxSetting(string) | 返回: sound
cj.CreateSound = JassCommon["CreateSound"]
--- 根据文件名和标签创建声音 [new] | 参数: fileName(string), looping(boolean), is3D(boolean), stopwhenoutofrange(boolean), fadeInRate(integer), fadeOutRate(integer), SLKEntryName(string) | 返回: sound
cj.CreateSoundFilenameWithLabel = JassCommon["CreateSoundFilenameWithLabel"]
--- 从标签创建声音 [new] | 参数: soundLabel(string), looping(boolean), is3D(boolean), stopwhenoutofrange(boolean), fadeInRate(integer), fadeOutRate(integer) | 返回: sound
cj.CreateSoundFromLabel = JassCommon["CreateSoundFromLabel"]
--- 删除技能 [C] | 返回: texttag
cj.CreateTextTag = JassCommon["CreateTextTag"]
--- 新建计时器 [R] | 返回: timer
cj.CreateTimer = JassCommon["CreateTimer"]
--- 新建计时器窗口 [R] | 参数: t(timer) | 返回: timerdialog
cj.CreateTimerDialog = JassCommon["CreateTimerDialog"]
--- 自定义代码 [C] | 参数: trackableModelPath(string), x(real), y(real), facing(real) | 返回: trackable
cj.CreateTrackable = JassCommon["CreateTrackable"]
--- 新建触发 [R] | 返回: trigger
cj.CreateTrigger = JassCommon["CreateTrigger"]
--- 新建地面纹理变化 [R] | 参数: x(real), y(real), name(string), red(integer), green(integer), blue(integer), alpha(integer), forcePaused(boolean), noBirthTime(boolean) | 返回: ubersplat
cj.CreateUbersplat = JassCommon["CreateUbersplat"]
--- 新建单位(指定坐标) [R] | 参数: id(player), unitid(integer), x(real), y(real), face(real) | 返回: unit
cj.CreateUnit = JassCommon["CreateUnit"]
--- 新建单位(指定点) [R] | 参数: id(player), unitid(integer), whichLocation(location), face(real) | 返回: unit
cj.CreateUnitAtLoc = JassCommon["CreateUnitAtLoc"]
--- 按名字创建单位(指定点) | 参数: id(player), unitname(string), whichLocation(location), face(real) | 返回: unit
cj.CreateUnitAtLocByName = JassCommon["CreateUnitAtLocByName"]
--- 按名字创建单位(指定坐标) | 参数: whichPlayer(player), unitname(string), x(real), y(real), face(real) | 返回: unit
cj.CreateUnitByName = JassCommon["CreateUnitByName"]
--- 新建单位池 [R] | 返回: unitpool
cj.CreateUnitPool = JassCommon["CreateUnitPool"]
--- 设置玩家与目标联盟关系 | 参数: whichPlayer(player), toWhichPlayers(force), flag(boolean)
cj.CripplePlayer = JassCommon["CripplePlayer"]
--- 降低技能等级 [R] | 参数: whichUnit(unit), abilcode(integer) | 返回: integer
cj.DecUnitAbilityLevel = JassCommon["DecUnitAbilityLevel"]
--- 改变失败条件说明 | 参数: whichCondition(defeatcondition), description(string)
cj.DefeatConditionSetDescription = JassCommon["DefeatConditionSetDescription"]
--- 定义起始位置(坐标) | 参数: whichStartLoc(integer), x(real), y(real)
cj.DefineStartLocation = JassCommon["DefineStartLocation"]
--- 定义起始位置(点) | 参数: whichStartLoc(integer), whichLocation(location)
cj.DefineStartLocationLoc = JassCommon["DefineStartLocationLoc"]
--- 转换角度为弧度 | 参数: degrees(real) | 返回: real
cj.Deg2Rad = JassCommon["Deg2Rad"]
--- 销毁布尔表达式 | 参数: e(boolexpr)
cj.DestroyBoolExpr = JassCommon["DestroyBoolExpr"]
--- 销毁条件表达式 | 参数: c(conditionfunc)
cj.DestroyCondition = JassCommon["DestroyCondition"]
--- 删除失败条件 | 参数: whichCondition(defeatcondition)
cj.DestroyDefeatCondition = JassCommon["DestroyDefeatCondition"]
--- 删除特效 | 参数: whichEffect(effect)
cj.DestroyEffect = JassCommon["DestroyEffect"]
--- 销毁过滤器 | 参数: f(filterfunc)
cj.DestroyFilter = JassCommon["DestroyFilter"]
--- 删除可见度修正器 | 参数: whichFogModifier(fogmodifier)
cj.DestroyFogModifier = JassCommon["DestroyFogModifier"]
--- 删除玩家组 [R] | 参数: whichForce(force)
cj.DestroyForce = JassCommon["DestroyForce"]
--- 删除单位组 [R] | 参数: whichGroup(group)
cj.DestroyGroup = JassCommon["DestroyGroup"]
--- 删除 | 参数: whichImage(image)
cj.DestroyImage = JassCommon["DestroyImage"]
--- 删除物品池 [R] | 参数: whichItemPool(itempool)
cj.DestroyItemPool = JassCommon["DestroyItemPool"]
--- 删除 | 参数: lb(leaderboard)
cj.DestroyLeaderboard = JassCommon["DestroyLeaderboard"]
--- 删除闪电效果 | 参数: whichBolt(lightning) | 返回: boolean
cj.DestroyLightning = JassCommon["DestroyLightning"]
--- 删除 | 参数: lb(multiboard)
cj.DestroyMultiboard = JassCommon["DestroyMultiboard"]
--- 删除任务 | 参数: whichQuest(quest)
cj.DestroyQuest = JassCommon["DestroyQuest"]
--- 删除 | 参数: t(texttag)
cj.DestroyTextTag = JassCommon["DestroyTextTag"]
--- 删除计时器 [R] | 参数: whichTimer(timer)
cj.DestroyTimer = JassCommon["DestroyTimer"]
--- 删除计时器窗口 | 参数: whichDialog(timerdialog)
cj.DestroyTimerDialog = JassCommon["DestroyTimerDialog"]
--- 删除触发器 [R] | 参数: whichTrigger(trigger)
cj.DestroyTrigger = JassCommon["DestroyTrigger"]
--- 删除地面纹理变化 | 参数: whichSplat(ubersplat)
cj.DestroyUbersplat = JassCommon["DestroyUbersplat"]
--- 删除单位池 [R] | 参数: whichPool(unitpool)
cj.DestroyUnitPool = JassCommon["DestroyUnitPool"]
--- 复活 | 参数: d(destructable), life(real), birth(boolean)
cj.DestructableRestoreLife = JassCommon["DestructableRestoreLife"]
--- 添加对话框按钮 [R] | 参数: whichDialog(dialog), buttonText(string), hotkey(integer) | 返回: button
cj.DialogAddButton = JassCommon["DialogAddButton"]
--- 添加退出游戏按钮 [R] | 参数: whichDialog(dialog), doScoreScreen(boolean), buttonText(string), hotkey(integer) | 返回: button
cj.DialogAddQuitButton = JassCommon["DialogAddQuitButton"]
--- 清空 | 参数: whichDialog(dialog)
cj.DialogClear = JassCommon["DialogClear"]
--- 新建对话框 [R] | 返回: dialog
cj.DialogCreate = JassCommon["DialogCreate"]
--- 删除 [R] | 参数: whichDialog(dialog)
cj.DialogDestroy = JassCommon["DialogDestroy"]
--- 显示/隐藏 [R] | 参数: whichPlayer(player), whichDialog(dialog), flag(boolean)
cj.DialogDisplay = JassCommon["DialogDisplay"]
--- 改变标题 | 参数: whichDialog(dialog), messageText(string)
cj.DialogSetMessage = JassCommon["DialogSetMessage"]
--- 禁用 重新开始任务按钮 | 参数: flag(boolean)
cj.DisableRestartMission = JassCommon["DisableRestartMission"]
--- 关闭触发 | 参数: whichTrigger(trigger)
cj.DisableTrigger = JassCommon["DisableTrigger"]
--- 显示/隐藏 滤镜 | 参数: flag(boolean)
cj.DisplayCineFilter = JassCommon["DisplayCineFilter"]
--- DisplayLoadDialog
cj.DisplayLoadDialog = JassCommon["DisplayLoadDialog"]
--- 对玩家显示文本消息(自动限时) [R] | 参数: toPlayer(player), x(real), y(real), message(string)
cj.DisplayTextToPlayer = JassCommon["DisplayTextToPlayer"]
--- 显示计时文本(来自玩家) | 参数: toPlayer(player), x(real), y(real), duration(real), message(string)
cj.DisplayTimedTextFromPlayer = JassCommon["DisplayTimedTextFromPlayer"]
--- 对玩家显示文本消息(指定时间) [R] | 参数: toPlayer(player), x(real), y(real), duration(real), message(string)
cj.DisplayTimedTextToPlayer = JassCommon["DisplayTimedTextToPlayer"]
--- 关闭游戏录像功能 [R]
cj.DoNotSaveReplay = JassCommon["DoNotSaveReplay"]
--- 允许/禁用框选 | 参数: state(boolean), ui(boolean)
cj.EnableDragSelect = JassCommon["EnableDragSelect"]
--- 允许/禁用小地图按钮 | 参数: enableAlly(boolean), enableCreep(boolean)
cj.EnableMinimapFilterButtons = JassCommon["EnableMinimapFilterButtons"]
--- 允许/禁止闭塞(所有玩家) [R] | 参数: flag(boolean)
cj.EnableOcclusion = JassCommon["EnableOcclusion"]
--- 允许/禁用预选 | 参数: state(boolean), ui(boolean)
cj.EnablePreSelect = JassCommon["EnablePreSelect"]
--- 允许/禁用选择 | 参数: state(boolean), ui(boolean)
cj.EnableSelect = JassCommon["EnableSelect"]
--- 开启触发 | 参数: whichTrigger(trigger)
cj.EnableTrigger = JassCommon["EnableTrigger"]
--- 启用/禁用玩家控制权(所有玩家) [R] | 参数: b(boolean)
cj.EnableUserControl = JassCommon["EnableUserControl"]
--- 启用/禁用用户界面 | 参数: b(boolean)
cj.EnableUserUI = JassCommon["EnableUserUI"]
--- 启用/禁用 天气效果 | 参数: whichEffect(weathereffect), enable(boolean)
cj.EnableWeatherEffect = JassCommon["EnableWeatherEffect"]
--- 允许/禁止 边界染色(所有玩家) [R] | 参数: b(boolean)
cj.EnableWorldFogBoundary = JassCommon["EnableWorldFogBoundary"]
--- EndCinematicScene
cj.EndCinematicScene = JassCommon["EndCinematicScene"]
--- 结束游戏 | 参数: doScoreScreen(boolean)
cj.EndGame = JassCommon["EndGame"]
--- 停止主题音乐[C]
cj.EndThematicMusic = JassCommon["EndThematicMusic"]
--- 枚举矩形区域内的可破坏物 | 参数: r(rect), filter(boolexpr), actionFunc(code)
cj.EnumDestructablesInRect = JassCommon["EnumDestructablesInRect"]
--- 枚举矩形区域内的物品 | 参数: r(rect), filter(boolexpr), actionFunc(code)
cj.EnumItemsInRect = JassCommon["EnumItemsInRect"]
--- 运行函数 [R] | 参数: funcName(string)
cj.ExecuteFunc = JassCommon["ExecuteFunc"]
--- 创建过滤器 | 参数: func(code) | 返回: filterfunc
cj.Filter = JassCommon["Filter"]
--- 结束地面纹理变化 | 参数: whichSplat(ubersplat)
cj.FinishUbersplat = JassCommon["FinishUbersplat"]
--- 自定义代码 [C] | 参数: whichGroup(group) | 返回: unit
cj.FirstOfGroup = JassCommon["FirstOfGroup"]
--- 闪动任务按钮
cj.FlashQuestDialogButton = JassCommon["FlashQuestDialogButton"]
--- <1.24> 清空哈希表主索引 [C] | 参数: table(hashtable), parentKey(integer)
cj.FlushChildHashtable = JassCommon["FlushChildHashtable"]
--- 删除缓存 | 参数: cache(gamecache)
cj.FlushGameCache = JassCommon["FlushGameCache"]
--- <1.24> 清空哈希表 | 参数: table(hashtable)
cj.FlushParentHashtable = JassCommon["FlushParentHashtable"]
--- 清除游戏缓存中的布尔值 | 参数: cache(gamecache), missionKey(string), key(string)
cj.FlushStoredBoolean = JassCommon["FlushStoredBoolean"]
--- 清除游戏缓存中的整数 | 参数: cache(gamecache), missionKey(string), key(string)
cj.FlushStoredInteger = JassCommon["FlushStoredInteger"]
--- 删除类别 | 参数: cache(gamecache), missionKey(string)
cj.FlushStoredMission = JassCommon["FlushStoredMission"]
--- 清除游戏缓存中的实数 | 参数: cache(gamecache), missionKey(string), key(string)
cj.FlushStoredReal = JassCommon["FlushStoredReal"]
--- 清除游戏缓存中的字符串 | 参数: cache(gamecache), missionKey(string), key(string)
cj.FlushStoredString = JassCommon["FlushStoredString"]
--- 清除游戏缓存中的单位 | 参数: cache(gamecache), missionKey(string), key(string)
cj.FlushStoredUnit = JassCommon["FlushStoredUnit"]
--- 启用/禁用 战争迷雾 [R] | 参数: enable(boolean)
cj.FogEnable = JassCommon["FogEnable"]
--- 启用/禁用黑色阴影 [R] | 参数: enable(boolean)
cj.FogMaskEnable = JassCommon["FogMaskEnable"]
--- 启用可见度修正器 | 参数: whichFogModifier(fogmodifier)
cj.FogModifierStart = JassCommon["FogModifierStart"]
--- 禁用可见度修正器 | 参数: whichFogModifier(fogmodifier)
cj.FogModifierStop = JassCommon["FogModifierStop"]
--- 选取玩家组内玩家做动作(多个动作) | 参数: whichForce(force), callback(code)
cj.ForForce = JassCommon["ForForce"]
--- 选取单位组内单位做动作 | 参数: whichGroup(group), callback(code)
cj.ForGroup = JassCommon["ForGroup"]
--- 添加玩家 [R] | 参数: whichForce(force), whichPlayer(player)
cj.ForceAddPlayer = JassCommon["ForceAddPlayer"]
--- ForceCampaignSelectScreen
cj.ForceCampaignSelectScreen = JassCommon["ForceCampaignSelectScreen"]
--- 字幕显示 | 参数: flag(boolean)
cj.ForceCinematicSubtitles = JassCommon["ForceCinematicSubtitles"]
--- 清空玩家组 | 参数: whichForce(force)
cj.ForceClear = JassCommon["ForceClear"]
--- 选取玩家的盟友加入玩家组 | 参数: whichForce(force), whichPlayer(player), filter(boolexpr)
cj.ForceEnumAllies = JassCommon["ForceEnumAllies"]
--- 选取玩家的敌人加入玩家组 | 参数: whichForce(force), whichPlayer(player), filter(boolexpr)
cj.ForceEnumEnemies = JassCommon["ForceEnumEnemies"]
--- 选取所有玩家加入玩家组 | 参数: whichForce(force), filter(boolexpr)
cj.ForceEnumPlayers = JassCommon["ForceEnumPlayers"]
--- 选取指定数量玩家加入玩家组 | 参数: whichForce(force), filter(boolexpr), countLimit(integer)
cj.ForceEnumPlayersCounted = JassCommon["ForceEnumPlayersCounted"]
--- 设置玩家起始位置 | 参数: whichPlayer(player), startLocIndex(integer)
cj.ForcePlayerStartLocation = JassCommon["ForcePlayerStartLocation"]
--- ForceQuestDialogUpdate
cj.ForceQuestDialogUpdate = JassCommon["ForceQuestDialogUpdate"]
--- 移除玩家 [R] | 参数: whichForce(force), whichPlayer(player)
cj.ForceRemovePlayer = JassCommon["ForceRemovePlayer"]
--- ForceUICancel
cj.ForceUICancel = JassCommon["ForceUICancel"]
--- 发送按键事件 | 参数: key(string)
cj.ForceUIKey = JassCommon["ForceUIKey"]
--- 玩家的AI难度 | 参数: num(player) | 返回: aidifficulty
cj.GetAIDifficulty = JassCommon["GetAIDifficulty"]
--- 获取技能特效字符串 | 参数: abilityString(string), t(effecttype), index(integer) | 返回: string
cj.GetAbilityEffect = JassCommon["GetAbilityEffect"]
--- 技能效果路径名 | 参数: abilityId(integer), t(effecttype), index(integer) | 返回: string
cj.GetAbilityEffectById = JassCommon["GetAbilityEffectById"]
--- 获取技能音效字符串 | 参数: abilityString(string), t(soundtype) | 返回: string
cj.GetAbilitySound = JassCommon["GetAbilitySound"]
--- 技能音效名 | 参数: abilityId(integer), t(soundtype) | 返回: string
cj.GetAbilitySoundById = JassCommon["GetAbilitySoundById"]
--- 联盟颜色显示设置 | 返回: integer
cj.GetAllyColorFilterState = JassCommon["GetAllyColorFilterState"]
--- 攻击单位 | 返回: unit
cj.GetAttacker = JassCommon["GetAttacker"]
--- 购买者 | 返回: unit
cj.GetBuyingUnit = JassCommon["GetBuyingUnit"]
--- 获取镜头边界最大X | 返回: real
cj.GetCameraBoundMaxX = JassCommon["GetCameraBoundMaxX"]
--- 获取镜头边界最大Y | 返回: real
cj.GetCameraBoundMaxY = JassCommon["GetCameraBoundMaxY"]
--- 获取镜头边界最小X | 返回: real
cj.GetCameraBoundMinX = JassCommon["GetCameraBoundMinX"]
--- 获取镜头边界最小Y | 返回: real
cj.GetCameraBoundMinY = JassCommon["GetCameraBoundMinY"]
--- 当前镜头源位置 | 返回: location
cj.GetCameraEyePositionLoc = JassCommon["GetCameraEyePositionLoc"]
--- 当前镜头源X坐标 | 返回: real
cj.GetCameraEyePositionX = JassCommon["GetCameraEyePositionX"]
--- 当前镜头源Y坐标 | 返回: real
cj.GetCameraEyePositionY = JassCommon["GetCameraEyePositionY"]
--- 当前镜头源Z坐标 | 返回: real
cj.GetCameraEyePositionZ = JassCommon["GetCameraEyePositionZ"]
--- 镜头属性(当前镜头) | 参数: whichField(camerafield) | 返回: real
cj.GetCameraField = JassCommon["GetCameraField"]
--- 获取镜头边缘间距 | 参数: whichMargin(integer) | 返回: real
cj.GetCameraMargin = JassCommon["GetCameraMargin"]
--- 当前镜头目标点 | 返回: location
cj.GetCameraTargetPositionLoc = JassCommon["GetCameraTargetPositionLoc"]
--- 当前镜头目标X坐标 | 返回: real
cj.GetCameraTargetPositionX = JassCommon["GetCameraTargetPositionX"]
--- 当前镜头目标Y坐标 | 返回: real
cj.GetCameraTargetPositionY = JassCommon["GetCameraTargetPositionY"]
--- 当前镜头目标Z坐标 | 返回: real
cj.GetCameraTargetPositionZ = JassCommon["GetCameraTargetPositionZ"]
--- 被取消的建筑 | 返回: unit
cj.GetCancelledStructure = JassCommon["GetCancelledStructure"]
--- 被改变所有者的单位 | 返回: unit
cj.GetChangingUnit = JassCommon["GetChangingUnit"]
--- 原所有者 | 返回: player
cj.GetChangingUnitPrevOwner = JassCommon["GetChangingUnitPrevOwner"]
--- 点击的对话框按钮 | 返回: button
cj.GetClickedButton = JassCommon["GetClickedButton"]
--- 点击的对话框 | 返回: dialog
cj.GetClickedDialog = JassCommon["GetClickedDialog"]
--- 完成的建筑 | 返回: unit
cj.GetConstructedStructure = JassCommon["GetConstructedStructure"]
--- 正在建造的建筑 | 返回: unit
cj.GetConstructingStructure = JassCommon["GetConstructingStructure"]
--- 获取怪物密度 | 返回: mapdensity
cj.GetCreatureDensity = JassCommon["GetCreatureDensity"]
--- 小地图中立生物显示开启 | 返回: boolean
cj.GetCreepCampFilterState = JassCommon["GetCreepCampFilterState"]
--- 自定义战役按钮是否可见 | 参数: whichButton(integer) | 返回: boolean
cj.GetCustomCampaignButtonVisible = JassCommon["GetCustomCampaignButtonVisible"]
--- 腐化的单位 | 返回: unit
cj.GetDecayingUnit = JassCommon["GetDecayingUnit"]
--- 获取默认难度 | 返回: gamedifficulty
cj.GetDefaultDifficulty = JassCommon["GetDefaultDifficulty"]
--- 生命值 | 参数: d(destructable) | 返回: real
cj.GetDestructableLife = JassCommon["GetDestructableLife"]
--- 最大生命值 | 参数: d(destructable) | 返回: real
cj.GetDestructableMaxLife = JassCommon["GetDestructableMaxLife"]
--- 物件名字 | 参数: d(destructable) | 返回: string
cj.GetDestructableName = JassCommon["GetDestructableName"]
--- 闭塞高度 | 参数: d(destructable) | 返回: real
cj.GetDestructableOccluderHeight = JassCommon["GetDestructableOccluderHeight"]
--- 指定可破坏物的类型 | 参数: d(destructable) | 返回: integer
cj.GetDestructableTypeId = JassCommon["GetDestructableTypeId"]
--- 可破坏物所在X轴坐标 [R] | 参数: d(destructable) | 返回: real
cj.GetDestructableX = JassCommon["GetDestructableX"]
--- 可破坏物所在Y轴坐标 [R] | 参数: d(destructable) | 返回: real
cj.GetDestructableY = JassCommon["GetDestructableY"]
--- 获取被侦查到的单位 | 返回: unit
cj.GetDetectedUnit = JassCommon["GetDetectedUnit"]
--- 死亡单位 | 返回: unit
cj.GetDyingUnit = JassCommon["GetDyingUnit"]
--- 进入的单位 | 返回: unit
cj.GetEnteringUnit = JassCommon["GetEnteringUnit"]
--- 选取的可破坏物 | 返回: destructable
cj.GetEnumDestructable = JassCommon["GetEnumDestructable"]
--- 选取物品 | 返回: item
cj.GetEnumItem = JassCommon["GetEnumItem"]
--- 选取玩家 | 返回: player
cj.GetEnumPlayer = JassCommon["GetEnumPlayer"]
--- 选取单位 | 返回: unit
cj.GetEnumUnit = JassCommon["GetEnumUnit"]
--- 伤害值 | 返回: real
cj.GetEventDamage = JassCommon["GetEventDamage"]
--- 伤害来源 | 返回: unit
cj.GetEventDamageSource = JassCommon["GetEventDamageSource"]
--- 获取事件触发玩家 | 返回: player
cj.GetEventDetectingPlayer = JassCommon["GetEventDetectingPlayer"]
--- 获取事件游戏状态 | 返回: gamestate
cj.GetEventGameState = JassCommon["GetEventGameState"]
--- 输入的聊天信息 | 返回: string
cj.GetEventPlayerChatString = JassCommon["GetEventPlayerChatString"]
--- 匹配的聊天信息 | 返回: string
cj.GetEventPlayerChatStringMatched = JassCommon["GetEventPlayerChatStringMatched"]
--- 获取事件玩家状态值 | 返回: playerstate
cj.GetEventPlayerState = JassCommon["GetEventPlayerState"]
--- 事件目标单位 | 返回: unit
cj.GetEventTargetUnit = JassCommon["GetEventTargetUnit"]
--- 获取事件单位状态值 | 返回: unitstate
cj.GetEventUnitState = JassCommon["GetEventUnitState"]
--- 到期的计时器 | 返回: timer
cj.GetExpiredTimer = JassCommon["GetExpiredTimer"]
--- 匹配的可破坏物 | 返回: destructable
cj.GetFilterDestructable = JassCommon["GetFilterDestructable"]
--- 匹配物品 | 返回: item
cj.GetFilterItem = JassCommon["GetFilterItem"]
--- 匹配玩家 | 返回: player
cj.GetFilterPlayer = JassCommon["GetFilterPlayer"]
--- 匹配单位 | 返回: unit
cj.GetFilterUnit = JassCommon["GetFilterUnit"]
--- 获取浮点游戏状态值 | 参数: whichFloatGameState(fgamestate) | 返回: real
cj.GetFloatGameState = JassCommon["GetFloatGameState"]
--- 单位提供人口数量(指定单位类型) | 参数: unitId(integer) | 返回: integer
cj.GetFoodMade = JassCommon["GetFoodMade"]
--- 单位使用人口数量(指定单位类型) | 参数: unitId(integer) | 返回: integer
cj.GetFoodUsed = JassCommon["GetFoodUsed"]
--- 当前游戏难度 | 返回: gamedifficulty
cj.GetGameDifficulty = JassCommon["GetGameDifficulty"]
--- 获取游戏放置方式 | 返回: placement
cj.GetGamePlacement = JassCommon["GetGamePlacement"]
--- 当前游戏速度 | 返回: gamespeed
cj.GetGameSpeed = JassCommon["GetGameSpeed"]
--- 获取已选择的游戏类型 | 返回: gametype
cj.GetGameTypeSelected = JassCommon["GetGameTypeSelected"]
--- <1.24> 获取对象的h2i值 [C] | 参数: h(handle) | 返回: integer
cj.GetHandleId = JassCommon["GetHandleId"]
--- 英雄敏捷 [R] | 参数: whichHero(unit), includeBonuses(boolean) | 返回: integer
cj.GetHeroAgi = JassCommon["GetHeroAgi"]
--- 英雄智力 [R] | 参数: whichHero(unit), includeBonuses(boolean) | 返回: integer
cj.GetHeroInt = JassCommon["GetHeroInt"]
--- 英雄等级 | 参数: whichHero(unit) | 返回: integer
cj.GetHeroLevel = JassCommon["GetHeroLevel"]
--- 英雄称谓 | 参数: whichHero(unit) | 返回: string
cj.GetHeroProperName = JassCommon["GetHeroProperName"]
--- 未分配技能点数 | 参数: whichHero(unit) | 返回: integer
cj.GetHeroSkillPoints = JassCommon["GetHeroSkillPoints"]
--- 英雄力量 [R] | 参数: whichHero(unit), includeBonuses(boolean) | 返回: integer
cj.GetHeroStr = JassCommon["GetHeroStr"]
--- 英雄经验值 | 参数: whichHero(unit) | 返回: integer
cj.GetHeroXP = JassCommon["GetHeroXP"]
--- 获取整数游戏状态值 | 参数: whichIntegerGameState(igamestate) | 返回: integer
cj.GetIntegerGameState = JassCommon["GetIntegerGameState"]
--- 发布的命令ID | 返回: integer
cj.GetIssuedOrderId = JassCommon["GetIssuedOrderId"]
--- 使用次数 | 参数: whichItem(item) | 返回: integer
cj.GetItemCharges = JassCommon["GetItemCharges"]
--- 物品等级 | 参数: whichItem(item) | 返回: integer
cj.GetItemLevel = JassCommon["GetItemLevel"]
--- 物品名字 | 参数: whichItem(item) | 返回: string
cj.GetItemName = JassCommon["GetItemName"]
--- 物品所属玩家 | 参数: whichItem(item) | 返回: player
cj.GetItemPlayer = JassCommon["GetItemPlayer"]
--- 指定物品的分类 | 参数: whichItem(item) | 返回: itemtype
cj.GetItemType = JassCommon["GetItemType"]
--- 物品类型ID [C] | 参数: i(item) | 返回: integer
cj.GetItemTypeId = JassCommon["GetItemTypeId"]
--- 物品自定义值 | 参数: whichItem(item) | 返回: integer
cj.GetItemUserData = JassCommon["GetItemUserData"]
--- 物品的X轴坐标 [R] | 参数: i(item) | 返回: real
cj.GetItemX = JassCommon["GetItemX"]
--- 物品的Y轴坐标 [R] | 参数: i(item) | 返回: real
cj.GetItemY = JassCommon["GetItemY"]
--- 凶手单位 | 返回: unit
cj.GetKillingUnit = JassCommon["GetKillingUnit"]
--- 学习技能 [R] | 返回: integer
cj.GetLearnedSkill = JassCommon["GetLearnedSkill"]
--- 学习技能等级 | 返回: integer
cj.GetLearnedSkillLevel = JassCommon["GetLearnedSkillLevel"]
--- 学习技能的英雄 | 返回: unit
cj.GetLearningUnit = JassCommon["GetLearningUnit"]
--- 离开的单位 | 返回: unit
cj.GetLeavingUnit = JassCommon["GetLeavingUnit"]
--- 升级的英雄 | 返回: unit
cj.GetLevelingUnit = JassCommon["GetLevelingUnit"]
--- Alpha通道值 | 参数: whichBolt(lightning) | 返回: real
cj.GetLightningColorA = JassCommon["GetLightningColorA"]
--- 蓝颜色值 | 参数: whichBolt(lightning) | 返回: real
cj.GetLightningColorB = JassCommon["GetLightningColorB"]
--- 绿颜色值 | 参数: whichBolt(lightning) | 返回: real
cj.GetLightningColorG = JassCommon["GetLightningColorG"]
--- 红颜色值 | 参数: whichBolt(lightning) | 返回: real
cj.GetLightningColorR = JassCommon["GetLightningColorR"]
--- 被装载单位 | 返回: unit
cj.GetLoadedUnit = JassCommon["GetLoadedUnit"]
--- 自定义代码 [C] | 返回: player
cj.GetLocalPlayer = JassCommon["GetLocalPlayer"]
--- 本地热键  | 参数: source(string) | 返回: integer
cj.GetLocalizedHotkey = JassCommon["GetLocalizedHotkey"]
--- 本地字符串 [R] | 参数: source(string) | 返回: string
cj.GetLocalizedString = JassCommon["GetLocalizedString"]
--- 点的X轴坐标 | 参数: whichLocation(location) | 返回: real
cj.GetLocationX = JassCommon["GetLocationX"]
--- 点的Y轴坐标 | 参数: whichLocation(location) | 返回: real
cj.GetLocationY = JassCommon["GetLocationY"]
--- 点的Z轴高度 [R] | 参数: whichLocation(location) | 返回: real
cj.GetLocationZ = JassCommon["GetLocationZ"]
--- 被操作物品 | 返回: item
cj.GetManipulatedItem = JassCommon["GetManipulatedItem"]
--- 操作物品的单位 | 返回: unit
cj.GetManipulatingUnit = JassCommon["GetManipulatingUnit"]
--- 物体名称 [C] | 参数: objectId(integer) | 返回: string
cj.GetObjectName = JassCommon["GetObjectName"]
--- 命令发布点 | 返回: location
cj.GetOrderPointLoc = JassCommon["GetOrderPointLoc"]
--- 命令发布点X坐标 [R] | 返回: real
cj.GetOrderPointX = JassCommon["GetOrderPointX"]
--- 命令发布点Y坐标 [R] | 返回: real
cj.GetOrderPointY = JassCommon["GetOrderPointY"]
--- 获取命令目标 | 返回: widget
cj.GetOrderTarget = JassCommon["GetOrderTarget"]
--- 命令发布目标(可破坏物) | 返回: destructable
cj.GetOrderTargetDestructable = JassCommon["GetOrderTargetDestructable"]
--- 命令发布目标 | 返回: item
cj.GetOrderTargetItem = JassCommon["GetOrderTargetItem"]
--- 命令发布目标 | 返回: unit
cj.GetOrderTargetUnit = JassCommon["GetOrderTargetUnit"]
--- 发布命令的单位 | 返回: unit
cj.GetOrderedUnit = JassCommon["GetOrderedUnit"]
--- 单位所有者 | 参数: whichUnit(unit) | 返回: player
cj.GetOwningPlayer = JassCommon["GetOwningPlayer"]
--- 联盟状态设置 | 参数: sourcePlayer(player), otherPlayer(player), whichAllianceSetting(alliancetype) | 返回: boolean
cj.GetPlayerAlliance = JassCommon["GetPlayerAlliance"]
--- 玩家颜色 | 参数: whichPlayer(player) | 返回: playercolor
cj.GetPlayerColor = JassCommon["GetPlayerColor"]
--- 玩家控制者 | 参数: whichPlayer(player) | 返回: mapcontrol
cj.GetPlayerController = JassCommon["GetPlayerController"]
--- 获取玩家属性加成 | 参数: whichPlayer(player) | 返回: real
cj.GetPlayerHandicap = JassCommon["GetPlayerHandicap"]
--- 获取玩家经验加成 | 参数: whichPlayer(player) | 返回: real
cj.GetPlayerHandicapXP = JassCommon["GetPlayerHandicapXP"]
--- 玩家ID - 1 [R] | 参数: whichPlayer(player) | 返回: integer
cj.GetPlayerId = JassCommon["GetPlayerId"]
--- 玩家名字 | 参数: whichPlayer(player) | 返回: string
cj.GetPlayerName = JassCommon["GetPlayerName"]
--- 玩家的种族 | 参数: whichPlayer(player) | 返回: race
cj.GetPlayerRace = JassCommon["GetPlayerRace"]
--- 玩家得分 | 参数: whichPlayer(player), whichPlayerScore(playerscore) | 返回: integer
cj.GetPlayerScore = JassCommon["GetPlayerScore"]
--- 玩家是否可选 | 参数: whichPlayer(player) | 返回: boolean
cj.GetPlayerSelectable = JassCommon["GetPlayerSelectable"]
--- 玩家游戏状态 | 参数: whichPlayer(player) | 返回: playerslotstate
cj.GetPlayerSlotState = JassCommon["GetPlayerSlotState"]
--- 获取玩家起始位置索引 | 参数: whichPlayer(player) | 返回: integer
cj.GetPlayerStartLocation = JassCommon["GetPlayerStartLocation"]
--- 玩家属性 | 参数: whichPlayer(player), whichPlayerState(playerstate) | 返回: integer
cj.GetPlayerState = JassCommon["GetPlayerState"]
--- 建筑数量 | 参数: whichPlayer(player), includeIncomplete(boolean) | 返回: integer
cj.GetPlayerStructureCount = JassCommon["GetPlayerStructureCount"]
--- 玩家税率 [R] | 参数: sourcePlayer(player), otherPlayer(player), whichResource(playerstate) | 返回: integer
cj.GetPlayerTaxRate = JassCommon["GetPlayerTaxRate"]
--- 玩家队伍 | 参数: whichPlayer(player) | 返回: integer
cj.GetPlayerTeam = JassCommon["GetPlayerTeam"]
--- 获取玩家科技计数 | 参数: whichPlayer(player), techid(integer), specificonly(boolean) | 返回: integer
cj.GetPlayerTechCount = JassCommon["GetPlayerTechCount"]
--- 获取玩家科技最大等级 | 参数: whichPlayer(player), techid(integer) | 返回: integer
cj.GetPlayerTechMaxAllowed = JassCommon["GetPlayerTechMaxAllowed"]
--- 获取玩家科技研究等级 | 参数: whichPlayer(player), techid(integer), specificonly(boolean) | 返回: boolean
cj.GetPlayerTechResearched = JassCommon["GetPlayerTechResearched"]
--- 获取玩家指定类型单位数量 | 参数: whichPlayer(player), unitName(string), includeIncomplete(boolean), includeUpgrades(boolean) | 返回: integer
cj.GetPlayerTypedUnitCount = JassCommon["GetPlayerTypedUnitCount"]
--- 非建筑单位数量 | 参数: whichPlayer(player), includeIncomplete(boolean) | 返回: integer
cj.GetPlayerUnitCount = JassCommon["GetPlayerUnitCount"]
--- 玩家数量 | 返回: integer
cj.GetPlayers = JassCommon["GetPlayers"]
--- 随机整数 | 参数: lowBound(integer), highBound(integer) | 返回: integer
cj.GetRandomInt = JassCommon["GetRandomInt"]
--- 随机实数 | 参数: lowBound(real), highBound(real) | 返回: real
cj.GetRandomReal = JassCommon["GetRandomReal"]
--- 中心X坐标 | 参数: whichRect(rect) | 返回: real
cj.GetRectCenterX = JassCommon["GetRectCenterX"]
--- 中心Y坐标 | 参数: whichRect(rect) | 返回: real
cj.GetRectCenterY = JassCommon["GetRectCenterY"]
--- 右上角X坐标 | 参数: whichRect(rect) | 返回: real
cj.GetRectMaxX = JassCommon["GetRectMaxX"]
--- 右上角Y坐标 | 参数: whichRect(rect) | 返回: real
cj.GetRectMaxY = JassCommon["GetRectMaxY"]
--- 左下角X坐标 | 参数: whichRect(rect) | 返回: real
cj.GetRectMinX = JassCommon["GetRectMinX"]
--- 左下角Y坐标 | 参数: whichRect(rect) | 返回: real
cj.GetRectMinY = JassCommon["GetRectMinY"]
--- 获取救援玩家 返回: unit
cj.GetRescuer = JassCommon["GetRescuer"]
--- 被研究科技 | 返回: integer
cj.GetResearched = JassCommon["GetResearched"]
--- 研究科技的单位 | 返回: unit
cj.GetResearchingUnit = JassCommon["GetResearchingUnit"]
--- 储金量 | 参数: whichUnit(unit) | 返回: integer
cj.GetResourceAmount = JassCommon["GetResourceAmount"]
--- 获取资源密度 返回: mapdensity
cj.GetResourceDensity = JassCommon["GetResourceDensity"]
--- 可复活英雄 | 返回: unit
cj.GetRevivableUnit = JassCommon["GetRevivableUnit"]
--- 复活英雄 | 返回: unit
cj.GetRevivingUnit = JassCommon["GetRevivingUnit"]
--- 存档文件名 | 返回: string
cj.GetSaveBasicFilename = JassCommon["GetSaveBasicFilename"]
--- 贩卖者 | 返回: unit
cj.GetSellingUnit = JassCommon["GetSellingUnit"]
--- 被售出物品 | 返回: item
cj.GetSoldItem = JassCommon["GetSoldItem"]
--- 被贩卖单位 | 返回: unit
cj.GetSoldUnit = JassCommon["GetSoldUnit"]
--- 获取声音时长 | 参数: soundHandle(sound) | 返回: integer
cj.GetSoundDuration = JassCommon["GetSoundDuration"]
--- 获取音频文件时长 | 参数: musicFileName(string) | 返回: integer
cj.GetSoundFileDuration = JassCommon["GetSoundFileDuration"]
--- 声音在加载 [new] | 参数: soundHandle(sound) | 返回: boolean
cj.GetSoundIsLoading = JassCommon["GetSoundIsLoading"]
--- 声音在播放 [new] | 参数: soundHandle(sound) | 返回: boolean
cj.GetSoundIsPlaying = JassCommon["GetSoundIsPlaying"]
--- 获取施法技能 返回: ability
cj.GetSpellAbility = JassCommon["GetSpellAbility"]
--- 施放技能 | 返回: integer
cj.GetSpellAbilityId = JassCommon["GetSpellAbilityId"]
--- 施法单位 | 返回: unit
cj.GetSpellAbilityUnit = JassCommon["GetSpellAbilityUnit"]
--- 技能施放目标(可破坏物) | 返回: destructable
cj.GetSpellTargetDestructable = JassCommon["GetSpellTargetDestructable"]
--- 技能施放目标 | 返回: item
cj.GetSpellTargetItem = JassCommon["GetSpellTargetItem"]
--- 技能施放点 | 返回: location
cj.GetSpellTargetLoc = JassCommon["GetSpellTargetLoc"]
--- 技能施放目标 | 返回: unit
cj.GetSpellTargetUnit = JassCommon["GetSpellTargetUnit"]
--- 技能施放点X坐标 | 返回: real
cj.GetSpellTargetX = JassCommon["GetSpellTargetX"]
--- 技能施放点Y坐标 | 返回: real
cj.GetSpellTargetY = JassCommon["GetSpellTargetY"]
--- 获取起始位置优先级 | 参数: whichStartLoc(integer), prioSlotIndex(integer) | 返回: startlocprio
cj.GetStartLocPrio = JassCommon["GetStartLocPrio"]
--- 获取起始位置优先级槽位 | 参数: whichStartLoc(integer), prioSlotIndex(integer) | 返回: integer
cj.GetStartLocPrioSlot = JassCommon["GetStartLocPrioSlot"]
--- 获取起始位置(点) | 参数: whichStartLocation(integer) | 返回: location
cj.GetStartLocationLoc = JassCommon["GetStartLocationLoc"]
--- 获取起始位置X坐标 | 参数: whichStartLocation(integer) | 返回: real
cj.GetStartLocationX = JassCommon["GetStartLocationX"]
--- 获取起始位置Y坐标 | 参数: whichStartLocation(integer) | 返回: real
cj.GetStartLocationY = JassCommon["GetStartLocationY"]
--- 读取布尔值[R] | 参数: cache(gamecache), missionKey(string), key(string) | 返回: boolean
cj.GetStoredBoolean = JassCommon["GetStoredBoolean"]
--- 缓存读取整数 [C] | 参数: cache(gamecache), missionKey(string), key(string) | 返回: integer
cj.GetStoredInteger = JassCommon["GetStoredInteger"]
--- 缓存读取实数 [C] | 参数: cache(gamecache), missionKey(string), key(string) | 返回: real
cj.GetStoredReal = JassCommon["GetStoredReal"]
--- 读取字符串 [C] | 参数: cache(gamecache), missionKey(string), key(string) | 返回: string
cj.GetStoredString = JassCommon["GetStoredString"]
--- 召唤单位 | 返回: unit
cj.GetSummonedUnit = JassCommon["GetSummonedUnit"]
--- 召唤者 | 返回: unit
cj.GetSummoningUnit = JassCommon["GetSummoningUnit"]
--- 队伍数量 | 返回: integer
cj.GetTeams = JassCommon["GetTeams"]
--- 地形悬崖高度(指定坐标) [R] | 参数: x(real), y(real) | 返回: integer
cj.GetTerrainCliffLevel = JassCommon["GetTerrainCliffLevel"]
--- 指定坐标地形 [R] | 参数: x(real), y(real) | 返回: integer
cj.GetTerrainType = JassCommon["GetTerrainType"]
--- 地形样式(指定坐标) [R] | 参数: x(real), y(real) | 返回: integer
cj.GetTerrainVariance = JassCommon["GetTerrainVariance"]
--- 获取时间流逝速度 返回: real
cj.GetTimeOfDayScale = JassCommon["GetTimeOfDayScale"]
--- 获取锦标赛立即结束玩家 返回: player
cj.GetTournamentFinishNowPlayer = JassCommon["GetTournamentFinishNowPlayer"]
--- 比赛结束规则 | 返回: integer
cj.GetTournamentFinishNowRule = JassCommon["GetTournamentFinishNowRule"]
--- 比赛剩余时间 | 返回: real
cj.GetTournamentFinishSoonTimeRemaining = JassCommon["GetTournamentFinishSoonTimeRemaining"]
--- 对战比赛得分 | 参数: whichPlayer(player) | 返回: integer
cj.GetTournamentScore = JassCommon["GetTournamentScore"]
--- 训练单位 | 返回: unit
cj.GetTrainedUnit = JassCommon["GetTrainedUnit"]
--- 训练单位类型 | 返回: integer
cj.GetTrainedUnitType = JassCommon["GetTrainedUnitType"]
--- 运输单位 | 返回: unit
cj.GetTransportUnit = JassCommon["GetTransportUnit"]
--- 获取触发可破坏物 返回: destructable
cj.GetTriggerDestructable = JassCommon["GetTriggerDestructable"]
--- 触发条件判断次数 | 参数: whichTrigger(trigger) | 返回: integer
cj.GetTriggerEvalCount = JassCommon["GetTriggerEvalCount"]
--- 获取触发事件ID 返回: eventid
cj.GetTriggerEventId = JassCommon["GetTriggerEventId"]
--- 触发动作运行次数 | 参数: whichTrigger(trigger) | 返回: integer
cj.GetTriggerExecCount = JassCommon["GetTriggerExecCount"]
--- 触发玩家 | 返回: player
cj.GetTriggerPlayer = JassCommon["GetTriggerPlayer"]
--- 触发单位 | 返回: unit
cj.GetTriggerUnit = JassCommon["GetTriggerUnit"]
--- 获取触发控件 返回: widget
cj.GetTriggerWidget = JassCommon["GetTriggerWidget"]
--- 触发区域 [R] | 返回: region
cj.GetTriggeringRegion = JassCommon["GetTriggeringRegion"]
--- 事件响应 - 触发可追踪物 [R] | 返回: trackable
cj.GetTriggeringTrackable = JassCommon["GetTriggeringTrackable"]
--- 当前触发 | 返回: trigger
cj.GetTriggeringTrigger = JassCommon["GetTriggeringTrigger"]
--- 单位技能等级 [R] | 参数: whichUnit(unit), abilcode(integer) | 返回: integer
cj.GetUnitAbilityLevel = JassCommon["GetUnitAbilityLevel"]
--- 当前主动攻击范围 | 参数: whichUnit(unit) | 返回: real
cj.GetUnitAcquireRange = JassCommon["GetUnitAcquireRange"]
--- 当前命令ID | 参数: whichUnit(unit) | 返回: integer
cj.GetUnitCurrentOrder = JassCommon["GetUnitCurrentOrder"]
--- 默认主动攻击范围 | 参数: whichUnit(unit) | 返回: real
cj.GetUnitDefaultAcquireRange = JassCommon["GetUnitDefaultAcquireRange"]
--- 默认飞行高度 | 参数: whichUnit(unit) | 返回: real
cj.GetUnitDefaultFlyHeight = JassCommon["GetUnitDefaultFlyHeight"]
--- 默认移动速度 | 参数: whichUnit(unit) | 返回: real
cj.GetUnitDefaultMoveSpeed = JassCommon["GetUnitDefaultMoveSpeed"]
--- 默认转向角度 | 参数: whichUnit(unit) | 返回: real
cj.GetUnitDefaultPropWindow = JassCommon["GetUnitDefaultPropWindow"]
--- 默认转身速度 | 参数: whichUnit(unit) | 返回: real
cj.GetUnitDefaultTurnSpeed = JassCommon["GetUnitDefaultTurnSpeed"]
--- 面向角度 | 参数: whichUnit(unit) | 返回: real
cj.GetUnitFacing = JassCommon["GetUnitFacing"]
--- 当前飞行高度 | 参数: whichUnit(unit) | 返回: real
cj.GetUnitFlyHeight = JassCommon["GetUnitFlyHeight"]
--- 单位提供人口数量 | 参数: whichUnit(unit) | 返回: integer
cj.GetUnitFoodMade = JassCommon["GetUnitFoodMade"]
--- 单位使用人口数量 | 参数: whichUnit(unit) | 返回: integer
cj.GetUnitFoodUsed = JassCommon["GetUnitFoodUsed"]
--- 单位等级 | 参数: whichUnit(unit) | 返回: integer
cj.GetUnitLevel = JassCommon["GetUnitLevel"]
--- 单位位置 | 参数: whichUnit(unit) | 返回: location
cj.GetUnitLoc = JassCommon["GetUnitLoc"]
--- 当前移动速度 | 参数: whichUnit(unit) | 返回: real
cj.GetUnitMoveSpeed = JassCommon["GetUnitMoveSpeed"]
--- 单位名字 | 参数: whichUnit(unit) | 返回: string
cj.GetUnitName = JassCommon["GetUnitName"]
--- 单位附加值 | 参数: whichUnit(unit) | 返回: integer
cj.GetUnitPointValue = JassCommon["GetUnitPointValue"]
--- 单位附加值(指定单位类型) | 参数: unitType(integer) | 返回: integer
cj.GetUnitPointValueByType = JassCommon["GetUnitPointValueByType"]
--- 当前转向角度(弧度制) [R] | 参数: whichUnit(unit) | 返回: real
cj.GetUnitPropWindow = JassCommon["GetUnitPropWindow"]
--- 单位种族 | 参数: whichUnit(unit) | 返回: race
cj.GetUnitRace = JassCommon["GetUnitRace"]
--- 创建单位(面向角度) [C] | 参数: whichUnit(unit) | 返回: destructable
cj.GetUnitRallyDestructable = JassCommon["GetUnitRallyDestructable"]
--- 单位集结点 | 参数: whichUnit(unit) | 返回: location
cj.GetUnitRallyPoint = JassCommon["GetUnitRallyPoint"]
--- 单位集结点目标 | 参数: whichUnit(unit) | 返回: unit
cj.GetUnitRallyUnit = JassCommon["GetUnitRallyUnit"]
--- 属性 [R] | 参数: whichUnit(unit), whichUnitState(unitstate) | 返回: real
cj.GetUnitState = JassJapi["GetUnitState"]
--- 当前转身速度 | 参数: whichUnit(unit) | 返回: real
cj.GetUnitTurnSpeed = JassCommon["GetUnitTurnSpeed"]
--- 自定义代码 [C] | 参数: whichUnit(unit) | 返回: integer
cj.GetUnitTypeId = JassCommon["GetUnitTypeId"]
--- 单位自定义值 | 参数: whichUnit(unit) | 返回: integer
cj.GetUnitUserData = JassCommon["GetUnitUserData"]
--- 单位所在X轴坐标 [R] | 参数: whichUnit(unit) | 返回: real
cj.GetUnitX = JassCommon["GetUnitX"]
--- 单位所在Y轴坐标 [R] | 参数: whichUnit(unit) | 返回: real
cj.GetUnitY = JassCommon["GetUnitY"]
--- 获取控件生命值 | 参数: whichWidget(widget) | 返回: real
cj.GetWidgetLife = JassCommon["GetWidgetLife"]
--- 获取控件X坐标 | 参数: whichWidget(widget) | 返回: real
cj.GetWidgetX = JassCommon["GetWidgetX"]
--- 获取控件Y坐标 | 参数: whichWidget(widget) | 返回: real
cj.GetWidgetY = JassCommon["GetWidgetY"]
--- 获取获胜玩家 返回: player
cj.GetWinningPlayer = JassCommon["GetWinningPlayer"]
--- 完整地图区域 | 返回: rect
cj.GetWorldBounds = JassCommon["GetWorldBounds"]
--- 添加单位 [R] | 参数: whichGroup(group), whichUnit(unit)
cj.GroupAddUnit = JassCommon["GroupAddUnit"]
--- 清空单位组 | 参数: whichGroup(group)
cj.GroupClear = JassCommon["GroupClear"]
--- 选取单位添加到单位组(坐标) | 参数: whichGroup(group), x(real), y(real), radius(real), filter(boolexpr)
cj.GroupEnumUnitsInRange = JassCommon["GroupEnumUnitsInRange"]
--- 选取单位添加到单位组(坐标)(不建议使用) | 参数: whichGroup(group), x(real), y(real), radius(real), filter(boolexpr), countLimit(integer)
cj.GroupEnumUnitsInRangeCounted = JassCommon["GroupEnumUnitsInRangeCounted"]
--- 选取单位添加到单位组(点) | 参数: whichGroup(group), whichLocation(location), radius(real), filter(boolexpr)
cj.GroupEnumUnitsInRangeOfLoc = JassCommon["GroupEnumUnitsInRangeOfLoc"]
--- 选取单位添加到单位组(点)(不建议使用) | 参数: whichGroup(group), whichLocation(location), radius(real), filter(boolexpr), countLimit(integer)
cj.GroupEnumUnitsInRangeOfLocCounted = JassCommon["GroupEnumUnitsInRangeOfLocCounted"]
--- 选取矩形区域内的单位加入单位组 | 参数: whichGroup(group), r(rect), filter(boolexpr)
cj.GroupEnumUnitsInRect = JassCommon["GroupEnumUnitsInRect"]
--- 选取矩形区域内指定数量的单位 | 参数: whichGroup(group), r(rect), filter(boolexpr), countLimit(integer)
cj.GroupEnumUnitsInRectCounted = JassCommon["GroupEnumUnitsInRectCounted"]
--- 选取属于某玩家的单位加入单位组 | 参数: whichGroup(group), whichPlayer(player), filter(boolexpr)
cj.GroupEnumUnitsOfPlayer = JassCommon["GroupEnumUnitsOfPlayer"]
--- 选取指定类型的单位加入单位组 | 参数: whichGroup(group), unitname(string), filter(boolexpr)
cj.GroupEnumUnitsOfType = JassCommon["GroupEnumUnitsOfType"]
--- 选取指定类型指定数量的单位 | 参数: whichGroup(group), unitname(string), filter(boolexpr), countLimit(integer)
cj.GroupEnumUnitsOfTypeCounted = JassCommon["GroupEnumUnitsOfTypeCounted"]
--- 选取玩家选中单位加入单位组 | 参数: whichGroup(group), whichPlayer(player), filter(boolexpr)
cj.GroupEnumUnitsSelected = JassCommon["GroupEnumUnitsSelected"]
--- 发布命令(无目标) | 参数: whichGroup(group), order(string) | 返回: boolean
cj.GroupImmediateOrder = JassCommon["GroupImmediateOrder"]
--- 发布命令(无目标)(ID) | 参数: whichGroup(group), order(integer) | 返回: boolean
cj.GroupImmediateOrderById = JassCommon["GroupImmediateOrderById"]
--- 发布命令(指定坐标) [R] | 参数: whichGroup(group), order(string), x(real), y(real) | 返回: boolean
cj.GroupPointOrder = JassCommon["GroupPointOrder"]
--- 发布命令(指定坐标)(ID) | 参数: whichGroup(group), order(integer), x(real), y(real) | 返回: boolean
cj.GroupPointOrderById = JassCommon["GroupPointOrderById"]
--- 发布命令(指定点)(ID) | 参数: whichGroup(group), order(integer), whichLocation(location) | 返回: boolean
cj.GroupPointOrderByIdLoc = JassCommon["GroupPointOrderByIdLoc"]
--- 发布命令(指定点) | 参数: whichGroup(group), order(string), whichLocation(location) | 返回: boolean
cj.GroupPointOrderLoc = JassCommon["GroupPointOrderLoc"]
--- 移除单位 [R] | 参数: whichGroup(group), whichUnit(unit)
cj.GroupRemoveUnit = JassCommon["GroupRemoveUnit"]
--- 发布命令(指定单位) | 参数: whichGroup(group), order(string), targetWidget(widget) | 返回: boolean
cj.GroupTargetOrder = JassCommon["GroupTargetOrder"]
--- 发布命令(指定单位)(ID) | 参数: whichGroup(group), order(integer), targetWidget(widget) | 返回: boolean
cj.GroupTargetOrderById = JassCommon["GroupTargetOrderById"]
--- <1.24> 哈希项存有布尔值 <new> | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: boolean
cj.HaveSavedBoolean = JassCommon["HaveSavedBoolean"]
--- <1.24> 哈希项存有句柄 <new> | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: boolean
cj.HaveSavedHandle = JassCommon["HaveSavedHandle"]
--- <1.24> 哈希项存有整数值 <new> | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: boolean
cj.HaveSavedInteger = JassCommon["HaveSavedInteger"]
--- <1.24> 哈希项存有实数值 <new> | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: boolean
cj.HaveSavedReal = JassCommon["HaveSavedReal"]
--- <1.24> 哈希项存有字符串 <new> | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: boolean
cj.HaveSavedString = JassCommon["HaveSavedString"]
--- 游戏缓存中是否存在布尔值 | 参数: cache(gamecache), missionKey(string), key(string) | 返回: boolean
cj.HaveStoredBoolean = JassCommon["HaveStoredBoolean"]
--- 游戏缓存中是否存在整数 | 参数: cache(gamecache), missionKey(string), key(string) | 返回: boolean
cj.HaveStoredInteger = JassCommon["HaveStoredInteger"]
--- 游戏缓存中是否存在实数 | 参数: cache(gamecache), missionKey(string), key(string) | 返回: boolean
cj.HaveStoredReal = JassCommon["HaveStoredReal"]
--- 游戏缓存中是否存在字符串 | 参数: cache(gamecache), missionKey(string), key(string) | 返回: boolean
cj.HaveStoredString = JassCommon["HaveStoredString"]
--- 游戏缓存中是否存在单位 | 参数: cache(gamecache), missionKey(string), key(string) | 返回: boolean
cj.HaveStoredUnit = JassCommon["HaveStoredUnit"]
--- 转换整数为实数 | 参数: i(integer) | 返回: real
cj.I2R = JassCommon["I2R"]
--- 转换整数为字符串 | 参数: i(integer) | 返回: string
cj.I2S = JassCommon["I2S"]
--- 提升技能等级 [R] | 参数: whichUnit(unit), abilcode(integer) | 返回: integer
cj.IncUnitAbilityLevel = JassCommon["IncUnitAbilityLevel"]
--- 新建游戏缓存 [R] | 参数: campaignFile(string) | 返回: gamecache
cj.InitGameCache = JassCommon["InitGameCache"]
--- <1.24> 新建哈希表 [C] | 返回: hashtable
cj.InitHashtable = JassCommon["InitHashtable"]
--- 滤镜是否显示 返回: boolean
cj.IsCineFilterDisplayed = JassCommon["IsCineFilterDisplayed"]
--- 物件无敌 | 参数: d(destructable) | 返回: boolean
cj.IsDestructableInvulnerable = JassCommon["IsDestructableInvulnerable"]
--- 战争迷雾开启 | 返回: boolean
cj.IsFogEnabled = JassCommon["IsFogEnabled"]
--- 黑色阴影开启 | 返回: boolean
cj.IsFogMaskEnabled = JassCommon["IsFogMaskEnabled"]
--- 坐标在迷雾中 | 参数: x(real), y(real), whichPlayer(player) | 返回: boolean
cj.IsFoggedToPlayer = JassCommon["IsFoggedToPlayer"]
--- 游戏类型是否支持 | 参数: whichGameType(gametype) | 返回: boolean
cj.IsGameTypeSupported = JassCommon["IsGameTypeSupported"]
--- 单位类型是英雄单位 | 参数: unitId(integer) | 返回: boolean
cj.IsHeroUnitId = JassCommon["IsHeroUnitId"]
--- 物品类型是否可抵押 | 参数: itemId(integer) | 返回: boolean
cj.IsItemIdPawnable = JassCommon["IsItemIdPawnable"]
--- 物品类型是否是加强能力 | 参数: itemId(integer) | 返回: boolean
cj.IsItemIdPowerup = JassCommon["IsItemIdPowerup"]
--- 物品类型是否可出售 | 参数: itemId(integer) | 返回: boolean
cj.IsItemIdSellable = JassCommon["IsItemIdSellable"]
--- 物品无敌 | 参数: whichItem(item) | 返回: boolean
cj.IsItemInvulnerable = JassCommon["IsItemInvulnerable"]
--- 物品被持有 | 参数: whichItem(item) | 返回: boolean
cj.IsItemOwned = JassCommon["IsItemOwned"]
--- 物品可被抵押 [R] | 参数: whichItem(item) | 返回: boolean
cj.IsItemPawnable = JassCommon["IsItemPawnable"]
--- 物品是拾取时自动使用的 [R] | 参数: whichItem(item) | 返回: boolean
cj.IsItemPowerup = JassCommon["IsItemPowerup"]
--- 物品可被市场随机出售 [R] | 参数: whichItem(item) | 返回: boolean
cj.IsItemSellable = JassCommon["IsItemSellable"]
--- 物品可见 [R] | 参数: whichItem(item) | 返回: boolean
cj.IsItemVisible = JassCommon["IsItemVisible"]
--- 排行榜是否显示 | 参数: lb(leaderboard) | 返回: boolean
cj.IsLeaderboardDisplayed = JassCommon["IsLeaderboardDisplayed"]
--- 点在迷雾中 | 参数: whichLocation(location), whichPlayer(player) | 返回: boolean
cj.IsLocationFoggedToPlayer = JassCommon["IsLocationFoggedToPlayer"]
--- 包含点 | 参数: whichRegion(region), whichLocation(location) | 返回: boolean
cj.IsLocationInRegion = JassCommon["IsLocationInRegion"]
--- 点在黑色阴影中 | 参数: whichLocation(location), whichPlayer(player) | 返回: boolean
cj.IsLocationMaskedToPlayer = JassCommon["IsLocationMaskedToPlayer"]
--- 点可见 | 参数: whichLocation(location), whichPlayer(player) | 返回: boolean
cj.IsLocationVisibleToPlayer = JassCommon["IsLocationVisibleToPlayer"]
--- 地图参数设置 | 参数: whichMapFlag(mapflag) | 返回: boolean
cj.IsMapFlagSet = JassCommon["IsMapFlagSet"]
--- 坐标在黑色阴影中 | 参数: x(real), y(real), whichPlayer(player) | 返回: boolean
cj.IsMaskedToPlayer = JassCommon["IsMaskedToPlayer"]
--- 多面板显示 | 参数: lb(multiboard) | 返回: boolean
cj.IsMultiboardDisplayed = JassCommon["IsMultiboardDisplayed"]
--- 多面板最小化 | 参数: lb(multiboard) | 返回: boolean
cj.IsMultiboardMinimized = JassCommon["IsMultiboardMinimized"]
--- 无法失败 [R] | 返回: boolean
cj.IsNoDefeatCheat = JassCommon["IsNoDefeatCheat"]
--- 无法胜利 [R] | 返回: boolean
cj.IsNoVictoryCheat = JassCommon["IsNoVictoryCheat"]
--- 是玩家的盟友 | 参数: whichPlayer(player), otherPlayer(player) | 返回: boolean
cj.IsPlayerAlly = JassCommon["IsPlayerAlly"]
--- 是玩家的敌人 | 参数: whichPlayer(player), otherPlayer(player) | 返回: boolean
cj.IsPlayerEnemy = JassCommon["IsPlayerEnemy"]
--- 在玩家组 | 参数: whichPlayer(player), whichForce(force) | 返回: boolean
cj.IsPlayerInForce = JassCommon["IsPlayerInForce"]
--- 玩家是裁判或观察者 [R] | 参数: whichPlayer(player) | 返回: boolean
cj.IsPlayerObserver = JassCommon["IsPlayerObserver"]
--- 玩家的种族选择 | 参数: whichPlayer(player), pref(racepreference) | 返回: boolean
cj.IsPlayerRacePrefSet = JassCommon["IsPlayerRacePrefSet"]
--- 坐标点被荒芜地表覆盖 [R] | 参数: x(real), y(real) | 返回: boolean
cj.IsPointBlighted = JassCommon["IsPointBlighted"]
--- 包含坐标 | 参数: whichRegion(region), x(real), y(real) | 返回: boolean
cj.IsPointInRegion = JassCommon["IsPointInRegion"]
--- 任务完成 | 参数: whichQuest(quest) | 返回: boolean
cj.IsQuestCompleted = JassCommon["IsQuestCompleted"]
--- 任务被发现 | 参数: whichQuest(quest) | 返回: boolean
cj.IsQuestDiscovered = JassCommon["IsQuestDiscovered"]
--- 任务激活 | 参数: whichQuest(quest) | 返回: boolean
cj.IsQuestEnabled = JassCommon["IsQuestEnabled"]
--- 任务失败 | 参数: whichQuest(quest) | 返回: boolean
cj.IsQuestFailed = JassCommon["IsQuestFailed"]
--- 任务项目完成 | 参数: whichQuestItem(questitem) | 返回: boolean
cj.IsQuestItemCompleted = JassCommon["IsQuestItemCompleted"]
--- 是主要任务 | 参数: whichQuest(quest) | 返回: boolean
cj.IsQuestRequired = JassCommon["IsQuestRequired"]
--- 经验不可获得 | 参数: whichHero(unit) | 返回: boolean
cj.IsSuspendedXP = JassCommon["IsSuspendedXP"]
--- 地形通行状态关闭(指定坐标) [R] | 参数: x(real), y(real), t(pathingtype) | 返回: boolean
cj.IsTerrainPathable = JassCommon["IsTerrainPathable"]
--- 计时器窗口是否显示 | 参数: whichDialog(timerdialog) | 返回: boolean
cj.IsTimerDialogDisplayed = JassCommon["IsTimerDialogDisplayed"]
--- 触发开启 | 参数: whichTrigger(trigger) | 返回: boolean
cj.IsTriggerEnabled = JassCommon["IsTriggerEnabled"]
--- 触发器是否等待睡眠模式 | 参数: whichTrigger(trigger) | 返回: boolean
cj.IsTriggerWaitOnSleeps = JassCommon["IsTriggerWaitOnSleeps"]
--- 单位检查 | 参数: whichUnit(unit), whichSpecifiedUnit(unit) | 返回: boolean
cj.IsUnit = JassCommon["IsUnit"]
--- 是玩家的同盟单位 | 参数: whichUnit(unit), whichPlayer(player) | 返回: boolean
cj.IsUnitAlly = JassCommon["IsUnitAlly"]
--- 被检测到 | 参数: whichUnit(unit), whichPlayer(player) | 返回: boolean
cj.IsUnitDetected = JassCommon["IsUnitDetected"]
--- 是玩家的敌对单位 | 参数: whichUnit(unit), whichPlayer(player) | 返回: boolean
cj.IsUnitEnemy = JassCommon["IsUnitEnemy"]
--- 单位在迷雾中 | 参数: whichUnit(unit), whichPlayer(player) | 返回: boolean
cj.IsUnitFogged = JassCommon["IsUnitFogged"]
--- 单位隐藏 | 参数: whichUnit(unit) | 返回: boolean
cj.IsUnitHidden = JassCommon["IsUnitHidden"]
--- 单位类别检查(指定单位类型) | 参数: unitId(integer), whichUnitType(unittype) | 返回: boolean
cj.IsUnitIdType = JassCommon["IsUnitIdType"]
--- 单位是镜像 | 参数: whichUnit(unit) | 返回: boolean
cj.IsUnitIllusion = JassCommon["IsUnitIllusion"]
--- 是玩家组里玩家的单位 | 参数: whichUnit(unit), whichForce(force) | 返回: boolean
cj.IsUnitInForce = JassCommon["IsUnitInForce"]
--- 在单位组 | 参数: whichUnit(unit), whichGroup(group) | 返回: boolean
cj.IsUnitInGroup = JassCommon["IsUnitInGroup"]
--- 在指定单位范围内 [R] | 参数: whichUnit(unit), otherUnit(unit), distance(real) | 返回: boolean
cj.IsUnitInRange = JassCommon["IsUnitInRange"]
--- 在指定点范围内 [R] | 参数: whichUnit(unit), whichLocation(location), distance(real) | 返回: boolean
cj.IsUnitInRangeLoc = JassCommon["IsUnitInRangeLoc"]
--- 在指定坐标范围内 [R] | 参数: whichUnit(unit), x(real), y(real), distance(real) | 返回: boolean
cj.IsUnitInRangeXY = JassCommon["IsUnitInRangeXY"]
--- 在不规则区域内 [R] | 参数: whichRegion(region), whichUnit(unit) | 返回: boolean
cj.IsUnitInRegion = JassCommon["IsUnitInRegion"]
--- 被指定单位装载 | 参数: whichUnit(unit), whichTransport(unit) | 返回: boolean
cj.IsUnitInTransport = JassCommon["IsUnitInTransport"]
--- 单位不可见 | 参数: whichUnit(unit), whichPlayer(player) | 返回: boolean
cj.IsUnitInvisible = JassCommon["IsUnitInvisible"]
--- 被装载 | 参数: whichUnit(unit) | 返回: boolean
cj.IsUnitLoaded = JassCommon["IsUnitLoaded"]
--- 单位在黑色阴影中 | 参数: whichUnit(unit), whichPlayer(player) | 返回: boolean
cj.IsUnitMasked = JassCommon["IsUnitMasked"]
--- 是玩家的单位 | 参数: whichUnit(unit), whichPlayer(player) | 返回: boolean
cj.IsUnitOwnedByPlayer = JassCommon["IsUnitOwnedByPlayer"]
--- 单位暂停 | 参数: whichHero(unit) | 返回: boolean
cj.IsUnitPaused = JassCommon["IsUnitPaused"]
--- 单位种族检查 | 参数: whichUnit(unit), whichRace(race) | 返回: boolean
cj.IsUnitRace = JassCommon["IsUnitRace"]
--- 被玩家选择 | 参数: whichUnit(unit), whichPlayer(player) | 返回: boolean
cj.IsUnitSelected = JassCommon["IsUnitSelected"]
--- 单位类别检查 | 参数: whichUnit(unit), whichUnitType(unittype) | 返回: boolean
cj.IsUnitType = JassCommon["IsUnitType"]
--- 单位可见 | 参数: whichUnit(unit), whichPlayer(player) | 返回: boolean
cj.IsUnitVisible = JassCommon["IsUnitVisible"]
--- 坐标可见 | 参数: x(real), y(real), whichPlayer(player) | 返回: boolean
cj.IsVisibleToPlayer = JassCommon["IsVisibleToPlayer"]
--- 发布建造命令(字符串) | 参数: whichPeon(unit), unitToBuild(string), x(real), y(real) | 返回: boolean
cj.IssueBuildOrder = JassCommon["IssueBuildOrder"]
--- 发布建造命令(指定坐标) [R] | 参数: whichPeon(unit), unitId(integer), x(real), y(real) | 返回: boolean
cj.IssueBuildOrderById = JassCommon["IssueBuildOrderById"]
--- 发布命令(无目标) | 参数: whichUnit(unit), order(string) | 返回: boolean
cj.IssueImmediateOrder = JassCommon["IssueImmediateOrder"]
--- 发布命令(无目标)(ID) | 参数: whichUnit(unit), order(integer) | 返回: boolean
cj.IssueImmediateOrderById = JassCommon["IssueImmediateOrderById"]
--- 发布即时点目标命令(字符串) | 参数: whichUnit(unit), order(string), x(real), y(real), instantTargetWidget(widget) | 返回: boolean
cj.IssueInstantPointOrder = JassCommon["IssueInstantPointOrder"]
--- 发布即时点目标命令(ID) | 参数: whichUnit(unit), order(integer), x(real), y(real), instantTargetWidget(widget) | 返回: boolean
cj.IssueInstantPointOrderById = JassCommon["IssueInstantPointOrderById"]
--- 发布即时单位目标命令(字符串) | 参数: whichUnit(unit), order(string), targetWidget(widget), instantTargetWidget(widget) | 返回: boolean
cj.IssueInstantTargetOrder = JassCommon["IssueInstantTargetOrder"]
--- 发布即时单位目标命令(ID) | 参数: whichUnit(unit), order(integer), targetWidget(widget), instantTargetWidget(widget) | 返回: boolean
cj.IssueInstantTargetOrderById = JassCommon["IssueInstantTargetOrderById"]
--- 发布中介命令(无目标) | 参数: forWhichPlayer(player), neutralStructure(unit), unitToBuild(string) | 返回: boolean
cj.IssueNeutralImmediateOrder = JassCommon["IssueNeutralImmediateOrder"]
--- 发布中介命令(无目标)(ID) | 参数: forWhichPlayer(player), neutralStructure(unit), unitId(integer) | 返回: boolean
cj.IssueNeutralImmediateOrderById = JassCommon["IssueNeutralImmediateOrderById"]
--- 发布中介命令(指定坐标) | 参数: forWhichPlayer(player), neutralStructure(unit), unitToBuild(string), x(real), y(real) | 返回: boolean
cj.IssueNeutralPointOrder = JassCommon["IssueNeutralPointOrder"]
--- 发布中介命令(指定坐标)(ID) | 参数: forWhichPlayer(player), neutralStructure(unit), unitId(integer), x(real), y(real) | 返回: boolean
cj.IssueNeutralPointOrderById = JassCommon["IssueNeutralPointOrderById"]
--- 发布中介命令(指定单位) | 参数: forWhichPlayer(player), neutralStructure(unit), unitToBuild(string), target(widget) | 返回: boolean
cj.IssueNeutralTargetOrder = JassCommon["IssueNeutralTargetOrder"]
--- 发布中介命令(指定单位)(ID) | 参数: forWhichPlayer(player), neutralStructure(unit), unitId(integer), target(widget) | 返回: boolean
cj.IssueNeutralTargetOrderById = JassCommon["IssueNeutralTargetOrderById"]
--- 发布命令(指定坐标) | 参数: whichUnit(unit), order(string), x(real), y(real) | 返回: boolean
cj.IssuePointOrder = JassCommon["IssuePointOrder"]
--- 发布命令(指定坐标)(ID) | 参数: whichUnit(unit), order(integer), x(real), y(real) | 返回: boolean
cj.IssuePointOrderById = JassCommon["IssuePointOrderById"]
--- 发布命令(指定点)(ID) | 参数: whichUnit(unit), order(integer), whichLocation(location) | 返回: boolean
cj.IssuePointOrderByIdLoc = JassCommon["IssuePointOrderByIdLoc"]
--- 发布命令(指定点) | 参数: whichUnit(unit), order(string), whichLocation(location) | 返回: boolean
cj.IssuePointOrderLoc = JassCommon["IssuePointOrderLoc"]
--- 发布命令(指定单位) | 参数: whichUnit(unit), order(string), targetWidget(widget) | 返回: boolean
cj.IssueTargetOrder = JassCommon["IssueTargetOrder"]
--- 发布命令(指定单位)(ID) | 参数: whichUnit(unit), order(integer), targetWidget(widget) | 返回: boolean
cj.IssueTargetOrderById = JassCommon["IssueTargetOrderById"]
--- 添加物品类型 [R] | 参数: whichItemPool(itempool), itemId(integer), weight(real)
cj.ItemPoolAddItemType = JassCommon["ItemPoolAddItemType"]
--- 删除物品类型 [R] | 参数: whichItemPool(itempool), itemId(integer)
cj.ItemPoolRemoveItemType = JassCommon["ItemPoolRemoveItemType"]
--- 杀死 | 参数: d(destructable)
cj.KillDestructable = JassCommon["KillDestructable"]
--- 删除音效 | 参数: soundHandle(sound)
cj.KillSoundWhenDone = JassCommon["KillSoundWhenDone"]
--- 杀死 | 参数: whichUnit(unit)
cj.KillUnit = JassCommon["KillUnit"]
--- 排行榜添加项目 | 参数: lb(leaderboard), label(string), value(integer), p(player)
cj.LeaderboardAddItem = JassCommon["LeaderboardAddItem"]
--- 清空 [R] | 参数: lb(leaderboard)
cj.LeaderboardClear = JassCommon["LeaderboardClear"]
--- 显示/隐藏 [R] | 参数: lb(leaderboard), show(boolean)
cj.LeaderboardDisplay = JassCommon["LeaderboardDisplay"]
--- 行数 | 参数: lb(leaderboard) | 返回: integer
cj.LeaderboardGetItemCount = JassCommon["LeaderboardGetItemCount"]
--- 获取排行榜标签文本 | 参数: lb(leaderboard) | 返回: string
cj.LeaderboardGetLabelText = JassCommon["LeaderboardGetLabelText"]
--- 获取排行榜中玩家的索引 | 参数: lb(leaderboard), p(player) | 返回: integer
cj.LeaderboardGetPlayerIndex = JassCommon["LeaderboardGetPlayerIndex"]
--- 玩家在排行榜 | 参数: lb(leaderboard), p(player) | 返回: boolean
cj.LeaderboardHasPlayerItem = JassCommon["LeaderboardHasPlayerItem"]
--- 移除排行榜项目 | 参数: lb(leaderboard), index(integer)
cj.LeaderboardRemoveItem = JassCommon["LeaderboardRemoveItem"]
--- 移除排行榜中玩家的项目 | 参数: lb(leaderboard), p(player)
cj.LeaderboardRemovePlayerItem = JassCommon["LeaderboardRemovePlayerItem"]
--- 设置排行榜项目标签 | 参数: lb(leaderboard), whichItem(integer), val(string)
cj.LeaderboardSetItemLabel = JassCommon["LeaderboardSetItemLabel"]
--- 设置排行榜项目标签颜色 | 参数: lb(leaderboard), whichItem(integer), red(integer), green(integer), blue(integer), alpha(integer)
cj.LeaderboardSetItemLabelColor = JassCommon["LeaderboardSetItemLabelColor"]
--- 设置排行榜项目样式 | 参数: lb(leaderboard), whichItem(integer), showLabel(boolean), showValue(boolean), showIcon(boolean)
cj.LeaderboardSetItemStyle = JassCommon["LeaderboardSetItemStyle"]
--- 设置排行榜项目值 | 参数: lb(leaderboard), whichItem(integer), val(integer)
cj.LeaderboardSetItemValue = JassCommon["LeaderboardSetItemValue"]
--- 设置排行榜项目值颜色 | 参数: lb(leaderboard), whichItem(integer), red(integer), green(integer), blue(integer), alpha(integer)
cj.LeaderboardSetItemValueColor = JassCommon["LeaderboardSetItemValueColor"]
--- 设置标题 | 参数: lb(leaderboard), label(string)
cj.LeaderboardSetLabel = JassCommon["LeaderboardSetLabel"]
--- 设置文字颜色 [R] | 参数: lb(leaderboard), red(integer), green(integer), blue(integer), alpha(integer)
cj.LeaderboardSetLabelColor = JassCommon["LeaderboardSetLabelColor"]
--- 设置排行榜大小(按项目数) | 参数: lb(leaderboard), count(integer)
cj.LeaderboardSetSizeByItemCount = JassCommon["LeaderboardSetSizeByItemCount"]
--- 设置显示样式 | 参数: lb(leaderboard), showLabel(boolean), showNames(boolean), showValues(boolean), showIcons(boolean)
cj.LeaderboardSetStyle = JassCommon["LeaderboardSetStyle"]
--- 设置数值颜色 [R] | 参数: lb(leaderboard), red(integer), green(integer), blue(integer), alpha(integer)
cj.LeaderboardSetValueColor = JassCommon["LeaderboardSetValueColor"]
--- 排行榜按标签排序 | 参数: lb(leaderboard), ascending(boolean)
cj.LeaderboardSortItemsByLabel = JassCommon["LeaderboardSortItemsByLabel"]
--- 排行榜按玩家排序 | 参数: lb(leaderboard), ascending(boolean)
cj.LeaderboardSortItemsByPlayer = JassCommon["LeaderboardSortItemsByPlayer"]
--- 排行榜按值排序 | 参数: lb(leaderboard), ascending(boolean)
cj.LeaderboardSortItemsByValue = JassCommon["LeaderboardSortItemsByValue"]
--- 从哈希表读取技能句柄 | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: ability
cj.LoadAbilityHandle = JassCommon["LoadAbilityHandle"]
--- <1.24> 从哈希表提取布尔 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: boolean
cj.LoadBoolean = JassCommon["LoadBoolean"]
--- <1.24> 从哈希表提取布尔表达式 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: boolexpr
cj.LoadBooleanExprHandle = JassCommon["LoadBooleanExprHandle"]
--- <1.24> 从哈希表提取对话框按钮 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: button
cj.LoadButtonHandle = JassCommon["LoadButtonHandle"]
--- <1.24> 从哈希表提取失败条件 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: defeatcondition
cj.LoadDefeatConditionHandle = JassCommon["LoadDefeatConditionHandle"]
--- <1.24> 从哈希表提取可破坏物 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: destructable
cj.LoadDestructableHandle = JassCommon["LoadDestructableHandle"]
--- <1.24> 从哈希表提取对话框 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: dialog
cj.LoadDialogHandle = JassCommon["LoadDialogHandle"]
--- <1.24> 从哈希表提取特效 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: effect
cj.LoadEffectHandle = JassCommon["LoadEffectHandle"]
--- <1.24> 从哈希表提取可见度修正器 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: fogmodifier
cj.LoadFogModifierHandle = JassCommon["LoadFogModifierHandle"]
--- <1.24> 从哈希表提取迷雾状态 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: fogstate
cj.LoadFogStateHandle = JassCommon["LoadFogStateHandle"]
--- <1.24> 从哈希表提取玩家组 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: force
cj.LoadForceHandle = JassCommon["LoadForceHandle"]
--- 读取进度 | 参数: saveFileName(string), doScoreScreen(boolean)
cj.LoadGame = JassCommon["LoadGame"]
--- <1.24> 从哈希表提取单位组 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: group
cj.LoadGroupHandle = JassCommon["LoadGroupHandle"]
--- <1.24> 从哈希表提取哈希表 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: hashtable
cj.LoadHashtableHandle = JassCommon["LoadHashtableHandle"]
--- <1.24> 从哈希表提取图象 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: image
cj.LoadImageHandle = JassCommon["LoadImageHandle"]
--- <1.24> 从哈希表提取整数 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: integer
cj.LoadInteger = JassCommon["LoadInteger"]
--- <1.24> 从哈希表提取物品 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: item
cj.LoadItemHandle = JassCommon["LoadItemHandle"]
--- <1.24> 从哈希表提取物品池 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: itempool
cj.LoadItemPoolHandle = JassCommon["LoadItemPoolHandle"]
--- <1.24> 从哈希表提取排行榜 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: leaderboard
cj.LoadLeaderboardHandle = JassCommon["LoadLeaderboardHandle"]
--- <1.24> 从哈希表提取闪电效果 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: lightning
cj.LoadLightningHandle = JassCommon["LoadLightningHandle"]
--- <1.24> 从哈希表提取点 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: location
cj.LoadLocationHandle = JassCommon["LoadLocationHandle"]
--- <1.24> 从哈希表提取多面板 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: multiboard
cj.LoadMultiboardHandle = JassCommon["LoadMultiboardHandle"]
--- <1.24> 从哈希表提取多面板项目 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: multiboarditem
cj.LoadMultiboardItemHandle = JassCommon["LoadMultiboardItemHandle"]
--- <1.24> 从哈希表提取玩家 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: player
cj.LoadPlayerHandle = JassCommon["LoadPlayerHandle"]
--- <1.24> 从哈希表提取任务 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: quest
cj.LoadQuestHandle = JassCommon["LoadQuestHandle"]
--- <1.24> 从哈希表提取任务要求 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: questitem
cj.LoadQuestItemHandle = JassCommon["LoadQuestItemHandle"]
--- <1.24> 从哈希表提取实数 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: real
cj.LoadReal = JassCommon["LoadReal"]
--- <1.24> 从哈希表提取区域(矩型) [C] | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: rect
cj.LoadRectHandle = JassCommon["LoadRectHandle"]
--- <1.24> 从哈希表提取区域(不规则) [C] | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: region
cj.LoadRegionHandle = JassCommon["LoadRegionHandle"]
--- <1.24> 从哈希表提取音效 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: sound
cj.LoadSoundHandle = JassCommon["LoadSoundHandle"]
--- <1.24> 从哈希表提取字符串 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: string
cj.LoadStr = JassCommon["LoadStr"]
--- <1.24> 从哈希表提取漂浮文字 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: texttag
cj.LoadTextTagHandle = JassCommon["LoadTextTagHandle"]
--- <1.24> 从哈希表提取计时器窗口 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: timerdialog
cj.LoadTimerDialogHandle = JassCommon["LoadTimerDialogHandle"]
--- <1.24> 从哈希表提取计时器 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: timer
cj.LoadTimerHandle = JassCommon["LoadTimerHandle"]
--- <1.24> 从哈希表提取可追踪物 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: trackable
cj.LoadTrackableHandle = JassCommon["LoadTrackableHandle"]
--- <1.24> 从哈希表提取触发动作 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: triggeraction
cj.LoadTriggerActionHandle = JassCommon["LoadTriggerActionHandle"]
--- <1.24> 从哈希表提取触发条件 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: triggercondition
cj.LoadTriggerConditionHandle = JassCommon["LoadTriggerConditionHandle"]
--- <1.24> 从哈希表提取触发事件 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: event
cj.LoadTriggerEventHandle = JassCommon["LoadTriggerEventHandle"]
--- <1.24> 从哈希表提取触发器 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: trigger
cj.LoadTriggerHandle = JassCommon["LoadTriggerHandle"]
--- <1.24> 从哈希表提取地面纹理变化 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: ubersplat
cj.LoadUbersplatHandle = JassCommon["LoadUbersplatHandle"]
--- <1.24> 从哈希表提取单位 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: unit
cj.LoadUnitHandle = JassCommon["LoadUnitHandle"]
--- <1.24> 从哈希表提取单位池 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: unitpool
cj.LoadUnitPoolHandle = JassCommon["LoadUnitPoolHandle"]
--- 从哈希表读取控件句柄 | 参数: table(hashtable), parentKey(integer), childKey(integer) | 返回: widget
cj.LoadWidgetHandle = JassCommon["LoadWidgetHandle"]
--- 坐标点 | 参数: x(real), y(real) | 返回: location
cj.Location = JassCommon["Location"]
--- 移动闪电效果 | 参数: whichBolt(lightning), checkVisibility(boolean), x1(real), y1(real), x2(real), y2(real) | 返回: boolean
cj.MoveLightning = JassCommon["MoveLightning"]
--- 移动闪电效果(指定坐标) [R] | 参数: whichBolt(lightning), checkVisibility(boolean), x1(real), y1(real), z1(real), x2(real), y2(real), z2(real) | 返回: boolean
cj.MoveLightningEx = JassCommon["MoveLightningEx"]
--- 移动点 [R] | 参数: whichLocation(location), newX(real), newY(real)
cj.MoveLocation = JassCommon["MoveLocation"]
--- 移动矩形区域(指定坐标) [R] | 参数: whichRect(rect), newCenterX(real), newCenterY(real)
cj.MoveRectTo = JassCommon["MoveRectTo"]
--- 移动矩形区域(指定点) | 参数: whichRect(rect), newCenterLoc(location)
cj.MoveRectToLoc = JassCommon["MoveRectToLoc"]
--- 清空多面板 | 参数: lb(multiboard)
cj.MultiboardClear = JassCommon["MultiboardClear"]
--- 显示/隐藏 [R] | 参数: lb(multiboard), show(boolean)
cj.MultiboardDisplay = JassCommon["MultiboardDisplay"]
--- 列数 | 参数: lb(multiboard) | 返回: integer
cj.MultiboardGetColumnCount = JassCommon["MultiboardGetColumnCount"]
--- 多面板项目 [R] | 参数: lb(multiboard), row(integer), column(integer) | 返回: multiboarditem
cj.MultiboardGetItem = JassCommon["MultiboardGetItem"]
--- 行数 | 参数: lb(multiboard) | 返回: integer
cj.MultiboardGetRowCount = JassCommon["MultiboardGetRowCount"]
--- 多面板标题 | 参数: lb(multiboard) | 返回: string
cj.MultiboardGetTitleText = JassCommon["MultiboardGetTitleText"]
--- 最大/最小化 [R] | 参数: lb(multiboard), minimize(boolean)
cj.MultiboardMinimize = JassCommon["MultiboardMinimize"]
--- 删除多面板项目 [R] | 参数: mbi(multiboarditem)
cj.MultiboardReleaseItem = JassCommon["MultiboardReleaseItem"]
--- 设置列数 | 参数: lb(multiboard), count(integer)
cj.MultiboardSetColumnCount = JassCommon["MultiboardSetColumnCount"]
--- 设置指定项目图标 [R] | 参数: mbi(multiboarditem), iconFileName(string)
cj.MultiboardSetItemIcon = JassCommon["MultiboardSetItemIcon"]
--- 设置指定项目显示风格 [R] | 参数: mbi(multiboarditem), showValue(boolean), showIcon(boolean)
cj.MultiboardSetItemStyle = JassCommon["MultiboardSetItemStyle"]
--- 设置指定项目文本 [R] | 参数: mbi(multiboarditem), val(string)
cj.MultiboardSetItemValue = JassCommon["MultiboardSetItemValue"]
--- 设置指定项目颜色 [R] | 参数: mbi(multiboarditem), red(integer), green(integer), blue(integer), alpha(integer)
cj.MultiboardSetItemValueColor = JassCommon["MultiboardSetItemValueColor"]
--- 设置指定项目宽度 [R] | 参数: mbi(multiboarditem), width(real)
cj.MultiboardSetItemWidth = JassCommon["MultiboardSetItemWidth"]
--- 设置所有项目图标 [R] | 参数: lb(multiboard), iconPath(string)
cj.MultiboardSetItemsIcon = JassCommon["MultiboardSetItemsIcon"]
--- 设置所有项目显示风格 [R] | 参数: lb(multiboard), showValues(boolean), showIcons(boolean)
cj.MultiboardSetItemsStyle = JassCommon["MultiboardSetItemsStyle"]
--- 设置所有项目文本 [R] | 参数: lb(multiboard), value(string)
cj.MultiboardSetItemsValue = JassCommon["MultiboardSetItemsValue"]
--- 设置所有项目颜色 [R] | 参数: lb(multiboard), red(integer), green(integer), blue(integer), alpha(integer)
cj.MultiboardSetItemsValueColor = JassCommon["MultiboardSetItemsValueColor"]
--- 设置所有项目宽度 [R] | 参数: lb(multiboard), width(real)
cj.MultiboardSetItemsWidth = JassCommon["MultiboardSetItemsWidth"]
--- 设置行数 | 参数: lb(multiboard), count(integer)
cj.MultiboardSetRowCount = JassCommon["MultiboardSetRowCount"]
--- 设置标题 | 参数: lb(multiboard), label(string)
cj.MultiboardSetTitleText = JassCommon["MultiboardSetTitleText"]
--- 设置标题颜色 [R] | 参数: lb(multiboard), red(integer), green(integer), blue(integer), alpha(integer)
cj.MultiboardSetTitleTextColor = JassCommon["MultiboardSetTitleTextColor"]
--- 显示/隐藏多面板模式 [R] | 参数: flag(boolean)
cj.MultiboardSuppressDisplay = JassCommon["MultiboardSuppressDisplay"]
--- 设置环境音效 [new] | 参数: environmentName(string)
cj.NewSoundEnvironment = JassCommon["NewSoundEnvironment"]
--- 逻辑非(条件表达式) | 参数: operand(boolexpr) | 返回: boolexpr
cj.Not = JassCommon["Not"]
--- 逻辑或(条件表达式) | 参数: operandA(boolexpr), operandB(boolexpr) | 返回: boolexpr
cj.Or = JassCommon["Or"]
--- 字符串转命令ID | 参数: orderIdString(string) | 返回: integer
cj.OrderId = JassCommon["OrderId"]
--- 命令ID转字符串 | 参数: orderId(integer) | 返回: string
cj.OrderId2String = JassCommon["OrderId2String"]
--- 平移镜头到坐标 | 参数: x(real), y(real)
cj.PanCameraTo = JassCommon["PanCameraTo"]
--- 平移镜头(所有玩家)(限时) [R] | 参数: x(real), y(real), duration(real)
cj.PanCameraToTimed = JassCommon["PanCameraToTimed"]
--- 指定高度平移镜头(所有玩家)(限时) [R] | 参数: x(real), y(real), zOffsetDest(real), duration(real)
cj.PanCameraToTimedWithZ = JassCommon["PanCameraToTimedWithZ"]
--- 平移镜头到坐标(带Z轴) | 参数: x(real), y(real), zOffsetDest(real)
cj.PanCameraToWithZ = JassCommon["PanCameraToWithZ"]
--- 暂停/恢复 AI脚本运行 [R] | 参数: p(player), pause(boolean)
cj.PauseCompAI = JassCommon["PauseCompAI"]
--- 暂停/恢复游戏 [R] | 参数: flag(boolean)
cj.PauseGame = JassCommon["PauseGame"]
--- 暂停计时器 [R] | 参数: whichTimer(timer)
cj.PauseTimer = JassCommon["PauseTimer"]
--- 暂停/恢复 [R] | 参数: whichUnit(unit), flag(boolean)
cj.PauseUnit = JassCommon["PauseUnit"]
--- 小地图信号(所有玩家) [R] | 参数: x(real), y(real), duration(real)
cj.PingMinimap = JassCommon["PingMinimap"]
--- 小地图信号(指定颜色)(所有玩家) [R] | 参数: x(real), y(real), duration(real), red(integer), green(integer), blue(integer), extraEffects(boolean)
cj.PingMinimapEx = JassCommon["PingMinimapEx"]
--- 选择放置物品 [R] | 参数: whichItemPool(itempool), x(real), y(real) | 返回: item
cj.PlaceRandomItem = JassCommon["PlaceRandomItem"]
--- 选择放置单位 [R] | 参数: whichPool(unitpool), forWhichPlayer(player), x(real), y(real), facing(real) | 返回: unit
cj.PlaceRandomUnit = JassCommon["PlaceRandomUnit"]
--- 播放电影 | 参数: movieName(string)
cj.PlayCinematic = JassCommon["PlayCinematic"]
--- 播放模型电影 | 参数: modelName(string)
cj.PlayModelCinematic = JassCommon["PlayModelCinematic"]
--- 播放音乐 | 参数: musicName(string)
cj.PlayMusic = JassCommon["PlayMusic"]
--- 播放音乐(扩展) | 参数: musicName(string), frommsecs(integer), fadeinmsecs(integer)
cj.PlayMusicEx = JassCommon["PlayMusicEx"]
--- 播放主题音乐 [C] | 参数: musicFileName(string)
cj.PlayThematicMusic = JassCommon["PlayThematicMusic"]
--- 跳播主题音乐 [R] | 参数: musicFileName(string), frommsecs(integer)
cj.PlayThematicMusicEx = JassCommon["PlayThematicMusicEx"]
--- 整数索引转玩家对象 | 参数: number(integer) | 返回: player
cj.Player = JassCommon["Player"]
--- 玩家使用的排行榜 | 参数: toPlayer(player) | 返回: leaderboard
cj.PlayerGetLeaderboard = JassCommon["PlayerGetLeaderboard"]
--- 设置玩家使用的排行榜 [R] | 参数: toPlayer(player), lb(leaderboard)
cj.PlayerSetLeaderboard = JassCommon["PlayerSetLeaderboard"]
--- 幂运算 | 参数: x(real), power(real) | 返回: real
cj.Pow = JassCommon["Pow"]
--- 预载文件 | 参数: filename(string)
cj.Preload = JassCommon["Preload"]
--- 开始预载 | 参数: timeout(real)
cj.PreloadEnd = JassCommon["PreloadEnd"]
--- PreloadEndEx
cj.PreloadEndEx = JassCommon["PreloadEndEx"]
--- PreloadGenClear
cj.PreloadGenClear = JassCommon["PreloadGenClear"]
--- 预加载结束 | 参数: filename(string)
cj.PreloadGenEnd = JassCommon["PreloadGenEnd"]
--- PreloadGenStart
cj.PreloadGenStart = JassCommon["PreloadGenStart"]
--- PreloadRefresh
cj.PreloadRefresh = JassCommon["PreloadRefresh"]
--- PreloadStart
cj.PreloadStart = JassCommon["PreloadStart"]
--- 批量预载 | 参数: filename(string)
cj.Preloader = JassCommon["Preloader"]
--- 创建任务需求项目 | 参数: whichQuest(quest) | 返回: questitem
cj.QuestCreateItem = JassCommon["QuestCreateItem"]
--- 设置任务项目完成 | 参数: whichQuestItem(questitem), completed(boolean)
cj.QuestItemSetCompleted = JassCommon["QuestItemSetCompleted"]
--- 改变任务项目说明 | 参数: whichQuestItem(questitem), description(string)
cj.QuestItemSetDescription = JassCommon["QuestItemSetDescription"]
--- 设置任务完成 | 参数: whichQuest(quest), completed(boolean)
cj.QuestSetCompleted = JassCommon["QuestSetCompleted"]
--- 设置任务说明 | 参数: whichQuest(quest), description(string)
cj.QuestSetDescription = JassCommon["QuestSetDescription"]
--- 设置任务被发现 | 参数: whichQuest(quest), discovered(boolean)
cj.QuestSetDiscovered = JassCommon["QuestSetDiscovered"]
--- 启用/禁用 任务 [R] | 参数: whichQuest(quest), enabled(boolean)
cj.QuestSetEnabled = JassCommon["QuestSetEnabled"]
--- 设置任务失败 | 参数: whichQuest(quest), failed(boolean)
cj.QuestSetFailed = JassCommon["QuestSetFailed"]
--- 设置任务图标路径 | 参数: whichQuest(quest), iconPath(string)
cj.QuestSetIconPath = JassCommon["QuestSetIconPath"]
--- 设置任务是否为主要任务 | 参数: whichQuest(quest), required(boolean)
cj.QuestSetRequired = JassCommon["QuestSetRequired"]
--- 设置任务标题 | 参数: whichQuest(quest), title(string)
cj.QuestSetTitle = JassCommon["QuestSetTitle"]
--- 将可破坏物动画加入队列 | 参数: d(destructable), whichAnimation(string)
cj.QueueDestructableAnimation = JassCommon["QueueDestructableAnimation"]
--- 单位动画加入队列 | 参数: whichUnit(unit), whichAnimation(string)
cj.QueueUnitAnimation = JassCommon["QueueUnitAnimation"]
--- 转换实数为整数 | 参数: r(real) | 返回: integer
cj.R2I = JassCommon["R2I"]
--- 转换实数为字符串 | 参数: r(real) | 返回: string
cj.R2S = JassCommon["R2S"]
--- 格式转换实数为字符串 | 参数: r(real), width(integer), precision(integer) | 返回: string
cj.R2SW = JassCommon["R2SW"]
--- 转换弧度为角度 | 参数: radians(real) | 返回: real
cj.Rad2Deg = JassCommon["Rad2Deg"]
--- 新建矩形区域(指定边角坐标) | 参数: minx(real), miny(real), maxx(real), maxy(real) | 返回: rect
cj.Rect = JassCommon["Rect"]
--- 新建矩形区域(指定边角点) | 参数: min(location), max(location) | 返回: rect
cj.RectFromLoc = JassCommon["RectFromLoc"]
--- 恢复指定单位的警戒点 | 参数: hUnit(unit)
cj.RecycleGuardPosition = JassCommon["RecycleGuardPosition"]
--- 添加单元点(指定坐标) [R] | 参数: whichRegion(region), x(real), y(real)
cj.RegionAddCell = JassCommon["RegionAddCell"]
--- 添加单元点(指定点) [R] | 参数: whichRegion(region), whichLocation(location)
cj.RegionAddCellAtLoc = JassCommon["RegionAddCellAtLoc"]
--- 添加区域 [R] | 参数: whichRegion(region), r(rect)
cj.RegionAddRect = JassCommon["RegionAddRect"]
--- 移除单元点(指定坐标) [R] | 参数: whichRegion(region), x(real), y(real)
cj.RegionClearCell = JassCommon["RegionClearCell"]
--- 移除单元点(指定点) [R] | 参数: whichRegion(region), whichLocation(location)
cj.RegionClearCellAtLoc = JassCommon["RegionClearCellAtLoc"]
--- 移除区域 [R] | 参数: whichRegion(region), r(rect)
cj.RegionClearRect = JassCommon["RegionClearRect"]
--- 注册堆叠音效 [new] | 参数: soundHandle(sound), byPosition(boolean), rectwidth(real), rectheight(real)
cj.RegisterStackedSound = JassCommon["RegisterStackedSound"]
--- ReloadGame
cj.ReloadGame = JassCommon["ReloadGame"]
--- 读取本地缓存数据 | 返回: boolean
cj.ReloadGameCachesFromDisk = JassCommon["ReloadGameCachesFromDisk"]
--- 忽视所有单位的警戒点 | 参数: num(player)
cj.RemoveAllGuardPositions = JassCommon["RemoveAllGuardPositions"]
--- 删除 | 参数: d(destructable)
cj.RemoveDestructable = JassCommon["RemoveDestructable"]
--- 忽视指定单位的警戒点 | 参数: hUnit(unit)
cj.RemoveGuardPosition = JassCommon["RemoveGuardPosition"]
--- 删除 | 参数: whichItem(item)
cj.RemoveItem = JassCommon["RemoveItem"]
--- 删除物品(所有市场) | 参数: itemId(integer)
cj.RemoveItemFromAllStock = JassCommon["RemoveItemFromAllStock"]
--- 从商店移除物品 | 参数: whichUnit(unit), itemId(integer)
cj.RemoveItemFromStock = JassCommon["RemoveItemFromStock"]
--- 清除点 [R] | 参数: whichLocation(location)
cj.RemoveLocation = JassCommon["RemoveLocation"]
--- 踢除玩家 | 参数: whichPlayer(player), gameResult(playergameresult)
cj.RemovePlayer = JassCommon["RemovePlayer"]
--- 删除矩形区域 [R] | 参数: whichRect(rect)
cj.RemoveRect = JassCommon["RemoveRect"]
--- 删除不规则区域 [R] | 参数: whichRegion(region)
cj.RemoveRegion = JassCommon["RemoveRegion"]
--- 删除存档文件夹 | 参数: sourceDirName(string) | 返回: boolean
cj.RemoveSaveDirectory = JassCommon["RemoveSaveDirectory"]
--- 清理哈希项存储的布尔值 <new> | 参数: table(hashtable), parentKey(integer), childKey(integer)
cj.RemoveSavedBoolean = JassCommon["RemoveSavedBoolean"]
--- 清理哈希项存储的句柄 <new> | 参数: table(hashtable), parentKey(integer), childKey(integer)
cj.RemoveSavedHandle = JassCommon["RemoveSavedHandle"]
--- 清理哈希项存储的整数值 <new> | 参数: table(hashtable), parentKey(integer), childKey(integer)
cj.RemoveSavedInteger = JassCommon["RemoveSavedInteger"]
--- 清理哈希项存储的实数值 <new> | 参数: table(hashtable), parentKey(integer), childKey(integer)
cj.RemoveSavedReal = JassCommon["RemoveSavedReal"]
--- 清理哈希项存储的字符串 <new> | 参数: table(hashtable), parentKey(integer), childKey(integer)
cj.RemoveSavedString = JassCommon["RemoveSavedString"]
--- 删除 | 参数: whichUnit(unit)
cj.RemoveUnit = JassCommon["RemoveUnit"]
--- 删除单位(所有市场) | 参数: unitId(integer)
cj.RemoveUnitFromAllStock = JassCommon["RemoveUnitFromAllStock"]
--- 从商店移除单位 | 参数: whichUnit(unit), unitId(integer)
cj.RemoveUnitFromStock = JassCommon["RemoveUnitFromStock"]
--- 删除天气效果 | 参数: whichEffect(weathereffect)
cj.RemoveWeatherEffect = JassCommon["RemoveWeatherEffect"]
--- 重命名存档文件夹 | 参数: sourceDirName(string), destDirName(string) | 返回: boolean
cj.RenameSaveDirectory = JassCommon["RenameSaveDirectory"]
--- 重置迷雾
cj.ResetTerrainFog = JassCommon["ResetTerrainFog"]
--- 重置游戏镜头(所有玩家) [R] | 参数: duration(real)
cj.ResetToGameCamera = JassCommon["ResetToGameCamera"]
--- 重置触发器 | 参数: whichTrigger(trigger)
cj.ResetTrigger = JassCommon["ResetTrigger"]
--- 重置地面纹理变化 | 参数: whichSplat(ubersplat)
cj.ResetUbersplat = JassCommon["ResetUbersplat"]
--- 重置身体朝向 | 参数: whichUnit(unit)
cj.ResetUnitLookAt = JassCommon["ResetUnitLookAt"]
--- 重新开始游戏 | 参数: doScoreScreen(boolean)
cj.RestartGame = JassCommon["RestartGame"]
--- 从游戏缓存还原单位 | 参数: cache(gamecache), missionKey(string), key(string), forWhichPlayer(player), x(real), y(real), facing(real) | 返回: unit
cj.RestoreUnit = JassCommon["RestoreUnit"]
--- 恢复背景音乐
cj.ResumeMusic = JassCommon["ResumeMusic"]
--- 恢复计时器 [R] | 参数: whichTimer(timer)
cj.ResumeTimer = JassCommon["ResumeTimer"]
--- 立即复活(指定坐标) [R] | 参数: whichHero(unit), x(real), y(real), doEyecandy(boolean) | 返回: boolean
cj.ReviveHero = JassCommon["ReviveHero"]
--- 立即复活(指定点) | 参数: whichHero(unit), loc(location), doEyecandy(boolean) | 返回: boolean
cj.ReviveHeroLoc = JassCommon["ReviveHeroLoc"]
--- 转换字符串为整数 | 参数: s(string) | 返回: integer
cj.S2I = JassCommon["S2I"]
--- 转换字符串为实数 | 参数: s(string) | 返回: real
cj.S2R = JassCommon["S2R"]
--- 保存技能句柄到哈希表 | 参数: table(hashtable), parentKey(integer), childKey(integer), whichAbility(ability) | 返回: boolean
cj.SaveAbilityHandle = JassCommon["SaveAbilityHandle"]
--- <1.24> 保存布尔 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), value(boolean)
cj.SaveBoolean = JassCommon["SaveBoolean"]
--- <1.24> 保存布尔表达式 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), whichBoolexpr(boolexpr) | 返回: boolean
cj.SaveBooleanExprHandle = JassCommon["SaveBooleanExprHandle"]
--- <1.24> 保存对话框按钮 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), whichButton(button) | 返回: boolean
cj.SaveButtonHandle = JassCommon["SaveButtonHandle"]
--- <1.24> 保存失败条件 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), whichDefeatcondition(defeatcondition) | 返回: boolean
cj.SaveDefeatConditionHandle = JassCommon["SaveDefeatConditionHandle"]
--- <1.24> 保存可破坏物 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), whichDestructable(destructable) | 返回: boolean
cj.SaveDestructableHandle = JassCommon["SaveDestructableHandle"]
--- <1.24> 保存对话框 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), whichDialog(dialog) | 返回: boolean
cj.SaveDialogHandle = JassCommon["SaveDialogHandle"]
--- <1.24> 保存特效 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), whichEffect(effect) | 返回: boolean
cj.SaveEffectHandle = JassCommon["SaveEffectHandle"]
--- <1.24> 保存可见度修正器 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), whichFogModifier(fogmodifier) | 返回: boolean
cj.SaveFogModifierHandle = JassCommon["SaveFogModifierHandle"]
--- <1.24> 保存迷雾状态 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), whichFogState(fogstate) | 返回: boolean
cj.SaveFogStateHandle = JassCommon["SaveFogStateHandle"]
--- <1.24> 保存玩家组 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), whichForce(force) | 返回: boolean
cj.SaveForceHandle = JassCommon["SaveForceHandle"]
--- 保存进度 [R] | 参数: saveFileName(string)
cj.SaveGame = JassCommon["SaveGame"]
--- 本地保存游戏缓存 | 参数: whichCache(gamecache) | 返回: boolean
cj.SaveGameCache = JassCommon["SaveGameCache"]
--- 游戏存档存在 | 参数: saveName(string) | 返回: boolean
cj.SaveGameExists = JassCommon["SaveGameExists"]
--- <1.24> 保存单位组 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), whichGroup(group) | 返回: boolean
cj.SaveGroupHandle = JassCommon["SaveGroupHandle"]
--- <1.24> 保存图像 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), whichImage(image) | 返回: boolean
cj.SaveImageHandle = JassCommon["SaveImageHandle"]
--- <1.24> 保存整数 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), value(integer)
cj.SaveInteger = JassCommon["SaveInteger"]
--- <1.24> 保存物品 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), whichItem(item) | 返回: boolean
cj.SaveItemHandle = JassCommon["SaveItemHandle"]
--- <1.24> 保存物品池 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), whichItempool(itempool) | 返回: boolean
cj.SaveItemPoolHandle = JassCommon["SaveItemPoolHandle"]
--- <1.24> 保存排行榜 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), whichLeaderboard(leaderboard) | 返回: boolean
cj.SaveLeaderboardHandle = JassCommon["SaveLeaderboardHandle"]
--- <1.24> 保存闪电效果 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), whichLightning(lightning) | 返回: boolean
cj.SaveLightningHandle = JassCommon["SaveLightningHandle"]
--- <1.24> 保存点 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), whichLocation(location) | 返回: boolean
cj.SaveLocationHandle = JassCommon["SaveLocationHandle"]
--- <1.24> 保存多面板 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), whichMultiboard(multiboard) | 返回: boolean
cj.SaveMultiboardHandle = JassCommon["SaveMultiboardHandle"]
--- <1.24> 保存多面板项目 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), whichMultiboarditem(multiboarditem) | 返回: boolean
cj.SaveMultiboardItemHandle = JassCommon["SaveMultiboardItemHandle"]
--- <1.24> 保存玩家 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), whichPlayer(player) | 返回: boolean
cj.SavePlayerHandle = JassCommon["SavePlayerHandle"]
--- <1.24> 保存任务 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), whichQuest(quest) | 返回: boolean
cj.SaveQuestHandle = JassCommon["SaveQuestHandle"]
--- <1.24> 保存任务要求 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), whichQuestitem(questitem) | 返回: boolean
cj.SaveQuestItemHandle = JassCommon["SaveQuestItemHandle"]
--- <1.24> 保存实数 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), value(real)
cj.SaveReal = JassCommon["SaveReal"]
--- <1.24> 保存区域(矩型) [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), whichRect(rect) | 返回: boolean
cj.SaveRectHandle = JassCommon["SaveRectHandle"]
--- <1.24> 保存区域(不规则) [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), whichRegion(region) | 返回: boolean
cj.SaveRegionHandle = JassCommon["SaveRegionHandle"]
--- <1.24> 保存音效 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), whichSound(sound) | 返回: boolean
cj.SaveSoundHandle = JassCommon["SaveSoundHandle"]
--- <1.24> 保存字符串 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), value(string) | 返回: boolean
cj.SaveStr = JassCommon["SaveStr"]
--- <1.24> 保存漂浮文字 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), whichTexttag(texttag) | 返回: boolean
cj.SaveTextTagHandle = JassCommon["SaveTextTagHandle"]
--- <1.24> 保存计时器窗口 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), whichTimerdialog(timerdialog) | 返回: boolean
cj.SaveTimerDialogHandle = JassCommon["SaveTimerDialogHandle"]
--- <1.24> 保存计时器 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), whichTimer(timer) | 返回: boolean
cj.SaveTimerHandle = JassCommon["SaveTimerHandle"]
--- <1.24> 保存可追踪物 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), whichTrackable(trackable) | 返回: boolean
cj.SaveTrackableHandle = JassCommon["SaveTrackableHandle"]
--- <1.24> 保存触发动作 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), whichTriggeraction(triggeraction) | 返回: boolean
cj.SaveTriggerActionHandle = JassCommon["SaveTriggerActionHandle"]
--- <1.24> 保存触发条件 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), whichTriggercondition(triggercondition) | 返回: boolean
cj.SaveTriggerConditionHandle = JassCommon["SaveTriggerConditionHandle"]
--- <1.24> 保存触发事件 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), whichEvent(event) | 返回: boolean
cj.SaveTriggerEventHandle = JassCommon["SaveTriggerEventHandle"]
--- <1.24> 保存触发器 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), whichTrigger(trigger) | 返回: boolean
cj.SaveTriggerHandle = JassCommon["SaveTriggerHandle"]
--- <1.24> 保存地面纹理变化 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), whichUbersplat(ubersplat) | 返回: boolean
cj.SaveUbersplatHandle = JassCommon["SaveUbersplatHandle"]
--- <1.24> 保存单位 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), whichUnit(unit) | 返回: boolean
cj.SaveUnitHandle = JassCommon["SaveUnitHandle"]
--- <1.24> 保存单位池 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), whichUnitpool(unitpool) | 返回: boolean
cj.SaveUnitPoolHandle = JassCommon["SaveUnitPoolHandle"]
--- 保存控件句柄到哈希表 | 参数: table(hashtable), parentKey(integer), childKey(integer), whichWidget(widget) | 返回: boolean
cj.SaveWidgetHandle = JassCommon["SaveWidgetHandle"]
--- 学习技能 | 参数: whichHero(unit), abilcode(integer)
cj.SelectHeroSkill = JassCommon["SelectHeroSkill"]
--- 选择/取消选择单位 | 参数: whichUnit(unit), flag(boolean)
cj.SelectUnit = JassCommon["SelectUnit"]
--- 限制物品种类(所有市场) | 参数: slots(integer)
cj.SetAllItemTypeSlots = JassCommon["SetAllItemTypeSlots"]
--- 限制单位种类(所有市场) | 参数: slots(integer)
cj.SetAllUnitTypeSlots = JassCommon["SetAllUnitTypeSlots"]
--- 设置联盟颜色显示 | 参数: state(integer)
cj.SetAllyColorFilterState = JassCommon["SetAllyColorFilterState"]
--- 设置小地图特殊标志 | 参数: iconPath(string)
cj.SetAltMinimapIcon = JassCommon["SetAltMinimapIcon"]
--- 创建/删除荒芜地表(圆范围)(指定坐标) [R] | 参数: whichPlayer(player), x(real), y(real), radius(real), addBlight(boolean)
cj.SetBlight = JassCommon["SetBlight"]
--- 设置荒芜(点) | 参数: whichPlayer(player), whichLocation(location), radius(real), addBlight(boolean)
cj.SetBlightLoc = JassCommon["SetBlightLoc"]
--- 设置荒芜(坐标) | 参数: whichPlayer(player), x(real), y(real), addBlight(boolean)
cj.SetBlightPoint = JassCommon["SetBlightPoint"]
--- 创建/删除荒芜地表(矩形区域) [R] | 参数: whichPlayer(player), r(rect), addBlight(boolean)
cj.SetBlightRect = JassCommon["SetBlightRect"]
--- 设置可用镜头区域(所有玩家) [R] | 参数: x1(real), y1(real), x2(real), y2(real), x3(real), y3(real), x4(real), y4(real)
cj.SetCameraBounds = JassCommon["SetCameraBounds"]
--- 设置镜头属性(所有玩家)(限时) [R] | 参数: whichField(camerafield), value(real), duration(real)
cj.SetCameraField = JassCommon["SetCameraField"]
--- 锁定镜头到单位(固定镜头源)(所有玩家) [R] | 参数: whichUnit(unit), xoffset(real), yoffset(real)
cj.SetCameraOrientController = JassCommon["SetCameraOrientController"]
--- 设置镜头位置 | 参数: x(real), y(real)
cj.SetCameraPosition = JassCommon["SetCameraPosition"]
--- 设置空格键转向点(所有玩家) [R] | 参数: x(real), y(real)
cj.SetCameraQuickPosition = JassCommon["SetCameraQuickPosition"]
--- 指定点旋转镜头(所有玩家)(弧度)(限时) [R] | 参数: x(real), y(real), radiansToSweep(real), duration(real)
cj.SetCameraRotateMode = JassCommon["SetCameraRotateMode"]
--- 锁定镜头到单位(所有玩家) [R] | 参数: whichUnit(unit), xoffset(real), yoffset(real), inheritOrientation(boolean)
cj.SetCameraTargetController = JassCommon["SetCameraTargetController"]
--- 设置战役可用性 | 参数: campaignNumber(integer), available(boolean)
cj.SetCampaignAvailable = JassCommon["SetCampaignAvailable"]
--- 设置战役菜单种族 | 参数: r(race)
cj.SetCampaignMenuRace = JassCommon["SetCampaignMenuRace"]
--- 设置战役菜单种族(扩展) | 参数: campaignIndex(integer)
cj.SetCampaignMenuRaceEx = JassCommon["SetCampaignMenuRaceEx"]
--- 设置滤镜混合模式 | 参数: whichMode(blendmode)
cj.SetCineFilterBlendMode = JassCommon["SetCineFilterBlendMode"]
--- 设置滤镜持续时间 | 参数: duration(real)
cj.SetCineFilterDuration = JassCommon["SetCineFilterDuration"]
--- 设置滤镜结束颜色 | 参数: red(integer), green(integer), blue(integer), alpha(integer)
cj.SetCineFilterEndColor = JassCommon["SetCineFilterEndColor"]
--- 设置滤镜结束UV坐标 | 参数: minu(real), minv(real), maxu(real), maxv(real)
cj.SetCineFilterEndUV = JassCommon["SetCineFilterEndUV"]
--- 设置滤镜开始颜色 | 参数: red(integer), green(integer), blue(integer), alpha(integer)
cj.SetCineFilterStartColor = JassCommon["SetCineFilterStartColor"]
--- 设置滤镜开始UV坐标 | 参数: minu(real), minv(real), maxu(real), maxv(real)
cj.SetCineFilterStartUV = JassCommon["SetCineFilterStartUV"]
--- 设置滤镜纹理映射标记 | 参数: whichFlags(texmapflags)
cj.SetCineFilterTexMapFlags = JassCommon["SetCineFilterTexMapFlags"]
--- 设置滤镜纹理 | 参数: filename(string)
cj.SetCineFilterTexture = JassCommon["SetCineFilterTexture"]
--- 播放电影镜头(所有玩家) [R] | 参数: cameraModelFile(string)
cj.SetCinematicCamera = JassCommon["SetCinematicCamera"]
--- 设置电影场景 | 参数: portraitUnitId(integer), color(playercolor), speakerTitle(string), text(string), sceneDuration(real), voiceoverDuration(real)
cj.SetCinematicScene = JassCommon["SetCinematicScene"]
--- 设置怪物密度 | 参数: whichdensity(mapdensity)
cj.SetCreatureDensity = JassCommon["SetCreatureDensity"]
--- 设置小地图中立生物显示 | 参数: state(boolean)
cj.SetCreepCampFilterState = JassCommon["SetCreepCampFilterState"]
--- 设置自定义战役按钮可见 | 参数: whichButton(integer), visible(boolean)
cj.SetCustomCampaignButtonVisible = JassCommon["SetCustomCampaignButtonVisible"]
--- 设置昼夜模型 | 参数: terrainDNCFile(string), unitDNCFile(string)
cj.SetDayNightModels = JassCommon["SetDayNightModels"]
--- 设置默认难度 | 参数: g(gamedifficulty)
cj.SetDefaultDifficulty = JassCommon["SetDefaultDifficulty"]
--- 播放可破坏物动画 | 参数: d(destructable), whichAnimation(string)
cj.SetDestructableAnimation = JassCommon["SetDestructableAnimation"]
--- 改变可破坏物动画播放速度 [R] | 参数: d(destructable), speedFactor(real)
cj.SetDestructableAnimationSpeed = JassCommon["SetDestructableAnimationSpeed"]
--- 设置无敌/可攻击 | 参数: d(destructable), flag(boolean)
cj.SetDestructableInvulnerable = JassCommon["SetDestructableInvulnerable"]
--- 设置生命值(指定值) | 参数: d(destructable), life(real)
cj.SetDestructableLife = JassCommon["SetDestructableLife"]
--- 设置最大生命值 | 参数: d(destructable), max(real)
cj.SetDestructableMaxLife = JassCommon["SetDestructableMaxLife"]
--- 设置闭塞高度 | 参数: d(destructable), height(real)
cj.SetDestructableOccluderHeight = JassCommon["SetDestructableOccluderHeight"]
--- 播放圆范围内地形装饰物动画 [R] | 参数: x(real), y(real), radius(real), doodadID(integer), nearestOnly(boolean), animName(string), animRandom(boolean)
cj.SetDoodadAnimation = JassCommon["SetDoodadAnimation"]
--- 播放矩形区域内地形装饰物动画 [R] | 参数: r(rect), doodadID(integer), animName(string), animRandom(boolean)
cj.SetDoodadAnimationRect = JassCommon["SetDoodadAnimationRect"]
--- 设置编辑器电影可用 | 参数: campaignNumber(integer), available(boolean)
cj.SetEdCinematicAvailable = JassCommon["SetEdCinematicAvailable"]
--- 设置浮点游戏状态值 | 参数: whichFloatGameState(fgamestate), value(real)
cj.SetFloatGameState = JassCommon["SetFloatGameState"]
--- 设置地图迷雾(圆范围) [R] | 参数: forWhichPlayer(player), whichState(fogstate), centerx(real), centerY(real), radius(real), useSharedVision(boolean)
cj.SetFogStateRadius = JassCommon["SetFogStateRadius"]
--- 设置迷雾状态(圆形范围，点) | 参数: forWhichPlayer(player), whichState(fogstate), center(location), radius(real), useSharedVision(boolean)
cj.SetFogStateRadiusLoc = JassCommon["SetFogStateRadiusLoc"]
--- 设置地图迷雾(矩形区域) [R] | 参数: forWhichPlayer(player), whichState(fogstate), where(rect), useSharedVision(boolean)
cj.SetFogStateRect = JassCommon["SetFogStateRect"]
--- 设置游戏难度 [R] | 参数: whichdifficulty(gamedifficulty)
cj.SetGameDifficulty = JassCommon["SetGameDifficulty"]
--- 设置游戏放置方式 | 参数: whichPlacementType(placement)
cj.SetGamePlacement = JassCommon["SetGamePlacement"]
--- 设定游戏速度 | 参数: whichspeed(gamespeed)
cj.SetGameSpeed = JassCommon["SetGameSpeed"]
--- 设置游戏类型支持 | 参数: whichGameType(gametype), value(boolean)
cj.SetGameTypeSupported = JassCommon["SetGameTypeSupported"]
--- 设置英雄敏捷 [R] | 参数: whichHero(unit), newAgi(integer), permanent(boolean)
cj.SetHeroAgi = JassCommon["SetHeroAgi"]
--- 设置英雄智力 [R] | 参数: whichHero(unit), newInt(integer), permanent(boolean)
cj.SetHeroInt = JassCommon["SetHeroInt"]
--- 提升等级 [R] | 参数: whichHero(unit), level(integer), showEyeCandy(boolean)
cj.SetHeroLevel = JassCommon["SetHeroLevel"]
--- 设置英雄力量 [R] | 参数: whichHero(unit), newStr(integer), permanent(boolean)
cj.SetHeroStr = JassCommon["SetHeroStr"]
--- 设置经验值 | 参数: whichHero(unit), newXpVal(integer), showEyeCandy(boolean)
cj.SetHeroXP = JassCommon["SetHeroXP"]
--- 图像水面显示状态 | 参数: whichImage(image), flag(boolean), useWaterAlpha(boolean)
cj.SetImageAboveWater = JassCommon["SetImageAboveWater"]
--- 改变图像颜色 [R] | 参数: whichImage(image), red(integer), green(integer), blue(integer), alpha(integer)
cj.SetImageColor = JassCommon["SetImageColor"]
--- 设置图像高度 | 参数: whichImage(image), flag(boolean), height(real)
cj.SetImageConstantHeight = JassCommon["SetImageConstantHeight"]
--- 改变图像位置(指定坐标) [R] | 参数: whichImage(image), x(real), y(real), z(real)
cj.SetImagePosition = JassCommon["SetImagePosition"]
--- 设置图像渲染状态 | 参数: whichImage(image), flag(boolean)
cj.SetImageRender = JassCommon["SetImageRender"]
--- 设置图像永久渲染状态 | 参数: whichImage(image), flag(boolean)
cj.SetImageRenderAlways = JassCommon["SetImageRenderAlways"]
--- 改变图像类型 | 参数: whichImage(image), imageType(integer)
cj.SetImageType = JassCommon["SetImageType"]
--- 设置整数游戏状态值 | 参数: whichIntegerGameState(igamestate), value(integer)
cj.SetIntegerGameState = JassCommon["SetIntegerGameState"]
--- 设置介绍画面模型 | 参数: introModelPath(string)
cj.SetIntroShotModel = JassCommon["SetIntroShotModel"]
--- 设置介绍画面文本 | 参数: introText(string)
cj.SetIntroShotText = JassCommon["SetIntroShotText"]
--- 设置物品使用次数 | 参数: whichItem(item), charges(integer)
cj.SetItemCharges = JassCommon["SetItemCharges"]
--- 设置重生神符的产生单位类型 | 参数: whichItem(item), unitId(integer)
cj.SetItemDropID = JassCommon["SetItemDropID"]
--- 设置物品死亡是否掉落 | 参数: whichItem(item), flag(boolean)
cj.SetItemDropOnDeath = JassCommon["SetItemDropOnDeath"]
--- 设置物品可否丢弃 | 参数: i(item), flag(boolean)
cj.SetItemDroppable = JassCommon["SetItemDroppable"]
--- 设置物品无敌/可攻击 | 参数: whichItem(item), flag(boolean)
cj.SetItemInvulnerable = JassCommon["SetItemInvulnerable"]
--- 设置物品可否抵押 | 参数: i(item), flag(boolean)
cj.SetItemPawnable = JassCommon["SetItemPawnable"]
--- 改变物品所属玩家 | 参数: whichItem(item), whichPlayer(player), changeColor(boolean)
cj.SetItemPlayer = JassCommon["SetItemPlayer"]
--- 移动物品到坐标(立即)(指定坐标) [R] | 参数: i(item), x(real), y(real)
cj.SetItemPosition = JassCommon["SetItemPosition"]
--- 限制物品种类(指定市场) | 参数: whichUnit(unit), slots(integer)
cj.SetItemTypeSlots = JassCommon["SetItemTypeSlots"]
--- 设置物品自定义值 | 参数: whichItem(item), data(integer)
cj.SetItemUserData = JassCommon["SetItemUserData"]
--- 显示/隐藏 [R] | 参数: whichItem(item), show(boolean)
cj.SetItemVisible = JassCommon["SetItemVisible"]
--- 改变闪电效果颜色 | 参数: whichBolt(lightning), r(real), g(real), b(real), a(real) | 返回: boolean
cj.SetLightningColor = JassCommon["SetLightningColor"]
--- 设置地图描述 | 参数: description(string)
cj.SetMapDescription = JassCommon["SetMapDescription"]
--- 设置地图参数 | 参数: whichMapFlag(mapflag), value(boolean)
cj.SetMapFlag = JassCommon["SetMapFlag"]
--- 设置背景音乐列表 [R] | 参数: musicName(string), random(boolean), index(integer)
cj.SetMapMusic = JassCommon["SetMapMusic"]
--- 设置地图名称 | 参数: name(string)
cj.SetMapName = JassCommon["SetMapName"]
--- 设置任务可用 | 参数: campaignNumber(integer), missionNumber(integer), available(boolean)
cj.SetMissionAvailable = JassCommon["SetMissionAvailable"]
--- 设置背景音乐播放时间点 [R] | 参数: millisecs(integer)
cj.SetMusicPlayPosition = JassCommon["SetMusicPlayPosition"]
--- 设置背景音乐音量 [R] | 参数: volume(integer)
cj.SetMusicVolume = JassCommon["SetMusicVolume"]
--- 设置过场电影可用 | 参数: campaignNumber(integer), available(boolean)
cj.SetOpCinematicAvailable = JassCommon["SetOpCinematicAvailable"]
--- 允许/禁用 技能 [R] | 参数: whichPlayer(player), abilid(integer), avail(boolean)
cj.SetPlayerAbilityAvailable = JassCommon["SetPlayerAbilityAvailable"]
--- 设置联盟状态(指定项目) [R] | 参数: sourcePlayer(player), otherPlayer(player), whichAllianceSetting(alliancetype), value(boolean)
cj.SetPlayerAlliance = JassCommon["SetPlayerAlliance"]
--- 改变玩家颜色 [R] | 参数: whichPlayer(player), color(playercolor)
cj.SetPlayerColor = JassCommon["SetPlayerColor"]
--- 设置玩家控制类型 | 参数: whichPlayer(player), controlType(mapcontrol)
cj.SetPlayerController = JassCommon["SetPlayerController"]
--- 设置生命上限 [R] | 参数: whichPlayer(player), handicap(real)
cj.SetPlayerHandicap = JassCommon["SetPlayerHandicap"]
--- 设置经验获得率 [R] | 参数: whichPlayer(player), handicap(real)
cj.SetPlayerHandicapXP = JassCommon["SetPlayerHandicapXP"]
--- 更改名字 | 参数: whichPlayer(player), name(string)
cj.SetPlayerName = JassCommon["SetPlayerName"]
--- 显示/隐藏计分屏显示 [R] | 参数: whichPlayer(player), flag(boolean)
cj.SetPlayerOnScoreScreen = JassCommon["SetPlayerOnScoreScreen"]
--- 设置玩家种族偏好 | 参数: whichPlayer(player), whichRacePreference(racepreference)
cj.SetPlayerRacePreference = JassCommon["SetPlayerRacePreference"]
--- 设置玩家种族是否可选 | 参数: whichPlayer(player), value(boolean)
cj.SetPlayerRaceSelectable = JassCommon["SetPlayerRaceSelectable"]
--- 设置玩家起始位置 | 参数: whichPlayer(player), startLocIndex(integer)
cj.SetPlayerStartLocation = JassCommon["SetPlayerStartLocation"]
--- 设置属性 | 参数: whichPlayer(player), whichPlayerState(playerstate), value(integer)
cj.SetPlayerState = JassCommon["SetPlayerState"]
--- 设置税率 [R] | 参数: sourcePlayer(player), otherPlayer(player), whichResource(playerstate), rate(integer)
cj.SetPlayerTaxRate = JassCommon["SetPlayerTaxRate"]
--- 设置玩家队伍 | 参数: whichPlayer(player), whichTeam(integer)
cj.SetPlayerTeam = JassCommon["SetPlayerTeam"]
--- 设置玩家科技最大等级 | 参数: whichPlayer(player), techid(integer), maximum(integer)
cj.SetPlayerTechMaxAllowed = JassCommon["SetPlayerTechMaxAllowed"]
--- 设置玩家科技等级 | 参数: whichPlayer(player), techid(integer), setToLevel(integer)
cj.SetPlayerTechResearched = JassCommon["SetPlayerTechResearched"]
--- 转移玩家单位所有权 | 参数: whichPlayer(player), newOwner(integer)
cj.SetPlayerUnitsOwner = JassCommon["SetPlayerUnitsOwner"]
--- 设置玩家数量 | 参数: playercount(integer)
cj.SetPlayers = JassCommon["SetPlayers"]
--- 设置随机种子 | 参数: seed(integer)
cj.SetRandomSeed = JassCommon["SetRandomSeed"]
--- 设置矩形区域(指定坐标) [R] | 参数: whichRect(rect), minx(real), miny(real), maxx(real), maxy(real)
cj.SetRect = JassCommon["SetRect"]
--- 设置矩形区域(指定点) [R] | 参数: whichRect(rect), min(location), max(location)
cj.SetRectFromLoc = JassCommon["SetRectFromLoc"]
--- 保留英雄图标 | 参数: reserved(integer)
cj.SetReservedLocalHeroButtons = JassCommon["SetReservedLocalHeroButtons"]
--- 设置黄金储量 | 参数: whichUnit(unit), amount(integer)
cj.SetResourceAmount = JassCommon["SetResourceAmount"]
--- 设置资源密度 | 参数: whichdensity(mapdensity)
cj.SetResourceDensity = JassCommon["SetResourceDensity"]
--- 设置天空 | 参数: skyModelFile(string)
cj.SetSkyModel = JassCommon["SetSkyModel"]
--- 设置声音的声道 [new] | 参数: soundHandle(sound), channel(integer)
cj.SetSoundChannel = JassCommon["SetSoundChannel"]
--- 设置声音的角度 [new] | 参数: soundHandle(sound), inside(real), outside(real), outsideVolume(integer)
cj.SetSoundConeAngles = JassCommon["SetSoundConeAngles"]
--- 设置声音的传播方向 [new] | 参数: soundHandle(sound), x(real), y(real), z(real)
cj.SetSoundConeOrientation = JassCommon["SetSoundConeOrientation"]
--- 设置声音截断距离 | 参数: soundHandle(sound), cutoff(real)
cj.SetSoundDistanceCutoff = JassCommon["SetSoundDistanceCutoff"]
--- 设置3D音效衰减范围 | 参数: soundHandle(sound), minDist(real), maxDist(real)
cj.SetSoundDistances = JassCommon["SetSoundDistances"]
--- 设置声音时长 | 参数: soundHandle(sound), duration(integer)
cj.SetSoundDuration = JassCommon["SetSoundDuration"]
--- 设置声音标签 [new] | 参数: soundHandle(sound), soundLabel(string)
cj.SetSoundParamsFromLabel = JassCommon["SetSoundParamsFromLabel"]
--- 设置声音速率 | 参数: soundHandle(sound), pitch(real)
cj.SetSoundPitch = JassCommon["SetSoundPitch"]
--- 设置音效播放时间点 [R] | 参数: soundHandle(sound), millisecs(integer)
cj.SetSoundPlayPosition = JassCommon["SetSoundPlayPosition"]
--- 设置3D音效位置(指定坐标) [R] | 参数: soundHandle(sound), x(real), y(real), z(real)
cj.SetSoundPosition = JassCommon["SetSoundPosition"]
--- 设置声音的速度 [new] | 参数: soundHandle(sound), x(real), y(real), z(real)
cj.SetSoundVelocity = JassCommon["SetSoundVelocity"]
--- 设置音效音量 [R] | 参数: soundHandle(sound), volume(integer)
cj.SetSoundVolume = JassCommon["SetSoundVolume"]
--- 设置起始位置优先级 | 参数: whichStartLoc(integer), prioSlotIndex(integer), otherStartLocIndex(integer), priority(startlocprio)
cj.SetStartLocPrio = JassCommon["SetStartLocPrio"]
--- 设置起始位置优先级数量 | 参数: whichStartLoc(integer), prioSlotCount(integer)
cj.SetStartLocPrioCount = JassCommon["SetStartLocPrioCount"]
--- 设置队伍数量 | 参数: teamcount(integer)
cj.SetTeams = JassCommon["SetTeams"]
--- 设置地形迷雾 | 参数: a(real), b(real), c(real), d(real), e(real)
cj.SetTerrainFog = JassCommon["SetTerrainFog"]
--- 设置迷雾 [R] | 参数: style(integer), zstart(real), zend(real), density(real), red(real), green(real), blue(real)
cj.SetTerrainFogEx = JassCommon["SetTerrainFogEx"]
--- 设置地形通行状态(指定坐标) [R] | 参数: x(real), y(real), t(pathingtype), flag(boolean)
cj.SetTerrainPathable = JassCommon["SetTerrainPathable"]
--- 改变地形类型(指定坐标) [R] | 参数: x(real), y(real), terrainType(integer), variation(integer), area(integer), shape(integer)
cj.SetTerrainType = JassCommon["SetTerrainType"]
--- 设置已存在时间 | 参数: t(texttag), age(real)
cj.SetTextTagAge = JassCommon["SetTextTagAge"]
--- 改变颜色 [R] | 参数: t(texttag), red(integer), green(integer), blue(integer), alpha(integer)
cj.SetTextTagColor = JassCommon["SetTextTagColor"]
--- 设置消逝时间点 | 参数: t(texttag), fadepoint(real)
cj.SetTextTagFadepoint = JassCommon["SetTextTagFadepoint"]
--- 设置显示时间 | 参数: t(texttag), lifespan(real)
cj.SetTextTagLifespan = JassCommon["SetTextTagLifespan"]
--- 设置永久显示 | 参数: t(texttag), flag(boolean)
cj.SetTextTagPermanent = JassCommon["SetTextTagPermanent"]
--- 改变位置(坐标) [R] | 参数: t(texttag), x(real), y(real), heightOffset(real)
cj.SetTextTagPos = JassCommon["SetTextTagPos"]
--- 改变位置(单位) | 参数: t(texttag), whichUnit(unit), heightOffset(real)
cj.SetTextTagPosUnit = JassCommon["SetTextTagPosUnit"]
--- 暂停/恢复 | 参数: t(texttag), flag(boolean)
cj.SetTextTagSuspended = JassCommon["SetTextTagSuspended"]
--- 改变文字内容 [R] | 参数: t(texttag), s(string), height(real)
cj.SetTextTagText = JassCommon["SetTextTagText"]
--- 设置速率 [R] | 参数: t(texttag), xvel(real), yvel(real)
cj.SetTextTagVelocity = JassCommon["SetTextTagVelocity"]
--- 显示/隐藏 (所有玩家) [R] | 参数: t(texttag), flag(boolean)
cj.SetTextTagVisibility = JassCommon["SetTextTagVisibility"]
--- 设置主题音乐播放时间点 [R] | 参数: millisecs(integer)
cj.SetThematicMusicPlayPosition = JassCommon["SetThematicMusicPlayPosition"]
--- 设置昼夜时间流逝速度 [R] | 参数: r(real)
cj.SetTimeOfDayScale = JassCommon["SetTimeOfDayScale"]
--- 设置教程已完成 | 参数: cleared(boolean)
cj.SetTutorialCleared = JassCommon["SetTutorialCleared"]
--- 设置渲染状态 | 参数: whichSplat(ubersplat), flag(boolean)
cj.SetUbersplatRender = JassCommon["SetUbersplatRender"]
--- 设置永久渲染状态 | 参数: whichSplat(ubersplat), flag(boolean)
cj.SetUbersplatRenderAlways = JassCommon["SetUbersplatRenderAlways"]
--- 设置技能等级 [R] | 参数: whichUnit(unit), abilcode(integer), level(integer) | 返回: integer
cj.SetUnitAbilityLevel = JassCommon["SetUnitAbilityLevel"]
--- 设置主动攻击范围 | 参数: whichUnit(unit), newAcquireRange(real)
cj.SetUnitAcquireRange = JassCommon["SetUnitAcquireRange"]
--- 播放单位动画 | 参数: whichUnit(unit), whichAnimation(string)
cj.SetUnitAnimation = JassCommon["SetUnitAnimation"]
--- 播放单位指定序号动动作 [R] | 参数: whichUnit(unit), whichAnimation(integer)
cj.SetUnitAnimationByIndex = JassCommon["SetUnitAnimationByIndex"]
--- 播放单位动运作(指定概率) | 参数: whichUnit(unit), whichAnimation(string), rarity(raritycontrol)
cj.SetUnitAnimationWithRarity = JassCommon["SetUnitAnimationWithRarity"]
--- 改变单位混合时间 | 参数: whichUnit(unit), blendTime(real)
cj.SetUnitBlendTime = JassCommon["SetUnitBlendTime"]
--- 改变队伍颜色 | 参数: whichUnit(unit), whichColor(playercolor)
cj.SetUnitColor = JassCommon["SetUnitColor"]
--- 锁定指定单位的警戒点 [R] | 参数: whichUnit(unit), creepGuard(boolean)
cj.SetUnitCreepGuard = JassCommon["SetUnitCreepGuard"]
--- 设置死亡方式 | 参数: whichUnit(unit), exploded(boolean)
cj.SetUnitExploded = JassCommon["SetUnitExploded"]
--- 设置单位面向角度 [R] | 参数: whichUnit(unit), facingAngle(real)
cj.SetUnitFacing = JassCommon["SetUnitFacing"]
--- 设置单位面向角度(指定时间) | 参数: whichUnit(unit), facingAngle(real), duration(real)
cj.SetUnitFacingTimed = JassCommon["SetUnitFacingTimed"]
--- 改变单位飞行高度 | 参数: whichUnit(unit), newHeight(real), rate(real)
cj.SetUnitFlyHeight = JassCommon["SetUnitFlyHeight"]
--- 设置单位迷雾 | 参数: a(real), b(real), c(real), d(real), e(real)
cj.SetUnitFog = JassCommon["SetUnitFog"]
--- 设置无敌/可攻击 | 参数: whichUnit(unit), flag(boolean)
cj.SetUnitInvulnerable = JassCommon["SetUnitInvulnerable"]
--- 锁定身体朝向 | 参数: whichUnit(unit), whichBone(string), lookAtTarget(unit), offsetX(real), offsetY(real), offsetZ(real)
cj.SetUnitLookAt = JassCommon["SetUnitLookAt"]
--- 设置移动速度 | 参数: whichUnit(unit), newSpeed(real)
cj.SetUnitMoveSpeed = JassCommon["SetUnitMoveSpeed"]
--- 改变所属 | 参数: whichUnit(unit), whichPlayer(player), changeColor(boolean)
cj.SetUnitOwner = JassCommon["SetUnitOwner"]
--- 设置碰撞开关 | 参数: whichUnit(unit), flag(boolean)
cj.SetUnitPathing = JassCommon["SetUnitPathing"]
--- 移动单位(立即)(指定坐标) [R] | 参数: whichUnit(unit), newX(real), newY(real)
cj.SetUnitPosition = JassCommon["SetUnitPosition"]
--- 移动单位(立即)(指定点) | 参数: whichUnit(unit), whichLocation(location)
cj.SetUnitPositionLoc = JassCommon["SetUnitPositionLoc"]
--- 改变单位转向角度(弧度制) [R] | 参数: whichUnit(unit), newPropWindowAngle(real)
cj.SetUnitPropWindow = JassCommon["SetUnitPropWindow"]
--- 设置可否营救(对玩家) [R] | 参数: whichUnit(unit), byWhichPlayer(player), flag(boolean)
cj.SetUnitRescuable = JassCommon["SetUnitRescuable"]
--- 设置营救范围 | 参数: whichUnit(unit), range(real)
cj.SetUnitRescueRange = JassCommon["SetUnitRescueRange"]
--- 改变单位尺寸(按倍数) [R] | 参数: whichUnit(unit), scaleX(real), scaleY(real), scaleZ(real)
cj.SetUnitScale = JassCommon["SetUnitScale"]
--- 设置单位属性 [R] | 参数: whichUnit(unit), whichUnitState(unitstate), newVal(real)
cj.SetUnitState = JassJapi["SetUnitState"]
--- 改变单位动画播放速度(按倍数) [R] | 参数: whichUnit(unit), timeScale(real)
cj.SetUnitTimeScale = JassCommon["SetUnitTimeScale"]
--- 改变单位转身速度 | 参数: whichUnit(unit), newTurnSpeed(real)
cj.SetUnitTurnSpeed = JassCommon["SetUnitTurnSpeed"]
--- 限制单位种类(指定市场) | 参数: whichUnit(unit), slots(integer)
cj.SetUnitTypeSlots = JassCommon["SetUnitTypeSlots"]
--- 允许/禁止 人口占用 [R] | 参数: whichUnit(unit), useFood(boolean)
cj.SetUnitUseFood = JassCommon["SetUnitUseFood"]
--- 设置自定义值 | 参数: whichUnit(unit), data(integer)
cj.SetUnitUserData = JassCommon["SetUnitUserData"]
--- 改变单位的颜色(RGB:0-255) [R] | 参数: whichUnit(unit), red(integer), green(integer), blue(integer), alpha(integer)
cj.SetUnitVertexColor = JassCommon["SetUnitVertexColor"]
--- 设置X坐标 [R] | 参数: whichUnit(unit), newX(real)
cj.SetUnitX = JassCommon["SetUnitX"]
--- 设置Y坐标 [R] | 参数: whichUnit(unit), newY(real)
cj.SetUnitY = JassCommon["SetUnitY"]
--- 设置水颜色 [R] | 参数: red(integer), green(integer), blue(integer), alpha(integer)
cj.SetWaterBaseColor = JassCommon["SetWaterBaseColor"]
--- 开启/关闭 水面变形 | 参数: val(boolean)
cj.SetWaterDeforms = JassCommon["SetWaterDeforms"]
--- 设置物品生命值 | 参数: whichWidget(widget), newLife(real)
cj.SetWidgetLife = JassCommon["SetWidgetLife"]
--- 显示/隐藏 [R] | 参数: d(destructable), flag(boolean)
cj.ShowDestructable = JassCommon["ShowDestructable"]
--- 显示/隐藏 [R] | 参数: whichImage(image), flag(boolean)
cj.ShowImage = JassCommon["ShowImage"]
--- 开启/关闭 信箱模式(所有玩家) [R] | 参数: flag(boolean), fadeDuration(real)
cj.ShowInterface = JassCommon["ShowInterface"]
--- 显示/隐藏 地面纹理变化[R] | 参数: whichSplat(ubersplat), flag(boolean)
cj.ShowUbersplat = JassCommon["ShowUbersplat"]
--- 显示/隐藏 [R] | 参数: whichUnit(unit), show(boolean)
cj.ShowUnit = JassCommon["ShowUnit"]
--- 正弦(弧度) [R] | 参数: radians(real) | 返回: real
cj.Sin = JassCommon["Sin"]
--- 平方根 | 参数: x(real) | 返回: real
cj.SquareRoot = JassCommon["SquareRoot"]
--- 启用战役AI | 参数: num(player), script(string)
cj.StartCampaignAI = JassCommon["StartCampaignAI"]
--- 启用对战AI | 参数: num(player), script(string)
cj.StartMeleeAI = JassCommon["StartMeleeAI"]
--- 播放声音 | 参数: soundHandle(sound)
cj.StartSound = JassCommon["StartSound"]
--- 停止播放镜头(所有玩家) [R]
cj.StopCamera = JassCommon["StopCamera"]
--- 停止背景音乐 | 参数: fadeOut(boolean)
cj.StopMusic = JassCommon["StopMusic"]
--- 停止声音 | 参数: soundHandle(sound), killWhenDone(boolean), fadeOut(boolean)
cj.StopSound = JassCommon["StopSound"]
--- 记录布尔值 | 参数: cache(gamecache), missionKey(string), key(string), value(boolean)
cj.StoreBoolean = JassCommon["StoreBoolean"]
--- 记录整数 | 参数: cache(gamecache), missionKey(string), key(string), value(integer)
cj.StoreInteger = JassCommon["StoreInteger"]
--- 记录实数 | 参数: cache(gamecache), missionKey(string), key(string), value(real)
cj.StoreReal = JassCommon["StoreReal"]
--- 记录字符串 | 参数: cache(gamecache), missionKey(string), key(string), value(string) | 返回: boolean
cj.StoreString = JassCommon["StoreString"]
--- 存储单位到游戏缓存 | 参数: cache(gamecache), missionKey(string), key(string), whichUnit(unit) | 返回: boolean
cj.StoreUnit = JassCommon["StoreUnit"]
--- 大小写转换 | 参数: source(string), upper(boolean) | 返回: string
cj.StringCase = JassCommon["StringCase"]
--- 获取字符串的哈希值 | 参数: s(string) | 返回: integer
cj.StringHash = JassCommon["StringHash"]
--- 自定义代码 [C] | 参数: s(string) | 返回: integer
cj.StringLength = JassCommon["StringLength"]
--- 截取字符串 [R] | 参数: source(string), start(integer), end(integer) | 返回: string
cj.SubString = JassCommon["SubString"]
--- 允许/禁止经验获取 [R] | 参数: whichHero(unit), flag(boolean)
cj.SuspendHeroXP = JassCommon["SuspendHeroXP"]
--- 暂停/恢复昼夜更替 | 参数: b(boolean)
cj.SuspendTimeOfDay = JassCommon["SuspendTimeOfDay"]
--- SyncSelections
cj.SyncSelections = JassCommon["SyncSelections"]
--- 同步游戏缓存的布尔值 | 参数: cache(gamecache), missionKey(string), key(string)
cj.SyncStoredBoolean = JassCommon["SyncStoredBoolean"]
--- 同步游戏缓存的整数 | 参数: cache(gamecache), missionKey(string), key(string)
cj.SyncStoredInteger = JassCommon["SyncStoredInteger"]
--- 同步游戏缓存的实数 | 参数: cache(gamecache), missionKey(string), key(string)
cj.SyncStoredReal = JassCommon["SyncStoredReal"]
--- 同步游戏缓存的字符串 | 参数: cache(gamecache), missionKey(string), key(string)
cj.SyncStoredString = JassCommon["SyncStoredString"]
--- 同步游戏缓存的单位 | 参数: cache(gamecache), missionKey(string), key(string)
cj.SyncStoredUnit = JassCommon["SyncStoredUnit"]
--- 正切(弧度) [R] | 参数: radians(real) | 返回: real
cj.Tan = JassCommon["Tan"]
--- 新建地形变化:弹坑 [R] | 参数: x(real), y(real), radius(real), depth(real), duration(integer), permanent(boolean) | 返回: terraindeformation
cj.TerrainDeformCrater = JassCommon["TerrainDeformCrater"]
--- 新建地形变化:随机 [R] | 参数: x(real), y(real), radius(real), minDelta(real), maxDelta(real), duration(integer), updateInterval(integer) | 返回: terraindeformation
cj.TerrainDeformRandom = JassCommon["TerrainDeformRandom"]
--- 新建地形变化:波纹 [R] | 参数: x(real), y(real), radius(real), depth(real), duration(integer), count(integer), spaceWaves(real), timeWaves(real), radiusStartPct(real), limitNeg(boolean) | 返回: terraindeformation
cj.TerrainDeformRipple = JassCommon["TerrainDeformRipple"]
--- 停止地形变化 [R] | 参数: deformation(terraindeformation), duration(integer)
cj.TerrainDeformStop = JassCommon["TerrainDeformStop"]
--- 停止所有地形变化
cj.TerrainDeformStopAll = JassCommon["TerrainDeformStopAll"]
--- 新建地形变化:冲击波 [R] | 参数: x(real), y(real), dirX(real), dirY(real), distance(real), speed(real), radius(real), depth(real), trailTime(integer), count(integer) | 返回: terraindeformation
cj.TerrainDeformWave = JassCommon["TerrainDeformWave"]
--- 显示/隐藏 计时器窗口(所有玩家) [R] | 参数: whichDialog(timerdialog), display(boolean)
cj.TimerDialogDisplay = JassCommon["TimerDialogDisplay"]
--- 设置计时器窗口剩余时间(实数) | 参数: whichDialog(timerdialog), timeRemaining(real)
cj.TimerDialogSetRealTimeRemaining = JassCommon["TimerDialogSetRealTimeRemaining"]
--- 设置计时器窗口速率 [R] | 参数: whichDialog(timerdialog), speedMultFactor(real)
cj.TimerDialogSetSpeed = JassCommon["TimerDialogSetSpeed"]
--- 改变计时器窗口计时颜色 [R] | 参数: whichDialog(timerdialog), red(integer), green(integer), blue(integer), alpha(integer)
cj.TimerDialogSetTimeColor = JassCommon["TimerDialogSetTimeColor"]
--- 改变计时器窗口标题 | 参数: whichDialog(timerdialog), title(string)
cj.TimerDialogSetTitle = JassCommon["TimerDialogSetTitle"]
--- 改变计时器窗口文字颜色 [R] | 参数: whichDialog(timerdialog), red(integer), green(integer), blue(integer), alpha(integer)
cj.TimerDialogSetTitleColor = JassCommon["TimerDialogSetTitleColor"]
--- 逝去时间 | 参数: whichTimer(timer) | 返回: real
cj.TimerGetElapsed = JassCommon["TimerGetElapsed"]
--- 剩余时间 | 参数: whichTimer(timer) | 返回: real
cj.TimerGetRemaining = JassCommon["TimerGetRemaining"]
--- 设置时间 | 参数: whichTimer(timer) | 返回: real
cj.TimerGetTimeout = JassCommon["TimerGetTimeout"]
--- 运行计时器 [C] | 参数: whichTimer(timer), timeout(real), periodic(boolean), handlerFunc(code)
cj.TimerStart = JassCommon["TimerStart"]
--- 触发器添加动作 | 参数: whichTrigger(trigger), actionFunc(code) | 返回: triggeraction
cj.TriggerAddAction = JassCommon["TriggerAddAction"]
--- 触发器添加条件 | 参数: whichTrigger(trigger), condition(boolexpr) | 返回: triggercondition
cj.TriggerAddCondition = JassCommon["TriggerAddCondition"]
--- 清除触发器的所有动作 | 参数: whichTrigger(trigger)
cj.TriggerClearActions = JassCommon["TriggerClearActions"]
--- 清除触发器的所有条件 | 参数: whichTrigger(trigger)
cj.TriggerClearConditions = JassCommon["TriggerClearConditions"]
--- 触发条件成立 | 参数: whichTrigger(trigger) | 返回: boolean
cj.TriggerEvaluate = JassCommon["TriggerEvaluate"]
--- 运行触发(无视条件) | 参数: whichTrigger(trigger)
cj.TriggerExecute = JassCommon["TriggerExecute"]
--- 等待触发器执行完毕 | 参数: whichTrigger(trigger)
cj.TriggerExecuteWait = JassCommon["TriggerExecuteWait"]
--- 可破坏物死亡事件 | 参数: whichTrigger(trigger), whichWidget(widget) | 返回: event
cj.TriggerRegisterDeathEvent = JassCommon["TriggerRegisterDeathEvent"]
--- 对话框按钮被点击 [R] | 参数: whichTrigger(trigger), whichButton(button) | 返回: event
cj.TriggerRegisterDialogButtonEvent = JassCommon["TriggerRegisterDialogButtonEvent"]
--- 对话框被点击 | 参数: whichTrigger(trigger), whichDialog(dialog) | 返回: event
cj.TriggerRegisterDialogEvent = JassCommon["TriggerRegisterDialogEvent"]
--- 单位进入不规则区域(指定条件) [R] | 参数: whichTrigger(trigger), whichRegion(region), filter(boolexpr) | 返回: event
cj.TriggerRegisterEnterRegion = JassCommon["TriggerRegisterEnterRegion"]
--- 注册单位过滤事件 | 参数: whichTrigger(trigger), whichUnit(unit), whichEvent(unitevent), filter(boolexpr) | 返回: event
cj.TriggerRegisterFilterUnitEvent = JassCommon["TriggerRegisterFilterUnitEvent"]
--- 比赛游戏事件 | 参数: whichTrigger(trigger), whichGameEvent(gameevent) | 返回: event
cj.TriggerRegisterGameEvent = JassCommon["TriggerRegisterGameEvent"]
--- 注册游戏状态事件 | 参数: whichTrigger(trigger), whichState(gamestate), opcode(limitop), limitval(real) | 返回: event
cj.TriggerRegisterGameStateEvent = JassCommon["TriggerRegisterGameStateEvent"]
--- 单位离开不规则区域(指定条件) [R] | 参数: whichTrigger(trigger), whichRegion(region), filter(boolexpr) | 返回: event
cj.TriggerRegisterLeaveRegion = JassCommon["TriggerRegisterLeaveRegion"]
--- 联盟状态更改(指定项目) | 参数: whichTrigger(trigger), whichPlayer(player), whichAlliance(alliancetype) | 返回: event
cj.TriggerRegisterPlayerAllianceChange = JassCommon["TriggerRegisterPlayerAllianceChange"]
--- 输入聊天信息 | 参数: whichTrigger(trigger), whichPlayer(player), chatMessageToDetect(string), exactMatchOnly(boolean) | 返回: event
cj.TriggerRegisterPlayerChatEvent = JassCommon["TriggerRegisterPlayerChatEvent"]
--- 注册玩家事件 | 参数: whichTrigger(trigger), whichPlayer(player), whichPlayerEvent(playerevent) | 返回: event
cj.TriggerRegisterPlayerEvent = JassCommon["TriggerRegisterPlayerEvent"]
--- 属性事件 | 参数: whichTrigger(trigger), whichPlayer(player), whichState(playerstate), opcode(limitop), limitval(real) | 返回: event
cj.TriggerRegisterPlayerStateEvent = JassCommon["TriggerRegisterPlayerStateEvent"]
--- 注册玩家单位事件 | 参数: whichTrigger(trigger), whichPlayer(player), whichPlayerUnitEvent(playerunitevent), filter(boolexpr) | 返回: event
cj.TriggerRegisterPlayerUnitEvent = JassCommon["TriggerRegisterPlayerUnitEvent"]
--- 注册定时器事件 | 参数: whichTrigger(trigger), timeout(real), periodic(boolean) | 返回: event
cj.TriggerRegisterTimerEvent = JassCommon["TriggerRegisterTimerEvent"]
--- 计时器到期 | 参数: whichTrigger(trigger), t(timer) | 返回: event
cj.TriggerRegisterTimerExpireEvent = JassCommon["TriggerRegisterTimerExpireEvent"]
--- 鼠标点击可追踪物 [R] | 参数: whichTrigger(trigger), t(trackable) | 返回: event
cj.TriggerRegisterTrackableHitEvent = JassCommon["TriggerRegisterTrackableHitEvent"]
--- 鼠标移动到追踪对象 [R] | 参数: whichTrigger(trigger), t(trackable) | 返回: event
cj.TriggerRegisterTrackableTrackEvent = JassCommon["TriggerRegisterTrackableTrackEvent"]
--- 指定单位事件 | 参数: whichTrigger(trigger), whichUnit(unit), whichEvent(unitevent) | 返回: event
cj.TriggerRegisterUnitEvent = JassCommon["TriggerRegisterUnitEvent"]
--- 注册单位进入范围事件 | 参数: whichTrigger(trigger), whichUnit(unit), range(real), filter(boolexpr) | 返回: event
cj.TriggerRegisterUnitInRange = JassCommon["TriggerRegisterUnitInRange"]
--- 注册单位状态事件 | 参数: whichTrigger(trigger), whichUnit(unit), whichState(unitstate), opcode(limitop), limitval(real) | 返回: event
cj.TriggerRegisterUnitStateEvent = JassCommon["TriggerRegisterUnitStateEvent"]
--- 实数变量事件 | 参数: whichTrigger(trigger), varName(string), opcode(limitop), limitval(real) | 返回: event
cj.TriggerRegisterVariableEvent = JassCommon["TriggerRegisterVariableEvent"]
--- 移除触发器动作 | 参数: whichTrigger(trigger), whichAction(triggeraction)
cj.TriggerRemoveAction = JassCommon["TriggerRemoveAction"]
--- 移除触发器条件 | 参数: whichTrigger(trigger), whichCondition(triggercondition)
cj.TriggerRemoveCondition = JassCommon["TriggerRemoveCondition"]
--- 等待(玩家时间) | 参数: timeout(real)
cj.TriggerSleepAction = JassCommon["TriggerSleepAction"]
--- TriggerSyncReady
cj.TriggerSyncReady = JassCommon["TriggerSyncReady"]
--- TriggerSyncStart
cj.TriggerSyncStart = JassCommon["TriggerSyncStart"]
--- 等待(声音结束) | 参数: s(sound), offset(real)
cj.TriggerWaitForSound = JassCommon["TriggerWaitForSound"]
--- 设置触发器等待睡眠模式 | 参数: whichTrigger(trigger), flag(boolean)
cj.TriggerWaitOnSleeps = JassCommon["TriggerWaitOnSleeps"]
--- 添加技能 [R] | 参数: whichUnit(unit), abilityId(integer) | 返回: boolean
cj.UnitAddAbility = JassCommon["UnitAddAbility"]
--- 闪动指示器(对单位) [R] | 参数: whichUnit(unit), red(integer), green(integer), blue(integer), alpha(integer)
cj.UnitAddIndicator = JassCommon["UnitAddIndicator"]
--- 给予物品 [R] | 参数: whichUnit(unit), whichItem(item) | 返回: boolean
cj.UnitAddItem = JassCommon["UnitAddItem"]
--- 单位获得指定ID的物品 | 参数: whichUnit(unit), itemId(integer) | 返回: item
cj.UnitAddItemById = JassCommon["UnitAddItemById"]
--- 新建物品到指定物品栏 [R] | 参数: whichUnit(unit), itemId(integer), itemSlot(integer) | 返回: boolean
cj.UnitAddItemToSlotById = JassCommon["UnitAddItemToSlotById"]
--- 设置单位夜晚睡眠 | 参数: whichUnit(unit), add(boolean)
cj.UnitAddSleep = JassCommon["UnitAddSleep"]
--- 控制单位睡眠状态 | 参数: whichUnit(unit), add(boolean)
cj.UnitAddSleepPerm = JassCommon["UnitAddSleepPerm"]
--- 添加类别 [R] | 参数: whichUnit(unit), whichUnitType(unittype) | 返回: boolean
cj.UnitAddType = JassCommon["UnitAddType"]
--- 设置生命周期 [R] | 参数: whichUnit(unit), buffId(integer), duration(real)
cj.UnitApplyTimedLife = JassCommon["UnitApplyTimedLife"]
--- 允许夜晚睡眠 | 参数: whichUnit(unit) | 返回: boolean
cj.UnitCanSleep = JassCommon["UnitCanSleep"]
--- 允许控制睡眠状态 | 参数: whichUnit(unit) | 返回: boolean
cj.UnitCanSleepPerm = JassCommon["UnitCanSleepPerm"]
--- 拥有Buff数量 [R] | 参数: whichUnit(unit), removePositive(boolean), removeNegative(boolean), magic(boolean), physical(boolean), timedLife(boolean), aura(boolean), autoDispel(boolean) | 返回: integer
cj.UnitCountBuffsEx = JassCommon["UnitCountBuffsEx"]
--- 伤害区域 [R] | 参数: whichUnit(unit), delay(real), radius(real), x(real), y(real), amount(real), attack(boolean), ranged(boolean), attackType(attacktype), damageType(damagetype), weaponType(weapontype) | 返回: boolean
cj.UnitDamagePoint = JassCommon["UnitDamagePoint"]
--- 伤害目标 [R] | 参数: whichUnit(unit), target(widget), amount(real), attack(boolean), ranged(boolean), attackType(attacktype), damageType(damagetype), weaponType(weapontype) | 返回: boolean
cj.UnitDamageTarget = JassCommon["UnitDamageTarget"]
--- 发布丢弃物品命令(指定坐标) [R] | 参数: whichUnit(unit), whichItem(item), x(real), y(real) | 返回: boolean
cj.UnitDropItemPoint = JassCommon["UnitDropItemPoint"]
--- 移动物品到物品栏 [R] | 参数: whichUnit(unit), whichItem(item), slot(integer) | 返回: boolean
cj.UnitDropItemSlot = JassCommon["UnitDropItemSlot"]
--- 发布给予物品命令 | 参数: whichUnit(unit), whichItem(item), target(widget) | 返回: boolean
cj.UnitDropItemTarget = JassCommon["UnitDropItemTarget"]
--- 单位是否拥有Buff(详细) | 参数: whichUnit(unit), removePositive(boolean), removeNegative(boolean), magic(boolean), physical(boolean), timedLife(boolean), aura(boolean), autoDispel(boolean) | 返回: boolean
cj.UnitHasBuffsEx = JassCommon["UnitHasBuffsEx"]
--- 持有物品 | 参数: whichUnit(unit), whichItem(item) | 返回: boolean
cj.UnitHasItem = JassCommon["UnitHasItem"]
--- 转换字符串为单位类型 | 参数: unitIdString(string) | 返回: integer
cj.UnitId = JassCommon["UnitId"]
--- 单位ID转字符串 | 参数: unitId(integer) | 返回: string
cj.UnitId2String = JassCommon["UnitId2String"]
--- 单位忽略警戒(设置) | 参数: whichUnit(unit), flag(boolean) | 返回: boolean
cj.UnitIgnoreAlarm = JassCommon["UnitIgnoreAlarm"]
--- 单位是否忽略警戒 | 参数: whichUnit(unit) | 返回: boolean
cj.UnitIgnoreAlarmToggled = JassCommon["UnitIgnoreAlarmToggled"]
--- 物品栏格数 | 参数: whichUnit(unit) | 返回: integer
cj.UnitInventorySize = JassCommon["UnitInventorySize"]
--- 正在睡眠 | 参数: whichUnit(unit) | 返回: boolean
cj.UnitIsSleeping = JassCommon["UnitIsSleeping"]
--- 单位持有物品 | 参数: whichUnit(unit), itemSlot(integer) | 返回: item
cj.UnitItemInSlot = JassCommon["UnitItemInSlot"]
--- 设置技能永久性 [R] | 参数: whichUnit(unit), permanent(boolean), abilityId(integer) | 返回: boolean
cj.UnitMakeAbilityPermanent = JassCommon["UnitMakeAbilityPermanent"]
--- 添加剩余技能点 [R] | 参数: whichHero(unit), skillPointDelta(integer) | 返回: boolean
cj.UnitModifySkillPoints = JassCommon["UnitModifySkillPoints"]
--- 暂停/恢复生命周期 [R] | 参数: whichUnit(unit), flag(boolean)
cj.UnitPauseTimedLife = JassCommon["UnitPauseTimedLife"]
--- 添加单位类型 [R] | 参数: whichPool(unitpool), unitId(integer), weight(real)
cj.UnitPoolAddUnitType = JassCommon["UnitPoolAddUnitType"]
--- 删除单位类型 [R] | 参数: whichPool(unitpool), unitId(integer)
cj.UnitPoolRemoveUnitType = JassCommon["UnitPoolRemoveUnitType"]
--- 删除指定魔法效果 [R] | 参数: whichUnit(unit), abilityId(integer) | 返回: boolean
cj.UnitRemoveAbility = JassCommon["UnitRemoveAbility"]
--- 删除魔法效果(指定极性) [R] | 参数: whichUnit(unit), removePositive(boolean), removeNegative(boolean)
cj.UnitRemoveBuffs = JassCommon["UnitRemoveBuffs"]
--- 删除魔法效果(详细类别) [R] | 参数: whichUnit(unit), removePositive(boolean), removeNegative(boolean), magic(boolean), physical(boolean), timedLife(boolean), aura(boolean), autoDispel(boolean)
cj.UnitRemoveBuffsEx = JassCommon["UnitRemoveBuffsEx"]
--- 单位丢弃物品 | 参数: whichUnit(unit), whichItem(item)
cj.UnitRemoveItem = JassCommon["UnitRemoveItem"]
--- 单位从指定栏位移除物品 | 参数: whichUnit(unit), itemSlot(integer) | 返回: item
cj.UnitRemoveItemFromSlot = JassCommon["UnitRemoveItemFromSlot"]
--- 删除类别 [R] | 参数: whichUnit(unit), whichUnitType(unittype) | 返回: boolean
cj.UnitRemoveType = JassCommon["UnitRemoveType"]
--- 重置技能CD | 参数: whichUnit(unit)
cj.UnitResetCooldown = JassCommon["UnitResetCooldown"]
--- 设置建筑建造进度条 | 参数: whichUnit(unit), constructionPercentage(integer)
cj.UnitSetConstructionProgress = JassCommon["UnitSetConstructionProgress"]
--- 设置建筑升级进度条 | 参数: whichUnit(unit), upgradePercentage(integer)
cj.UnitSetUpgradeProgress = JassCommon["UnitSetUpgradeProgress"]
--- 是否启用小地图特殊图标 | 参数: whichUnit(unit), flag(boolean)
cj.UnitSetUsesAltIcon = JassCommon["UnitSetUsesAltIcon"]
--- 共享视野 [R] | 参数: whichUnit(unit), whichPlayer(player), share(boolean)
cj.UnitShareVision = JassCommon["UnitShareVision"]
--- 降低等级 [R] | 参数: whichHero(unit), howManyLevels(integer) | 返回: boolean
cj.UnitStripHeroLevel = JassCommon["UnitStripHeroLevel"]
--- 暂停尸体腐烂 [R] | 参数: whichUnit(unit), suspend(boolean)
cj.UnitSuspendDecay = JassCommon["UnitSuspendDecay"]
--- 使用物品(无目标) | 参数: whichUnit(unit), whichItem(item) | 返回: boolean
cj.UnitUseItem = JassCommon["UnitUseItem"]
--- 使用物品(指定坐标) | 参数: whichUnit(unit), whichItem(item), x(real), y(real) | 返回: boolean
cj.UnitUseItemPoint = JassCommon["UnitUseItemPoint"]
--- 使用物品(对单位) | 参数: whichUnit(unit), whichItem(item), target(widget) | 返回: boolean
cj.UnitUseItemTarget = JassCommon["UnitUseItemTarget"]
--- 叫醒 | 参数: whichUnit(unit)
cj.UnitWakeUp = JassCommon["UnitWakeUp"]
--- 取消注册的堆叠音效设置 [new] | 参数: soundHandle(sound), byPosition(boolean), rectwidth(real), rectheight(real)
cj.UnregisterStackedSound = JassCommon["UnregisterStackedSound"]
--- 版本兼容性检查 | 参数: whichVersion(version) | 返回: boolean
cj.VersionCompatible = JassCommon["VersionCompatible"]
--- 获取魔兽版本 返回: version
cj.VersionGet = JassCommon["VersionGet"]
--- 版本是否支持 | 参数: whichVersion(version) | 返回: boolean
cj.VersionSupported = JassCommon["VersionSupported"]
--- VolumeGroupReset
cj.VolumeGroupReset = JassCommon["VolumeGroupReset"]
--- 设置多通道音量 [R] | 参数: vgroup(volumegroup), scale(real)
cj.VolumeGroupSetVolume = JassCommon["VolumeGroupSetVolume"]
--- 激活/关闭传送门 | 参数: waygate(unit), activate(boolean)
cj.WaygateActivate = JassCommon["WaygateActivate"]
--- 传送门目的地X坐标 | 参数: waygate(unit) | 返回: real
cj.WaygateGetDestinationX = JassCommon["WaygateGetDestinationX"]
--- 传送门目的地Y坐标 | 参数: waygate(unit) | 返回: real
cj.WaygateGetDestinationY = JassCommon["WaygateGetDestinationY"]
--- 传送门激活 | 参数: waygate(unit) | 返回: boolean
cj.WaygateIsActive = JassCommon["WaygateIsActive"]
--- 设置传送门目的坐标 [R] | 参数: waygate(unit), x(real), y(real)
cj.WaygateSetDestination = JassCommon["WaygateSetDestination"]
-- 注：SetUnitGoldBounty / SetUnitLumberBounty Native 在当前运行环境下不存在，已跳过

--- <1.24> 保存实体对象 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), whichAgent(agent) | 返回: boolean | 2026-06-19 补全
cj.SaveAgentHandle = JassCommon["SaveAgentHandle"]
--- <1.24> 保存哈希表 [C] | 参数: table(hashtable), parentKey(integer), childKey(integer), whichHashtable(hashtable) | 返回: boolean | 2026-06-19 补全
cj.SaveHashtableHandle = JassCommon["SaveHashtableHandle"]
--- 获取玩家起始位置X坐标 | 参数: whichPlayer(player) | 返回: real | 2026-06-19 补全
cj.GetPlayerStartLocationX = JassCommon["GetPlayerStartLocationX"]
--- 获取玩家起始位置Y坐标 | 参数: whichPlayer(player) | 返回: real | 2026-06-19 补全
cj.GetPlayerStartLocationY = JassCommon["GetPlayerStartLocationY"]
--- 设置堆叠声音 | 参数: soundHandle(sound), byPosition(boolean), rectwidth(real), rectheight(real) | 2026-06-19 补全
cj.SetStackedSound = JassCommon["SetStackedSound"]
--- 设置矩形区域堆叠声音 | 参数: soundHandle(sound), r(rect) | 2026-06-19 补全
cj.SetStackedSoundRect = JassCommon["SetStackedSoundRect"]
--- 清除堆叠声音 | 参数: soundHandle(sound), byPosition(boolean), rectwidth(real), rectheight(real) | 2026-06-19 补全
cj.ClearStackedSound = JassCommon["ClearStackedSound"]
--- 清除矩形区域堆叠声音 | 参数: soundHandle(sound), r(rect) | 2026-06-19 补全
cj.ClearStackedSoundRect = JassCommon["ClearStackedSoundRect"]
--- 设置对话框异步模式 | 参数: whichDialog(dialog), isAsync(boolean) | 2026-06-19 补全
cj.DialogSetAsync = JassCommon["DialogSetAsync"]

math.sin = cj.Sin
math.cos = cj.Cos
math.tan = cj.Tan
math.asin = cj.Asin
math.acos = cj.Acos
math.atan = cj.Atan2
-- ============================================================
-- math.random 覆盖：改用引擎同步随机流（根治 Lua 随机分叉 desync）
-- ============================================================
-- 与上方 math.sin = cj.Sin 同一模式：引擎 GetRandomInt/GetRandomReal
-- 走全机同步推进的随机流，跨机结果一致；Lua 自带 math.random 用本地种子，
-- 各机一旦消耗次数不同 → 序列错位雪崩 → desync。
-- 语义保持：random() = [0,1) 浮点；random(n) = 1..n；random(m,n) = m..n（含端点）。
-- ★ 捕获原始引用而非 cj.GetRandomInt 表项：DesyncGuard 在 common.lua 之后装钩，
--   直接写 cj.GetRandomInt 会触发其 GetRandomInt 钩子 → math.random 双重记录；
--   捕获原始引用则只经 math.random 一层记录。
-- ★ 同步铁律不变：随机数只允许在同步上下文消耗（Timer/全局事件/伤害回调），
--   异步（本地键/UI帧）里消耗引擎随机流同样会立即 desync 并被 DG 更快暴露。

local _gri = cj.GetRandomInt
local _grr = cj.GetRandomReal
--- 随机数生成器 | 参数: a(integer), b(integer) | 返回: integer
math.random = function(a, b)
    _G._RNG = (_G._RNG or 0) + 1  -- [PROBE] 临时诊断：RNG 流消耗计数（跨机对照，定位随机流首个分叉）
    if a == nil then
        -- print("math.random() → [0,1)" .. _grr(0, 1))
        return _grr(0, 1)          -- math.random() → [0,1)
    elseif b == nil then
        -- print("math.random(n) → 1..n" .. _gri(1, a))
        return _gri(1, a)          -- math.random(n) → 1..n
    else
        -- print("math.random(m,n) → m..n" .. _gri(a, b))
        return _gri(a, b)          -- math.random(m,n) → m..n
    end
end


local cic = { c2i = {}, i2c = {} }
--- 字符串转ID
c2i = function(idChar)
    if (type(idChar) ~= "string") then
        return idChar
    end
    local id = cic.c2i[idChar]
    if (id == nil) then
        id = ('>I4'):unpack(idChar)
        cic.c2i[idChar] = id
        cic.i2c[id] = idChar
    end
    return id
end
--- ID转字符串
i2c = function(id)
    if (type(id) ~= "number") then
        return id
    end
    local idChar = cic.i2c[id]
    if (idChar == nil) then
        idChar = ('>I4'):pack(id)
        cic.i2c[id] = idChar
        cic.c2i[idChar] = id
    end
    return idChar
end