timer = 0

function Update()
    if timer == 0 then
        Player.SetControlOverride(true)
        Encounter.GetVar("enemies")[1].Call("StartShow")
    end
    local dt = Time.mult
    if dt > 2 then
        dt = 2
    end
    timer = timer + dt
    if timer > 240 then
        EndWave()
    end
end
