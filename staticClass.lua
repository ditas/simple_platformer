Static = {}
Static.__index = Static

function Static.new(x, y, shape, width, height)
    local o = {}
    o.x = x or 0
    o.y = y or 0
    o.shape = shape or "rectangle"
    o.width = width or 50
    o.height = height or 300
    setmetatable(o, Static)
    return o
end

function Static:update(dt)
    self.x = self.x
    self.y = self.y
end

function Static:draw()
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end