-- player.lua
local player = {}

function player.load()
   
    player.x = 400
    player.y = 400
    player.z = 0              
    player.zVel = 0           
    player.gravity = 800     
    player.jumpForce = -350   
    player.onGround = true    

    player.speed = 180
    player.scale = 4

    
    player.isDashing = false
    player.dashTimer = 0
    player.dashDuration = 0.15
    player.dashSpeed = 800
    player.dashCooldown = 0.5
    player.dashCooldownTimer = 0
    player.dashDirX = 0
    player.dashDirY = 0

    
    player.bodySprite = love.graphics.newImage("only body.png")
    player.headSprite = love.graphics.newImage("only head.png")

    player.frameWidth = player.bodySprite:getWidth() / 4
    player.frameHeight = player.bodySprite:getHeight() / 4

    player.currentAnimation = "down"
    player.frame = 1
    player.timer = 0
    player.animationSpeed = 0.15

    player.bodyAnims = {}
    player.headAnims = {}

    local function createAnim(sprite, row)
        local anim = {}
        for col = 0, 3 do
            table.insert(anim, love.graphics.newQuad(
                col * player.frameWidth,
                row * player.frameHeight,
                player.frameWidth,
                player.frameHeight,
                sprite:getDimensions()
            ))
        end
        return anim
    end

    
    player.bodyAnims.right = createAnim(player.bodySprite, 0)
    player.bodyAnims.left  = createAnim(player.bodySprite, 1)
    player.bodyAnims.down  = createAnim(player.bodySprite, 2)
    player.bodyAnims.up    = createAnim(player.bodySprite, 3)

    player.headAnims.right = createAnim(player.headSprite, 0)
    player.headAnims.left  = createAnim(player.headSprite, 1)
    player.headAnims.down  = createAnim(player.headSprite, 2)
    player.headAnims.up    = createAnim(player.headSprite, 3)
end


function player.performDash()
    local moveX, moveY = 0, 0

    if love.keyboard.isScancodeDown("d") then moveX = moveX + 1 end
    if love.keyboard.isScancodeDown("a") then moveX = moveX - 1 end
    if love.keyboard.isScancodeDown("s") then moveY = moveY + 1 end
    if love.keyboard.isScancodeDown("w") then moveY = moveY - 1 end

    if moveX == 0 and moveY == 0 then
        if player.currentAnimation == "right" then moveX = 1
        elseif player.currentAnimation == "left" then moveX = -1
        elseif player.currentAnimation == "down" then moveY = 1
        elseif player.currentAnimation == "up" then moveY = -1
        end
    end

    local len = math.sqrt(moveX^2 + moveY^2)
    if len > 0 then
        player.dashDirX = moveX / len
        player.dashDirY = moveY / len
        player.isDashing = true
        player.dashTimer = player.dashDuration
        player.dashCooldownTimer = player.dashCooldown
    end
end

function player.keypressed(key, scancode)
    if scancode == "lshift" then
        if not player.isDashing and player.dashCooldownTimer <= 0 then
            player.performDash()
        end
    end

    if key == "space" and player.onGround then
        player.zVel = player.jumpForce
        player.onGround = false
    end
end

function player.update(dt)
   
    if player.dashCooldownTimer > 0 then
        player.dashCooldownTimer = math.max(0, player.dashCooldownTimer - dt)
    end

    
    if player.isDashing then
        player.x = player.x + player.dashDirX * player.dashSpeed * dt
        player.y = player.y + player.dashDirY * player.dashSpeed * dt

        player.dashTimer = player.dashTimer - dt
        if player.dashTimer <= 0 then
            player.isDashing = false
        end
        return
    end

    
    local moveX, moveY = 0, 0
    if love.keyboard.isScancodeDown("d") then moveX = moveX + 1 end
    if love.keyboard.isScancodeDown("a") then moveX = moveX - 1 end
    if love.keyboard.isScancodeDown("s") then moveY = moveY + 1 end
    if love.keyboard.isScancodeDown("w") then moveY = moveY - 1 end

    local moving = (moveX ~= 0 or moveY ~= 0)

    if moving then
        local len = math.sqrt(moveX^2 + moveY^2)
        moveX, moveY = moveX / len, moveY / len

        player.x = player.x + moveX * player.speed * dt
        player.y = player.y + moveY * player.speed * dt

        if math.abs(moveX) > math.abs(moveY) then
            player.currentAnimation = (moveX > 0) and "right" or "left"
        else
            player.currentAnimation = (moveY > 0) and "down" or "up"
        end

        player.timer = player.timer + dt
        if player.timer >= player.animationSpeed then
            player.timer = 0
            player.frame = (player.frame % 4) + 1
        end
    else
        player.frame = 1
    end

    
    player.zVel = player.zVel + player.gravity * dt
    player.z = player.z + player.zVel * dt

    if player.z > 0 then
        player.z = 0
        player.zVel = 0
        player.onGround = true
    end
end

function player.draw()
    local bodyQuad = player.bodyAnims[player.currentAnimation][player.frame]
    local headQuad = player.headAnims[player.currentAnimation][player.frame]

    local drawX = math.floor(player.x)
    local drawY = math.floor(player.y + player.z)

    
    love.graphics.draw(
        player.bodySprite,
        bodyQuad,
        drawX,
        drawY,
        0,
        player.scale,
        player.scale,
        player.frameWidth / 2,
        player.frameHeight / 2
    )

    
    love.graphics.draw(
        player.headSprite,
        headQuad,
        drawX,
        drawY,
        0,
        player.scale,
        player.scale,
        player.frameWidth / 2,
        player.frameHeight / 2
    )
end

return player