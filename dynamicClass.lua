local g = 10
local tick = 1/60

Dynamic = {}
Dynamic.__index = Dynamic

function Dynamic.new(x, y, shape, width, height, baseSpeed, maxSpeed, angle, action, obstacles)
    local o = {}

    o.id = nil
    o.type = "dynamic"

    o.x = x or 0
    o.y = y or 0
    o.shape = shape or "rectangle"
    o.width = width or 50
    o.height = height or 50

    o.square = o.width * o.height

    o.baseSpeed = baseSpeed or 0
    o.maxSpeed = maxSpeed or 10
    o.action = action or "freeFall" -- | throwUp | throwAngle | stop
    o.obstacles = obstacles or {}

    o.angle = 0 -- in rads
    o.time = 0
    o.fixX = 0
    o.fixY = 0
    o.throwAngleTimeMultiplier = 1

    o.statusL = 0
    o.statusT = 0
    o.statusR = 0
    o.statusB = 0

    -- o.platform = {0, 0, 0, 0}
    o.platform = {}
    -- o.platform.x = 0
    -- o.platform.y = 0
    -- o.platform.width = 0
    -- o.platform.height = 0

    o.acc = 0

    o.animation = nil

    setmetatable(o, Dynamic)
    return o
end

function Dynamic:setId(id)
    self.id = id
end

function Dynamic:setAnimation(animation)
    self.animation = animation or {}
end

function Dynamic:setUpdateData(
    x,
    y,
    width,
    height,
    baseSpeed,
    maxSpeed,
    action,
    angle,
    time,
    fixX,
    fixY,
    throwAngleTimeMultiplier,
    statusL,
    statusT,
    statusR,
    statusB
)
    self.x = tonumber(x)
    self.y = tonumber(y)
    self.width = tonumber(width)
    self.height = tonumber(height)
    self.baseSpeed = tonumber(baseSpeed)
    self.maxSpeed = tonumber(maxSpeed)
    self.action = action
    self.angle = tonumber(angle)
    self.time = tonumber(time)
    self.fixX = tonumber(fixX)
    self.fixY = tonumber(fixY)
    self.throwAngleTimeMultiplier = tonumber(throwAngleTimeMultiplier)
    self.statusL = tonumber(statusL)
    self.statusT = tonumber(statusT)
    self.statusR = tonumber(statusR)
    self.statusB = tonumber(statusB)
end

function Dynamic:update(dt, obstacles, direction)

    -- print("dt 1 "..dt)
    print("----" .. self.id .."-----ACTION: " .. self.action .. " DIR: " .. direction .. " statusB: " .. self.statusB .. " statusL: " .. self.statusL .. " statusR: " .. self.statusR)

    -- stuck prevention
    if self.statusB == 1 and self.statusL == 1 then

print("-----------L-------------"  .. self.id .. "-------------------------- X " ..  self.x .. " Y " .. self.y)

        self.x = self.x + 1
        self.y = self.y - 1
        self.statusL = 0
    end

    if self.statusB == 1 and self.statusR == 1 then

