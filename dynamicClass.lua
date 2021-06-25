local g = 10
local tick = 1/60
local runSpeed = 300 -- 200 -- 120 -- this is max, don't use more as it could fail on collisions when pushing 2+ objects
local deathZone = {-1000, -2000, 1000, 2000}
local collisionDelta = 7.5 -- do not change, as it could break collision detection
local stuckPreventionDelta = 7 -- do not change, as it could cause some visual drift on the edges of the platforms

require("common")

Dynamic = {}

function Dynamic:new(id, x, y, shape, width, height, baseSpeed, maxSpeed, angle, action, obstacles)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.id = id or nil
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
    o.throwAngleTimeMultiplier = 10

    o.statusL = 0
    o.statusT = 0
    o.statusR = 0
    o.statusB = 0

    o.platform = {}

    o.acc = 0

    o.direction = nil

    o.isJump = false

    o.isMovable = false

    -- proj collisions test
    o.isDead = false
    -----------------------

    o.deathZone = deathZone

    return o
end

function Dynamic:getCollisionDelta()
    if self.type == "player" then
        return collisionDelta
    else 
        return 0
    end
end

function Dynamic:setIsMovable(isMovable)
    self.isMovable = isMovable
end

function Dynamic:setDeathZone(deathZoneTable)
    self.deathZone = deathZoneTable
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
    statusB,
    direction,
    isJump,

    platformX,
    platformY,
    platformWidth,
    platformHeight
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
    self.direction = direction
    self.isJump = numToBool(tonumber(isJump))

    self.platform.x = tonumber(platformX)
    self.platform.y = tonumber(platformY)
    self.platform.width = tonumber(platformWidth)
    self.platform.height = tonumber(platformHeight)
end

function Dynamic:update(dt, obstacles, direction, updateCallbacks)

    if direction ~= nil then
        self.direction = direction
    end

    -- print("----" .. self.id .."-----ACTION: " .. self.action .. " statusB: " .. self.statusB .. " statusL: " .. self.statusL .. " statusR: " .. self.statusR .. " statusT " .. self.statusT)
    -- print(self.direction)
    -- print(self.isJump)

    -- stuck prevention
    if self.isMovable then
        if self.statusB == 1 and self.statusL == 1 then
            self.x = self.x + 1
            self.y = self.y - 0.5
        end

        if self.statusB == 1 and self.statusR == 1 then
            self.x = self.x - 1
            self.y = self.y - 0.5
        end

        if self.statusB == 1
            and self.platform.y ~= nil
        then
            if self.y + self.height + stuckPreventionDelta > self.platform.y then -- it's 7, NOT 7.5, as 7.5 causes some visual drift (WHY?)
                self.y = self.y - 0.1
            end
        end
    end
    -------------------

    if self.statusB == 1 then
        if (self.x + collisionDelta < self.platform.x + self.platform.width and self.x + self.width - collisionDelta > self.platform.x)
            or
            (self.platform.x + collisionDelta < self.x + self.width and self.platform.x + self.platform.width - collisionDelta > self.x)
        then
            if self.direction == "left" and self.statusL ~= 1 then
                self.x = self.x - runSpeed * dt
                self.statusR = 0
                updateCallbacks[self.direction](self, dt)
            elseif self.direction == "right" and self.statusR ~= 1 then
                self.x = self.x + runSpeed * dt
                self.statusL = 0
                updateCallbacks[self.direction](self, dt)
            end
        else
            self.statusB = 0
            self.action = "freeFall"
        end
        self.platform.x = 0
        self.platform.y = 0
        self.platform.width = 0
        self.platform.height = 0
    end

    if self.action == "topBlocked" then
        if self.statusB == 1 then
            self.action = "stop"
        else
            self.action = "freeFall"
            if self.baseSpeed > self.maxSpeed then
                self.baseSpeed = 0
            end
        end
    end

    if self.action == "rightBlocked" or self.action == "leftBlocked" then
        if self.statusB == 1 then
            self.action = "stop"
        else
            self.action = "freeFall"
            if self.baseSpeed > self.maxSpeed then
                self.baseSpeed = 0
            end
        end
    end

    if self.action == "stop" then
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
        self:throwAngleDelta(dt, updateCallbacks)
    end

    Dynamic.deathZoneCheck(self)

    Dynamic.detectCollision(self, obstacles)
