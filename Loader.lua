-- Лоадер для игр

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Обновлённые ссылки на Obsidian UI
local ObsidianLibURL = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"
local ObsidianThemeURL = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/ThemeManager.lua"
local ObsidianSaveURL  = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/SaveManager.lua"

-- Загружаем UI библиотеку
local success, Obsidian = pcall(function()
    return loadstring(game:HttpGet(ObsidianLibURL, true))()
end)

if not success or not Obsidian then
    warn("Не удалось загрузить Obsidian UI библиотеку")
    return
end

-- Window
local Window = Obsidian:CreateWindow({
    Title = "mqixwed",
    Center = true,
    AutoShow = true
})

-- Tab
local MainTab = Window:AddTab("Loader")

-- Info
MainTab:AddParagraph({
    Title = "Loader",
    Content = "Загрузка подходящего скрипта для игры...\nПожалуйста, подождите."
})

-- Supported games
local Games = {
    [13985151437] = function() -- CASUAL STOCK
        loadstring(game:HttpGet("https://api.junkie-development.de/api/v1/luascripts/public/69cc0b3eb4a7f175d4d4e60d29007bf92e7d8e2f7250f90d75f445d383f2537f/download"))()
    end
}

-- Loader function
task.delay(1.5, function()
    local PlaceId = game.PlaceId

    if Games[PlaceId] then
        MainTab:AddParagraph({
            Title = "Игра обнаружена",
            Content = "Загружаем скрипт для этой игры"
        })

        pcall(Games[PlaceId])

        MainTab:AddParagraph({
            Title = "Успешно",
            Content = "Скрипт успешно загружен!"
        })
    else
        MainTab:AddParagraph({
            Title = "Игра не поддерживается",
            Content = "Для этой игре пока нет скрипта."
        })
    end
end)
