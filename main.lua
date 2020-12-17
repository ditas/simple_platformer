-- network test
local socket = require("socket")
local address, port = "localhost", 5555
local timeStamp
local updateRate = 0.1 -- 1/10 of sec
local client
local t
---------------

function love.load()
    require("staticClass")
    obstacles = {}

    require("dynamicClass")
    dynamic = Dynamic.new(500, 0, nil, nil, nil, nil, 10)
    dynamic2 = Dynamic.new(400, 0, nil, nil, nil, nil, 10)
    dynamic3 = Dynamic.new(300, 0, nil, nil, nil, nil, 10)
    dynamic4 = Dynamic.new(600, 0, nil, nil, nil, nil, 10)
    dynamic5 = Dynamic.new(700, 0, nil, nil, nil, nil, 10)

    obstacles = {dynamic, dynamic2, dynamic3, dynamic4, dynamic5}

    spawnObstacle(300, 300, 600, 50) -- create platform

    -- network test
    timeStamp = tostring(os.time())
    local dg = string.format("%s %d %s %s", 'init', timeStamp, 'test_match', 'test_player1')

    t = 0

    local ip = assert(socket.dns.toip(address))
    udp = socket.udp()
    udp:setsockname("*", 0) -- bind on any availible port and local(?) ip address.
    udp:settimeout(5)
    udp:sendto(dg, ip, port) 
    ---------------

    gameState = 1
end

function love.update(dt)

    if gameState == 2 then
        if love.keyboard.isDown("q") then
            player = dynamic:update(dt, obstacles, "left")
        elseif love.keyboard.isDown("e") then
            player = dynamic:update(dt, obstacles, "right")
        else
            player = dynamic:update(dt, obstacles, "none")
        end    

        dynamic2:update(dt, obstacles, "none")
        dynamic3:update(dt, obstacles, "none")
        dynamic4:update(dt, obstacles, "none")
        dynamic5:update(dt, obstacles, "none")

        for i,o in ipairs(obstacles) do
            if o.type == "static" then
                o:update(dt)
            end
        end
    end

    -- network test
    t = t + dt

    if not client then
        data, from_ip, from_port = udp:receivefrom()
        -- print(data)
        -- print(from_ip)
        -- print(from_port)

        udp:setpeername(from_ip, from_port)
        client = udp
        client:settimeout(0)

        gameState = 2
    elseif t > updateRate then
        timeStamp = tostring(os.time())
        local dg = string.format("%s %d %f %f", 'move', timeStamp, player.x, player.y)
        client:send(dg)
        t = t - updateRate
    else
        update = client:receive()
        -- print(update)
        player_update = {}
        if update then
            for w in update:gmatch("%S+") do 
                -- print(w)
                table.insert(player_update, w)
            end

            dynamic2.x = tonumber(player_update[3])
            dynamic2.y = tonumber(player_update[4])
        end
    end
    ---------------
end

function love.draw()
    dynamic:draw()
    dynamic2:draw()
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
        dynamic:throwAngle(50, 135)
        -- dynamic2:throwAngle(50, 135)
    end
    if key == "right" then
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