print("-----------R-------------"  .. self.id .. "-------------------------- X " ..  self.x .. " Y " .. self.y)

        self.x = self.x - 1
        self.y = self.y - 1
        self.statusR = 0
    end

    print("----" .. self.id .."-----BOTTOM Y: " .. self.y + self.height + 7.5)
    if self.statusB == 1 and self.platform.y ~= nil then
        print("----" .. self.id .."-----PLATFORM Y: " .. self.platform.y)
        if self.y + self.height + 7.5 > self.platform.y then
            self.y = self.y - 0.1
        end
    end
    -------------------


    -- if #self.platform > 0 then
    --     print("----" .. self.id .."-----PLATFORM x " .. self.platform.x .. " y " .. self.platform.y .. " width " .. self.platform.width .. " height " .. self.platform.height)
    -- end

    if self.statusB == 1 then
        if (self.x < self.platform.x + self.platform.width and self.x + self.width > self.platform.x) 
            or 
            (self.platform.x < self.x + self.width and self.platform.x + self.platform.width > self.x) 
        then
            if direction == "left" and self.statusL ~= 1 then
                self.x = self.x - 100 * dt
                self.statusR = 0
            elseif direction == "right" and self.statusR ~= 1 then
                self.x = self.x + 100 * dt
                self.statusL = 0
            end

            self.platform.x = 0
            self.platform.y = 0
            self.platform.width = 0
            self.platform.height = 0
        else
            self.statusB = 0
            self.action = "freeFall"

            self.platform.x = 0
            self.platform.y = 0
            self.platform.width = 0
            self.platform.height = 0
        end
    end

    -- if self.statusB == 1 and self.x + self.width > self.platform.x and self.x < self.platform.x + self.platform.width then
    --     if direction == "left" and self.statusL ~= 1 then
    --         self.x = self.x - 100 * dt
    --         self.statusR = 0
    --     elseif direction == "right" and self.statusR ~= 1 then
    --         self.x = self.x + 100 * dt
    --         self.statusL = 0
    --     end

    --     self.platform.x = 0
    --     self.platform.y = 0
    --     self.platform.width = 0
    --     self.platform.height = 0
    -- elseif self.statusB == 1 then
    --     self.statusB = 0
    --     self.action = "freeFall"

    --     self.platform.x = 0
    --     self.platform.y = 0
    --     self.platform.width = 0
    --     self.platform.height = 0
    -- end

    if self.action == "topBlocked" then
        self.action = "freeFall"
        self.baseSpeed = 0
    elseif self.action == "rightBlocked" or self.action == "leftBlocked" then
        if self.statusB == 1 then
            self.action = "stop"
        else
            self.action = "freeFall"
            if self.baseSpeed > self.maxSpeed then
                self.baseSpeed = 0
            end
        end
    elseif self.action == "stop" then
        self.baseSpeed = 0
    end

    if self.action == "freeFall" then
        self:freeFallDelta(dt) -- без разницы вызывать собственный метод через self./self:
    elseif self.action == "throwUp" then
        self:throwUpDelta(dt) -- или через Dynamic.
        if self.baseSpeed <= 0 then
            self.action = "freeFall"
            self:freeFallDelta(dt) -- но при вызове через "." нужно передавать в него self
        end
    elseif self.action == "throwAngle" then
        self:throwAngleDelta(dt)
    end

    Dynamic.detectCollision(self, obstacles)

    return self
end

function Dynamic:freeFallDelta(t)
    if self.baseSpeed < self.maxSpeed then
        speed = self.baseSpeed + g*t
        self.y = self.y + speed
    else
        speed = self.baseSpeed
        self.y = self.y + speed
    end
    self.baseSpeed = speed
    self.statusL = 0
    self.statusR = 0
end

function Dynamic:throwUpDelta(t)
    print(t)
    if self.baseSpeed > 0 then
        speed = self.baseSpeed - g*t
        self.y = self.y - speed
        self.baseSpeed = speed
    end
end

function Dynamic:throwUp(v)
    if self.action ~= "topBlocked" then
        self.baseSpeed = v
        self.action = "throwUp"
        self.statusB = 0
    end
end

function Dynamic:throwAngleDelta(t)
    self.time = self.time + t*self.throwAngleTimeMultiplier
    local speedX = self.baseSpeed*math.cos(self.angle)*self.time
    local speedY = (self.baseSpeed*math.sin(self.angle)*self.time - (g*self.time^2)/2)
    self.x = self.fixX + speedX
    self.y = self.fixY - speedY
end

function Dynamic:throwAngle(v, alpha, throwAngleTimeMultiplier)
    if self.action ~= "topBlocked" then
        if alpha < 90 and self.statusR ~= 1 and self.action ~= "rightBlocked" then
            self:applyAngleMovement(v, alpha, throwAngleTimeMultiplier)
            self.statusL = 0
        elseif alpha > 90 and self.statusL ~= 1 and self.action ~= "leftBlocked" then
            self:applyAngleMovement(v, alpha, throwAngleTimeMultiplier)
            self.statusR = 0
        end
    end
end

function Dynamic:applyAngleMovement(v, alpha, throwAngleTimeMultiplier)
    self.fixX = self.x
    self.fixY = self.y
    self.angle = alpha*math.pi/180
    self.baseSpeed = v
    self.action = "throwAngle"
    self.time = 0
    self.throwAngleTimeMultiplier = throwAngleTimeMultiplier or 10
    self.statusB = 0
end

