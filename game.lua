Game = {}

function Game.init()
    Game.defaultBet = 25000
    Game.balance = Game.defaultBet
    Game.prevBalance = Game.balance
    Game.chipValue = 10
    Game.lastWon = 0
    Game.isGameOver = false
    Game.comment = ""
    Game.bets = {}
    Game.bettingScales = {10, 50, 100, 500, 1000, 5000, 10000, 50000, 1000000, 5000000, 10000000, 50000000}
    
    Game.buttons = {"CLEAR", "DOUBLE", "ALL", "SPIN"}
    
    Game.colors = {
        black = {0.109804, 0.109804, 0.109804},
        white = {1.000000, 1.000000, 1.000000},
        trans = {1.000000, 1.000000, 1.000000, 0.05},
        bg = {0.109804, 0.109804, 0.109804},
        chip = {1.000000, 0.905882, 0.172549},
        ball = {0.996078, 1.000000, 0.172549},
        green = {0.149020, 0.796078, 0.129412},
        red = {1.000000, 0.172549, 0.172549}
    }
    
    -- Load sounds
    Game.tickSound = love.audio.newSource("audio/tick.wav", "static")  
    Game.tickSound:setVolume(0.7)
    Game.woohSound = love.audio.newSource("audio/wooh.wav", "static")
    Game.woohSound:setVolume(1)
    Game.cashSound = love.audio.newSource("audio/cash.wav", "static")
    Game.cashSound:setVolume(1)
    
    -- Initialize grid properties
    Game.resize()
end

function Game.reset()
    Game.balance = Game.defaultBet
    Game.prevBalance = Game.balance
    Game.lastWon = 0
    Game.bets = {}
    Game.isGameOver = false
    Game.comment = ""
    Game.chipValue = 10
    Roulette.reset()
    History.reset()
end

function Game.resize()
    Game.gridCellSize = windowWidth/23
    if Game.gridCellSize > 40 then
        Game.gridCellSize = 40
    end
    Game.gridX = windowWidth/2 - 2.3 * Game.gridCellSize
    Game.gridY = windowHeight/2 - 3.5 * Game.gridCellSize
    
	-- print(Game.gridCellSize, Game.gridX, Game.gridY)
    Roulette.resize(Game.gridCellSize, Game.gridX, Game.gridY)
end

function Game.draw()
    love.graphics.clear(Game.colors.bg)
    
    -- Draw roulette wheel
    Roulette.draw()
    
    -- Draw betting grid
    Game.drawBettingGrid()
    
    -- Draw buttons
    if Game.isGameOver then
        -- Draw Play Again button
        local x = Game.gridX
        local y = Game.gridY + Game.gridCellSize * 7
        love.graphics.setColor(Game.colors.white)
        love.graphics.rectangle("fill", x, y, Game.gridCellSize * 4, Game.gridCellSize)
        love.graphics.setColor(Game.colors.black)
        love.graphics.printf("PLAY AGAIN", x, y + Game.gridCellSize/4, Game.gridCellSize * 4, "center")
    else
        -- Draw normal buttons
        for i, label in ipairs(Game.buttons) do
            local x = Game.gridX + (i-1) * Game.gridCellSize * 2.4
            local y = Game.gridY + Game.gridCellSize * 7
            love.graphics.setColor(Game.colors.trans)
            love.graphics.rectangle("fill", x, y, Game.gridCellSize * 2, Game.gridCellSize)
            love.graphics.setColor(Game.colors.white)
            love.graphics.printf(label, x, y + Game.gridCellSize/4, Game.gridCellSize * 2, "center")
        end
    end
    
    -- Draw betting scales
    for i, val in ipairs(Game.bettingScales) do
        if val <= Game.balance then
            local x = Game.gridX + Game.gridCellSize * (i - 2/3)
            local y = Game.gridY + Game.gridCellSize * 6
            if Game.chipValue == val then
                love.graphics.setColor(1, 1, 1, 0.3)
                love.graphics.circle("fill", x, y, Game.gridCellSize/2)
            end
            Game.drawChip(val, x, y, Game.gridCellSize)
        end
    end
    
    -- Display balance
    local sum = 0
    for _, bet in pairs(Game.bets) do
        sum = sum + bet
    end
    
    love.graphics.setFont(midFont)
    
    local label = "$" .. format_num_comma(Game.balance) .. " $" .. format_num_comma(sum)
    local tw, _ = love.graphics.newText(love.graphics.getFont(), label):getDimensions()
    
    love.graphics.setColor(Game.colors.white)
    love.graphics.print(label, 14, 14)
    
    label = format_num_comma(Game.lastWon)
    
    if Game.lastWon > 0 then
        love.graphics.setColor(Game.colors.green)
        label = "+$" .. format_num_comma(Game.lastWon)
    elseif Game.lastWon < 0 then
        love.graphics.setColor(Game.colors.red)
        label = "-$" .. format_num_comma(math.abs(Game.lastWon))
    else 
        love.graphics.setColor(Game.colors.white)
        label = "$0"
    end
    love.graphics.print(label, 18 + tw, 14)
    
    -- Draw comment
    if Game.comment ~= "" then
        love.graphics.setColor(Game.colors.white)
        local commentWidth = love.graphics.getFont():getWidth(Game.comment)
        love.graphics.print(Game.comment, Game.gridX + Game.gridCellSize * 6 - commentWidth/2, Game.gridY - Game.gridCellSize)
    end
    
    -- Draw History button
    love.graphics.setColor(Game.colors.white)
    love.graphics.circle("line", windowWidth - 30, 30, 15)
    love.graphics.setFont(smallFont)
    love.graphics.print("H", windowWidth - 30 - smallFont:getWidth("H")/2, 30 - smallFont:getHeight()/2)
    
    -- Draw history panel if shown
    if History.showHistory then
        History.drawPanel()
    end
