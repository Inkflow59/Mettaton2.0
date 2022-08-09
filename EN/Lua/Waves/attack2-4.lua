require "battle"
EnableShooter()
streamBlocks = true

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
        CreateInfiniteBomb(timer, NoMoveFunc(offsetX, offsetY - 200))
        CreateInfiniteBomb(timer, NoMoveFunc(offsetX + 200, offsetY))
        CreateBlockPortal(timer, offsetX - 240, offsetY - 72, 1, 1, 36)
        CreateBlock(timer, LineFunc(timer, offsetX - 204, offsetY - 36, 1, 1))
        local queue = {}
        for y = 300, 1500, 48 do
            if #queue == 0 then
                queue = {1, 1, 1}
                queue[math.random(#queue)] = 2
            end
            if queue[1] == 1 then
                CreateTimeBomb(timer, (y + 48) / 1.5, LineFunc(timer, offsetX - 80, offsetY + y, 0, -1.5))
            else
                CreateBomb(timer, LineFunc(timer, offsetX - 80, offsetY + y, 0, -1.5))
            end
            table.remove(queue, 1)
        end
        for k = 240, 1740, 90 do
            if math.random(2) == 1 then
                CreateBox(timer, LineFunc(timer, offsetX + k, offsetY, -1.5, 0))
            else
                CreateBox(timer, LineFunc(timer, offsetX, offsetY - k, 0, 1.5))
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
    if timer >= 1200 then
        enemy.Call("Transform", false)
        enemy.Call("StopCannon")
        enemy.Call("ResetAim", 0.5)
        Player.sprite.rotation = 180
        EndWave()
    end
    timer = timer + TimeMult()
end

function OnHit(bullet)
    bullet.GetVar("hitPlayer")(bullet)
end
