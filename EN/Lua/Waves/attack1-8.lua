require "battle"
EnableShooter()

timer = 0
transformed = false

function Update()
    if not transformed then
        enemy.Call("Transform", true)
        transformed = true
    end

    if timer == 0 then
        local offsetX = 0
        local offsetY = 137
        CreateInfiniteBomb(timer, NoMoveFunc(offsetX, offsetY + 200))
        CreateInfiniteBomb(timer, NoMoveFunc(offsetX, offsetY - 200))
        CreateInfiniteBomb(timer, NoMoveFunc(offsetX - 200, offsetY))
        CreateInfiniteBomb(timer, NoMoveFunc(offsetX + 200, offsetY))
        for k = 0, 5 do
            CreateBox(timer, ShrinkCircleFunc(60, offsetX, offsetY, 120, 2 * math.pi * k / 6, -0.025, 360))
            CreateBox(timer, ShrinkCircleFunc(420, offsetX, offsetY, 120, 2 * math.pi * k / 6, -0.025, 360))
            CreateBox(timer, ShrinkCircleFunc(780, offsetX, offsetY, 120, 2 * math.pi * k / 6, -0.025, 360))
        end
        CreateTimeBomb(timer, 720, StopFunc(timer, offsetX, offsetY + 170 + 840, 0, -2, offsetX, offsetY + 200, offsetX, offsetY + 170))
        CreateTimeBomb(timer, 720, StopFunc(timer, offsetX, offsetY - 170 - 840, 0, 2, offsetX, offsetY - 200, offsetX, offsetY - 170))
        CreateTimeBomb(timer, 720, StopFunc(timer, offsetX - 170 - 840, offsetY, 2, 0, offsetX - 200, offsetY, offsetX - 170, offsetY))
        CreateTimeBomb(timer, 720, StopFunc(timer, offsetX + 170 + 840, offsetY, -2, 0, offsetX + 200, offsetY, offsetX + 170, offsetY))
        CreateTimeBomb(timer, 1080, StopFunc(timer, offsetX, offsetY + 170 + 1560, 0, -2, offsetX, offsetY + 200, offsetX, offsetY + 170))
        CreateTimeBomb(timer, 1080, StopFunc(timer, offsetX, offsetY - 170 - 1560, 0, 2, offsetX, offsetY - 200, offsetX, offsetY - 170))
        CreateTimeBomb(timer, 1080, StopFunc(timer, offsetX - 170 - 1560, offsetY, 2, 0, offsetX - 200, offsetY, offsetX - 170, offsetY))
        CreateTimeBomb(timer, 1080, StopFunc(timer, offsetX + 170 + 1560, offsetY, -2, 0, offsetX + 200, offsetY, offsetX + 170, offsetY))
    end

    BattleUpdate(timer)
    if timer >= 1240 then
        enemy.Call("Transform", false)
        Player.sprite.rotation = 180
        EndWave()
    end
    timer = timer + TimeMult()
end

function OnHit(bullet)
    bullet.GetVar("hitPlayer")(bullet)
end
