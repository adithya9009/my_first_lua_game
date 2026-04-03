
local world = {}

function world.load()
    
    world.bg = love.graphics.newImage("background.png.png")

    world.tileSize = 64
end


function world.draw(camera)
    local bgW = world.bg:getWidth()
    local bgH = world.bg:getHeight()

    
    local startX = math.floor(camera.x / bgW) * bgW
    local startY = math.floor(camera.y / bgH) * bgH

    
    for x = startX - bgW, startX + love.graphics.getWidth() + bgW, bgW do
        for y = startY - bgH, startY + love.graphics.getHeight() + bgH, bgH do
            love.graphics.draw(world.bg, x, y)
        end
    end
end

return world