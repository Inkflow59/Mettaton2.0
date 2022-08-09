require "battle"

timer = 0
spawnedEverything = false
transformed = false
speedBullet = nil
timerSpeed = 1
stage = 0
realTimer = 0

function Update()
    if not transformed then
        enemy.Call("Transform", true)
        transformed = true
    end
    if timer > 0 and not spawnedEverything then
        speedBullet = CreateSpeedBullet()
        CreateMegaMetta(timer, 120, NoMoveFunc(-180, 20))
        CreateMegaMetta(timer, 120, NoMoveFunc(180, 20))
        for k = 0, 9 do
            local bullet = CreateMiniMetta(timer, 120, CircleFunc(timer, 0, 0, 160, 2 * math.pi * k / 10, 0.02))
            bullet.SetVar("shootOffset", 12 * k)
        end
        for k = 0, 4 do
            CreateBox(timer, CircleFunc(timer, 0, 0, 140, 2 * math.pi * k / 5, -0.02))
        end
        spawnedEverything = true
    end
    BattleUpdate(timer)
    if stage == 0 then
        if timer >= 600 and timerSpeed > 0 then
            timerSpeed = timerSpeed - 0.01
            speedBullet.sprite.Set("Speed/Pause")
        elseif timer >= 600 and timerSpeed < 0 then
            timerSpeed = 0
        elseif timer >= 600 and timerSpeed == 0 then
            realTimer = realTimer + TimeMult()
        end
        if realTimer > 60 then
            stage = 1
            timer = 0
            speedBullet.sprite.Set("Speed/Replay")
            Audio.PlaySound("snd_bell")
            realTimer = 0
        end
    elseif stage == 1 then
        if realTimer < 60 then
            realTimer = realTimer + TimeMult()
        elseif timer < 600 and timerSpeed < 1.5 then
            timerSpeed = timerSpeed + 0.02
            speedBullet.sprite.Set("Speed/FastForward")
        elseif timer >= 600 then
            stage = 2
            realTimer = 0
        end
    elseif stage == 2 then
        if timer >= 600 and timerSpeed > -1 then
            timerSpeed = timerSpeed - 0.02
            speedBullet.sprite.Set("Speed/Rewind")
        elseif timerSpeed < 0 then
            timerSpeed = -1
        end
    end
    if stage == 2 and timer <= 2 then
        enemy.Call("Transform", false)
        EndWave()
    end
    timer = timer + TimeMult() * timerSpeed
end

function OnHit(bullet)
    bullet.GetVar("hitPlayer")(bullet)
end