end

function Game.drawChip(num, x, y, r) 
    local a = 2 * math.pi / 10
    for i = 1, 10 do
        local angleStart = (i * a)
        local angleEnd = angleStart + a
        if i % 2 == 1 then
            love.graphics.setColor(Game.colors.chip) 
        else
            love.graphics.setColor(Game.colors.white)
        end
        love.graphics.arc("fill", x, y, r/2.5, angleStart, angleEnd)
    end
    
    love.graphics.setColor(0.7, 0.7, 0)
    love.graphics.circle("fill", x, y, r/3.2)    
    
    love.graphics.setColor(0, 0, 0, 0.73)
    love.graphics.setFont(smallFont)
    love.graphics.printf(format_num(num), x - 20, y - love.graphics.getFont():getHeight()/2, 40, "center")
    love.graphics.setFont(mainFont)
end

function Game.drawBettingGrid()
    -- Define grid data
    local rouletteGrid = {
        {{num=3,  color="red"},   {num=2,  color="black"}, {num=1, color="red"}},
        {{num=6,  color="black"}, {num=5,  color="red"},   {num=4, color="black"}},
        {{num=9,  color="red"},   {num=8,  color="black"}, {num=7, color="red"}},
        {{num=12, color="red"},   {num=11, color="black"}, {num=10, color="black"}},
        {{num=15, color="black"}, {num=14, color="red"},   {num=13, color="black"}},
        {{num=18, color="red"},   {num=17, color="black"}, {num=16, color="red"}},
        {{num=21, color="red"},   {num=20, color="black"}, {num=19, color="black"}},
        {{num=24, color="black"}, {num=23, color="red"},   {num=22, color="black"}},
        {{num=27, color="red"},   {num=26, color="black"}, {num=25, color="red"}},
        {{num=30, color="red"},   {num=29, color="black"}, {num=28, color="red"}},
        {{num=33, color="black"}, {num=32, color="red"},   {num=31, color="black"}},
        {{num=36, color="red"},   {num=35, color="black"}, {num=34, color="red"}}
    }
    
    local rouletteCol1 = {"2-1", "2-1", "2-1"}
    local rouletteRow1 = {"1 to 12", "13 to 24", "25 to 36"}
    local rouletteRow2 = {"1-18","EVEN", "RED","BLACK", "ODD", "19-36"}
    local rouletteZero = "0"
    
    -- Draw zero 
    love.graphics.setColor(Game.colors.green)
    love.graphics.rectangle("fill", Game.gridX - Game.gridCellSize, Game.gridY, Game.gridCellSize, Game.gridCellSize * 3)
    
    love.graphics.setColor(Game.colors.black)
    love.graphics.printf(rouletteZero, Game.gridX - Game.gridCellSize, Game.gridY + Game.gridCellSize * 1.25, Game.gridCellSize, "center")
    
    if Game.bets[0] ~= nil then
        Game.drawChip(Game.bets[0], Game.gridX - Game.gridCellSize/2, Game.gridY + Game.gridCellSize * 1.5, Game.gridCellSize)
    end
    
    -- Draw row 1 (dozens)
    for rowIndex, str in ipairs(rouletteRow1) do
        local cellSize = Game.gridCellSize * 4
        local x = Game.gridX + (rowIndex - 1) * cellSize
        local y = Game.gridY + 3 * Game.gridCellSize
        
        love.graphics.setColor(Game.colors.trans)
        love.graphics.rectangle("fill", x, y, cellSize, Game.gridCellSize)
        
        love.graphics.setColor(Game.colors.white)
        love.graphics.printf(str, x, y + Game.gridCellSize / 4, cellSize, "center")
        
        local v = Game.bets[40 + rowIndex]
        if v ~= nil then
            Game.drawChip(v, x + cellSize / 2, y + Game.gridCellSize / 2, Game.gridCellSize)
        end
    end
    
    -- Draw row 2 (outside bets)
    for rowIndex, str in ipairs(rouletteRow2) do
        local cellSize = Game.gridCellSize * 2
        local x = Game.gridX + (rowIndex - 1) * cellSize
        local y = Game.gridY + 4 * Game.gridCellSize
        
        if str == "RED" then
            love.graphics.setColor(Game.colors.red)
        elseif str == "BLACK" then
            love.graphics.setColor(Game.colors.black)
        else
            love.graphics.setColor(Game.colors.trans)
        end
        love.graphics.rectangle("fill", x, y, cellSize, Game.gridCellSize)
        
        love.graphics.setColor(Game.colors.white)
        love.graphics.printf(str, x, y + Game.gridCellSize / 4, cellSize, "center")
        
        local v = Game.bets[50 + rowIndex]
        if v ~= nil then
            Game.drawChip(v, x + cellSize / 2, y + Game.gridCellSize / 2, Game.gridCellSize)
        end
    end
    
    -- Draw column bets
    for colIndex, str in ipairs(rouletteCol1) do
        local x = Game.gridX + Game.gridCellSize * 12
        local y = Game.gridY + Game.gridCellSize * (colIndex - 1)
        
        love.graphics.setColor(Game.colors.trans)
        love.graphics.rectangle("fill", x, y, Game.gridCellSize, Game.gridCellSize)
        
        love.graphics.setColor(Game.colors.white)
        love.graphics.printf(str, x, y + Game.gridCellSize / 4, Game.gridCellSize, "center")
        
        local v = Game.bets[60 + colIndex]
        if v ~= nil then
            Game.drawChip(v, x + Game.gridCellSize / 2, y + Game.gridCellSize / 2, Game.gridCellSize)
        end
    end
    
    -- Draw main number grid
    for rowIndex, row in ipairs(rouletteGrid) do
        for colIndex, cell in ipairs(row) do
            local x = Game.gridX + (rowIndex - 1) * Game.gridCellSize
            local y = Game.gridY + (colIndex - 1) * Game.gridCellSize
            
            love.graphics.setColor(Game.colors[cell.color])
            love.graphics.rectangle("fill", x, y, Game.gridCellSize, Game.gridCellSize)
            
            if cell.color == "red" then 
                love.graphics.setColor(Game.colors.black)
            elseif cell.color == "black" then 
                love.graphics.setColor(Game.colors.red)
            else 
                love.graphics.setColor(Game.colors.white)
            end
            love.graphics.printf("" .. cell.num, x, y + Game.gridCellSize / 4, Game.gridCellSize, "center")
            
            local v = Game.bets[cell.num]
            if v ~= nil then
                Game.drawChip(v, x + Game.gridCellSize / 2, y + Game.gridCellSize / 2, Game.gridCellSize)
            end
        end
    end
