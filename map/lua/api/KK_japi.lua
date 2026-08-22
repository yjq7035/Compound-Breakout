-- =========================================================
-- DzAPI / KKAPI / EX API 扩展函数注册
-- 自动生成于 2026-06-19，按功能分类排序
-- 共 723 个扩展函数
-- =========================================================

JassDz = require "jass.japi"


cdz = {}


-- ====== DZ 核心 API ======

--- 界面 - 创建ui模型控件 | 参数: frame | 返回: frame
cdz.DzFrameAddModel = JassDz["DzFrameAddModel"]

--- 界面 - ui模型 - 添加绑定特效 | 参数: frame, string, modelfile | 返回: frame
cdz.DzFrameAddModelEffect = JassDz["DzFrameAddModelEffect"]

--- 世界坐标 - 为绑定的Frame添加隐藏区域 | 参数: frame, real, real, real, real, real, real
cdz.DzFrameBindAddHideRect = JassDz["DzFrameBindAddHideRect"]

--- 世界坐标 - 绑定Frame到单位实时位置 | 参数: frame, unit, real, real, real, real, real, boolean, boolean, boolean
cdz.DzFrameBindWidget = JassDz["DzFrameBindWidget"]

--- 世界坐标 - 绑定Frame到世界坐标实时位置 | 参数: frame, real, real, real, real, real, boolean
cdz.DzFrameBindWorldPos = JassDz["DzFrameBindWorldPos"]

--- 游戏界面限制设置 | 参数: YESNO
cdz.DzFrameEnableClipRect = JassDz["DzFrameEnableClipRect"]

--- 界面 - 原生 - 获取聊天输入栏控件 | 返回: frame
cdz.DzFrameGetChatEditBar = JassDz["DzFrameGetChatEditBar"]

--- 界面 - 获取复选框勾选状态 | 参数: frame | 返回: boolean
cdz.DzFrameGetCheckBoxState = JassDz["DzFrameGetCheckBoxState"]

--- 获取子控件 | 参数: frame, integer | 返回: frame
cdz.DzFrameGetChild = JassDz["DzFrameGetChild"]

--- 获取子控件数量 | 参数: frame | 返回: integer
cdz.DzFrameGetChildrenCount = JassDz["DzFrameGetChildrenCount"]

--- 获取技能自动施法指示器 | 参数: frame | 返回: frame
cdz.DzFrameGetCommandBarButtonAutoCastIndicator = JassDz["DzFrameGetCommandBarButtonAutoCastIndicator"]

--- 获取技能冷却指示器 | 参数: frame | 返回: frame
cdz.DzFrameGetCommandBarButtonCooldownIndicator = JassDz["DzFrameGetCommandBarButtonCooldownIndicator"]

--- 获取技能右下角数字文本框体 | 参数: frame | 返回: frame
cdz.DzFrameGetCommandBarButtonNumberOverlay = JassDz["DzFrameGetCommandBarButtonNumberOverlay"]

--- 获取技能右下角数字文本控件 | 参数: frame | 返回: frame
cdz.DzFrameGetCommandBarButtonNumberText = JassDz["DzFrameGetCommandBarButtonNumberText"]

--- 界面 - 获取控件绑定的整数 | 参数: frame | 返回: integer
cdz.DzFrameGetContext = JassDz["DzFrameGetContext"]

--- 获取BUFF控件 | 参数: integer | 返回: frame
cdz.DzFrameGetInfoPanelBuffButton = JassDz["DzFrameGetInfoPanelBuffButton"]

--- 获取框选控件 | 参数: integer | 返回: frame
cdz.DzFrameGetInfoPanelSelectButton = JassDz["DzFrameGetInfoPanelSelectButton"]

--- 界面 - 获取低于控制台的底层Frame | 返回: frame
cdz.DzFrameGetLowerLevelFrame = JassDz["DzFrameGetLowerLevelFrame"]

--- 界面 - ui模型 - 获取颜色 | 参数: frame | 返回: rgba2color
cdz.DzFrameGetModelColor = JassDz["DzFrameGetModelColor"]

--- 界面 - ui模型 - 获取缩放大小 | 参数: frame | 返回: real
cdz.DzFrameGetModelSize = JassDz["DzFrameGetModelSize"]

--- 界面 - ui模型 - 获取动画播放速度 | 参数: frame | 返回: real
cdz.DzFrameGetModelSpeed = JassDz["DzFrameGetModelSpeed"]

--- 界面 - ui模型 - 获取场景内的坐标X轴 | 参数: frame | 返回: real
cdz.DzFrameGetModelX = JassDz["DzFrameGetModelX"]

--- 界面 - ui模型 - 获取场景内的坐标Y轴 | 参数: frame | 返回: real
cdz.DzFrameGetModelY = JassDz["DzFrameGetModelY"]

--- 界面 - ui模型 - 获取场景内的坐标Z轴 | 参数: frame | 返回: real
cdz.DzFrameGetModelZ = JassDz["DzFrameGetModelZ"]

--- 界面 - 获取鼠标控件 | 返回: frame
cdz.DzFrameGetMouse = JassDz["DzFrameGetMouse"]

--- 界面 - 获取控件的全局名字 | 参数: frame | 返回: string
cdz.DzFrameGetName = JassDz["DzFrameGetName"]

--- 获取农民控件 | 返回: frame
cdz.DzFrameGetPeonBar = JassDz["DzFrameGetPeonBar"]

--- 获取相对锚点所在界面 [NEW] | 参数: frame, framepoints | 返回: frame
cdz.DzFrameGetPointRelative = JassDz["DzFrameGetPointRelative"]

--- 获取相对锚点的界面锚点 [NEW] | 参数: frame, framepoints | 返回: framepoints
cdz.DzFrameGetPointRelativePoint = JassDz["DzFrameGetPointRelativePoint"]

--- 是否有指定锚点 [NEW] | 参数: frame, framepoints | 返回: boolean
cdz.DzFrameGetPointValid = JassDz["DzFrameGetPointValid"]

--- 获取锚点X坐标 [NEW] | 参数: frame, framepoints | 返回: real
cdz.DzFrameGetPointX = JassDz["DzFrameGetPointX"]

--- 获取锚点Y坐标 [NEW] | 参数: frame, framepoints | 返回: real
cdz.DzFrameGetPointY = JassDz["DzFrameGetPointY"]

--- 界面 - 获取控件实际高度 | 参数: frame | 返回: real
cdz.DzFrameGetRealHeight = JassDz["DzFrameGetRealHeight"]

--- 界面 - 获取控件实际宽度 | 参数: frame | 返回: real
cdz.DzFrameGetRealWidth = JassDz["DzFrameGetRealWidth"]

--- 触发的血条 [NEW] | 返回: frame
cdz.DzFrameGetTriggerHpBar = JassDz["DzFrameGetTriggerHpBar"]

--- 触发血条的单位 [NEW] | 返回: unit
cdz.DzFrameGetTriggerHpBarUnit = JassDz["DzFrameGetTriggerHpBarUnit"]

--- 获取单位血条 [NEW] | 参数: unit | 返回: frame
cdz.DzFrameGetUnitHpBar = JassDz["DzFrameGetUnitHpBar"]

--- 获取 Frame 的 宽度 | 参数: frame | 返回: real
cdz.DzFrameGetWidth = JassDz["DzFrameGetWidth"]

--- 游戏提示信息界面 | 返回: frame
cdz.DzFrameGetWorldFrameMessage = JassDz["DzFrameGetWorldFrameMessage"]

--- 血条刷新事件 [NEW] | 参数: func(code)
cdz.DzFrameHookHpBar = JassDz["DzFrameHookHpBar"]

--- 界面 - 获取控件是否焦点 | 参数: frame | 返回: boolean
cdz.DzFrameIsFocus = JassDz["DzFrameIsFocus"]

--- 界面 - ui模型 - 移除绑定特效 | 参数: frame, frame
cdz.DzFrameRemoveModelEffect = JassDz["DzFrameRemoveModelEffect"]

--- 设置模型界面播放动画（编号） | 参数: frame, integer, integer
cdz.DzFrameSetAnimateByIndex = JassDz["DzFrameSetAnimateByIndex"]

--- 界面 - 设置复选框勾选状态 | 参数: frame, boolean
cdz.DzFrameSetCheckBoxState = JassDz["DzFrameSetCheckBoxState"]

--- 设置控件视口 | 参数: frame, onoffoption
cdz.DzFrameSetClip = JassDz["DzFrameSetClip"]

--- 界面 - 设置编辑框激活状态 | 参数: frame, boolean
cdz.DzFrameSetEditBoxActive = JassDz["DzFrameSetEditBoxActive"]

--- 界面 - 设置编辑框禁用输入法 | 参数: frame, boolean
cdz.DzFrameSetEditBoxDisableIme = JassDz["DzFrameSetEditBoxDisableIme"]

--- 界面 - 设置Frame控件忽略点击事件 | 参数: frame, boolean
cdz.DzFrameSetIgnoreTrackEvents = JassDz["DzFrameSetIgnoreTrackEvents"]

--- 界面 - ui模型 - 设置模型文件 | 参数: frame, modelfile, integer
cdz.DzFrameSetModel2 = JassDz["DzFrameSetModel2"]

--- 界面 - ui模型 - 播放动画指定动画名 | 参数: frame, string
cdz.DzFrameSetModelAnimation = JassDz["DzFrameSetModelAnimation"]

--- 界面 - ui模型 - 播放动画指定索引 | 参数: frame, integer
cdz.DzFrameSetModelAnimationByIndex = JassDz["DzFrameSetModelAnimationByIndex"]

--- 界面 - ui模型 - 设置场景内镜头源点 | 参数: frame, real, real, real
cdz.DzFrameSetModelCameraSource = JassDz["DzFrameSetModelCameraSource"]

--- 界面 - ui模型 - 设置场景内镜头目标点 | 参数: frame, real, real, real
cdz.DzFrameSetModelCameraTarget = JassDz["DzFrameSetModelCameraTarget"]

--- 界面 - ui模型 - 设置模型颜色 | 参数: frame, rgba2color
cdz.DzFrameSetModelColor = JassDz["DzFrameSetModelColor"]

--- 界面 - ui模型 - 设置宽屏补丁 | 参数: frame, boolean
cdz.DzFrameSetModelEnableWideScreen = JassDz["DzFrameSetModelEnableWideScreen"]

--- 界面 - ui模型 - 设置矩阵重置 | 参数: frame
cdz.DzFrameSetModelMatReset = JassDz["DzFrameSetModelMatReset"]

--- 界面 - ui模型 - 设置粒子2缩放大小 | 参数: frame, real
cdz.DzFrameSetModelParticle2Size = JassDz["DzFrameSetModelParticle2Size"]

--- 界面 - ui模型 - 设置场景内的坐标(X Y Z) | 参数: frame, real, real, real
cdz.DzFrameSetModelPosition = JassDz["DzFrameSetModelPosition"]

--- 界面 - ui模型 - 设置矩阵旋转X轴 | 参数: frame, real
cdz.DzFrameSetModelRotateX = JassDz["DzFrameSetModelRotateX"]

--- 界面 - ui模型 - 设置矩阵旋转Y轴 | 参数: frame, real
cdz.DzFrameSetModelRotateY = JassDz["DzFrameSetModelRotateY"]

--- 界面 - ui模型 - 设置矩阵旋转Z轴 | 参数: frame, real
cdz.DzFrameSetModelRotateZ = JassDz["DzFrameSetModelRotateZ"]

--- 界面 - ui模型 - 设置矩阵缩放 | 参数: frame, real, real, real
cdz.DzFrameSetModelScale = JassDz["DzFrameSetModelScale"]

--- 界面 - ui模型 - 设置缩放大小 | 参数: frame, real
cdz.DzFrameSetModelSize = JassDz["DzFrameSetModelSize"]

--- 界面 - ui模型 - 设置动画播放速度 | 参数: frame, real
cdz.DzFrameSetModelSpeed = JassDz["DzFrameSetModelSpeed"]

--- 界面 - ui模型 - 替换模型id贴图 | 参数: frame, imagefile, integer
cdz.DzFrameSetModelTexture = JassDz["DzFrameSetModelTexture"]

--- 界面 - ui模型 - 设置场景内的坐标X轴 | 参数: frame, real
cdz.DzFrameSetModelX = JassDz["DzFrameSetModelX"]

--- 界面 - ui模型 - 设置场景内的坐标Y轴 | 参数: frame, real
cdz.DzFrameSetModelY = JassDz["DzFrameSetModelY"]

--- 界面 - ui模型 - 设置场景内的坐标Z轴 | 参数: frame, real
cdz.DzFrameSetModelZ = JassDz["DzFrameSetModelZ"]

--- 界面 - 设置控件全局名字跟绑定整数 | 参数: frame, string, integer
cdz.DzFrameSetNameContext = JassDz["DzFrameSetNameContext"]

--- 设置界面纹理坐标 [NEW] | 参数: frame, real, real, real, real
cdz.DzFrameSetTexCoord = JassDz["DzFrameSetTexCoord"]

--- 界面 - 设置文本控件字间距 | 参数: frame, real
cdz.DzFrameSetTextFontSpacing = JassDz["DzFrameSetTextFontSpacing"]

--- 世界坐标 - 解除Frame的绑定 | 参数: frame
cdz.DzFrameUnBind = JassDz["DzFrameUnBind"]

--- 界面 - 解锁右下角区域鼠标焦点限制 | 参数: boolean
cdz.DzFrameUnlockMouseRectLimit = JassDz["DzFrameUnlockMouseRectLimit"]

--- 转换地图坐标为小地图x坐标 | 参数: real, real | 返回: real
cdz.DzFrameWorldToMinimapPosX = JassDz["DzFrameWorldToMinimapPosX"]

--- 转换地图坐标为小地图y坐标 | 参数: real, real | 返回: real
cdz.DzFrameWorldToMinimapPosY = JassDz["DzFrameWorldToMinimapPosY"]

--- 绑定特效 | 参数: unit, string, effect
cdz.DzBindEffect = JassDz["DzBindEffect"]

--- 特效 - 特效绑定特效 | 参数: effect, string, effect
cdz.DzEffectBindEffect = JassDz["DzEffectBindEffect"]

--- 降低玩家科技等级 [NEW] | 参数: player, techcode, integer
cdz.DzRemovePlayerTechResearched = JassDz["DzRemovePlayerTechResearched"]

--- 解除绑定特效 | 参数: effect
cdz.DzUnbindEffect = JassDz["DzUnbindEffect"]

--- 技能 - 获取技能施法范围 | 参数: unit, abilcode | 返回: real
cdz.DzGetUnitAbilityArea = JassDz["DzGetUnitAbilityArea"]

--- 技能 - 获取技能图标 | 参数: unit, abilcode | 返回: string
cdz.DzGetUnitAbilityArt = JassDz["DzGetUnitAbilityArt"]

--- 技能 - 获取建造技能命令ID（象牙塔） | 参数: unit, ordercode | 返回: integer
cdz.DzGetUnitAbilityBuildOrderId = JassDz["DzGetUnitAbilityBuildOrderId"]

--- 技能 - 获取技能当前冷却时间 | 参数: unit, abilcode | 返回: real
cdz.DzGetUnitAbilityCool = JassDz["DzGetUnitAbilityCool"]

--- 技能 - 获取技能魔法消耗 | 参数: unit：单位, abilcode：技能ID | 返回: integer
cdz.DzGetUnitAbilityCost = JassDz["DzGetUnitAbilityCost"]

--- 技能 - 获取技能数据A | 参数: unit, abilcode | 返回: real
cdz.DzGetUnitAbilityDataA = JassDz["DzGetUnitAbilityDataA"]

--- 技能 - 获取技能数据B | 参数: unit, abilcode | 返回: real
cdz.DzGetUnitAbilityDataB = JassDz["DzGetUnitAbilityDataB"]

