---@diagnostic disable: undefined-global
-- Establishes the addon namespace. No side effects beyond table creation.

local ADDON_NAME, ns = ...

ns.NAME = ADDON_NAME
ns.VERSION = "1.0.0"
ns.SCHEMA = 1

ns.Translations = {}
ns.Translations.Maps = {}
ns.Translations.Encounters = {}
ns.Translations.Spells = {}
ns.Translations.EventTypes = {}
ns.Translations.VoiceLabels = {}
ns.Translations.VoiceLabelAliases = {}
ns.Translations.VoiceFileByLabel = {}
ns.Translations.ExwindCoreL = {}
ns.Translations.ExBossL = {}
ns.Translations.ModuleStrings = {}

ns.Patches = {}
ns.UI = {}

_G.EX_EnglishPatch = ns
