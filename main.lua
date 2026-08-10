local utf8 = require("utf8")
local WIDTH
local HEIGHT
local monofont
local textsize_s36, textsize_s24
local gamestate
local text_title = "BUCKSHOT ROULETTE"
local text_name = "Enter your name: "
local text_button = "ENTER"
local text_turn = "YOUR TURN"
local text_title_w
local text_name_w
local text_enter_w, text_enter_h
local text_turn_w

local INITIAL_HP = 6
local player, dealer
local item_pool = {'painkiller','soda','glass','cuff','saw'}
local player_turn, dealer_turn
local UI = {}
function UI.update(width,height)
    UI.title = {
        x = math.floor((width-text_title_w)/2),
        y = math.floor(height*1/3)
    }
    UI.name = {
        x = math.floor(width/4),
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
        text_x =  math.floor((width-text_enter_w)/2),
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
        y = math.floor(height*1/3*2/3) + (INITIAL_HP - player.hp) * (math.floor(height*1/3)/6),
        w = 50,
        h = math.floor(height*1/3)/6 * player.hp
    }
    UI.dealerHPbar = {
        mode = "fill",
        x = math.floor(width*1/10-50),
        y = math.floor(height*1/3*2/3) + (INITIAL_HP - dealer.hp) * (math.floor(height*1/3)/6),
        w = 50,
        h = math.floor(height*1/3)/6 * dealer.hp
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
        w = (UI.shotgun.w-2 * UI.shotgun.x_offset - (#player.shotgun-1)*UI.shotgun.padding)/#player.shotgun,
        h = UI.shotgun.h - (2 * UI.shotgun.y_offset)
    }
    UI.turn = {
        x = math.floor((width-text_turn_w)/2),
        y = 50
    }
end

local function start_newgame()
    player = {hp = 3, shotgun = {}, dmg = 1, inv = {}, name = ""}
    dealer = {hp = INITIAL_HP, shotgun = {}, dmg = 1, inv = {}}
    player_turn = true
    dealer_turn = false
end
local function restock_inventory()
    table.insert(player.inv, item_pool[math.random(1, #item_pool)])
    table.insert(dealer.inv, item_pool[math.random(1, #item_pool)])
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
local function updateTurn(text)
    text_turn = text
    text_turn_w = textsize_s36:getWidth(text_turn)
    WIDTH = love.graphics.getWidth()
    UI.turn.x = math.floor((WIDTH-text_turn_w)/2)
end
function love.load()
    WIDTH = love.graphics.getWidth()
    HEIGHT = love.graphics.getHeight()
    monofont = love.graphics.newFont("RobotoMono.ttf", 18)
    love.graphics.setFont(monofont)
    love.graphics.setBackgroundColor(0.05,0.05,0.05)
    love.graphics.setColor(1,1,1)
    love.graphics.setLineWidth(2)
    love.graphics.setLineStyle("rough")
    gamestate = "menu"
    textsize_s24 = love.graphics.newFont(24)
    textsize_s36 = love.graphics.newFont(36)
    text_title_w = textsize_s36:getWidth(text_title)
    text_name_w = textsize_s24:getWidth(text_name)
    text_enter_w = textsize_s24:getWidth(text_button)
    text_enter_h = textsize_s24:getHeight(text_button)
    text_turn_w = textsize_s36:getWidth(text_turn)
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
            if text_turn == "DEALER'S TURN" then
                updateTurn("YOUR TURN")
                
            end

        elseif dealer_turn then
            -- dealer turn
            if text_turn == "YOUR TURN" then
                updateTurn("DEALER'S TURN")
            end
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
        love.graphics.print(text_title, UI.title.x, UI.title.y)
        -- Enter your name: 
        love.graphics.setFont(textsize_s24)
        love.graphics.print(text_name, UI.name.x, UI.name.y)
        -- Name space
        love.graphics.printf(player.name, UI.playerName.x, UI.playerName.y, UI.playerName.w)
        -- ENTER button
        love.graphics.setColor(0.2,0.2,0.2)
        love.graphics.rectangle("fill", UI.button.x, UI.button.y, UI.button.w, UI.button.h)
        love.graphics.setColor(1,1,1)
        love.graphics.print(text_button, UI.button.text_x, UI.button.text_y)
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
        -- dealer 
        love.graphics.setColor(1,0,0,0.7)
        love.graphics.setLineWidth(6)
        love.graphics.setLineStyle("smooth")
        love.graphics.circle(UI.dealer.mode, UI.dealer.x, UI.dealer.y, UI.dealer.radius)
        love.graphics.setLineWidth(2)
        love.graphics.setLineStyle("rough")

        -- shotgun
        love.graphics.setColor(1,1,1,1)
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
        love.graphics.print((player_turn) and "YOUR TURN" or "DEALER'S TURN", UI.turn.x, UI.turn.y)
        love.graphics.pop()
    elseif gamestate == "gameover" then
        love.graphics.push("all")
        if check_wincondition() == "player" then
            love.graphics.print("YOU WON!", 320, 200)
        elseif check_wincondition() == "dealer" then
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
            end
        end
    elseif gamestate == "game" then
        if button_no == 1 then
            
        end
    end
end
function love.resize(w, h)
    --  Measure the exact pixel width o
    text_title_w = textsize_s36:getWidth(text_title)
    text_name_w = textsize_s24:getWidth(text_name)
    text_enter_w = textsize_s24:getWidth(text_button)
    text_enter_h = textsize_s24:getHeight(text_button)
    UI.update(w, h)
end