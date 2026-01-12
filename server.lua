local json = json or require("json")


local function SendWebhook(msg)
    if Config.Webhook == "" then return end
    PerformHttpRequest(Config.Webhook, function() end, 'POST', json.encode({
        username = "Maintenance Logger",
        embeds = {{
            title = "ESX Maintenance",
            description = msg,
            color = 16753920
        }}
    }), { ['Content-Type'] = 'application/json' })
end


local function HasDiscordRole(userId, callback)
    local endpoint = string.format("https://discord.com/api/guilds/%s/members/%s", Config.Discord.GuildID, userId)
    PerformHttpRequest(endpoint, function(code, data, headers)
        if code ~= 200 then
            print(("[Maintenance] Discord API Fehler (%s): %s"):format(code, data))
            callback(false)
            return
        end

        local member = json.decode(data)
        if not member or not member.roles then
            callback(false)
            return
        end

        for _, role in ipairs(member.roles) do
            for _, allowedRole in ipairs(Config.Discord.AllowedRoleIDs) do
                if role == allowedRole then
                    callback(true)
                    return
                end
            end
        end

        callback(false)
    end, "GET", "", {
        ["Authorization"] = "Bot " .. Config.Discord.BotToken,
        ["Content-Type"] = "application/json"
    })
end


AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    deferrals.defer()
    deferrals.update("Verifiziere Discord-Rolle...")
    local src = source

    -- Wenn kein Wartungsmodus, einfach joinen
    if not Config.Maintenance then
        deferrals.done()
        return
    end


    local discordId = nil
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if string.find(id, "discord:") then
            discordId = string.gsub(id, "discord:", "")
            break
        end
    end

    if not discordId then
        deferrals.done("❌ Du musst Discord verbunden haben, um den Server zu betreten.")
        CancelEvent()
        return
    end


    HasDiscordRole(discordId, function(hasRole)
        if hasRole then
            deferrals.done()
            print(("[Maintenance] %s darf joinen. (DiscordID: %s)"):format(name, discordId))
            SendWebhook(Config.LogMessages.PlayerAllowed:format(name, discordId))
        else
            deferrals.done(Config.KickMessage)
            print(("[Maintenance] %s hat keine erlaubte Discord-Rolle. (DiscordID: %s)"):format(name, discordId))
            SendWebhook(Config.LogMessages.PlayerDenied:format(name, discordId))
            CancelEvent()
        end
    end)
end)


RegisterCommand('maintenance', function(source, args)
    if source == 0 or IsPlayerAceAllowed(source, "command") then
        if args[1] == "on" then
            Config.Maintenance = true
            print(Config.LogMessages.MaintenanceOn)
            SendWebhook(Config.LogMessages.MaintenanceOn)
        elseif args[1] == "off" then
            Config.Maintenance = false
            print(Config.LogMessages.MaintenanceOff)
            SendWebhook(Config.LogMessages.MaintenanceOff)
        else
            print("Benutzung: /maintenance [on|off]")
        end
    end
end)
