---@diagnostic disable: undefined-global
-- Ring-buffer log for developer inspection. Never emits chat output.

local _, ns = ...

local MAX_ENTRIES = 200

ns._log = ns._log or {}
ns._logHead = ns._logHead or 0

local function PushEntry(level, msg)
    ns._logHead = (ns._logHead % MAX_ENTRIES) + 1
    ns._log[ns._logHead] = {
        t = (type(GetTime) == "function" and GetTime() or 0),
        level = level,
        msg = tostring(msg or ""),
    }
end

function ns.Log(msg)
    PushEntry("info", msg)
end

function ns.Warn(msg)
    PushEntry("warn", msg)
end

function ns.LogTail(maxLines)
    maxLines = tonumber(maxLines) or 40
    local out = {}
    local head = ns._logHead
    local count = 0
    for i = head, head - MAX_ENTRIES + 1, -1 do
        local idx = ((i - 1) % MAX_ENTRIES) + 1
        local entry = ns._log[idx]
        if entry then
            count = count + 1
            out[count] = entry
            if count >= maxLines then break end
        end
    end
    return out
end
