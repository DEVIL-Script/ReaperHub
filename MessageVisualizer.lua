
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local DEFAULT_DURATION = 10
local BACKGROUND_COLOR = Color3.fromRGB(20, 20, 20)
local TEXT_COLOR = Color3.fromRGB(255, 100, 100)
local FONT_SIZE_MIN = 22
local FONT_SIZE_MAX = 50
local FRAME_PADDING = 40
local MIN_FRAME_WIDTH = 200
local MAX_FRAME_WIDTH_PERCENT = 0.85
local TEXT_PADDING = 30

local activeUI = {
    background = nil,
    textLayers = {},
    connection = nil,
    isActive = false,
    onComplete = nil
}

-- Helper to calculate text width
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
    
    local fontSize = math.clamp(math.floor(screenHeight * 0.045), FONT_SIZE_MIN, FONT_SIZE_MAX)
    local lineHeight = fontSize + 6
    
    local prefix = "[DEVIL] "
    local line1Text = prefix .. text
    local line2Text = "Expires in " .. remaining .. "s"
    
    local line1Width = getTextWidth(line1Text, fontSize)
    local line2Width = getTextWidth(line2Text, fontSize * 0.9)
    local maxTextWidth = math.max(line1Width, line2Width)
    
    local frameWidth = math.clamp(
        maxTextWidth + (TEXT_PADDING * 2),
        MIN_FRAME_WIDTH,
        screenWidth * MAX_FRAME_WIDTH_PERCENT
    )
    
    if maxTextWidth > frameWidth - (TEXT_PADDING * 2) then
        local newFontSize = fontSize * ((frameWidth - (TEXT_PADDING * 2)) / maxTextWidth)
        fontSize = math.max(FONT_SIZE_MIN, newFontSize)
        lineHeight = fontSize + 6
        
        line1Width = getTextWidth(line1Text, fontSize)
        line2Width = getTextWidth(line2Text, fontSize * 0.9)
        maxTextWidth = math.max(line1Width, line2Width)
        frameWidth = math.clamp(
            maxTextWidth + (TEXT_PADDING * 2),
            MIN_FRAME_WIDTH,
            screenWidth * MAX_FRAME_WIDTH_PERCENT
        )
    end
    
    local frameHeight = (lineHeight * 2) + 20
    
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
    local topTextY = frameY + (frameHeight - (lineHeight * 2)) / 2
    
    -- Line 1 (main message)
    if #activeUI.textLayers < 1 then
        activeUI.textLayers[1] = createBoldTextLayer(line1Text, Vector2.new(centerX, topTextY), fontSize)
    else
        for _, layer in ipairs(activeUI.textLayers[1]) do
            layer.Text = line1Text
            layer.Size = fontSize
            layer.Position = Vector2.new(centerX, topTextY)
        end
    end
    
    if #activeUI.textLayers < 2 then
        activeUI.textLayers[2] = createBoldTextLayer(line2Text, Vector2.new(centerX, topTextY + lineHeight), fontSize * 0.9, Color3.fromRGB(255, 200, 200))
    else
        for _, layer in ipairs(activeUI.textLayers[2]) do
            layer.Text = line2Text
            layer.Size = fontSize * 0.9
            layer.Position = Vector2.new(centerX, topTextY + lineHeight)
        end
    end
end

local function showMessage(text, duration, callback)
    -- Clean up any existing UI
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

_G.message = function(text, duration, callback)
    showMessage(text, duration, callback)
end

return {
    message = showMessage,
    cleanup = cleanupUI,
    version = "1.0.0"
}


--[[
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
