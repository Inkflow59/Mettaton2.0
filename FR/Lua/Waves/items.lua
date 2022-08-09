needsInitialize = true

laserOverlay = CreateProjectileAbs("Mettaton/MettatonNeoCannonLaser", 0, 0)
laserOverlay.sprite.SetPivot(1, 0)
enemy = Encounter.GetVar("enemies")[1]

options = {}
cancel = nil
selected = nil
delay = 0

function Update()
    if needsInitialize then
        if Encounter.GetVar("pie") then
            local bullet = CreateProjectile("Item/Pie", -25, 110)
            bullet.Move(-bullet.sprite.width * 0.5, 0)
            bullet.SetVar("name", "pie")
            table.insert(options, bullet)
        end
        if Encounter.GetVar("noodles") then
            local bullet = CreateProjectile("Item/Noodles", 25, 110)
            bullet.Move(bullet.sprite.width * 0.5, 0)
            bullet.SetVar("name", "noodles")
            table.insert(options, bullet)
        end
        if Encounter.GetVar("steak") then
            local bullet = CreateProjectile("Item/Steak", -25, 70)
            bullet.Move(-bullet.sprite.width * 0.5, 0)
            bullet.SetVar("name", "steak")
            table.insert(options, bullet)
        end
        if Encounter.GetVar("snowman1") then
            local bullet = CreateProjectile("Item/SnowPiece", 25, 70)
            bullet.Move(bullet.sprite.width * 0.5, 0)
            bullet.SetVar("name", "snowman1")
            table.insert(options, bullet)
        end
        if Encounter.GetVar("snowman2") then
            local bullet = CreateProjectile("Item/SnowPiece", -25, 30)
            bullet.Move(-bullet.sprite.width * 0.5, 0)
            bullet.SetVar("name", "snowman2")
            table.insert(options, bullet)
        end
        if Encounter.GetVar("snowman3") then
            local bullet = CreateProjectile("Item/SnowPiece", 25, 30)
            bullet.Move(bullet.sprite.width * 0.5, 0)
            bullet.SetVar("name", "snowman3")
            table.insert(options, bullet)
        end
        if Encounter.GetVar("legend1") then
            local bullet = CreateProjectile("Item/Legend", -25, -10)
            bullet.Move(-bullet.sprite.width * 0.5, 0)
            bullet.SetVar("name", "legend1")
            table.insert(options, bullet)
        end
        if Encounter.GetVar("legend2") then
            local bullet = CreateProjectile("Item/Legend", 25, -10)
            bullet.Move(bullet.sprite.width * 0.5, 0)
            bullet.SetVar("name", "legend2")
            table.insert(options, bullet)
        end
        cancel = CreateProjectile("Item/Cancel", 0, -50)
        cancel.SetVar("name", "cancel")
        needsInitialize = false
    end
    if delay > 0 then
        delay = delay - 1
    elseif selected then
        selected.sprite.color = {1, 1, 1}
        selected = nil
    end
    laserOverlay.sprite.Set("Mettaton/MettatonNeoCannonLaser")
    local laserPos = enemy.Call("CalcLaserPos")
    laserOverlay.MoveToAbs(laserPos[1], laserPos[2])
    local cannonSprite = enemy.GetVar("neoCannon")
    local laserSprite = enemy.GetVar("neoCannonLaser")
    laserOverlay.sprite.alpha = laserSprite.alpha
    laserOverlay.sprite.rotation = cannonSprite.rotation
    laserOverlay.sprite.xscale = laserSprite.xscale
    if selected and Input.Confirm == 1 then
        Select(selected.GetVar("name"))
    end
    if Input.Cancel == 1 then
        EndWave()
    end
end

function OnHit(bullet)
    if selected then
        selected.sprite.color = {1, 1, 1}
        selected = nil
    end
    selected = bullet
    bullet.sprite.color = {1, 1, 0}
    delay = 3
end

function Select(name)
    if name == "cancel" then
        EndWave()
        return
    end
    Encounter.SetVar(name, false)
    Encounter.GetVar("enemies")[1].SetVar("usedItem", name)
    if name == "pie" then
        Player.Heal(91)
    elseif name == "noodles" then
        Player.Heal(90)
    elseif name == "steak" then
        Player.Heal(60)
    elseif name == "snowman1" or name == "snowman2" or name == "snowman3" then
        Player.Heal(45)
    elseif name == "legend1" or name == "legend2" then
        Player.Heal(40)
        Encounter.SetVar("extraAttack", Encounter.GetVar("extraAttack") + 4)
    end
    EndWave()
end
