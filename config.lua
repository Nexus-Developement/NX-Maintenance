Config = {}

-- Wartungsmodus aktiv/inaktiv
Config.Maintenance = true -- true = aktiv, false = aus

-- Discord API
Config.Discord = {
    BotToken = "", -- Your Bot Token
    GuildID = "", -- Your Guild ID
}

Config.Discord.AllowedRoleIDs = { "23212318283213212", "312321321213", "312213213321", "132213123123123" } -- Allowed join Rule Ids

-- Webhook-URL für Logs
Config.Webhook = "" Your Webhook

-- Message if someone gets kicked out
Config.KickMessage = [[    
🛠️ Der Server befindet sich momentan im Wartungsmodus.
Nur autorisierte Personen mit der Discord-Rolle dürfen joinen.
]]

-- Console Message
Config.LogMessages = {
    MaintenanceOn = "✅ Wartungsmodus wurde AKTIVIERT.",
    MaintenanceOff = "❌ Wartungsmodus wurde DEAKTIVIERT.",
    PlayerDenied = "🚫 %s (%s) wollte joinen, hat aber keine Berechtigung.",
    PlayerAllowed = "✅ %s (%s) darf joinen (Rolle erkannt)."
}