end

function Game.mousepressed(x, y)
    if History.showHistory then
        History.mousepressed(x, y)
        return
    end
    
    -- Check history button
    local dx = x - (windowWidth - 30)
    local dy = y - 30
    if dx*dx + dy*dy <= 15*15 then
        History.showHistory = not History.showHistory
        return
    end
    
    if Game.isGameOver then
        -- Check Play Again button
        local btnX = Game.gridX
        local btnY = Game.gridY + Game.gridCellSize * 7
        local btnWidth = Game.gridCellSize * 4
        local btnHeight = Game.gridCellSize
        
        if x >= btnX and x <= btnX + btnWidth and y >= btnY and y <= btnY + btnHeight then
            Game.reset()
        end
    else
        Game.handleButtonClick(x, y)
        Game.handleGridClick(x, y)
    end
end

function Game.handleButtonClick(x, y)
    for i, label in ipairs(Game.buttons) do
        local a = Game.gridX + (i-1) * Game.gridCellSize * 2.4
        local b = Game.gridY + Game.gridCellSize * 7
        if x >= a and x <= a + Game.gridCellSize * 2 and y >= b and y <= b + Game.gridCellSize then 
            if i == 1 then
                for _, val in pairs(Game.bets) do
                    Game.balance = Game.balance + val
                end        
                Game.bets = {}            
            elseif i == 2 then
                for key, val in pairs(Game.bets) do
                    local d = val * 2
                    if Game.balance - d >= 0 then
                        Game.bets[key] = d
                    end
                end        
            elseif i == 3 then
                Game.chipValue = Game.balance
            elseif i == 4 then
                Roulette.startSpin()
            end
        end
    end
    
    for i, val in ipairs(Game.bettingScales) do
        local r = Game.gridCellSize / 2.5
        local a = Game.gridX + Game.gridCellSize * (i - 2/3) - r
        local b = Game.gridY + Game.gridCellSize * 6 - r
        if x >= a and x <= a + r * 2 and y >= b and y <= b + r * 2 then 
            Game.chipValue = val
        end
    end
