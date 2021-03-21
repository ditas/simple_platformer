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

    self.dead = false

    self.shoot = false
    self.projAngle = 0
    self.projStartCoords = {0, 0}

    return o
end

function Player:storeProj(angle, x, y)
    self.shoot = true
    self.projAngle = angle
    self.projStartCoords = {x, y}
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
    if not self.dead then
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
    else
        return 1
    end
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

function Player:updateOpponents(opponents)
    self.opponents = opponents or {}
end

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

    shoot,
    projAngle,
    projStartCoordsX,
    projStartCoordsY,

    platform_x,
    platform_y,
    platform_width,
    platform_height
)

    self.shoot = numToBool(tonumber(shoot))
    self.projAngle = tonumber(projAngle)
    self.projStartCoords = {tonumber(projStartCoordsX), tonumber(projStartCoordsY)}

    -- TODO: for some reason I can't use ":" without self here (WTF?)
    Animation.setUpdateData(self, x, y, width, height, baseSpeed, maxSpeed, action, angle, time, fixX, fixY, throwAngleTimeMultiplier, statusL, statusT, statusR, statusB, direction, platform_x, platform_y, platform_width, platform_height)
end

function Player:handleSelfUpdate()
    local timeStamp = tostring(os.time())
    local dg = string.format("%s %d %f %f %f %f %f %f %s %f %f %f %f %f %f %f %f %f %s %f %f %f %f", 'move', timeStamp,
        -- self.id, -- TODO: handle me
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
        update[3],
        update[4],
        update[5],
        update[6],
        update[7],
        update[8],
        update[9],
        update[10],
        update[11],
        update[12],
        update[13],
        update[14],
        update[15],
        update[16],
        update[17],
        update[18],
        update[19],
        update[20],

        update[21],
        update[22],
        update[23],
        update[24],

        update[25],
        update[26],
        update[27],
        update[28]
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
