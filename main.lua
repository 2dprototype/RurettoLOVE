function love.load()
    windowWidth = 700
    windowHeight = 400

    love.window.setTitle("Ruretto")
    love.window.setMode(windowWidth, windowHeight, {resizable = true})

    -- Bets and chips
	defaultBet = 25000
    bets = {} -- Store player's bets
    balance = defaultBet-- Starting balance
	prevBalance = balance
    chipValue = 10 -- Default chip value
	lastWon = 0

    -- Betting layout properties (grid)
    gridCellSize = 30
    gridX = windowWidth/2 - 2.3*gridCellSize
    gridY = windowHeight/2 - 3.5*gridCellSize
	rouletteRadius = 2.5*gridCellSize
	centerX = gridX - 150
	centerY = gridY + 100
	
    -- Roulette wheel properties
    currentAngle = 0 -- Initial rotation of the wheel
    spinSpeed = 0 -- Speed of the spin

    -- Ball properties
    ballAngle = 0 -- Ball's initial angle
    ballSpeed = 0 -- Ball's rotation speed
    ballRadius = rouletteRadius - 10 -- Ball's distance from the center
	prevMod = 0

    -- Spin result
    landedNumber = nil -- The number where the ball lands
    landedColor = nil -- The number where the ball lands

    -- Game state
    isGameOver = false
    showHistory = false
    comment = ""
    
    -- Game history
    gameHistory = {}
    
    -- Button properties
	buttons = {"CLEAR", "DOUBLE", "ALL", "SPIN"}
	playAgainButton = {"PLAY AGAIN"}
	
	colors = {
		black={0.109804, 0.109804, 0.109804},
		white={1.000000, 1.000000, 1.000000},
		trans={1.000000, 1.000000, 1.000000, 0.05},
		bg={0.109804, 0.109804, 0.109804},
		chip={1.000000, 0.905882, 0.172549},
		ball={0.996078, 1.000000, 0.172549},
		green={0.149020, 0.796078, 0.129412},
		red={1.000000, 0.172549, 0.172549},
        panelBg={0.109804, 0.109804, 0.109804, 0.95},
        historyBg={0.070588, 0.070588, 0.070588, 0.9},
        historyHeader={1.000000, 1.000000, 1.000000, 0.8},
        historyRowEven={1.000000, 1.000000, 1.000000, 0.05},
        historyRowOdd={1.000000, 1.000000, 1.000000, 0.1}
	}
	
	love.graphics.setBackgroundColor(colors.black)
	mainFont = love.graphics.newFont("font/IBMPlexSans-Bold.ttf")
	midFont = love.graphics.newFont("font/IBMPlexSans-Bold.ttf", 14)
	smallFont = love.graphics.newFont("font/IBMPlexSans-Bold.ttf", 10)
    historyFont = love.graphics.newFont("font/IBMPlexSans-Bold.ttf", 12)

    -- Define roulette sections
    rouletteSections = {
        {number = 0, color = "green"},
        {number = 32, color = "red"},
        {number = 15, color = "black"},
        {number = 19, color = "red"},
        {number = 4, color = "black"},
        {number = 21, color = "red"},
        {number = 2, color = "black"},
        {number = 25, color = "red"},
        {number = 17, color = "black"},
        {number = 34, color = "red"},
        {number = 6, color = "black"},
        {number = 27, color = "red"},
        {number = 13, color = "black"},
        {number = 36, color = "red"},
        {number = 11, color = "black"},
        {number = 30, color = "red"},
        {number = 8, color = "black"},
        {number = 23, color = "red"},
        {number = 10, color = "black"},
        {number = 5, color = "red"},
        {number = 24, color = "black"},
        {number = 16, color = "red"},
        {number = 33, color = "black"},
        {number = 1, color = "red"},
        {number = 20, color = "black"},
        {number = 14, color = "red"},
        {number = 31, color = "black"},
        {number = 9, color = "red"},
        {number = 22, color = "black"},
        {number = 18, color = "red"},
        {number = 29, color = "black"},
        {number = 7, color = "red"},
        {number = 28, color = "black"},
        {number = 12, color = "red"},
        {number = 35, color = "black"},
        {number = 3, color = "red"},
        {number = 26, color = "black"}
    }
	
	rouletteGrid={
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
	
	rouletteCol1={"2-1", "2-1", "2-1"}
	rouletteRow1={"1 to 12", "13 to 24", "25 to 36"}
	rouletteRow2={"1-18","EVEN", "RED","BLACK", "ODD", "19-36"}
	rouletteZero="0"
	bettingScales = {10, 50, 100, 500, 1000, 5000, 10000, 50000, 1000000, 5000000, 10000000, 50000000}

    tickSound = love.audio.newSource("audio/tick.wav", "static")  
    tickSound:setVolume(0.7)
	woohSound = love.audio.newSource("audio/wooh.wav", "static")
    woohSound:setVolume(1)
	cashSound = love.audio.newSource("audio/cash.wav", "static")
    cashSound:setVolume(1)
end

function love.resize(w, h)
    windowWidth = w
    windowHeight = h
end

function love.update(dt)
	love.graphics.setFont(mainFont)
    if spinSpeed > 0.25 then
        currentAngle = currentAngle + spinSpeed * dt
        spinSpeed = spinSpeed * 0.99 -- Gradually slow down
        ballAngle = ballAngle - ballSpeed * dt
        ballSpeed = math.max(spinSpeed * 1.5, 0)
		local mod = (currentAngle*spinSpeed) % math.pi
		if prevMod >= mod then
			tickSound:setPitch(spinSpeed)
			love.audio.play(tickSound)
		end
		prevMod = mod
    elseif landedNumber == nil then
        local normalizedAngle = (ballAngle - currentAngle) % (2 * math.pi)
        local sectionSize = 2 * math.pi / #rouletteSections
        local landedIndex = math.floor(normalizedAngle / sectionSize) + 1
		landedNumber = rouletteSections[landedIndex].number
		landedColor = rouletteSections[landedIndex].color
        if landedNumber then checkBets(landedNumber, landedColor) end
		if lastWon < 0 then
			love.audio.play(woohSound)
		elseif lastWon > 0 then
			love.audio.play(cashSound)
		end
    end
end

function love.draw()
    gridCellSize = windowWidth/23
	if gridCellSize > 40 then
		gridCellSize = 40
	end
    gridX = windowWidth/2 - 2.3*gridCellSize
    gridY = windowHeight/2 - 3.5*gridCellSize
	rouletteRadius = 3.5*gridCellSize
	centerX = gridX - 5*gridCellSize
	centerY = gridY + 3.33*gridCellSize
	
	drawWheel()
    drawBettingGrid()
	
    -- Draw buttons
    if isGameOver then
        -- Draw Play Again button
        local x = gridX
        local y = gridY + gridCellSize*7
        love.graphics.setColor(colors.white)
        love.graphics.rectangle("fill", x, y, gridCellSize*4, gridCellSize)
        love.graphics.setColor(colors.black)
        love.graphics.printf("PLAY AGAIN", x, y + gridCellSize/4, gridCellSize*4, "center")
    else
        -- Draw normal buttons
        for i, label in ipairs(buttons) do
            local x = gridX + (i-1)*gridCellSize*2.4
            local y = gridY + gridCellSize*7
            love.graphics.setColor(colors.trans)
            love.graphics.rectangle("fill", x, y, gridCellSize*2, gridCellSize)
            love.graphics.setColor(colors.white)
            love.graphics.printf(label, x, y + gridCellSize/4, gridCellSize*2, "center")
        end
    end
    
	-- Draw bettingScales
    for i, val in ipairs(bettingScales) do
		if val <= balance then
			local x = gridX + gridCellSize * (i - 2/3)
			local y = gridY + gridCellSize*6
			if chipValue == val then
				love.graphics.setColor(1,1,1,0.3)
				love.graphics.circle("fill", x, y, gridCellSize/2)
			end
			drawChip(val, x, y, gridCellSize)
		end
	end
	
    if showGlitch then
        love.graphics.setShader() -- Reset shader
    end
	
	-- Display balance
	local sum = 0
	for i, bet in pairs(bets) do
		sum = sum + bet
	end
	
	love.graphics.setFont(midFont)
	
	local label = "$" .. format_num_comma(balance) .. " $" .. format_num_comma(sum)
	local tw, th = love.graphics.newText(love.graphics.getFont(), label):getDimensions()
	
    love.graphics.setColor(colors.white)
    love.graphics.print(label, 14, 14)

	label = format_num_comma(lastWon)

	if lastWon > 0 then
		love.graphics.setColor(colors.green)
		label = "+$" .. format_num_comma(lastWon)
	elseif lastWon < 0 then
		love.graphics.setColor(colors.red)
		label = "-$" .. format_num_comma(math.abs(lastWon))
	else 
		love.graphics.setColor(colors.white)
		label = "$0"
	end
    love.graphics.print(label, 18 + tw, 14)
    
    -- Draw comment
    if comment ~= "" then
        love.graphics.setColor(colors.white)
        local commentWidth = love.graphics.getFont():getWidth(comment)
        love.graphics.print(comment, gridX + gridCellSize*6 - commentWidth/2, gridY - gridCellSize)
    end
	
	-- Draw History button
    love.graphics.setColor(colors.white)
    love.graphics.circle("line", windowWidth - 30, 30, 15)
    love.graphics.setFont(smallFont)
    love.graphics.print("H", windowWidth - 30 - smallFont:getWidth("H")/2, 30 - smallFont:getHeight()/2)
    
    -- Draw history panel if shown
    if showHistory then
        drawHistoryPanel()
    end
	
end

function drawChip(num, x, y, r) 
	local a = 2 * math.pi / 10
    for i = 1, 10 do
		local angleStart = (i * a)
        local angleEnd = angleStart + a
		if i % 2 == 1 then
			love.graphics.setColor(colors.chip) 
		else
			love.graphics.setColor(colors.white)
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

function drawWheel()
	
	local a = 2 * math.pi / #rouletteSections
    for i, section in ipairs(rouletteSections) do
		local angleStart = ((i-1) * a) + currentAngle
        local angleEnd = angleStart + a
        love.graphics.setColor(colors[section.color])
        love.graphics.arc("fill", centerX, centerY, rouletteRadius, angleStart, angleEnd)
		
		if section.color == "green" then
			love.graphics.setColor(colors.black)
		elseif section.color == "red" then
			love.graphics.setColor(colors.black)
		else
			love.graphics.setColor(colors.red)
		end
		
		love.graphics.push()
		love.graphics.translate(centerX, centerY)
		local angle = angleStart
		love.graphics.rotate(angle)
		love.graphics.print(section.number, rouletteRadius - 0.6*gridCellSize, textX, 0)
		love.graphics.pop()
    end
	
	
	love.graphics.setLineWidth(1)
    love.graphics.setColor(colors.red)
    love.graphics.arc("line", "open", centerX, centerY, rouletteRadius-0.8*gridCellSize, currentAngle + a*2, currentAngle + a*#rouletteSections) 
	
	
	love.graphics.setColor(colors.black)
    love.graphics.circle("fill", centerX, centerY, rouletteRadius-1.66*gridCellSize)
	
	love.graphics.setLineWidth(1.5)
	love.graphics.setColor(colors.red)
    love.graphics.circle("line", centerX, centerY, rouletteRadius-1.66*gridCellSize)
   
	
    if landedNumber then
		if landedColor == "red" then
			love.graphics.setColor(colors.red)
		elseif landedColor == "black" then
			love.graphics.setColor(colors.trans)
		else 
			love.graphics.setColor(colors.green)
		end
		love.graphics.circle("fill", centerX, centerY, 15)
		if landedColor == "black" then
			love.graphics.setColor(colors.red)
		else 
			love.graphics.setColor(colors.black)
		end
		love.graphics.printf(landedNumber, centerX - 20, centerY - love.graphics.getFont():getHeight()/2, 40, "center")
    end

    -- Draw the ball
    ballRadius = rouletteRadius - 2*gridCellSize
    local ballX = centerX + math.cos(ballAngle) * ballRadius
    local ballY = centerY + math.sin(ballAngle) * ballRadius
    love.graphics.setColor(colors.ball)
    love.graphics.circle("fill", ballX, ballY, 4.2)
end

function drawBettingGrid()
	-- zero 
	-- Draw cell background
	love.graphics.setColor(colors.green)
	love.graphics.rectangle("fill", gridX-gridCellSize, gridY, gridCellSize, gridCellSize*3)

	-- Draw the number
	love.graphics.setColor(colors.black)
	love.graphics.printf(rouletteZero, gridX-gridCellSize, gridY + gridCellSize*1.25, gridCellSize, "center")
	
	if bets[0] ~= nil then
		drawChip(bets[0], gridX-gridCellSize/2, gridY + gridCellSize*1.5, gridCellSize)
	end
	
	for rowIndex, str in ipairs(rouletteRow1) do
		local cellSize = gridCellSize * 4
		local x = gridX + (rowIndex - 1) * cellSize
		local y = gridY + 3 * gridCellSize

		-- Draw cell background
		love.graphics.setColor(colors.trans)
		love.graphics.rectangle("fill", x, y, cellSize, gridCellSize)

		-- Draw the number
		love.graphics.setColor(colors.white)
		love.graphics.printf(str, x, y + gridCellSize / 4, cellSize, "center")

		local v = bets[40 + rowIndex]
		-- Draw chip if a bet is placed
		if v ~= nil then
			drawChip(v, x + cellSize / 2, y + gridCellSize / 2, gridCellSize)
		end
	end
	
	for rowIndex, str in ipairs(rouletteRow2) do
		local cellSize = gridCellSize * 2
		local x = gridX + (rowIndex - 1) * cellSize
		local y = gridY + 4 * gridCellSize

		-- Draw cell background
		if str == "RED" then
			love.graphics.setColor(colors.red)
		elseif str == "BLACK" then
			love.graphics.setColor(colors.black)
		else
			love.graphics.setColor(colors.trans)
		end
		love.graphics.rectangle("fill", x, y, cellSize, gridCellSize)

		-- Draw the number
		love.graphics.setColor(colors.white)
		love.graphics.printf(str, x, y + gridCellSize / 4, cellSize, "center")

		-- Draw chip if a bet is placed
		local v = bets[50 + rowIndex]
		if v ~= nil then
			drawChip(v, x + cellSize / 2, y + gridCellSize / 2, gridCellSize)
		end
	end
	
	for colIndex, str in ipairs(rouletteCol1) do
		local x = gridX + gridCellSize*12
		local y = gridY + gridCellSize * (colIndex-1)

		-- Draw cell background
		love.graphics.setColor(colors.trans)
		love.graphics.rectangle("fill", x, y, gridCellSize, gridCellSize)

		-- Draw the number
		love.graphics.setColor(colors.white)
		love.graphics.printf(str, x, y + gridCellSize / 4, gridCellSize, "center")

		-- Draw chip if a bet is placed
		local v = bets[60 + colIndex]
		if v ~= nil then
			drawChip(v, x + gridCellSize / 2, y + gridCellSize / 2, gridCellSize)
		end
	end
	
    for rowIndex, row in ipairs(rouletteGrid) do
        for colIndex, cell in ipairs(row) do
            local x = gridX + (rowIndex - 1) * gridCellSize
            local y = gridY + (colIndex - 1) * gridCellSize

            -- Draw cell background
            love.graphics.setColor(colors[cell.color])
            love.graphics.rectangle("fill", x, y, gridCellSize, gridCellSize)

            -- Draw the number
            if cell.color == "red" then 
				love.graphics.setColor(colors.black)
			elseif cell.color == "black" then 
				love.graphics.setColor(colors.red)
			else 
				love.graphics.setColor(colors.white)
			end
            love.graphics.printf("" .. cell.num, x, y + gridCellSize / 4, gridCellSize, "center")

            -- Draw chip if a bet is placed
			local v = bets[cell.num]
            if v ~= nil then
                drawChip(v, x + gridCellSize / 2, y + gridCellSize / 2, gridCellSize)
            end
        end
    end

end

function love.mousepressed(x, y, button)
    if button == 1 then
        -- Check if history panel is open
        if showHistory then
            -- Check if close button is clicked
            local panelWidth = windowWidth * 0.8
            local panelHeight = windowHeight * 0.7
            local panelX = (windowWidth - panelWidth) / 2
            local panelY = (windowHeight - panelHeight) / 2
            
            local closeBtnSize = 20
            local closeBtnX = panelX + panelWidth - closeBtnSize - 10
            local closeBtnY = panelY + 10
            
            local dx = x - closeBtnX
            local dy = y - closeBtnY
            if dx*dx + dy*dy <= (closeBtnSize/2)*(closeBtnSize/2) then
                showHistory = false
                return
            end
            
            -- Don't process other clicks when history panel is open
            return
        end
        
        -- Check history button
        local dx = x - (windowWidth - 30)
        local dy = y - 30
        if dx*dx + dy*dy <= 15*15 then
            showHistory = not showHistory
            return
        end
        
        if isGameOver then
            -- Check Play Again button
            local btnX = gridX
            local btnY = gridY + gridCellSize*7
            local btnWidth = gridCellSize*4
            local btnHeight = gridCellSize
            
            if x >= btnX and x <= btnX + btnWidth and y >= btnY and y <= btnY + btnHeight then
                resetGame()
            end
        else
            handleButtonClick(x, y)
            handleGridClick(x, y)
        end
    end
end

function handleButtonClick(x, y)
    if isGameOver then return end
    
	for i, label in ipairs(buttons) do
		local a = gridX + (i-1)*gridCellSize*2.4
		local b = gridY + gridCellSize*7
		if x >= a and x <= a + gridCellSize*2 and y >= b and y <= b + gridCellSize then 
			if i == 1 then
			    for _, val in pairs(bets) do
					balance = balance + val
				end		
				bets = {}			
			elseif i == 2 then
			    for i, val in pairs(bets) do
					local d = val*2
					if balance - d >= 0 then
						bets[i] = d
					end
				end		
			elseif i == 3 then
			    chipValue = balance
			elseif i == 4 then
				spinSpeed = 6
				landedNumber = nil
				landedColor = nil
			end
		end
	end
	
    for i, val in ipairs(bettingScales) do
		local r =  gridCellSize/2.5
		local a = gridX + gridCellSize * (i - 2/3) - r
		local b = gridY + gridCellSize*6 - r
		if x >= a and x <= a + r*2 and y >= b and y <= b + r*2 then 
			chipValue = val
		end
	end
end

function handleGridClick(x, y)
    if isGameOver then return end
    
	-- Handle clicks for rouletteZero
	if x >= gridX - gridCellSize and x <= gridX and y >= gridY and y <= (gridY + gridCellSize*3) then
		local number = 0
		if not bets[number] and balance >= chipValue then
			-- Place a bet if not already bet on this number and if the player has enough balance
			bets[number] = chipValue
			balance = balance - chipValue
		elseif bets[number] then
			-- Remove bet if already placed on this number
			bets[number] = nil
			balance = balance + chipValue
		end
	end
	
    -- Handle clicks for rouletteRow1
    for rowIndex, row in ipairs(rouletteRow1) do
        local cellSize = gridCellSize * 4
        local cellX = gridX + (rowIndex - 1) * cellSize
        local cellY = gridY + 3 * gridCellSize

        if x >= cellX and x <= cellX + cellSize and y >= cellY and y <= cellY + gridCellSize then
            local number = rowIndex + 40
            if not bets[number] and balance >= chipValue then
                -- Place a bet if not already bet on this number and if the player has enough balance
                bets[number] = chipValue
                balance = balance - chipValue
            elseif bets[number] then
                -- Remove bet if already placed on this number
                bets[number] = nil
                balance = balance + chipValue
            end
        end
    end

    -- Handle clicks for rouletteRow2
    for rowIndex, row in ipairs(rouletteRow2) do
        local cellSize = gridCellSize * 2
        local cellX = gridX + (rowIndex - 1) * cellSize
        local cellY = gridY + 4 * gridCellSize

        if x >= cellX and x <= cellX + cellSize and y >= cellY and y <= cellY + gridCellSize then
            local number = rowIndex + 50
            if not bets[number] and balance >= chipValue then
                -- Place a bet if not already bet on this number and if the player has enough balance
                bets[number] = chipValue
                balance = balance - chipValue
            elseif bets[number] then
                -- Remove bet if already placed on this number
                bets[number] = nil
                balance = balance + chipValue
            end
        end
    end  
	
	-- Handle clicks for rouletteCol1
    for colIndex, row in ipairs(rouletteCol1) do
		local cellX = gridX + gridCellSize*12
		local cellY = gridY + gridCellSize * (colIndex-1)

        if x >= cellX and x <= cellX + gridCellSize and y >= cellY and y <= cellY + gridCellSize then
            local number = colIndex + 60
            if not bets[number] and balance >= chipValue then
                -- Place a bet if not already bet on this number and if the player has enough balance
                bets[number] = chipValue
                balance = balance - chipValue
            elseif bets[number] then
                -- Remove bet if already placed on this number
                bets[number] = nil
                balance = balance + chipValue
            end
        end
    end

    -- Handle clicks for rouletteGrid
    for rowIndex, row in ipairs(rouletteGrid) do
        for colIndex, cell in ipairs(row) do
            local cellX = gridX + (rowIndex - 1) * gridCellSize
            local cellY = gridY + (colIndex - 1) * gridCellSize

            if x >= cellX and x <= cellX + gridCellSize and y >= cellY and y <= cellY + gridCellSize then
                if not bets[cell.num] and balance >= chipValue then
                    -- Place a bet if not already bet on this number and if the player has enough balance
                    bets[cell.num] = chipValue
                    balance = balance - chipValue
                elseif bets[cell.num] then
                    -- Remove bet if already placed on this number
                    bets[cell.num] = nil
                    balance = balance + chipValue
                end
            end
        end
    end
end

function drawHistoryPanel()
    local panelWidth = windowWidth * 0.8
    local panelHeight = windowHeight * 0.7
    local panelX = (windowWidth - panelWidth) / 2
    local panelY = (windowHeight - panelHeight) / 2
    
    -- Draw background
    love.graphics.setColor(colors.historyBg)
    love.graphics.rectangle("fill", panelX, panelY, panelWidth, panelHeight)
    
    -- Draw border
    love.graphics.setColor(colors.white)
    love.graphics.rectangle("line", panelX, panelY, panelWidth, panelHeight)
    
    -- Draw title
    love.graphics.setColor(colors.historyHeader)
    love.graphics.setFont(midFont)
    local title = "Game History"
    local titleWidth = love.graphics.getFont():getWidth(title)
    love.graphics.print(title, panelX + panelWidth/2 - titleWidth/2, panelY + 10)
    
    -- Draw close button
    local closeBtnSize = 20
    local closeBtnX = panelX + panelWidth - closeBtnSize - 10
    local closeBtnY = panelY + 10
    love.graphics.setColor(colors.red)
    love.graphics.circle("line", closeBtnX, closeBtnY, closeBtnSize/2)
    love.graphics.setColor(colors.white)
    love.graphics.print("x", closeBtnX - smallFont:getWidth("x")/2, closeBtnY - smallFont:getHeight()/2 - closeBtnSize/4)
    
    -- Draw column headers
    love.graphics.setFont(historyFont)
    local columnWidth = panelWidth / 5
    local headers = {"Time", "Bet", "Result", "Won", "Balance"}
    for i, header in ipairs(headers) do
        love.graphics.setColor(colors.white)
        love.graphics.print(header, panelX + (i-1)*columnWidth + 10, panelY + 50)
    end
    
    -- Draw history entries
    local startY = panelY + 80
    for i, entry in ipairs(gameHistory) do
        local y = startY + (i-1) * 30
        
        -- Alternate row colors
        if i % 2 == 0 then
            love.graphics.setColor(colors.historyRowEven)
        else
            love.graphics.setColor(colors.historyRowOdd)
        end
        love.graphics.rectangle("fill", panelX, y - 5, panelWidth, 25)
        
        love.graphics.setFont(historyFont)
        
        -- Time
        love.graphics.setColor(colors.white)
        love.graphics.print(entry.time, panelX + 10, y)
        
        -- Bet
        love.graphics.setColor(colors.white)
        love.graphics.print("$" .. format_num_comma(entry.bet), panelX + columnWidth, y)
        
        -- Result
        love.graphics.setColor(colors.white)
        love.graphics.print(entry.number .. " " .. entry.color, panelX + 2*columnWidth, y)
        
        -- Won
        local wonText
        if entry.won > 0 then
            wonText = "+$" .. format_num_comma(entry.won)
            love.graphics.setColor(colors.green)
        elseif entry.won < 0 then
            wonText = "-$" .. format_num_comma(math.abs(entry.won))
            love.graphics.setColor(colors.red)
        else
            wonText = "$0"
            love.graphics.setColor(colors.white)
        end
        love.graphics.print(wonText, panelX + 3*columnWidth, y)
        
        -- Balance change
        local balanceText
        if entry.balanceChange > 0 then
            balanceText = "+$" .. format_num_comma(entry.balanceChange)
            love.graphics.setColor(colors.green)
        elseif entry.balanceChange < 0 then
            balanceText = "-$" .. format_num_comma(math.abs(entry.balanceChange))
            love.graphics.setColor(colors.red)
        else
            balanceText = "$0"
            love.graphics.setColor(colors.white)
        end
        love.graphics.print(balanceText, panelX + 4*columnWidth, y)
    end
    
    -- Draw "No games played yet" message if history is empty
    if #gameHistory == 0 then
        love.graphics.setColor(colors.white)
        local msg = "No games played yet"
        local msgWidth = love.graphics.getFont():getWidth(msg)
        love.graphics.print(msg, panelX + panelWidth/2 - msgWidth/2, panelY + panelHeight/2)
    end
    
    -- Draw summary at bottom
    if #gameHistory > 0 then
        local totalWon = 0
        local totalLost = 0
        local wins = 0
        local losses = 0
        
        for _, entry in ipairs(gameHistory) do
            if entry.won > 0 then
                totalWon = totalWon + entry.won
                wins = wins + 1
            elseif entry.won < 0 then
                totalLost = totalLost + math.abs(entry.won)
                losses = losses + 1
            end
        end
        
        local summaryY = panelY + panelHeight - 30
        local totalGames = wins + losses
        local winRate = totalGames > 0 and ((wins / totalGames) * 100) or 0
        
        local summaryText = string.format("Games: %d | Wins: %d (%.0f%%) | Profit: $%s", 
            totalGames, wins, winRate, format_num_comma(totalWon - totalLost))
        
        love.graphics.setColor(colors.white)
        love.graphics.setFont(smallFont)
        local summaryWidth = love.graphics.getFont():getWidth(summaryText)
        love.graphics.print(summaryText, panelX + panelWidth/2 - summaryWidth/2, summaryY)
    end
end

function addToHistory(betAmount, resultNumber, resultColor, wonAmount, balanceChange)
    local historyEntry = {
        time = os.date("%H:%M:%S"),
        bet = betAmount,
        number = resultNumber,
        color = resultColor,
        won = wonAmount,
        balanceChange = balanceChange,
        finalBalance = balance
    }
    
    table.insert(gameHistory, historyEntry)
    
    -- Keep only last 100 games
    if #gameHistory > 100 then
        table.remove(gameHistory, 1)
    end
end

function resetGame()
    balance = defaultBet
    prevBalance = balance
    lastWon = 0
    bets = {}
    landedNumber = nil
    landedColor = nil
    isGameOver = false
    comment = ""
    chipValue = 10
end


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

-- Function to format numbers with commas
function format_num_comma(n)
    local str = tostring(n)
    local out = ""
    local commaCount = 0

    for i = #str, 1, -1 do
        out = str:sub(i, i) .. out -- Add the character to the output
        commaCount = commaCount + 1
        if commaCount == 3 and i > 1 then
            out = "," .. out
            commaCount = 0
        end
    end

    return out
end


function checkBets(num, col)
    -- Calculate total bet before spin
    local totalBetBefore = 0
    for _, bet in pairs(bets) do
        totalBetBefore = totalBetBefore + bet
    end
    
    local pointsBefore = balance
    
	if bets[num] and (num >= 0 and num <= 36) then
		balance = balance + bets[num] * 36
	end
	-- row 1
	if bets[41] and num >= 1 and num <= 12 then
		balance = balance + bets[41] * 3
	elseif bets[42] and num >= 13 and num <= 24 then
		balance = balance + bets[42] * 3
	elseif bets[43] and num >= 25 and num <= 36 then
		balance = balance + bets[43] * 3
	end
	-- row 2
	if bets[51] and num >= 1 and num <= 18 then
		balance = balance + bets[51] * 2
	elseif bets[56] and num >= 19 and num <= 36 then
		balance = balance + bets[56] * 2
	end
	-- even odd
	if bets[52] and num % 2 == 0 then
		balance = balance + bets[52] * 2
	elseif bets[55] and num % 2 ~= 0 then
		balance = balance + bets[55] * 2
	end
	-- black red
	if bets[53] and col == "red" then
		balance = balance + bets[53] * 2
	elseif bets[54] and col == "black" then
		balance = balance + bets[54] * 2
	end
	-- cols
	if bets[61] and (num >= 3 and num <= 36 and num % 3 == 0) then
		balance = balance + bets[61] * 3
	elseif bets[62] and (num >= 2 and num <= 35 and (num - 2) % 3 == 0) then
		balance = balance + bets[62] * 3
	elseif bets[63] and (num >= 1 and num <= 34 and (num - 1) % 3 == 0) then
		balance = balance + bets[63] * 3
	end
	
	lastWon = balance - prevBalance
    
    -- Calculate winnings/losses for history
    local wonAmount = 0
    local balanceChange = balance - pointsBefore
    
    if balanceChange > 0 then
        wonAmount = balanceChange
    else
        wonAmount = -totalBetBefore
    end
    
    -- Add to history
    addToHistory(totalBetBefore, num, col, wonAmount, balanceChange)
    
    if lastWon < 0 then
        showGlitch = true
        love.audio.play(woohSound) -- Losing sound effect
    end
    
    -- Check for game over
    if balance == 0 then
        comment = "Woooh! You lost all of your chips, didn't you?"
        isGameOver = true
    elseif balance >= 1000000000 then
        comment = "Damn! You've become a billionaire!"
    elseif balance < 1000000000 then
        comment = ""
    end
    
	prevBalance = balance
	bets = {}
end