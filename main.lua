local utf8 = require("utf8")
local WIDTH
local HEIGHT
local monofont
local textsize_s36, textsize_s24
local gamestate
local text_title = "BUCKSHOT ROULETTE"
local text_name = "Enter your name: "
local text_button = "ENTER"
local text_shoot_player = "SHOOT YOURSELF"
local text_shoot_dealer = "SHOOT DEALER"
local text_name_w, text_enter_h

local INITIAL_HP = 6
local MAX_SHELLS = 6
local player, dealer
local item_pool = {'cig','soda','glass','cuff','saw','sample'}
local player_turn, dealer_turn
local UI = {}
function UI.update(width,height)
    UI.title = {
        x = 0,
        y = math.floor(height*1/3)
    }
    UI.name = {
        x = 0,
        y = math.floor(height*1/2)
    }
    UI.playerName = {
        x = math.floor(width/4) + text_name_w,
        y = math.floor(height*1/2),
        w = width-(math.floor(width/4)+text_name_w)-50
    }
    UI.button = {
        x = math.floor((width-200)/2),
        y = math.floor(height*2/3),
        w = 200,
        h = 50,
        text_x =  0,
        text_y =  math.floor(height*2/3) + math.floor((50-text_enter_h)/2)
    }
    UI.bottomPanel = {
        x = 2,
        y = math.floor(height*2/3),
        w = width - 4,
        h =  math.floor(height*1/3) - 2
    }
    UI.lineDivisionOne = {
        x1 = math.floor(width*1/3),
        y1 = math.floor(height*2/3),
        x2 = math.floor(width*1/3),
        y2 = height-2
    }
    UI.lineDivisionTwo = {
        x1 = math.floor(width*2/3),
        y1 = math.floor(height*2/3),
        x2 = math.floor(width*2/3),
        y2 = height-2
    }
    UI.invLineDivisionH1 = {
        x1 = math.floor(width*2/3),
        y1 = math.floor(height*(2/3+1/9)),
        x2 = width-2,
        y2 = math.floor(height*(2/3+1/9))
        
    }
    UI.invLineDivisionH2 = {
        x1 = math.floor(width*2/3),
        y1 = math.floor(height*(2/3+2/9)),
        x2 = width-2,
        y2 = math.floor(height*(2/3+2/9))
    }
    UI.invLineDivisionV = {
        x1 = math.floor(width*(2/3+1/6)),
        y1 = math.floor(height*2/3),
        x2 = math.floor(width*(2/3+1/6)),
        y2 = height-2

    }
    UI.playerHP = {
        mode = "line",
        x = math.floor(width*9/10),
        y = math.floor(height*1/3*2/3),
        w = 50,
        h = math.floor(height*1/3)
    }
    UI.dealerHP = {
        mode = "line",
        x = math.floor(width*1/10-50),
        y = math.floor(height*1/3*2/3),
        w = 50,
        h = math.floor(height*1/3)
    }
    UI.playerHPbar = {
        mode = "fill",
        x = math.floor(width*9/10),
        y = math.floor(height*1/3*2/3) + (INITIAL_HP - player.hp) * (math.floor(height*1/3)/INITIAL_HP),
        w = 50,
        h = math.floor(height*1/3)/INITIAL_HP * player.hp
    }
    UI.dealerHPbar = {
        mode = "fill",
        x = math.floor(width*1/10-50),
        y = math.floor(height*1/3*2/3) + (INITIAL_HP - dealer.hp) * (math.floor(height*1/3)/INITIAL_HP),
        w = 50,
        h = math.floor(height*1/3)/INITIAL_HP * dealer.hp
    }
    UI.table = {
        mode = "line",
        x = math.floor(width*1/6),
        y = math.floor(height*1/2),
        w = math.floor(width*2/3),
        h = math.floor(height*1/6)
    }
    UI.dealer = {
        mode = "line",
        x = math.floor(width*1/2),
        y = math.floor(height*1/3),
        radius = 50
    }
    UI.shootplayer = {
        mode = "line",
        x = math.floor(width*(1/3+1/18)),
        y = math.floor(height*(2/3+1/36)),
        w = math.floor(width*(1/3*2/3)),
        h = math.floor(height*(1/3*1/3*1/2))
    }
    UI.shootdealer = {
        mode = "line",
        x = math.floor(width*(1/3+1/18)),
        y = math.floor(height - height*(1/3*1/3*1/2) - height*(1/36)),
        w = math.floor(width*(1/3*2/3)),
        h = math.floor(height*(1/3*1/3*1/2))
    }
    UI.shotgun = {
        x_offset = 10,
        y_offset = 10,
        padding = 5,
        mode = "line",
        x = width*(1/3+1/18),
        y = height*(2/3+1/9),
        w = width*(1/3*2/3),
        h = height*(1/3*1/3)
    }
    UI.pellets = {
        mode = "line",
        x = UI.shotgun.x + UI.shotgun.x_offset,
        y = UI.shotgun.y + UI.shotgun.y_offset,
        w = (UI.shotgun.w-2 * UI.shotgun.x_offset - (MAX_SHELLS-1)*UI.shotgun.padding)/MAX_SHELLS,
        h = UI.shotgun.h - (2 * UI.shotgun.y_offset)
    }
    UI.turn = {
        x = 0,
        y = 50
    }
    UI.playerInv = {
        mode = "line",
        x = math.floor(width*2/3),
        y = math.floor(height*2/3),
        w = math.floor(width*1/3*1/2),
        h = math.floor(height*1/3*1/3)
    }
    UI.dealerInv = {
        mode = "line",
        x = UI.table.x,
        y = UI.table.y,
        w = UI.table.w/6,
        h = UI.table.h
    }
