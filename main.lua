function love.load()
    require("staticClass")
    obstacles = {}

    -- d = require("dynamicClass")
    -- dynamic = Dynamic:new(d, 500, 0, nil, nil, nil, nil, 10)
    -- dynamic2 = Dynamic:new(d, 100, 0, nil, nil, nil, nil, 10)
    require("dynamicClass")
    dynamic = Dynamic.new(500, 0, nil, nil, nil, nil, 10)
    dynamic2 = Dynamic.new(100, 0, nil, nil, nil, nil, 10)
end

function love.update(dt)    
    dynamic:update(dt, obstacles)
    print(dynamic.baseSpeed)

    dynamic2:update(dt, obstacles)
    print(dynamic2.baseSpeed)

    for i,o in ipairs(obstacles) do
        o:update()
    end
end

function love.draw()
    dynamic:draw()
    dynamic2:draw()

    for i,o in ipairs(obstacles) do
        o:draw()
    end
end

function love.keypressed(key)
    if key == "up" then
        dynamic:throwUp(3)
        dynamic2:throwUp(3)
    end
    if key == "left" then
        dynamic:throwAngle(50, 135)
        dynamic2:throwAngle(50, 135)
    end
    if key == "right" then
        dynamic:throwAngle(50, 45)
        dynamic2:throwAngle(50, 45)
    end

    if key == "q" then
        dynamic:throwAngle(50, 90)
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
        spawnObstacle(300, 300, 300, 50)
    end
end

function spawnObstacle(x, y, width, height)
    obstacle = Static.new(x, y, nil, width, height)
    table.insert(obstacles, obstacle)
end