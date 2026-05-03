---@diagnostic disable: undefined-global
-- The source UI was sized for Chinese; English labels overflow. Grow a
-- FontString's width (and optionally its host frame) to GetStringWidth +
-- padding, clamped to maxWidth. Mutations route through RunSafe to defer
-- past combat lockdown, and we never resize a `protected` frame.

local _, ns = ...

local function IsProtected(frame)
    if type(frame) ~= "table" or type(frame.IsProtected) ~= "function" then
        return false
    end
    local ok, protected = pcall(frame.IsProtected, frame)
    return ok and protected == true
end

local function HasMethod(obj, name)
    return type(obj) == "table" and type(obj[name]) == "function"
end

-- Returns true if a resize was applied or queued.
function ns.UI_FitWidth(fontString, opts)
    if type(fontString) ~= "table" then return false end
    if not HasMethod(fontString, "GetStringWidth") then return false end
    if not HasMethod(fontString, "SetWidth") then return false end
    if IsProtected(fontString) then return false end

    opts = opts or {}
    local padding = tonumber(opts.padding) or 8
    local maxWidth = tonumber(opts.maxWidth) or 600
    local minWidth = tonumber(opts.minWidth) or 0
    local wordWrap = opts.wordWrap == true
    local hostFrame = opts.hostFrame
    local hostExtra = tonumber(opts.hostExtra) or 0

    return ns.RunSafe("UI_FitWidth", function()
        if wordWrap and HasMethod(fontString, "SetWordWrap") then
            fontString:SetWordWrap(true)
        end
        local desired = fontString:GetStringWidth() + padding
        if desired < minWidth then desired = minWidth end
        if desired > maxWidth then desired = maxWidth end
        fontString:SetWidth(desired)
        if hostFrame and HasMethod(hostFrame, "SetWidth") and not IsProtected(hostFrame) then
            local hostDesired = desired + hostExtra
            local current = HasMethod(hostFrame, "GetWidth") and hostFrame:GetWidth() or 0
            if hostDesired > current then
                hostFrame:SetWidth(hostDesired)
            end
        end
    end)
end

function ns.UI_FitButton(button, opts)
    if type(button) ~= "table" then return false end
    if IsProtected(button) then return false end
    local fs
    if HasMethod(button, "GetFontString") then
        fs = button:GetFontString()
    end
    if not fs then return false end
    return ns.UI_FitWidth(fs, opts)
end
