monster = {}
monster.__index = monster

-- Class methods

function monster.new(name, x, y)
    local o = {}
    o.name = name
    -- o.stats = {power = 10, agility = 10, endurance = 10, filters = {}}
    o.x = x or 0
    o.y = y or 0
    setmetatable(o, monster)
    return o
end

function monster:shout()
    print('Aaaaaaa! My name is ' .. self.name .. '!')
end

function monster:update(dt)
    deltaX = monster.deltaX(self)
    deltaY = self.deltaY()
    self.x = self.x + deltaX * dt
    self.y = self.y + deltaY * dt
end

function monster:draw()
    love.graphics.rectangle("line", self.x, self.y, 50, 50)
end

function monster:deltaX()
    return 100 + self.x
end

function monster.deltaY()
    return 50
end