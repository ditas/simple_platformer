g = 10
tick = 1/60
acc = 0

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

    o.statusL = 0
    o.statusT = 0
    o.statusR = 0
    o.statusB = 0

    setmetatable(o, Dynamic)
    return o
end

function Dynamic:update(dt, obstacles)

    print("----DELTA TIME: " .. dt)
    print("----ACC: " .. acc)

    acc = acc + dt
    if acc >= tick then
        dt = acc
        acc = 0

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
        if self.statusB == 1 then
            self.action = "Left side crossed with obstacle's Top"
            self.statusB = 0
        else
            self.action = "freeFall"
            if self.baseSpeed > self.maxSpeed then
                self.baseSpeed = 0
            end
        end
    elseif self.action == "Left side crossed with obstacle's Top"
        or self.action == "Right side crossed with obstacle's Top"
    then
        self.action = "stop"
        self.baseSpeed = 0
    end

    self.x = self.x
    if self.action == "freeFall" then
        self:freeFallDelta(dt) -- без разницы вызывать собственный метод через self./self:
    elseif self.action == "throwUp" then
        Dynamic.throwUpDelta(self, dt) -- или через Dynamic.
        if self.baseSpeed <= 0 then
            self.action = "freeFall"
            Dynamic.freeFallDelta(self, dt) -- но при вызове через "." нужно передавать в него self
        end
    elseif self.action == "throwAngle" then
        Dynamic.throwAngleDelta(self, dt)
    end
    Dynamic.detectCollision(self, obstacles)

    end
end

function Dynamic:freeFallDelta(t)
    if self.baseSpeed < self.maxSpeed then
        speed = self.baseSpeed + g*t
        print("--1--ff DELTA SPEED: " .. speed)
        self.y = self.y + speed
    else
        speed = self.baseSpeed
        print("--2--ff DELTA SPEED: " .. speed)
        self.y = self.y + speed
    end
    self.baseSpeed = speed
    self.statusL = 0
    self.statusR = 0
end

function Dynamic:throwUpDelta(t)
    if self.baseSpeed > 0 then
        speed = self.baseSpeed - g*t
        print("----tu DELTA SPEED: " .. speed)
        self.y = self.y - speed
        self.baseSpeed = speed
    end
end

function Dynamic:throwUp(v)
    if self.action ~= "Right side crossed with obstacle's Bottom"
        and self.action ~= "Left side crossed with obstacle's Bottom" then
            self.baseSpeed = v
            self.action = "throwUp"
            self.statusB = 0
    end
end

function Dynamic:throwAngleDelta(t)
    self.time = self.time + t*self.throwAngleTimeMultiplier
    local speedX = self.baseSpeed*math.cos(self.angle)*self.time
    local speedY = (self.baseSpeed*math.sin(self.angle)*self.time - (g*self.time^2)/2)
    print("----ta DELTA SPEED X: " .. speedX)
    print("----ta DELTA SPEED Y: " .. speedY)
    self.x = self.fixX + speedX
    self.y = self.fixY - speedY
end

function Dynamic:throwAngle(v, alpha, throwAngleTimeMultiplier)
    if self.action ~= "Right side crossed with obstacle's Bottom"
        and self.action ~= "Left side crossed with obstacle's Bottom"
    then
        if alpha < 90 and self.statusR ~= 1
            and self.action ~= "Top side crossed with obstacle's Left"
            and self.action ~= "Bottom side crossed with obstacle's Left"
        then
            self.fixX = self.x
            self.fixY = self.y
            self.angle = alpha*math.pi/180
            self.baseSpeed = v
            self.action = "throwAngle"
            self.time = 0
            self.throwAngleTimeMultiplier = throwAngleTimeMultiplier or 10
            self.statusB = 0
            self.statusL = 0
        elseif alpha > 90 and self.statusL ~= 1
            and self.action ~= "Top side crossed with obstacle's Right"
            and self.action ~= "Bottom side crossed with obstacle's Right"
        then
            self.fixX = self.x
            self.fixY = self.y
            self.angle = alpha*math.pi/180
            self.baseSpeed = v
            self.action = "throwAngle"
            self.time = 0
            self.throwAngleTimeMultiplier = throwAngleTimeMultiplier or 10
            self.statusB = 0
            self.statusR = 0
        end
    end
end

function Dynamic:detectCollision(obstacles)

    local left = {x1 = self.x, y1 = self.y - 5, x2 = self.x, y2 = self.y + self.height + 5}
    local right = {x1 = self.x + self.width, y1 = self.y - 5, x2 = self.x + self.width, y2 = self.y + self.height + 5}

    local top = {x1 = self.x - 5, y1 = self.y, x2 = self.x + self.width + 5, y2 = self.y}
    local bottom = {x1 = self.x - 5, y1 = self.y + self.height, x2 = self.x + self.width + 5, y2 = self.y + self.height}

    for i,o in ipairs(obstacles) do
        local o_left = {x1 = o.x, y1 = o.y, x2 = o.x, y2 = o.y + o.height}
        local o_right = {x1 = o.x + o.width, y1 = o.y, x2 = o.x + o.width, y2 = o.y + o.height}

        local o_top = {x1 = o.x, y1 = o.y, x2 = o.x + o.width, y2 = o.y}
        local o_bottom = {x1 = o.x, y1 = o.y + o.height, x2 = o.x + o.width, y2 = o.y + o.height}

        inter1 = checkIntersection(left, o_top)
        inter2 = checkIntersection(right, o_top)

        inter3 = checkIntersection(left, o_bottom)
        inter4 = checkIntersection(right, o_bottom)



        inter5 = checkIntersection(top, o_left)
        inter6 = checkIntersection(bottom, o_left)

        inter7 = checkIntersection(top, o_right)
        inter8 = checkIntersection(bottom, o_right)

        if inter1 then
            self.action = "Left side crossed with obstacle's Top"
            self.statusB = 1
        end
        if inter2 then
            self.action = "Right side crossed with obstacle's Top"
            self.statusB = 1
        end

        if inter3 then
            self.action = "Left side crossed with obstacle's Bottom"
            self.statusT = 1
        end
        if inter4 then
            self.action = "Right side crossed with obstacle's Bottom"
            self.statusT = 1
        end



        if inter5 and self.action ~="throwUp" then
            self.action = "Top side crossed with obstacle's Left"
            self.statusR = 1
        end
        if inter6 and self.action ~="throwUp" then
            self.action = "Bottom side crossed with obstacle's Left"
            self.statusR = 1
        end
        if inter7 and self.action ~="throwUp" then
            self.action = "Top side crossed with obstacle's Right"
            self.statusL = 1
        end
        if inter8 and self.action ~="throwUp" then
            self.action = "Bottom side crossed with obstacle's Right"
            self.statusL = 1
        end
    end
end

function checkIntersection(a, b)
    v1 = (b.x2-b.x1)*(a.y1-b.y1)-(b.y2-b.y1)*(a.x1-b.x1)
    v2 = (b.x2-b.x1)*(a.y2-b.y1)-(b.y2-b.y1)*(a.x2-b.x1)
    v3 = (a.x2-a.x1)*(b.y1-a.y1)-(a.y2-a.y1)*(b.x1-a.x1)
    v4 = (a.x2-a.x1)*(b.y2-a.y1)-(a.y2-a.y1)*(b.x2-a.x1)
    return (v1*v2<0) and (v3*v4<0)
end

function Dynamic:draw()
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end