end

function Dynamic:deathZoneCheck()
    if self.x < self.deathZone[1]
    or self.x > self.deathZone[3]
    or self.y < self.deathZone[2]
    or self.y > self.deathZone[4]
    then
        self.isDead = true
    end
end

function Dynamic:freeFallDelta(t)
    self.isJump = false
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
    if self.baseSpeed > 0 then
        speed = self.baseSpeed - g*t
        self.y = self.y - speed
        self.baseSpeed = speed
    end
end

function Dynamic:throwUp(v)
    self.isJump = true
    if self.action ~= "topBlocked" then
        self.baseSpeed = v
        self.action = "throwUp"
        self.statusB = 0
    end
end

-- function Dynamic.throwAngleDelta(self, t, callbacks) -- it works too
function Dynamic:throwAngleDelta(t, callbacks)
    local angleDeg = self.angle * 180 / math.pi
    if angleDeg < 90 then
        self.direction = "right"
        callbacks[self.direction](self, t)
    elseif angleDeg > 90 then
        self.direction = "left"
        callbacks[self.direction](self, t)
    end

    self.time = self.time + t*self.throwAngleTimeMultiplier

    -- print("--------BEFORE--------- self.throwAngleTimeMultiplier " .. self.throwAngleTimeMultiplier)

    if self.throwAngleTimeMultiplier > 1 then
        self.throwAngleTimeMultiplier = self.throwAngleTimeMultiplier - t*1.5
    end

    -- print("--------AFTER--------- self.throwAngleTimeMultiplier " .. self.throwAngleTimeMultiplier)

    -- print("---------- self.time " .. self.time)

    local speedX = self.baseSpeed*math.cos(self.angle)*self.time
    local speedY = (self.baseSpeed*math.sin(self.angle)*self.time - (g*self.time^2)/2)

    -- print("---------- self.baseSpeed " .. self.baseSpeed)
    -- print("---------- speedX " .. speedX .. " speedY " .. speedY)

    self.x = self.fixX + speedX
    self.y = self.fixY - speedY

end

function Dynamic:throwAngle(v, alpha, throwAngleTimeMultiplier)
    self.isJump = true
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

    -- print("--------INIT--------- self.throwAngleTimeMultiplier " .. self.throwAngleTimeMultiplier)
end

function Dynamic:detectCollision(obstacles)
    for i,o in ipairs(obstacles) do

        if o.id ~= self.id then

            -- AABB
            if (self.x - collisionDelta < o.x + o.width and
                self.x + self.width + collisionDelta > o.x and
                self.y - collisionDelta < o.y + o.height and
                self.y + self.height + collisionDelta > o.y)
            then
            -------

                if o.y + o.height <= self.y + collisionDelta then
                    self.statusT = 1
                    self.action = "topBlocked"
                elseif o.x + o.width <= self.x + collisionDelta then
                    self.statusL = 1
                    self.action = "leftBlocked"
                elseif o.x >= self.x + self.width - collisionDelta then
                    self.statusR = 1
                    self.action = "rightBlocked"
                elseif self.y + self.height - collisionDelta < o.y then
                    self.statusB = 1
                    self.action = "stop"

                    self.isJump = false

                    self.platform.x = o.x
                    self.platform.y = o.y
                    self.platform.width = o.width
                    self.platform.height = o.height
                end

            end

        end

    end
end

function Dynamic:draw()
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end

function Dynamic:handleProj()
    self.isDead = true
end
