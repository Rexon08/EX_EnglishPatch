---@diagnostic disable: undefined-global
-- Last-resort literal-string replacements for code paths that bypass
-- L[...]. Real UTF-8 zh keys only.

local _, ns = ...

ns.Translations.ModuleStrings = {
    -- Hardcoded fallback inside the spell-info module; bypasses L[].
    ["技能 "] = "Spell ",
    ["事件 "] = "Event ",
}

-- Visible UI strings captured before locale force, or used directly as
-- dropdown/display values. Display-only — owner DB tables keep originals.
ns.Translations.ModuleStrings.DisplayText = {
    -- Shared controls / dropdown values
    ["首页"] = "Home",
    ["语音/配置"] = "Voice / Config",
    ["副本(首领)"] = "Dungeons (Boss)",
    ["小怪CD"] = "Trash CD",
    ["设置"] = "Settings",
    ["导入导出"] = "Import / Export",
    ["更新日志"] = "Changelog",
    ["开启编辑模式"] = "Enable Edit Mode",
    ["关闭编辑模式"] = "Disable Edit Mode",
    ["重置当前模块设置"] = "Reset Module Settings",
    ["预设配置"] = "Preset Config",
    ["请选择配置"] = "Select a profile",
    ["12.0大秘境"] = "12.0 Mythic+",
    ["12.0团本"] = "12.0 Raid",
    ["其他"] = "Other",
    ["其他方案"] = "Other Scheme",
    ["提前5秒"] = "5 sec early",
    ["姓名版"] = "Nameplate",
    ["圆环"] = "Ring",
    ["竖条"] = "Bun Bar",
    ["计时条"] = "Timer Bar",
    ["施法检测"] = "Cast Detection",
    ["语音包标签"] = "Voice Pack Label",
    ["控断钢条"] = "CC / Kick Bar",
    ["延迟"] = "Delay",
    ["提前"] = "Early",
    ["秒"] = "sec",
    ["首次施放时间："] = "First cast: ",
    ["CD时间："] = "Cooldown: ",
    ["施法进度条"] = "Cast Progress Bar",
    ["中央圆环"] = "Center Ring",
    ["开启暴雪中央文字预警（注意：如果关闭会导致语音不工作）"] =
        "Enable Blizzard center-screen alerts (voice may stop if disabled)",

    -- EXSP M+ Spell Details slider: source uses literal strings and a
    -- "|cffffd100%d|r 层" formatter, bypassing the source's enUS L entry.
    ["模拟层数"] = "Simulated Level",
    ["|r 层"] = "|r Lvl",

    -- Anchor / position values
    ["左下"] = "Bottom Left",
    ["左上"] = "Top Left",
    ["右下"] = "Bottom Right",
    ["右上"] = "Top Right",
    ["中下"] = "Bottom Center",
    ["上方"] = "Above",
    ["下方"] = "Below",
    ["战斗中显示"] = "Show in Combat",
    ["战斗外显示"] = "Show out of Combat",
    ["仅副本内"] = "Instances only",

    -- Player Position page
    ["玩家角色定位标记"] = "Player Position Marker",
    ["优先加载本地材质(PNG)。若文件缺失，自动回退到纯代码绘图模式。"] =
        "Prefer local PNG textures. Falls back to code-drawn shapes if files are missing.",
    ["启用指示器"] = "Enable Marker",
    ["图形样式"] = "Shape Style",
    ["方块 (Square)"] = "Square",
    ["十字 (Cross)"] = "Cross",
    ["圆形 (Circle)"] = "Circle",
    ["圆环 (Ring)"] = "Ring",
    ["菱形 (Diamond)"] = "Diamond",
    ["缩放"] = "Scale",
    ["正常颜色"] = "Normal Color",
    ["X 轴偏移"] = "X Offset",
    ["Y 轴偏移"] = "Y Offset",
    ["距离监控"] = "Range Monitor",
    ["当超出距离时 图标变色 (空=自动使用专精预设)"] =
        "Changes marker color when out of range. Leave blank to use the spec preset.",
    ["距离判定法术(ID)"] = "Range Spell (ID)",
    ["默认: 专精预设"] = "Default: spec preset",
    ["超距颜色"] = "Out-of-Range Color",
    ["显示条件"] = "Display Conditions",
    ["触发场景"] = "Visibility",
    ["专精过滤 (仅在勾选的专精下启用)"] = "Spec Filter (enabled only for checked specs)",
    ["启用专精"] = "Enabled Specs",

    -- Mythic Damage page
    ["提示：10层以上会额外应用基础加成：首领 1.15x，小怪 1.2x。\n此设置会直接影响 MDT 增强和法术详情页显示的数值。"] =
        "Tip: Above +10, an extra base multiplier is applied: bosses 1.15x, trash 1.2x.\nThis directly affects MDT enhancements and spell-detail values.",

    -- Entry/status notices via ExBoss.Print.Say (bypasses locale lookup).
    ["进入 |cffffd100萨隆矿坑|r 小怪内置CD已载入,该功能测试中 如遇到问题请反馈给我 谢谢!"] =
        "Entered |cffffd100Pit of Saron|r; trash built-in CDs loaded. This feature is in testing; please report any issues.",
    ["进入 |cffffd100通天峰|r 小怪内置CD已载入,该功能测试中 如遇到问题请反馈给我 谢谢!"] =
        "Entered |cffffd100Skyreach|r; trash built-in CDs loaded. This feature is in testing; please report any issues.",
    ["进入 |cffffd100执政团之座|r 小怪内置CD已载入,该功能测试中 如遇到问题请反馈给我 谢谢!"] =
        "Entered |cffffd100Seat of the Triumvirate|r; trash built-in CDs loaded. This feature is in testing; please report any issues.",
    ["进入 |cffffd100艾杰斯亚学院|r 小怪内置CD已载入,该功能测试中 如遇到问题请反馈给我 谢谢!"] =
        "Entered |cffffd100Algeth'ar Academy|r; trash built-in CDs loaded. This feature is in testing; please report any issues.",
    ["进入 |cffffd100风行者之塔|r 小怪内置CD已载入,该功能测试中 如遇到问题请反馈给我 谢谢!"] =
        "Entered |cffffd100Windrunner Spire|r; trash built-in CDs loaded. This feature is in testing; please report any issues.",
    ["进入 |cffffd100魔导师平台|r 小怪内置CD已载入,该功能测试中 如遇到问题请反馈给我 谢谢!"] =
        "Entered |cffffd100Magisters' Terrace|r; trash built-in CDs loaded. This feature is in testing; please report any issues.",
    ["进入 |cffffd100迈萨拉洞窟|r 小怪内置CD已载入,该功能测试中 如遇到问题请反馈给我 谢谢!"] =
        "Entered |cffffd100Maisara Caverns|r; trash built-in CDs loaded. This feature is in testing; please report any issues.",
    ["进入 |cffffd100节点希纳斯|r 小怪内置CD已载入,该功能测试中 如遇到问题请反馈给我 谢谢!"] =
        "Entered |cffffd100Nexus-Point Xenas|r; trash built-in CDs loaded. This feature is in testing; please report any issues.",
    ["2号BOSS |cffffd100狗跳点名模块|r已载入 该功能测试中 仅供参考!"] =
        "Boss 2 |cffffd100Dog Jump Callout|r loaded. This feature is in testing and for reference only.",
    ["施法条调试 "] = "Cast bar debug ",
    ["已开启"] = "enabled",
    ["已关闭"] = "disabled",
    ["AI轴语音调试已开启 encounter="] = "AI timeline voice debug enabled encounter=",
    ["AI轴语音调试已关闭"] = "AI timeline voice debug disabled",
    ["小怪测试等级偏移已关闭"] = "Trash test level offset disabled",
    ["小怪测试等级偏移: "] = "Trash test level offset: ",
    ["，/reload 后自动失效"] = ", expires automatically after /reload",
    ["小怪匹配调试模块未就绪"] = "Trash matching debug module is not ready",
    ["小怪匹配调试缓存已清空"] = "Trash matching debug cache cleared",
    ["小怪语音调试已开启"] = "Trash voice debug enabled",
    ["小怪语音调试已关闭"] = "Trash voice debug disabled",
    ["小怪语音调试模块未就绪"] = "Trash voice debug module is not ready",
    ["小怪语音调试缓存已清空"] = "Trash voice debug cache cleared",

    -- Voice/profile text captured at file load
    ["团本坦克"] = "Raid Tank",
    ["团本DPS"] = "Raid DPS",
    ["团本治疗"] = "Raid Healer",
    ["大米坦克"] = "M+ Tank",
    ["大米DPS"] = "M+ DPS",
    ["大米治疗"] = "M+ Healer",
    ["团本方案"] = "Raid Profiles",
    ["大米方案"] = "Mythic+ Profiles",
    ["配置方案"] = "Profiles",
    ["当前职责："] = "Current role: ",

    -- Common class/spec display values used in multiselect widgets.
    ["战士"] = "Warrior",
    ["圣骑士"] = "Paladin",
    ["猎人"] = "Hunter",
    ["潜行者"] = "Rogue",
    ["牧师"] = "Priest",
    ["死亡骑士"] = "Death Knight",
    ["萨满祭司"] = "Shaman",
    ["法师"] = "Mage",
    ["术士"] = "Warlock",
    ["武僧"] = "Monk",
    ["德鲁伊"] = "Druid",
    ["恶魔猎手"] = "Demon Hunter",
    ["唤魔师"] = "Evoker",
    ["武器"] = "Arms",
    ["狂怒"] = "Fury",
    ["防护"] = "Protection",
    ["神圣"] = "Holy",
    ["惩戒"] = "Retribution",
    ["野兽控制"] = "Beast Mastery",
    ["射击"] = "Marksmanship",
    ["生存"] = "Survival",
    ["奇袭"] = "Assassination",
    ["狂徒"] = "Outlaw",
    ["敏锐"] = "Subtlety",
    ["戒律"] = "Discipline",
    ["暗影"] = "Shadow",
    ["鲜血"] = "Blood",
    ["冰霜"] = "Frost",
    ["邪恶"] = "Unholy",
    ["元素"] = "Elemental",
    ["增强"] = "Enhancement",
    ["恢复"] = "Restoration",
    ["奥术"] = "Arcane",
    ["火焰"] = "Fire",
    ["痛苦"] = "Affliction",
    ["恶魔学识"] = "Demonology",
    ["毁灭"] = "Destruction",
    ["酒仙"] = "Brewmaster",
    ["踏风"] = "Windwalker",
    ["织雾"] = "Mistweaver",
    ["平衡"] = "Balance",
    ["野性"] = "Feral",
    ["守护"] = "Guardian",
    ["浩劫"] = "Havoc",
    ["复仇"] = "Vengeance",
    ["湮灭"] = "Devastation",
    ["恩护"] = "Preservation",
    ["增辉"] = "Augmentation",
    ["噬灭"] = "Devourer",
}