end

function Game.handleGridClick(x, y)
    -- Handle clicks for rouletteZero
    if x >= Game.gridX - Game.gridCellSize and x <= Game.gridX and 
       y >= Game.gridY and y <= (Game.gridY + Game.gridCellSize * 3) then
        Game.placeBet(0, x, y)
    end
    
    -- Handle clicks for rouletteRow1
    for rowIndex = 1, 3 do
        local cellSize = Game.gridCellSize * 4
        local cellX = Game.gridX + (rowIndex - 1) * cellSize
        local cellY = Game.gridY + 3 * Game.gridCellSize
        
        if x >= cellX and x <= cellX + cellSize and y >= cellY and y <= cellY + Game.gridCellSize then
            Game.placeBet(40 + rowIndex, x, y)
        end
    end
    
    -- Handle clicks for rouletteRow2
    for rowIndex = 1, 6 do
        local cellSize = Game.gridCellSize * 2
        local cellX = Game.gridX + (rowIndex - 1) * cellSize
        local cellY = Game.gridY + 4 * Game.gridCellSize
        
        if x >= cellX and x <= cellX + cellSize and y >= cellY and y <= cellY + Game.gridCellSize then
            Game.placeBet(50 + rowIndex, x, y)
        end
    end
    
    -- Handle clicks for rouletteCol1
    for colIndex = 1, 3 do
        local cellX = Game.gridX + Game.gridCellSize * 12
        local cellY = Game.gridY + Game.gridCellSize * (colIndex - 1)
        
        if x >= cellX and x <= cellX + Game.gridCellSize and y >= cellY and y <= cellY + Game.gridCellSize then
            Game.placeBet(60 + colIndex, x, y)
        end
    end
    
    -- Handle clicks for number grid (1-36)
    local rouletteGrid = {
        {{num=3}, {num=2}, {num=1}},
        {{num=6}, {num=5}, {num=4}},
        {{num=9}, {num=8}, {num=7}},
        {{num=12}, {num=11}, {num=10}},
        {{num=15}, {num=14}, {num=13}},
        {{num=18}, {num=17}, {num=16}},
        {{num=21}, {num=20}, {num=19}},
        {{num=24}, {num=23}, {num=22}},
        {{num=27}, {num=26}, {num=25}},
        {{num=30}, {num=29}, {num=28}},
        {{num=33}, {num=32}, {num=31}},
        {{num=36}, {num=35}, {num=34}}
    }
    
    for rowIndex = 1, 12 do
        for colIndex = 1, 3 do
            local cellX = Game.gridX + (rowIndex - 1) * Game.gridCellSize
            local cellY = Game.gridY + (colIndex - 1) * Game.gridCellSize
            
            if x >= cellX and x <= cellX + Game.gridCellSize and 
               y >= cellY and y <= cellY + Game.gridCellSize then
                Game.placeBet(rouletteGrid[rowIndex][colIndex].num, x, y)
            end
        end
    end
