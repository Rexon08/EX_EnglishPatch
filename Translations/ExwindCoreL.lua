---@diagnostic disable: undefined-global
-- Additive enUS entries for ExwindLocale (shared by ExwindCore +
-- ExwindTools). Source ships a substantial enUS file; this file only
-- adds gaps or shorter/better English overrides. Keys are real UTF-8 zh.

local _, ns = ...

ns.Translations.ExwindCoreL = {
    -- Add rows here when an audit finds an L[...] string the source's
    -- enUS file doesn't cover.
    ["设置中心"]            = "Settings",
    ["首页概览"]            = "Home",
    ["模块管理"]            = "Modules",
    ["状态诊断"]            = "Diagnostics",
    ["配置管理"]            = "Profiles",

    -- InterruptTracker config panel
    ["通用设置"]                       = "General",
    ["启用"]                           = "Enable",
    ["锁定位置"]                       = "Lock Position",
    ["预览模式"]                       = "Preview Mode",
    ["重置位置"]                       = "Reset Position",
    ["整体水平位置"]                   = "Position X",
    ["整体垂直位置"]                   = "Position Y",
    ["计时条"]                         = "Timer Bars",
    ["垂直间距"]                       = "Spacing",
    ["增长方向"]                       = "Grow Direction",
    ["最大显示数量"]                   = "Max Bars",
    ["使用职业颜色"]                   = "Use Class Color",
    ["计时条外观"]                     = "Bar Appearance",
    ["玩家名称"]                       = "Player Name",
    ["显示玩家名字"]                   = "Show Player Name",
    ["名字对齐方式"]                   = "Name Alignment",
    ["玩家名字文字设置"]               = "Name Font",
    ["冷却时间设置"]                   = "Cooldown Text",
    ["显示剩余时间"]                   = "Show Remaining Time",
    ["冷却结束显示就绪"]               = "Show Ready Text",
    ["就绪文字"]                       = "Ready Text",
    ["时间文字设置"]                   = "Timer Font",
    ["排序优先级"]                     = "Sort Priority",
    ["CD就绪时按角色优先级排序，CD冷却中按剩余时间排序（时间短优先）"]
                                       = "When ready, sort by role priority. When on CD, sort by remaining time (shortest first).",
    ["坦克优先级"]                     = "Tank Priority",
    ["治疗优先级"]                     = "Healer Priority",
    ["DPS优先级"]                      = "DPS Priority",
    ["近战DPS优先于远程DPS"]           = "Melee DPS before Ranged DPS",
    ["依附小队框体"]                   = "Attach to Party Frame",
    ["启用后，打断条组将整体依附到小队框体的上方或下方"]
                                       = "Anchors the bar group above or below the party frame.",
    ["启用依附到小队框体"]             = "Enable Attach",
    ["目标框架"]                       = "Target Frame",
    ["依附到目标框架的"]               = "Attach Side",
    ["水平偏移"]                       = "Offset X",
    ["垂直偏移"]                       = "Offset Y",
    ["自适应宽度"]                     = "Auto Width",
    ["打断监控 (计时条)"]              = "Interrupt Tracker (Bars)",
    ["实时监控队友打断技能冷却状态（计时条样式）"]
                                       = "Live tracker of party interrupt cooldowns (bar layout).",

    -- ExM+Info.SpellInfo settings panel (M+ Mob Spells)
    ["大米法术手册 (Mythic Spell Guide)"] = "M+ Spell Guide",
    ["此模块提供了一个极度详细的地下城百科，涵盖所有层数下的怪物技能数值。"]
                                          = "Detailed dungeon encyclopedia covering mob spell values at every keystone level.",
    ["立即打开手册"]                      = "Open Guide",
    ["数值模拟 (全局同步)"]               = "Value Simulation (global)",
    ["模拟层数"]                          = "Simulated Level",
    ["注：模拟层数与“大秘境伤害计算”模块共享数据。"]
                                          = "Note: Simulated level is shared with the Mythic Damage Calc module.",
    ["搜索怪物..."]                       = "Search Mobs...",
    ["缓存中..."]                         = "Loading...",
    ["未知生物"]                          = "Unknown",

    -- ExTools.PlayerPosition config panel (hardcoded layout in source)
    ["玩家角色定位标记"] = "Player Position Marker",
    ["在屏幕中心显示标记，支持超出距离变色"] = "Shows a marker at screen center with out-of-range color support.",
    ["优先加载本地材质(PNG)。若文件缺失，自动回退到纯代码绘图模式。"]
        = "Prefer local PNG textures. Falls back to code-drawn shapes if files are missing.",
    ["启用指示器"] = "Enable Marker",
    ["图形样式"] = "Shape Style",
    ["缩放"] = "Scale",
    ["正常颜色"] = "Normal Color",
    ["X 轴偏移"] = "X Offset",
    ["Y 轴偏移"] = "Y Offset",
    ["距离监控"] = "Range Monitor",
    ["当超出距离时 图标变色 (空=自动使用专精预设)"]
        = "Changes marker color when out of range. Leave blank to use the spec preset.",
    ["距离判定法术(ID)"] = "Range Spell (ID)",
    ["默认: 专精预设"] = "Default: spec preset",
    ["超距颜色"] = "Out-of-Range Color",
    ["显示条件"] = "Display Conditions",
    ["触发场景"] = "Visibility",
    ["战斗中显示"] = "Show in Combat",
    ["战斗外显示"] = "Show out of Combat",
    ["仅副本内"] = "Instances only",
    ["专精过滤 (仅在勾选的专精下启用)"] = "Spec Filter (enabled only for checked specs)",
    ["启用专精"] = "Enabled Specs",

    -- ExTools.MiniTools / MythicDamage values captured by registered layouts
    ["左下"] = "Bottom Left",
    ["左上"] = "Top Left",
    ["右下"] = "Bottom Right",
    ["右上"] = "Top Right",
    ["中下"] = "Bottom Center",
    ["提示：10层以上会额外应用基础加成：首领 1.15x，小怪 1.2x。\n此设置会直接影响 MDT 增强和法术详情页显示的数值。"]
        = "Tip: Above +10, an extra base multiplier is applied: bosses 1.15x, trash 1.2x.\nThis directly affects MDT enhancements and spell-detail values.",
    ["重置当前模块设置"] = "Reset Module Settings",

    -- ExTools.TransformTimer (Devourer Demon Hunter transform timer)
    ["噬灭变身计时"] = "Devourer Transform Timer",
    ["玩家施放指定变身法术后，在屏幕显示持续秒数。"]
        = "Shows the elapsed seconds on screen after the player casts the assigned transform spell.",
    ["监控玩家施放 1217605，并通过 473662 图标变化判断变身开始与结束。结束后停表，不隐藏。"]
        = "Watches casts of spell 1217605 and uses icon 473662 changes to detect transform start and end. Stops the timer on end without hiding.",
    ["变身存在时"] = "While Active",
    ["变身消失时"] = "While Inactive",
    ["褪色"]       = "Faded",
    ["变身图标"]   = "Transform Icon",
    ["计时文字"]   = "Timer Text",
    ["图标高亮"]   = "Icon Glow",

    -- ExTools.MiniTools — section headers (numbered list on the page)
    ["6. 批量购买助手"]      = "6. Bulk Buy Helper",
    ["7. 进本重置伤害"]      = "7. Reset Damage on Instance Enter",
    ["8. 战斗提示"]          = "8. Combat Alerts",
    ["9. 修改战网名称"]      = "9. Custom BattleTag Name",
    ["10. 自动修理"]         = "10. Auto Repair",
    ["11. 地下城手册增强"]   = "11. Encounter Journal Enhancements",
    ["12. 商人界面增强"]     = "12. Merchant UI Enhancements",
    ["13. 宏界面增强"]       = "13. Macro UI Enhancements",

    -- ExwindToolsUI home page — sponsor / feedback / actions panel
    ["赞助支持"]                                                       = "Sponsor",
    ["ExwindTools 和 EXBoss 是免费项目；赞助不会解锁额外功能，所有人使用同一版本。"]
        = "ExwindTools and EXBoss are free projects. Donations do not unlock additional features; everyone uses the same version.",
    ["复制赞助链接"]                                                   = "Copy Sponsor Link",
    ["点击输入框可全选，按 Ctrl+C 复制链接。"]                          = "Click the box to select all, then Ctrl+C to copy.",
    ["遇到问题、配置建议或缺少选项都可以反馈。"]                       = "Report bugs, config suggestions, or missing options.",
    ["这些操作会直接影响插件配置。"]                                   = "These actions directly affect addon configuration.",
    ["当前模块"]                                                       = "Current Module",
    ["你将重置%s模块设置，并重载。是否确定？"]                         = "Reset settings for the %s module and reload. Continue?",

    -- ExClass.NoMoveSkillAlert (movement skill cooldown alert)
    ["当位移技能CD时 在屏幕上显示文字提醒。"]   = "Shows on-screen text when a movement skill is on cooldown.",
    ["显示CD时的内容 (用 %t 代表时间)"]         = "Cooldown text (use %t for the time)",
    ["显示内容"]                                = "Display Text",

    -- ExClass.BrewmasterStagger
    ["显示酒仙武僧的酒池百分比，并支持独立满条上限与阈值变色。"]
        = "Shows Brewmaster Stagger percent, with custom max-fill and threshold colors.",
    ["隐藏条体"] = "Hide Bar",
    ["文字对齐"] = "Text Align",
    ["文字设置"] = "Text Settings",

    -- ExTools.InstanceNote (per-instance note panel)
    ["启用功能"]           = "Enable",
    ["地下城"]             = "Dungeon",
    ["团队副本"]           = "Raid",
    ["选择副本"]           = "Select Instance",
    ["选择首领"]           = "Select Boss",
    ["备注内容"]           = "Note Text",
    ["首领备注预览"]       = "Boss Note Preview",
    ["这里显示副本备注内容"] = "Dungeon note text appears here.",
    ["这里显示首领备注内容"] = "Boss note text appears here.",

    -- ExM+.MythicCast (mythic-cast bar visibility option)
    ["隐藏92级读条"] = "Hide Level 92 Casts",
    ["坦克职责下不显示"] = "Hide for Tank Role",
    ["玩家目标提示"]     = "Player Target Indicator",
    ["提示材质"]         = "Indicator Texture",
    ["提示大小"]         = "Indicator Size",
    ["提示X偏移"]        = "Indicator X Offset",
    ["提示Y偏移"]        = "Indicator Y Offset",

    -- ExTools.PveKeystoneInfo
    ["在 PVEFrame 上显示玩家与队友钥石信息。"] = "Shows player and party keystone info on the PVE frame.",
    ["队友"]                                   = "Party Member",

    -- ExTools.ChatChannelBar
    ["聊天框打开失败: "] = "Failed to open chat: ",

    -- ExTools.StreamerTools (Edit Mode overlay titles)
    ["战斗计时器"] = "Combat Timer",
    ["战复计时"]   = "Battle Res Timer",
    ["怪物数量"]   = "Mob Count",

    -- ExwindToolsUI module-card help tip
    ["点击卡片切换启用/禁用，点击 Settings 打开设置。禁用会立即停用；启用未初始化模块仍需 /reload。"]
        = "Click a card to toggle enable/disable; click Settings to open its settings. Disable applies immediately; enabling an uninitialized module still requires /reload.",

    -- Raw layout/default strings surfaced by the full source inventory.
    ["新组件"] = "New Component",
    ["保存设置"] = "Save Settings",
    ["v26.5.3.1404 更新日志"] = "v26.5.3.1404 Changelog",
    ["v26.5.3.0737 更新日志"] = "v26.5.3.0737 Changelog",
    ["大脚世界频道"] = "BigFoot World Channel",

    -- Length-tight overrides for grid labels whose source enUS overflows
    -- its column width. Mirrored in LabelOverrides for the enUS path.
    ["图标路径/ID |cffff2628优先使用法术ID(如有)|r"]
        = "Icon Path/ID |cffff2628(Spell ID wins)|r",
    ["打断CD时隐藏可断条"]            = "Hide bars on CD",
    ["打断CD时颜色"]                  = "On-CD Color",
    ["打断CD剩余几秒时显示(左边颜色)"] = "Left-color threshold (s)",
    ["举例:打断CD剩余2秒时会显示左边颜色的条 打断CD好的瞬间会变色"]
        = "Example: at 2s left, bar shows left color; turns ready color when CD ends.",
    ["启用明志灵药冷却监控"]                            = "Track Elixir of Determination CD",
    ["启用：进入/离开战斗时屏幕中心显示文字提示"]      = "Enable: center-screen text on combat enter/leave",

    -- PlayerStats default row labels — captured before locale force.
    ["%主属性"] = "%Main Stat",
    ["暴击"] = "Crit",
    ["急速"] = "Haste",
    ["精通"] = "Mast",
    ["全能"] = "Vers",
    ["移速"] = "Move",

    -- MicroMenu module — disabled in source; entries kept for parity.
    ["（无）"] = "(None)",
    ["角色"] = "Character",
    ["法术书/天赋"] = "Spellbook / Talents",
    ["成就"] = "Achievements",
    ["任务日志"] = "Quest Log",
    ["公会/社区"] = "Guild / Communities",
    ["寻求组队"] = "Group Finder",
    ["收藏"] = "Collections",
    ["冒险指南"] = "Adventure Guide",
    ["专业技能"] = "Professions",
    ["家园"] = "Housing",
    ["自定义命令"] = "Custom Command",
    ["动作"] = "Action",
    ["/目标 boss1"] = "/target boss1",
    ["提示文字"] = "Tooltip Text",
    ["留空不显示"] = "Leave blank to hide",
    ["微型选单"] = "Micro Menu",
    ["顶端微型选单：中间时钟，左右各有可配置图标。图案与动作完全独立设置。"]
        = "Top micro menu: center clock with configurable icons on both sides. Icon art and actions are configured independently.",
    ["基础设置"] = "Basic Settings",
    ["显示背景"] = "Show Background",
    ["整体缩放"] = "Overall Scale",
    ["背景透明度"] = "Background Alpha",
    ["图标风格"] = "Icon Style",
    ["整体风格"] = "Overall Style",
    ["时间文字"] = "Time Text",
    ["时间格式"] = "Time Format",
    ["显示秒数"] = "Show Seconds",
    ["字体大小（0=自动）"] = "Font Size (0 = auto)",
    ["时间 X 偏移"] = "Time X Offset",
    ["时间 Y 偏移"] = "Time Y Offset",
    ["X 偏移"] = "X Offset",
    ["Y 偏移"] = "Y Offset",
    ["左侧图标槽位"] = "Left Icon Slots",
    ["左侧图标数量"] = "Left Icon Count",
    ["右侧图标槽位"] = "Right Icon Slots",
    ["右侧图标数量"] = "Right Icon Count",
}
