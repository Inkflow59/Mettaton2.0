require "battle"
streamBlocks = true
streamLightning = true

timer = 0
transformed = false
numCannonShots = 0

heartBullet = nil
heartBaseX = 0
heartBaseY = 224
heartHealth = 16
if Encounter.GetVar("easyMode") then
    heartHealth = 12
end
heartTimer = 0
heartShootTimer = 0
heartShakeTimer = 0
maxHeartShakeTimer = 15
endTimer = 0

function Update()
    if not transformed then
        enemy.Call("Transform", true)
        transformed = true
    end
    if timer == 0 then
        local speed = 1
        for k = 0, 2 do
            CreateBlockPortal(timer, 200 + 24 * k, 12, -speed, 0, 24 / speed * 6)
        end
        heartBullet = CreateProjectile("MettaHeart1", heartBaseX, heartBaseY)
        heartBullet.SetVar("hitPlayer", Empty)
        heartBullet.SetVar("name", "heart")
        heartBullet.SetVar("posFunc", HeartPos)
        heartBullet.SetVar("updateFunc", UpdateHeart)
        heartBullet.SetVar("blockShot", true)
        heartBullet.SetVar("shotFunc", ShootHeart)
        table.insert(bullets, heartBullet)
    end
    if heartHealth > 0 then
        enemy.Call("AimAtPlayer", 0)
        local interval = 180
        if timer >= interval + interval * numCannonShots then
            numCannonShots = numCannonShots + 1
            enemy.Call("FireCannon")
        end
        if timer >= interval + interval * numCannonShots - 60 then
            enemy.Call("StopCannon")
        end
    else
        endTimer = endTimer + 1
        heartBullet.sprite.Set("MettaHeart" .. (math.floor(endTimer / 4) % 2 + 1))
    end
    BattleUpdate(timer)
    if endTimer > 120 then
        enemy.Call("Transform", false)
        enemy.Call("SetHead", "Mettaton/MettatonNeoHead")
        EndWave()
    end
    timer = timer + TimeMult()
end

function UpdateHeart(time, bullet)
    if heartShootTimer > 0 then
        heartShootTimer = heartShootTimer - 1
        if heartShootTimer > 26 then
            bullet.sprite.Set("MettaHeart1")
        elseif heartShootTimer > 22 then
            bullet.sprite.Set("MettaHeart2")
        elseif heartShootTimer > 18 then
            bullet.sprite.Set("MettaHeart1")
        elseif heartShootTimer % 4 == 0 then
            CreateLightning(time, LineFunc(time, bullet.x, bullet.y, 0, -6))
        end
    elseif time > 0 and math.abs(bullet.x - Player.x) <= 16 then
        heartShootTimer = 30
        bullet.sprite.Set("MettaHeart2")
    else
        heartTimer = heartTimer + 0.015 * TimeMult()
    end
    if heartShakeTimer > 0 then
        heartShakeTimer = heartShakeTimer - 1
    end
    return false
end

function HeartPos(t)
    if heartHealth <= 0 then
        local offsetX = heartBaseX - heartBullet.x
        local offsetY = heartBaseY - heartBullet.y
        return {heartBullet.x + 0.2 * offsetX, heartBullet.y + 0.2 * offsetY}
    end
    local theta = heartTimer % (math.pi / 2)
    if theta > math.pi / 4 then
        theta = math.pi / 2 - theta
    end
    local radius = 60 * math.cos(2 * theta)
    local x = radius * math.cos(theta)
    local y = radius * math.sin(theta)
    local periodTimer = heartTimer % math.pi
    if periodTimer > math.pi * 0.25 and periodTimer < math.pi * 0.75 then
        x = x * -1
    end
    if periodTimer > math.pi * 0.25 and periodTimer < math.pi * 0.5 then
        y = y * -1
    elseif periodTimer > math.pi * 0.75 then
        y = y * -1
    end
    if heartShakeTimer > 0 then
        local angle = heartShakeTimer * 4 * math.pi / maxHeartShakeTimer
        x = x + 2 * math.cos(angle)
        y = y + 2 * math.sin(angle)
    end
    return {heartBaseX + x, heartBaseY + y}
end

function ShootHeart(time, bullet)
    heartHealth = heartHealth - 1
    --Audio.PlaySound("hurtSound")
    heartShakeTimer = maxHeartShakeTimer
    if heartHealth <= 0 then
        enemy.Call("StopCannon")
        enemy.Call("ResetAim", 0.5)
        Audio.PlaySound("mus_explosion")
        enemy.Call("SetHead", "Mettaton/MettatonNeoHurt")
        enemy.Call("DestroyWings")
    end
    return false
end

function OnHit(bullet)
    if heartHealth > 0 then
        bullet.GetVar("hitPlayer")(bullet)
    end
end
