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

    -- Button properties
	buttons = {"CLEAR", "DOUBLE", "ALL", "SPIN"}
	
	colors = {
		black={0.109804, 0.109804, 0.109804},
		white={1.000000, 1.000000, 1.000000},
		trans={1.000000, 1.000000, 1.000000, 0.05},
		bg={0.109804, 0.109804, 0.109804},
		chip={1.000000, 0.905882, 0.172549},
		ball={0.996078, 1.000000, 0.172549},
		green={0.149020, 0.796078, 0.129412},
		red={1.000000, 0.172549, 0.172549},
	}
	
	love.graphics.setBackgroundColor(colors.black)
	mainFont = love.graphics.newFont("font/IBMPlexSans-Bold.ttf")
	midFont = love.graphics.newFont("font/IBMPlexSans-Bold.ttf", 14)
	smallFont = love.graphics.newFont("font/IBMPlexSans-Bold.ttf", 10)

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
    for i, label in ipairs(buttons) do
		local x = gridX + (i-1)*gridCellSize*2.4
		local y = gridY + gridCellSize*7
		love.graphics.setColor(colors.trans)
		love.graphics.rectangle("fill", x, y, gridCellSize*2, gridCellSize)
		love.graphics.setColor(colors.white)
		love.graphics.printf(label, x, y + gridCellSize/4, gridCellSize*2, "center")
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
		handleButtonClick(x, y)
        handleGridClick(x, y)
    end
end

function handleButtonClick(x, y)
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
			-- love.audio.play(tickSound)
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
	if lastWon < 0 then
        showGlitch = true
        love.audio.play(woohSound) -- Losing sound effect
    end
	prevBalance = balance
	bets = {}
end
