require "battle"

timer = 0
transformed = false
spawnedEverything = false
speedBullet = nil
timerSpeed = 1
stage = 0
realTimer = 0

function Update()
    if not transformed then
        enemy.Call("Transform", true)
        transformed = true
    end
    if timer > 10 and not spawnedEverything then
        speedBullet = CreateSpeedBullet()
        for y = 240, 1200, 180 do
            local first = math.random(3) - 1
            local second = math.random(2)
            local third = (first - second) % 3
            second = (first + second) % 3
            local order = {first, second, third}
            local x = -Arena.width / 2
            local speed = -1
            for k = 1, 3 do
                local choice = order[k]
                if choice == 0 then
                    x = x + 24
                    CreateBoxLarge(timer, LineFunc(timer, x, y, 0, speed))
                    x = x + 24
                elseif choice == 1 then
                    x = x + 58
                    CreateMegaMetta(timer, 120, LineFunc(timer, x, y + 24, 0, speed))
                    x = x + 58
                else
                    x = x + 12
                    CreateBomb(timer, LineFunc(timer, x, y + 12, 0, speed))
                    CreateBomb(timer, LineFunc(timer, x, y - 12, 0, speed))
                    x = x + 24
                    CreateBomb(timer, LineFunc(timer, x, y + 12, 0, speed))
                    CreateBomb(timer, LineFunc(timer, x, y - 12, 0, speed))
                    x = x + 12
                end
            end
        end
        spawnedEverything = true
    end
    BattleUpdate(timer)
    if timer < 10 and stage == 4 then
        enemy.Call("Transform", false)
        EndWave()
    end
    if stage == 0 and timer >= 1260 then
        timerSpeed = timerSpeed - 0.01
        speedBullet.sprite.Set("Speed/Pause")
    elseif stage == 1 then
        timerSpeed = 0
        realTimer = realTimer + TimeMult()
    elseif stage == 2 then
        realTimer = realTimer + TimeMult()
        speedBullet.sprite.Set("Speed/Replay")
    elseif stage == 3 and timerSpeed < 1.5 then
        timerSpeed = timerSpeed + 0.02
        speedBullet.sprite.Set("Speed/FastForward")
    elseif stage == 4 and timerSpeed > -1.5 then
        timerSpeed = timerSpeed - 0.02
        speedBullet.sprite.Set("Speed/Rewind")
    end
    if stage == 0 and timerSpeed <= 0 then
        stage = 1
    end
    if stage == 1 and realTimer >= 60 then
        stage = 2
        Audio.PlaySound("snd_bell")
        timer = 10
    end
    if stage == 2 and realTimer >= 120 then
        stage = 3
    end
    if stage == 3 and timer >= 1260 then
        stage = 4
    end
    timer = timer + TimeMult() * timerSpeed
end

function OnHit(bullet)
    bullet.GetVar("hitPlayer")(bullet)
end
