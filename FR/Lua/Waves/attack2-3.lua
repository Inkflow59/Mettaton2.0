require "battle"

timer = 0
transformed = false
spawnedEverything = false
speedBullet = nil
timerSpeed = 1
stage = 0

function Update()
    if not transformed then
        enemy.Call("Transform", true)
        transformed = true
    end
    if timer > 10 and not spawnedEverything then
        speedBullet = CreateSpeedBullet()
        for y = 5, 11 do
            CreateDownBlock(0, y)
            CreateDownBlock(5, y)
        end
        for x = 1, 3 do
            CreateDownBlock(x, 5)
            CreateDownBlock(x, 9)
        end
        for x = 2, 4 do
            CreateDownBlock(x, 7)
            CreateDownBlock(x, 11)
        end
        CreateDownTimeBomb(-1, 7, 360)
        CreateDownTimeBomb(6, 7, 360)
        for y = 20, 40, 5 do
            local bombPos = math.random(6) - 1
            local mettaPos = math.random(5) - 1
            local smallestPos = mettaPos
            local largestPos = bombPos
            if mettaPos >= bombPos then
                mettaPos = mettaPos + 1
                smallestPos, largestPos = largestPos, smallestPos
            end
            local blockPos = math.random(4) - 1
            if blockPos >= smallestPos then
                blockPos = blockPos + 1
            end
            if blockPos >= largestPos then
                blockPos = blockPos + 1
            end
            for x = 0, 5 do
                if x == bombPos then
                    CreateDownBomb(x, y)
                elseif x == mettaPos then
                    CreateDownMetta(x, y)
                elseif x == blockPos then
                    CreateDownBlock(x, y)
                else
                    CreateDownBox(x, y)
                end
            end
        end
        spawnedEverything = true
    end
    BattleUpdate(timer)
    if timer >= 1320 then
        enemy.Call("Transform", false)
        EndWave()
    end
    if stage == 0 and timer >= 390 then
        stage = 1
    elseif stage == 1 and timer <= 120 then
        stage = 2
    elseif stage == 2 and timer >= 1230 then
        stage = 3
    elseif stage == 3 and timer <= 270 then
        stage = 4
    end
    if stage == 1 and timerSpeed > -1 then
        timerSpeed = timerSpeed - 0.02
        speedBullet.sprite.Set("Speed/Rewind")
    end
    if stage == 2 and timerSpeed < 1.6 then
        timerSpeed = timerSpeed + 0.02
        speedBullet.sprite.Set("Speed/FastForward")
    end
    if stage == 3 and timerSpeed > -1.6 then
        timerSpeed = timerSpeed - 0.02
        speedBullet.sprite.Set("Speed/Rewind")
    end
    if stage == 4 and timerSpeed < 2 then
        timerSpeed = timerSpeed + 0.02
        speedBullet.sprite.Set("Speed/FastForward")
    end
    timer = timer + TimeMult() * timerSpeed
end

function CreateDownBlock(x, y)
    return CreateBlock(timer, LineFunc(timer, -75 + 30 * x, 30 * y, 0, -1))
end

function CreateDownTimeBomb(x, y, timeLeft)
    return CreateTimeBomb(timer, timeLeft, LineFunc(timer, -75 + 30 * x, 30 * y, 0, -1))
end

function CreateDownBomb(x, y)
    return CreateBomb(timer, LineFunc(timer, -75 + 30 * x, 30 * y, 0, -1))
end

function CreateDownMetta(x, y)
    return CreateMiniMetta(timer, 120, LineFunc(timer, -75 + 30 * x, 30 * y, 0, -1))
end

function CreateDownBox(x, y)
    return CreateBox(timer, LineFunc(timer, -75 + 30 * x, 30 * y, 0, -1))
end

function OnHit(bullet)
    bullet.GetVar("hitPlayer")(bullet)
end
