History = {}

function History.init()
    History.gameHistory = {}
    History.showHistory = false
    History.hoverIndex = nil
    History.selectedIndex = nil

    -- scrolling
    History.scrollY = 0
    History.targetScrollY = 0
    History.maxScroll = 0

    -- scrollbar
    History.dragging = false
    History.dragOffset = 0

    History.colors = {
        panelBg = {0.109804, 0.109804, 0.109804, 0.95},
        historyBg = {0.070588, 0.070588, 0.070588, 0.9},

        header = {1,1,1,0.9},

        rowEven = {1,1,1,0.05},
        rowOdd  = {1,1,1,0.10},
        rowHover = {1,1,1,0.18},
        rowSelected = {1,1,1,0.23},
		
        white = {1,1,1},
        red = {1,0.17,0.17},
        green = {0.15,0.79,0.13},

        scrollbarTrack = {1,1,1,0.12},
        scrollbarThumb = {1,1,1,0.65},
        scrollbarThumbHover = {1,1,1,0.85},
    }

    historyFont = love.graphics.newFont("font/IBMPlexSans-Bold.ttf", 10)
end

function History.reset()
    History.gameHistory = {}
end

function History.addEntry(betAmount, resultNumber, resultColor, wonAmount, balanceChange)
    table.insert(History.gameHistory, {
        time = os.date("%H:%M:%S"),
        bet = betAmount,
        number = resultNumber,
        color = resultColor,
        won = wonAmount,
        balanceChange = balanceChange,
        finalBalance = Game.balance
    })

    if #History.gameHistory > 300 then
        table.remove(History.gameHistory, 1)
    end
end

-- Internal helper
local function clamp(v, min, max)
    return v < min and min or (v > max and max or v)
end

function History.updateScroll(panelHeight)
    local rowH = 32
    local visibleRows = math.floor((panelHeight - 140) / rowH)
    local totalRows = #History.gameHistory
    local extra = math.max(0, totalRows - visibleRows)

    History.maxScroll = extra * rowH
    History.targetScrollY = clamp(History.targetScrollY, 0, History.maxScroll)
end

function History.update(dt)
    if not History.showHistory then return end

    -- Smooth scrolling
    local speed = 10
    History.scrollY = History.scrollY + (History.targetScrollY - History.scrollY) * dt * speed
end

