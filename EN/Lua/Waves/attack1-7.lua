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
        for k = 280, 400, 40 do
            CreateBox(timer, LineFunc(timer, offsetX, offsetY + k, 0, -0.8))
            CreateBox(timer, LineFunc(timer, offsetX, offsetY - k, 0, 0.8))
            CreateBox(timer, LineFunc(timer, offsetX - k, offsetY, 0.8, 0))
            CreateBox(timer, LineFunc(timer, offsetX + k, offsetY, -0.8, 0))
        end
        CreateBoxLarge(timer, LineFunc(timer, offsetX, offsetY + 450, 0, -0.5))
        CreateBoxLarge(timer, LineFunc(timer, offsetX, offsetY - 450, 0, 0.5))
        CreateBoxLarge(timer, LineFunc(timer, offsetX - 450, offsetY, 0.5, 0))
        CreateBoxLarge(timer, LineFunc(timer, offsetX + 450, offsetY, -0.5, 0))
        for k = 0, 80, 40 do
            CreateTimeBomb(timer, 970 + 2 * k, StopFunc(timer, offsetX, offsetY + 1970 + k, 0, -2, offsetX, offsetY + 80 + k, offsetX, offsetY + 40 + k))
            CreateTimeBomb(timer, 990 + 2 * k, StopFunc(timer, offsetX + 1970 + k, offsetY, -2, 0, offsetX + 80 + k, offsetY, offsetX + 40 + k, offsetY))
            CreateTimeBomb(timer, 1010 + 2 * k, StopFunc(timer, offsetX, offsetY - 1970 - k, 0, 2, offsetX, offsetY - 80 - k, offsetX, offsetY - 40 - k))
            CreateTimeBomb(timer, 1030 + 2 * k, StopFunc(timer, offsetX - 1970 - k, offsetY, 2, 0, offsetX - 80 - k, offsetY, offsetX - 40 - k, offsetY))
        end
    end

    BattleUpdate(timer)
    if timer >= 1210 then
        enemy.Call("Transform", false)
        Player.sprite.rotation = 180
        EndWave()
    end
    timer = timer + TimeMult()
end

function OnHit(bullet)
    bullet.GetVar("hitPlayer")(bullet)
end
