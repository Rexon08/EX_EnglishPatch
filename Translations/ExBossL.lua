---@diagnostic disable: undefined-global
-- Additive enUS entries for ExBoss.Locale.

local _, ns = ...

ns.Translations.ExBossL = {
    -- Gap-fillers atop ExBoss's enUS file. Keys are real UTF-8 zh.
    ["首页"]         = "Home",
    ["语音/配置"]    = "Voice / Config",
    ["其他语音"]     = "Other Voice",
    ["副本"]         = "Dungeons",
    ["小怪CD"]       = "Trash CD",
    ["设置"]         = "Settings",
    ["导入导出"]     = "Import / Export",
    ["时间轴"]       = "Timeline",
    ["更新日志"]     = "Changelog",
    ["关闭编辑模式"] = "Disable Edit Mode",
    ["开启编辑模式"] = "Enable Edit Mode",

    -- Import / Export page
    ["设置页全部设置"]                    = "All Settings",
    ["导入设置页全部设置（立即应用）"]    = "Import All Settings (apply now)",
    ["导入作者名（留空则使用配置名）"]    = "Author (leave blank to use config name)",

    -- File-load constants and late-built layouts.
    ["副本(首领)"] = "Dungeons (Boss)",
    ["提前5秒"] = "5 sec early",
    ["姓名版"] = "Nameplate",
    ["圆环"] = "Ring",
    ["竖条"] = "Bun Bar",
    ["施法检测"] = "Cast Detection",
    ["其他方案"] = "Other Scheme",
    ["预设配置"] = "Preset Config",
    ["首次施放时间：%s"] = "First cast: %s",
    ["CD时间：%s"] = "Cooldown: %s",
    ["开启暴雪中央文字预警（注意：如果关闭会导致语音不工作）"]
        = "Enable Blizzard center-screen alerts (voice may stop if disabled)",
    ["施法进度条"] = "Cast Progress Bar",

    -- BunBar / TimerBar / CastProgressBar shared labels
    ["显示名称"]     = "Show Name",
    ["时间文本"]     = "Time Text",
    ["背景设置"]     = "Background",
    ["移动方向"]     = "Move Direction",
    ["提示图标"]     = "Alert Icons",
    ["显示提示图标"] = "Show Alert Icons",
    ["提示图标锚点"] = "Alert Icon Anchor",
    ["左右排列"]     = "Horizontal",
    ["上下排列"]     = "Vertical",

    -- CastProgressBar settings
    ["施法进度条设置"] = "Cast Progress Bar Settings",
    ["与中央圆环使用相同触发逻辑，额外显示一根施法/引导进度条。"]
        = "Adds a cast/channel progress bar that shares trigger logic with the central ring.",
    ["与中央圆环同源的施法/引导进度条。"]
        = "Cast/channel progress bar sharing the central ring source.",
    ["左到右填满"]     = "Fill Left-to-Right",
    ["右到左填满"]     = "Fill Right-to-Left",
    ["测试施法检测"]   = "Test Cast Detection",

    -- BossPage / GlobalSettings extras
    ["BOSS施法时显示读条"] = "Show Cast Bar on Boss Cast",
    ["未知首领 "]          = "Unknown Boss ",

    -- Conditions rule editor
    ["倒数文字"] = "Countdown Text",
    ["播放音效"] = "Play Sound",

    -- PrivateAura page
    ["对象列表"]                       = "Object List",
    ["请选择左侧一个私人光环对象"]     = "Select a private aura object on the left.",
    ["当前对象没有私人光环法术。"]     = "No private aura spells for the current object.",
    ["团本首领：%d  |  大米副本：%d"]  = "Raid Bosses: %d  |  M+ Dungeons: %d",

    -- MDT page / route presets
    ["路线套装"]                       = "Route Preset",
    ["导入MDT"]                        = "Import MDT",
    ["当前进度：未获取"]               = "Current Progress: Not Available",
    ["已切换路线套装：%s"]             = "Switched route preset: %s",
    ["已导入MDT路线：%s"]              = "Imported MDT route: %s",
    ["已选择路线套装：%s（尚未导入）"] = "Selected route preset: %s (not yet imported)",

    -- ImportExport page summary
    ["设置页配置："] = "Settings Page Config: ",

    -- VoicePackPage missing-deps message
    ["语音/配置页面依赖 ExwindTools.UI，当前未就绪。请确认 ExwindCore 已正确加载后重开面板。"]
        = "The Voice/Config page depends on ExwindTools.UI, which is not ready. Confirm ExwindCore loaded correctly and reopen the panel.",

    -- SpellPage row reset button
    ["重置"] = "Reset",

    -- TrashCDPage custom-event labels (12.0.5 upstream)
    ["触发类型"]         = "Trigger Type",
    ["事件分类"]         = "Event Type",
    ["自定义事件"]       = "Custom Event",
    ["自定义小怪事件"]   = "Custom Mob Event",
    ["自定义小怪事件。"] = "Custom mob event.",

    -- Edit Mode panel section titles
    ["进入战斗提示"] = "Combat Enter Alert",
    ["离开战斗提示"] = "Combat Leave Alert",

    -- Page-local T(...) calls captured before locale force; also feed
    -- DisplayText for file-local layout constants from EXBoss load.
    ["%s易伤阶段"] = "%s vulnerability",
    ["易伤阶段"] = "Vulnerability",
    ["易伤阶段(%s)"] = "Vulnerability (%s)",
    ["准备易伤"] = "Prepare vulnerability",
    ["易伤结束"] = "Vulnerability ended",

    -- Batch Edit page
    ["中央文本"] = "Center Text",
    ["计时条改名"] = "Rename Timer Bar",
    ["中央警告语音"] = "Central Warning Voice",
    ["施法开始语音"] = "Cast Start Voice",
    ["提前5秒语音"] = "5-Second Voice",
    ["BOSS施法时显示圆环"] = "Show ring on boss casts",
    ["颜色覆盖"] = "Color Override",
    ["禁用"] = "Disable",
    ["全部大秘境BOSS"] = "All Mythic+ Bosses",
    ["全部团本BOSS"] = "All Raid Bosses",
    ["全部BOSS"] = "All Bosses",
    ["全部事件"] = "All Events",
    ["仅当前已启用"] = "Currently Enabled Only",
    ["仅当前已禁用"] = "Currently Disabled Only",
    ["批量修改"] = "Batch Edit",
    ["这里用于真实批量启用/禁用事件功能。第一版先覆盖普通事件的常用开关，并直接写入 override。"]
        = "This page performs real batch enable/disable changes for event features. The first version covers common toggles for normal events and writes directly into overrides.",
    ["选择作用的BOSS"] = "Choose Boss Scope",
    ["作用范围"] = "Scope",
    ["选择哪些事件"] = "Choose Events",
    ["目标筛选"] = "Target Filter",
    ["选择要做什么改动"] = "Choose Change",
    ["批量动作"] = "Batch Actions",
    ["选择禁用启用"] = "Choose Enable / Disable",
    ["操作"] = "Operation",
    ["生成预览"] = "Generate Preview",
    ["确认应用"] = "Apply",
    ["这是物理修改，不是额外叠一层运行时规则。应用后会真实写入事件 override，并在必要时重启当前 encounter。"]
        = "These are physical config changes, not extra runtime rules. Applying them writes directly into event overrides and restarts the current encounter when needed.",
    ["当前预览"] = "Current Preview",
    ["请先选择范围与动作，然后点击生成预览。"] =
        "Choose a scope and actions first, then click Generate Preview.",
    ["副本 "] = "Dungeon ",
    ["首领 "] = "Boss ",
    ["已应用批量修改。"] = "Batch changes applied.",
    ["命中事件数量"] = "Matched Events",
    ["动作数量"] = "Action Count",
    ["请至少选择一条批量动作。"] = "Select at least one batch action.",
    ["本次动作"] = "Actions",
    ["当前范围没有命中任何事件。"] = "No events matched the current scope.",
    ["预览前20条事件"] = "First 20 Matched Events",
    ["其余省略，共%d条。"] = "Omitted the rest, %d total.",

    -- Private Aura Monitor page
    ["私人光环监控"] = "Private Aura Monitor",
    ["启用私人光环监控"] = "Enable Private Aura Monitor",
    ["进入编辑模式"] = "Enter Edit Mode",
    ["图标外观"] = "Icon Appearance",
    ["图标大小"] = "Icon Size",
    ["图标间距"] = "Icon Spacing",
    ["排列方向"] = "Growth Direction",
    ["向右"] = "Right",
    ["向左"] = "Left",
    ["向上"] = "Up",
    ["向下"] = "Down",
    ["显示边框"] = "Show Border",
    ["边框缩放"] = "Border Scale",
    ["倒计时"] = "Countdown",
    ["显示冷却圈"] = "Show Cooldown Ring",
    ["显示数字倒计时"] = "Show Numeric Countdown",
    ["位置"] = "Position",
    ["水平位置 (X)"] = "Horizontal Position (X)",
    ["垂直位置 (Y)"] = "Vertical Position (Y)",
    ["锚点"] = "Anchor Point",
    ["屏幕中央"] = "Screen Center",
    ["左上角"] = "Top Left",
    ["上方中央"] = "Top Center",
    ["右上角"] = "Top Right",
    ["左侧中央"] = "Middle Left",
    ["右侧中央"] = "Middle Right",
    ["左下角"] = "Bottom Left",
    ["下方中央"] = "Bottom Center",
    ["右下角"] = "Bottom Right",

    -- Route-collection labels (currently disabled in source).
    ["硬玩复仇"] = "Hardplay Vengeance",
    ["硬玩复仇 · 艾杰斯亚学院"] = "Hardplay Vengeance · Algeth'ar Academy",
    ["硬玩复仇 · 执政团之座"] = "Hardplay Vengeance · Seat of the Triumvirate",
    ["硬玩复仇 · 迈萨拉洞窟"] = "Hardplay Vengeance · Maisara Caverns",
    ["硬玩复仇 · 萨隆矿坑"] = "Hardplay Vengeance · Pit of Saron",
    ["硬玩复仇 · 节点希纳斯"] = "Hardplay Vengeance · Nexus-Point Xenas",
    ["硬玩复仇 · 通天峰"] = "Hardplay Vengeance · Skyreach",
    ["硬玩复仇 · 风行者之塔"] = "Hardplay Vengeance · Windrunner Spire",
    ["硬玩复仇 · 魔导师平台"] = "Hardplay Vengeance · Magisters' Terrace",
    ["SHUN · 艾杰斯亚学院"] = "SHUN · Algeth'ar Academy",
    ["SHUN · 执政团之座"] = "SHUN · Seat of the Triumvirate",
    ["SHUN · 节点希纳斯"] = "SHUN · Nexus-Point Xenas",
    ["SHUN · 萨隆矿坑"] = "SHUN · Pit of Saron",
    ["SHUN · 迈萨拉洞窟"] = "SHUN · Maisara Caverns",
    ["SHUN · 通天峰"] = "SHUN · Skyreach",
    ["SHUN · 风行者之塔"] = "SHUN · Windrunner Spire",
    ["SHUN · 魔导师平台"] = "SHUN · Magisters' Terrace",
}
