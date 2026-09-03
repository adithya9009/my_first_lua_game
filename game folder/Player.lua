local player = {}

local function sign(x)
    return x > 0 and 1 or (x < 0 and -1 or 0)
end

function player.load()
    player.x = 640
    player.y = 360
    player.z = 0
    player.vz = 0
    player.gravity = -1400
    player.jumpForce = 520
    player.onGround = true

    player.jumpBuffer = 0
    player.jumpBufferTime = 0.12

    player.scale = 4

    player.vx = 0
    player.vy = 0
    player.accel = 1200
    player.friction = 800
    player.maxSpeed = 200

    player.isDashing = false
    player.dashTimer = 0
    player.dashDuration = 0.15
    player.dashSpeed = 800
    player.dashCooldown = 0.5
    player.dashCooldownTimer = 0
    player.dashDirX = 0
    player.dashDirY = 0

    player.bodySprite = love.graphics.newImage("libresprite stuff . sprites/only body.edited.edited.png")
    player.headSprite = love.graphics.newImage("libresprite stuff . sprites/only head.edited.png")

    player.frameWidth = player.bodySprite:getWidth() / 4
    player.frameHeight = player.bodySprite:getHeight() / 4

    player.currentAnimation = "down"
    player.frame = 1
    player.timer = 0
    player.animationSpeed = 0.1
    player.wasMoving = false
    player.turnCooldown = 0

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
        player.timer = 0
    end
end

function player.keypressed(key, scancode)
    if scancode == "lshift" then
        if not player.isDashing and player.dashCooldownTimer <= 0 then
            player.performDash()
        end
    end

    if scancode == "space" then
        player.jumpBuffer = player.jumpBufferTime
    end
end

function player.update(dt)
    if player.dashCooldownTimer > 0 then
        player.dashCooldownTimer = math.max(0, player.dashCooldownTimer - dt)
    end

    player.turnCooldown = math.max(0, player.turnCooldown - dt)
    player.jumpBuffer = math.max(0, player.jumpBuffer - dt)

    if player.isDashing then
        player.timer = player.timer + dt
        if player.timer > 0.05 then
            player.timer = 0
            if player.frame == 2 then
                player.frame = 4
            else
                player.frame = 2
            end
        end

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

        player.vx = player.vx + moveX * player.accel * dt
        player.vy = player.vy + moveY * player.accel * dt

        local speed = math.sqrt(player.vx^2 + player.vy^2)
        if speed > player.maxSpeed then
            player.vx = (player.vx / speed) * player.maxSpeed
            player.vy = (player.vy / speed) * player.maxSpeed
        end

        local newDir = player.currentAnimation

        if moveY < 0 then
            newDir = "up"
        elseif moveY > 0 then
            newDir = "down"
        elseif moveX > 0 then
            newDir = "right"
        elseif moveX < 0 then
            newDir = "left"
        end

        if newDir ~= player.currentAnimation and player.turnCooldown <= 0 then
            player.currentAnimation = newDir
            player.frame = 1
            player.timer = 0
            player.turnCooldown = 0.08
        end
    else
        player.vx = player.vx - sign(player.vx) * player.friction * dt
        player.vy = player.vy - sign(player.vy) * player.friction * dt

        if math.abs(player.vx) < 5 then player.vx = 0 end
        if math.abs(player.vy) < 5 then player.vy = 0 end
    end

    player.x = player.x + player.vx * dt
    player.y = player.y + player.vy * dt

    if player.jumpBuffer > 0 and player.onGround then
        player.vz = player.jumpForce
        player.onGround = false
        player.jumpBuffer = 0
    end

    player.vz = player.vz + player.gravity * dt
    player.z = player.z + player.vz * dt

    if player.z <= 0 then
        player.z = 0
        player.vz = 0
        if not player.onGround then
            player.frame = 1
            player.timer = 0
        end
        player.onGround = true
    end

    if not player.onGround then
        player.frame = 2
        player.timer = 0
    elseif moving then
        if not player.wasMoving then
            player.frame = 2
            player.timer = 0
        end

        player.timer = player.timer + dt
        if player.timer >= player.animationSpeed then
            player.timer = 0
            player.frame = (player.frame % 4) + 1
        end
    else
        player.frame = 1
        player.timer = 0
    end

    player.wasMoving = moving
end

function player.draw()
    local bodyQuad = player.bodyAnims[player.currentAnimation][player.frame]
    local headQuad = player.headAnims[player.currentAnimation][player.frame]

    local drawX = math.floor(player.x / player.scale + 0.5) * player.scale
    local drawY = math.floor((player.y - player.z) / player.scale + 0.5) * player.scale

    local originX = player.frameWidth / 2
    local originY = player.frameHeight / 2

    love.graphics.draw(player.bodySprite, bodyQuad, drawX, drawY, 0, player.scale, player.scale, originX, originY)
    love.graphics.draw(player.headSprite, headQuad, drawX, drawY, 0, player.scale, player.scale, originX, originY)
end

return player
