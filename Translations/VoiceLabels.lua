---@diagnostic disable: undefined-global
-- zh voice label → short English label. Each English label is registered
-- as an LSM alias for the same sound file, so configs that stored the
-- zh label still play correctly.

local _, ns = ...

ns.Translations.VoiceLabels = {
    -- Prepare X
    ["准备AOE"]       = "Prep AoE",
    ["准备引线"]      = "Prep Beam",
    ["准备打断"]      = "Prep Interrupt",
    ["准备拉人"]      = "Prep Pull",
    ["准备挡线"]      = "Prep Block",
    ["准备接圈"]      = "Prep Soak",
    ["准备消层"]      = "Prep Clear",
    ["准备点名"]      = "Prep Target",
    ["准备踩箭"]      = "Prep Arrow",
    ["准备进圈"]      = "Prep Enter",
    ["准备连线"]      = "Prep Link",
    ["准备送球"]      = "Prep Pass",
    ["准备钩人"]      = "Prep Hook",
    ["准备集合"]      = "Prep Stack",
    ["准备驱散"]      = "Prep Dispel",
    ["准备AOE(断条)"] = "Prep AoE (kick)",
    ["准备吸球"]      = "Prep Absorb",
    -- Action verbs
    ["去撞分身"]      = "Hit Clone",
    ["坦克尖刺"]      = "Tank Buster",
    ["快卡视角"]      = "Fix Camera",
    ["快去消水"]      = "Clear Water",
    ["快找光柱"]      = "Find Beacon",
    ["快踩陷阱"]      = "Step Trap",
    ["出去放水"]      = "Drop Water",
    ["去接小怪"]      = "Intercept Add",
    ["快分散"]        = "Spread",
    ["快打断"]        = "Interrupt",
    ["快救人"]        = "Rescue",
    ["快破盾"]        = "Break Shield",
    ["快进罩子"]      = "Enter Bubble",
    ["拉断连线"]      = "Break Link",
    ["躲开头前"]      = "Dodge Frontal",
    ["转火小怪"]      = "Switch Add",
    ["转火大怪"]      = "Switch Boss",
    ["转阶段"]        = "Phase Change",
    ["远离BOSS"]      = "Away Boss",
    ["远离大怪"]      = "Away Add",
    ["靠近分散"]      = "Spread Close",
    ["风筝小怪"]      = "Kite Add",
    ["集合分摊"]      = "Stack Share",
    -- Watch / target / status
    ["注意击退"]      = "Watch Knockback",
    ["注意头前"]      = "Watch Frontal",
    ["注意挡球"]      = "Block Ball",
    ["注意消球"]      = "Clear Ball",
    ["注意躲避"]      = "Dodge",
    ["注意减伤"]      = "Defensive",
    ["注意治疗"]      = "Healing",
    ["点名头前"]      = "Tagged: Frontal",
    ["点名放水"]      = "Tagged: Water",
    ["点名消线"]      = "Tagged: Line",
    ["射线点你"]      = "Beam on You",
    ["你是白色"]      = "You: White",
    ["你是黑色"]      = "You: Black",
    ["小心冲击波"]    = "Watch Shockwave",
    ["小心击飞"]      = "Watch Launch",
    ["Boss狂暴"]      = "Boss Enrage",
    ["Boss易伤"]      = "Boss Vuln",
    ["易伤爆发"]      = "Vuln Burst",
    ["特殊技能"]      = "Special",
    -- Paladin empower (DPS-class-specific cues from default pack)
    ["强化奶骑"]      = "Empower HPal",
    ["强化惩戒骑"]    = "Empower Ret",
    ["强化防骑"]      = "Empower Prot",
    -- Countdowns and silence
    ["倒数5"]         = "5",
    ["倒数4"]         = "4",
    ["倒数3"]         = "3",
    ["倒数2"]         = "2",
    ["倒数1"]         = "1",
    ["无"]            = "None",

    -- TrashCDPreset display-only labels with no direct entry above.
    -- LSM aliasing skips entries with no backing sound, so extra rows
    -- here are harmless.
    ["贴边放水"]       = "Drop Water Edge",
    ["举盾(AOE)"]      = "Shield (AoE)",
    ["救人(诱捕)"]     = "Rescue (Snared)",
    ["转火宝珠"]       = "Switch Orb",
    ["注意地板"]       = "Watch Ground",
    ["坦克尖刺(击飞)"] = "Tank Buster (Knockup)",
    ["注意躲球"]       = "Watch Ball",
    ["驱散(魔法)"]     = "Dispel Magic",
    ["锁链点名"]       = "Chain on You",
    ["控断小怪"]       = "CC Add",
    ["AOE(断条)"]      = "AoE (Kick)",
    ["AOE(击退)"]      = "AoE (Knockback)",
    ["AOE(沉默)"]      = "AoE (Silence)",
    ["点名(射线)"]     = "Tagged: Beam",
    ["驱散(坦克)"]     = "Dispel Tank",
    ["坦克(吸收)"]     = "Tank Absorb",
    ["召唤小怪"]       = "Summon Add",
    ["注意点名"]       = "Watch Tag",
    ["注意躲圈"]       = "Dodge Circle",
    ["点名(驱散)"]     = "Tagged: Dispel",
    ["注意躲风"]       = "Dodge Wind",
    ["躲开火圈"]       = "Dodge Fire",
    ["救人(定身)"]     = "Rescue (Rooted)",
    ["准备吸人"]       = "Prep Pull-In",
    ["正面顺劈"]       = "Frontal Cleave",
    ["躲开正面"]       = "Dodge Frontal",
    ["治疗坦克"]       = "Heal Tank",
    ["点名追人"]       = "Targeted Chase",
    ["控断钢条"]       = "CC / Kick Bar",
}

