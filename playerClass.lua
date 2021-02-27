require("animationDynamicClass")

Player = Animation:new()

function Player:new(id, x, y, shape, width, height, baseSpeed, maxSpeed, angle, action, obstacless)
    local o = Animation:new(id, x, y, shape, width, height, baseSpeed, maxSpeed, angle, action, obstacles)
    setmetatable(o, self)
    self.__index = self
    return o
end

function Player:test()
    print("test")
end