-- M+ Spell Info data — display-only translations. Lookup-index keys
-- (EXSP.Database / EXSP.DungeonAbbr) stay zh.
ns.Translations.MobSpells = {}

-- Creature types are both stored and displayed; mutating in place
-- translates the right-panel "<type>    LV.X(<rank>)" line.
ns.Translations.MobSpells.CreatureTypes = {
    ["人型生物"] = "Humanoid",
    ["野兽"]     = "Beast",
    ["亡灵"]     = "Undead",
    ["龙类"]     = "Dragonkin",
    ["元素生物"] = "Elemental",
    ["机械"]     = "Mechanical",
    ["畸变怪"]   = "Aberration",
    ["未指定"]   = "Unspecified",
}

-- TagDefs[<key>].name only; tag keys (aoe, los, ...) stay zh.
ns.Translations.MobSpells.TagNames = {
    ["范围伤害"]         = "AoE",
    ["卡视野规避"]       = "LoS-able",
    ["可打断"]           = "Interruptible",
    ["无法盾反"]         = "No Reflect",
    ["总是命中(无法闪招)"] = "Cannot Miss",
    ["无法格挡"]         = "No Block",
    ["无法躲闪"]         = "No Dodge",
    ["无法招架"]         = "No Parry",
    ["盾反仅免疫伤害"]   = "Reflect: dmg only",
    ["流血"]             = "Bleed",
    ["诅咒"]             = "Curse",
    ["疾病"]             = "Disease",
    ["激怒"]             = "Enrage",
    ["魔法"]             = "Magic",
    ["中毒"]             = "Poison",
    ["沉睡"]             = "Sleep",
    ["迷惑"]             = "Disorient",
    ["冻结"]             = "Freeze",
    ["变形"]             = "Polymorph",
    ["定身"]             = "Root",
    ["诱捕"]             = "Snare",
    ["昏迷"]             = "Stun",
    ["逃跑"]             = "Flee",
}

