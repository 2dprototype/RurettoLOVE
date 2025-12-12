Roulette = {}

function Roulette.init()
    Roulette.currentAngle = 0
    Roulette.spinSpeed = 0
    Roulette.ballAngle = 0
    Roulette.ballSpeed = 0
    Roulette.ballRadius = 0
    Roulette.prevMod = 0
    Roulette.landedNumber = nil
    Roulette.landedColor = nil
    Roulette.centerX = 0
    Roulette.centerY = 0
    Roulette.rouletteRadius = 0
    
    -- Define roulette sections
    Roulette.sections = {
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
end

function Roulette.reset()
    Roulette.currentAngle = 0
    Roulette.spinSpeed = 0
    Roulette.ballAngle = 0
    Roulette.ballSpeed = 0
    Roulette.landedNumber = nil
    Roulette.landedColor = nil
end

function Roulette.resize(gridCellSize, gridX, gridY)
    Roulette.rouletteRadius = 3.5 * gridCellSize
    Roulette.centerX = gridX - 5 * gridCellSize
    Roulette.centerY = gridY + 3.33 * gridCellSize
    Roulette.ballRadius = Roulette.rouletteRadius - 2 * gridCellSize
end

function Roulette.update(dt)
    if Roulette.spinSpeed > 0.25 then
        Roulette.currentAngle = Roulette.currentAngle + Roulette.spinSpeed * dt
        Roulette.spinSpeed = Roulette.spinSpeed * 0.99 -- Gradually slow down
        Roulette.ballAngle = Roulette.ballAngle - Roulette.ballSpeed * dt
        Roulette.ballSpeed = math.max(Roulette.spinSpeed * 1.5, 0)
        
        local mod = (Roulette.currentAngle * Roulette.spinSpeed) % math.pi
        if Roulette.prevMod >= mod then
            Game.tickSound:setPitch(Roulette.spinSpeed)
            love.audio.play(Game.tickSound)
        end
        Roulette.prevMod = mod
    elseif Roulette.landedNumber == nil then
        local normalizedAngle = (Roulette.ballAngle - Roulette.currentAngle) % (2 * math.pi)
        local sectionSize = 2 * math.pi / #Roulette.sections
        local landedIndex = math.floor(normalizedAngle / sectionSize) + 1
        
        Roulette.landedNumber = Roulette.sections[landedIndex].number
        Roulette.landedColor = Roulette.sections[landedIndex].color
        
        if Roulette.landedNumber then 
            Game.checkBets(Roulette.landedNumber, Roulette.landedColor) 
        end
    end
end

function Roulette.draw()
    local a = 2 * math.pi / #Roulette.sections
    
    -- Draw wheel sections
    for i, section in ipairs(Roulette.sections) do
        local angleStart = ((i-1) * a) + Roulette.currentAngle
        local angleEnd = angleStart + a
        
        love.graphics.setColor(Game.colors[section.color])
        love.graphics.arc("fill", Roulette.centerX, Roulette.centerY, 
                          Roulette.rouletteRadius, angleStart, angleEnd)
        
        if section.color == "green" then
            love.graphics.setColor(Game.colors.black)
        elseif section.color == "red" then
            love.graphics.setColor(Game.colors.black)
        else
            love.graphics.setColor(Game.colors.red)
        end
        
        love.graphics.push()
        love.graphics.translate(Roulette.centerX, Roulette.centerY)
        local angle = angleStart
        love.graphics.rotate(angle)
        love.graphics.print(section.number, Roulette.rouletteRadius - 0.6 * Game.gridCellSize, 5)
        love.graphics.pop()
    end
    
    -- Draw wheel outline
    love.graphics.setLineWidth(1)
    love.graphics.setColor(Game.colors.red)
    love.graphics.arc("line", "open", Roulette.centerX, Roulette.centerY, 
                      Roulette.rouletteRadius - 0.8 * Game.gridCellSize, 
                      Roulette.currentAngle + a * 2, Roulette.currentAngle + a * #Roulette.sections)
    
    -- Draw center
    love.graphics.setColor(Game.colors.black)
    love.graphics.circle("fill", Roulette.centerX, Roulette.centerY, 
                         Roulette.rouletteRadius - 1.66 * Game.gridCellSize)
    
    love.graphics.setLineWidth(1.5)
    love.graphics.setColor(Game.colors.red)
    love.graphics.circle("line", Roulette.centerX, Roulette.centerY, 
                         Roulette.rouletteRadius - 1.66 * Game.gridCellSize)
    
    -- Draw landed number
    if Roulette.landedNumber then
        if Roulette.landedColor == "red" then
            love.graphics.setColor(Game.colors.red)
        elseif Roulette.landedColor == "black" then
            love.graphics.setColor(Game.colors.trans)
        else 
            love.graphics.setColor(Game.colors.green)
        end
        love.graphics.circle("fill", Roulette.centerX, Roulette.centerY, 15)
        
        if Roulette.landedColor == "black" then
            love.graphics.setColor(Game.colors.red)
        else 
            love.graphics.setColor(Game.colors.black)
        end
        love.graphics.printf(Roulette.landedNumber, 
                            Roulette.centerX - 20, 
                            Roulette.centerY - love.graphics.getFont():getHeight()/2, 
                            40, "center")
    end
    
    -- Draw the ball
    local ballX = Roulette.centerX + math.cos(Roulette.ballAngle) * Roulette.ballRadius
    local ballY = Roulette.centerY + math.sin(Roulette.ballAngle) * Roulette.ballRadius
    love.graphics.setColor(Game.colors.ball)
    love.graphics.circle("fill", ballX, ballY, 4.2)
end

function Roulette.startSpin()
    Roulette.spinSpeed = 6
    Roulette.landedNumber = nil
    Roulette.landedColor = nil
end