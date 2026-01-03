--// Obsidian UI
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

--// Window
local Window = Library:CreateWindow({
    Title = "Game Script Loader",
    Footer = "Auto game detection",
    ToggleKey = Enum.KeyCode.RightShift
})

local Tab = Window:AddTab({
    Name = "Loader"
})


local Section = Tab:AddSection({
    Name = "Game Detection"
})


--// Game scripts table
local GameScripts = {
    [13985151437] = { -- Casual Stock
        Name = "Casual Stock",
        Script = "https://api.junkie-development.de/api/v1/luascripts/public/69cc0b3eb4a7f175d4d4e60d29007bf92e7d8e2f7250f90d75f445d383f2537f/download"
    },

    [286090429] = { -- Arsenal
        Name = "Arsenal",
        Script = "https://example.com/arsenal.lua"
    },

    [537413528] = { -- Build A Boat
        Name = "Build A Boat",
        Script = "https://example.com/buildaboat.lua"
    }
}

--// Detect game
local PlaceId = game.PlaceId
local DetectedGame = GameScripts[PlaceId]

if DetectedGame then
    Section:CreateLabel("Game detected: " .. DetectedGame.Name)

    Section:CreateButton({
        Name = "Load script",
        Callback = function()
            local ok, err = pcall(function()
                loadstring(game:HttpGet(DetectedGame.Script))()
            end)

            if not ok then
                warn("Script load error:", err)
            end
        end
    })
else
    Section:CreateLabel("Game not supported")
end
