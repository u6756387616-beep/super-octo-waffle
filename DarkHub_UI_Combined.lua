--[[
    DarkHub UI Prototype
    UI-only rewrite inspired by the uploaded script.
    This file intentionally does NOT automate gameplay, teleport, collect items,
    manipulate other players, or attempt to bypass anti-cheat.
    For use as a LocalScript in your own Roblox experience.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remove previous copy on rerun
local old = playerGui:FindFirstChild("DarkHubUI")
if old then old:Destroy() end

local state = {
    AutoSteal = false,
    AutoCollect = false,
    AutoPlace = false,
    AutoDivine = false,
    AutoEvent = false,
    Priority = "Divine",
    MaxAttempts = 5,
    DelayBetween = 2,
    SelectedEggTypes = {
        Normal = true, Golden = true, Rainbow = true, Divine = true, Event = true
    },
    Status = "GUI gotowe — tryb demonstracyjny",
}

local COLORS = {
    bg = Color3.fromRGB(17, 19, 26),
    panel = Color3.fromRGB(25, 28, 38),
    panel2 = Color3.fromRGB(34, 38, 51),
    accent = Color3.fromRGB(126, 92, 255),
    text = Color3.fromRGB(240, 242, 255),
    muted = Color3.fromRGB(160, 166, 190),
    green = Color3.fromRGB(52, 211, 153),
    red = Color3.fromRGB(248, 113, 113),
    line = Color3.fromRGB(54, 59, 77),
}

local gui = Instance.new("ScreenGui")
gui.Name = "DarkHubUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local function round(instance, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = instance
    return c
end

local function stroke(instance, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or COLORS.line
    s.Thickness = thickness or 1
    s.Transparency = 0.15
    s.Parent = instance
    return s
end

local function make(className, props, parent)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end

local main = make("Frame", {
    Name = "Main", Size = UDim2.fromOffset(560, 430),
    Position = UDim2.new(0.5, -280, 0.5, -215),
    BackgroundColor3 = COLORS.bg, BorderSizePixel = 0,
}, gui)
round(main, 14)
stroke(main, COLORS.line, 1)

local top = make("Frame", {
    Name = "TopBar", Size = UDim2.new(1, 0, 0, 54),
    BackgroundColor3 = COLORS.panel, BorderSizePixel = 0,
}, main)
round(top, 14)
make("Frame", {
    Position = UDim2.new(0, 0, 1, -14), Size = UDim2.new(1, 0, 0, 14),
    BackgroundColor3 = COLORS.panel, BorderSizePixel = 0,
}, top)

make("TextLabel", {
    Position = UDim2.fromOffset(18, 5), Size = UDim2.fromOffset(250, 25),
    BackgroundTransparency = 1, Text = "DARKHUB", TextColor3 = COLORS.text,
    Font = Enum.Font.GothamBold, TextSize = 19, TextXAlignment = Enum.TextXAlignment.Left,
}, top)
make("TextLabel", {
    Position = UDim2.fromOffset(19, 29), Size = UDim2.fromOffset(300, 16),
    BackgroundTransparency = 1, Text = "UI prototype  •  local demo controls",
    TextColor3 = COLORS.muted, Font = Enum.Font.Gotham, TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
}, top)

local hide = make("TextButton", {
    Position = UDim2.new(1, -43, 0, 10), Size = UDim2.fromOffset(30, 30),
    BackgroundColor3 = COLORS.panel2, Text = "×", TextColor3 = COLORS.text,
    Font = Enum.Font.GothamBold, TextSize = 22, AutoButtonColor = true,
}, top)
round(hide, 9)

local reopen = make("TextButton", {
    Name = "ReopenButton", Visible = false, Position = UDim2.new(0, 18, 0.5, -24),
    Size = UDim2.fromOffset(48, 48), BackgroundColor3 = COLORS.accent,
    Text = "DH", TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold, TextSize = 15,
}, gui)
round(reopen, 24)
stroke(reopen, Color3.fromRGB(178, 158, 255), 1)

hide.MouseButton1Click:Connect(function()
    main.Visible = false
    reopen.Visible = true
end)
reopen.MouseButton1Click:Connect(function()
    main.Visible = true
    reopen.Visible = false
end)

-- Drag window by its top bar
do
    local dragging = false
    local dragStart, startPos
    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local sidebar = make("Frame", {
    Position = UDim2.fromOffset(12, 66), Size = UDim2.new(0, 132, 1, -78),
    BackgroundColor3 = COLORS.panel, BorderSizePixel = 0,
}, main)
round(sidebar, 11)

local content = make("Frame", {
    Position = UDim2.fromOffset(154, 66), Size = UDim2.new(1, -166, 1, -78),
    BackgroundColor3 = COLORS.panel, BorderSizePixel = 0,
}, main)
round(content, 11)

local navLayout = make("UIListLayout", {
    Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder,
}, sidebar)
make("UIPadding", {
    PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 8),
    PaddingRight = UDim.new(0, 8),
}, sidebar)

local pages, navButtons = {}, {}
local activePage = "Overview"

local function setStatus(text)
    state.Status = text
end

local function createPage(name)
    local page = make("ScrollingFrame", {
        Name = name, Visible = false, Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 4, ScrollBarImageColor3 = COLORS.accent,
        CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, content)
    make("UIPadding", {
        PaddingTop = UDim.new(0, 14), PaddingLeft = UDim.new(0, 14),
        PaddingRight = UDim.new(0, 14), PaddingBottom = UDim.new(0, 14),
    }, page)
    make("UIListLayout", {Padding = UDim.new(0, 9), SortOrder = Enum.SortOrder.LayoutOrder}, page)
    pages[name] = page
    return page
end

local function switchPage(name)
    activePage = name
    for pageName, page in pairs(pages) do page.Visible = (pageName == name) end
    for buttonName, button in pairs(navButtons) do
        button.BackgroundColor3 = buttonName == name and COLORS.accent or COLORS.panel2
        button.TextColor3 = COLORS.text
    end
end

local function section(parent, title, subtitle)
    local card = make("Frame", {
        Size = UDim2.new(1, 0, 0, subtitle and 72 or 44),
        BackgroundColor3 = COLORS.panel2, BorderSizePixel = 0,
    }, parent)
    round(card, 9)
    make("TextLabel", {
        Position = UDim2.fromOffset(12, subtitle and 9 or 0),
        Size = UDim2.new(1, -24, 0, 25), BackgroundTransparency = 1,
        Text = title, TextColor3 = COLORS.text, Font = Enum.Font.GothamBold,
        TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
    }, card)
    if subtitle then
        make("TextLabel", {
            Position = UDim2.fromOffset(12, 34), Size = UDim2.new(1, -24, 0, 25),
            BackgroundTransparency = 1, Text = subtitle, TextColor3 = COLORS.muted,
            Font = Enum.Font.Gotham, TextSize = 11, TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, card)
    end
    return card
end

local function addToggle(parent, label, key)
    local row = section(parent, label)
    row.Size = UDim2.new(1, 0, 0, 44)
    local btn = make("TextButton", {
        Position = UDim2.new(1, -72, 0.5, -13), Size = UDim2.fromOffset(60, 26),
        BackgroundColor3 = state[key] and COLORS.green or COLORS.red,
        Text = state[key] and "ON" or "OFF", TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.GothamBold, TextSize = 11,
    }, row)
    round(btn, 8)
    btn.MouseButton1Click:Connect(function()
        state[key] = not state[key]
        btn.Text = state[key] and "ON" or "OFF"
        btn.BackgroundColor3 = state[key] and COLORS.green or COLORS.red
        setStatus(label .. (state[key] and " — włączony tryb demo" or " — wyłączony"))
    end)
end

local function addButton(parent, label, callback)
    local btn = make("TextButton", {
        Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = COLORS.panel2,
        Text = label, TextColor3 = COLORS.text, Font = Enum.Font.GothamBold,
        TextSize = 12, AutoButtonColor = true,
    }, parent)
    round(btn, 9)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local overview = createPage("Overview")
section(overview, "Witaj w DarkHub", "Przejrzysty panel z zakładkami i lokalnymi przełącznikami demonstracyjnymi.")
section(overview, "Status", "Przyciski zmieniają stan interfejsu. Nie wykonują akcji w grze.")
addButton(overview, "Resetuj wszystkie przełączniki", function()
    for _, key in ipairs({"AutoSteal","AutoCollect","AutoPlace","AutoDivine","AutoEvent"}) do
        state[key] = false
    end
    setStatus("Przełączniki zresetowane")
    switchPage("Modules")
    switchPage("Overview")
end)

local modules = createPage("Modules")
addToggle(modules, "Auto Steal (demo)", "AutoSteal")
addToggle(modules, "Auto Collect (demo)", "AutoCollect")
addToggle(modules, "Auto Place (demo)", "AutoPlace")
addToggle(modules, "Auto Divine (demo)", "AutoDivine")
addToggle(modules, "Auto Event (demo)", "AutoEvent")

local eggs = createPage("Eggs")
section(eggs, "Kategorie", "Wybierz kategorie do zapamiętania w ustawieniach interfejsu.")
for _, eggType in ipairs({"Normal", "Golden", "Rainbow", "Divine", "Event"}) do
    local row = section(eggs, eggType)
    row.Size = UDim2.new(1, 0, 0, 42)
    local btn = make("TextButton", {
        Position = UDim2.new(1, -72, 0.5, -12), Size = UDim2.fromOffset(60, 24),
        BackgroundColor3 = state.SelectedEggTypes[eggType] and COLORS.green or COLORS.red,
        Text = state.SelectedEggTypes[eggType] and "ON" or "OFF",
        TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 11,
    }, row)
    round(btn, 7)
    btn.MouseButton1Click:Connect(function()
        state.SelectedEggTypes[eggType] = not state.SelectedEggTypes[eggType]
        btn.Text = state.SelectedEggTypes[eggType] and "ON" or "OFF"
        btn.BackgroundColor3 = state.SelectedEggTypes[eggType] and COLORS.green or COLORS.red
        setStatus("Kategoria " .. eggType .. " zmieniona")
    end)
end

local settings = createPage("Settings")
section(settings, "Ustawienia interfejsu", "Przykładowe ustawienia zapisywane tylko w pamięci tej sesji.")
local priorityIndex = 1
local priorities = {"Divine", "Rainbow", "Golden", "Event", "Normal", "All"}
local priorityButton = addButton(settings, "Priorytet: " .. state.Priority, function()
    priorityIndex = priorityIndex % #priorities + 1
    state.Priority = priorities[priorityIndex]
    priorityButton.Text = "Priorytet: " .. state.Priority
    setStatus("Priorytet ustawiony na " .. state.Priority)
end)
addButton(settings, "Limit prób: " .. tostring(state.MaxAttempts), function()
    local limits = {3, 5, 10, 15, 20}
    local idx = table.find(limits, state.MaxAttempts) or 2
    idx = idx % #limits + 1
    state.MaxAttempts = limits[idx]
    setStatus("Limit prób: " .. state.MaxAttempts)
end)
addButton(settings, "Opóźnienie: " .. tostring(state.DelayBetween) .. " s", function()
    local delays = {1, 2, 3, 5, 10}
    local idx = table.find(delays, state.DelayBetween) or 2
    idx = idx % #delays + 1
    state.DelayBetween = delays[idx]
    setStatus("Opóźnienie: " .. state.DelayBetween .. " s")
end)

local footer = make("TextLabel", {
    Position = UDim2.new(0, 14, 1, -24), Size = UDim2.new(1, -28, 0, 16),
    BackgroundTransparency = 1, Text = "Status: " .. state.Status,
    TextColor3 = COLORS.muted, Font = Enum.Font.Gotham, TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
}, main)

-- Sidebar buttons
for i, name in ipairs({"Overview", "Modules", "Eggs", "Settings"}) do
    local labels = {Overview = "⌂  Overview", Modules = "⚙  Modules", Eggs = "🥚  Egg types", Settings = "☷  Settings"}
    local btn = make("TextButton", {
        Name = name, LayoutOrder = i, Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = COLORS.panel2, Text = labels[name],
        TextColor3 = COLORS.text, Font = Enum.Font.GothamBold, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = true,
    }, sidebar)
    round(btn, 8)
    make("UIPadding", {PaddingLeft = UDim.new(0, 10)}, btn)
    navButtons[name] = btn
    btn.MouseButton1Click:Connect(function() switchPage(name) end)
end

task.spawn(function()
    while gui.Parent do
        footer.Text = "Status: " .. state.Status
        task.wait(0.25)
    end
end)

switchPage("Overview")
print("[DarkHub] UI prototype loaded. Demo toggles do not run gameplay automation.")
