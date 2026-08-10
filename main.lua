local utf8 = require("utf8")
local WIDTH
local HEIGHT
local monofont
local textsize_s36, textsize_s24
local gamestate
local text_title = "BUCKSHOT ROULETTE"
local text_name = "Enter your name: "
local text_button = "ENTER"
local text_title_w
local text_name_w
local text_enter_w, text_enter_h
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
        x= math.floor(width*9/10),
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
    UI.table = {
        x = math.floor(width*1/6),
        y = math.floor(height*1/2),
        w = math.floor(width*2/3),
        h = math.floor(height*1/6)
    }
    UI.dealer = {
        x = math.floor(width*1/2),
        y = math.floor(height*1/3),
        radius = 50
    }
end

local function start_newgame()
    player = {hp = 6, shotgun = {}, dmg = 1, inv = {}, name = ""}
    dealer = {hp = 6, shotgun = {}, dmg = 1, inv = {}}
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
    UI.update(WIDTH, HEIGHT)
    love.keyboard.setKeyRepeat(true)
    start_newgame()
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
        end

    elseif gamestate == "gameover" then
        -- gameover
    end
end

function love.draw()
    love.graphics.push("all")
    if gamestate == "menu" then
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

    elseif gamestate == "game" then
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
        -- dealer hp
        love.graphics.rectangle(UI.dealerHP.mode, UI.dealerHP.x, UI.dealerHP.y, UI.dealerHP.w, UI.dealerHP.h)
        -- table
        love.graphics.rectangle("line", UI.table.x, UI.table.y, UI.table.w, UI.table.h)
        -- dealer 
        love.graphics.circle("line", UI.dealer.x, UI.dealer.y, UI.dealer.radius)
    elseif gamestate == "gameover" then
        if check_wincondition() == "player" then
            love.graphics.print("YOU WON!", 320, 200)
        elseif check_wincondition() == "dealer" then
            love.graphics.print("YOU LOST!", 320, 200)
        end
        
        love.graphics.print("Press 'R' to Play Again", 280, 280)
        love.graphics.print("Press 'M' for Main Menu", 280, 310)
    end
    love.graphics.pop()
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