-- Reverse direction, used by alias registration to avoid duplicating
-- the same English string against different sound files.
ns.Translations.VoiceLabelAliases = {}
do
    for zh, en in pairs(ns.Translations.VoiceLabels) do
        ns.Translations.VoiceLabelAliases[en] = zh
    end
end

-- Default voice pack name as registered by the source. Lives here so no
-- other file embeds zh literals. (默认 = "default")
ns.Translations.VoicePackName = "EXWIND(\233\187\152\232\174\164)"

-- zh label → English ogg filename in EX_EnglishPatch/sound/. The
-- VoicePack patch re-points the default pack's LSM keys at these files.
ns.Translations.VoiceFileByLabel = {
    ["准备AOE"]       = "AoE.ogg",
    ["准备引线"]      = "Beam.ogg",
    ["准备打断"]      = "Interrupt.ogg",
    ["准备拉人"]      = "Grip.ogg",
    ["准备挡线"]      = "Line.ogg",
    ["准备接圈"]      = "Soak.ogg",
    ["准备消层"]      = "Clear.ogg",
    ["准备点名"]      = "Targeted.ogg",
    ["准备踩箭"]      = "Trap.ogg",
    ["准备进圈"]      = "In.ogg",
    ["准备连线"]      = "Link.ogg",
    ["准备送球"]      = "Orb.ogg",
    ["准备钩人"]      = "Grip.ogg",
    ["准备集合"]      = "Gather.ogg",
    ["准备驱散"]      = "Dispell.ogg",
    ["准备AOE(断条)"] = "AoE.ogg",
    ["准备吸球"]      = "Orb.ogg",
    ["去撞分身"]      = "Charge.ogg",
    ["坦克尖刺"]      = "Defensive.ogg",
    ["快卡视角"]      = "LoS.ogg",
    ["快去消水"]      = "Clear.ogg",
    ["快找光柱"]      = "Beam.ogg",
    ["快踩陷阱"]      = "Trap.ogg",
    ["出去放水"]      = "Drop.ogg",
    ["去接小怪"]      = "Add.ogg",
    ["快分散"]        = "Spread.ogg",
    ["快打断"]        = "Interrupt.ogg",
    ["快救人"]        = "Rescue.ogg",
    ["快破盾"]        = "Break.ogg",
    ["快进罩子"]      = "Enter.ogg",
    ["拉断连线"]      = "Break.ogg",
    ["躲开头前"]      = "Dodge.ogg",
    ["转火小怪"]      = "Adds.ogg",
    ["转火大怪"]      = "Boss.ogg",
    ["转阶段"]        = "Transition.ogg",
    ["远离BOSS"]      = "Out.ogg",
    ["远离大怪"]      = "Out.ogg",
    ["靠近分散"]      = "Spread.ogg",
    ["风筝小怪"]      = "Kite.ogg",
    ["集合分摊"]      = "Stack.ogg",
    ["注意击退"]      = "Knock.ogg",
    ["注意头前"]      = "Front.ogg",
    ["注意挡球"]      = "Soak.ogg",
    ["注意消球"]      = "Clear.ogg",
    ["注意躲避"]      = "Dodge.ogg",
    ["注意减伤"]      = "Defensive.ogg",
    ["注意治疗"]      = "Healcd.ogg",
    ["点名头前"]      = "Front.ogg",
    ["点名放水"]      = "Drop.ogg",
    ["点名消线"]      = "Line.ogg",
    ["射线点你"]      = "Beam.ogg",
    ["你是白色"]      = "Blue.ogg",
    ["你是黑色"]      = "Purple.ogg",
    ["小心冲击波"]    = "Wave.ogg",
    ["小心击飞"]      = "Knock.ogg",
    ["Boss狂暴"]      = "Boss.ogg",
    ["Boss易伤"]      = "Nuke.ogg",
    ["易伤爆发"]      = "Nuke.ogg",
    ["特殊技能"]      = "Check.ogg",
    ["强化奶骑"]      = "Angel.ogg",
    ["强化惩戒骑"]    = "Sac.ogg",
    ["强化防骑"]      = "Protection.ogg",
    ["倒数5"]         = "5.ogg",
    ["倒数4"]         = "4.ogg",
    ["倒数3"]         = "3.ogg",
    ["倒数2"]         = "2.ogg",
    ["倒数1"]         = "1.ogg",
    ["无"]            = "Check.ogg",
    ["召唤小怪"]      = "Spawn.ogg",
}

-- Tab-button labels the panel-frame fitter should widen. Keys match
-- the live FontString text; values unused.
ns.Translations.TabKeysToFit = {}
for _, zh in ipairs({
    "\232\175\173\233\159\179/\233\133\141\231\189\174", -- 语音/配置
    "\229\133\182\228\187\150\232\175\173\233\159\179", -- 其他语音
    "\229\175\188\229\133\165\229\175\188\229\135\186", -- 导入导出
    "\230\155\180\230\150\176\230\151\165\229\191\151", -- 更新日志
    "\229\133\179\233\151\173\231\188\150\232\190\145\230\168\161\229\188\143", -- 关闭编辑模式
    "\229\188\128\229\144\175\231\188\150\232\190\145\230\168\161\229\188\143", -- 开启编辑模式
}) do
    ns.Translations.TabKeysToFit[zh] = true
end
