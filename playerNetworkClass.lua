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

    print(udp)

    self.udp = udp
end

function Player:networkUpdate(dt)
    self.t = self.t + dt

    print(self.client)

    if not self.client then
        data, from_ip, from_port = self.udp:receivefrom()

        print(from_ip)

        self.udp:setpeername(from_ip, from_port)
        self.client = self.udp

        print(self.client)

        self.client:settimeout(0)

        return 2 -- return gameState update
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

    return 2 -- TODO: doo I need this?
end

function Player:test()
    print("player network test")
end

function Player:updateOpponents(opponents)
    self.opponents = opponents or {}
end

function Player:handleSelfUpdate()
    local timeStamp = tostring(os.time())
    local dg = string.format("%s %d %f %f %f %f %f %f %s %f %f %f %f %f %f %f %f %f %s", 'move', timeStamp,
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
        self.direction
    )
    dg = dg .. platformToDg(self.platform)
    self.client:send(dg)
    self.t = self.t - self.updateRate
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
        update[24]
    )
end

function platformToDg(platform)
    local string = ""
    if platform.x ~= nil and platform.y ~= nil and platform.width ~= nil and platform.height ~= nil then
        string = string .. string.format(" %f", platform.x)
        string = string .. string.format(" %f", platform.y)
        string = string .. string.format(" %f", platform.width)
        string = string .. string.format(" %f", platform.height)
    end
    -- print("--------------------------------------------------------------------------------STRING " .. string)
    return string
end
