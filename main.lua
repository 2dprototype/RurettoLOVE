-- Main entry point
require("menu")
require("game")
require("roulette")
require("history")

function love.load()
    -- Set up window
    windowWidth = 700
    windowHeight = 400
    love.window.setTitle("Ruretto")
    love.window.setMode(windowWidth, windowHeight, {resizable = true, msaa = 4})
	love.graphics.setDefaultFilter("nearest", "nearest")

    
    -- Load fonts
    mainFont = love.graphics.newFont("font/IBMPlexSans-Bold.ttf")
    midFont = love.graphics.newFont("font/IBMPlexSans-Bold.ttf", 14)
    smallFont = love.graphics.newFont("font/IBMPlexSans-Bold.ttf", 10)
    
    -- Initialize modules
    gameState = "menu" -- menu, playing, gameover
    Menu.init()
    Game.init()
    Roulette.init()
    History.init()
	
	Game.resize()
	Roulette.resize(Game.gridCellSize, Game.gridX, Game.gridY)
end

function love.update(dt)
    if gameState == "playing" or gameState == "gameover" then
        Roulette.update(dt)
    end
end

function love.draw()
    if gameState == "menu" then
        Menu.draw()
    elseif gameState == "playing" or gameState == "gameover" then
        Game.draw()
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        if gameState == "menu" then
            Menu.mousepressed(x, y)
        elseif gameState == "playing" or gameState == "gameover" then
            Game.mousepressed(x, y)
        end
    end
end

function love.resize(w, h)
    windowWidth = w
    windowHeight = h
    
    -- Update game elements when resized
    if gameState == "playing" or gameState == "gameover" then
        Game.resize()
    end
end

-- Utility functions
function format_num(num)
    if num < 1000 then
        return tostring(num)
    elseif num < 1000000 then
        return tostring(math.floor(num / 1000)) .. "K"
    elseif num < 1000000000 then
        return tostring(math.floor(num / 1000000)) .. "M"
    elseif num < 1000000000000 then
        return tostring(math.floor(num / 1000000000)) .. "B"
    elseif num < 1000000000000000 then
        return tostring(math.floor(num / 1000000000000)) .. "T"
    elseif num < 1000000000000000000 then
        return tostring(math.floor(num / 1000000000000000)) .. "Q"
    end
    return "∞"
end

function format_num_comma(n)
    local str = tostring(n)
    local out = ""
    local commaCount = 0

    for i = #str, 1, -1 do
        out = str:sub(i, i) .. out
        commaCount = commaCount + 1
        if commaCount == 3 and i > 1 then
            out = "," .. out
            commaCount = 0
        end
    end
    return out
end