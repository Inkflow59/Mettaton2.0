screenWidth = 640
screenHeight = 480

yellowBullets = {}
shootCool = 0
bullets = {}
timelessBullets = {}
arenaMask = CreateProjectileAbs("Shooter/ArenaMask", screenWidth / 2, 103)
fakeArena = CreateProjectileAbs("Shooter/FakeArena", screenWidth / 2, screenHeight / 2)
upArrow = CreateProjectileAbs("Shooter/UpArrow", screenWidth / 2, screenHeight / 2 + 30)
downArrow = CreateProjectileAbs("Shooter/DownArrow", screenWidth / 2, screenHeight / 2 - 30)
leftArrow = CreateProjectileAbs("Shooter/LeftArrow", screenWidth / 2 - 30, screenHeight / 2)
rightArrow = CreateProjectileAbs("Shooter/RightArrow", screenWidth / 2 + 30, screenHeight / 2)
arenaMask.sprite.alpha = 0
fakeArena.sprite.alpha = 0
upArrow.sprite.alpha = 0
downArrow.sprite.alpha = 0
leftArrow.sprite.alpha = 0
rightArrow.sprite.alpha = 0
laserOverlay = CreateProjectileAbs("Mettaton/MettatonNeoCannonLaser", 0, 0)
laserOverlay.sprite.SetPivot(1, 0)
streamBlocks = false
shooter = false
streamLightning = false

enemy = Encounter.GetVar("enemies")[1]

function EnableShooter()
    shooter = true
    Player.SetControlOverride(true)
    Player.MoveToAbs(320, 240, true)
    arenaMask.sprite.alpha = 1
    fakeArena.sprite.alpha = 1
    upArrow.sprite.alpha = 1
    downArrow.sprite.alpha = 1
    leftArrow.sprite.alpha = 1
    rightArrow.sprite.alpha = 1
end

function Empty(bullet)
end

arenaMask.SetVar("hitPlayer", Empty)
fakeArena.SetVar("hitPlayer", Empty)
upArrow.SetVar("hitPlayer", Empty)
downArrow.SetVar("hitPlayer", Empty)
leftArrow.SetVar("hitPlayer", Empty)
rightArrow.SetVar("hitPlayer", Empty)

function FalseFunc(bullet)
    return false
end

function FalseFunc2(time, bullet)
    return false
end

function TimeMult()
    if Time.mult > 2 then
        return 2
    else
        return Time.mult
    end
end