--- 技能 - 获取技能数据C | 参数: unit, abilcode | 返回: real
cdz.DzGetUnitAbilityDataC = JassDz["DzGetUnitAbilityDataC"]

--- 技能 - 获取技能数据D | 参数: unit, abilcode | 返回: real
cdz.DzGetUnitAbilityDataD = JassDz["DzGetUnitAbilityDataD"]

--- 技能 - 获取技能数据E | 参数: unit, abilcode | 返回: real
cdz.DzGetUnitAbilityDataE = JassDz["DzGetUnitAbilityDataE"]

--- 技能 - 获取当前禁用的内部计数 | 参数: unit, abilcode | 返回: integer
cdz.DzGetUnitAbilityDisabledCount = JassDz["DzGetUnitAbilityDisabledCount"]

--- 技能 - 获取当前是否禁用状态 | 参数: unit, abilcode | 返回: boolean
cdz.DzGetUnitAbilityIsDisabled = JassDz["DzGetUnitAbilityIsDisabled"]

--- 技能 - 获取技能最大冷却时间 | 参数: unit, abilcode | 返回: real
cdz.DzGetUnitAbilityMaxCool = JassDz["DzGetUnitAbilityMaxCool"]

--- 技能 - 获取技能投射物弧度 | 参数: unit, abilcode | 返回: real
cdz.DzGetUnitAbilityMissileArc = JassDz["DzGetUnitAbilityMissileArc"]

--- 技能 - 获取技能投射物模型 | 参数: unit, abilcode | 返回: string
cdz.DzGetUnitAbilityMissileArt = JassDz["DzGetUnitAbilityMissileArt"]

--- 技能 - 获取技能投射物数量 (弹幕攻击) | 参数: unit, abilcode | 返回: integer
cdz.DzGetUnitAbilityMissileCount = JassDz["DzGetUnitAbilityMissileCount"]

--- 技能 - 获取技能投射物伤害 (弹幕攻击) | 参数: unit, abilcode | 返回: real
cdz.DzGetUnitAbilityMissileDamage = JassDz["DzGetUnitAbilityMissileDamage"]

--- 技能 - 获取技能投射物允许自导 | 参数: unit, abilcode | 返回: boolean
cdz.DzGetUnitAbilityMissileHoming = JassDz["DzGetUnitAbilityMissileHoming"]

--- 技能 - 获取技能投射物最大伤害 (弹幕攻击) | 参数: unit, abilcode | 返回: real
cdz.DzGetUnitAbilityMissileMaxDamage = JassDz["DzGetUnitAbilityMissileMaxDamage"]

--- 技能 - 获取技能投射物速度 | 参数: unit, abilcode | 返回: real
cdz.DzGetUnitAbilityMissileSpeed = JassDz["DzGetUnitAbilityMissileSpeed"]

--- 技能 - 获取技能命令ID | 参数: unit, abilcode | 返回: integer
cdz.DzGetUnitAbilityOrderId = JassDz["DzGetUnitAbilityOrderId"]

--- 技能 - 获取技能施法距离 | 参数: unit, abilcode | 返回: real
cdz.DzGetUnitAbilityRange = JassDz["DzGetUnitAbilityRange"]

--- 技能 - 获取技能等级要求 | 参数: unit, abilcode | 返回: integer
cdz.DzGetUnitAbilityReqLevel = JassDz["DzGetUnitAbilityReqLevel"]

--- 技能 - 获取魔法书的技能列表 | 参数: unit, abilcode | 返回: string
cdz.DzGetUnitAbilitySpellBookList = JassDz["DzGetUnitAbilitySpellBookList"]

--- 技能 - 获取技能目标允许 | 参数: unit, abilcode | 返回: integer
cdz.DzGetUnitAbilityTargs = JassDz["DzGetUnitAbilityTargs"]

--- 技能 - 获取当前科技条件是否达成 | 参数: unit, abilcode | 返回: boolean
cdz.DzGetUnitAbilityTechReach = JassDz["DzGetUnitAbilityTechReach"]

--- 技能 - 获取技能提示 | 参数: unit, abilcode | 返回: string
cdz.DzGetUnitAbilityTip = JassDz["DzGetUnitAbilityTip"]

--- 技能 - 获取技能提示扩展 | 参数: unit, abilcode | 返回: string
cdz.DzGetUnitAbilityUberTip = JassDz["DzGetUnitAbilityUberTip"]

--- 技能 - 获取建造技能单位ID（象牙塔） | 参数: unit, abilcode | 返回: integer
cdz.DzGetUnitAbilityUnitId = JassDz["DzGetUnitAbilityUnitId"]

--- 单位 - 获取单位作为目标类型 | 参数: unit | 返回: integer
cdz.DzGetUnitAsAttackTargetType = JassDz["DzGetUnitAsAttackTargetType"]

--- 单位 - 获取单位攻击1目标允许 | 参数: unit | 返回: integer
cdz.DzGetUnitAttack1TargetType = JassDz["DzGetUnitAttack1TargetType"]

--- 单位 - 获取单位攻击2目标允许 | 参数: unit | 返回: integer
cdz.DzGetUnitAttack2TargetType = JassDz["DzGetUnitAttack2TargetType"]

--- 单位 - 获取单位的碰撞体积 | 参数: unit | 返回: real
cdz.DzGetUnitCollisionSize = JassDz["DzGetUnitCollisionSize"]

--- 单位 - 获取单位控制命令是否被屏蔽 | 参数: unit | 返回: boolean
cdz.DzGetUnitDisableControlOrder = JassDz["DzGetUnitDisableControlOrder"]

--- 单位 - 获取单位本地命令是否被屏蔽 | 参数: unit | 返回: boolean
cdz.DzGetUnitDisableLocalOrder = JassDz["DzGetUnitDisableLocalOrder"]

--- 单位 - 获取单位头顶高度偏移 | 参数: unit | 返回: real
cdz.DzGetUnitOverheadOffset = JassDz["DzGetUnitOverheadOffset"]

--- 单位 - 获取单位Z轴高度 | 参数: unit | 返回: real
cdz.DzGetUnitZ = JassDz["DzGetUnitZ"]

--- 复活单位 | 参数: unit, player, real, real, real, real
cdz.DzReviveUnit = JassDz["DzReviveUnit"]

--- 技能 - 设置技能施法范围 | 参数: unit, abilcode, real
cdz.DzSetUnitAbilityArea = JassDz["DzSetUnitAbilityArea"]

--- 技能 - 设置技能图标 | 参数: unit, abilcode, imagefile
cdz.DzSetUnitAbilityArt = JassDz["DzSetUnitAbilityArt"]

--- 技能 - 设置建造技能模型（象牙塔） | 参数: unit, abilcode, string, real
cdz.DzSetUnitAbilityBuildModel = JassDz["DzSetUnitAbilityBuildModel"]

--- 技能 - 设置建造技能命令ID（象牙塔） | 参数: unit, abilcode, ordercode
cdz.DzSetUnitAbilityBuildOrderId = JassDz["DzSetUnitAbilityBuildOrderId"]

--- 技能 - 设置技能按钮位置 | 参数: unit, abilcode, integer, integer
cdz.DzSetUnitAbilityButtonPos = JassDz["DzSetUnitAbilityButtonPos"]

--- 技能 - 设置技能冷却时间 | 参数: unit：单位, abilcode：技能ID, real：冷却时间, real：最大冷却时间
cdz.DzSetUnitAbilityCool = JassDz["DzSetUnitAbilityCool"]

--- 技能 - 设置技能魔法消耗 | 参数: unit：单位, abilcode：技能ID, integer：魔法消耗
cdz.DzSetUnitAbilityCost = JassDz["DzSetUnitAbilityCost"]

--- 技能 - 设置技能数据A | 参数: unit, abilcode, real
cdz.DzSetUnitAbilityDataA = JassDz["DzSetUnitAbilityDataA"]

--- 技能 - 设置技能数据B | 参数: unit, abilcode, real
cdz.DzSetUnitAbilityDataB = JassDz["DzSetUnitAbilityDataB"]

--- 技能 - 设置技能数据C | 参数: unit, abilcode, real
cdz.DzSetUnitAbilityDataC = JassDz["DzSetUnitAbilityDataC"]

--- 技能 - 设置技能数据D | 参数: unit, abilcode, real
cdz.DzSetUnitAbilityDataD = JassDz["DzSetUnitAbilityDataD"]

--- 技能 - 设置技能数据E | 参数: unit, abilcode, real
cdz.DzSetUnitAbilityDataE = JassDz["DzSetUnitAbilityDataE"]

--- 技能 - 设置技能禁用 | 参数: unit, abilcode
cdz.DzSetUnitAbilityDisable = JassDz["DzSetUnitAbilityDisable"]

--- 技能 - 设置技能启用 | 参数: unit, abilcode
cdz.DzSetUnitAbilityEnable = JassDz["DzSetUnitAbilityEnable"]

--- 技能 - 设置技能快捷键 | 参数: unit, abilcode, string
cdz.DzSetUnitAbilityHotkey = JassDz["DzSetUnitAbilityHotkey"]

--- 技能 - 设置技能投射物弧度 | 参数: unit, abilcode, real
cdz.DzSetUnitAbilityMissileArc = JassDz["DzSetUnitAbilityMissileArc"]

--- 技能 - 设置技能投射物模型 | 参数: unit, abilcode, modelfile
cdz.DzSetUnitAbilityMissileArt = JassDz["DzSetUnitAbilityMissileArt"]

--- 技能 - 设置技能投射物数量 (弹幕攻击) | 参数: unit, abilcode, integer
cdz.DzSetUnitAbilityMissileCount = JassDz["DzSetUnitAbilityMissileCount"]

--- 技能 - 设置技能投射物伤害 (弹幕攻击) | 参数: unit, abilcode, real, real, attacktype, damagetype
cdz.DzSetUnitAbilityMissileDamage = JassDz["DzSetUnitAbilityMissileDamage"]

--- 技能 - 设置技能投射物允许自导 | 参数: unit, abilcode, boolean
cdz.DzSetUnitAbilityMissileHoming = JassDz["DzSetUnitAbilityMissileHoming"]

--- 技能 - 设置技能投射物速度 | 参数: unit, abilcode, real
cdz.DzSetUnitAbilityMissileSpeed = JassDz["DzSetUnitAbilityMissileSpeed"]

--- 技能 - 设置技能命令ID | 参数: unit, abilcode, integer
cdz.DzSetUnitAbilityOrderId = JassDz["DzSetUnitAbilityOrderId"]

--- 技能 - 设置技能施法距离 | 参数: unit, abilcode, real
cdz.DzSetUnitAbilityRange = JassDz["DzSetUnitAbilityRange"]

--- 技能 - 设置技能等级要求 | 参数: unit, abilcode, integer
cdz.DzSetUnitAbilityReqLevel = JassDz["DzSetUnitAbilityReqLevel"]

--- 技能 - 设置魔法书技能列表添加新技能 | 参数: unit, abilcode, abilcode
cdz.DzSetUnitAbilitySpellBookAddAbility = JassDz["DzSetUnitAbilitySpellBookAddAbility"]

--- 技能 - 设置魔法书的技能列表 | 参数: unit, abilcode, string, boolean
cdz.DzSetUnitAbilitySpellBookList = JassDz["DzSetUnitAbilitySpellBookList"]

--- 技能 - 设置魔法书技能列表移除指定技能 | 参数: unit, abilcode, abilcode
cdz.DzSetUnitAbilitySpellBookRemoveAbility = JassDz["DzSetUnitAbilitySpellBookRemoveAbility"]

--- 技能 - 设置技能目标允许 | 参数: unit, abilcode, integer
cdz.DzSetUnitAbilityTargs = JassDz["DzSetUnitAbilityTargs"]

--- 技能 - 设置技能科技条件达成 | 参数: unit, abilcode, boolean
cdz.DzSetUnitAbilityTechReach = JassDz["DzSetUnitAbilityTechReach"]

--- 技能 - 设置技能科技条件文本 | 参数: unit, abilcode, string
cdz.DzSetUnitAbilityTechReachTip = JassDz["DzSetUnitAbilityTechReachTip"]

--- 技能 - 设置技能提示 | 参数: unit, abilcode, string
cdz.DzSetUnitAbilityTip = JassDz["DzSetUnitAbilityTip"]

--- 技能 - 设置技能提示扩展 | 参数: unit, abilcode, string
cdz.DzSetUnitAbilityUberTip = JassDz["DzSetUnitAbilityUberTip"]

--- 技能 - 设置建造技能单位ID（象牙塔） | 参数: unit, abilcode, integer
cdz.DzSetUnitAbilityUnitId = JassDz["DzSetUnitAbilityUnitId"]

--- 技能 - 设置刷新数据 | 参数: unit, abilcode
cdz.DzSetUnitAbilityUpdate = JassDz["DzSetUnitAbilityUpdate"]

--- 单位 - 设置单位作为目标类型 | 参数: unit, integer
cdz.DzSetUnitAsAttackTargetType = JassDz["DzSetUnitAsAttackTargetType"]

--- 单位 - 设置单位攻击1目标允许 | 参数: unit, integer
cdz.DzSetUnitAttack1TargetType = JassDz["DzSetUnitAttack1TargetType"]

--- 单位 - 设置单位攻击2目标允许 | 参数: unit, integer
cdz.DzSetUnitAttack2TargetType = JassDz["DzSetUnitAttack2TargetType"]

--- 单位 - 修改单位碰撞体积 | 参数: unit, real
cdz.DzSetUnitCollisionSize = JassDz["DzSetUnitCollisionSize"]

--- 设置单位描述 | 参数: unit, string
cdz.DzSetUnitDescription = JassDz["DzSetUnitDescription"]

--- 单位 - 设置单位屏蔽控制命令(模拟失控) | 参数: unit, boolean
cdz.DzSetUnitDisableControlOrder = JassDz["DzSetUnitDisableControlOrder"]

--- 单位 - 设置单位屏蔽本地命令(模拟失控) | 参数: unit, boolean
cdz.DzSetUnitDisableLocalOrder = JassDz["DzSetUnitDisableLocalOrder"]

--- 单位 - 设置单位是否忽略点击 | 参数: unit, boolean
cdz.DzSetUnitHitIgnore = JassDz["DzSetUnitHitIgnore"]

--- 设置单位普攻弹道弧度 | 参数: unit, real
cdz.DzSetUnitMissileArc = JassDz["DzSetUnitMissileArc"]

--- 设置单位普攻弹道自导允许 | 参数: unit, boolean
cdz.DzSetUnitMissileHoming = JassDz["DzSetUnitMissileHoming"]

--- 设置单位普攻弹道模型 | 参数: unit, modelfile
cdz.DzSetUnitMissileModel = JassDz["DzSetUnitMissileModel"]

--- 设置单位普攻弹道速度 | 参数: unit, real
cdz.DzSetUnitMissileSpeed = JassDz["DzSetUnitMissileSpeed"]

--- 设置单位名字 | 参数: unit, string
cdz.DzSetUnitName = JassDz["DzSetUnitName"]

--- 设置单位头像模型 | 参数: unit, modelfile
cdz.DzSetUnitPortrait = JassDz["DzSetUnitPortrait"]

--- 设置单位的鼠标指向UI和血条显示/隐藏 | 参数: unit, showhideoption
cdz.DzSetUnitPreselectUIVisible = JassDz["DzSetUnitPreselectUIVisible"]

--- 设置英雄称谓 | 参数: unit, string
cdz.DzSetUnitProperName = JassDz["DzSetUnitProperName"]

--- 单位 - 修改单位选择圈缩放 | 参数: unit, real
cdz.DzSetUnitSelectScale = JassDz["DzSetUnitSelectScale"]

--- 单位 - 是否可以被放置到坐标 | 参数: unit, real, real | 返回: boolean
cdz.DzUnitCanPlaceAround = JassDz["DzUnitCanPlaceAround"]

