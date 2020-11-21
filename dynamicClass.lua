g = 9.8

Dynamic = {}
Dynamic.__index = Dynamic

function Dynamic.new(x, y, shape, width, height, baseSpeed, maxSpeed, angle, action, obstacles)
    local o = {}
    o.x = x or 0
    o.y = y or 0
    o.shape = shape or "rectangle"
    o.width = width or 50
    o.height = height or 50
    o.baseSpeed = baseSpeed or 0
    o.maxSpeed = maxSpeed or 5
    o.action = action or "freeFall" -- | throwUp | throwAngle | stop
    o.obstacles = obstacles or {}

    o.angle = 0 -- in rads
    o.time = 0
    o.fixX = 0
    o.fixY = 0
    o.throwAngleTimeMultiplier = 10

    setmetatable(o, Dynamic)
    return o
end

function Dynamic:update(dt, obstacles)
    print("ACTION " .. self.action)
    self.x = self.x
    if self.action == "freeFall" then
        self:freeFallDelta(dt) -- без разницы вызывать собственный метод через self./self:
        -- print("down axis Y " .. self.y)
    elseif self.action == "throwUp" then
        Dynamic.throwUpDelta(self, dt) -- или через Dynamic.
        -- print("up axis Y " .. self.y)
        if self.baseSpeed <= 0 then
            self.action = "freeFall"
            Dynamic.freeFallDelta(self, dt) -- но при вызове через "." нужно передавать в него self
            -- print("back to down axis Y " .. self.y)
        end
    elseif self.action == "throwAngle" then
        Dynamic.throwAngleDelta(self, dt)
    end
    -- detectCollision(obstacles)
end

function Dynamic:freeFallDelta(t)
    print("down V " .. self.baseSpeed)
    if self.baseSpeed < self.maxSpeed then
        speed = self.baseSpeed + g*t
        self.y = self.y + speed
    else
        speed = self.baseSpeed
        self.y = self.y + speed
    end
    self.baseSpeed = speed
end

function Dynamic:throwUpDelta(t)
    -- print("up V " .. v)
    if self.baseSpeed > 0 then
        speed = self.baseSpeed - g*t
        self.y = self.y - speed
    end
    self.baseSpeed = speed
end

function Dynamic:throwUp(v)
    self.baseSpeed = v
    self.action = "throwUp"
end

function Dynamic:throwAngleDelta(t)
    -- print("X: " .. self.x .. " Y: " .. self.y)
    self.time = self.time + t*self.throwAngleTimeMultiplier
    -- vx = self.baseSpeed*math.cos(self.angle)
    -- vy = self.baseSpeed*math.sin(self.angle) - g*self.time
    self.x = self.fixX + self.baseSpeed*math.cos(self.angle)*self.time
    self.y = self.fixY - (self.baseSpeed*math.sin(self.angle)*self.time - (g*self.time^2)/2)
end

function Dynamic:throwAngle(v, alpha, throwAngleTimeMultiplier)
    self.fixX = self.x
    self.fixY = self.y
    -- print("FIX X: " .. self.fixX .. " FIX Y: " .. self.fixY)
    self.angle = alpha*math.pi/180
    self.baseSpeed = v
    self.action = "throwAngle"
    self.time = 0
    self.throwAngleTimeMultiplier = throwAngleTimeMultiplier or 10
end

function Dynamic:draw()
    print('DRAW')
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end

-- return Dynamic