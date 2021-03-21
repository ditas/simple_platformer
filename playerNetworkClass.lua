require("animationDynamicClass")

Player = Animation:new()

function Player:new(id, x, y, shape, width, height, baseSpeed, maxSpeed, angle, action, obstacles)
    local o = Animation:new(id, x, y, shape, width, height, baseSpeed, maxSpeed, angle, action, obstacles)
    setmetatable(o, self)
    self.__index = self

    self.opponents = {}
    self.socket = require("socket")
    self.client = nil
    self.udp = nil
    self.address = nil
    self.port = nil
    self.updateRate = 0.1
    self.t = 0

    o.type = "player"
    o:setIsMovable(true) -- players are movable by default

    -- self.hurt = false
    -- self.dead = false
    self.shoot = false
    self.projAngle = 0
    self.projStartCoords = {0, 0}

    return o
end

function Player:connect(address, port)
    self.address = address
    self.port = port

    local osString = love.system.getOS()
    -- print(osString)

    local timeStamp = tostring(os.time())
    local dg = string.format("%s %d %s %s", 'init', timeStamp, 'test_match', self.id)

    local udp = self.socket.udp()
    udp:settimeout(5)
    if osString == "Linux" then
        local ip = assert(self.socket.dns.toip(self.address))
        udp:setsockname("*", 0) -- bind on any availible port and local(?) ip address.
        udp:sendto(dg, ip, self.port)
    else
        udp:setpeername(self.address, self.port)
        udp:send(dg)
        udp:setpeername("*")
    end

    self.udp = udp
end

function Player:networkUpdate(dt)
    self.t = self.t + dt

    if not self.client then
        data, from_ip, from_port = self.udp:receivefrom()

        self.udp:setpeername(from_ip, from_port)
        self.client = self.udp
        self.client:settimeout(0)
    elseif self.t > self.updateRate then
        self:handleSelfUpdate()
    else
        local update = self.client:receive()
        local opponentUpdate = {}
        if update then
            for w in update:gmatch("%S+") do
                table.insert(opponentUpdate, w)
            end
            self:handleOpponentUpdate(opponentUpdate)
        end
    end

    return 2
end

-- function Player:setUpdateData(
--     x,
--     y,
--     width,
--     height,
--     baseSpeed,
--     maxSpeed,
--     action,
--     angle,
--     time,
--     fixX,
--     fixY,
--     throwAngleTimeMultiplier,
--     statusL,
--     statusT,
--     statusR,
--     statusB,
--     direction,
--     hurt,
--     dead,
--
--     shoot,
--     projAngle,
--     projStartCoordsX,
--     projStartCoordsY,
--
--     platform_x,
--     platform_y,
--     platform_width,
--     platform_height
-- )
--     self.x = tonumber(x)
--     self.y = tonumber(y)
--     self.width = tonumber(width)
--     self.height = tonumber(height)
--     self.baseSpeed = tonumber(baseSpeed)
--     self.maxSpeed = tonumber(maxSpeed)
--     self.action = action
--     self.angle = tonumber(angle)
--     self.time = tonumber(time)
--     self.fixX = tonumber(fixX)
--     self.fixY = tonumber(fixY)
--     self.throwAngleTimeMultiplier = tonumber(throwAngleTimeMultiplier)
--     self.statusL = tonumber(statusL)
--     self.statusT = tonumber(statusT)
--     self.statusR = tonumber(statusR)
--     self.statusB = tonumber(statusB)
--     self.direction = direction
--     self.hurt = numToBool(tonumber(hurt))
--     self.dead = numToBool(tonumber(dead))
--
--     self.shoot = numToBool(tonumber(shoot))
--     self.projAngle = tonumber(projAngle)
--     self.projStartCoords = {tonumber(projStartCoordsX), tonumber(projStartCoordsY)}
--
--     self.platform.x = tonumber(platform_x)
--     self.platform.y = tonumber(platform_y)
--     self.platform.width = tonumber(platform_width)
--     self.platform.height = tonumber(platform_height)
-- end