--- 修改单位透明度 | 参数: unit, integer, boolean
cdz.DzUnitChangeAlpha = JassDz["DzUnitChangeAlpha"]

--- 创建幻象单位 [NEW] | 参数: player, unitcode, real, real, real | 返回: unit
cdz.DzUnitCreateIllusion = JassDz["DzUnitCreateIllusion"]

--- 为单位创建幻象 [NEW] | 参数: unit | 返回: unit
cdz.DzUnitCreateIllusionFromUnit = JassDz["DzUnitCreateIllusionFromUnit"]

--- 禁用攻击 | 参数: unit, disableenableoption
cdz.DzUnitDisableAttack = JassDz["DzUnitDisableAttack"]

--- 禁用道具 | 参数: unit, disableenableoption
cdz.DzUnitDisableInventory = JassDz["DzUnitDisableInventory"]

--- 获取单位的指定技能 | 参数: unit, abilcode | 返回: ability
cdz.DzUnitFindAbility = JassDz["DzUnitFindAbility"]

--- 技能 - 判断单位是否拥有技能 (包含模版技能) | 参数: unit, abilcode | 返回: boolean
cdz.DzUnitHasAbility = JassDz["DzUnitHasAbility"]

--- 清除单位命令队列 [NEW] | 参数: unit, boolean
cdz.DzUnitOrdersClear = JassDz["DzUnitOrdersClear"]

--- 获取单位的命令数量 [NEW] | 参数: unit | 返回: integer
cdz.DzUnitOrdersCount = JassDz["DzUnitOrdersCount"]

--- 执行单位的命令队列 [NEW] | 参数: unit
cdz.DzUnitOrdersExec = JassDz["DzUnitOrdersExec"]

--- 强制停止单位当前命令 [NEW] | 参数: unit, boolean
cdz.DzUnitOrdersForceStop = JassDz["DzUnitOrdersForceStop"]

--- 反转单位命令队列 [NEW] | 参数: unit
cdz.DzUnitOrdersReverse = JassDz["DzUnitOrdersReverse"]

--- 修改单位选中状态 | 参数: unit, canorcantoption
cdz.DzUnitSetCanSelect = JassDz["DzUnitSetCanSelect"]

--- 设置单位实例的移动类型 | 参数: unit, MoveTypeName
cdz.DzUnitSetMoveType = JassDz["DzUnitSetMoveType"]

--- 修改单位是否可以被设置为目标 | 参数: unit, canorcantoption
cdz.DzUnitSetTargetable = JassDz["DzUnitSetTargetable"]

--- 沉默单位 | 参数: unit, boolean
cdz.DzUnitSilence = JassDz["DzUnitSilence"]

--- 设置技能启用/禁用 | 参数: ability, boolean, boolean
cdz.DzAbilitySetEnable = JassDz["DzAbilitySetEnable"]

--- 设置技能数据-字符串 | 参数: ability, string, string
cdz.DzAbilitySetStringData = JassDz["DzAbilitySetStringData"]

--- 获取物品技能 | 参数: item, integer | 返回: ability
cdz.DzGetItemAbility = JassDz["DzGetItemAbility"]

--- 物品 - 获取物品的碰撞体积 | 参数: item | 返回: real
cdz.DzGetItemCollisionSize = JassDz["DzGetItemCollisionSize"]

--- 物品 - 获取物品大小 | 参数: item | 返回: real
cdz.DzItemGetSize = JassDz["DzItemGetSize"]

--- 物品 - 获取物品颜色 | 参数: item | 返回: rgba2color
cdz.DzItemGetVertexColor = JassDz["DzItemGetVertexColor"]

--- 物品 - 模型重置旋转缩 | 参数: item
cdz.DzItemMatReset = JassDz["DzItemMatReset"]

--- 物品 - 模型按照X轴旋转 | 参数: item, real
cdz.DzItemMatRotateX = JassDz["DzItemMatRotateX"]

--- 物品 - 模型按照Y轴旋转 | 参数: item, real
cdz.DzItemMatRotateY = JassDz["DzItemMatRotateY"]

--- 物品 - 模型按照Z轴旋转 | 参数: item, real
cdz.DzItemMatRotateZ = JassDz["DzItemMatRotateZ"]

--- 物品 - 模型按照XYZ轴缩放 | 参数: item, real, real, real
cdz.DzItemMatScale = JassDz["DzItemMatScale"]

--- 设置物品透明度(0-255) [NEW] | 参数: item, integer
cdz.DzItemSetAlpha = JassDz["DzItemSetAlpha"]

--- 设置物品模型 [NEW] | 参数: item, modelfile
cdz.DzItemSetModel = JassDz["DzItemSetModel"]

--- 设置物品头像 [NEW] | 参数: item, modelfile
cdz.DzItemSetPortrait = JassDz["DzItemSetPortrait"]

--- 物品 - 物品大小 | 参数: item, real
cdz.DzItemSetSize = JassDz["DzItemSetSize"]

--- 设置物品颜色 [NEW] | 参数: item, rgba2color
cdz.DzItemSetVertexColor = JassDz["DzItemSetVertexColor"]

--- 物品 - 修改物品碰撞体积 | 参数: item, real
cdz.DzSetItemCollisionSize = JassDz["DzSetItemCollisionSize"]

--- 新建地形装饰物 | 参数: doodadcode, integer, real, real, real, degree, real | 返回: doodad
cdz.DzDoodadCreate = JassDz["DzDoodadCreate"]

--- 装饰物动画数量 | 参数: doodad | 返回: integer
cdz.DzDoodadGetAnimationCount = JassDz["DzDoodadGetAnimationCount"]

--- 装饰物动画名 | 参数: doodad, integer | 返回: string
cdz.DzDoodadGetAnimationName = JassDz["DzDoodadGetAnimationName"]

--- 装饰物动画时间 | 参数: doodad, integer | 返回: integer
cdz.DzDoodadGetAnimationTime = JassDz["DzDoodadGetAnimationTime"]

--- 装饰物当前动画编号 | 参数: doodad | 返回: integer
cdz.DzDoodadGetCurrentAnimationIndex = JassDz["DzDoodadGetCurrentAnimationIndex"]

--- 装饰物动画播放速度 | 参数: doodad | 返回: real
cdz.DzDoodadGetTimeScale = JassDz["DzDoodadGetTimeScale"]

--- 装饰物的类型ID | 参数: doodad | 返回: doodadcode
cdz.DzDoodadGetTypeId = JassDz["DzDoodadGetTypeId"]

--- 装饰物的X坐标 | 参数: doodad | 返回: real
cdz.DzDoodadGetX = JassDz["DzDoodadGetX"]

--- 装饰物的Y坐标 | 参数: doodad | 返回: real
cdz.DzDoodadGetY = JassDz["DzDoodadGetY"]

--- 装饰物的Z坐标 | 参数: doodad | 返回: real
cdz.DzDoodadGetZ = JassDz["DzDoodadGetZ"]

--- 删除装饰物  [NEW] | 参数: doodad
cdz.DzDoodadRemove = JassDz["DzDoodadRemove"]

--- 装饰物播放动画 | 参数: doodad, string, boolean
cdz.DzDoodadSetAnimation = JassDz["DzDoodadSetAnimation"]

--- 设置装饰物颜色 | 参数: doodad, rgba2color
cdz.DzDoodadSetColor = JassDz["DzDoodadSetColor"]

--- 设置装饰物模型 | 参数: doodad, modelfile
cdz.DzDoodadSetModel = JassDz["DzDoodadSetModel"]

--- 装饰物重置大小 | 参数: doodad
cdz.DzDoodadSetOrientMatrixResize = JassDz["DzDoodadSetOrientMatrixResize"]

--- 设置装饰物旋转 | 参数: doodad, degree, real, real, real
cdz.DzDoodadSetOrientMatrixRotate = JassDz["DzDoodadSetOrientMatrixRotate"]

--- 修改装饰物尺寸 | 参数: doodad, real, real, real
cdz.DzDoodadSetOrientMatrixScale = JassDz["DzDoodadSetOrientMatrixScale"]

--- 设置装饰物位置 | 参数: doodad, real, real, real
cdz.DzDoodadSetPosition = JassDz["DzDoodadSetPosition"]

--- 改变装饰物队伍颜色 | 参数: doodad, playercolorid
cdz.DzDoodadSetTeamColor = JassDz["DzDoodadSetTeamColor"]

--- 设置装饰物动画播放速度 | 参数: doodad, real
cdz.DzDoodadSetTimeScale = JassDz["DzDoodadSetTimeScale"]

--- 装饰物显示/隐藏 | 参数: doodad, showhideoption
cdz.DzDoodadSetVisible = JassDz["DzDoodadSetVisible"]

--- 装饰物 - 获取当前地形装饰物数量 | 返回: integer
cdz.DzGetDoodadsCount = JassDz["DzGetDoodadsCount"]

--- 装饰物 - 设置地形装饰物矩阵重置 | 参数: integer
cdz.DzSetDoodadsMatReset = JassDz["DzSetDoodadsMatReset"]

--- 装饰物 - 设置地形装饰物矩阵旋转X轴 | 参数: integer, real
cdz.DzSetDoodadsMatRotateX = JassDz["DzSetDoodadsMatRotateX"]

--- 装饰物 - 设置地形装饰物矩阵旋转Y轴 | 参数: integer, real
cdz.DzSetDoodadsMatRotateY = JassDz["DzSetDoodadsMatRotateY"]

--- 装饰物 - 设置装饰物矩阵旋转Z轴 | 参数: integer, real
cdz.DzSetDoodadsMatRotateZ = JassDz["DzSetDoodadsMatRotateZ"]

--- 装饰物 - 设置地形装饰物矩阵缩放 | 参数: integer, real, real, real
cdz.DzSetDoodadsMatScale = JassDz["DzSetDoodadsMatScale"]

--- 获取商店目标 | 参数: unit, player | 返回: unit
cdz.DzGetActivePatron = JassDz["DzGetActivePatron"]

--- 获取普攻技能 | 参数: unit | 返回: ability
cdz.DzGetAttackAbility = JassDz["DzGetAttackAbility"]

--- 获取当前缓存模型的数量 | 返回: integer
cdz.DzGetCacheModelCount = JassDz["DzGetCacheModelCount"]

--- 鼠标界面 [NEW] | 返回: frame
cdz.DzGetCursorFrame = JassDz["DzGetCursorFrame"]

--- 获取特效透明度 | 参数: effect | 返回: integer
cdz.DzGetEffectVertexAlpha = JassDz["DzGetEffectVertexAlpha"]

--- 获取特效颜色 | 参数: effect | 返回: integer
cdz.DzGetEffectVertexColor = JassDz["DzGetEffectVertexColor"]

--- 获取 FPS 帧数 | 返回: integer
cdz.DzGetFPS = JassDz["DzGetFPS"]

--- 界面 - 获取游戏外界面底层 | 返回: frame
cdz.DzGetGlueUI = JassDz["DzGetGlueUI"]

--- 获取字符串数量 | 返回: integer
cdz.DzGetJassStringTableCount = JassDz["DzGetJassStringTableCount"]

--- 物品 - 当前选择的物品(异步) | 返回: item
cdz.DzGetLastSelectedItem = JassDz["DzGetLastSelectedItem"]

--- 玩家 - 获取本地玩家的聊天频道 | 返回: ChatRecipient
cdz.DzGetLocalChatRecipient = JassDz["DzGetLocalChatRecipient"]

--- 获取玩家选中的单位 | 参数: integer | 返回: unit
cdz.DzGetLocalSelectUnit = JassDz["DzGetLocalSelectUnit"]

--- 获取玩家选中的单位数量 | 返回: integer
cdz.DzGetLocalSelectUnitCount = JassDz["DzGetLocalSelectUnitCount"]

--- 读取内存数据 | 返回: string
cdz.DzGetMemoryCache = JassDz["DzGetMemoryCache"]

--- 获取预建造对象 | 返回: unit
cdz.DzGetOnBuildAgent = JassDz["DzGetOnBuildAgent"]

--- 获取建造的命令id | 返回: integer
cdz.DzGetOnBuildOrderId = JassDz["DzGetOnBuildOrderId"]

--- 获取建造的命令类型 | 返回: integer
cdz.DzGetOnBuildOrderType = JassDz["DzGetOnBuildOrderType"]

--- 获取监听到的技能 | 返回: abilcode
cdz.DzGetOnTargetAbilId = JassDz["DzGetOnTargetAbilId"]

--- 获取监听到技能预选目标 | 返回: unit
cdz.DzGetOnTargetAgent = JassDz["DzGetOnTargetAgent"]

--- 获取监听到技能预选目标 | 返回: unit
cdz.DzGetOnTargetInstantTarget = JassDz["DzGetOnTargetInstantTarget"]

--- 获取监听到技能预选命令 | 返回: integer
cdz.DzGetOnTargetOrderId = JassDz["DzGetOnTargetOrderId"]

--- 获取监听到技能预选命令类型 | 返回: integer
cdz.DzGetOnTargetOrderType = JassDz["DzGetOnTargetOrderType"]

--- 物品 - 玩家当前选择的物品(同步) | 参数: player | 返回: item
cdz.DzGetPlayerLastSelectedItem = JassDz["DzGetPlayerLastSelectedItem"]

--- 当前选择的单位(异步) | 返回: unit
cdz.DzGetSelectedLeaderUnit = JassDz["DzGetSelectedLeaderUnit"]

--- 硬件 - 获取屏幕设备高度 | 返回: integer
cdz.DzGetSystemMetricsHeight = JassDz["DzGetSystemMetricsHeight"]

--- 硬件 - 获取屏幕设备宽度 | 返回: integer
cdz.DzGetSystemMetricsWidth = JassDz["DzGetSystemMetricsWidth"]

--- 坐标 - 获取地形Z轴高度 | 参数: real, real | 返回: real
cdz.DzGetTerrainZ = JassDz["DzGetTerrainZ"]

--- 设置剪切板 [NEW] | 参数: string
cdz.DzSetClipboard = JassDz["DzSetClipboard"]

--- 设置特效播放动画 | 参数: effect, integer, integer
cdz.DzSetEffectAnimation = JassDz["DzSetEffectAnimation"]

--- 特效 - 设置特效迷雾可见 | 参数: effect, boolean
cdz.DzSetEffectFogVisible = JassDz["DzSetEffectFogVisible"]

--- 特效 - 设置特效黑色阴影可见 | 参数: effect, boolean
cdz.DzSetEffectMaskVisible = JassDz["DzSetEffectMaskVisible"]

--- 设置特效模型 | 参数: effect, modelfile
cdz.DzSetEffectModel = JassDz["DzSetEffectModel"]

--- 设置特效坐标 | 参数: effect, real, real, real
cdz.DzSetEffectPos = JassDz["DzSetEffectPos"]

--- 特效缩放 | 参数: effect, real
cdz.DzSetEffectScale = JassDz["DzSetEffectScale"]

--- 设置特效队伍颜色 | 参数: effect, playercolorid
cdz.DzSetEffectTeamColor = JassDz["DzSetEffectTeamColor"]

--- 设置特效透明度 | 参数: effect, integer
cdz.DzSetEffectVertexAlpha = JassDz["DzSetEffectVertexAlpha"]

--- 设置特效颜色 | 参数: effect, rgba2color
cdz.DzSetEffectVertexColor = JassDz["DzSetEffectVertexColor"]

--- 特效显示/隐藏 | 参数: effect, showhideoption
cdz.DzSetEffectVisible = JassDz["DzSetEffectVisible"]

--- 游戏 - 限制最高帧数 | 参数: integer
cdz.DzSetMaxFps = JassDz["DzSetMaxFps"]

--- 设置加速倍率 | 参数: real
cdz.DzSetSpeed = JassDz["DzSetSpeed"]

--- 单位缩放 | 参数: unit, real
cdz.DzSetWidgetSpriteScale = JassDz["DzSetWidgetSpriteScale"]