end

local function restock_inventory()
    local rand_1 = math.random(1, #item_pool)
    local rand_2 = math.random(1, #item_pool)
    player.inv[item_pool[rand_1]] = player.inv[item_pool[rand_1]] + 1
    dealer.inv[item_pool[rand_2]] = dealer.inv[item_pool[rand_2]] + 1
end
local function check_wincondition()
    if player.hp <= 0 then
        return "dealer"
    elseif dealer.hp <= 0 then
        return "player"
    else
        return "none"
    end
end
local function shotgun_refill()
    table.insert(player.shotgun, math.random(0,1))
    table.insert(dealer.shotgun, math.random(0,1))
end
local function start_newgame()
    player = {hp = INITIAL_HP, shotgun = {}, dmg = 1, inv = {["cig"] = 0, ["soda"] = 0, ["glass"] = 0, ["cuff"] = 0, ["saw"] = 0, ["sample"] = 0}, name = ""}
    dealer = {hp = INITIAL_HP, shotgun = {}, dmg = 1, inv = {["cig"] = 0, ["soda"] = 0, ["glass"] = 0, ["cuff"] = 0, ["saw"] = 0, ["sample"] = 0}}
    player_turn = true
    dealer_turn = false
    for i = 1,2 do
        restock_inventory()
    end
    for i = 1,4 do
        shotgun_refill()
    end
end
function love.load()
    WIDTH = love.graphics.getWidth()
    HEIGHT = love.graphics.getHeight()
    monofont = love.graphics.newFont("RobotoMono.ttf", 18)
    love.graphics.setFont(monofont)
    monofont:setFilter("nearest", "nearest")
    love.graphics.setBackgroundColor(0.05,0.05,0.05)
    love.graphics.setColor(1,1,1)
    love.graphics.setLineWidth(2)
    love.graphics.setLineStyle("rough")
    gamestate = "menu"
    textsize_s24 = love.graphics.newFont(24)
    textsize_s36 = love.graphics.newFont(36)
    text_name_w = textsize_s24:getWidth(text_name)
    text_enter_h = textsize_s24:getHeight(text_button)
    love.keyboard.setKeyRepeat(true)
    start_newgame()
    UI.update(WIDTH, HEIGHT)
end
function love.textinput(t)
    if gamestate == "menu" then
        if utf8.len(player.name) < 20 then
            player.name = player.name .. t
        end
    end
end
function love.update(dt)
    if gamestate == "menu" then
        -- menu
    elseif gamestate == "game" then
        if player_turn then
            -- player turn
        elseif dealer_turn then
            -- dealer turn
        end
    elseif gamestate == "gameover" then
        -- gameover
    end
end

function love.draw()
    if gamestate == "menu" then
        love.graphics.push("all")
        -- BUCKSHOT ROULETTE
        love.graphics.setFont(textsize_s36)
        love.graphics.printf(text_title, UI.title.x, UI.title.y, WIDTH , "center")
        -- Enter your name: 
        love.graphics.setFont(textsize_s24)
        love.graphics.printf(text_name, UI.name.x, UI.name.y, WIDTH*3/4, "center")
        -- Name space
        love.graphics.printf(player.name, UI.playerName.x, UI.playerName.y, UI.playerName.w, "left")
        -- ENTER button
        love.graphics.setColor(0.2,0.2,0.2)
        love.graphics.rectangle("fill", UI.button.x, UI.button.y, UI.button.w, UI.button.h)
        love.graphics.setColor(1,1,1)
        love.graphics.printf(text_button, UI.button.text_x, UI.button.text_y, WIDTH, "center")
        love.graphics.pop()
    elseif gamestate == "game" then
        love.graphics.push("all")
        love.graphics.rectangle("line", UI.bottomPanel.x, UI.bottomPanel.y, UI.bottomPanel.w, UI.bottomPanel.h)
        -- line divisions
        love.graphics.line(UI.lineDivisionOne.x1, UI.lineDivisionOne.y1, UI.lineDivisionOne.x2 ,UI.lineDivisionOne.y2)
        love.graphics.line(UI.lineDivisionTwo.x1, UI.lineDivisionTwo.y1, UI.lineDivisionTwo.x2 ,UI.lineDivisionTwo.y2)
        -- line divisions for items
        love.graphics.line(UI.invLineDivisionH1.x1, UI.invLineDivisionH1.y1, UI.invLineDivisionH1.x2, UI.invLineDivisionH1.y2)
        love.graphics.line(UI.invLineDivisionH2.x1, UI.invLineDivisionH2.y1, UI.invLineDivisionH2.x2, UI.invLineDivisionH2.y2)
        love.graphics.line(UI.invLineDivisionV.x1, UI.invLineDivisionV.y1, UI.invLineDivisionV.x2, UI.invLineDivisionV.y2)
        -- your hp
        love.graphics.rectangle(UI.playerHP.mode, UI.playerHP.x, UI.playerHP.y, UI.playerHP.w, UI.playerHP.h)
        love.graphics.rectangle(UI.playerHPbar.mode, UI.playerHPbar.x, UI.playerHPbar.y, UI.playerHPbar.w, UI.playerHPbar.h)
        -- dealer hp
        love.graphics.setColor(1,0,0,0.7)
        love.graphics.rectangle(UI.dealerHP.mode, UI.dealerHP.x, UI.dealerHP.y, UI.dealerHP.w, UI.dealerHP.h)
        love.graphics.rectangle(UI.dealerHPbar.mode, UI.dealerHPbar.x, UI.dealerHPbar.y, UI.dealerHPbar.w, UI.dealerHPbar.h)
        -- table
        love.graphics.setColor(1,1,1,1)
        love.graphics.rectangle(UI.table.mode, UI.table.x, UI.table.y, UI.table.w, UI.table.h)
        for i = 0,5 do
            love.graphics.printf(item_pool[i+1].."\n x"..dealer.inv[item_pool[i+1]], UI.dealerInv.x + (i * UI.dealerInv.w), UI.dealerInv.y + (UI.dealerInv.h-48)/2,UI.dealerInv.w, "center")
        end
        -- dealer 
        love.graphics.setColor(1,0,0,0.7)
        love.graphics.setLineWidth(6)
        love.graphics.setLineStyle("smooth")
        love.graphics.circle(UI.dealer.mode, UI.dealer.x, UI.dealer.y, UI.dealer.radius)
        love.graphics.setLineWidth(2)
        love.graphics.setLineStyle("rough")
        love.graphics.setColor(1,1,1,1)
        -- shoot player
        love.graphics.rectangle(UI.shootplayer.mode, UI.shootplayer.x, UI.shootplayer.y, UI.shootplayer.w, UI.shootplayer.h)
        love.graphics.printf(text_shoot_player, UI.shootplayer.x, UI.shootplayer.y + (UI.shootplayer.h-24)/2, UI.shootplayer.w, "center")
        -- shoot dealer
        love.graphics.rectangle(UI.shootdealer.mode, UI.shootdealer.x, UI.shootdealer.y, UI.shootdealer.w, UI.shootdealer.h)
        love.graphics.printf(text_shoot_dealer, UI.shootdealer.x, UI.shootdealer.y + (UI.shootdealer.h-24)/2, UI.shootdealer.w, "center")
        -- shotgun
        love.graphics.rectangle(UI.shotgun.mode, UI.shotgun.x, UI.shotgun.y, UI.shotgun.w, UI.shotgun.h)
        -- pellets
        for i = 1, #player.shotgun do
            local offset = (UI.pellets.w + UI.shotgun.padding) * (i-1)
            love.graphics.rectangle(UI.pellets.mode, UI.pellets.x + offset, UI.pellets.y, UI.pellets.w, UI.pellets.h)
        end
        -- turn indicator
        love.graphics.setFont(textsize_s36)
        if player_turn then
            love.graphics.setColor(1,1,1,1)
        else
            love.graphics.setColor(1,0,0,0.7)
        end
        love.graphics.printf((player_turn) and "YOUR TURN" or "DEALER'S TURN", UI.turn.x, UI.turn.y, WIDTH, "center")
        -- render items
        love.graphics.setFont(monofont)
        love.graphics.setColor(1,1,1,1)
        for i = 0,5 do
            local rem = i % 2
            local quot = math.floor(i / 2)
            love.graphics.rectangle(UI.playerInv.mode, UI.playerInv.x + (rem * UI.playerInv.w) , UI.playerInv.y + (quot * UI.playerInv.h), UI.playerInv.w, UI.playerInv.h)
            love.graphics.printf(item_pool[i+1].." x"..player.inv[item_pool[i+1]], UI.playerInv.x + (rem * UI.playerInv.w), UI.playerInv.y + (quot * UI.playerInv.h) + (UI.playerInv.h-24)/2,UI.playerInv.w, "center")
        end
        love.graphics.pop()
    elseif gamestate == "gameover" then
        love.graphics.push("all")
        local winner = check_wincondition()
        if winner == "player" then
            love.graphics.print("YOU WON!", 320, 200)
        elseif winner == "dealer" then
            love.graphics.print("YOU LOST!", 320, 200)
        end
        love.graphics.setFont(textsize_s24)
        love.graphics.print("Press 'R' to Play Again", 280, 280)
        love.graphics.print("Press 'M' for Main Menu", 280, 310)
        love.graphics.pop()
    end
end

--backspace functionality
function love.keypressed(key)
    if gamestate == "menu" then
        if key == "return" then
            gamestate = "game"
            if player.name == "" then
                player.name = "John"
            end
        end
        if key == "backspace" then
            -- get the byte offset to the last UTF-8 character in the string.
            local byteoffset = utf8.offset(player.name, -1)
    
            if byteoffset then
                -- remove the last UTF-8 character.
                -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(player.name, 1, -2).
                player.name = string.sub(player.name, 1, byteoffset - 1)
            end
        end
    elseif gamestate == "game" then
        if key == "space" then
            player_turn = not player_turn
            dealer_turn = not dealer_turn
        end
        if key == "x" then
            gamestate = "gameover"
        end
    elseif gamestate == "gameover" then
        if key == "r" then
            start_newgame()
            gamestate = "game"
        elseif key == "m" then
            start_newgame()
            gamestate = "menu"
        end
    end
end
--enter button functionality
function love.mousepressed(x,y,button_no)
    if gamestate == "menu" then
        if button_no == 1 then
            if x >= UI.button.x and x <= UI.button.x + UI.button.w and y >= UI.button.y and y <= UI.button.y + UI.button.h then
                gamestate = "game"
                if player.name == "" then
                player.name = "John"
            end
            end
        end
    elseif gamestate == "game" then
        if button_no == 1 then
            
        end
    end
end
function love.resize(w, h)
    WIDTH = love.graphics.getWidth()
    HEIGHT = love.graphics.getHeight()
    UI.update(w, h)
end