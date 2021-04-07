-- TODO:
--      handle id over network
-- handle ALL dynamics updates over network (to avoid the case when it's has slightly different positions probably because of some minor coordinate difference)
--      handle isJump over network (do I need this?)
--      handle projectiles over network
--      remove projectiles from over the screen size
--      screen to follow up player
--      detect projectiles collisions
-- animation for boxes
-- use sprites table for all images
-- class animationStatic
-- handle obstacles, sceneObjects, etc in minimum number of loops
-- handle projectiles via player class
-- handle window movement (???)
-- add gun to player -> point gun to the mouse (???)
-- TODO: the pushing issue fix creates another issue, when I can't get through the line between 2 dynamics (well, I can jump over it)

-- network test
-- local address, port = "23.97.134.178", 5555
local address, port = "127.0.0.1", 5555
---------------

local assets = "assets/"
local assetPathPlayers = "assets/Players/"
local assetPathBoxes = "assets/Boxes/"
local assetPathTiles = "assets/Tiles/"

local fixedDT = 0.01666667
local jump = false
local jumpUpSpeed = 7
local jumpAngleSpeed = 50
local jumpLeftAngle = 120
local jumpRightAngle = 60
local animationSpeed = 0.4

local screenWidth = 1600
local screenHeight = 900
local screenFlags = {fullscreen = false} -- set fullscreen to avoid issues with pointer detached from crosshairs

-- proj test
local projs = {}
------------

local sceneObjects = {}

-- config for Players
local id = "player1"
local opponentId = "player2"

local players = {}
players[id] = {}
players[id]["x"] = 1000
players[id]["y"] = 0
players[id]["width"] = 32
players[id]["height"] = 32
players[id]["baseSpeed"] = 10

players[opponentId] = {}
players[opponentId]["x"] = 1000
players[opponentId]["y"] = 0
players[opponentId]["width"] = 32
players[opponentId]["height"] = 32
players[opponentId]["maxSpeed"] = 10
---------------------

-- config for dynamics
local dynamics = {}
dynamics[3] = {}
dynamics[3]["x"] = 300
dynamics[3]["y"] = 0
dynamics[3]["width"] = 64
dynamics[3]["height"] = 48
dynamics[3]["maxSpeed"] = 10
dynamics[3]["scale"] = 2

dynamics[4] = {}
dynamics[4]["x"] = 600
dynamics[4]["y"] = 0
dynamics[4]["width"] = 64
dynamics[4]["height"] = 48
dynamics[4]["maxSpeed"] = 10
dynamics[4]["isMovable"] = true
dynamics[4]["scale"] = 2

dynamics[5] = {}
dynamics[5]["x"] = 700
dynamics[5]["y"] = 0
dynamics[5]["width"] = 64
dynamics[5]["height"] = 48
dynamics[5]["maxSpeed"] = 10
dynamics[5]["isMovable"] = true
dynamics[5]["scale"] = 2
----------------------

function love.load()

    love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setMode(screenWidth, screenHeight, screenFlags)

    require("playerNetworkClass")
    -- TODO: spawn players in loop (I need number of players for match + players ids, probably I should get them from server)
    dynamic = Player:new(id, 1000, 0, nil, 32, 32, nil, 10)
    dynamic:setDeathZone({-1000, -2000, 2000, 2000})
    dynamic2 = Player:new(opponentId, 1050, 0, nil, 32, 32, nil, 10)
    dynamic2:setDeathZone({-1000, -2000, 2000, 2000})

    -- TODO: spawn dynamics in loop
    dynamic3 = Animation:new(3, 300, 0, nil, 64, 48, nil, 10)
    dynamic3:setScale(2)
    dynamic3:setDeathZone({-1000, -2000, 2000, 2000})
    dynamic4 = Animation:new(4, 600, 0, nil, 64, 48, nil, 10)
    dynamic4:setIsMovable(true)
    dynamic4:setScale(2)
    dynamic4:setDeathZone({-1000, -2000, 2000, 2000})
    dynamic5 = Animation:new(5, 700, 0, nil, 64, 48, nil, 10)
    dynamic5:setIsMovable(true)
    dynamic5:setScale(2)
    dynamic5:setDeathZone({-1000, -2000, 2000, 2000})

    require("staticClass")
    obstacles = {}

    -- animation test -- TODO: load graphics in loop for the number of players availible
    -- player 1
    imgRight1 = love.graphics.newImage(assetPathPlayers .. "Pink_Monster_Run_6_right.png")
    imgLeft1 = love.graphics.newImage(assetPathPlayers .. "Pink_Monster_Run_6_left.png")
    imgDeath1 = love.graphics.newImage(assetPathPlayers .. "Pink_Monster_Death_8.png")
    -- player 2
    imgRight2 = love.graphics.newImage(assetPathPlayers .. "Dude_Monster_Run_6_right.png")
    imgLeft2 = love.graphics.newImage(assetPathPlayers .. "Dude_Monster_Run_6_left.png")
    imgDeath2 = love.graphics.newImage(assetPathPlayers .. "Dude_Monster_Death_8.png")

    dynamic:addAnimation(imgRight1, 32, 32, animationSpeed)
    dynamic:addAnimation(imgLeft1, 32, 32, animationSpeed)
    dynamic:addAnimation(imgDeath1, 32, 32, animationSpeed)
    dynamic:setAnimation(1)

    dynamic2:addAnimation(imgRight2, 32, 32, animationSpeed)
    dynamic2:addAnimation(imgLeft2, 32, 32, animationSpeed)
    dynamic2:addAnimation(imgDeath2, 32, 32, animationSpeed)
    dynamic2:setAnimation(1)

    imgBoxStatic = love.graphics.newImage(assetPathBoxes .. "1_static_cropped.png")
    dynamic3:addStatic(imgBoxStatic, 32, 24)
    dynamic3:setAnimation(1)

    imgBoxDynamic = love.graphics.newImage(assetPathBoxes .. "2_dynamic_cropped.png")
    dynamic4:addStatic(imgBoxDynamic, 32, 24)
    dynamic4:setAnimation(1)
    dynamic5:addStatic(imgBoxDynamic, 32, 24)
    dynamic5:setAnimation(1)
    -----------------

    obstacles = {
        dynamic,
        dynamic2,
        dynamic3,
        dynamic4,
        dynamic5
    }

    sceneObjects = {
        dynamic,
        dynamic2,
        dynamic3,
        dynamic4,
        dynamic5
    }

    -- use tiles
    tilemap = {
        {1,2,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,1,2,2,2,2,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,1,2,2,2,2,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,1,2,2,2,2,2,2,2,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,1,2,2,2,2,2,2,2,2,2,2,3,0,0,0,0,0,0,0,0}
    }

    image_platform_left = love.graphics.newImage(assetPathTiles .. "Tileset/TileSet_01.png")
    image_platform_middle = love.graphics.newImage(assetPathTiles .. "Tileset/TileSet_02.png")
    image_platform_right = love.graphics.newImage(assetPathTiles .."Tileset/TileSet_03.png")
    ------------

    -- create platforms -- TODO: spawn in loop
    spawnTiles(tilemap)
    spawnObject(50, 50, 150, 50, true)

    spawnObject(150, 150, 300, 50, true)
        spawnObject(350, 200, 300, 50, true)

        spawnObject(350, 350, 450, 50, true)

                spawnObject(650, 650, 600, 50, true)

    -- spawnObject(0, 1000, 5000, 50, true)
    -------------------

    -- network test
    dynamic:connect(address, port)
    ---------------

    sprites = {}
    sprites.crosshairs = love.graphics.newImage(assets .. "crosshairs.png")
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

            for i,o in ipairs(obstacles) do
                -- print(o.type)
                if o.type == "player" and o.id ~= id then
                    o:update(dt, obstacles)
                    shootNetworkProj(o)
                elseif o.type == "dynamic" then
                    o:update(dt, obstacles)
                elseif o.type == "static" then
                    o:update(dt)
                end
            end

        end

    end

    -- network test
    local opponents = {}
    opponents[dynamic2.id] = dynamic2
    dynamic:updateOpponents(opponents)
    gameState = dynamic:networkUpdate(dt)
    ---------------

    jump = false

    -- proj test
    -- print(#projs)

    for i,p in ipairs(projs) do
        p.x = p.x + math.cos(p.direction) * p.speed * dt
        p.y = p.y + math.sin(p.direction) * p.speed * dt
    end
    for i=#projs, 1, -1 do
        local p = projs[i]
        if p.x > love.graphics.getWidth() + screenWidth/2 or p.x < 0 - screenWidth/2 or p.y > love.graphics.getHeight() + screenHeight/2 or p.y < 0 - screenHeight/2 or p.isDead == true then
            table.remove(projs, i)
        end
    end

    for i,o in ipairs(obstacles) do
        for n,p in ipairs(projs) do
            if isCollided(o, p) then
                p.isDead = true
            end
        end
    end
    for i=#obstacles, 1, -1 do
        local o = obstacles[i]
        if o.isDead == true then
            table.remove(obstacles, i)
        end
    end

    for i=#sceneObjects, 1, -1 do
        local o = sceneObjects[i]
        if o.isDead == true then
            table.remove(sceneObjects, i)
        end
    end
    ------------
end

function love.draw()

    -- follow player test
    love.graphics.push()
    love.graphics.translate(-dynamic.x+(screenWidth/2), -dynamic.y+(screenHeight/2))
        -- draw map here

        for i,o in ipairs(sceneObjects) do
            if o.type == "player" then
                o:draw(true)
            else
                o:draw()
            end
        end

        love.graphics.draw(sprites.crosshairs, love.mouse.getX()-20, love.mouse.getY()-20)

        for i,p in ipairs(projs) do
            love.graphics.circle("fill", p.x, p.y, p.radius)
        end
        ------------

    love.graphics.pop()
    -- draw gui here

    love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
    love.graphics.print("Player's X: "..tostring(dynamic.x).. " Y: "..tostring(dynamic.y), 10, 30)

end

function love.keypressed(key)
    if key == "space" then
        jump = true
    end
end

function spawnObject(x, y, width, height, isCollisionEnabled, image)
    static = Static.new(x, y, nil, width, height, image)
    if isCollisionEnabled then
        table.insert(obstacles, static)
    end
    table.insert(sceneObjects, static)
end

function spawnTiles(tilemap)
    for i=1, #tilemap do
        for k=1, #tilemap[i] do
            if tilemap[i][k] == 1 then
                spawnObject(k*50, i*50, 50, 50, false, image_platform_left)
            elseif tilemap[i][k] == 2 then
                spawnObject(k*50, i*50, 50, 50, false, image_platform_middle)
            elseif tilemap[i][k] == 3 then
                spawnObject(k*50, i*50, 50, 50, false, image_platform_right)
            end
        end
    end
end

-- proj test
function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 and gameState == 2 then
        shootProj(dynamic)
    end
end

function shootProj(player)
    local proj = {}

    proj.x = player.x + player.width/2
    proj.y = player.y + player.height/2
    proj.radius = 3

    proj.speed = 300
    proj.direction = playerMouseAngle(player)
    proj.isDead = false

    proj.source = player.id

    player:storeProj(proj.direction, proj.x, proj.y)

    table.insert(projs, proj)
end

function shootNetworkProj(player)
    -- print(player.shoot)

    if player.shoot then
        local proj = {}

        proj.x = player.projStartCoords[1]
        proj.y = player.projStartCoords[2]
        proj.radius = 3

        proj.speed = 300
        proj.direction = player.projAngle
        proj.isDead = false

        proj.source = player.id

        table.insert(projs, proj)
    end
    player.shoot = false

    -- print(player.shoot)
end

function playerMouseAngle(player)
    local x = player.x + player.width/2
    local y = player.y + player.height/2

    local mX = love.mouse.getX()
    local mY = love.mouse.getY()
    -- return math.atan2(y - love.mouse.getY(), x - love.mouse.getX()) + math.pi -- this is getting from PLAYER to MOUSE but rotated on 180 deg (Pi)
    return math.atan2(mY - y, mX - x) -- this is without additional rotation
end

function isCollided(o, p)
    local pCenterX = p.x + p.radius/2
    local pCenterY = p.y + p.radius/2
    local res = false
    if o.id ~= p.source then
        res = pCenterX < o.x + o.width and
            pCenterX > o.x and
            pCenterY < o.y + o.height and
            pCenterY > o.y
        if res and (o.type == "dynamic" or o.type == "player") then
            o:handleProj()
        end
    else
        res = false
    end
    return res
end
------------
