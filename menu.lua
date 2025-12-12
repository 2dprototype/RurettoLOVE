Menu = {}

function Menu.init()
    Menu.buttons = {
        {text = "START GAME", action = "start"},
        {text = "HOW TO PLAY", action = "howto"},
        {text = "CREDITS", action = "credits"},
        {text = "EXIT", action = "exit"}
    }
    
    Menu.subState = "main" -- main, howto, credits
    Menu.selectedButton = 1
    
    -- Colors
    Menu.colors = {
        bg = {0.109804, 0.109804, 0.109804},
        title = {1.000000, 0.905882, 0.172549},
        button = {1.000000, 1.000000, 1.000000, 0.1},
        buttonHover = {1.000000, 0.905882, 0.172549, 0.3},
        buttonText = {1.000000, 1.000000, 1.000000},
        infoText = {1.000000, 1.000000, 1.000000, 0.8}
    }
    
    -- How to play text
    Menu.howtoText = {
        "HOW TO PLAY",
        "",
        "1. Click on chips at the bottom to select bet amount",
        "2. Click on numbers/sections to place bets",
        "3. Click SPIN to start the roulette",
        "4. Click CLEAR to remove all bets",
        "5. Click DOUBLE to double all bets",
        "6. Click ALL to bet all remaining balance",
        "",
        "PAYOUTS:",
        "- Single number: 35:1",
        "- Red/Black, Even/Odd, 1-18/19-36: 1:1",
        "- Dozens (1-12, 13-24, 25-36): 2:1",
        "- Columns: 2:1",
        "- 0 (zero): 35:1",
        "",
        "Press ESC or click BACK to return"
    }
    
    -- Credits text
    Menu.creditsText = {
        "CREDITS",
        "",
        "RURETTO - Roulette Game",
        "Developed with LÖVE2D",
        "",
        "Graphics & Design:",
        "- Custom chip design",
        "- Roulette wheel animation",
        "- Clean UI/UX",
        "",
        "Sound Effects:",
        "- Wheel tick sounds",
        "- Win/lose sounds",
        "",
        "Font: IBM Plex Sans",
        "",
        "Press ESC or click BACK to return"
    }
end

function Menu.draw()
    love.graphics.clear(Menu.colors.bg)
    
    -- Title
    love.graphics.setFont(mainFont)
    love.graphics.setColor(Menu.colors.title)
    local title = "RURETTO"
    local titleWidth = mainFont:getWidth(title)
    love.graphics.print(title, windowWidth/2 - titleWidth/2, 50)
    
    if Menu.subState == "main" then
        -- Draw buttons
        for i, button in ipairs(Menu.buttons) do
            local x = windowWidth/2 - 100
            local y = 150 + (i-1) * 60
            local width = 200
            local height = 50
            
            -- Button background
            if i == Menu.selectedButton then
                love.graphics.setColor(Menu.colors.buttonHover)
            else
                love.graphics.setColor(Menu.colors.button)
            end
            love.graphics.rectangle("fill", x, y, width, height, 5)
            love.graphics.setColor(1, 1, 1, 0.2)
            love.graphics.rectangle("line", x, y, width, height, 5)
            
            -- Button text
            love.graphics.setColor(Menu.colors.buttonText)
            local textWidth = mainFont:getWidth(button.text)
            love.graphics.print(button.text, x + width/2 - textWidth/2, y + 15)
        end
        
        -- Instructions
        love.graphics.setFont(smallFont)
        love.graphics.setColor(Menu.colors.infoText)
        love.graphics.print("Use UP/DOWN arrows to navigate, ENTER to select", 
            windowWidth/2 - 150, windowHeight - 30)
    elseif Menu.subState == "howto" then
        Menu.drawInfoPanel(Menu.howtoText)
    elseif Menu.subState == "credits" then
        Menu.drawInfoPanel(Menu.creditsText)
    end
end

function Menu.drawInfoPanel(textLines)
    -- Panel background
    local panelWidth = 600
    local panelHeight = 500
    local panelX = (windowWidth - panelWidth) / 2
    local panelY = (windowHeight - panelHeight) / 2
    
    love.graphics.setColor(0.1, 0.1, 0.1, 0.9)
    love.graphics.rectangle("fill", panelX, panelY, panelWidth, panelHeight, 10)
    love.graphics.setColor(1, 1, 1, 0.2)
    love.graphics.rectangle("line", panelX, panelY, panelWidth, panelHeight, 10)
    
    -- Draw text lines
    love.graphics.setFont(midFont)
    love.graphics.setColor(Menu.colors.buttonText)
    
    for i, line in ipairs(textLines) do
        local lineWidth = midFont:getWidth(line)
        local y = panelY + 30 + (i-1) * 25
        
        -- Title in gold
        if i == 1 or (Menu.subState == "howto" and i == 9) or (Menu.subState == "credits" and i == 3) then
            love.graphics.setColor(Menu.colors.title)
        else
            love.graphics.setColor(Menu.colors.infoText)
        end
        
        love.graphics.print(line, panelX + panelWidth/2 - lineWidth/2, y)
    end
    
    -- Back button
    local backX = panelX + panelWidth/2 - 50
    local backY = panelY + panelHeight - 40
    love.graphics.setColor(Menu.colors.button)
    love.graphics.rectangle("fill", backX, backY, 100, 30, 5)
    love.graphics.setColor(Menu.colors.buttonText)
    love.graphics.print("BACK", backX + 25, backY + 5)
end

function Menu.mousepressed(x, y)
    if Menu.subState == "main" then
        for i, button in ipairs(Menu.buttons) do
            local btnX = windowWidth/2 - 100
            local btnY = 150 + (i-1) * 60
            local btnWidth = 200
            local btnHeight = 50
            
            if x >= btnX and x <= btnX + btnWidth and y >= btnY and y <= btnY + btnHeight then
                Menu.handleButtonClick(button.action)
                break
            end
        end
    elseif Menu.subState == "howto" or Menu.subState == "credits" then
        -- Check back button
        local panelWidth = 600
        local panelHeight = 500
        local panelX = (windowWidth - panelWidth) / 2
        local panelY = (windowHeight - panelHeight) / 2
        
        local backX = panelX + panelWidth/2 - 50
        local backY = panelY + panelHeight - 40
        local backWidth = 100
        local backHeight = 30
        
        if x >= backX and x <= backX + backWidth and y >= backY and y <= backY + backHeight then
            Menu.subState = "main"
        end
    end
end

function Menu.handleButtonClick(action)
    if action == "start" then
        gameState = "playing"
        Game.reset()
    elseif action == "howto" then
        Menu.subState = "howto"
    elseif action == "credits" then
        Menu.subState = "credits"
    elseif action == "exit" then
        love.event.quit()
    end
end

function love.keypressed(key)
    if gameState == "menu" then
        if key == "up" then
            Menu.selectedButton = Menu.selectedButton > 1 and Menu.selectedButton - 1 or #Menu.buttons
        elseif key == "down" then
            Menu.selectedButton = Menu.selectedButton < #Menu.buttons and Menu.selectedButton + 1 or 1
        elseif key == "return" then
            Menu.handleButtonClick(Menu.buttons[Menu.selectedButton].action)
        elseif key == "escape" then
            if Menu.subState ~= "main" then
                Menu.subState = "main"
            else
                love.event.quit()
            end
        end
    elseif gameState == "playing" or gameState == "gameover" then
        if key == "escape" then
            if History.showHistory then
                History.showHistory = false
            else
                gameState = "menu"
                Menu.subState = "main"
            end
        end
    end
end