function Player:setUpdateData(
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
    hurt,
    dead,

    shoot,
    projAngle,
    projStartCoordsX,
    projStartCoordsY,

    platform_x,
    platform_y,
    platform_width,
    platform_height
)
    Animation.setUpdateData(self,
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
        hurt,
        dead,

        platform_x,
        platform_y,
        platform_width,
        platform_height
    )

    self.shoot = numToBool(tonumber(shoot))
    self.projAngle = tonumber(projAngle)
    self.projStartCoords = {tonumber(projStartCoordsX), tonumber(projStartCoordsY)}
end

function Player:update(dt, obstacles, direction)
    if self.hurt == true then

        self:setAnimation(3)

        self.animation.currentTime = self.animation.currentTime + dt
        if self.animation.currentTime >= self.animation.duration then
            self.animation.currentTime = self.animation.currentTime - self.animation.duration
            self.dead = true
        end
    end
    Animation.update(self, dt, obstacles, direction, callbacks)
end

function Player:test()
    print("player network test")
end

function Player:storeProj(angle, x, y)
    self.shoot = true
    self.projAngle = angle
    self.projStartCoords = {x, y}
end

function Player:updateOpponents(opponents)
    self.opponents = opponents or {}
end

function Player:handleSelfUpdate()
    local timeStamp = tostring(os.time())
    local dg = string.format("%s %d %s %f %f %f %f %f %f %s %f %f %f %f %f %f %f %f %f %s %f %f %f %f %f %f", 'move', timeStamp,
        self.id,
        self.x,
        self.y,
        self.width,
        self.height,
        self.baseSpeed,
        self.maxSpeed,
        self.action,
        self.angle,
        self.time,
        self.fixX,
        self.fixY,
        self.throwAngleTimeMultiplier,
        self.statusL,
        self.statusT,
        self.statusR,
        self.statusB,
        self.direction,

        boolToNum(self.hurt),
        boolToNum(self.dead),

        boolToNum(self.shoot),
        self.projAngle,
        self.projStartCoords[1],
        self.projStartCoords[2]
    )
    dg = dg .. platformToDg(self.platform)
    self.client:send(dg)
    self.t = self.t - self.updateRate

    self.shoot = false
end

function Player:handleOpponentUpdate(update)
    self.opponents[1]:setUpdateData(
        -- update[3], -- self.id,
        update[4], -- self.x,
        update[5], -- self.y,
        update[6],  -- self.width,
        update[7], -- self.height,
        update[8], -- self.baseSpeed,
        update[9], -- self.maxSpeed,
        update[10], -- self.action,
        update[11], -- self.angle,
        update[12], -- self.time,
        update[13], -- self.fixX,
        update[14], -- self.fixY,
        update[15], -- self.throwAngleTimeMultiplier,
        update[16], -- self.statusL,
        update[17], -- self.statusT,
        update[18], -- self.statusR,
        update[19], -- self.statusB,
        update[20], -- self.direction,
        update[21], -- self.hurt
        update[22], -- self.dead

        -- proj
        update[23], -- self.shoot
        update[24], -- self.projAngle
        update[25], -- self.projStartCoords[1],
        update[26], -- self.projStartCoords[2]

        -- platform
        update[27],
        update[28],
        update[29],
        update[30]
    )
end

function Player:handleProj()
    self.hurt = true
end

function platformToDg(platform)
    local string = ""
    if platform.x ~= nil and platform.y ~= nil and platform.width ~= nil and platform.height ~= nil then
        string = string .. string.format(" %f", platform.x)
        string = string .. string.format(" %f", platform.y)
        string = string .. string.format(" %f", platform.width)
        string = string .. string.format(" %f", platform.height)
    end
    return string
end

function boolToNum(bool)
    return bool and 1 or 0
end

function numToBool(num)
    return num > 0
end
