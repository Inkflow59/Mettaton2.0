require "battle"

timer = 0
transformed = false

function Update()
    if not transformed then
        enemy.Call("Transform", true)
        transformed = true
    end
    if timer == 0 then
        CreateDiscoBall(0.1, {0, 0, 0, 0, 2, 2, 1, 1, 0, 2, 1, 2, 0, 1})
    end
    BattleUpdate(timer)
    if timer >= 140 * 2 * math.pi then
        enemy.Call("Transform", false)
        EndWave()
    end
    timer = timer + TimeMult()
end

function OnHit(bullet)
    bullet.GetVar("hitPlayer")(bullet)
end
