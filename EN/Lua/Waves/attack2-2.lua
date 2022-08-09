require "battle"

timer = 0
transformed = false
spawnedEverything = false

function Update()
    if not transformed then
        enemy.Call("Transform", true)
        transformed = true
    end
    if timer > 0 and not spawnedEverything then
        Player.MoveTo(0, 0, false)
        colors = {0, 0, 0}
        for k = 1, 12 do
            table.insert(colors, math.random(3) - 1)
        end
        CreateDiscoBall(0.1, colors)
        for k = 1, 6 do
            for x = 0, 1 do
                CreateBox(timer, LineFunc(timer, (6 * k + x) * 24, 24, -0.5, 0))
                CreateBox(timer, LineFunc(timer, (6 * k + x) * -24, -36, 0.5, 0))
            end
        end
        CreateMiniMetta(timer, 240, FollowPlayerYFunc(-200))
        CreateMiniMetta(timer, 240, FollowPlayerYFunc(200))
        spawnedEverything = true
    end
    BattleUpdate(timer)
    if timer >= 1200 then
        enemy.Call("Transform", false)
        EndWave()
    end
    timer = timer + TimeMult()
end

function OnHit(bullet)
    bullet.GetVar("hitPlayer")(bullet)
end
