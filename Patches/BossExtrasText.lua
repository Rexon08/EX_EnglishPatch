---@diagnostic disable: undefined-global
-- ExBoss.BossEncounters (v26.9.15) lets encounter files declare per-boss
-- "extras" cards on the Boss page. Their label/description are L[...]
-- values captured while EXBoss loads — before our locale merge — so keys
-- upstream enUS lacks stay zh. Rewrite the captured display fields in
-- place; `key` and `defaults` (the DB-facing parts) are never touched.
-- Layout labels are handled by the RegisterModuleLayout hook.

local _, ns = ...

local FIELDS = { "label", "description" }

local function PatchExtras()
    if ns.IsMarked("BossExtrasText", "Registry") then return end
    local registry = _G.ExBoss and _G.ExBoss.BossEncounters
    if type(registry) ~= "table" or type(registry.byEncounterID) ~= "table" then return end

    local count = 0
    for _, def in pairs(registry.byEncounterID) do
        local extras = type(def) == "table" and def.extras
        if type(extras) == "table" then
            for _, extra in ipairs(extras) do
                if type(extra) == "table" then
                    for _, field in ipairs(FIELDS) do
                        local value = extra[field]
                        if type(value) == "string" and value ~= "" then
                            local out, changed = ns.Resolver.DisplayText(value)
                            if changed and out ~= value then
                                ns.Patches.StashOriginal(extra, field)
                                extra[field] = out
                                count = count + 1
                            end
                        end
                    end
                end
            end
        end
    end

    ns.Mark("BossExtrasText", "Registry")
    ns.Log("BossExtrasText: translated " .. count .. " boss extras fields")
end

ns.Patches.RegisterPostInit { deps = "exboss", apply = PatchExtras, login = true }