end

function Game.placeBet(number, x, y)
    if not Game.bets[number] and Game.balance >= Game.chipValue then
        Game.bets[number] = Game.chipValue
        Game.balance = Game.balance - Game.chipValue
    elseif Game.bets[number] then
        Game.balance = Game.balance + Game.chipValue
        Game.bets[number] = nil
    end
end

function Game.checkBets(num, col)
    -- Calculate total bet before spin
    local totalBetBefore = 0
    for _, bet in pairs(Game.bets) do
        totalBetBefore = totalBetBefore + bet
    end
    
    local pointsBefore = Game.balance
    
    -- Check single number bet
    if Game.bets[num] and (num >= 0 and num <= 36) then
        Game.balance = Game.balance + Game.bets[num] * 36
    end
    
    -- Check row 1 (dozens)
    if Game.bets[41] and num >= 1 and num <= 12 then
        Game.balance = Game.balance + Game.bets[41] * 3
    elseif Game.bets[42] and num >= 13 and num <= 24 then
        Game.balance = Game.balance + Game.bets[42] * 3
    elseif Game.bets[43] and num >= 25 and num <= 36 then
        Game.balance = Game.balance + Game.bets[43] * 3
    end
    
    -- Check row 2 (outside bets)
    if Game.bets[51] and num >= 1 and num <= 18 then
        Game.balance = Game.balance + Game.bets[51] * 2
    elseif Game.bets[56] and num >= 19 and num <= 36 then
        Game.balance = Game.balance + Game.bets[56] * 2
    end
    
    -- Check even/odd
    if Game.bets[52] and num % 2 == 0 then
        Game.balance = Game.balance + Game.bets[52] * 2
    elseif Game.bets[55] and num % 2 ~= 0 then
        Game.balance = Game.balance + Game.bets[55] * 2
    end
    
    -- Check black/red
    if Game.bets[53] and col == "red" then
        Game.balance = Game.balance + Game.bets[53] * 2
    elseif Game.bets[54] and col == "black" then
        Game.balance = Game.balance + Game.bets[54] * 2
    end
    
    -- Check columns
    if Game.bets[61] and (num >= 3 and num <= 36 and num % 3 == 0) then
        Game.balance = Game.balance + Game.bets[61] * 3
    elseif Game.bets[62] and (num >= 2 and num <= 35 and (num - 2) % 3 == 0) then
        Game.balance = Game.balance + Game.bets[62] * 3
    elseif Game.bets[63] and (num >= 1 and num <= 34 and (num - 1) % 3 == 0) then
        Game.balance = Game.balance + Game.bets[63] * 3
    end
    
    Game.lastWon = Game.balance - Game.prevBalance
    
    -- Calculate winnings/losses for history
    local wonAmount = 0
    local balanceChange = Game.balance - pointsBefore
    
    if balanceChange > 0 then
        wonAmount = balanceChange
    else
        wonAmount = -totalBetBefore
    end
    
    -- Add to history
    History.addEntry(totalBetBefore, num, col, wonAmount, balanceChange)
    
    -- Play sound effects
    if Game.lastWon < 0 then
        love.audio.play(Game.woohSound)
    elseif Game.lastWon > 0 then
        love.audio.play(Game.cashSound)
    end
    
    -- Check for game over or special messages
    if Game.balance == 0 then
        Game.comment = "Woooh! You lost all of your chips, didn't you?"
        Game.isGameOver = true
    elseif Game.balance >= 1000000000 then
        Game.comment = "Damn! You've become a billionaire!"
    else
        Game.comment = ""
    end
    
    Game.prevBalance = Game.balance
    Game.bets = {}
end