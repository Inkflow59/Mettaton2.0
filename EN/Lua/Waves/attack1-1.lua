require "battle"

timer = 0
transformed = false
spawnedEverything = false
mustDestroy = {}
endTimer = 0

function Update()
    if timer >= 30 and timer < 120 and not transformed then
        enemy.Call("Transform", true)
        enemy.Call("StartMusic", "mus_mettaton_neo")
        transformed = true
    end
    if timer >= 120 and not spawnedEverything then
        for y = 400, 520, 30 do
            for x = -Arena.width * 0.5 - 12, Arena.width * 0.5 + 12, 30 do
                local randomX = math.random(-4, 4)
                local randomY = math.random(-4, 4)
                local randomSinTime = 2.0 * math.pi * math.random()
                CreateBox(timer, SinFunc(timer, x + randomX, y + randomY, 0, -2, randomSinTime, 30, 3, 0))
            end
        end
        for y = 604, 700, 48 do
            for x = -96, 96, 48 do
                CreateBoxLarge(timer, LineFunc(timer, x, y, 0, -2))
            end
        end
        for x = -60, 60, 120 do
            local bullet = CreateMiniMetta(timer, 120, StopFunc(timer, x, 800, 0, -1.2, x, 120, x, 60))
            --bullet.SetVar("shootOffset", -30)
            table.insert(mustDestroy, bullet)
            bullet = CreateMiniMetta(timer, 120, StopFunc(timer, x, 920, 0, -1.2, x, 180, x, 120))
            --bullet.SetVar("shootOffset", -30)
            table.insert(mustDestroy, bullet)
            bullet = CreateMegaMetta(timer, 120, StopFunc(timer, x, 1100, 0, -1.2, x, 300, x, 240), mustDestroy)
            --bullet.SetVar("shootOffset", -30)
            table.insert(mustDestroy, bullet)
        end
        spawnedEverything = true
    end
    BattleUpdate(timer)
    for i = #mustDestroy, 1, -1 do
        if not mustDestroy[i].isactive then
            table.remove(mustDestroy, i)
        end
    end
    timer = timer + TimeMult()
    if timer >= 120 and #mustDestroy == 0 then
        endTimer = endTimer + 1
        if endTimer >= 120 and transformed then
            enemy.Call("Transform", false)
            enemy.Call("StartMusic", "mus_mettatonbattle")
            transformed = false
        end
        if endTimer >= 180 then
            EndWave()
        end
    end
end

function OnHit(bullet)
    bullet.GetVar("hitPlayer")(bullet)
end