--- 建造 - 异步获取当前正在建造的技能Id | 返回: abilcode
cdz.DzAsyncGetCurrentBuildingAbilityId = JassDz["DzAsyncGetCurrentBuildingAbilityId"]

--- 建造 - 异步获取当前正在建造的单位Id | 返回: unitcode
cdz.DzAsyncGetCurrentBuildingUnitId = JassDz["DzAsyncGetCurrentBuildingUnitId"]

--- 结束普攻技能CD | 参数: ability
cdz.DzAttackAbilityEndCooldown = JassDz["DzAttackAbilityEndCooldown"]

--- 按位与 [NEW] | 参数: integer, integer | 返回: integer
cdz.DzBitAnd = JassDz["DzBitAnd"]

--- 整数的2进制的位值 [NEW] | 参数: integer, integer | 返回: integer
cdz.DzBitGet = JassDz["DzBitGet"]

--- 整数的256进制的位值 [NEW] | 参数: integer, integer | 返回: integer
cdz.DzBitGetByte = JassDz["DzBitGetByte"]

--- 按位取反 [NEW] | 参数: integer | 返回: integer
cdz.DzBitNot = JassDz["DzBitNot"]

--- 按位或 [NEW] | 参数: integer, integer | 返回: integer
cdz.DzBitOr = JassDz["DzBitOr"]

--- 设置整数的2进制的位值 [NEW] | 参数: integer, integer, integer | 返回: integer
cdz.DzBitSet = JassDz["DzBitSet"]

--- 设置整数的256进制的位值 [NEW] | 参数: integer, integer, integer | 返回: integer
cdz.DzBitSetByte = JassDz["DzBitSetByte"]

--- 按位左移 [NEW] | 参数: integer, integer | 返回: integer
cdz.DzBitShiftLeft = JassDz["DzBitShiftLeft"]

--- 按位右移 [NEW] | 参数: integer, integer | 返回: integer
cdz.DzBitShiftRight = JassDz["DzBitShiftRight"]

--- 4字节组合为整数 [NEW] | 参数: integer, integer, integer, integer | 返回: integer
cdz.DzBitToInt = JassDz["DzBitToInt"]

--- 按位异或 [NEW] | 参数: integer, integer | 返回: integer
cdz.DzBitXor = JassDz["DzBitXor"]

--- 设置魔兽窗口大小 | 参数: integer, integer
cdz.DzChangeWindowSize = JassDz["DzChangeWindowSize"]

--- 转换屏幕坐标到世界x坐标 | 参数: real, real | 返回: real
cdz.DzConvertScreenPositionX = JassDz["DzConvertScreenPositionX"]

--- 转换屏幕坐标到世界y坐标 | 参数: real, real | 返回: real
cdz.DzConvertScreenPositionY = JassDz["DzConvertScreenPositionY"]

--- 转化 - 目标允许字符串转整数 | 参数: string | 返回: integer
cdz.DzConvertStr2Targs = JassDz["DzConvertStr2Targs"]

--- 转化 - 目标允许整数转字符串 | 参数: integer | 返回: string
cdz.DzConvertTargs2Str = JassDz["DzConvertTargs2Str"]

--- 游戏 - 屏蔽按键 (游戏UI消息) | 参数: player, gamekey
cdz.DzDisableGameUIKeyboard = JassDz["DzDisableGameUIKeyboard"]

--- 界面 - 屏蔽所有物品指向UI
cdz.DzDisableItemPreselectUi = JassDz["DzDisableItemPreselectUi"]

--- 界面 - 屏蔽所有单位指向UI跟血条
cdz.DzDisableUnitPreselectUi = JassDz["DzDisableUnitPreselectUi"]

--- 游戏 - 屏蔽按键 (窗口消息) | 参数: player, gamekey
cdz.DzDisableWindowKeyboard = JassDz["DzDisableWindowKeyboard"]

--- 允许查看指定单位技能 | 参数: unit, boolean
cdz.DzEnableDrawSkillPanel = JassDz["DzEnableDrawSkillPanel"]

--- 允许查看指定玩家单位技能 | 参数: player, boolean
cdz.DzEnableDrawSkillPanelByPlayer = JassDz["DzEnableDrawSkillPanelByPlayer"]

--- 哈希表 - 开启保存空值(逆天设置null) | 参数: boolean
cdz.DzEnableHashtableSetNull = JassDz["DzEnableHashtableSetNull"]

--- 游戏 - 修复单位命令事件泄漏
cdz.DzFixUnitEventMemoryLeak = JassDz["DzFixUnitEventMemoryLeak"]

--- 游戏 - 模拟按键 (游戏UI消息) | 参数: player, gamekey, gamekeyaction
cdz.DzForceUiKeyboard = JassDz["DzForceUiKeyboard"]

--- 获取单位组里单位数量 [NEW] | 参数: group | 返回: integer
cdz.DzGroupGetCount = JassDz["DzGroupGetCount"]

--- 获取单位组里指定索引的单位 [NEW] | 参数: group, integer | 返回: unit
cdz.DzGroupGetUnitAt = JassDz["DzGroupGetUnitAt"]

--- 聊天框是否打开 | 返回: boolean
cdz.DzIsChatBoxOpen = JassDz["DzIsChatBoxOpen"]

--- 硬件 - 当前游戏窗口是否活动窗口 | 返回: boolean
cdz.DzIsWindowActive = JassDz["DzIsWindowActive"]

--- 硬件 - 当前游戏是否窗口化模式 | 返回: boolean
cdz.DzIsWindowMode = JassDz["DzIsWindowMode"]

--- 清除所有模型内存缓存
cdz.DzModelRemoveAllFromCache = JassDz["DzModelRemoveAllFromCache"]

--- 清除模型内存缓存 | 参数: modelfile
cdz.DzModelRemoveFromCache = JassDz["DzModelRemoveFromCache"]

--- 打开QQ群链接 | 参数: string
cdz.DzOpenQQGroupUrl = JassDz["DzOpenQQGroupUrl"]

--- 设置特效播放动画 | 参数: effect, string, string
cdz.DzPlayEffectAnimation = JassDz["DzPlayEffectAnimation"]

--- 玩家 - 发送聊天消息(触发同步事件) | 参数: player, string, ChatRecipient
cdz.DzPlayerSendChat = JassDz["DzPlayerSendChat"]

--- 坐标 - 是否可以能够通过物体 | 参数: real, real, real, CollisionType | 返回: boolean
cdz.DzPositionCanPlaceAround = JassDz["DzPositionCanPlaceAround"]

--- 对单位组添加命令到队列(无目标) [NEW] | 参数: group, ordercodenotarg
cdz.DzQueueGroupImmediateOrderById = JassDz["DzQueueGroupImmediateOrderById"]

--- 对单位组添加命令到队列(指定坐标) [NEW] | 参数: group, ordercodeptarg, real, real
cdz.DzQueueGroupPointOrderById = JassDz["DzQueueGroupPointOrderById"]

--- 对单位添加建造命令到队列 [NEW] | 参数: unit, unitcode, real, real
cdz.DzQueueIssueBuildOrderById = JassDz["DzQueueIssueBuildOrderById"]

--- 对单位添加命令到队列(无目标) [NEW] | 参数: unit, ordercodenotarg
cdz.DzQueueIssueImmediateOrderById = JassDz["DzQueueIssueImmediateOrderById"]

--- 添加中介命令到队列(无目标) [NEW] | 参数: player, unit, ordercodenotarg
cdz.DzQueueIssueNeutralImmediateOrderById = JassDz["DzQueueIssueNeutralImmediateOrderById"]

--- 添加中介命令到队列(指定坐标) [NEW] | 参数: player, unit, ordercodeptarg, real, real
cdz.DzQueueIssueNeutralPointOrderById = JassDz["DzQueueIssueNeutralPointOrderById"]

--- 对单位添加命令到队列(指定坐标) [NEW] | 参数: unit, ordercodeptarg, real, real
cdz.DzQueueIssuePointOrderById = JassDz["DzQueueIssuePointOrderById"]

--- 监听建筑选位置 | 参数: func(code)
cdz.DzRegisterOnBuildLocal = JassDz["DzRegisterOnBuildLocal"]

--- 监听技能预选目标 | 参数: func(code)
cdz.DzRegisterOnTargetLocal = JassDz["DzRegisterOnTargetLocal"]

--- 保存内存数据 | 参数: string
cdz.DzSaveMemoryCache = JassDz["DzSaveMemoryCache"]

--- 游戏 - 模拟按键 (窗口消息) | 参数: player, gamekey, gamekeyaction
cdz.DzSendKeyboard = JassDz["DzSendKeyboard"]

--- 显示游戏提示信息 | 参数: frame, string, rgba2color, real, YESNO
cdz.DzSimpleMessageFrameAddMessage = JassDz["DzSimpleMessageFrameAddMessage"]

--- 清理游戏提示信息 | 参数: frame
cdz.DzSimpleMessageFrameClear = JassDz["DzSimpleMessageFrameClear"]

--- 检查字符串是否包含指定的子字符串 [NEW] | 参数: string, string, boolean | 返回: boolean
cdz.DzStringContains = JassDz["DzStringContains"]

--- 字符串中查找子字符串并返回其位置 [NEW] | 参数: string, string, integer, boolean | 返回: integer
cdz.DzStringFind = JassDz["DzStringFind"]

--- 检查字符串第一个不包含指定字符串里任意字符的位置 [NEW] | 参数: string, string, integer, boolean | 返回: integer
cdz.DzStringFindFirstNotOf = JassDz["DzStringFindFirstNotOf"]

--- 检测字符串里第一个包含指定字符串里任意字符的位置 [NEW] | 参数: string, string, integer, boolean | 返回: integer
cdz.DzStringFindFirstOf = JassDz["DzStringFindFirstOf"]

--- 从后往前查找字符串中不包含指定字符串任意字符的所在位置 [NEW] | 参数: string, string, integer, boolean | 返回: integer
cdz.DzStringFindLastNotOf = JassDz["DzStringFindLastNotOf"]

--- 从后往前查找字符串中包含指定字符串任意字符的所在位置 [NEW] | 参数: string, string, integer, boolean | 返回: integer
cdz.DzStringFindLastOf = JassDz["DzStringFindLastOf"]

--- 插入字符串 [NEW] | 参数: string, integer, string | 返回: string
cdz.DzStringInsert = JassDz["DzStringInsert"]

--- 字符串全局替换 [NEW] | 参数: string, string, string, boolean | 返回: string
cdz.DzStringReplace = JassDz["DzStringReplace"]

--- 反转字符串 [NEW] | 参数: string | 返回: string
cdz.DzStringReverse = JassDz["DzStringReverse"]

--- 删除字符串两边的空格 [NEW] | 参数: string | 返回: string
cdz.DzStringTrim = JassDz["DzStringTrim"]

--- 删除字符串左边的空格 [NEW] | 参数: string | 返回: string
cdz.DzStringTrimLeft = JassDz["DzStringTrimLeft"]

--- 删除字符串右边的空格 [NEW] | 参数: string | 返回: string
cdz.DzStringTrimRight = JassDz["DzStringTrimRight"]

--- 获取当前漂浮文字的字体 [NEW] | 返回: string
cdz.DzTextTagGetFont = JassDz["DzTextTagGetFont"]

--- 获取漂浮文字的阴影颜色 [NEW] | 参数: texttag | 返回: rgba2color
cdz.DzTextTagGetShadowColor = JassDz["DzTextTagGetShadowColor"]

--- 设置漂浮文字字体 [NEW] | 参数: string
cdz.DzTextTagSetFont = JassDz["DzTextTagSetFont"]

--- 设置漂浮文字阴影颜色 [NEW] | 参数: texttag, rgba2color
cdz.DzTextTagSetShadowColor = JassDz["DzTextTagSetShadowColor"]

--- 设置漂浮文字透明度 [NEW] | 参数: texttag, integer
cdz.DzTextTagSetStartAlpha = JassDz["DzTextTagSetStartAlpha"]

--- 设置FPS显示/隐藏 | 参数: showhideoption
cdz.DzToggleFPS = JassDz["DzToggleFPS"]

--- 解锁BLP像素限制 | 参数: boolean
cdz.DzUnlockBlpSizeLimit = JassDz["DzUnlockBlpSizeLimit"]

--- 解锁JASS字节码限制 [NEW] | 参数: YESNO
cdz.DzUnlockOpCodeLimit = JassDz["DzUnlockOpCodeLimit"]

--- 自定义指定单位的小地图图标 | 参数: unit, imagefile
cdz.DzWidgetSetMinimapIcon = JassDz["DzWidgetSetMinimapIcon"]

--- 开启/关闭自定义指定单位的小地图图标 | 参数: unit, onoffoption
cdz.DzWidgetSetMinimapIconEnable = JassDz["DzWidgetSetMinimapIconEnable"]

--- 硬件 - 设置游戏窗口位置 | 参数: integer, integer
cdz.DzWindowSetPoint = JassDz["DzWindowSetPoint"]

--- 硬件 - 设置游戏窗口大小 | 参数: integer, integer
cdz.DzWindowSetSize = JassDz["DzWindowSetSize"]

--- 打印调试信息到平台日志 [NEW] | 参数: string
cdz.DzWriteLog = JassDz["DzWriteLog"]

--- 关闭工作表 [NEW] | 参数: xlsxworksheet
cdz.DzXlsxClose = JassDz["DzXlsxClose"]

--- 打开Excel文件 [NEW] | 参数: string | 返回: xlsxworksheet
cdz.DzXlsxOpen = JassDz["DzXlsxOpen"]

--- 工作表的值（布尔值） [NEW] | 参数: xlsxworksheet, string, integer, integer | 返回: boolean
cdz.DzXlsxWorksheetGetCellBoolean = JassDz["DzXlsxWorksheetGetCellBoolean"]

--- 工作表的值（实数） [NEW] | 参数: xlsxworksheet, string, integer, integer | 返回: real
cdz.DzXlsxWorksheetGetCellFloat = JassDz["DzXlsxWorksheetGetCellFloat"]

--- 工作表的值（整数） [NEW] | 参数: xlsxworksheet, string, integer, integer | 返回: integer
cdz.DzXlsxWorksheetGetCellInteger = JassDz["DzXlsxWorksheetGetCellInteger"]

--- 工作表的值（字符串） [NEW] | 参数: xlsxworksheet, string, integer, integer | 返回: string
cdz.DzXlsxWorksheetGetCellString = JassDz["DzXlsxWorksheetGetCellString"]

--- 单元格的数据类型 [NEW] | 参数: xlsxworksheet, string, integer, integer | 返回: integer
cdz.DzXlsxWorksheetGetCellType = JassDz["DzXlsxWorksheetGetCellType"]

--- 工作表的总列数 [NEW] | 参数: xlsxworksheet, string | 返回: integer
cdz.DzXlsxWorksheetGetColumnCount = JassDz["DzXlsxWorksheetGetColumnCount"]

--- 工作表的总行数 [NEW] | 参数: xlsxworksheet, string | 返回: integer
cdz.DzXlsxWorksheetGetRowCount = JassDz["DzXlsxWorksheetGetRowCount"]

--- 技能按钮 - 鼠标点击技能按钮 | 参数: frame, integer
cdz.KKCommandButtonClick = JassDz["KKCommandButtonClick"]

--- 技能按钮 - 获取按钮上的技能ID | 参数: frame | 返回: abilcode
cdz.KKCommandButtonGetAbilityId = JassDz["KKCommandButtonGetAbilityId"]

--- 技能按钮 - 获取按钮上的命令ID | 参数: frame | 返回: ordercode
cdz.KKCommandButtonGetOrderId = JassDz["KKCommandButtonGetOrderId"]

--- 界面 - 获取技能/物品按钮的冷却模型控件 | 参数: frame | 返回: frame
cdz.KKCommandGetCooldownModel = JassDz["KKCommandGetCooldownModel"]

