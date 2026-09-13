---@diagnostic disable: undefined-global
-- ExBoss.UI.DungeonExtras (v26.9.13) draws per-unit health bars for
-- encounter producers such as AltarOfFangs/TrashHealth. The bar label is
-- Trash.State's lastResolvedName — the zh trait name from
-- EXBossData/TrashMobTraits, which no data-layer patch reaches. Translate
-- at the display seam: npcID-keyed first (upstream's own TrashCDLocale,
-- then MobNames), DisplayText as the catch-all.

local _, ns = ...

local function HasHighByte(s)
    for i = 1, #s do
        if s:byte(i) >= 128 then return true end
    end
    return false
end

local function UnitNPCID(unit)
    local State = _G.ExBoss and _G.ExBoss.Trash and _G.ExBoss.Trash.State
    if type(State) ~= "table" or type(State.GetUnit) ~= "function" then return nil end
    local ok, row = pcall(State.GetUnit, unit)
    if ok and type(row) == "table" then return tonumber(row.npcID) end
    return nil
end

local function TranslateName(unit, name)
    if type(name) ~= "string" or name == "" or not HasHighByte(name) then return name end
    local en = ns.Resolver.MobName(UnitNPCID(unit), name)
    if en then return en end
    local out = ns.Resolver.DisplayText(name)
    if type(out) == "string" and out ~= "" then return out end
    return name
end

local function WrapUpdateHealth()
    if ns.IsMarked("DungeonExtrasText", "UpdateHealth") then return end
    local display = _G.ExBoss and _G.ExBoss.UI and _G.ExBoss.UI.DungeonExtras
    if type(display) ~= "table" or type(display.UpdateHealth) ~= "function" then return end
    if display._eb_orig_UpdateHealth then return end

    local original = display.UpdateHealth
    display._eb_orig_UpdateHealth = original
    display.UpdateHealth = function(self, id, unit, name, ...)
        return original(self, id, unit, TranslateName(unit, name), ...)
    end

    ns.Mark("DungeonExtrasText", "UpdateHealth")
    ns.Log("DungeonExtrasText: wrapped ExBoss.UI.DungeonExtras.UpdateHealth")
end

ns.OnAddonLoaded("exboss", WrapUpdateHealth)
ns.OnPlayerLogin(WrapUpdateHealth)
