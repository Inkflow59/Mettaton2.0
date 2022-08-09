require "battle"

timer = 0
transformed = false
spawnedEverything = false
numCannonShots = 0
waveTime = 1230

function Update()
    if timer < waveTime and not transformed then
        enemy.Call("Transform", true)
        transformed = true
    end
    if timer >= 60 and not spawnedEverything then
        for x = -24, 48, 24 do
            CreateBlock(timer, LineFunc(timer, x, 400, 0, -1.5))
        end
        CreateBomb(timer, LineFunc(timer, -48, 400, 0, -1.5))
        for x = -48, 24, 24 do
            CreateBlock(timer, LineFunc(timer, x, 424, 0, -1.5))
        end
        CreateBomb(timer, LineFunc(timer, 48, 424, 0, -1.5))
        for x = -24, 48, 24 do
            CreateBlock(timer, LineFunc(timer, x, 448, 0, -1.5))
        end
        CreateBomb(timer, LineFunc(timer, -48, 448, 0, -1.5))
        for x = -48, 24, 24 do
            CreateBlock(timer, LineFunc(timer, x, 472, 0, -1.5))
        end
        CreateBomb(timer, LineFunc(timer, 48, 472, 0, -1.5))
        for x = -48, 48, 24 do
            CreateBlock(timer, LineFunc(timer, x, 620, 0, -1.5))
        end
        CreateTimeBomb(timer, 400, LineFunc(timer, -72, 620, 0, -1.5))
        CreateTimeBomb(timer, 400, LineFunc(timer, 72, 620, 0, -1.5))
        for x = -48, 48, 24 do
            CreateTimeBomb(timer, 520, StopFunc(timer, x, 770, 0, -1.5, x, 44, x, 20))
        end
        spawnedEverything = true
    end
    if timer >= 640 + 150 * numCannonShots then
        numCannonShots = numCannonShots + 1
        enemy.Call("AimAtPlayer", 0.5)
        enemy.Call("FireCannon")
    end
    if timer >= 640 + 150 * numCannonShots - 30 then
        enemy.Call("StopCannon")
    end
    BattleUpdate(timer)
    if timer >= waveTime then
        enemy.Call("Transform", false)
        transformed = false
        enemy.Call("StopCannon")
        enemy.Call("ResetAim", 0.5)
        EndWave()
    end
    timer = timer + TimeMult()
end

function OnHit(bullet)
    bullet.GetVar("hitPlayer")(bullet)
end