function History.drawPanel()
    local panelW = windowWidth * 0.8
    local panelH = windowHeight * 0.7
    local panelX = (windowWidth - panelW) / 2
    local panelY = (windowHeight - panelH) / 2

    -- panel bg
    love.graphics.setColor(History.colors.historyBg)
    love.graphics.rectangle("fill", panelX, panelY, panelW, panelH, 12)

    -- border
    love.graphics.setColor(History.colors.white)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", panelX, panelY, panelW, panelH, 12)

    -- title
    love.graphics.setColor(History.colors.header)
    love.graphics.setFont(midFont)
    local title = "Game History"
    local tW = midFont:getWidth(title)
    love.graphics.print(title, panelX + panelW/2 - tW/2, panelY + 10)

    -- close button
    local closeX = panelX + panelW - 30
    local closeY = panelY + 20
    love.graphics.setColor(History.colors.red)
    love.graphics.circle("fill", closeX, closeY, 10)
    love.graphics.setColor(History.colors.white)
    love.graphics.print("x", closeX - 4, closeY - 7)

    -- columns
    love.graphics.setFont(historyFont)
    local colW = panelW / 5
    local headers = {"Time","Bet","Result","Won","Balance"}

    for i, h in ipairs(headers) do
        love.graphics.setColor(History.colors.white)
        love.graphics.print(h, panelX + (i-1)*colW + 10, panelY + 50)
    end

    ------------------------------------------------------------------------------
    -- SCROLL AREA
    ------------------------------------------------------------------------------

    local listY = panelY + 80
    local listH = panelH - 140
    local rowH = 32

    History.updateScroll(panelH)

    love.graphics.setScissor(panelX, listY, panelW, listH)

    local offset = -History.scrollY
    History.hoverIndex = nil

    for i, entry in ipairs(History.gameHistory) do
        local y = listY + (i-1)*rowH + offset

        if y > listY - rowH and y < listY + listH then
            
            -- Hover detection
            if love.mouse.getX() > panelX and love.mouse.getX() < panelX + panelW
            and love.mouse.getY() > y and love.mouse.getY() < y + rowH then
                History.hoverIndex = i
            end

            -- Row background
            if History.selectedIndex == i then
                love.graphics.setColor(History.colors.rowSelected)
            elseif History.hoverIndex == i then
                love.graphics.setColor(History.colors.rowHover)
            elseif i % 2 == 0 then
                love.graphics.setColor(History.colors.rowEven)
            else
                love.graphics.setColor(History.colors.rowOdd)
            end

            love.graphics.rectangle("fill", panelX, y, panelW, rowH)

            -- Draw row text
            love.graphics.setColor(History.colors.white)
            love.graphics.print(entry.time, panelX + 10, y + 8)
            love.graphics.print("$"..format_num_comma(entry.bet), panelX + colW, y + 8)
            love.graphics.print(entry.number.." "..entry.color, panelX + colW*2, y + 8)

            -- won/lost
            if entry.won > 0 then
                love.graphics.setColor(History.colors.green)
                love.graphics.print("+$"..format_num_comma(entry.won), panelX + colW*3, y + 8)
            elseif entry.won < 0 then
                love.graphics.setColor(History.colors.red)
                love.graphics.print("-$"..format_num_comma(math.abs(entry.won)), panelX + colW*3, y + 8)
            else
                love.graphics.setColor(History.colors.white)
                love.graphics.print("$0", panelX + colW*3, y + 8)
            end

            -- balance
            if entry.balanceChange > 0 then
                love.graphics.setColor(History.colors.green)
                love.graphics.print("+$"..format_num_comma(entry.balanceChange), panelX + colW*4, y + 8)
            elseif entry.balanceChange < 0 then
                love.graphics.setColor(History.colors.red)
                love.graphics.print("-$"..format_num_comma(math.abs(entry.balanceChange)), panelX + colW*4, y + 8)
            else
                love.graphics.setColor(History.colors.white)
                love.graphics.print("$0", panelX + colW*4, y + 8)
            end
        end
    end

    love.graphics.setScissor()

    ------------------------------------------------------------------------------
    -- SCROLLBAR
    ------------------------------------------------------------------------------
    if History.maxScroll > 0 then
        local trackX = panelX + panelW - 10
        local trackY = listY
        local trackH = listH
        local thumbH = trackH * (trackH / (trackH + History.maxScroll))
        local thumbY = trackY + (History.scrollY / History.maxScroll) * (trackH - thumbH)

        -- background track
        love.graphics.setColor(History.colors.scrollbarTrack)
        love.graphics.rectangle("fill", trackX, trackY, 6, trackH, 3)

        -- thumb
        local hoveringThumb =
            love.mouse.getX() >= trackX and love.mouse.getX() <= trackX + 6 and
            love.mouse.getY() >= thumbY and love.mouse.getY() <= thumbY + thumbH

        if hoveringThumb or History.dragging then
            love.graphics.setColor(History.colors.scrollbarThumbHover)
        else
            love.graphics.setColor(History.colors.scrollbarThumb)
        end

        love.graphics.rectangle("fill", trackX, thumbY, 6, thumbH, 3)

        -- save positions
        History.scrollbar = {
            x = trackX,
            y = thumbY,
            w = 6,
            h = thumbH,
            trackY = trackY,
            trackH = trackH
        }
    end

    ------------------------------------------------------------------------------
    -- No entries message
    ------------------------------------------------------------------------------
    if #History.gameHistory == 0 then
        love.graphics.setColor(History.colors.white)
        local msg = "No games played yet"
        local w = love.graphics.getFont():getWidth(msg)
        love.graphics.print(msg, panelX + panelW/2 - w/2, panelY + panelH/2)
    end
end

-- INPUT --------------------------------------------------------

function History.mousepressed(x, y)
    if not History.showHistory then return end

    local panelW = windowWidth * 0.8
    local panelH = windowHeight * 0.7
    local panelX = (windowWidth - panelW) / 2
    local panelY = (windowHeight - panelH) / 2

    -- close button
    if (x - (panelX + panelW - 30))^2 + (y - (panelY + 20))^2 <= 10*10 then
        History.showHistory = false
        return
    end

    -- drag scrollbar
    if History.scrollbar then
        if x >= History.scrollbar.x and x <= History.scrollbar.x + History.scrollbar.w and
           y >= History.scrollbar.y and y <= History.scrollbar.y + History.scrollbar.h then
            History.dragging = true
            History.dragOffset = y - History.scrollbar.y
            return
        end
    end

    -- row clicking
    if History.hoverIndex then
        History.selectedIndex = History.hoverIndex
    end
end

function love.mousereleased()
    History.dragging = false
end

function love.mousemoved(x, y, dx, dy)
    if History.showHistory and History.dragging and History.scrollbar then
        local sb = History.scrollbar
        local newY = y - History.dragOffset
        newY = clamp(newY, sb.trackY, sb.trackY + sb.trackH - sb.h)

        local ratio = (newY - sb.trackY) / (sb.trackH - sb.h)
        History.targetScrollY = ratio * History.maxScroll
    end
end

function love.wheelmoved(dx, dy)
    if History.showHistory then
        History.targetScrollY = History.targetScrollY - dy * 50
    end
end
