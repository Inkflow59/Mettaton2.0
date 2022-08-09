require "battle"

timer = 0
transformed = false
speedBullet = nil
timerSpeed = 1

function Update()
    if not transformed then
        enemy.Call("Transform", true)
        transformed = true
    end
    if timer == 0 then
        speedBullet = CreateSpeedBullet()
        for y = 600, 2100, 300 do
            local bomb = (math.random(4) - 2.5) * 24
            for x = -36, 36, 24 do
                if x == bomb then
                    CreateBomb(timer, LineFunc(timer, x, y + 24, 0, -2.5))
                else
                    CreateBlock(timer, LineFunc(timer, x, y, 0, -2.5))
                end
            end
        end
        CreateMegaMetta(timer, 180, NoMoveFunc(-180, 20))
        CreateMegaMetta(timer, 180, NoMoveFunc(180, 20))
    end
    BattleUpdate(timer)
    if timer >= 930 then
        speedBullet.sprite.Set("Speed/Rewind")
        timerSpeed = timerSpeed - 0.02
    elseif timerSpeed < 0 then
        timerSpeed = -1
    end
    if timer < 100 and timerSpeed < 0 then
        enemy.Call("Transform", false)
        EndWave()
    end
    timer = timer + TimeMult() * timerSpeed
end

function OnHit(bullet)
    bullet.GetVar("hitPlayer")(bullet)
end
