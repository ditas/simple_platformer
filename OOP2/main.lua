-- require 'monster'

-- m = monster.new('Katla')
-- m:shout()

-- m2 = monster.new('Test')
-- m2:shout()

function love.load()
    require("monster")
    m = monster.new('Vasya', 300, 300)
    m2 = monster.new('Petya', 0, 0)
end

function love.update(dt)
    m:update(dt)
    m2:update(dt)
end

function love.draw()
    m:draw()
    m2:draw()
end