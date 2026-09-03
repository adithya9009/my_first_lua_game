local Player = require("player")
local World  = require("world")

local accumulator = 0
local fixedDt = 1 / 60

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    love.window.setMode(1280, 720, {
        fullscreen = true,
        resizable = false,
        vsync = 1
    })

    World.load()
    Player.load()

    _G.camera = { x = 0, y = 0, lerp = 5 }
end

function love.keypressed(key, scancode)
    if key == "escape" then
        love.event.quit()
    end
    Player.keypressed(key, scancode)
end

function love.update(dt)
    if dt > 0.1 then dt = 0.1 end
    accumulator = accumulator + dt

    while accumulator >= fixedDt do
        Player.update(fixedDt)

        local targetX = Player.x - love.graphics.getWidth() / 2
        local targetY = Player.y - love.graphics.getHeight() / 2

        camera.x = camera.x + (targetX - camera.x) * camera.lerp * fixedDt
        camera.y = camera.y + (targetY - camera.y) * camera.lerp * fixedDt

        accumulator = accumulator - fixedDt
    end
end

function love.draw()
    love.graphics.clear(0.15, 0.5, 0.15)

    local camX = math.floor(camera.x / 4 + 0.5) * 4
    local camY = math.floor(camera.y / 4 + 0.5) * 4

    love.graphics.push()
    love.graphics.translate(-camX, -camY)

    World.draw(camera)
    Player.draw()

    love.graphics.pop()
    
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 5, 5, 140, 70)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("X: " .. math.floor(Player.x), 10, 10)
    love.graphics.print("Y: " .. math.floor(Player.y), 10, 30)
    love.graphics.print("Z: " .. math.floor(Player.z or 0), 10, 50)
end