--- 界面 - 设置技能/物品按钮的冷却模型缩放大小 | 参数: frame, real
cdz.KKCommandSetCooldownModelSize = JassDz["KKCommandSetCooldownModelSize"]

--- 界面 - 设置技能/物品按钮的冷却模型缩放指定宽高比例 | 参数: frame, real, real
cdz.KKCommandSetCooldownModelSize2 = JassDz["KKCommandSetCooldownModelSize2"]

--- 技能按钮 - 目标指示器点击目标单位 | 参数: integer, unit
cdz.KKCommandTargetClick = JassDz["KKCommandTargetClick"]

--- 技能按钮 - 目标指示器点击地面坐标 | 参数: integer, real, real, real
cdz.KKCommandTerrainClick = JassDz["KKCommandTerrainClick"]

--- 技能 - 创建技能按钮控件 | 返回: frame
cdz.KKCreateCommandButton = JassDz["KKCreateCommandButton"]

--- 技能按钮 - 删除技能按钮 | 参数: frame
cdz.KKDestroyCommandButton = JassDz["KKDestroyCommandButton"]

--- 技能按钮 - 绑定单位技能 | 参数: frame, unit, abilcode
cdz.KKSetCommandUnitAbility = JassDz["KKSetCommandUnitAbility"]

--- 界面 - 判断SimpleFrame类型控件是否显示 | 参数: frame | 返回: boolean
cdz.KKSimpleFrameIsVisible = JassDz["KKSimpleFrameIsVisible"]


-- ====== DZ 平台 API ======

--- 本局游戏的开始时间 | 返回: integer
cdz.DzAPI_Map_GetGameStartTime = JassDz["DzAPI_Map_GetGameStartTime"]

--- 玩家天梯等级 | 参数: player | 返回: integer
cdz.DzAPI_Map_GetLadderLevel = JassDz["DzAPI_Map_GetLadderLevel"]

--- 玩家天梯排名 | 参数: player | 返回: integer
cdz.DzAPI_Map_GetLadderRank = JassDz["DzAPI_Map_GetLadderRank"]

--- 地图配置参数 | 参数: string | 返回: string
cdz.DzAPI_Map_GetMapConfig = JassDz["DzAPI_Map_GetMapConfig"]

--- 玩家地图等级 | 参数: player | 返回: integer
cdz.DzAPI_Map_GetMapLevel = JassDz["DzAPI_Map_GetMapLevel"]

--- 玩家在地图等级排行榜上的排名 | 参数: player | 返回: integer
cdz.DzAPI_Map_GetMapLevelRank = JassDz["DzAPI_Map_GetMapLevelRank"]

--- 本局游戏的地图模式 | 返回: integer
cdz.DzAPI_Map_GetMatchType = JassDz["DzAPI_Map_GetMatchType"]

--- 读取服务器存档组 | 参数: player, string | 返回: string
cdz.DzAPI_Map_GetPublicArchive = JassDz["DzAPI_Map_GetPublicArchive"]

--- BOSS击杀后的掉落内容 | 参数: player, string | 返回: string
cdz.DzAPI_Map_GetServerArchiveDrop = JassDz["DzAPI_Map_GetServerArchiveDrop"]

--- BOSS击杀后的掉落数量 | 参数: player, string | 返回: integer
cdz.DzAPI_Map_GetServerArchiveEquip = JassDz["DzAPI_Map_GetServerArchiveEquip"]

--- 读取服务器存储的数据 | 参数: player, string | 返回: string
cdz.DzAPI_Map_GetServerValue = JassDz["DzAPI_Map_GetServerValue"]

--- 玩家是否拥有地图商城道具 | 参数: player, string | 返回: boolean
cdz.DzAPI_Map_HasMallItem = JassDz["DzAPI_Map_HasMallItem"]

--- 玩家是否平台认证的主播 | 参数: player | 返回: boolean
cdz.DzAPI_Map_IsBlueVIP = JassDz["DzAPI_Map_IsBlueVIP"]

--- 本局游戏是否天梯排位赛 | 返回: boolean
cdz.DzAPI_Map_IsRPGLadder = JassDz["DzAPI_Map_IsRPGLadder"]

--- 本局游戏是否处于RPG游戏大厅 | 返回: boolean
cdz.DzAPI_Map_IsRPGLobby = JassDz["DzAPI_Map_IsRPGLobby"]

--- 玩家是否平台认证的职业选手 | 参数: player | 返回: boolean
cdz.DzAPI_Map_IsRedVIP = JassDz["DzAPI_Map_IsRedVIP"]

--- 天梯提交字符串数据 | 参数: player, string, string
cdz.DzAPI_Map_Ladder_SetStat = JassDz["DzAPI_Map_Ladder_SetStat"]

--- 触发BOSS击杀 | 参数: player, string
cdz.DzAPI_Map_OrpgTrigger = JassDz["DzAPI_Map_OrpgTrigger"]

--- 保存服务器存档组 | 参数: player, string, string
cdz.DzAPI_Map_SavePublicArchive = JassDz["DzAPI_Map_SavePublicArchive"]

--- 保存服务器存档 | 参数: player, string, string
cdz.DzAPI_Map_SaveServerValue = JassDz["DzAPI_Map_SaveServerValue"]

--- 上报房间内显示的数据 | 参数: player, string, string
cdz.DzAPI_Map_Stat_SetStat = JassDz["DzAPI_Map_Stat_SetStat"]

--- 上报埋点数据 | 参数: player, string, string, integer
cdz.DzAPI_Map_Statistics = JassDz["DzAPI_Map_Statistics"]

--- 使用地图商城道具（局数型） | 参数: player, string
cdz.DzAPI_Map_UseConsumablesItem = JassDz["DzAPI_Map_UseConsumablesItem"]


-- ====== BZ 界面 API ======

--- 追加文本 | 参数: frame, string
cdz.DzFrameAddText = JassDz["DzFrameAddText"]

--- 限制鼠标移动 | 参数: frame, boolean
cdz.DzFrameCageMouse = JassDz["DzFrameCageMouse"]

--- 清空所有锚点 | 参数: frame
cdz.DzFrameClearAllPoints = JassDz["DzFrameClearAllPoints"]

--- 原生 - 修改游戏渲染黑边范围 | 参数: real, real
cdz.DzFrameEditBlackBorders = JassDz["DzFrameEditBlackBorders"]

--- 获取子Frame | 参数: string, integer | 返回: frame
cdz.DzFrameFindByName = JassDz["DzFrameFindByName"]

--- 获取 Frame 的 透明度(0-255) | 参数: frame | 返回: integer
cdz.DzFrameGetAlpha = JassDz["DzFrameGetAlpha"]

--- 原生 - 玩家聊天信息框 | 返回: frame
cdz.DzFrameGetChatMessage = JassDz["DzFrameGetChatMessage"]

--- 原生 - 技能按钮 | 参数: integer, integer | 返回: frame
cdz.DzFrameGetCommandBarButton = JassDz["DzFrameGetCommandBarButton"]

--- 控件是否启用 | 参数: frame | 返回: boolean
cdz.DzFrameGetEnable = JassDz["DzFrameGetEnable"]

--- 获取 Frame 的 高度 | 参数: frame | 返回: real
cdz.DzFrameGetHeight = JassDz["DzFrameGetHeight"]

--- 原生 - 英雄按钮 | 参数: integer | 返回: frame
cdz.DzFrameGetHeroBarButton = JassDz["DzFrameGetHeroBarButton"]

--- 原生 - 英雄血条 | 参数: integer | 返回: frame
cdz.DzFrameGetHeroHPBar = JassDz["DzFrameGetHeroHPBar"]

--- 原生 - 英雄蓝条 | 参数: integer | 返回: frame
cdz.DzFrameGetHeroManaBar = JassDz["DzFrameGetHeroManaBar"]

--- 原生 - 物品栏按钮 | 参数: integer | 返回: frame
cdz.DzFrameGetItemBarButton = JassDz["DzFrameGetItemBarButton"]

--- 原生 - 小地图 | 返回: frame
cdz.DzFrameGetMinimap = JassDz["DzFrameGetMinimap"]

--- 原生 - 小地图按钮 | 参数: integer | 返回: frame
cdz.DzFrameGetMinimapButton = JassDz["DzFrameGetMinimapButton"]

--- 获取 Frame 的 Parent | 参数: frame | 返回: frame
cdz.DzFrameGetParent = JassDz["DzFrameGetParent"]

--- 原生 - 单位大头像 | 返回: frame
cdz.DzFrameGetPortrait = JassDz["DzFrameGetPortrait"]

--- 获取 Frame 内的文字 | 参数: frame | 返回: string
cdz.DzFrameGetText = JassDz["DzFrameGetText"]

--- 获取 Frame 的 字数限制 | 参数: frame | 返回: integer
cdz.DzFrameGetTextSizeLimit = JassDz["DzFrameGetTextSizeLimit"]

--- 原生 - 鼠标提示 | 返回: frame
cdz.DzFrameGetTooltip = JassDz["DzFrameGetTooltip"]

--- 原生 - 上方消息框 | 返回: frame
cdz.DzFrameGetTopMessage = JassDz["DzFrameGetTopMessage"]

--- 原生 - 系统消息框 | 返回: frame
cdz.DzFrameGetUnitMessage = JassDz["DzFrameGetUnitMessage"]

--- 原生 - 界面按钮 | 参数: integer | 返回: frame
cdz.DzFrameGetUpperButtonBarButton = JassDz["DzFrameGetUpperButtonBarButton"]

--- 获取当前值 | 参数: frame | 返回: real
cdz.DzFrameGetValue = JassDz["DzFrameGetValue"]

--- 原生 - 隐藏界面元素
cdz.DzFrameHideInterface = JassDz["DzFrameHideInterface"]

--- 控件是否显示 | 参数: frame | 返回: boolean
cdz.DzFrameIsVisible = JassDz["DzFrameIsVisible"]

--- 设置绝对位置 | 参数: frame, framepoints, real, real
cdz.DzFrameSetAbsolutePoint = JassDz["DzFrameSetAbsolutePoint"]

--- 移动所有锚点到Frame | 参数: frame, frame
cdz.DzFrameSetAllPoints = JassDz["DzFrameSetAllPoints"]

--- 设置透明度(0-255) | 参数: frame, integer
cdz.DzFrameSetAlpha = JassDz["DzFrameSetAlpha"]

--- 设置动画 | 参数: frame, integer, boolean
cdz.DzFrameSetAnimate = JassDz["DzFrameSetAnimate"]

--- 设置动画进度 | 参数: frame, real
cdz.DzFrameSetAnimateOffset = JassDz["DzFrameSetAnimateOffset"]

--- 启用/禁用 | 参数: frame, boolean
cdz.DzFrameSetEnable = JassDz["DzFrameSetEnable"]

--- 设置焦点 | 参数: frame, boolean
cdz.DzFrameSetFocus = JassDz["DzFrameSetFocus"]

--- 设置字体  | 参数: frame, string, real, integer
cdz.DzFrameSetFont = JassDz["DzFrameSetFont"]

--- 设置最大/最小值 | 参数: frame, real, real
cdz.DzFrameSetMinMaxValue = JassDz["DzFrameSetMinMaxValue"]

--- 设置模型 | 参数: frame, string, integer, integer
cdz.DzFrameSetModel = JassDz["DzFrameSetModel"]

--- 设置父窗口  | 参数: frame, frame
cdz.DzFrameSetParent = JassDz["DzFrameSetParent"]

--- 设置相对位置 | 参数: frame, framepoints, frame, framepoints, real, real
cdz.DzFrameSetPoint = JassDz["DzFrameSetPoint"]

--- 设置优先级 | 参数: frame, integer
cdz.DzFrameSetPriority = JassDz["DzFrameSetPriority"]

--- 设置缩放 | 参数: frame, real
cdz.DzFrameSetScale = JassDz["DzFrameSetScale"]

--- 注册UI事件回调(func name)[观战、录像不响应] | 参数: frame, frameevent, string, boolean
cdz.DzFrameSetScript = JassDz["DzFrameSetScript"]

--- 注册UI事件回调-异步(func name)[观战、录像可响应][new] | 参数: frame, frameevent, string
cdz.DzFrameSetScriptAsync = JassDz["DzFrameSetScriptAsync"]

--- 注册UI事件回调-异步(func handle)[观战、录像不响应][new] | 参数: frame, frameevent, code, boolean
cdz.DzFrameSetScriptBlock = JassDz["DzFrameSetScriptBlock"]

--- 注册UI事件回调-异步(func handle)[观战、录像可响应][new] | 参数: frame, frameevent, code
cdz.DzFrameSetScriptBlockAsync = JassDz["DzFrameSetScriptBlockAsync"]

--- 注册UI事件回调(func handle)[观战、录像不响应] | 参数: frame, frameevent, code, boolean
cdz.DzFrameSetScriptByCode = JassDz["DzFrameSetScriptByCode"]

--- 注册UI事件回调-异步(func handle)[观战、录像可响应][new] | 参数: frame, frameevent, code
cdz.DzFrameSetScriptByCodeAsync = JassDz["DzFrameSetScriptByCodeAsync"]

--- 设置大小 | 参数: frame, real, real
cdz.DzFrameSetSize = JassDz["DzFrameSetSize"]

--- 设置步进值 | 参数: frame, real
cdz.DzFrameSetStepValue = JassDz["DzFrameSetStepValue"]

--- 设置文本 | 参数: frame, string
cdz.DzFrameSetText = JassDz["DzFrameSetText"]

--- 设置对齐方式 | 参数: frame, integer
cdz.DzFrameSetTextAlignment = JassDz["DzFrameSetTextAlignment"]

--- 设置字数限制 | 参数: frame, integer
cdz.DzFrameSetTextSizeLimit = JassDz["DzFrameSetTextSizeLimit"]

--- 设置贴图 | 参数: frame, imagefile, integer
cdz.DzFrameSetTexture = JassDz["DzFrameSetTexture"]

--- 设置提示 | 参数: frame, integer
cdz.DzFrameSetTooltip = JassDz["DzFrameSetTooltip"]

--- 设置当前值 | 参数: frame, real
cdz.DzFrameSetValue = JassDz["DzFrameSetValue"]

--- 设置颜色 | 参数: frame, rgba2color
cdz.DzFrameSetVertexColor = JassDz["DzFrameSetVertexColor"]

--- 显示/隐藏 | 参数: frame, boolean
cdz.DzFrameShow = JassDz["DzFrameShow"]

--- 取 RGBA 色值 | 参数: integer, integer, integer, integer | 返回: rgba2color
cdz.DzGetColor = JassDz["DzGetColor"]

--- 获取转换后的屏幕 X 坐标 | 返回: real
cdz.DzGetConvertWorldPositionX = JassDz["DzGetConvertWorldPositionX"]

--- 获取转换后的屏幕 Y 坐标 | 返回: real
cdz.DzGetConvertWorldPositionY = JassDz["DzGetConvertWorldPositionY"]

--- 原生 - 游戏UI | 返回: frame
cdz.DzGetGameUI = JassDz["DzGetGameUI"]

--- 鼠标所在的Frame控件指针 | 返回: frame
cdz.DzGetMouseFocus = JassDz["DzGetMouseFocus"]

--- 事件响应 - 触发的Frame | 返回: frame
cdz.DzGetTriggerUIEventFrame = JassDz["DzGetTriggerUIEventFrame"]

--- 事件响应 - 获取触发ui的玩家 | 返回: player
cdz.DzGetTriggerUIEventPlayer = JassDz["DzGetTriggerUIEventPlayer"]

--- 原生 - 修改屏幕比例(FOV) | 参数: real
cdz.DzSetCustomFovFix = JassDz["DzSetCustomFovFix"]

--- 原生 - 设置小地图背景贴图 | 参数: string
cdz.DzSetWar3MapMap = JassDz["DzSetWar3MapMap"]

--- 点击 | 参数: frame
cdz.DzClickFrame = JassDz["DzClickFrame"]