function BattleUpdate(time)
    if shootCool > 0 then
        shootCool = shootCool - TimeMult()
    end
    if shooter then
        if Input.Up == 1 then
            Player.sprite.rotation = 180
        elseif Input.Down == 1 then
            Player.sprite.rotation = 0
        elseif Input.Left == 1 then
            Player.sprite.rotation = 270
        elseif Input.Right == 1 then
            Player.sprite.rotation = 90
        end
        upArrow.sprite.color = {0.5, 0.5, 0.5}
        downArrow.sprite.color = {0.5, 0.5, 0.5}
        leftArrow.sprite.color = {0.5, 0.5, 0.5}
        rightArrow.sprite.color = {0.5, 0.5, 0.5}
        if Player.sprite.rotation == 180 then
            upArrow.sprite.color = {0.9, 0.9, 0.9}
        elseif Player.sprite.rotation == 0 then
            downArrow.sprite.color = {0.9, 0.9, 0.9}
        elseif Player.sprite.rotation == 270 then
            leftArrow.sprite.color = {0.9, 0.9, 0.9}
        elseif Player.sprite.rotation == 90 then
            rightArrow.sprite.color = {0.9, 0.9, 0.9}
        end
    end
    if Input.Confirm == 1 and (shootCool <= 0 or #yellowBullets == 0) then
        table.insert(yellowBullets, CreateYellowBullet())
        Audio.PlaySound("snd_heartshot")
        shootCool = 20
    end
    for i = #yellowBullets, 1, -1 do
        if UpdateYellowBullet(time, yellowBullets[i]) then
            yellowBullets[i].Remove()
            table.remove(yellowBullets, i)
        end
    end
    enemy.Call("ResetLaserLength")
    for i = #bullets, 1, -1 do
        local bullet = bullets[i]
        local nextPos = bullet.GetVar("posFunc")(time)
        bullet.MoveTo(nextPos[1], nextPos[2])
        if bullet.GetVar("updateFunc")(time, bullet) then
            bullet.Remove()
            table.remove(bullets, i)
        end
    end
    for i = #timelessBullets, 1, -1 do
        local bullet = timelessBullets[i]
        if bullet.GetVar("updateFunc")(bullet) then
            bullet.Remove()
            table.remove(timelessBullets, i)
        end
    end
    laserOverlay.sprite.Set("Mettaton/MettatonNeoCannonLaser") --because bullet scales are currently bugged in Unitale
    local laserPos = enemy.Call("CalcLaserPos")
    laserOverlay.MoveToAbs(laserPos[1], laserPos[2])
    local cannonSprite = enemy.GetVar("neoCannon")
    local laserSprite = enemy.GetVar("neoCannonLaser")
    laserOverlay.sprite.alpha = laserSprite.alpha
    laserOverlay.sprite.rotation = cannonSprite.rotation
    laserOverlay.sprite.xscale = laserSprite.xscale
end

function CreateYellowBullet()
    local bullet = CreateProjectile("YellowBullet/YellowBullet1", Player.x, Player.y)
    bullet.SetVar("hitPlayer", Empty)
    bullet.SetVar("name", "yellowBullet")
    if Player.sprite.rotation == 180 then
        bullet.SetVar("speedX", 0)
        bullet.SetVar("speedY", 10)
    elseif Player.sprite.rotation == 0 then
        bullet.SetVar("speedX", 0)
        bullet.SetVar("speedY", -10)
    elseif Player.sprite.rotation == 90 then
        bullet.SetVar("speedX", 10)
        bullet.SetVar("speedY", 0)
    elseif Player.sprite.rotation == 270 then
        bullet.SetVar("speedX", -10)
        bullet.SetVar("speedY", 0)
    end
    bullet.sprite.rotation = (Player.sprite.rotation + 180) % 360
    bullet.SetVar("frame", 1)
    return bullet
end

function UpdateYellowBullet(time, bullet)
    bullet.Move(bullet.GetVar("speedX") * TimeMult(), bullet.GetVar("speedY") * TimeMult())
    local frame = bullet.GetVar("frame")
    if frame < 10 then
        frame = frame + 1
        bullet.SetVar("frame", frame)
        bullet.sprite.Set("YellowBullet/YellowBullet" .. frame)
    end
    for i = #bullets, 1, -1 do
        local other = bullets[i]
        if BulletOnScreen(other) and YellowBulletCollides(bullet, other) then
            local flag = other.GetVar("blockShot")
            if other.GetVar("shotFunc")(time, other) then
                other.Remove()
                table.remove(bullets, i)
            end
            if flag then
                return true
            end
        end
    end
    return not BulletOnScreen(bullet)
end

function YellowBulletCollides(yellowBullet, bullet)
    local x1 = yellowBullet.x
    local y1 = yellowBullet.y
    local w1 = yellowBullet.sprite.width * 0.5
    local h1 = yellowBullet.sprite.height * 0.5
    if yellowBullet.sprite.rotation == 90 or yellowBullet.sprite.rotation == 270 then
        w1, h1 = h1, w1
    end
    if yellowBullet.GetVar("speedX") < 0 then
        x1 = x1 - w1
    end
    if yellowBullet.GetVar("speedY") < 0 then
        y1 = y1 - h1
    end
    local x2 = bullet.x - bullet.sprite.width * 0.5
    local y2 = bullet.y - bullet.sprite.height * 0.5
    local w2 = bullet.sprite.width
    local h2 = bullet.sprite.height
    return x1 + w1 >= x2 and x1 <= x2 + w2 and y1 + h1 >= y2 and y1 <= y2 + h2
end

function Collides(bullet1, bullet2)
    local x1 = bullet1.x - bullet1.sprite.width * 0.5
    local y1 = bullet1.y - bullet1.sprite.height * 0.5
    local w1 = bullet1.sprite.width
    local h1 = bullet1.sprite.height
    local x2 = bullet2.x - bullet2.sprite.width * 0.5
    local y2 = bullet2.y - bullet2.sprite.height * 0.5
    local w2 = bullet2.sprite.width
    local h2 = bullet2.sprite.height
    return x1 + w1 >= x2 and x1 <= x2 + w2 and y1 + h1 >= y2 and y1 <= y2 + h2
end

function OnScreen(x, y)
    return x >= 0 and x <= screenWidth and y >= 0 and y <= screenHeight
end

function BulletOnScreen(bullet)
    return bullet.absx + bullet.sprite.width / 2 >= 0 and bullet.absx - bullet.sprite.width / 2 <= screenWidth and bullet.absy + bullet.sprite.height / 2 >= 0 and bullet.absy - bullet.sprite.height / 2 <= screenHeight
end

function YellowBulletOnScreen(bullet)
    local w = bullet.sprite.width / 2
    local h = bullet.sprite.height / 2
    if bullet.sprite.rotation == 90 or bullet.sprite.rotation == 270 then
        w, h = h, w
    end
    return bullet.absx + w >= 0 and bullet.absx - w <= screenWidth and bullet.absy + h >= 0 and bullet.absy - h <= screenHeight
end

function CreateBox(time, posFunc)
    local startPos = posFunc(time)
    local bullet = CreateProjectile("Box/Box", startPos[1], startPos[2])
    bullet.SetVar("hitPlayer", BoxHitPlayer)
    bullet.SetVar("name", "box")
    bullet.SetVar("posFunc", posFunc)
    bullet.SetVar("updateFunc", UpdateBox)
    bullet.SetVar("blockShot", true)
    bullet.SetVar("shotFunc", DestroyBox)
    bullet.SetVar("destroy", false)
    table.insert(bullets, bullet)
    return bullet
end

function UpdateBox(time, bullet)
    return bullet.GetVar("destroy")
end

function DestroyBox(time, bullet)
    Audio.PlaySound("snd_mtt_burst")
    CreateBoxPart(bullet.x, bullet.y, 0)
    CreateBoxPart(bullet.x, bullet.y, 90)
    CreateBoxPart(bullet.x, bullet.y, 180)
    CreateBoxPart(bullet.x, bullet.y, 270)
    return true
end

function BoxHitPlayer(bullet)
    if shooter then
        bullet.SetVar("destroy", true)
    end
    DamageFunc(9)(bullet)
end

function CreateBoxPart(x, y, rotation)
    local bullet = CreateProjectile("Box/BoxPart", x, y)
    bullet.sprite.rotation = rotation
    bullet.SetVar("hitPlayer", Empty)
    bullet.SetVar("name", "boxPart")
    bullet.SetVar("dx", (rotation == 0 or rotation == 90) and -1 or 1)
    bullet.SetVar("dy", (rotation == 0 or rotation == 270) and 1 or -1)
    bullet.SetVar("updateFunc", UpdateBoxPart)
    table.insert(timelessBullets, bullet)
    return bullet
end

function UpdateBoxPart(bullet)
    bullet.Move(bullet.GetVar("dx"), bullet.GetVar("dy"))
    bullet.sprite.alpha = bullet.sprite.alpha - 0.08
    return bullet.sprite.alpha <= 0
end

function CreateBoxLarge(time, posFunc)
    local startPos = posFunc(time)
    local bullet = CreateProjectile("Box/BoxLarge", startPos[1], startPos[2])
    bullet.SetVar("hitPlayer", LargeBoxHitPlayer)
    bullet.SetVar("name", "box")
    bullet.SetVar("cracked", false)
    bullet.SetVar("posFunc", posFunc)
    bullet.SetVar("updateFunc", UpdateLargeBox)
    bullet.SetVar("blockShot", true)
    bullet.SetVar("shotFunc", DestroyLargeBox)
    bullet.SetVar("destroy", false)
    table.insert(bullets, bullet)
    return bullet
end

function UpdateLargeBox(time, bullet)
    return bullet.GetVar("destroy")
end

function DestroyLargeBox(time, bullet)
    Audio.PlaySound("snd_mtt_burst")
    if bullet.GetVar("cracked") then
        local dx = bullet.sprite.width * 0.25
        local dy = bullet.sprite.height * 0.25
        local innerFunc = bullet.GetVar("posFunc")
        CreateBox(time, OffsetFunc(innerFunc, -dx, dy))
        CreateBox(time, OffsetFunc(innerFunc, dx, dy))
        CreateBox(time, OffsetFunc(innerFunc, -dx, -dy))
        CreateBox(time, OffsetFunc(innerFunc, dx, -dy))
        return true
    else
        bullet.SetVar("cracked", true)
        bullet.sprite.Set("Box/BoxLargeCracked")
        return false
    end
end

function LargeBoxHitPlayer(bullet)
    if shooter then
        bullet.SetVar("destroy", true)
    end
    DamageFunc(12)(bullet)
end

function CreateMiniMetta(time, shootDelay, posFunc)
    if shootDelay < 39 then
        shootDelay = 39
    end
    local startPos = posFunc(time)
    local bullet = CreateProjectile("MiniMetta/MiniMetta1", startPos[1], startPos[2])
    bullet.SetVar("hitPlayer", DamageFunc(9))
    bullet.SetVar("name", "miniMetta")
    bullet.SetVar("posFunc", posFunc)
    bullet.SetVar("updateFunc", UpdateMiniMetta)
    bullet.SetVar("blockShot", true)
    bullet.SetVar("shotFunc", DestroyMiniMetta)
    bullet.SetVar("shootDelay", shootDelay)
    bullet.SetVar("shootOffset", 0)
    bullet.SetVar("startTime", time)
    bullet.SetVar("lastShoot", 0)
    table.insert(bullets, bullet)
    return bullet
end

function UpdateMiniMetta(time, bullet)
    local shootTimer = time - bullet.GetVar("startTime") + bullet.GetVar("shootOffset")
    local shootDelay = bullet.GetVar("shootDelay")
    local startShoot = shootDelay - 39
    local shootProgress = shootTimer % shootDelay - startShoot
    local shootFrame = shootTimer - (shootTimer % shootDelay)
    local doShoot = startShoot + 23
    local frame = 1
    if shootProgress > 0 then
        if shootProgress <= 2 then
            frame = 1
        elseif shootProgress <= 4 then
            frame = 2
        elseif shootProgress <= 6 then
            frame = 3
        elseif shootProgress <= 8 then
            frame = 4
        elseif shootProgress <= 10 then
            frame = 5
        elseif shootProgress <= 14 then
            frame = 6
        elseif shootProgress <= 16 then
            frame = 7
        elseif shootProgress <= 18 then
            frame = 6
        elseif shootProgress <= 22 then
            frame = 7
        elseif shootProgress <= 26 then
            frame = 8
        elseif shootProgress <= 30 then
            frame = 9
        elseif shootProgress <= 34 then
            frame = 10
        elseif shootProgress <= 38 then
            frame = 11
        end
    end
    bullet.sprite.Set("MiniMetta/MiniMetta" .. frame)
    if shootTimer >= bullet.GetVar("lastShoot") + doShoot then
        if BulletOnScreen(bullet) then
            CreateHeart(time, bullet.x, bullet.y, Player.x - bullet.x, Player.y - bullet.y)
        end
        bullet.SetVar("lastShoot", shootFrame + shootDelay)
    end
    return false
end

function DestroyMiniMetta(time, bullet)
    Audio.PlaySound("snd_mtt_burst")
    CreateMiniMettaPart(bullet.x, bullet.y, 1)
    CreateMiniMettaPart(bullet.x, bullet.y, 2)
    CreateMiniMettaPart(bullet.x, bullet.y, 3)
    return true
end

function CreateMiniMettaPart(x, y, id)
    local bullet = CreateProjectile("MiniMetta/MiniMettaPart" .. id, x, y)
    bullet.SetVar("hitPlayer", Empty)
    bullet.SetVar("name", "miniMettaPart")
    if id == 1 then
        bullet.SetVar("dx", -1)
        bullet.SetVar("dy", 0)
    elseif id == 2 then
        bullet.SetVar("dx", 1)
        bullet.SetVar("dy", 0)
    else
        bullet.SetVar("dx", 0)
        bullet.SetVar("dy", 1)
    end
    bullet.SetVar("updateFunc", UpdateMiniMettaPart)
    table.insert(timelessBullets, bullet)
    return bullet
end

function UpdateMiniMettaPart(bullet)
    bullet.Move(bullet.GetVar("dx"), bullet.GetVar("dy"))
    bullet.sprite.alpha = bullet.sprite.alpha - 0.08
    return bullet.sprite.alpha <= 0
end

function CreateHeart(time, x, y, dx, dy)
    if dx == 0 and dy == 0 then
        dy = -1
    end
    local speed = math.sqrt(dx * dx + dy * dy)
    dx = dx * 2 / speed
    dy = dy * 2 / speed
    local bullet = CreateProjectile("MiniMetta/Heart", x, y)
    bullet.SetVar("hitPlayer", DamageFunc(9))
    bullet.SetVar("name", "heart")
    bullet.SetVar("posFunc", LineFunc(time, x, y, dx, dy))
    bullet.SetVar("updateFunc", UpdateHeart)
    bullet.SetVar("blockShot", false)
    bullet.SetVar("shotFunc", FalseFunc2)
    bullet.SetVar("startTime", time)
    bullet.sprite.Scale(0, 0)
    table.insert(bullets, bullet)
    return bullet
end

function UpdateHeart(time, bullet)
    local deltaT = time - bullet.GetVar("startTime")
    bullet.sprite.rotation = 10 * math.sin(deltaT / 10)
    local scale = deltaT * 0.03
    if scale > 1 then
        scale = 1
    elseif scale < 0 then
        scale = 0
    end
    scale = scale * (1 + 0.1 * math.abs(math.sin(deltaT / 10)))
    bullet.sprite.Set("MiniMetta/Heart") -- because bullet scales are currently bugged in Unitale
    bullet.sprite.Scale(scale, scale)
    return false
end

function CreateMegaMetta(time, shootDelay, posFunc, mustDestroy)
    if shootDelay < 25 then
        shootDelay = 25
    end
    local startPos = posFunc(time)
    local bullet = CreateProjectile("MiniMetta/MegaMetta1", startPos[1], startPos[2])
    bullet.SetVar("hitPlayer", DamageFunc(12))
    bullet.SetVar("name", "megaMetta")
    bullet.SetVar("cracked", false)
    bullet.SetVar("posFunc", posFunc)
    bullet.SetVar("updateFunc", UpdateMegaMetta)
    bullet.SetVar("blockShot", true)
    bullet.SetVar("shotFunc", DestroyMegaMetta)
    bullet.SetVar("mustDestroy", mustDestroy)
    bullet.SetVar("shootDelay", shootDelay)
    bullet.SetVar("shootOffset", 0)
    bullet.SetVar("startTime", time)
    bullet.SetVar("lastShoot", 0)
    table.insert(bullets, bullet)
    return bullet
end

function UpdateMegaMetta(time, bullet)
    local shootTimer = time - bullet.GetVar("startTime") + bullet.GetVar("shootOffset")
    local shootDelay = bullet.GetVar("shootDelay")
    local startShoot = shootDelay - 25
    local shootProgress = shootTimer % shootDelay - startShoot
    local shootFrame = shootTimer - (shootTimer % shootDelay)
    local doShoot = startShoot + 23
    local frame = 1
    if shootProgress > 0 then
        if shootProgress <= 2 then
            frame = 1
        elseif shootProgress <= 4 then
            frame = 2
        elseif shootProgress <= 6 then
            frame = 3
        elseif shootProgress <= 8 then
            frame = 4
        elseif shootProgress <= 10 then
            frame = 1
        elseif shootProgress <= 12 then
            frame = 2
        elseif shootProgress <= 14 then
            frame = 3
        elseif shootProgress <= 16 then
            frame = 4
        elseif shootProgress <= 18 then
            frame = 1
        elseif shootProgress <= 20 then
            frame = 2
        elseif shootProgress <= 22 then
            frame = 3
        elseif shootProgress <= 24 then
            frame = 4
        end
    end
    bullet.sprite.Set("MiniMetta/MegaMetta" .. frame)
    if shootTimer >= bullet.GetVar("lastShoot") + doShoot then
        if BulletOnScreen(bullet) then
            local offsetX = Player.x - bullet.x
            local offsetY = Player.y - bullet.y
            if offsetX == 0 and offsetY == 0 then
                offsetY = -1
            end
            local distance = math.sqrt(offsetX * offsetX + offsetY * offsetY)
            offsetX = offsetX / distance
            offsetY = offsetY / distance
            normalX = -offsetY
            normalY = offsetX
            local speedX = 4 * offsetX
            local speedY = 4 * offsetY
            local spawnX = bullet.x + 8 * offsetX
            local spawnY = bullet.y + 8 * offsetY
            CreateLightning(time, LineFunc(time, spawnX, spawnY, speedX, speedY), true)
            CreateLightning(time, LineFunc(time, spawnX + 16 * (normalX - offsetX), spawnY + 16 * (normalY - offsetY), speedX, speedY), true)
            CreateLightning(time, LineFunc(time, spawnX + 16 * (-normalX - offsetX), spawnY + 16 * (-normalY - offsetY), speedX, speedY), true)
        end
        bullet.SetVar("lastShoot", shootFrame + shootDelay)
    end
    return false
end

function DestroyMegaMetta(time, bullet)
    Audio.PlaySound("snd_mtt_burst")
    if bullet.GetVar("cracked") then
        local dx = bullet.sprite.width * 0.25
        local dy = bullet.sprite.height * 0.25
        local innerFunc = bullet.GetVar("posFunc")
        local mustDestroy = bullet.GetVar("mustDestroy")
        local shootDelay = bullet.GetVar("shootDelay")
        local bullet1 = CreateMiniMetta(time, shootDelay, OffsetFunc(innerFunc, -dx, dy))
        local bullet2 = CreateMiniMetta(time, shootDelay, OffsetFunc(innerFunc, dx, dy))
        bullet2.SetVar("shootOffset", shootDelay * 0.25)
        local bullet3 = CreateMiniMetta(time, shootDelay, OffsetFunc(innerFunc, -dx, -dy))
        bullet3.SetVar("shootOffset", shootDelay * 0.5)
        local bullet4 = CreateMiniMetta(time, shootDelay, OffsetFunc(innerFunc, dx, -dy))
        bullet4.SetVar("shootOffset", shootDelay * 0.75)
        if mustDestroy then
            table.insert(mustDestroy, bullet1)
            table.insert(mustDestroy, bullet2)
            table.insert(mustDestroy, bullet3)
            table.insert(mustDestroy, bullet4)
        end
        return true
    else
        bullet.SetVar("cracked", true)
        bullet.sprite.color = {1.0, 0.9, 0.9}
        return false
    end
end

function CreateLightning(time, posFunc, doScale)
    local startPos = posFunc(time)
    local bullet = CreateProjectile("Lightning", startPos[1], startPos[2])
    bullet.SetVar("hitPlayer", DamageFunc(8))
    bullet.SetVar("name", "lightning")
    bullet.SetVar("posFunc", posFunc)
    bullet.SetVar("updateFunc", UpdateLightning)
    bullet.SetVar("blockShot", false)
    bullet.SetVar("shotFunc", FalseFunc2)
    bullet.SetVar("startTime", doScale and time or -600)
    table.insert(bullets, bullet)
    return bullet
end

function UpdateLightning(time, bullet)
    local scale = (time - bullet.GetVar("startTime")) * 0.1
    if scale > 1 then
        scale = 1
    elseif scale < 0 then
        scale = 0
    end
    bullet.sprite.Set("Lightning")
    bullet.sprite.xscale = scale
    bullet.sprite.yscale = scale
    return streamLightning and not BulletOnScreen(bullet)
end

function CreateBlock(time, posFunc)
    local startPos = posFunc(time)
    local bullet = CreateProjectile("Bomb/Block", startPos[1], startPos[2])
    bullet.SetVar("hitPlayer", DamageFunc(9))
    bullet.SetVar("name", "block")
    bullet.SetVar("posFunc", posFunc)
    bullet.SetVar("updateFunc", UpdateBlock)
    bullet.SetVar("blockShot", true)
    bullet.SetVar("shotFunc", FalseFunc2)
    bullet.SetVar("destroy", false)
    table.insert(bullets, bullet)
    return bullet
end

function UpdateBlock(time, bullet)
    if streamBlocks and not BulletOnScreen(bullet) then
        return true
    end
    if bullet.sprite.xscale < 1 then
        bullet.sprite.Set("Bomb/Block")
        bullet.sprite.xscale = bullet.sprite.xscale + 0.05
        bullet.sprite.yscale = bullet.sprite.yscale + 0.05
        if bullet.sprite.xscale > 1 then
            bullet.sprite.xscale = 1
        end
        if bullet.sprite.yscale > 1 then
            bullet.sprite.yscale = 1
        end
    end
    if enemy.Call("IsLaserOn") and enemy.Call("LaserHitsBullet", bullet) then
        enemy.Call("BlockLaser", bullet)
    end
    return bullet.GetVar("destroy")
end

function CreateBlockPortal(time, x, y, dx, dy, interval)
    local bullet = CreateProjectile("Bomb/BlockPortal", x, y)
    bullet.SetVar("hitPlayer", Empty)
    bullet.SetVar("name", "blockPortal")
    bullet.SetVar("posFunc", NoMoveFunc(x, y))
    bullet.SetVar("updateFunc", UpdateBlockPortal)
    bullet.SetVar("blockShot", false)
    bullet.SetVar("shotFunc", FalseFunc2)
    bullet.SetVar("dx", dx)
    bullet.SetVar("dy", dy)
    bullet.SetVar("interval", interval)
    bullet.SetVar("numBlocks", 0)
    table.insert(bullets, bullet)
    return bullet
end

function UpdateBlockPortal(time, bullet)
    local numBlocks = bullet.GetVar("numBlocks")
    local interval = bullet.GetVar("interval")
    while time >= numBlocks * interval do
        local blockTime = interval * numBlocks
        local block = CreateBlock(blockTime, LineFunc(blockTime, bullet.x, bullet.y, bullet.GetVar("dx"), bullet.GetVar("dy")))
        block.sprite.xscale = 0
        block.sprite.yscale = 0
        numBlocks = numBlocks + 1
        bullet.SetVar("numBlocks", numBlocks)
    end
    return false
end

function CreateBomb(time, posFunc)
    posFunc = OffsetFunc(posFunc, 0, 3)
    local startPos = posFunc(time)
    local bullet = CreateProjectile("Bomb/PlusBomb1", startPos[1], startPos[2])
    bullet.SetVar("hitPlayer", DamageFunc(9))
    bullet.SetVar("name", "bomb")
    bullet.SetVar("posFunc", posFunc)
    bullet.SetVar("updateFunc", UpdateBomb)
    bullet.SetVar("blockShot", true)
    bullet.SetVar("shotFunc", DestroyBomb)
    bullet.SetVar("fuse", false)
    bullet.SetVar("fuseTime", 0)
    table.insert(bullets, bullet)
    return bullet
end

function UpdateBomb(time, bullet)
    if bullet.GetVar("fuse") then
        local fuseTime = bullet.GetVar("fuseTime")
        fuseTime = fuseTime + 1
        local frame = 1
        if fuseTime <= 3 then
            frame = 2
        elseif fuseTime <= 6 then
            frame = 1
        elseif fuseTime <= 9 then
            frame = 2
        elseif fuseTime <= 12 then
            frame = 1
        else
            Audio.PlaySound("snd_bomb")
            CreateExplode(bullet.absx, bullet.absy - 3)
            return true
        end
        if fuseTime == 1 or fuseTime == 7 then
            Audio.PlaySound("snd_mtt_prebomb")
        end
        bullet.sprite.Set("Bomb/PlusBomb" .. frame)
        bullet.SetVar("fuseTime", fuseTime)
    end
    return false
end

function DestroyBomb(time, bullet)
    bullet.SetVar("blockShot", false)
    bullet.SetVar("fuse", true)
    return false
end

function CreateExplode(x, y)
    local center = CreateExplodeHelper(x, y, "Center")
    for x2 = x - 24, -24, -24 do
        CreateExplodeHelper(x2, y, "Hor")
    end
    for x2 = x + 24, 640 + 24, 24 do
        CreateExplodeHelper(x2, y, "Hor")
    end
    for y2 = y - 24, -24, -24 do
        CreateExplodeHelper(x, y2, "Ver")
    end
    for y2 = y + 24, 480 + 24, 24 do
        CreateExplodeHelper(x, y2, "Ver")
    end
    for i = #bullets, 1, -1 do
        local other = bullets[i]
        if other.GetVar("name") == "block" and math.abs(other.absy - y) <= 20 then
            other.SetVar("destroy", true)
        end
    end
    return center
end

function CreateExplodeHelper(x, y, dir)
    local bullet = CreateProjectileAbs("Bomb/Explode" .. dir .. 1, x, y)
    bullet.SetVar("hitPlayer", ExplodeDamageFunc)
    bullet.SetVar("name", "explode")
    bullet.SetVar("updateFunc", UpdateExplode)
    bullet.SetVar("dir", dir)
    bullet.SetVar("frame", 0)
    bullet.SetVar("switchFrame", false)
    table.insert(timelessBullets, bullet)
    return bullet
end

function UpdateExplode(bullet)
    if bullet.GetVar("switchFrame") then
        local frame = bullet.GetVar("frame")
        frame = frame + 1
        if frame > 7 then
            return true
        end
        bullet.sprite.Set("Bomb/Explode" .. bullet.GetVar("dir") .. frame)
        bullet.SetVar("frame", frame)
        bullet.SetVar("switchFrame", false)
    else
        bullet.SetVar("switchFrame", true)
    end
    return false
end

function ExplodeDamageFunc(bullet)
    if bullet.GetVar("frame") <= 3 then
        DamageFunc(12)(bullet)
    end
end

function CreateTimeBomb(time, timeLeft, posFunc)
    posFunc = OffsetFunc(posFunc, 0, 3)
    local startPos = posFunc(time)
    local bullet = CreateProjectile("Bomb/TimeBomb1", startPos[1], startPos[2])
    bullet.SetVar("hitPlayer", DamageFunc(9))
    bullet.SetVar("name", "timeBomb")
    bullet.SetVar("posFunc", posFunc)
    bullet.SetVar("updateFunc", UpdateTimeBomb)
    bullet.SetVar("blockShot", true)
    bullet.SetVar("shotFunc", DestroyTimeBomb)
    bullet.SetVar("timeLeft", timeLeft - 12)
    bullet.SetVar("numSounds", 0)
    table.insert(bullets, bullet)
    return bullet
end

function UpdateTimeBomb(time, bullet)
    local timeLeft = bullet.GetVar("timeLeft") - TimeMult()
    bullet.SetVar("timeLeft", timeLeft)
    local frame = 1
    if timeLeft <= 0 then
        frame = 11
    elseif timeLeft <= 60 then
        frame = 10
    elseif timeLeft <= 120 then
        frame = 9
    elseif timeLeft <= 180 then
        frame = 8
    elseif timeLeft <= 240 then
        frame = 7
    elseif timeLeft <= 300 then
        frame = 6
    elseif timeLeft <= 360 then
        frame = 5
    elseif timeLeft <= 420 then
        frame = 4
    elseif timeLeft <= 480 then
        frame = 3
    elseif timeLeft <= 540 then
        frame = 2
    else
        frame = 1
    end
    bullet.sprite.Set("Bomb/TimeBomb" .. frame)
    if timeLeft <= 0 and bullet.GetVar("numSounds") <= 0 then
        Audio.PlaySound("snd_mtt_prebomb")
        bullet.SetVar("numSounds", 1)
    end
    if timeLeft <= -6 and bullet.GetVar("numSounds") <= 1 then
        Audio.PlaySound("snd_mtt_prebomb")
        bullet.SetVar("numSounds", 2)
    end
    if timeLeft <= -12 then
        Audio.PlaySound("snd_bomb")
        CreateExplode(bullet.absx, bullet.absy - 3)
        return true
    end
    return false
end

function DestroyTimeBomb(time, bullet)
    Audio.PlaySound("snd_mtt_burst")
    CreateDefusedTimeBomb(bullet.x, bullet.y)
    return true
end

function CreateDefusedTimeBomb(x, y)
    local bullet = CreateProjectile("Bomb/TimeBombDefused", x, y)
    bullet.SetVar("hitPlayer", Empty)
    bullet.SetVar("name", "timeBombDefused")
    bullet.SetVar("updateFunc", UpdateDefusedTimeBomb)
    table.insert(timelessBullets, bullet)
    return bullet
end

function UpdateDefusedTimeBomb(bullet)
    bullet.sprite.alpha = bullet.sprite.alpha - 0.05
    return bullet.sprite.alpha <= 0
end

function CreateSpeedBullet()
    local bullet = CreateProjectile("Speed/Record", Arena.width / 2, -Arena.height / 2)
    bullet.Move(-bullet.sprite.width / 2 - 4, bullet.sprite.height / 2 + 4)
    bullet.SetVar("hitPlayer", Empty)
    bullet.SetVar("name", "speed")
    bullet.SetVar("updateFunc", UpdateSpeed)
    bullet.SetVar("frame", 0)
    table.insert(timelessBullets, bullet)
    return bullet
end

function UpdateSpeed(bullet)
    local frame = bullet.GetVar("frame") + 1
    if frame > 15 then
        bullet.sprite.alpha = 0
    end
    if frame > 30 then
        bullet.sprite.alpha = 1
        frame = 0
    end
    bullet.SetVar("frame", frame)
    return false
end

function CreateDiscoBall(speed, colors)
    local wire = nil
    local posX = 0
    local posY = Arena.height / 2 - 15
    if shooter then
        posY = Player.y + 100
    else
        wire = CreateProjectile("DiscoBall/DiscoWire1", 0, Arena.height / 2 - 8)
    end
    local bullet = CreateProjectile("DiscoBall/DiscoBall1", posX, posY)
    bullet.SetVar("hitPlayer", DamageFunc(9))
    bullet.SetVar("name", "discoBall")
    bullet.SetVar("posFunc", NoMoveFunc(bullet.x, bullet.y))
    bullet.SetVar("updateFunc", UpdateDiscoBall)
    bullet.SetVar("blockShot", true)
    bullet.SetVar("shotFunc", ShootDiscoBall)
    bullet.SetVar("switch", 0)
    if not shooter then
        wire.SetVar("hitPlayer", DamageFunc(9))
        wire.SetVar("name", "discoWire")
        wire.SetVar("posFunc", NoMoveFunc(wire.x, wire.y))
        wire.SetVar("updateFunc", UpdateDiscoWire)
        wire.SetVar("blockShot", true)
        wire.SetVar("shotFunc", ShootDiscoWire)
        wire.SetVar("switch", 0)
        bullet.SetVar("wire", wire)
        wire.SetVar("ball", bullet)
    else
        bullet.SetVar("wire", nil)
    end
    bullet.SetVar("speed", speed)
    bullet.SetVar("colors", colors)
    bullet.SetVar("colorOffset", 0)
    local lasers =
    {
        CreateProjectile("DiscoBall/DiscoBeam", 0, bullet.y - 10),
        CreateProjectile("DiscoBall/DiscoBeam", 0, bullet.y - 10),
        CreateProjectile("DiscoBall/DiscoBeam", 0, bullet.y - 10),
        CreateProjectile("DiscoBall/DiscoBeam", 0, bullet.y - 10)
    }
    bullet.SetVar("lasers", lasers)
    for i = 1, #lasers do
        lasers[i].sprite.alpha = 0
        lasers[i].SetVar("hitPlayer", Empty)
        lasers[i].sprite.SetPivot(0, 0.5)
    end
    table.insert(bullets, wire)
    table.insert(bullets, bullet)
    return bullet
end

function UpdateDiscoBall(time, bullet)
    if bullet.GetVar("switch") > 0 then
        bullet.SetVar("switch", bullet.GetVar("switch") - 1)
    end
    if bullet.GetVar("switch") <= 0 then
        bullet.sprite.Set("DiscoBall/DiscoBall1")
    end
    local speed = bullet.GetVar("speed")
    local baseRotate = -(time * speed - math.sin(time * speed)) / 4
    local colors = bullet.GetVar("colors")
    local colorOffset = bullet.GetVar("colorOffset")
    local hitPlayer = bullet.GetVar("hitPlayer")
    local lasers = bullet.GetVar("lasers")
    for k = 1, #lasers do
        local laser = lasers[k]
        local rotation = baseRotate + (0.75 + 0.5 * k) * math.pi
        local realRotation = rotation % (2 * math.pi)
        if realRotation < math.pi * 0.1 or realRotation > math.pi * 0.9 then
            laser.sprite.alpha = 1
            laser.sprite.Set("DiscoBall/DiscoBeam")
            local offsetX = math.cos(realRotation)
            local offsetY = math.sin(realRotation)
            local newX = bullet.x + 20 * offsetX
            local newY = bullet.y - 10 + 20 * offsetY
            laser.MoveTo(newX, newY)
            laser.sprite.rotation = realRotation * 180 / math.pi
            local length = 200
            local useWidth = Arena.width / 2
            local useHeight = Arena.height / 2
            local arenaOffset = 0
            if shooter then
                useWidth = 60
                useHeight = 60
                arenaOffset = bullet.absy - bullet.y + 60 - 16 - 8
            end
            if offsetX > 0 then
                local t = useWidth - newX
                local limit = math.abs(t / math.cos(realRotation))
                if limit < length then
                    length = limit
                end
            elseif offsetX < 0 then
                local t = newX + useWidth
                local limit = math.abs(t / math.cos(realRotation))
                if limit < length then
                    length = limit
                end
            end
            if offsetY > 0 then
                local t = useHeight - (newY - arenaOffset)
                local limit = math.abs(t / math.sin(realRotation))
                if limit < length then
                    length = limit
                end
            elseif offsetY < 0 then
                local t = (newY - arenaOffset) + useHeight
                local limit = math.abs(t / math.sin(realRotation))
                if limit < length then
                    length = limit
                end
            end
            laser.sprite.xscale = length
            local frame = rotation - 0.5 * math.pi
            frame = -math.floor(frame / (2 * math.pi))
            frame = (4 * frame + k - 1) % #colors + 1
            local color = (colors[frame] + colorOffset) % 3
            if color == 0 then
                laser.sprite.color = {0/255, 162/255, 232/255}
            elseif color == 1 then
                laser.sprite.color = {255/255, 154/255, 34/255}
            elseif color == 2 then
                laser.sprite.color = {1, 1, 1}
            end
            local toPlayerX = Player.x - newX
            local toPlayerY = Player.y - newY
            local projection = toPlayerX * offsetX + toPlayerY * offsetY
            local closeX = newX + projection * offsetX
            local closeY = newY + projection * offsetY
            local distX = Player.x - closeX
            local distY = Player.y - closeY
            if math.sqrt(distX * distX + distY * distY) <= 8 then
                if not ((color == 0 and not Player.isMoving) or (color == 1 and Player.isMoving)) then
                    hitPlayer(laser)
                end
            end
        else
            laser.sprite.alpha = 0
        end
    end
    return false
end

function UpdateDiscoWire(time, bullet)
    if bullet.GetVar("switch") > 0 then
        bullet.SetVar("switch", bullet.GetVar("switch") - 1)
    end
    if bullet.GetVar("switch") <= 0 then
        bullet.sprite.Set("DiscoBall/DiscoWire1")
    end
    return false
end

function ShootDiscoBall(time, bullet)
    Audio.PlaySound("discoSwitch")
    bullet.SetVar("switch", 4)
    bullet.SetVar("colorOffset", bullet.GetVar("colorOffset") + 1)
    bullet.sprite.Set("DiscoBall/DiscoBall2")
    local wire = bullet.GetVar("wire")
    if wire then
        wire.SetVar("switch", 4)
        wire.sprite.Set("DiscoBall/DiscoWire2")
    end
    return false
end

function ShootDiscoWire(time, bullet)
    ShootDiscoBall(time, bullet.GetVar("ball"))
    return false
end

function CreateInfiniteBomb(time, posFunc)
    posFunc = OffsetFunc(posFunc, 0, 3)
    local startPos = posFunc(time)
    local bullet = CreateProjectile("Bomb/PlusBomb1", startPos[1], startPos[2])
    bullet.SetVar("hitPlayer", DamageFunc(9))
    bullet.SetVar("name", "infiniteBomb")
    bullet.SetVar("posFunc", posFunc)
    bullet.SetVar("updateFunc", UpdateInfiniteBomb)
    bullet.SetVar("blockShot", true)
    bullet.SetVar("shotFunc", DestroyInfiniteBomb)
    bullet.SetVar("fuse", false)
    bullet.SetVar("fuseTime", 0)
    table.insert(bullets, bullet)
    return bullet
end

function UpdateInfiniteBomb(time, bullet)
    if bullet.GetVar("fuse") then
        local fuseTime = bullet.GetVar("fuseTime")
        fuseTime = fuseTime + 1
        local frame = 1
        if fuseTime <= 3 then
            frame = 2
        elseif fuseTime <= 6 then
            frame = 1
        elseif fuseTime <= 9 then
            frame = 2
        elseif fuseTime <= 12 then
            frame = 1
        else
            Audio.PlaySound("snd_bomb")
            CreateExplode(bullet.absx, bullet.absy - 3)
            frame = 1
            bullet.SetVar("fuse", false)
            fuseTime = 0
        end
        if fuseTime == 1 or fuseTime == 7 then
            Audio.PlaySound("snd_mtt_prebomb")
        end
        bullet.sprite.Set("Bomb/PlusBomb" .. frame)
        bullet.SetVar("fuseTime", fuseTime)
    end
    return false
end

function DestroyInfiniteBomb(time, bullet)
    bullet.SetVar("fuse", true)
    return false
end

function DamageFunc(damage)
    return function(bullet)
        if bullet.sprite.xscale > 0 and bullet.sprite.yscale > 0 then
            local amount = damage + enemy.GetVar("extraAttack")
            if Encounter.GetVar("easyMode") then
                amount = math.floor(amount * 2 / 3)
            end
           Player.Hurt(amount)
        end
    end
end

function LineFunc(time, x, y, dx, dy)
    return function(t)
        return {x + (t - time) * dx, y + (t - time) * dy}
    end
end

function SinFunc(time, x, y, dx, dy, sinTime, period, waveX, waveY)
    return function(t)
        local baseX = x + (t - time) * dx
        local baseY = y + (t - time) * dy
        local offset = math.sin((t - sinTime) * 2.0 * math.pi / period)
        return {baseX + offset * waveX, baseY + offset * waveY}
    end
end

function StopFunc(time, x, y, dx, dy, slowX, slowY, stopX, stopY)
    local slowTime = time
    if x == slowX then
        slowTime = (slowY - y) / dy
    elseif y == slowY then
        slowTime = (slowX - x) / dx
    else
        local slowTimeX = (slowX - x) / dx
        local slowTimeY = (slowY - y) / dy
        slowTime = slowTimeX
    end
    local endTime = time
    if x == stopX then
        endTime = (stopY - y) / dy
    elseif y == stopY then
        endTime = (stopX - x) / dx
    else
        local endTimeX = (stopX - x) / dx
        local endTimeY = (stopY - y) / dy
        endTime = endTimeX
    end
    return function(t)
        if t - time < slowTime then
            return {x + (t - time) * dx, y + (t - time) * dy}
        else
            local fakeTime = t - time - slowTime
            local length = endTime - slowTime
            fakeTime = length * (1 - math.exp(-fakeTime / length))
            return {x + (slowTime + fakeTime) * dx, y + (slowTime + fakeTime) * dy}
        end
    end
end

function NoMoveFunc(x, y)
    return function(t)
        return {x, y}
    end
end

function ShrinkCircleFunc(time, x, y, r, angleStart, angleSpeed, duration)
    return function(t)
        local radius = r
        if t - time < 30 then
            local before = 30 - t + time
            radius = radius + 0.5 * before * before
        elseif t - time > 30 + duration then
            local after = t - time - 30 - duration
            radius = radius - 0.5 * after * after
        end
        local angle = angleStart + angleSpeed * (t - time)
        return {x + radius * math.cos(angle), y + radius * math.sin(angle)}
    end
end

function CircleFunc(time, x, y, r, angleStart, angleSpeed)
    return function(t)
        local angle = angleStart + angleSpeed * (t - time)
        return {x + r * math.cos(angle), y + r * math.sin(angle)}
    end
end

function FollowPlayerYFunc(x)
    return function(t)
        return {x, Player.y}
    end
end

function OffsetFunc(inner, x, y)
    return function(t)
        local innerPos = inner(t)
        return {innerPos[1] + x, innerPos[2] + y}
    end
end