-- Dungeon names — used both as EXSP.Database keys and as tab display text.
-- Keys stay zh; the UI hook repaints tab labels from this map.
ns.Translations.MobSpells.DungeonNames = {
    ["执政团之座"]    = "Seat of the Triumvirate",
    ["艾杰斯亚学院"]  = "Algeth'ar Academy",
    ["节点希纳斯"]    = "Nexus-Point Xenas",
    ["萨隆矿坑"]      = "Pit of Saron",
    ["迈萨拉洞窟"]    = "Maisara Caverns",
    ["通天峰"]        = "Skyreach",
    ["风行者之塔"]    = "Windrunner Spire",
    ["魔导师平台"]    = "Magisters' Terrace",
}

-- Short (≤3 char) abbreviations used as the small text under each
-- dungeon icon on the top tab row.
ns.Translations.MobSpells.DungeonAbbr = {
    ["执政"] = "SotT",
    ["学院"] = "AA",
    ["节点"] = "NPX",
    ["萨隆"] = "PoS",
    ["洞窟"] = "MC",
    ["通天"] = "SKR",
    ["风行"] = "WS",
    ["魔导"] = "MgT",
}

-- Display-only mob names for the M+ Spell Details browser. The source DB
-- keys by zh, so MobSpellsHooks repaints FontStrings rather than mutating
-- the keys. Auto-generated; see Tools/KnowledgeCrawler.
ns.Translations.MobSpells.MobNames = {
    -- ─ Seat of the Triumvirate ─────────────────────────────────────────
    ["暗影触须"]      = "Umbral Tentacle",
    ["暗影战争精锐"]  = "Umbral War-Adept",
    ["黯牙"]          = "Darkfang",
    ["残忍征服者"]    = "Merciless Subjugator",
    ["大织影者"]      = "Grand Shadow-Weaver",
    ["黑暗咒术师"]    = "Dark Conjurer",
    ["饥饿的破碎者"]  = "Famished Broken",
    ["晋升者祖拉尔"]  = "Zuraal the Ascended",
    ["恐怖缚灵师"]    = "Dire Voidbender",
    ["裂隙守护者"]    = "Rift Warden",
    ["鲁拉"]          = "L'ura",
    ["萨普瑞什"]      = "Saprish",
    ["贪食的影鳍鳐"]  = "Ravenous Umbralfin",
    ["无情的裂隙猎手"]= "Ruthless Riftstalker",
    ["虚空触须"]      = "Void Tentacle",
    ["影卫勇士"]      = "Shadowguard Champion",
    ["影翼鳐"]        = "Shadewing",
    ["注虚毁灭者"]    = "Void-Infused Destroyer",
    ["总督奈扎尔"]    = "Viceroy Nezhar",

    -- ─ Algeth'ar Academy ───────────────────────────────────────────────
    ["艾杰斯亚回声骑士"] = "Algeth'ar Echoknight",
    ["奥术抢劫者"]    = "Arcane Forager",
    ["被腐化的嗜魔者"]= "Corrupted Manafiend",
    ["被激怒的掠蜓"]  = "Aggravated Skitterfly",
    ["多拉苟萨的回响"]= "Echo of Doragosa",
    ["恶毒的鞭笞者"]  = "Vile Lasher",
    ["恶毒掠食者"]    = "Vicious Ravager",
    ["缚法战斧"]      = "Spellbound Battleaxe",
    ["克罗兹"]        = "Crawth",
    ["领地鹰隼"]      = "Territorial Eagle",
    ["茂林古树"]      = "Overgrown Ancient",
    ["任性的教科书"]  = "Unruly Textbook",
    ["守护者哨兵"]    = "Guardian Sentry",
    ["头领鹰隼"]      = "Alpha Eagle",
    ["维克萨姆斯"]    = "Vexamus",
    ["幽魂唤魔师"]    = "Spectral Invoker",

    -- ─ Nexus-Point Xenas ───────────────────────────────────────────────
    -- "[DNT] Conduit Stalker" skipped — name unreleased.
    ["残存镜像"]              = "Lingering Image",
    ["大废止者"]              = "Grand Nullifier",
    ["大废止者(251031)"]      = "Grand Nullifier",
    ["断裂的管道"]            = "Broken Pipe",
    ["法力电池"]              = "Mana Battery",
    ["法力电池(259569)"]      = "Mana Battery",
    ["分裂镜像"]              = "Fractured Image",
    ["分裂镜像(255179)"]      = "Fractured Image",
    ["光诞"]                  = "Lightwrought",
    ["光耀虫群"]              = "Radiant Swarm",
    ["核技奥术师"]            = "Corewright Arcanist",
    ["核闪晶塔"]              = "Corespark Pylon",
    ["核心守卫奈萨拉"]        = "Corewarden Nysarra",
    ["核心守卫奈萨拉(254227)"]= "Corewarden Nysarra",
    ["黑泥"]                  = "Smudge",
    ["回路先知"]              = "Circuit Seer",
    ["节点专家"]              = "Nexus Adept",
    ["卡斯雷瑟"]              = "Kasreth",
    ["恐惧连枷"]              = "Dreadflail",
    ["恐惧连枷(251024)"]      = "Dreadflail",
    ["洛萨克森"]              = "Lothraxion",
    ["暮恐传令官"]            = "Duskfright Herald",
    ["受诅的虚空召唤者"]      = "Cursed Voidcaller",
    ["通量工程师"]            = "Flux Engineer",
    ["虚无哨兵"]              = "Null Sentinel",
    ["虚隐之魂搜寻者"]        = "Hollowsoul Scrounger",
    ["耀光蝠"]                = "Flarebat",
    ["影卫防御者"]            = "Shadowguard Defender",
    ["重塑的虚空之子"]        = "Reformed Voidling",

    -- ─ Pit of Saron ────────────────────────────────────────────────────
    ["奥术师遗骸"]    = "Arcanist Cadaver",
    ["笨拙的灾疫恐魔"]= "Lumbering Plaguehorror",
    ["冰魂始祖龙"]    = "Iceborn Proto-Drake",
    ["冰煞"]          = "Glacieth",
    ["采掘场折磨者"]  = "Quarry Tormentor",
    ["腐烂的食尸鬼"]  = "Rotting Ghoul",
    ["复活的士兵"]    = "Risen Soldier",
    ["科瑞克"]        = "Krick",
    ["科瑞克之影"]    = "Shade of Krick",
    ["恐惧脉冲巫妖"]  = "Dreadpulse Lich",
    ["落爪石像鬼"]    = "Plungetalon Gargoyle",
    ["怒骨执行者"]    = "Wrathbone Enforcer",
    ["熔炉之主加弗斯特"]="Forgemaster Garfrost",
    ["霜骨冰骸"]      = "Rimebone Coldwraith",
    ["霜牙"]          = "Rimefang",
    ["腾跃的恶鬼"]    = "Leaping Geist",
    ["天灾领主泰兰努斯"]="Scourgelord Tyrannus",
    ["天灾瘟疫传播者"]= "Scourge Plaguespreader",
    ["亡语者侍僧"]    = "Deathwhisper Necrolyte",
    ["伊克"]          = "Ick",
    ["伊米亚墓刃"]    = "Ymirjar Graveblade",
    ["幽缚唤影者"]    = "Gloombound Shadebringer",

    -- ─ Maisara Caverns ─────────────────────────────────────────────────
    -- 吉尔加 (npcID 253458) → Zaib'yan in-game; legacy zh key mismatch.
    ["被缚的防御者"]      = "Bound Defender",
    ["被折磨的影魔"]      = "Tormented Shade",
    ["不安的纳拉丁"]      = "Restless Gnarldin",
    ["不稳定的幻影"]      = "Unstable Phantom",
    ["复活的战士"]        = "Reanimated Warrior",
    ["缚魂图腾"]          = "Soulbind Totem",
    ["晦翼蝙蝠"]          = "Gloomwing Bat",
    ["吉尔加"]            = "Zaib'yan",
    ["结界面具"]          = "Warding Mask",
    ["荆喉熊"]            = "Bramblemaw Bear",
    ["空洞的裂魂者"]      = "Hollow Soulrender",
    ["恐怖食魂者"]        = "Dread Souleater",
    ["魁梧主宰"]          = "Hulking Juggernaut",
    ["拉克图尔"]          = "Rak'tul",
    ["洛克扎尔"]          = "Rokh'zal",
    ["洛克扎尔(254233)"]  = "Rokh'zal",
    ["敏锐的猎头者"]      = "Keen Headhunter",
    ["姆罗金"]            = "Muro'jin",
    ["内克拉克斯"]        = "Nekraxx",
    ["死亡之握"]          = "Death's Grasp",
    ["沃达扎"]            = "Vordaza",
    ["妖缚飞鹰"]          = "Hexbound Eagle",
    ["妖术守护者"]        = "Hex Guardian",
    ["仪式妖术师"]        = "Ritual Hexxer",
    ["阴冷散兵"]          = "Grim Skirmisher",
    ["幽影缚影者"]        = "Umbral Shadowbinder",
    ["躁乱的狂战士"]      = "Frenzied Berserker",

    -- ─ Skyreach ────────────────────────────────────────────────────────
    -- "Sunwings" is an English key in source; map to canonical "Sunwing".
    ["阿拉卡纳斯"]        = "Araknath",
    ["飞天轮舞大师"]      = "Soaring Chakram Master",
    ["高阶贤者维里克斯"]  = "High Sage Viryx",
    ["华胄锐爪战士"]      = "Adorned Bladetalon",
    ["恐惧渡鸦"]          = "Dread Raven",
    ["狂怒的飑风"]        = "Raging Squall",
    ["兰吉特"]            = "Ranjit",
    ["黎明精锐"]          = "Adept of the Dawn",
    ["烈日构装体"]        = "Solar Construct",
    ["流亡战士"]          = "Outcast Warrior",
    ["鲁克兰"]            = "Rukhran",
    ["强势唤风者"]        = "Driving Gale-Caller",
    ["日爪"]              = "Suntalon",
    ["日爪驯服者"]        = "Suntalon Tamer",
    ["太阳宝珠"]          = "Solar Orb",
    ["太阳元素"]          = "Solar Elemental",
    ["通天峰炎阳构装体雏形"]="Skyreach Sun Construct Prototype",
    ["旭日新兵"]          = "Initiate of the Rising Sun",
    ["鸦人放大镜"]        = "Arakkoa Magnifying Glass",
    ["耀目太阳祭司"]      = "Blinding Sun Priestess",
    ["Sunwings"]          = "Sunwing",

    -- ─ Windrunner Spire ────────────────────────────────────────────────
    ["炽焰腾流"]              = "Flaming Updraft",
    ["烦人的鞭笞菇幼苗"]      = "Pesty Lashling",
    ["纺丝蜘蛛幼体"]          = "Spindleweb Hatchling",
    ["风行士兵"]              = "Windrunner Soldier",
    ["护法魔导师"]            = "Spellguard Magus",
    ["幻形秘术师"]            = "Phantasmal Mystic",
    ["幻影掷斧者"]            = "Spectral Axethrower",
    ["焦躁的管家"]            = "Restless Steward",
    ["烬晓"]                  = "Emberdawn",
    ["卡莉斯"]                = "Kalis",
    ["狂热的掠夺者"]          = "Zealous Reaver",
    ["狂热割喉者"]            = "Ardent Cutthroat",
    ["拉奇"]                  = "Latch",
    ["领地龙鹰"]              = "Territorial Dragonhawk",
    ["恼人的步兵"]            = "Haunting Grunt",
    ["徘徊的掠夺者"]          = "Lingering Marauder",
    ["破阵铁骑"]              = "Phalanx Breaker",
    ["破阵铁骑(232121)"]      = "Phalanx Breaker",
    ["虔诚的哀难使者"]        = "Devoted Woebringer",
    ["潜伏的纺丝蜘蛛"]        = "Creeping Spindleweb",
    ["热诚的药剂师"]          = "Fervent Apothecary",
    ["山猫首领"]              = "Apex Lynx",
    ["无眠之心"]              = "Restless Heart",
    ["血肉巨兽"]              = "Flesh Behemoth",
    ["迅捷弓箭手"]            = "Swiftshot Archer",
    ["臃肿的鞭笞者"]          = "Bloated Lasher",
    ["侦察诱捕者(250883)"]    = "Scouting Trapper",
    ["指挥官克罗鲁科"]        = "Commander Kroluk",
    ["忠诚的座狼"]            = "Loyal Worg",

    -- ─ Magisters' Terrace ──────────────────────────────────────────────
    ["奥能金刚库斯托斯"]      = "Arcanotron Custos",
    ["奥术魔导师"]            = "Arcane Magister",
    ["奥术哨兵"]              = "Arcane Sentry",
    ["不稳定的虚空之子"]      = "Unstable Voidling",
    ["炽热炎术士"]            = "Blazing Pyromancer",
    ["迪詹崔乌斯"]            = "Degentrius",
    ["符文破法者"]            = "Runed Spellbreaker",
    ["护光者医疗师"]          = "Lightward Healer",
    ["吉美尔鲁斯"]            = "Gemellus",
    ["吉美尔鲁斯(239636)"]    = "Gemellus",
    ["恐怖的虚空行者"]        = "Dreadful Voidwalker",
    ["亮鳞浮龙"]              = "Brightscale Wyrm",
    ["魔网编织魔宠"]          = "Spellwoven Familiar",
    ["瑟拉奈尔·日鞭"]         = "Seranel Sunlash",
    ["天界漂流者"]            = "Celestial Drifter",
    ["吞噬暴君"]              = "Devouring Tyrant",
    ["虚空恐魔"]              = "Void Terror",
    ["虚空之子"]              = "Voidling",
    ["虚隐之魂撕裂者"]        = "Hollowsoul Shredder",
    ["虚隐之魂撕裂者(257447)"]= "Hollowsoul Shredder",
    ["炎刃执行者"]            = "Sunblade Enforcer",
    ["影卫虚空召唤师"]        = "Shadowrift Voidcaller",
}

-- Window title (raw FontString text in source — not L[...]).
-- "Exwind 大米法术详细信息" encoded as UTF-8 byte escapes.
ns.Translations.MobSpells.MainTitle = {
    ["Exwind \229\164\167\231\177\179\230\179\149\230\156\175\232\175\166\231\187\134\228\191\161\230\129\175"] = "Exwind M+ Spell Details",
}

-- Level-suffix substrings (raw concat in source). The right-panel info
-- FontString hook swaps these at SetText time.
ns.Translations.MobSpells.LevelSuffix = {
    ["(\231\178\190\232\139\177)"] = "(Elite)", -- (精英)
    ["(\233\166\150\233\162\134)"] = "(Boss)",  -- (首领)
}

-- DogJumpTracker panel substring map. Scoped here rather than in
-- DisplayText because "当前" / "无" appear broadly as substrings; the
-- longest-first sort catches "下次: 无" before "下次: " so a bare "无"
-- never substitutes inside a player name that contains that glyph.
ns.Translations.ModuleStrings.DogJumpPanel = {
    ["下次: 无"]  = "Next: None",
    ["当前: "]    = "Current: ",
    ["下次: "]    = "Next: ",
    ["等待识别"]  = "Waiting...",
}