function Dynamic:detectCollision(obstacles)
    local left = {x1 = self.x, y1 = self.y - 7.5, x2 = self.x, y2 = self.y + self.height + 7.5}
    local right = {x1 = self.x + self.width, y1 = self.y - 7.5, x2 = self.x + self.width, y2 = self.y + self.height + 7.5}

    local top = {x1 = self.x - 7.5, y1 = self.y, x2 = self.x + self.width + 7.5, y2 = self.y}
    local bottom = {x1 = self.x - 7.5, y1 = self.y + self.height, x2 = self.x + self.width + 7.5, y2 = self.y + self.height}

    for i,o in ipairs(obstacles) do

        if o.id ~= self.id then

            -- AABB
            if (self.x - 7.5 < o.x + o.width and
                self.x + self.width + 7.5 > o.x and
                self.y - 7.5 < o.y + o.height and
                self.y + self.height + 7.5 > o.y) 
            then
            -------

                if o.y + o.height < self.y then
                    print(self.id .. " top")

                    self.statusT = 1
                    self.action = "topBlocked"
                elseif o.x + o.width < self.x then
                    print(self.id .. " left")

                    self.statusL = 1
                    self.action = "leftBlocked"
                elseif o.x > self.x + self.width then
                    print(self.id .. " right")

                    self.statusR = 1
                    self.action = "rightBlocked"
                else
                    print(self.id .. " bottom")

                    self.statusB = 1
                    self.action = "stop"

                    self.platform.x = o.x
                    self.platform.y = o.y
                    self.platform.width = o.width
                    self.platform.height = o.height
                end

                -- local o_left = {x1 = o.x, y1 = o.y, x2 = o.x, y2 = o.y + o.height}
                -- local o_right = {x1 = o.x + o.width, y1 = o.y, x2 = o.x + o.width, y2 = o.y + o.height}
                -- local o_top = {x1 = o.x, y1 = o.y, x2 = o.x + o.width, y2 = o.y}
                -- local o_bottom = {x1 = o.x, y1 = o.y + o.height, x2 = o.x + o.width, y2 = o.y + o.height}

                -- inter1 = checkIntersection(left, o_top)
                -- inter2 = checkIntersection(right, o_top)
                -- inter3 = checkIntersection(left, o_bottom)
                -- inter4 = checkIntersection(right, o_bottom)
                -- inter5 = checkIntersection(top, o_left)
                -- inter6 = checkIntersection(bottom, o_left)
                -- inter7 = checkIntersection(top, o_right)
                -- inter8 = checkIntersection(bottom, o_right)

                -- if inter1 or inter2 
                --     or 
                --     checkIntersection(o_left, bottom) or checkIntersection(o_right, bottom) 
                --     -- checkIntersection(bottom, o_left) or checkIntersection(bottom, o_right)
                -- then

                --     print("------------PL ID " .. o.id)

                --     self.statusB = 1
                --     self.action = "stop"

                --     self.platform.x = o.x
                --     self.platform.y = o.y
                --     self.platform.width = o.width
                --     self.platform.height = o.height
                -- end

                -- if inter3 or inter4 then
                --     self.statusT = 1
                --     self.action = "topBlocked"
                -- end

                -- if (inter5 or inter6) and self.action ~= "throwUp" then
                --     self.statusR = 1
                --     self.action = "rightBlocked"
                -- end

                -- if (inter7 or inter8) and self.action ~= "throwUp" then
                --     self.statusL = 1
                --     self.action = "leftBlocked"
                -- end

            end

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

function Dynamic:draw(isAnimate)
    -- if self.animation then
    --     if isAnimate then    
    --         spriteNum = math.floor(self.animation.currentTime/self.animation.duration * #self.animation.quads) + 1
    --         love.graphics.draw(self.animation.spiteSheet, self.animation.quads[spriteNum], self.x, self.y)
    --     elseif isAnimate == false then -- should be explicit "false" otherwise there are some frames when it's nil
    --         love.graphics.draw(self.animation.spiteSheet, self.animation.quads[1], self.x, self.y)
    --     end
    -- else
    --     love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    -- end

    -- if self.animation and isAnimate then  
    --     spriteNum = math.floor(self.animation.currentTime/self.animation.duration * #self.animation.quads) + 1
    --     love.graphics.draw(self.animation.spiteSheet, self.animation.quads[spriteNum], self.x, self.y)
    -- else
    --     love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    -- end

    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end
