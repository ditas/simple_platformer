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
end

function love.update(dt)

    if love.keyboard.isDown("q") then
        dynamic:update(dt, obstacles, "left")
    elseif love.keyboard.isDown("e") then
        dynamic:update(dt, obstacles, "right")
    else
        dynamic:update(dt, obstacles, "none")
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
    if key == "s" then
        spawnObstacle(300, 300, 600, 50)
    end
end

function spawnObstacle(x, y, width, height)
    obstacle = Static.new(x, y, nil, width, height)
    table.insert(obstacles, obstacle)
end
