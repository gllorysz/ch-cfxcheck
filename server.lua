Config = {}

Config.Webhook = 'TAVS Webhook'

function getCurrentTime()
    return os.date("%H:%M:%S")
end

local message = '**CFX.RE Traucējumi**'
local color = 1146986

function DiscordWebhook(message,color,status,description)
    if not color then
        color = color_msg
    end
    local sendD = {
        {
            ["color"] = color,
            ["title"] = message,
            ["description"] = "`Status` - **"..status.."**\n`Apraksts` - **"..description.."**",
            ["footer"] = {
                ["text"] = "Chakotay - "..os.date("%x %X %p")
            },
        }
    }
    PerformHttpRequest(Config.Webhook, function(err, text, headers) end, 'POST', json.encode({username = "CFX.RE Check", embeds = sendD}), { ['Content-Type'] = 'application/json' })
end

function CheckStatus()
    local Status_Description = ""
    local Status_Issue = ""
    local isDown = false
    PerformHttpRequest("https://status.cfx.re/api/v2/status.json", function(err, text, headers)
        convertJson = json.decode(text)
        Status_Description = convertJson['status']['description']
        Status_Issue = convertJson['status']['indicator']
        if Status_Description ~= "Visas sistēmas darbojas" then 
            print("====== Pārbaudam CFX Traucējumus ======")
            print("Laiks - " ..getCurrentTime())
            print("Problēma - " .. Status_Issue)
            print("Status - " .. Status_Description)
            isDown = true 
        end 
    end)
    Citizen.Wait(1000)
    return isDown, Status_Description, Status_Issue
end

Citizen.CreateThread(function()
    Result,Description,Issue = CheckStatus()
    if Result == true then
        DiscordWebhook(message, color_msg, Description, Issue)
    end
    while true do 
        Citizen.Wait(3600000)
        Result,Description,Issue = CheckStatus()
        if Result == true then
            DiscordWebhook(message, color_msg, Description, Issue)
        end
    end
end)
