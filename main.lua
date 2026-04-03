
local Player = require("player")
local World  = require("world")

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    
    love.window.setMode(1280, 720, {
        fullscreen = true,
        resizable = false,
        vsync = 1
    })

    
    World.load()
    Player.load()

    
    camera = {
        x = 0,
        y = 0,
        lerp = 8 
    }
end


function love.keypressed(key, scancode)
    
    if key == "escape" then
        love.event.quit()
    end

    Player.keypressed(key, scancode)
end


function love.update(dt)
    Player.update(dt)

    
    local targetX = Player.x - love.graphics.getWidth() / 2
    local targetY = Player.y - love.graphics.getHeight() / 2

    camera.x = camera.x + (targetX - camera.x) * camera.lerp * dt
    camera.y = camera.y + (targetY - camera.y) * camera.lerp * dt
end


function love.draw()
    
    love.graphics.clear(0.15, 0.5, 0.15)

    love.graphics.push()

   
    love.graphics.translate(-math.floor(camera.x), -math.floor(camera.y))

    
    World.draw(camera)

    
    Player.draw()

    love.graphics.pop()

    
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 5, 5, 140, 70)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("X: " .. math.floor(Player.x), 10, 10)
    love.graphics.print("Y: " .. math.floor(Player.y), 10, 30)
    love.graphics.print("Z: " .. math.floor(Player.z), 10, 50) 
end