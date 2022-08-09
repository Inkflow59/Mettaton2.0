require "battle"
streamBlocks = true

timer = 0
transformed = false
startedCannon = false
speed = 1.5

function Update()
    if not transformed then
        enemy.Call("Transform", true)
        transformed = true
    end
    if timer == 0 then
        for k = 0, 2 do
            CreateBlock(timer, LineFunc(timer, -120 - 36 * k, 120 - 36 * k, 1, 1))
        end
        CreateBlockPortal(timer, -120 - 36 * 3, 120 - 36 * 3, 1, 1, 36)
        local explodeAt = -120
        local y = 96
        CreateTimeBomb(timer, 360 / speed, LineFunc(timer, explodeAt + 360, y, -speed, 0))
        CreateBomb(timer, LineFunc(timer, explodeAt + 450, y, -speed, 0))
        CreateTimeBomb(timer, 540 / speed, LineFunc(timer, explodeAt + 540, y, -speed, 0))
        CreateTimeBomb(timer, 570 / speed, LineFunc(timer, explodeAt + 570, y, -speed, 0))
        CreateTimeBomb(timer, 600 / speed, LineFunc(timer, explodeAt + 600, y, -speed, 0))
        CreateBomb(timer, LineFunc(timer, explodeAt + 690, y, -speed, 0))
        CreateTimeBomb(timer, 720 / speed, LineFunc(timer, explodeAt + 720, y, -speed, 0))
        CreateBomb(timer, LineFunc(timer, explodeAt + 750, y, -speed, 0))
        for x = 840, 1140, 30 do
            if math.random(2) == 1 then
                CreateBomb(timer, LineFunc(timer, explodeAt + x, y, -speed, 0))
            else
                CreateTimeBomb(timer, x / speed, LineFunc(timer, explodeAt + x, y, -speed, 0))
            end
        end
    end
    if timer >= 60 then
        if not startedCannon then
            enemy.Call("FireCannon")
            startedCannon = true
        end
        enemy.Call("AimAtPlayer", 0)
    end
    BattleUpdate(timer)
    if timer >= 900 then
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
