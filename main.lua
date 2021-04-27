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
local assetPathBG = "assets/BG/"

local fixedDT = 0.01666667
local jump = false
local jumpUpSpeed = 7
local jumpAngleSpeed = 50
local jumpLeftAngle = 120
local jumpRightAngle = 60
local animationSpeed = 0.4

local screenWidth = 1600
local screenHeight = 900
local screenFlags = {fullscreen = true} -- set fullscreen to avoid issues with pointer detached from crosshairs

-- proj test
local projs = {}
------------

local obstacles = {}
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

    --BG
    width, height = love.graphics.getDimensions()
    -- image_bg = love.graphics.newImage(assetPathBG .. "Background.png")
    image_bg_1 = love.graphics.newImage(assetPathBG .. "Layers/1.png")
    image_bg_2 = love.graphics.newImage(assetPathBG .. "Layers/2.png")
    image_bg_3 = love.graphics.newImage(assetPathBG .. "Layers/3.png")
    image_bg_4 = love.graphics.newImage(assetPathBG .. "Layers/4.png")
    image_bg_5 = love.graphics.newImage(assetPathBG .. "Layers/5.png")
    image_bg_6 = love.graphics.newImage(assetPathBG .. "Layers/6.png")
    image_bg_7 = love.graphics.newImage(assetPathBG .. "Layers/7.png")
    ----

    require("playerNetworkClass")
    require("staticClass")

    tilemap0 = {
    --     {4,5,5,5,5,5,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    --     {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    --     {0,0,1,2,2,2,2,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    --     {0,0,0,0,0,0,1,2,2,2,2,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    --     {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    --     {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    --     {0,0,0,0,0,0,1,2,2,2,2,2,2,2,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    --     {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    --     {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    --     {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    --     {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    --     {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,0,0,0,0,0,0,0,0},
    --     {0,0,0,0,0,0,0,0,0,0,0,0,1,2,2,2,2,2,2,2,2,2,2,3,0,0,0,0,0,0,0,0}
    }

    tilemap = {
        {4,5,5,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
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
        -- {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,1,2,2,2,2,2,2,2,2,2,2,3,0,0,0,0,0,0,0,0}
    }
    image_platform_left = love.graphics.newImage(assetPathTiles .. "Tileset/platform_brick.png")
    image_platform = love.graphics.newImage(assetPathTiles .. "Tileset/platform_complex.png")
    image_platform_right = love.graphics.newImage(assetPathTiles .."Tileset/platform_brick.png")

    image_platform2_left = love.graphics.newImage(assetPathTiles .. "Tileset/platform2_corner.png")
    image_platform2 = love.graphics.newImage(assetPathTiles .. "Tileset/platform2.png")
    image_platform2_right = love.graphics.newImage(assetPathTiles .."Tileset/platform2_corner.png")

    image_bg_tube1 = love.graphics.newImage(assetPathTiles .."Tileset/bg_tube1.png")
    -- image_bg_tube1 = love.graphics.newImage(assetPathTiles .."Tileset/CavePlatforms.png")
    spawnTiles(tilemap0)
    spawnTiles(tilemap)
    spawnObject(50, 50, 200, 50, true)

    spawnObject(150, 150, 300, 50, true)
        spawnObject(350, 200, 300, 50, true)

        spawnObject(350, 350, 450, 50, true)

                spawnObject(650, 650, 600, 50, true)

    -- require("playerNetworkClass")
    -- TODO: spawn players in loop (I need number of players for match + players ids, probably I should get them from server)
    dynamic = Player:new(id, 1000, 0, nil, 96, 96, nil, 10)
    dynamic:setScale(3)
    dynamic:setDeathZone({-1000, -2000, 2000, 2000})
    dynamic2 = Player:new(opponentId, 1050, 0, nil, 32, 32, nil, 10)
    dynamic2:setDeathZone({-1000, -2000, 2000, 2000})

    -- TODO: spawn dynamics in loop
    dynamic3 = Animation:new(3, 350, 0, nil, 50, 50, nil, 10)
    -- dynamic3:setIsMovable(true)
    dynamic3:setScale(2.174)
    dynamic3:setDeathZone({-1000, -2000, 2000, 2000})
    dynamic4 = Animation:new(4, 600, 0, nil, 50, 50, nil, 10)
    dynamic4:setIsMovable(true)
    dynamic4:setScale(3.333)
    dynamic4:setDeathZone({-1000, -2000, 2000, 2000})
    dynamic5 = Animation:new(5, 700, 0, nil, 50, 50, nil, 10)
    dynamic5:setIsMovable(true)
    dynamic5:setScale(3.333)
    dynamic5:setDeathZone({-1000, -2000, 2000, 2000})

    -- require("staticClass")
    -- obstacles = {}

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

    imgBoxStatic = love.graphics.newImage(assetPathBoxes .. "box_static.png")
    dynamic3:addStatic(imgBoxStatic, 32, 24)
    dynamic3:setAnimation(1)

    imgBoxDynamic = love.graphics.newImage(assetPathBoxes .. "box_dynamic.png")
    dynamic4:addStatic(imgBoxDynamic, 32, 24)
    dynamic4:setAnimation(1)
    dynamic5:addStatic(imgBoxDynamic, 32, 24)
    dynamic5:setAnimation(1)
    -----------------

    obstacles_dynamics = {
        dynamic,
        dynamic2,
        dynamic3,
        dynamic4,
        dynamic5
    }

    sceneObjects_dynamics = {
        dynamic,
        dynamic2,
        dynamic3,
        dynamic4,
        dynamic5
    }

    for i,v in ipairs(obstacles_dynamics) do
        table.insert(obstacles, v)
    end
    for i,v in ipairs(sceneObjects_dynamics) do
        table.insert(sceneObjects, v)
    end

    -- use tiles
    -- tilemap = {
    --     {4,5,5,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    --     {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    --     {0,0,1,2,2,2,2,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    --     {0,0,0,0,0,0,1,2,2,2,2,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    --     {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    --     {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    --     {0,0,0,0,0,0,1,2,2,2,2,2,2,2,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    --     {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    --     {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    --     {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    --     {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    --     {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,0,0,0,0,0,0,0,0},
    --     {0,0,0,0,0,0,0,0,0,0,0,0,1,2,2,2,2,2,2,2,2,2,2,3,0,0,0,0,0,0,0,0}
    -- }

    -- image_platform_left = love.graphics.newImage(assetPathTiles .. "Tileset/platform_brick.png")
    -- image_platform = love.graphics.newImage(assetPathTiles .. "Tileset/platform_complex.png")
    -- image_platform_right = love.graphics.newImage(assetPathTiles .."Tileset/platform_brick.png")
    --
    -- image_platform2_left = love.graphics.newImage(assetPathTiles .. "Tileset/platform2_corner.png")
    -- image_platform2 = love.graphics.newImage(assetPathTiles .. "Tileset/platform2.png")
    -- image_platform2_right = love.graphics.newImage(assetPathTiles .."Tileset/platform2_corner.png")
    --
    -- image_bg_tube1 = love.graphics.newImage(assetPathTiles .."Tileset/bg_tube1.png")
    ------------

    -- create platforms -- TODO: spawn in loop
    -- spawnTiles(tilemap)
    -- spawnObject(50, 50, 200, 50, true)
    --
    -- spawnObject(150, 150, 300, 50, true)
    --     spawnObject(350, 200, 300, 50, true)
    --
    --     spawnObject(350, 350, 450, 50, true)
    --
    --             spawnObject(650, 650, 600, 50, true)

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
    -- BG
    -- local w = image_bg:getWidth()
    -- local h = image_bg:getHeight()
    -- local scaleX = width / w
    -- local scaleY = height / h
    -- love.graphics.draw(image_bg, 0, 0, 0, scaleX, scaleY)
    local w7 = image_bg_7:getWidth()
    local h7 = image_bg_7:getHeight()
    local scaleX7 = width / w7
    local scaleY7 = height / h7
    love.graphics.draw(image_bg_7, 0, 0, 0, scaleX7, scaleY7)

    local w6 = image_bg_6:getWidth()
    local h6 = image_bg_6:getHeight()
    local scaleX6 = width / w6
    local scaleY6 = height / h6
    love.graphics.draw(image_bg_6, 0, 0, 0, scaleX6, scaleY6)

    local w5 = image_bg_5:getWidth()
    local h5 = image_bg_5:getHeight()
    local scaleX5 = width / w5
    local scaleY5 = height / h5
    love.graphics.draw(image_bg_5, 0, 0, 0, scaleX5, scaleY5)

    local w4 = image_bg_4:getWidth()
    local h4 = image_bg_4:getHeight()
    local scaleX4 = width / w4
    local scaleY4 = height / h4
    love.graphics.draw(image_bg_4, dynamic.x/100-100, dynamic.y/100+100, 0, scaleX4*1.1, scaleY4*1.1)
    -----

    -- follow player test
    love.graphics.push()
    love.graphics.translate(-dynamic.x+(screenWidth/2), -dynamic.y+(screenHeight/2))
        -- draw map here

        -- BG
        -- local w4 = image_bg_4:getWidth()
        -- local h4 = image_bg_4:getHeight()
        -- local scaleX4 = width / w4
        -- local scaleY4 = height / h4
        -- love.graphics.draw(image_bg_4, screenWidth/2, screenHeight/2, 0, scaleX4, scaleY4)
        -----

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

function spawnObject(x, y, width, height, isCollisionEnabled, image, rotation, scaleX, scaleY, A, B)
    static = Static.new(x, y, nil, width, height, image, rotation, scaleX, scaleY, A, B)
    if isCollisionEnabled then
        table.insert(obstacles, static)
    end
    table.insert(sceneObjects, static)
end

function spawnTiles(tilemap)
    for i=1, #tilemap do
        for k=1, #tilemap[i] do
            if tilemap[i][k] == 1 then
                spawnObject(k*50, i*50, 50, 50, false, image_platform_left, 0, 1)
            elseif tilemap[i][k] == 2 then
                spawnObject(k*50, i*50, 50, 50, false, image_platform, 0, 3.125)
            elseif tilemap[i][k] == 3 then
                spawnObject(k*50, i*50, 50, 50, false, image_platform_right, 0, 1)

            elseif tilemap[i][k] == 4 then
                spawnObject(k*50, i*50, 50, 50, false, image_platform2_left, 0, 3.333)
            elseif tilemap[i][k] == 5 then
                spawnObject(k*50, i*50, 50, 50, false, image_platform2, 0, 3.333)
            elseif tilemap[i][k] == 6 then
                spawnObject(k*50, i*50, 50, 50, false, image_platform2_right, 0, 3.333)

            elseif tilemap[i][k] == 7 then
                spawnObject(k*50, i*50, 189, 222, false, image_bg_tube1, 0, 3, nil, 32, 57)
                -- spawnObject(k*50, i*50, 150, 150, false, image_bg_tube1, 0, 3, nil, 25, 0)

            -- BG
            elseif tilemap[i][k] == 8 then
                spawnObject(k*50, i*50, 50, 50, false, image_platform2_right, 0, 3.333)
            -----


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
