-- network test
local socket = require("socket")
local address, port = "127.0.0.1", 5555
local timeStamp
local updateRate = 0.1 -- 1/10 of sec
local client
local t
---------------

function love.load()
    require("staticClass")
    obstacles = {}

    require("dynamicClass")
    dynamic = Dynamic.new("player", 500, 0, nil, 30, 18, nil, 10)
    dynamic2 = Dynamic.new(2, 400, 0, nil, 30, 18, nil, 10)
    dynamic3 = Dynamic.new(3, 300, 0, nil, nil, nil, nil, 10)
    dynamic4 = Dynamic.new(4, 600, 0, nil, nil, nil, nil, 10)
    dynamic5 = Dynamic.new(5, 700, 0, nil, nil, nil, nil, 10)

    -- animation test
    -- img_right = love.graphics.newImage("hero_right.png")
    -- anim_right = newAnimation(img_right, 16, 18, 1)
    -- img_left = love.graphics.newImage("hero_left.png")
    -- anim_left = newAnimation(img_left, 16, 18, 1)
    --
    -- img_right_2 = love.graphics.newImage("hero_right.png")
    -- anim_right_2 = newAnimation(img_right_2, 16, 18, 1)
    -- img_left_2 = love.graphics.newImage("hero_left.png")
    -- anim_left_2 = newAnimation(img_left_2, 16, 18, 1)

    img_right = love.graphics.newImage("hero_right.png")
    dynamic:addAnimation(img_right, 16, 18, 1)
    dynamic2:addAnimation(img_right, 16, 18, 1)

    img_left = love.graphics.newImage("hero_left.png")
    dynamic:addAnimation(img_left, 16, 18, 1)
    dynamic2:addAnimation(img_left, 16, 18, 1)

    dynamic:setAnimation(1)
    dynamic2:setAnimation(1)
    -----------------

    obstacles = {
        dynamic,
        dynamic2,
        dynamic3,
        dynamic4,
        dynamic5
    }

    spawnObstacle(300, 300, 600, 50) -- create platform

    -- network test
    local osString = love.system.getOS()
    print(osString)

    timeStamp = tostring(os.time())
    local dg = string.format("%s %d %s %s", 'init', timeStamp, 'test_match', 'test_player1')

    t = 0

    udp = socket.udp()
    udp:settimeout(5)
    if osString == "Linux" then
        local ip = assert(socket.dns.toip(address))
        udp:setsockname("*", 0) -- bind on any availible port and local(?) ip address.
        udp:sendto(dg, ip, port)
    else
        udp:setpeername(address, port)
        udp:send(dg)
        udp:setpeername("*")
    end
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

                -- animation test
                -- dynamic:setAnimation(anim_left)
                --
                -- anim_left.currentTime = anim_left.currentTime + dt
                -- if anim_left.currentTime >= anim_left.duration then
                --     anim_left.currentTime = anim_left.currentTime - anim_left.duration
                -- end
                --
                -- dynamic2:setAnimation(anim_left_2)
                --
                -- anim_left_2.currentTime = anim_left_2.currentTime + dt
                -- if anim_left_2.currentTime >= anim_left_2.duration then
                --     anim_left_2.currentTime = anim_left_2.currentTime - anim_left_2.duration
                -- end
                -----------------

                player = dynamic:update(dt, obstacles, "left")
            elseif love.keyboard.isDown("e") then

                -- animation test
                -- dynamic:setAnimation(anim_right)
                --
                -- anim_right.currentTime = anim_right.currentTime + dt
                -- if anim_right.currentTime >= anim_right.duration then
                --     anim_right.currentTime = anim_right.currentTime - anim_right.duration
                -- end
                --
                -- dynamic2:setAnimation(anim_right_2)
                --
                -- anim_right_2.currentTime = anim_right_2.currentTime + dt
                -- if anim_right_2.currentTime >= anim_right_2.duration then
                --     anim_right_2.currentTime = anim_right_2.currentTime - anim_right_2.duration
                -- end
                -----------------

                player = dynamic:update(dt, obstacles, "right")
            else
                player = dynamic:update(dt, obstacles, "none") -- have to clear previous with NON nil value
            end
            -- dynamic2:update(dt, obstacles, "none")
            -- dynamic3:update(dt, obstacles, "none")
            -- dynamic4:update(dt, obstacles, "none")
            -- dynamic5:update(dt, obstacles, "none")
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
    t = t + dt

    if not client then
        data, from_ip, from_port = udp:receivefrom()
        -- print(from_ip)
        -- print(from_port)

        udp:setpeername(from_ip, from_port)

        client = udp
        client:settimeout(0)

        gameState = 2
    elseif t > updateRate then
        timeStamp = tostring(os.time())
        local dg = string.format("%s %d %f %f %f %f %f %f %s %f %f %f %f %f %f %f %f %f %s", 'move', timeStamp,
            player.x,
            player.y,
            player.width,
            player.height,
            player.baseSpeed,
            player.maxSpeed,
            player.action,
            player.angle,
            player.time,
            player.fixX,
            player.fixY,
            player.throwAngleTimeMultiplier,
            player.statusL,
            player.statusT,
            player.statusR,
            player.statusB,
            player.direction
        )
        dg = dg .. platofrm_to_dg(player.platform)
        client:send(dg)
        t = t - updateRate
    else
        local update = client:receive()
        -- print(update)
        local player_update = {}
        if update then
            for w in update:gmatch("%S+") do
                -- print(w)
                table.insert(player_update, w)
            end

            dynamic2:setUpdateData(
                player_update[3],
                player_update[4],
                player_update[5],
                player_update[6],
                player_update[7],
                player_update[8],
                player_update[9],
                player_update[10],
                player_update[11],
                player_update[12],
                player_update[13],
                player_update[14],
                player_update[15],
                player_update[16],
                player_update[17],
                player_update[18],
                player_update[19],
                player_update[20],

                player_update[21],
                player_update[22],
                player_update[23],
                player_update[24]
            )
        end
    end
    ---------------
end

function platofrm_to_dg(platform)
    local string = ""
    if platform.x ~= nil and platform.y ~= nil and platform.width ~= nil and platform.height ~= nil then
        string = string .. string.format(" %f", platform.x)
        string = string .. string.format(" %f", platform.y)
        string = string .. string.format(" %f", platform.width)
        string = string .. string.format(" %f", platform.height)
    end
    print("--------------------------------------------------------------------------------STRING " .. string)
    return string
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
        -- dynamic2:throwUp(5)
    end
    if key == "left" then
        -- dynamic:setAnimation(anim_left)
        dynamic:throwAngle(50, 135)
        -- dynamic2:throwAngle(50, 135)
    end
    if key == "right" then
        -- dynamic:setAnimation(anim_right)
        dynamic:throwAngle(50, 45)
        -- dynamic2:throwAngle(50, 45)
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