--- 转换地图坐标为屏幕坐标-异步 | 参数: real, real, real
cdz.DzConvertWorldPosition = JassDz["DzConvertWorldPosition"]

--- 创建技能按钮  | 参数: frame, string, string, string | 返回: frame
cdz.DzCreateCommandButton = JassDz["DzCreateCommandButton"]

--- 新建Frame | 参数: string, frame, integer | 返回: frame
cdz.DzCreateFrame = JassDz["DzCreateFrame"]

--- 新建Frame [Tag] | 参数: string, string, frame, string, integer | 返回: frame
cdz.DzCreateFrameByTagName = JassDz["DzCreateFrameByTagName"]

--- 销毁 | 参数: frame
cdz.DzDestroyFrame = JassDz["DzDestroyFrame"]

--- 开启/关闭宽屏模式 | 参数: optionEnable
cdz.DzEnableWideScreen = JassDz["DzEnableWideScreen"]

--- 加载Toc文件列表 | 参数: anyfile
cdz.DzLoadToc = JassDz["DzLoadToc"]

--- 获取子SimpleFontString | 参数: string, integer | 返回: frame
cdz.DzSimpleFontStringFindByName = JassDz["DzSimpleFontStringFindByName"]

--- 获取子SimpleFrame | 参数: string, integer | 返回: frame
cdz.DzSimpleFrameFindByName = JassDz["DzSimpleFrameFindByName"]

--- 显示/隐藏SimpleFrame | 参数: frame, boolean
cdz.DzSimpleFrameShow = JassDz["DzSimpleFrameShow"]

--- 获取子SimpleTexture | 参数: string, integer | 返回: frame
cdz.DzSimpleTextureFindByName = JassDz["DzSimpleTextureFindByName"]

--- 刷新小地图
cdz.DzUpdateMinimap = JassDz["DzUpdateMinimap"]


-- ====== JASS Native ======

--- 界面 - 设置文本颜色 | 参数: integer, integer
cdz.DzFrameSetTextColor = JassDz["DzFrameSetTextColor"]

--- 界面 - 注册帧更新回调(函数名) | 参数: string
cdz.DzFrameSetUpdateCallback = JassDz["DzFrameSetUpdateCallback"]

--- 界面 - 注册帧更新回调(code句柄) | 参数: code
cdz.DzFrameSetUpdateCallbackByCode = JassDz["DzFrameSetUpdateCallbackByCode"]

--- 特效组 - 添加特效 | 参数: dzeffectgroup, effect, boolean | 返回: integer
cdz.DzEffectGroupAdd = JassDz["DzEffectGroupAdd"]

--- 特效组 - 创建特效组 | 返回: dzeffectgroup
cdz.DzEffectGroupCreate = JassDz["DzEffectGroupCreate"]

--- 特效组 - 按范围选取特效 | 参数: dzeffectgroup, real, real, real, boolean, boolean | 返回: integer
cdz.DzEffectGroupEnumRange = JassDz["DzEffectGroupEnumRange"]

--- 特效组 - 按区域选取特效 | 参数: dzeffectgroup, rect, boolean, boolean | 返回: integer
cdz.DzEffectGroupEnumRect = JassDz["DzEffectGroupEnumRect"]

--- 特效 - 定时移除 | 参数: effect, real | 返回: boolean
cdz.DzRemoveEffectTimed = JassDz["DzRemoveEffectTimed"]

--- 单位 - 缓存整数数据 | 参数: integer, integer, integer, integer
cdz.DzSetUnitDataCacheInteger = JassDz["DzSetUnitDataCacheInteger"]

--- UI - 单位属性数组添加整数 | 参数: integer, integer, integer, integer
cdz.DzUnitUIAddLevelArrayInteger = JassDz["DzUnitUIAddLevelArrayInteger"]

--- 特效 - 设置粒子2缩放 | 参数: agent, real
cdz.DzSetPariticle2Size = JassDz["DzSetPariticle2Size"]

--- 单位/物品 - 替换贴图 | 参数: agent, string, integer
cdz.DzSetWidgetTexture = JassDz["DzSetWidgetTexture"]

--- 事件 - 注册按键事件(函数名) | 参数: trigger, integer, integer, boolean, string
cdz.DzTriggerRegisterKeyEvent = JassDz["DzTriggerRegisterKeyEvent"]

--- 事件 - 注册按键事件(code句柄) | 参数: trigger, integer, integer, boolean, code
cdz.DzTriggerRegisterKeyEventByCode = JassDz["DzTriggerRegisterKeyEventByCode"]

--- 事件 - 注册鼠标点击事件(函数名) | 参数: trigger, integer, integer, boolean, string
cdz.DzTriggerRegisterMouseEvent = JassDz["DzTriggerRegisterMouseEvent"]

--- 事件 - 注册鼠标点击事件(code句柄) | 参数: trigger, integer, integer, boolean, code
cdz.DzTriggerRegisterMouseEventByCode = JassDz["DzTriggerRegisterMouseEventByCode"]

--- 事件 - 注册鼠标移动事件(函数名) | 参数: trigger, boolean, string
cdz.DzTriggerRegisterMouseMoveEvent = JassDz["DzTriggerRegisterMouseMoveEvent"]

--- 事件 - 注册鼠标移动事件(code句柄) | 参数: trigger, boolean, code
cdz.DzTriggerRegisterMouseMoveEventByCode = JassDz["DzTriggerRegisterMouseMoveEventByCode"]

--- 事件 - 注册鼠标滚轮事件(函数名) | 参数: trigger, boolean, string
cdz.DzTriggerRegisterMouseWheelEvent = JassDz["DzTriggerRegisterMouseWheelEvent"]

--- 事件 - 注册鼠标滚轮事件(code句柄) | 参数: trigger, boolean, code
cdz.DzTriggerRegisterMouseWheelEventByCode = JassDz["DzTriggerRegisterMouseWheelEventByCode"]

--- 事件 - 注册窗口大小改变事件(函数名) | 参数: trigger, boolean, string
cdz.DzTriggerRegisterWindowResizeEvent = JassDz["DzTriggerRegisterWindowResizeEvent"]

--- 事件 - 注册窗口大小改变事件(code句柄) | 参数: trigger, boolean, code
cdz.DzTriggerRegisterWindowResizeEventByCode = JassDz["DzTriggerRegisterWindowResizeEventByCode"]

--- 平台 - 获取活动数据 | 返回: string
cdz.DzAPI_Map_GetActivityData = JassDz["DzAPI_Map_GetActivityData"]

--- 平台 - 获取平台VIP等级 | 参数: player | 返回: integer
cdz.DzAPI_Map_GetPlatformVIP = JassDz["DzAPI_Map_GetPlatformVIP"]

--- 平台 - 获取服务器存档错误码 | 参数: player | 返回: integer
cdz.DzAPI_Map_GetServerValueErrorCode = JassDz["DzAPI_Map_GetServerValueErrorCode"]

--- 天梯 - 设置玩家统计数据(string) | 参数: player, string, string
cdz.DzAPI_Map_Ladder_SetPlayerStat = JassDz["DzAPI_Map_Ladder_SetPlayerStat"]

--- 平台 - 任务完成上报 | 参数: player, string, string
cdz.DzAPI_Map_MissionComplete = JassDz["DzAPI_Map_MissionComplete"]

--- 界面 - 创建SimpleFrame | 参数: string, integer, integer | 返回: integer
cdz.DzCreateSimpleFrame = JassDz["DzCreateSimpleFrame"]

--- 特效 - 定时死亡播放死亡动画 | 参数: effect, real | 返回: boolean
cdz.DzDieEffectTimed = JassDz["DzDieEffectTimed"]

--- 输入 - 按键是否被按下 | 参数: integer | 返回: boolean
cdz.DzIsKeyDown = JassDz["DzIsKeyDown"]

--- 界面 - 原生UI自动重置锚点 | 参数: boolean
cdz.DzOriginalUIAutoResetPoint = JassDz["DzOriginalUIAutoResetPoint"]

--- 命令 - 单位组添加命令到队列(目标) | 参数: group, integer, widget | 返回: boolean
cdz.DzQueueGroupTargetOrderById = JassDz["DzQueueGroupTargetOrderById"]

--- 命令 - 添加命令到队列(瞬时点目标) | 参数: unit, integer, real, real, widget | 返回: boolean
cdz.DzQueueIssueInstantPointOrderById = JassDz["DzQueueIssueInstantPointOrderById"]

--- 命令 - 添加命令到队列(瞬时单位目标) | 参数: unit, integer, widget, widget | 返回: boolean
cdz.DzQueueIssueInstantTargetOrderById = JassDz["DzQueueIssueInstantTargetOrderById"]

--- 命令 - 添加中介命令到队列(目标) | 参数: player, unit, integer, widget | 返回: boolean
cdz.DzQueueIssueNeutralTargetOrderById = JassDz["DzQueueIssueNeutralTargetOrderById"]

--- 命令 - 添加命令到队列(目标) | 参数: unit, integer, widget | 返回: boolean
cdz.DzQueueIssueTargetOrderById = JassDz["DzQueueIssueTargetOrderById"]

--- 聊天 - 显示聊天消息(给指定玩家) | 参数: player, integer, string
cdz.EXDisplayChat = JassDz["EXDisplayChat"]

--- 脚本 - 执行JASS脚本字符串 | 参数: string | 返回: string
cdz.EXExecuteScript = JassDz["EXExecuteScript"]

--- 技能 - 获取技能数据(整数) | 参数: ability, integer, integer | 返回: integer
cdz.EXGetAbilityDataInteger = JassDz["EXGetAbilityDataInteger"]

--- 技能 - 获取技能数据(实数) | 参数: ability, integer, integer | 返回: real
cdz.EXGetAbilityDataReal = JassDz["EXGetAbilityDataReal"]

--- 技能 - 获取技能数据(字符串) | 参数: ability, integer, integer | 返回: string
cdz.EXGetAbilityDataString = JassDz["EXGetAbilityDataString"]

--- 技能 - 获取技能ID | 参数: ability | 返回: integer
cdz.EXGetAbilityId = JassDz["EXGetAbilityId"]

--- 技能 - 获取技能等级 | 参数: ability | 返回: integer
cdz.EXGetAbilityLevel = JassDz["EXGetAbilityLevel"]

--- 技能 - 获取技能状态 | 参数: ability, integer | 返回: real
cdz.EXGetAbilityState = JassDz["EXGetAbilityState"]

--- Buff - 获取Buff数据(字符串) | 参数: integer, integer | 返回: string
cdz.EXGetBuffDataString = JassDz["EXGetBuffDataString"]

--- 事件 - 获取伤害事件数据 | 参数: integer | 返回: integer
cdz.EXGetEventDamageData = JassDz["EXGetEventDamageData"]

--- 物品 - 获取物品数据(字符串) | 参数: integer, integer | 返回: string
cdz.EXGetItemDataString = JassDz["EXGetItemDataString"]

--- 单位 - 获取单位的指定技能 | 参数: unit, integer | 返回: ability
cdz.EXGetUnitAbility = JassDz["EXGetUnitAbility"]

--- 单位 - 按索引获取单位技能 | 参数: unit, integer | 返回: ability
cdz.EXGetUnitAbilityByIndex = JassDz["EXGetUnitAbilityByIndex"]

--- 单位 - 暂停/恢复单位 | 参数: unit, boolean
cdz.EXPauseUnit = JassDz["EXPauseUnit"]

--- 技能 - 设置技能A特效数据 | 参数: ability, integer | 返回: boolean
cdz.EXSetAbilityAEmeDataA = JassDz["EXSetAbilityAEmeDataA"]

--- 技能 - 设置技能数据(整数) | 参数: ability, integer, integer, integer | 返回: boolean
cdz.EXSetAbilityDataInteger = JassDz["EXSetAbilityDataInteger"]

--- 技能 - 设置技能数据(实数) | 参数: ability, integer, integer, real | 返回: boolean
cdz.EXSetAbilityDataReal = JassDz["EXSetAbilityDataReal"]

--- 技能 - 设置技能数据(字符串) | 参数: ability, integer, integer, string | 返回: boolean
cdz.EXSetAbilityDataString = JassDz["EXSetAbilityDataString"]

--- 技能 - 设置技能状态 | 参数: ability, integer, real | 返回: boolean
cdz.EXSetAbilityState = JassDz["EXSetAbilityState"]

--- Buff - 设置Buff数据(字符串) | 参数: integer, integer, string | 返回: boolean
cdz.EXSetBuffDataString = JassDz["EXSetBuffDataString"]

--- 事件 - 设置事件伤害值 | 参数: real | 返回: boolean
cdz.EXSetEventDamage = JassDz["EXSetEventDamage"]

--- 物品 - 设置物品数据(字符串) | 参数: integer, integer, string | 返回: boolean
cdz.EXSetItemDataString = JassDz["EXSetItemDataString"]

--- 单位 - 设置单位数组数据(字符串) | 参数: integer, integer, integer, string | 返回: boolean
cdz.EXSetUnitArrayString = JassDz["EXSetUnitArrayString"]

--- 单位 - 设置单位数据(整数) | 参数: integer, integer, integer | 返回: boolean
cdz.EXSetUnitInteger = JassDz["EXSetUnitInteger"]

--- 单位 - 获取单位的法术技能 | 参数: unit, integer | 返回: ability
cdz.ExGetUnitSpellAbility = JassDz["ExGetUnitSpellAbility"]

--- 平台 - 请求额外布尔数据 | 参数: integer, player, string, string, boolean, integer, integer, integer | 返回: boolean
cdz.RequestExtraBooleanData = JassDz["RequestExtraBooleanData"]

--- 平台 - 获取平台整数数据 | 参数: integer, player, string, string, boolean, integer, integer, integer | 返回: integer
cdz.RequestExtraIntegerData = JassDz["RequestExtraIntegerData"]

--- 平台 - 获取平台实数数据 | 参数: integer, player, string, string, boolean, integer, integer, integer | 返回: real
cdz.RequestExtraRealData = JassDz["RequestExtraRealData"]

--- 平台 - 请求额外字符串数据 | 参数: integer, player, string, string, boolean, integer, integer, integer | 返回: string
cdz.RequestExtraStringData = JassDz["RequestExtraStringData"]


-- ====== 其他 ======

--- 界面 - 添加文字阴影 | 参数: frame, real, real, integer
cdz.DzFrameAddTextShadow = JassDz["DzFrameAddTextShadow"]

--- 界面 - 复制文字阴影(模拟描边) | 参数: frame, integer
cdz.DzFrameDuplicateTextShadow = JassDz["DzFrameDuplicateTextShadow"]

--- 界面 - 获取控件优先级 | 参数: frame
cdz.DzFrameGetPriority = JassDz["DzFrameGetPriority"]

--- 界面 - 设置控件禁用文本 | 参数: frame, string
cdz.DzFrameSetDisabledText = JassDz["DzFrameSetDisabledText"]

--- 界面 - 设置控件高亮文本 | 参数: frame, string
cdz.DzFrameSetHighlightText = JassDz["DzFrameSetHighlightText"]

--- 特效组 - 第N个特效 | 参数: dzeffectgroup, integer | 返回: effect
cdz.DzEffectGroupAt = JassDz["DzEffectGroupAt"]

--- 特效组 - 清除 | 参数: dzeffectgroup
cdz.DzEffectGroupClear = JassDz["DzEffectGroupClear"]

--- 特效组 - 是否包含特效 | 参数: dzeffectgroup, effect | 返回: boolean
cdz.DzEffectGroupContains = JassDz["DzEffectGroupContains"]

--- 特效组 - 删除 | 参数: dzeffectgroup
cdz.DzEffectGroupDestroy = JassDz["DzEffectGroupDestroy"]

--- 特效组 - 获取特效数量 | 参数: dzeffectgroup | 返回: integer
cdz.DzEffectGroupGetSize = JassDz["DzEffectGroupGetSize"]

