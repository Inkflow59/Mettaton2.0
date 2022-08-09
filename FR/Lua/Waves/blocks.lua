require "battle"

timer = 0

function Update()
    if timer == 0 then
        for y = 400, 520, 30 do
            for x = -Arena.width * 0.5 - 12, Arena.width * 0.5 + 12, 30 do
                local randomX = math.random(-4, 4)
                local randomY = math.random(-4, 4)
                local randomSinTime = 2.0 * math.pi * math.random()
                CreateBox(0, SinFunc(0, x + randomX, y + randomY, 0, -2, randomSinTime, 30, 3, 0))
            end
        end
    end
    BattleUpdate(timer)
    timer = timer + TimeMult()
    if timer > 300 then
        EndWave()
    end
end

function OnHit(bullet)
    bullet.GetVar("hitPlayer")(bullet)
end
