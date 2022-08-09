body = nil
arms = nil
neoLegs = nil
neoBody = nil
neoWingLeft = nil
neoWingRight = nil
neoArmLeft = nil
neoArmRight = nil
neoBodyOverlay = nil
neoHead = nil
neoCannon = nil
neoCannonCharge = nil
neoCannonLaser = nil
stageLights = nil
whiteout = nil

bodyRotTime = 0.0
armPosTime = 0.0
neoAnimTime = 0.0
neoWingFlashTime = 0.0

transparent = false
neo = false

cannonRotStart = 0.0
canonRotFinish = 0.0
cannonRotFrom = 0.0
cannonRotTarget = 0.0

cannonOn = false
cannonCharge = 0
cannonChargeFrame = "Mettaton/MettatonNeoCannonCharge1"
defaultLaserLength = 800
laserLength = 0

lowerLights = false
lightTimer = 0

destroyWings = false
wingFall = 0
shakeTimer = 0

screenWidth = 640
screenHeight = 480

function Initialize()
    stageLights = CreateSprite("Mettaton/StageLightsOff")
    stageLights.SetPivot(0, 1)
    stageLights.MoveToAbs(0, screenHeight + 120)

    body = CreateSprite("Mettaton/MettatonBody")
    body.y = body.y + 120
    body.SetPivot(0.5, 0.65)
    arms = CreateSprite("Mettaton/MettatonArms1")
    arms.SetParent(body)
    arms.y = 0
    arms.SetAnimation({"Mettaton/MettatonArms1", "Mettaton/MettatonArms2"}, 0.25)

    neoLegs = CreateSprite("Mettaton/MettatonNeoLegs")
    neoBody = CreateSprite("Mettaton/MettatonNeoBody")
    neoWingLeft = CreateSprite("Mettaton/MettatonNeoWingLeft")
    neoWingRight = CreateSprite("Mettaton/MettatonNeoWingRight")
    neoArmLeft = CreateSprite("Mettaton/MettatonNeoArmLeft")
    neoArmRight = CreateSprite("Mettaton/MettatonNeoArmRight")
    neoBodyOverlay = CreateSprite("Mettaton/MettatonNeoBody")
    neoHead = CreateSprite("Mettaton/MettatonNeoHead")
    neoCannon = CreateSprite("Mettaton/MettatonNeoCannon")
    neoCannonCharge = CreateSprite(cannonChargeFrame)
    neoCannonLaser = CreateSprite("Mettaton/MettatonNeoCannonLaser")

    whiteout = CreateSprite("Whiteout")

    neoLegs.SetPivot(0.5, 0)
    neoLegs.MoveTo(screenWidth / 2, screenHeight / 2)
    neoBody.SetParent(neoLegs)
    neoBody.SetPivot(0.5, 0)
    neoBody.SetAnchor(0.5, 1 - 20.0 / neoLegs.height)
    neoBody.MoveTo(0, 0)
    neoWingLeft.SetParent(neoBody)
    neoWingRight.SetParent(neoBody)
    neoWingLeft.SetPivot(0, 1)
    neoWingRight.SetPivot(1, 1)
    neoWingLeft.MoveTo(26, 15)
    neoWingRight.MoveTo(-26, 15)
    neoArmLeft.SetParent(neoBody)
    neoArmLeft.SetPivot(0, 1)
    neoArmLeft.MoveTo(33, -6)
    neoBodyOverlay.SetParent(neoBody)
    neoBodyOverlay.MoveTo(0, 0)
    neoHead.SetParent(neoBody)
    neoHead.SetPivot(0.5, 0)
    neoHead.MoveTo(0, -2)
    neoArmRight.SetPivot(1, 1)
    local rightArmX = screenWidth / 2 - 28
    local rightArmY = screenHeight / 2 + 152
    neoArmRight.MoveTo(rightArmX, rightArmY)
    neoCannon.MoveTo(rightArmX - neoArmRight.width + neoCannon.width / 2, rightArmY - neoCannon.height / 2)

    neoCannonCharge.SetParent(neoCannon)
    neoCannonCharge.MoveTo(0, 0)
    neoCannonLaser.SetParent(neoCannon)
    neoCannonLaser.SetPivot(1, 0)
    neoCannonLaser.SetAnchor(0, 0)
    neoCannonLaser.MoveTo(0, 0)

    whiteout.SetPivot(0, 0)
    whiteout.MoveTo(0, 0)
    whiteout.alpha = 0
end