--- 特效组 - 移出 | 参数: dzeffectgroup, effect, boolean
cdz.DzEffectGroupRemove = JassDz["DzEffectGroupRemove"]

--- 特效 - 重新播放出生动画 | 参数: effect
cdz.DzEffectReplayBirth = JassDz["DzEffectReplayBirth"]

--- 特效 - 立即删除(不播放死亡动画) | 参数: effect
cdz.DzRemoveEffect = JassDz["DzRemoveEffect"]

--- 技能 - 设置技能魔法施放回复(后摇) | 参数: unit, abilcode | 返回: real
cdz.DzGetUnitAbilityBackSwing = JassDz["DzGetUnitAbilityBackSwing"]

--- 技能 - 获取技能魔法施放点(前摇) | 参数: unit, abilcode | 返回: real
cdz.DzGetUnitAbilityCastPoint = JassDz["DzGetUnitAbilityCastPoint"]

--- 技能 - 获取技能魔法施法时间 | 参数: unit, abilcode | 返回: real
cdz.DzGetUnitAbilityCastTime = JassDz["DzGetUnitAbilityCastTime"]

--- 技能 - 获取技能持续时间(普通) | 参数: unit, abilcode | 返回: real
cdz.DzGetUnitAbilityDuration = JassDz["DzGetUnitAbilityDuration"]

--- 技能 - 工程升级 - 获取替换后的技能ID | 参数: unit, abilcode | 返回: abilcode
cdz.DzGetUnitAbilityEngineeringUpgradeNewId = JassDz["DzGetUnitAbilityEngineeringUpgradeNewId"]

--- 技能 - 工程升级 - 获取替换前的技能ID | 参数: unit, abilcode | 返回: abilcode
cdz.DzGetUnitAbilityEngineeringUpgradeOldId = JassDz["DzGetUnitAbilityEngineeringUpgradeOldId"]

--- 技能 - 获取技能持续时间(英雄) | 参数: unit, abilcode | 返回: real
cdz.DzGetUnitAbilityHeroDuration = JassDz["DzGetUnitAbilityHeroDuration"]

--- 单位 - 获取攻击最大目标数 | 参数: unit, integer | 返回: integer
cdz.DzGetUnitAttackTargetCount = JassDz["DzGetUnitAttackTargetCount"]

--- 单位 - 获取魔法施放回复(后摇) | 参数: unit | 返回: real
cdz.DzGetUnitBackSwing = JassDz["DzGetUnitBackSwing"]

--- 单位 - 获取魔法施放点(前摇) | 参数: unit | 返回: real
cdz.DzGetUnitCastPoint = JassDz["DzGetUnitCastPoint"]

--- 单位 - 获取每秒生命恢复 | 参数: unit | 返回: real
cdz.DzGetUnitLifeRegen = JassDz["DzGetUnitLifeRegen"]

--- 单位 - 获取每秒魔法恢复 | 参数: unit | 返回: real
cdz.DzGetUnitManaRegen = JassDz["DzGetUnitManaRegen"]

--- 单位 - 获取最高移动速度 | 参数: unit | 返回: real
cdz.DzGetUnitMaxSpeed = JassDz["DzGetUnitMaxSpeed"]

--- 单位 - 获取最低移动速度 | 参数: unit | 返回: real
cdz.DzGetUnitMinSpeed = JassDz["DzGetUnitMinSpeed"]

--- 获取升级所需经验  | 参数: unit, integer | 返回: integer
cdz.DzGetUnitNeededXP = JassDz["DzGetUnitNeededXP"]

--- 单位 - 获取投射物发射坐标X | 参数: unit | 返回: real
cdz.DzGetUnitPojectileLaunchX = JassDz["DzGetUnitPojectileLaunchX"]

--- 单位 - 获取投射物发射坐标Y | 参数: unit | 返回: real
cdz.DzGetUnitPojectileLaunchY = JassDz["DzGetUnitPojectileLaunchY"]

--- 单位 - 获取投射物发射坐标Z | 参数: unit | 返回: real
cdz.DzGetUnitPojectileLaunchZ = JassDz["DzGetUnitPojectileLaunchZ"]

--- 获取鼠标指向的单位(异步) | 返回: unit
cdz.DzGetUnitUnderMouse = JassDz["DzGetUnitUnderMouse"]

--- 单位 - 杀死(指定凶手) | 参数: unit, unit
cdz.DzKillUnit = JassDz["DzKillUnit"]

--- 技能 - 设置技能魔法施放回复(后摇) | 参数: unit, abilcode, real
cdz.DzSetUnitAbilityBackSwing = JassDz["DzSetUnitAbilityBackSwing"]

--- 技能 - 设置技能魔法施放点(前摇) | 参数: unit, abilcode, real
cdz.DzSetUnitAbilityCastPoint = JassDz["DzSetUnitAbilityCastPoint"]

--- 技能 - 设置技能魔法施法时间 | 参数: unit, abilcode, real
cdz.DzSetUnitAbilityCastTime = JassDz["DzSetUnitAbilityCastTime"]

--- 技能 - 设置技能持续时间(普通) | 参数: unit, abilcode, real
cdz.DzSetUnitAbilityDuration = JassDz["DzSetUnitAbilityDuration"]

--- 技能 - 工程升级 - 替换技能(要相同模板) | 参数: unit, abilcode, abilcode, boolean
cdz.DzSetUnitAbilityEngineeringUpgrade = JassDz["DzSetUnitAbilityEngineeringUpgrade"]

--- 技能 - 工程升级 - 取消替换技能 | 参数: unit, abilcode
cdz.DzSetUnitAbilityEngineeringUpgradeCancel = JassDz["DzSetUnitAbilityEngineeringUpgradeCancel"]

--- 技能 - 设置技能持续时间(英雄) | 参数: unit, abilcode, real
cdz.DzSetUnitAbilityHeroDuration = JassDz["DzSetUnitAbilityHeroDuration"]

--- 单位 - 设置攻击最大目标数 | 参数: unit, integer, integer
cdz.DzSetUnitAttackTargetCount = JassDz["DzSetUnitAttackTargetCount"]

--- 单位 - 设置魔法施放回复(后摇) | 参数: unit, real
cdz.DzSetUnitBackSwing = JassDz["DzSetUnitBackSwing"]

--- 单位 - 设置魔法施放点(前摇) | 参数: unit, real
cdz.DzSetUnitCastPoint = JassDz["DzSetUnitCastPoint"]

--- 单位 - 缓存实数数据 | 参数: unit, string, real
cdz.DzSetUnitDataCacheReal = JassDz["DzSetUnitDataCacheReal"]

--- 替换单位类型 [BZAPI] | 参数: unit, unitcode
cdz.DzSetUnitID = JassDz["DzSetUnitID"]

--- 单位 - 设置每秒生命恢复 | 参数: unit, real
cdz.DzSetUnitLifeRegen = JassDz["DzSetUnitLifeRegen"]

--- 单位 - 设置每秒魔法恢复 | 参数: unit, real
cdz.DzSetUnitManaRegen = JassDz["DzSetUnitManaRegen"]

--- 单位 - 设置最高移动速度 | 参数: unit, real, boolean
cdz.DzSetUnitMaxSpeed = JassDz["DzSetUnitMaxSpeed"]

--- 单位 - 设置最低移动速度 | 参数: unit, real, boolean
cdz.DzSetUnitMinSpeed = JassDz["DzSetUnitMinSpeed"]

--- 替换单位模型 [BZAPI] | 参数: unit, string
cdz.DzSetUnitModel = JassDz["DzSetUnitModel"]

--- 设置单位位置 - 本地调用 [BZAPI] | 参数: unit, real, real
cdz.DzSetUnitPosition = JassDz["DzSetUnitPosition"]

--- 替换单位贴图 [BZAPI] | 参数: unit, string, integer
cdz.DzSetUnitTexture = JassDz["DzSetUnitTexture"]

--- 单位 - 设置XY坐标(不打断命令) | 参数: unit, real, real
cdz.DzSetUnitXY = JassDz["DzSetUnitXY"]

--- 单位 - 添加物品到指定格子 | 参数: unit, item, integer
cdz.DzUnitAddItemToSlot = JassDz["DzUnitAddItemToSlot"]

--- 单位 - 造成伤害(指定凶手) | 参数: unit, unit, real, weapontype, attacktype, damagetype, integer, boolean, unit, integer
cdz.DzUnitDamageTarget = JassDz["DzUnitDamageTarget"]

--- 单位 - 获取单位等级 | 参数: unit | 返回: integer
cdz.DzUnitGetLevel = JassDz["DzUnitGetLevel"]

--- 单位 - 是否显示血条 | 参数: unit | 返回: boolean
cdz.DzUnitIsShowingHpBar = JassDz["DzUnitIsShowingHpBar"]

--- 单位 - 获取头顶高度偏移 | 参数: unit | 返回: real
cdz.DzUnitOverheadOffset = JassDz["DzUnitOverheadOffset"]

--- UI - 单位属性数组清空整数 | 参数: unit, integer
cdz.DzUnitUIClearLevelArrayInteger = JassDz["DzUnitUIClearLevelArrayInteger"]

--- 物品 - 重置物品颜色 | 参数: item
cdz.DzItemResetColor = JassDz["DzItemResetColor"]

--- 装饰物 - 获取装饰物内存地址 | 参数: doodad | 返回: integer
cdz.DzDoodadGetAddress = JassDz["DzDoodadGetAddress"]

--- 获取魔兽窗口高度 | 返回: integer
cdz.DzGetClientHeight = JassDz["DzGetClientHeight"]

--- 获取魔兽窗口宽度 | 返回: integer
cdz.DzGetClientWidth = JassDz["DzGetClientWidth"]

--- 调试 - 根据HandleID获取对象名 | 参数: integer | 返回: string
cdz.DzGetCodeName = JassDz["DzGetCodeName"]

--- 特效组 - 选取特效 | 返回: effect
cdz.DzGetEnumEffect = JassDz["DzGetEnumEffect"]

--- 英雄 - 获取主属性 | 参数: unit, boolean | 返回: integer
cdz.DzGetHeroPrimaryAttribute = JassDz["DzGetHeroPrimaryAttribute"]

--- 英雄 - 获取属性成长 | 参数: unit, AttributeType | 返回: real
cdz.DzGetHeroPrimaryAttributePlus = JassDz["DzGetHeroPrimaryAttributePlus"]

--- 英雄 - 获取主属性类型 | 参数: unit | 返回: AttributeType
cdz.DzGetHeroPrimaryAttributeType = JassDz["DzGetHeroPrimaryAttributeType"]

--- 系统 - 获取客户端语言 | 返回: string
cdz.DzGetLocale = JassDz["DzGetLocale"]

--- 系统 - 获取地图文件路径 | 返回: string
cdz.DzGetMapFilePath = JassDz["DzGetMapFilePath"]

--- 获取鼠标在游戏内的坐标X | 返回: real
cdz.DzGetMouseTerrainX = JassDz["DzGetMouseTerrainX"]

--- 获取鼠标在游戏内的坐标Y | 返回: real
cdz.DzGetMouseTerrainY = JassDz["DzGetMouseTerrainY"]

--- 获取鼠标在游戏内的坐标Z | 返回: real
cdz.DzGetMouseTerrainZ = JassDz["DzGetMouseTerrainZ"]

--- 获取鼠标在屏幕的坐标X | 返回: integer
cdz.DzGetMouseX = JassDz["DzGetMouseX"]

--- 获取鼠标游戏窗口坐标X | 返回: integer
cdz.DzGetMouseXRelative = JassDz["DzGetMouseXRelative"]

--- 获取鼠标在屏幕的坐标Y | 返回: integer
cdz.DzGetMouseY = JassDz["DzGetMouseY"]

--- 获取鼠标游戏窗口坐标Y | 返回: integer
cdz.DzGetMouseYRelative = JassDz["DzGetMouseYRelative"]

--- 界面 - 获取SimpleUI父控件 | 返回: frame
cdz.DzGetSimpleUIParent = JassDz["DzGetSimpleUIParent"]

--- 事件响应 - 获取触发的按键 | 返回: gamekey
cdz.DzGetTriggerKey = JassDz["DzGetTriggerKey"]

--- 事件响应 - 获取触发硬件事件的玩家 | 返回: player
cdz.DzGetTriggerKeyPlayer = JassDz["DzGetTriggerKeyPlayer"]

--- 事件响应 - 获取同步的数据 | 返回: string
cdz.DzGetTriggerSyncData = JassDz["DzGetTriggerSyncData"]

--- 事件响应 - 获取同步数据的玩家 | 返回: player
cdz.DzGetTriggerSyncPlayer = JassDz["DzGetTriggerSyncPlayer"]

--- 事件响应 - 获取同步的数据前缀  | 返回: string
cdz.DzGetTriggerSyncPrefix = JassDz["DzGetTriggerSyncPrefix"]

--- 事件响应 - 获取滚轮变化值 | 返回: integer
cdz.DzGetWheelDelta = JassDz["DzGetWheelDelta"]

--- 获取魔兽窗口高度 | 返回: integer
cdz.DzGetWindowHeight = JassDz["DzGetWindowHeight"]

--- 获取war3窗口宽度 | 返回: integer
cdz.DzGetWindowWidth = JassDz["DzGetWindowWidth"]

--- 获取魔兽窗口X坐标 | 返回: integer
cdz.DzGetWindowX = JassDz["DzGetWindowX"]

--- 获取魔兽窗口Y坐标 | 返回: integer
cdz.DzGetWindowY = JassDz["DzGetWindowY"]

--- 技能按钮 - 设置快捷键文本背景 | 参数: imagefile
cdz.DzSetCommandButtonHotkeyBackground = JassDz["DzSetCommandButtonHotkeyBackground"]

--- 技能按钮 - 显示冷却时间文本 | 参数: boolean, boolean
cdz.DzSetCommandButtonShowCooldown = JassDz["DzSetCommandButtonShowCooldown"]

--- 技能按钮 - 显示快捷键文本 | 参数: boolean, boolean
cdz.DzSetCommandButtonShowHotkey = JassDz["DzSetCommandButtonShowHotkey"]

--- 特效 - 设置始终渲染 | 参数: effect, boolean
cdz.DzSetEffectAlwaysRender = JassDz["DzSetEffectAlwaysRender"]

--- 特效 - 设置绑定特效的缩放大小 | 参数: effect, real, real, real | 返回: boolean
cdz.DzSetEffectAttachedModelScale = JassDz["DzSetEffectAttachedModelScale"]

--- 特效 - 设置特效组黑名单(异步特效坐标专用) | 参数: effect, boolean
cdz.DzSetEffectGroupBlacklist = JassDz["DzSetEffectGroupBlacklist"]

--- 游戏 - 设置人口上限常量 | 参数: integer
cdz.DzSetGameConstantFoodCeiling = JassDz["DzSetGameConstantFoodCeiling"]

--- 游戏 - 设置全局移速 上/下 限 | 参数: real, real, real, real, real, real, real, real, real, real
cdz.DzSetGlobalUnitMinMaxMoveSpeed = JassDz["DzSetGlobalUnitMinMaxMoveSpeed"]

--- 哈希表 - 设置数量上限 | 参数: integer
cdz.DzSetHashtableLimit = JassDz["DzSetHashtableLimit"]

--- 英雄 - 设置主属性 | 参数: unit, integer
cdz.DzSetHeroPrimaryAttribute = JassDz["DzSetHeroPrimaryAttribute"]

--- 英雄 - 设置属性成长 | 参数: unit, AttributeType, real, boolean
cdz.DzSetHeroPrimaryAttributePlus = JassDz["DzSetHeroPrimaryAttributePlus"]

--- 英雄 - 设置主属性类型 | 参数: unit, AttributeType, boolean
cdz.DzSetHeroPrimaryAttributeType = JassDz["DzSetHeroPrimaryAttributeType"]

--- 设置内存数值 | 参数: integer, real
cdz.DzSetMemory = JassDz["DzSetMemory"]

