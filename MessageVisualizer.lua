
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local DEFAULT_DURATION = 10
local BACKGROUND_COLOR = Color3.fromRGB(20, 20, 20)
local TEXT_COLOR = Color3.fromRGB(255, 100, 100)
local FONT_SIZE_MIN = 22
local FONT_SIZE_MAX = 50
local MIN_FRAME_WIDTH = 200
local MAX_FRAME_WIDTH_PERCENT = 0.85
local TEXT_PADDING = 30
local LINE_PADDING = 6

local activeUI = {
    background = nil,
    textLayers = {},
    connection = nil,
    isActive = false,
    onComplete = nil
}

local function splitText(text)
    local lines = {}
    for line in text:gmatch("[^\n]+") do
        table.insert(lines, line)
    end
    return lines
end

local function getTextWidth(text, fontSize)
    return #text * fontSize * 0.6
end

local function createBoldTextLayer(text, position, size, color)
    local layers = {}
    local offsets = {
        Vector2.new(0, 0),
        Vector2.new(1, 0),
        Vector2.new(0, 1),
        Vector2.new(1, 1),
    }
    
    for _, offset in ipairs(offsets) do
        local layer = Drawing.new("Text")
        layer.Text = text
        layer.Font = 3
        layer.Size = size
        layer.Color = color or TEXT_COLOR
        layer.Center = true
        layer.Outline = true
        layer.Visible = true
        layer.Position = position + offset
        table.insert(layers, layer)
    end
    
    return layers
end

local function cleanupUI()
    if activeUI.background then
        activeUI.background:Remove()
        activeUI.background = nil
    end
    
    for _, layerGroup in ipairs(activeUI.textLayers) do
        for _, layer in ipairs(layerGroup) do
            layer:Remove()
        end
    end
    activeUI.textLayers = {}
    
    if activeUI.connection then
        activeUI.connection:Disconnect()
        activeUI.connection = nil
    end
    
    activeUI.isActive = false
end

local function updateUI(text, duration, remaining)
    local screenSize = Camera.ViewportSize
    local screenWidth, screenHeight = screenSize.X, screenSize.Y
    
    local messageLines = splitText(text)
    if #messageLines == 0 then messageLines = {text} end
    
    local fontSize = math.clamp(math.floor(screenHeight * 0.045), FONT_SIZE_MIN, FONT_SIZE_MAX)
    local lineHeight = fontSize + LINE_PADDING
    
    local displayLines = {}
    for i, line in ipairs(messageLines) do
        local prefix = (i == 1) and "[DEVIL] " or "        "
        table.insert(displayLines, prefix .. line)
    end
    table.insert(displayLines, "Expires in " .. remaining .. "s")
    
    local maxWidth = 0
    for _, line in ipairs(displayLines) do
        local lineWidth = getTextWidth(line, (line == displayLines[#displayLines]) and fontSize * 0.9 or fontSize)
        maxWidth = math.max(maxWidth, lineWidth)
    end
    
    local frameWidth = math.clamp(
        maxWidth + (TEXT_PADDING * 2),
        MIN_FRAME_WIDTH,
        screenWidth * MAX_FRAME_WIDTH_PERCENT
    )
    
    if maxWidth > frameWidth - (TEXT_PADDING * 2) then
        local newFontSize = fontSize * ((frameWidth - (TEXT_PADDING * 2)) / maxWidth)
        fontSize = math.max(FONT_SIZE_MIN, newFontSize)
        lineHeight = fontSize + LINE_PADDING
        
        maxWidth = 0
        for _, line in ipairs(displayLines) do
            local lineWidth = getTextWidth(line, (line == displayLines[#displayLines]) and fontSize * 0.9 or fontSize)
            maxWidth = math.max(maxWidth, lineWidth)
        end
        frameWidth = math.clamp(
            maxWidth + (TEXT_PADDING * 2),
            MIN_FRAME_WIDTH,
            screenWidth * MAX_FRAME_WIDTH_PERCENT
        )
    end
    
    local frameHeight = (#displayLines * lineHeight) + 20
    
    local frameX = (screenWidth - frameWidth) / 2
    local frameY = screenHeight * 0.05
    
    if not activeUI.background then
        activeUI.background = Drawing.new("Square")
        activeUI.background.Filled = true
        activeUI.background.Color = BACKGROUND_COLOR
        activeUI.background.Transparency = 0.65
        activeUI.background.Visible = true
    end
    
    activeUI.background.Size = Vector2.new(frameWidth, frameHeight)
    activeUI.background.Position = Vector2.new(frameX, frameY)
    
    local centerX = frameX + frameWidth / 2
    local startY = frameY + (frameHeight - (#displayLines * lineHeight)) / 2
    
    for _, layerGroup in ipairs(activeUI.textLayers) do
        for _, layer in ipairs(layerGroup) do
            layer:Remove()
        end
    end
    activeUI.textLayers = {}
    
    for i, line in ipairs(displayLines) do
        local isTimerLine = (i == #displayLines)
        local lineFontSize = isTimerLine and (fontSize * 0.9) or fontSize
        local lineColor = isTimerLine and Color3.fromRGB(255, 200, 200) or TEXT_COLOR
        
        local yPos = startY + ((i - 1) * lineHeight)
        local layers = createBoldTextLayer(line, Vector2.new(centerX, yPos), lineFontSize, lineColor)
        table.insert(activeUI.textLayers, layers)
    end
end

local function showMessage(text, duration, callback)
    cleanupUI()
    
    duration = duration or DEFAULT_DURATION
    
    if duration <= 0 then
        warn("Invalid duration. Must be greater than 0.")
        if callback then callback() end
        return
    end
    
    local startTime = tick()
    activeUI.isActive = true
    activeUI.onComplete = callback
    
    activeUI.connection = RunService.RenderStepped:Connect(function()
        if not activeUI.isActive then return end
        
        local elapsed = tick() - startTime
        local remaining = math.max(0, math.ceil(duration - elapsed))
        
        if elapsed >= duration then
            cleanupUI()
            
            if activeUI.onComplete then
                local cb = activeUI.onComplete
                activeUI.onComplete = nil
                cb()
            end
        else
            updateUI(text, duration, remaining)
        end
    end)
end

return {
    message = showMessage,
    cleanup = cleanupUI,
    version = "1.1.0"
}

--[[

local MessageShower = loadstring(game:HttpGet("https://raw.githubusercontent.com/DEVIL-Script/ReaperHub/refs/heads/main/MessageVisualizer.lua", true))()
message = MessageShower.message  -- Create global shortcut
message("Hi This is devil", 10)

-- Now you can use the message function anywhere!
message("Hi This is devil", 10)
message("This is a very long message", 8)

-- With callback when message ends
message("This will disappear in 3 seconds", 3, function()
    print("Message finished!")
    -- Do something after message disappears
    message("Now showing another message!", 5)
end)

-- You can also chain messages
message("First message", 3, function()
    message("Second message", 3, function()
        message("Third message!", 3)
    end)
end)

]]