function Animate()
    local dt = Time.mult
    if dt > 2 then
        dt = 2
    end

    SetAlphas()

    if shakeTimer > 0 then
        local amount = 0
        if shakeTimer == 60 then
            amount = 8
        elseif shakeTimer == 1 then
            amount = 8
        elseif shakeTimer % 10 == 5 then
            amount = -16
        elseif shakeTimer % 10 == 0 then
            amount = 16
        end
        neoLegs.x = neoLegs.x + amount
        neoArmRight.x = neoArmRight.x + amount
        neoCannon.x = neoCannon.x + amount
        shakeTimer = shakeTimer - 1
    end

    bodyRotTime = UpdateAngle(bodyRotTime, 0.17 * dt)
    body.rotation = 3.2 * math.sin(bodyRotTime)
    armPosTime = UpdateAngle(armPosTime, 0.15 * dt)
    arms.y = 4 * math.sin(armPosTime)

    neoAnimTime = UpdateAngle(neoAnimTime, 0.08 * dt)
    neoLegs.yscale = 0.98 + 0.02 * math.sin(2 * neoAnimTime)
    if destroyWings then
        if neoWingLeft.x > -640 and neoWingRight.y > -640 then
            wingFall = wingFall + 0.1 * dt
            neoWingLeft.x = neoWingLeft.x + 2 * dt
            neoWingRight.x = neoWingRight.x - 2 * dt
            neoWingLeft.y = neoWingRight.y - wingFall * dt
            neoWingRight.y = neoWingRight.y - wingFall * dt
            neoWingLeft.rotation = neoWingLeft.rotation - 0.5 * dt
            neoWingRight.rotation = neoWingRight.rotation + 0.5 * dt
        end
    else
        neoWingLeft.rotation = 2 * math.sin(neoAnimTime)
        neoWingRight.rotation = -2 * math.sin(neoAnimTime)
    end
    neoArmLeft.rotation = -2 * math.sin(neoAnimTime)
    neoArmLeft.x = 33 + 3 * math.abs(math.sin(neoAnimTime))
    neoHead.y = -2 + 2 * math.abs(math.sin(neoAnimTime + math.pi / 4))

    neoWingFlashTime = UpdateAngle(neoWingFlashTime, 0.3 * dt)

    if cannonRotStart > 0.0 then
        if Time.time >= cannonRotFinish then
            neoCannon.rotation = cannonRotTarget
            cannonRotStart = 0.0
            cannonRotFinish = 0.0
            cannonRotOriginal = 0.0
            cannonRotTarget = 0.0
        else
            local span = cannonRotFinish - cannonRotStart
            local time = Time.time - cannonRotStart
            local range = cannonRotTarget - cannonRotOriginal
            neoCannon.rotation = cannonRotOriginal + range * (1 - math.pow(time / span - 1, 2))
        end
    end

    if cannonOn then
        if cannonCharge == 0 then
            Audio.PlaySound("chargeLaser")
        end
        cannonCharge = cannonCharge + dt
        local flag = neoCannonLaser.alpha == 0
        neoCannonLaser.alpha = 0
        local frame = 1
        if cannonCharge <= 8 then
            frame = 1
        elseif cannonCharge <= 16 then
            frame = 2
        elseif cannonCharge <= 24 then
            frame = 3
        elseif cannonCharge <= 32 then
            frame = 4
        elseif cannonCharge <= 40 then
            frame = 5
        elseif cannonCharge <= 48 then
            frame = 6
        elseif cannonCharge <= 56 then
            frame = 7
        elseif cannonCharge <= 64 then
            frame = 8
        else
            frame = 9
            if flag then
                Audio.PlaySound("fireLaser")
            end
            neoCannonLaser.alpha = 1
            neoCannonLaser.xscale = laserLength
        end
        cannonChargeFrame = "Mettaton/MettatonNeoCannonCharge" .. frame
        neoCannonCharge.Set(cannonChargeFrame)
        neoCannonCharge.alpha = 1
    else
        cannonCharge = 0
        neoCannonCharge.alpha = 0
        neoCannonLaser.alpha = 0
    end

    if lowerLights then
        lightTimer = lightTimer + dt
        if lightTimer >= 120 then
            stageLights.MoveToAbs(0, screenHeight)
        else
            stageLights.MoveToAbs(0, screenHeight + 120 - lightTimer)
        end
        if lightTimer >= 180 then
            Audio.PlaySound("snd_lightswitch")
            stageLights.Set("Mettaton/StageLightsOn")
            lowerLights = false
        end
    end

    if whiteout.alpha > 0 then
        whiteout.alpha = whiteout.alpha + 0.04
        if whiteout.alpha > 1 then
            whiteout.alpha = 1
        end
    end
end

function SetCannonRotation(target, time)
    cannonRotStart = Time.time
    cannonRotFinish = Time.time + time
    cannonRotOriginal = neoCannon.rotation
    cannonRotTarget = target * 180.0 / math.pi
end

function SetAlphas()
    local gray = transparent and 0.5 or 1
    SetGray(body, gray)
    SetGray(arms, gray)
    SetGray(neoLegs, gray)
    SetGray(neoBody, gray)
    SetGray(neoArmLeft, gray)
    SetGray(neoArmRight, gray)
    SetGray(neoBodyOverlay, gray)
    SetGray(neoHead, gray)
    local wingGray = gray * (0.85 + 0.15 * math.sin(neoWingFlashTime))
    SetGray(neoWingLeft, wingGray)
    SetGray(neoWingRight, wingGray)

    local alpha = neo and 0 or 1
    body.alpha = alpha
    arms.alpha = alpha
    alpha = 1 - alpha
    neoLegs.alpha = alpha
    neoBody.alpha = alpha
    neoArmLeft.alpha = alpha
    neoWingLeft.alpha = alpha
    neoWingRight.alpha = alpha
    neoArmRight.alpha = alpha
    neoBodyOverlay.alpha = alpha
    neoHead.alpha = alpha
    neoCannon.alpha = alpha
end

function SetGray(sprite, brightness)
    sprite.color = {brightness, brightness, brightness}
end

function UpdateAngle(angle, speed)
    angle = angle + speed
    if angle > 2 * math.pi then
        angle = angle - 2 * math.pi
    end
    return angle
end
