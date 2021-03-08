-- TODO:
-- handle isJump over network
-- handle projectiles over network
-- remove projectiles from over the screen size
-- screen to follow up player
-- detect projectiles collisions
-- handle window movement (???)
-- add gun to player -> point gun to the mouse (???)
-- TODO: the pushing issue fix is creating another issue, when I can't get though the line between 2 dynamics (well, I can jump it over)

-- network test
local address, port = "127.0.0.1", 5555
---------------

local fixedDT = 0.01666667
local jump = false
local jumpUpSpeed = 7
local jumpAngleSpeed = 50
local jumpLeftAngle = 120
local jumpRightAngle = 60
local animationSpeed = 0.4

local screenWidth = 1600
local screenHeight = 900

-- proj test
local projs = {}
------------

function love.load()
    -- local screenWidth = 1600
    -- local screenHeight = 900
    local screenFlags = {}
    love.window.setMode(screenWidth, screenHeight, screenFlags)

    require("playerNetworkClass")
    dynamic = Player:new("player1", 1000, 0, nil, 32, 32, nil, 10)
    dynamic2 = Player:new("player2", 1050, 0, nil, 32, 32, nil, 10)

    dynamic3 = Dynamic:new(3, 300, 0, nil, nil, nil, nil, 10)
    dynamic4 = Dynamic:new(4, 600, 0, nil, nil, nil, nil, 10)
    dynamic4:setIsMovable(true)
    dynamic5 = Dynamic:new(5, 700, 0, nil, nil, nil, nil, 10)
    dynamic5:setIsMovable(true)

    require("staticClass")
    obstacles = {}

    -- animation test
    -- player 1
    img_right1 = love.graphics.newImage("Pink_Monster_Run_6_right.png")
    img_left1 = love.graphics.newImage("Pink_Monster_Run_6_left.png")
    -- player 2
    img_right2 = love.graphics.newImage("Dude_Monster_Run_6_right.png")
    img_left2 = love.graphics.newImage("Dude_Monster_Run_6_left.png")

    dynamic:addAnimation(img_right1, 32, 32, animationSpeed)
    dynamic:addAnimation(img_left1, 32, 32, animationSpeed)
    dynamic:setAnimation(1)

    dynamic2:addAnimation(img_right2, 32, 32, animationSpeed)
    dynamic2:addAnimation(img_left2, 32, 32, animationSpeed)
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
    spawnObstacle(150, 150, 300, 50)
        spawnObstacle(350, 200, 300, 50)

        spawnObstacle(350, 350, 450, 50)

                spawnObstacle(650, 650, 600, 50)

    -- network test
    dynamic:connect(address, port)
    ---------------

    sprites = {}
    sprites.crosshairs = love.graphics.newImage('crosshairs.png')
    love.mouse.setVisible(false)

    gameState = 1
end

dtotal = 0
function love.update(dt)
    dtotal = dtotal + dt

    if dtotal >= fixedDT then
        dtotal = dtotal - fixedDT
        dt = fixedDT

        if gameState == 2 then
            if jump then
                if love.keyboard.isDown("a") then
                    dynamic:throwAngle(jumpAngleSpeed, jumpLeftAngle)
                elseif love.keyboard.isDown("d") then
                    dynamic:throwAngle(jumpAngleSpeed, jumpRightAngle)
                else
                    dynamic:throwUp(jumpUpSpeed)
                end
            else
                if love.keyboard.isDown("a") then
                    dynamic:update(dt, obstacles, "left")
                elseif love.keyboard.isDown("d") then
                    dynamic:update(dt, obstacles, "right")
                else
                    dynamic:update(dt, obstacles, "none") -- have to clear previous with NON nil value
                end
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

    jump = false

    -- proj test
    for i,p in ipairs(projs) do
        p.x = p.x + math.cos(p.direction) * p.speed * dt
        p.y = p.y + math.sin(p.direction) * p.speed * dt
    end
    ------------
end

function love.draw()

    -- follow player test
    -- love.graphics.push()
    love.graphics.translate(-dynamic.x+(screenWidth/2), -dynamic.y+(screenHeight/2))
        -- draw map here

        dynamic:draw(true)
        dynamic2:draw(true)
        dynamic3:draw()
        dynamic4:draw()
        dynamic5:draw()
        for i,o in ipairs(obstacles) do
            o:draw()
        end

        -- -- proj test "A" (starts at right position, goes to the wrong one)
        -- for i,p in ipairs(projs) do
        --     love.graphics.circle("fill", p.x, p.y, 3)
        -- end
        -- ------------

    -- love.graphics.pop()
    -- draw gui here

    love.graphics.draw(sprites.crosshairs, love.mouse.getX()-20, love.mouse.getY()-20)

    -- proj test (starts at wrong position goes to the right one)
    for i,p in ipairs(projs) do
        love.graphics.circle("fill", p.x, p.y, 3)
    end
    ------------
    -- -- proj test -- this is the same as "A"
    -- for i,p in ipairs(projs) do
    --     love.graphics.circle("fill", p.x - dynamic.x+(screenWidth/2), p.y - dynamic.y+(screenHeight/2), 3)
    -- end
    -- ------------
    ---------------------

    love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)

end

function love.keypressed(key)
    if key == "space" then
        jump = true
    end
end

function spawnObstacle(x, y, width, height)
    obstacle = Static.new(x, y, nil, width, height)
    table.insert(obstacles, obstacle)
end

-- proj test
function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 and gameState == 2 then
        shotProj(dynamic)
    end
end

function shotProj(player)
    local proj = {}

    proj.x = player.x + player.width/2 -- - player.x+(screenWidth/2)
    proj.y = player.y + player.height/2 -- - player.y+(screenHeight/2)

    proj.speed = 300
    proj.direction = playerMouseAngle(player)
    proj.dead = false

    table.insert(projs, proj)
end

function playerMouseAngle(player)
    local x = player.x + player.width/2 -- - player.x+(screenWidth/2)
    local y = player.y + player.height/2 -- - player.x+(screenWidth/2)

    local mX = love.mouse.getX() -- + dynamic.x+(screenWidth/2)
    local mY = love.mouse.getY() -- + dynamic.y+(screenHeight/2)
    -- return math.atan2(y - love.mouse.getY(), x - love.mouse.getX()) + math.pi -- this is getting from PLAYER to MOUSE but rotated on 180 deg (Pi)
    return math.atan2(mY - y, mX - x) -- this is without additional rotation
end
------------
