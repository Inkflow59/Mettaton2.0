require "battle"
streamLightning = true

timer = 0
transformed = false
interval = 10
numLightnings = 0
numCannonShots = 0

function Update()
    if not transformed then
        enemy.Call("Transform", true)
        transformed = true
    end

    if timer == 0 then
        CreateMegaMetta(timer, 180, FollowPlayerYFunc(-200))
        CreateMegaMetta(timer, 180, FollowPlayerYFunc(200))
    end
    local nextLightning = interval * (numLightnings % 3) + 6 * interval * math.floor(numLightnings / 3)
    if timer >= nextLightning then
        CreateLightning(timer, LineFunc(timer, -320, 0, 2, 0))
        CreateLightning(timer, LineFunc(timer, 320, 48, -2, 0))
        CreateLightning(timer, LineFunc(timer, 320, -48, -2, 0))
        numLightnings = numLightnings + 1
    end
    if timer >= 240 + 240 * numCannonShots then
        numCannonShots = numCannonShots + 1
        enemy.Call("AimAtPlayer", 0.5)
        enemy.Call("FireCannon")
    end
    if timer >= 240 + 240 * numCannonShots - 150 then
        enemy.Call("StopCannon")
    end
    BattleUpdate(timer)
    if timer >= 1440 then
        enemy.Call("Transform", false)
        enemy.Call("StopCannon")
        enemy.Call("ResetAim", 0.5)
        EndWave()
    end
    timer = timer + TimeMult()
end

function OnHit(bullet)
    bullet.GetVar("hitPlayer")(bullet)
end