--- 游戏 - 设置攻速上限 | 参数: real, real
cdz.DzSetMinMaxAttackSpeedFactor = JassDz["DzSetMinMaxAttackSpeedFactor"]

--- 游戏 - 设置人口上限常量(自定义) | 参数: integer, integer
cdz.DzSetMiscCustomFoodCeiling = JassDz["DzSetMiscCustomFoodCeiling"]

--- 游戏 - 设置人口维修状态(自定义) | 参数: integer, boolean
cdz.DzSetMiscCustomUpkeepUsage = JassDz["DzSetMiscCustomUpkeepUsage"]

--- 设置鼠标的坐标 | 参数: integer, integer
cdz.DzSetMousePos = JassDz["DzSetMousePos"]

--- 游戏 - 设置移速可叠加 | 参数: boolean
cdz.DzSetMoveSpeedBonusesStack = JassDz["DzSetMoveSpeedBonusesStack"]

--- 游戏 - 设置玩家寻路上限 | 参数: player, integer, integer, integer, integer
cdz.DzSetPlayerPathFindingLimit = JassDz["DzSetPlayerPathFindingLimit"]

--- 触发器 - 清除所有事件 | 参数: trigger
cdz.DzTriggerClearEvents = JassDz["DzTriggerClearEvents"]

--- 数据同步 | 参数: string, boolean
cdz.DzTriggerRegisterSyncData = JassDz["DzTriggerRegisterSyncData"]

--- 平台 - 修改商城道具冷却 | 参数: player, integer, real
cdz.DzAPI_Map_ChangeStoreItemCoolDown = JassDz["DzAPI_Map_ChangeStoreItemCoolDown"]

--- 平台 - 修改商城道具数量 | 参数: player, integer, integer
cdz.DzAPI_Map_ChangeStoreItemCount = JassDz["DzAPI_Map_ChangeStoreItemCount"]

--- 玩家所属公会[废弃] | 参数: player | 返回: string
cdz.DzAPI_Map_GetGuildName = JassDz["DzAPI_Map_GetGuildName"]

--- 玩家在公会的职责【废弃】 | 参数: player | 返回: integer
cdz.DzAPI_Map_GetGuildRole = JassDz["DzAPI_Map_GetGuildRole"]

--- 平台 - 获取玩家平台ID | 参数: player | 返回: string
cdz.DzAPI_Map_GetUserID = JassDz["DzAPI_Map_GetUserID"]

--- 平台 - 打开/关闭商城 | 参数: player, boolean
cdz.DzAPI_Map_ToggleStore = JassDz["DzAPI_Map_ToggleStore"]

--- 平台 - 更新玩家英雄信息 | 参数: player, unit
cdz.DzAPI_Map_UpdatePlayerHero = JassDz["DzAPI_Map_UpdatePlayerHero"]

--- 单位 - 屏蔽选中模式的命令 | 参数: integer, boolean
cdz.DzBlockSelectModeCommand = JassDz["DzBlockSelectModeCommand"]

--- 地形 - 修改地形 | 参数: integer, integer, integer, real, integer
cdz.DzChangeTerrain = JassDz["DzChangeTerrain"]

--- 内存 - 清除Jass字符串未引用表
cdz.DzClearJassStringNotReference = JassDz["DzClearJassStringNotReference"]

--- 转换世界坐标为屏幕深度[同步] | 参数: real, real, real | 返回: real
cdz.DzConvertWorldPositionDepth = JassDz["DzConvertWorldPositionDepth"]

--- 转换世界坐标为屏幕x坐标[同步] | 参数: real, real, real | 返回: real
cdz.DzConvertWorldPositionX = JassDz["DzConvertWorldPositionX"]

--- 转换世界坐标为屏幕y坐标[同步] | 参数: real, real, real | 返回: real
cdz.DzConvertWorldPositionY = JassDz["DzConvertWorldPositionY"]

--- 调试 - 输出调试字符串 | 参数: string
cdz.DzDebugString = JassDz["DzDebugString"]

--- 设置可破坏物位置 [BZAPI] | 参数: destructable, real, real
cdz.DzDestructablePosition = JassDz["DzDestructablePosition"]

--- 游戏 - 禁用攻速限制 | 参数: boolean
cdz.DzDisableAttackSpeedLimit = JassDz["DzDisableAttackSpeedLimit"]

--- 游戏 - 禁用加载完毕按键继续
cdz.DzDisableLoadingPressAKey = JassDz["DzDisableLoadingPressAKey"]

--- 游戏 - 禁用移除多余死亡英雄
cdz.DzDisableRemoveExtraDeadHero = JassDz["DzDisableRemoveExtraDeadHero"]

--- 异步执行函数 | 参数: string
cdz.DzExecuteFunc = JassDz["DzExecuteFunc"]

--- 特效组 - 选取做多动作 | 参数: dzeffectgroup
cdz.DzForEffectGroup = JassDz["DzForEffectGroup"]

--- 单位组 - 添加编队单位到单位组 | 参数: group, player, integer, boolean
cdz.DzGroupEnumPlayerControlGroup = JassDz["DzGroupEnumPlayerControlGroup"]

--- 特效组 - 转换 handle ID 为特效组 | 参数: integer | 返回: dzeffectgroup
cdz.DzHandle2EffectGroup = JassDz["DzHandle2EffectGroup"]

--- 鼠标是否在游戏内 | 返回: boolean
cdz.DzIsMouseOverUI = JassDz["DzIsMouseOverUI"]

--- 投射物 - 发射炮火 | 参数: unit, unit, real, real, modelfile, integer, rgba2color, real, real, real, real, real, attacktype, damagetype, weapontype, real, real, boolean, integer, real, TargetFlags, real, real, real, real, real
cdz.DzLaunchArtillery = JassDz["DzLaunchArtillery"]

--- 投射物 - 发射炮火(穿透) | 参数: unit, unit, real, real, modelfile, integer, rgba2color, real, real, real, real, real, attacktype, damagetype, weapontype, real, real, boolean, integer, real, TargetFlags, real, real, real, real, real, real, real, real
cdz.DzLaunchArtilleryLine = JassDz["DzLaunchArtilleryLine"]

--- 投射物 - 发射箭矢 | 参数: unit, unit, modelfile, integer, rgba2color, real, real, real, real, real, attacktype, damagetype, weapontype, real, real, boolean, boolean, boolean, boolean, integer
cdz.DzLaunchMissile = JassDz["DzLaunchMissile"]

--- 投射物 - 发射箭矢(弹射) | 参数: unit, unit, modelfile, integer, rgba2color, real, real, real, real, real, attacktype, damagetype, weapontype, real, real, boolean, boolean, boolean, boolean, integer, TargetFlags, integer, real, real
cdz.DzLaunchMissileBounce = JassDz["DzLaunchMissileBounce"]

--- 投射物 - 发射技能投射物(腐臭蜂群) | 参数: unit, modelfile, integer, rgba2color, real, real, real, degree, real, real, real, attacktype, damagetype, weapontype, real, integer, TargetFlags, real, real, real, buffcode
cdz.DzLaunchMissileCarrionSwarmEx = JassDz["DzLaunchMissileCarrionSwarmEx"]

--- 投射物 - 发射箭矢(穿透) | 参数: unit, unit, modelfile, integer, rgba2color, real, real, real, real, real, attacktype, damagetype, weapontype, real, real, boolean, boolean, boolean, boolean, integer, TargetFlags, real, real, real
cdz.DzLaunchMissileLine = JassDz["DzLaunchMissileLine"]

--- 投射物 - 发射箭矢(溅射) | 参数: unit, unit, modelfile, integer, rgba2color, real, real, real, real, real, attacktype, damagetype, weapontype, real, real, boolean, boolean, boolean, boolean, integer, TargetFlags, real, real, real, real, real
cdz.DzLaunchMissileSplash = JassDz["DzLaunchMissileSplash"]

--- 哈希表 - 读取Handle ID | 参数: hashtable, integer, integer | 返回: integer
cdz.DzLoadHandleId = JassDz["DzLoadHandleId"]

--- 界面 - 获取多面板Frame | 参数: multiboard | 返回: frame
cdz.DzMultiboardGetFrame = JassDz["DzMultiboardGetFrame"]

--- 哈希表 - 保存Handle ID | 参数: hashtable, integer, integer, integer
cdz.DzSaveHandleId = JassDz["DzSaveHandleId"]

--- 哈希表 - 保存Handle ID(指定类型) | 参数: hashtable, integer, integer, integer, integer
cdz.DzSaveHandleIdEx = JassDz["DzSaveHandleIdEx"]

--- 界面 - SimpleFrame是否显示 | 参数: frame | 返回: boolean
cdz.DzSimpleFrameIsVisible = JassDz["DzSimpleFrameIsVisible"]

--- 界面 - 从注册表移除SimpleFrame | 参数: frame
cdz.DzSimpleFrameRemoveFromRegistry = JassDz["DzSimpleFrameRemoveFromRegistry"]

--- 同步游戏数据（指定长度） | 参数: string, string, integer
cdz.DzSyncBuffer = JassDz["DzSyncBuffer"]

--- 同步游戏数据 | 参数: string, string
cdz.DzSyncData = JassDz["DzSyncData"]

--- 同步游戏数据（立即） | 参数: string, string
cdz.DzSyncDataImmediately = JassDz["DzSyncDataImmediately"]

--- 文字 - 获取漂浮文字起始透明度 | 参数: texttag | 返回: integer
cdz.DzTextTagGetStartAlpha = JassDz["DzTextTagGetStartAlpha"]

--- 界面 - 获取计时器对话框Frame | 参数: timerdialog | 返回: frame
cdz.DzTimerDialogGetFrame = JassDz["DzTimerDialogGetFrame"]

--- 特效 - 更新坐标 | 参数: effect
cdz.DzUpdateEffectSmartPosition = JassDz["DzUpdateEffectSmartPosition"]

--- Hook - Hook函数返回布尔值 | 参数: integer, string, boolean | 返回: boolean
cdz.KKHookCodeBoolean = JassDz["KKHookCodeBoolean"]

--- Hook - Hook函数返回code | 参数: integer, string, code | 返回: code
cdz.KKHookCodeCode = JassDz["KKHookCodeCode"]

--- Hook - Hook函数返回handle | 参数: integer, string, handle | 返回: handle
cdz.KKHookCodeHandle = JassDz["KKHookCodeHandle"]

--- Hook - Hook函数返回整数 | 参数: integer, string, integer | 返回: integer
cdz.KKHookCodeInteger = JassDz["KKHookCodeInteger"]

--- Hook - Hook函数返回实数 | 参数: integer, string, real | 返回: real
cdz.KKHookCodeReal = JassDz["KKHookCodeReal"]

--- Hook - Hook函数返回字符串 | 参数: integer, string, string | 返回: string
cdz.KKHookCodeString = JassDz["KKHookCodeString"]

--- Hook - Hook函数无返回值 | 参数: integer, string
cdz.KKHookCodeVoid = JassDz["KKHookCodeVoid"]

--- UI - 混合技能按钮图标 | 参数: integer, integer, integer, integer, integer, integer, string
cdz.EXBlendButtonIcon = JassDz["EXBlendButtonIcon"]

--- UI - 声明技能按钮图标 | 参数: integer, integer, integer, integer, integer, integer, string, string, string, string, string, string, string
cdz.EXDclareButtonIcon = JassDz["EXDclareButtonIcon"]

--- 重置变换 [JAPI] [New!] | 参数: effect
cdz.EXEffectMatReset = JassDz["EXEffectMatReset"]

--- 绕X轴旋转 [JAPI] [New!] | 参数: effect, degree
cdz.EXEffectMatRotateX = JassDz["EXEffectMatRotateX"]

--- 绕Y轴旋转 [JAPI] [New!] | 参数: effect, degree
cdz.EXEffectMatRotateY = JassDz["EXEffectMatRotateY"]

--- 绕Z轴旋转 [JAPI] [New!] | 参数: effect, degree
cdz.EXEffectMatRotateZ = JassDz["EXEffectMatRotateZ"]

--- 缩放 [JAPI] [New!] | 参数: effect, real, real, real
cdz.EXEffectMatScale = JassDz["EXEffectMatScale"]

--- 技能 - 获取技能数据(字符串)[JAPI] | 参数: ability, integer, integer | 返回: string
cdz.EXGetAbilityString = JassDz["EXGetAbilityString"]

--- 大小 [JAPI] [New!] | 参数: effect | 返回: real
cdz.EXGetEffectSize = JassDz["EXGetEffectSize"]

--- X轴坐标 [JAPI] [New!] | 参数: effect | 返回: real
cdz.EXGetEffectX = JassDz["EXGetEffectX"]

--- Y轴坐标 [JAPI] [New!] | 参数: effect | 返回: real
cdz.EXGetEffectY = JassDz["EXGetEffectY"]

--- 高度 [JAPI] [New!] | 参数: effect | 返回: real
cdz.EXGetEffectZ = JassDz["EXGetEffectZ"]

--- 对象 - 根据HandleID获取对象 | 参数: integer | 返回: handle
cdz.EXGetObject = JassDz["EXGetObject"]

--- 单位 - 获取单位数组数据(字符串) | 参数: unit, integer, integer | 返回: string
cdz.EXGetUnitArrayString = JassDz["EXGetUnitArrayString"]

--- 单位 - 获取单位数据(整数) | 参数: unit, integer, integer | 返回: integer
cdz.EXGetUnitInteger = JassDz["EXGetUnitInteger"]

--- 单位 - 获取单位数据(实数) | 参数: unit, integer, integer | 返回: real
cdz.EXGetUnitReal = JassDz["EXGetUnitReal"]

--- 单位 - 获取单位数据(字符串) | 参数: unit, integer, integer | 返回: string
cdz.EXGetUnitString = JassDz["EXGetUnitString"]

--- 技能 - 设置技能数据(字符串)[JAPI] | 参数: ability, integer, integer, string | 返回: boolean
cdz.EXSetAbilityString = JassDz["EXSetAbilityString"]

--- 设置特效大小 [JAPI] [New!] | 参数: effect, real
cdz.EXSetEffectSize = JassDz["EXSetEffectSize"]

--- 设置特效动画速度 [JAPI] [New!] | 参数: effect, real
cdz.EXSetEffectSpeed = JassDz["EXSetEffectSpeed"]

--- 移动特效到坐标 [JAPI] [New!] | 参数: effect, real, real
cdz.EXSetEffectXY = JassDz["EXSetEffectXY"]

--- 设置特效高度 [JAPI] [New!] | 参数: effect, real
cdz.EXSetEffectZ = JassDz["EXSetEffectZ"]

--- 设置单位的碰撞类型 [JAPI] [New!] | 参数: onoffoption, unit, CollisionType
cdz.EXSetUnitCollisionType = JassDz["EXSetUnitCollisionType"]

--- 设置单位面向角度 [JAPI] [New!] | 参数: unit, degree
cdz.EXSetUnitFacing = JassDz["EXSetUnitFacing"]

--- 设置单位的移动类型 [JAPI] [New!] | 参数: unit, MoveType
cdz.EXSetUnitMoveType = JassDz["EXSetUnitMoveType"]

--- 单位 - 设置单位数据(实数) [JAPI] | 参数: unit, integer, integer, real
cdz.EXSetUnitReal = JassDz["EXSetUnitReal"]

--- 单位 - 设置单位数据(字符串) [JAPI] | 参数: unit, integer, integer, string
cdz.EXSetUnitString = JassDz["EXSetUnitString"]

--- 哈希表 - 读取特效组 | 参数: hashtable, integer, integer | 返回: dzeffectgroup
cdz.LoadDzEffectGroupHandle = JassDz["LoadDzEffectGroupHandle"]

--- 哈希表 - 保存特效组 | 参数: hashtable, integer, integer, dzeffectgroup
cdz.SaveDzEffectGroupHandle = JassDz["SaveDzEffectGroupHandle"]
