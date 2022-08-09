require "battle"

timer = 0
transformed = false
speedBullet = nil
timerSpeed = 1
realTimer = 0
numCannonShots = 0

function Update()
    if not transformed then
        enemy.Call("Transform", true)
        transformed = true
    end
    if timer == 0 then
        speedBullet = CreateSpeedBullet()
        colors = {0, 0, 0}
        for k = 1, 6 do
            table.insert(colors, math.random(3) - 1)
        end
        CreateDiscoBall(0.1, colors)
    end
    if timer >= 180 and realTimer >= 180 + 180 * numCannonShots then
        numCannonShots = numCannonShots + 1
        enemy.Call("AimAtPlayer", 0.5)
        enemy.Call("FireCannon")
    end
    if realTimer >= 180 + 180 * numCannonShots - 90 then
        enemy.Call("StopCannon")
    end
    BattleUpdate(timer)
    if timer >= 80 * 2 * math.pi then
        speedBullet.sprite.Set("Speed/Rewind")
        timerSpeed = timerSpeed - 0.02
    elseif timerSpeed < 0 then
        timerSpeed = -1
    end
    if timer <= 2 and timerSpeed < 0 then
        enemy.Call("Transform", false)
        enemy.Call("StopCannon")
        enemy.Call("ResetAim", 0.5)
        EndWave()
    end
    timer = timer + TimeMult() * timerSpeed
    realTimer = realTimer + TimeMult()
end

function OnHit(bullet)
    bullet.GetVar("hitPlayer")(bullet)
end
