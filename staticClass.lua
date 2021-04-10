Static = {}
Static.__index = Static

function Static.new(x, y, shape, width, height, image, rotation, scaleX, scaleY, A, B)
    local o = {}

    o.id = "tmp_static"
    o.type = "static"

    o.x = x or 0
    o.y = y or 0
    o.shape = shape or "rectangle"
    o.width = width or 50
    o.height = height or 300
    o.square = o.width * o.height

    o.image = image
    o.rotation = rotation or 0
    o.scale = scaleX or 1

    o.A = A
    o.B = B

    setmetatable(o, Static)
    return o
end

function Static:update(dt)
    self.x = self.x
    self.y = self.y
end

function Static:draw()
    if self.image then
        -- love.graphics.draw(self.image, self.x, self.y, 0, 1.5625)
        love.graphics.draw(self.image, self.x, self.y, self.rotation, self.scale, nil, self.A, self.B)
    else
        -- love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    end
    -- debug
    -- love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end
