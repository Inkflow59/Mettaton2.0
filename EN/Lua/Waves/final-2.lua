require "battle"
EnableShooter()
streamBlocks = true

timer = 0
transformed = false
spawnedEverything = false
nextBox = 70

function Update()
    if not transformed then
        enemy.Call("Transform", true)
        enemy.Call("SetHead", "Mettaton/MettatonNeoGlare")
        transformed = true
    end

    if timer > 2 and not spawnedEverything then
        local offsetX = 0
        local offsetY = 137
        CreateInfiniteBomb(timer, NoMoveFunc(offsetX, offsetY - 200))
        CreateInfiniteBomb(timer, NoMoveFunc(offsetX + 200, offsetY))
        CreateBlockPortal(timer, offsetX - 240, offsetY - 72, 1, 1, 36)
        local colors = {0, 0}
        for k = 1, 20 do
            table.insert(colors, math.random(3) - 1)
        end
        CreateDiscoBall(0.05, colors)
        CreateBlock(timer, LineFunc(timer, offsetX - 204, offsetY - 36, 1, 1))
        local queue = {}
        for y = 300, 2200, 48 do
            if #queue == 0 then
                local choice = math.random(3)
                if choice == 1 then
                    queue = {1, 1, 1, 2}
                elseif choice == 2 then
                    queue = {1, 2}
                elseif choice == 3 then
                    queue = {1, 1, 2}
                end
            end
            if queue[1] == 1 then
                CreateTimeBomb(timer, y + 48, LineFunc(timer, offsetX - 80, offsetY + y, 0, -1))
            else
                CreateBomb(timer, LineFunc(timer, offsetX - 80, offsetY + y, 0, -1))
            end
            table.remove(queue, 1)
        end
        spawnedEverything = true
    end
    if timer >= nextBox and timer < 2080 then
        if math.random(2) == 1 then
            CreateBox(nextBox, SinFunc(nextBox, 320, Player.y, -1, 0, 0, 60, 0, 18))
        else
            CreateBox(nextBox, SinFunc(nextBox, 0, Player.y - 320, 0, 1, 0, 60, 18, 0))
        end
        nextBox = nextBox + 90
    end
    if timer >= 60 then
        if not startedCannon then
            enemy.Call("FireCannon")
            startedCannon = true
        end
        enemy.Call("AimAtPlayer", 0)
    end
    BattleUpdate(timer)
    if timer >= 2400 then
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
