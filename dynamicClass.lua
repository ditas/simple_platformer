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

    if self.action == "Right side crossed with obstacle's Bottom" 
        or self.action == "Left side crossed with obstacle's Bottom" 
    then
        self.action = "freeFall"
        self.baseSpeed = 0
    elseif self.action == "Top side crossed with obstacle's Left"
        or self.action == "Bottom side crossed with obstacle's Left"
        or self.action == "Top side crossed with obstacle's Right"
        or self.action == "Bottom side crossed with obstacle's Right"
    then
        self.action = "freeFall"
        self.baseSpeed = self.maxSpeed
    end

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
    Dynamic.detectCollision(self, obstacles)
end

function Dynamic:freeFallDelta(t)
    -- print("down V " .. self.baseSpeed)
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
    if self.action ~= "Right side crossed with obstacle's Bottom" and self.action ~= "Left side crossed with obstacle's Bottom" then
        self.baseSpeed = v
        self.action = "throwUp"
    end
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
    if self.action ~= "Right side crossed with obstacle's Bottom" 
        and self.action ~= "Left side crossed with obstacle's Bottom" 
        and self.action ~= "Top side crossed with obstacle's Left"
        and self.action ~= "Bottom side crossed with obstacle's Left"
        and self.action ~= "Top side crossed with obstacle's Right"
        and self.action ~= "Bottom side crossed with obstacle's Right"
    then
        self.fixX = self.x
        self.fixY = self.y
        -- print("FIX X: " .. self.fixX .. " FIX Y: " .. self.fixY)
        self.angle = alpha*math.pi/180
        self.baseSpeed = v
        self.action = "throwAngle"
        self.time = 0
        self.throwAngleTimeMultiplier = throwAngleTimeMultiplier or 10
    end
end

function Dynamic:detectCollision(obstacles)

    -- local left = {x1 = self.x, y1 = self.y, x2 = self.x, y2 = self.y + self.height}
    -- local right = {x1 = self.x + self.width, y1 = self.y, x2 = self.x + self.width, y2 = self.y + self.height}

    -- local top = {x1 = self.x, y1 = self.y, x2 = self.x + self.width, y2 = self.y}
    -- local bottom = {x1 = self.x, y1 = self.y + self.height, x2 = self.x + self.width, y2 = self.y + self.height}

    local left = {x1 = self.x, y1 = self.y - 5, x2 = self.x, y2 = self.y + self.height + 5}
    local right = {x1 = self.x + self.width, y1 = self.y - 5, x2 = self.x + self.width, y2 = self.y + self.height + 5}

    local top = {x1 = self.x - 5, y1 = self.y, x2 = self.x + self.width + 5, y2 = self.y}
    local bottom = {x1 = self.x - 5, y1 = self.y + self.height, x2 = self.x + self.width + 5, y2 = self.y + self.height}

    for i,o in ipairs(obstacles) do

        -- print("------------OBSTACLE " .. o.x)

        local o_left = {x1 = o.x, y1 = o.y, x2 = o.x, y2 = o.y + o.height}
        local o_right = {x1 = o.x + o.width, y1 = o.y, x2 = o.x + o.width, y2 = o.y + o.height}

        local o_top = {x1 = o.x, y1 = o.y, x2 = o.x + o.width, y2 = o.y}
        local o_bottom = {x1 = o.x, y1 = o.y + o.height, x2 = o.x + o.width, y2 = o.y + o.height}

        inter1 = checkIntersection(left, o_top)
        inter2 = checkIntersection(right, o_top)

        inter3 = checkIntersection(left, o_bottom)
        inter4 = checkIntersection(right, o_bottom)

        -- if inter1 or inter2 then
        --     self.action = "side_top"
        -- elseif inter3 or inter4 then
        --     self.action = "side_bottom"
        --     -- self.baseSpeed = 0
        -- end

        inter5 = checkIntersection(top, o_left)
        inter6 = checkIntersection(bottom, o_left)

        inter7 = checkIntersection(top, o_right)
        inter8 = checkIntersection(bottom, o_right)

        if inter1 then
            self.action = "Left side crossed with obstacle's Top"
        end
        if inter2 then
            self.action = "Right side crossed with obstacle's Top"
        end

        if inter3 then
            self.action = "Left side crossed with obstacle's Bottom"
        end
        if inter4 then
            self.action = "Right side crossed with obstacle's Bottom"
        end



        if inter5 then
            self.action = "Top side crossed with obstacle's Left"
        end
        if inter6 then
            self.action = "Bottom side crossed with obstacle's Left"
        end
        if inter7 then
            self.action = "Top side crossed with obstacle's Right"
        end
        if inter8 then
            self.action = "Bottom side crossed with obstacle's Right"
        end

        -- inter5 = checkIntersection(top, o_left)
        -- inter6 = checkIntersection(bottom, o_left)

        -- inter7 = checkIntersection(top, o_right)
        -- inter8 = checkIntersection(bottom, o_right)

        -- if inter5 or inter6 or inter7 or inter8 then
        --     self.action = "side_side"
        --     -- self.baseSpeed = 0
        -- end
    end
end

function checkIntersection(a, b)
    v1 = (b.x2-b.x1)*(a.y1-b.y1)-(b.y2-b.y1)*(a.x1-b.x1)
    v2 = (b.x2-b.x1)*(a.y2-b.y1)-(b.y2-b.y1)*(a.x2-b.x1)
    v3 = (a.x2-a.x1)*(b.y1-a.y1)-(a.y2-a.y1)*(b.x1-a.x1)
    v4 = (a.x2-a.x1)*(b.y2-a.y1)-(a.y2-a.y1)*(b.x2-a.x1)

    print("-----V1 * V2: " .. v1*v2)
    print("-----V3 * V4: " .. v3*v4)

    return (v1*v2<0) and (v3*v4<0)
end

function Dynamic:draw()
    -- print('DRAW')
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end