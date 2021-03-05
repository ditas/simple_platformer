-- network test
local address, port = "127.0.0.1", 5555
---------------

function love.load()
    local screenWidth = 1600
    local screenHeight = 900
    local screenFlags = {}
    love.window.setMode(screenWidth, screenHeight, screenFlags)

    require("playerNetworkClass")
    dynamic = Player:new("player1", 1000, 0, nil, 32, 32, nil, 10)
    dynamic2 = Player:new("player2", 1050, 0, nil, 32, 32, nil, 10)

    dynamic3 = Dynamic:new(3, 300, 0, nil, nil, nil, nil, 10)
    dynamic4 = Dynamic:new(4, 600, 0, nil, nil, nil, nil, 10)
    dynamic5 = Dynamic:new(5, 700, 0, nil, nil, nil, nil, 10)

    require("staticClass")
    obstacles = {}

    -- animation test
    -- player 1
    img_right1 = love.graphics.newImage("Pink_Monster_Run_6_right.png")
    img_left1 = love.graphics.newImage("Pink_Monster_Run_6_left.png")
    -- player 2
    img_right2 = love.graphics.newImage("Dude_Monster_Run_6_right.png")
    img_left2 = love.graphics.newImage("Dude_Monster_Run_6_left.png")

    dynamic:addAnimation(img_right1, 32, 32, 0.5)
    dynamic:addAnimation(img_left1, 32, 32, 0.5)
    dynamic:setAnimation(1)

    dynamic2:addAnimation(img_right2, 32, 32, 0.5)
    dynamic2:addAnimation(img_left2, 32, 32, 0.5)
    dynamic2:setAnimation(1)
    -----------------

    obstacles = {
        dynamic,
        dynamic2,
        dynamic3,
        dynamic4,
        dynamic5
    }

    -- create platforms
    spawnObstacle(150, 150, 300, 30)
    spawnObstacle(350, 350, 450, 30)
    spawnObstacle(650, 650, 600, 30)

    -- network test
    dynamic:connect(address, port)
    ---------------

    gameState = 1
end

dtotal = 0
function love.update(dt)
    dtotal = dtotal + dt

    if dtotal >= 0.01666 then
        dtotal = dtotal - 0.01666
        dt = 0.01666

        if gameState == 2 then
            if love.keyboard.isDown("q") then
                dynamic:update(dt, obstacles, "left")
            elseif love.keyboard.isDown("e") then
                dynamic:update(dt, obstacles, "right")
            else
                dynamic:update(dt, obstacles, "none") -- have to clear previous with NON nil value
            end

            dynamic2:update(dt, obstacles)
            dynamic3:update(dt, obstacles)
            dynamic4:update(dt, obstacles)
            dynamic5:update(dt, obstacles)

            for i,o in ipairs(obstacles) do
                if o.type == "static" then
                    o:update(dt)
                end
            end
        end

    end

    -- network test
    dynamic:updateOpponents({dynamic2})
    gameState = dynamic:networkUpdate(dt)
    ---------------
end

function love.draw()

    dynamic:draw(true)
    dynamic2:draw(true)
    dynamic3:draw()
    dynamic4:draw()
    dynamic5:draw()

    for i,o in ipairs(obstacles) do
        o:draw()
    end

    love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end

function love.keypressed(key)
    if key == "up" then
        dynamic:throwUp(5)
    end
    if key == "left" then
        dynamic:throwAngle(50, 135)
    end
    if key == "right" then
        dynamic:throwAngle(50, 45)
    end

    if key == "w" then
        spawnObstacle(0, 0, 300, 50)
    end
    if key == "a" then
        spawnObstacle(0, 0, 50, 300)
    end
    if key == "d" then
        spawnObstacle(300, 0, 50, 300)
    end
    -- if key == "s" then
    --     spawnObstacle(300, 300, 600, 50)
    -- end
end

function spawnObstacle(x, y, width, height)
    obstacle = Static.new(x, y, nil, width, height)
    table.insert(obstacles, obstacle)
end
