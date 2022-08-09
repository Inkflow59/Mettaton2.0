commands = {"Taunt", "Heckle"}

sprite = "empty"
name = "Mettaton"
hp = 30000
atk = 30
def = 255
check = "His metal body renders him\rinvulnerable to attack."
dialogbubble = "rightwide"
canspare = false
cancheck = true

usedItem = nil
dialogueItem = nil
extraAttack = 0
progress = 0
justAttacked = false
triedHit = false
taunted = false
heckled = false
overrideEncounter = nil

musicFade = 0.5
maxMusicFade = 0.5

endLaserTimer = 0
canShootLaser = false
usingBattleDialogue = false

function EncounterStarting()
    Audio.Volume(0.5)
    Player.lv = 15
    Player.hp = 76
    Player.name = "Chara"
    Player.sprite.rotation = 180
    Player.sprite.color = {1, 1, 0}
    Encounter.SetVar("wavetimer", 6000)
    State("ENEMYDIALOGUE")
    require "Animations/animation"
    Initialize()
end

function UpdateAnimation()
    Animate()
end

function StartMusic(music)
    Audio.LoadFile(music)
    Audio.Volume(0)
    musicFade = 0
end

function StartShow()
    Audio.LoadFile("mus_neo")
    musicFade = 0.1
    maxMusicFade = 0.3
    lowerLights = true
end

function SetHead(head)
    neoHead.Set(head)
end

function DestroyWings()
    destroyWings = true
end

function UpdateMusic()
    if musicFade < maxMusicFade then
        musicFade = musicFade + 0.005
    end
    Audio.Volume(musicFade)
end

function Transform(toNeo)
    neo = toNeo
    Audio.PlaySound("mus_create")
end

function Whiteout()
    whiteout.alpha = 0.04
end

function GetCannonX()
    return neoCannon.x
end

function GetCannonY()
    return neoCannon.y - neoCannon.height / 2 + neoCannonLaser.height / 2
end

function CannonToPlayerRot()
    return math.atan2(Player.absy - GetCannonY(), Player.absx - GetCannonX()) + math.pi
end

function AimAtPlayer(time)
    SetCannonRotation(CannonToPlayerRot(), time)
end

function ResetAim(time)
    SetCannonRotation(0, time)
end

function FireCannon()
    cannonOn = true
end

function StopCannon()
    cannonOn = false
end

function CalcLaserPos()
    local offsetX = -neoCannon.width / 2
    local offsetY = -neoCannon.height / 2
    local rotation = neoCannon.rotation * math.pi / 180.0
    local rotatedOffsetX = offsetX * math.cos(rotation) - offsetY * math.sin(rotation)
    local rotatedOffsetY = offsetY * math.cos(rotation) + offsetX * math.sin(rotation)
    return {neoCannon.x + rotatedOffsetX, neoCannon.y + rotatedOffsetY}
end

function LaserHitsObject(objLeft, objRight, objBottom, objTop)
    local laserPos = CalcLaserPos()
    local rotation = neoCannon.rotation * math.pi / 180.0 - math.pi
    local laserWidth = neoCannonLaser.height - 4
    if objBottom > laserPos[2] then
        return false
    elseif objRight < laserPos[1] - laserWidth and rotation > -math.pi / 2 then
        return false
    elseif objLeft > laserPos[1] + laserWidth and rotation < -math.pi / 2 then
        return false
    end
    local dirX = math.cos(rotation)
    local dirY = math.sin(rotation)
    local normalX = -dirY
    local normalY = dirX
    local rightSourceX = laserPos[1] - 2 * normalX
    local rightSourceY = laserPos[2] - 2 * normalY
    local leftSourceX = rightSourceX - laserWidth * normalX
    local leftSourceY = rightSourceY - laserWidth * normalY
    local rightEndX = rightSourceX + laserLength * dirX
    local rightEndY = rightSourceY + laserLength * dirY
    local leftEndX = leftSourceX + laserLength * dirX
    local leftEndY = leftSourceY + laserLength * dirY
    --assume laser always points downwards
    if rotation == -math.pi / 2 then
        return objTop > rightEndX and objRight > leftEndX and objLeft < rightEndX
    elseif rotation > -math.pi / 2 then
        local interBottom = (objRight - leftSourceX) / (leftEndX - leftSourceX)
        local laserBottomCheck = leftSourceY + (leftEndY - leftSourceY) * interBottom
        local interTop = (objLeft - rightSourceX) / (rightEndX - rightSourceX)
        local laserTopCheck = rightSourceY + (rightEndY - rightSourceY) * interTop
        return interBottom < 1 and interTop < 1 and objTop > laserBottomCheck and objBottom < laserTopCheck
    else
        local interBottom = (objLeft - rightSourceX) / (rightEndX - rightSourceX)
        local laserBottomCheck = rightSourceY + (rightEndY - rightSourceY) * interBottom
        local interTop = (objRight - leftSourceX) / (leftEndX - leftSourceX)
        local laserTopCheck = leftSourceY + (leftEndY - leftSourceY) * interTop
        return interBottom < 1 and interTop < 1 and objTop > laserBottomCheck and objBottom < laserTopCheck
    end
end

function LaserHitsPlayer()
    return LaserHitsObject(Player.absx - 8, Player.absx + 8, Player.absy - 8, Player.absy + 8)
end

function IsLaserOn()
    return neoCannonLaser.alpha == 1
end

function CheckLaser()
    if progress == 21 and canShootLaser then
        if endLaserTimer == 60 then
            AimAtPlayer(0.5)
            FireCannon()
        elseif endLaserTimer == 180 then
            StopCannon()
            endLaserTimer = 30
        end
        ResetLaserLength()
        endLaserTimer = endLaserTimer + 1
    elseif progress >= 21 then
        ResetAim(0.5)
        StopCannon()
    end
    if IsLaserOn() and LaserHitsPlayer() then
        local amount = 15 + extraAttack
        if Encounter.GetVar("easyMode") then
            amount = math.floor(amount * 2 / 3)
        end
        Player.Hurt(amount)
    end
end

function LaserHitsBullet(bullet)
    local halfWidth = bullet.sprite.width / 2
    local halfHeight = bullet.sprite.height / 2
    return LaserHitsObject(bullet.absx - halfWidth, bullet.absx + halfWidth, bullet.absy - halfHeight, bullet.absy + halfHeight)
end

function ResetLaserLength()
    if IsLaserOn() then
        laserLength = defaultLaserLength
    else
        laserLength = 0
    end
end

function GetLaserLength()
    return laserLength
end

function BlockLaser(bullet)
    local laserPos = CalcLaserPos()
    local rotation = neoCannon.rotation * math.pi / 180.0 - math.pi
    local dirX = math.cos(rotation)
    local dirY = math.sin(rotation)
    local offsetX = bullet.absx - laserPos[1]
    local offsetY = bullet.absy - laserPos[2]
    local limit = offsetX * dirX + offsetY * dirY
    if limit < laserLength then
        laserLength = limit
    end
end

blacklist = 
{
    "[next]",
    "[noskip][novoice][waitall:6]. . .",
    "[noskip][w:30][next]",
    "[noskip][func:SetHead,Mettaton/MettatonNeoHurt][next]"
}

function EnemyDialogueStarting()
    local curTaunt = taunted
    local curHeckle = heckled
    taunted = false
    heckled = false
    if justAttacked then
        justAttacked = false
        currentdialogue = {"[next]", "NICE TRY, DARLING.", "BUT DR. ALPHYS\nDESIGNED THIS BODY\nTO BE COMPLETELY\nINVULNERABLE!"}
    elseif dialogueItem == "noodles" then
        currentdialogue =
        {
            "[next]",
            "THAT...\nTHAT'S ONE OF\nALPHYS'S FAVORITE\nFOOD...",
            "ALPHYS, I'M SORRY\nFOR HOW I'VE BEEN\nTREATING YOU...",
            "...I HOPE THIS CAN\nMAKE UP FOR IT."
        }
    elseif dialogueItem == "steak" then
        currentdialogue =
        {
            "[next]",
            "I'M FLATTERED THAT\nYOU PURCHASED MY\nONE-OF-A-KIND\nSTEAK.",
            "HOWEVER, IF YOU\nTHINK YOU CAN USE\nTHAT AGAINST ME...",
            "THEN YOU HAVE QUITE\nTHE TWIST COMING\nYOUR WAY!"
        }
    elseif progress == 0 then
        currentdialogue =
        {
            "[next]",
            "MY, MY.\nSO YOU'VE FINALLY\nARRIVED.",
            "AFTER OUR FIRST\nMEETING, I REALIZED...\nSOMETHING GHASTLY.",
            "YOU'RE NOT JUST A\nTHREAT TO MONSTERS...\nBUT HUMANITY, AS\nWELL.",
            "OH MY.\nTHAT'S AN ISSUE.",
            "YOU SEE, I CAN'T BE\nA STAR WITHOUT AN\nAUDIENCE.",
            "AND BESIDES...",
            "THERE ARE SOME\nPEOPLE...\nI WANT TO PROTECT.",
            "AH HA HA.\nEAGER, AS ALWAYS,\nEH?",
            "BUT DON'T TOUCH\nTHAT DIAL.",
            "THERE'S SOMETHING\nYOU HAVEN'T\nACCOUNTED FOR.",
            "AS ANY TRUE FAN\nWOULD KNOW,",
            "I WAS FIRST CREATED\nAS A HUMAN\nERADICATION ROBOT.",
            "IT WAS ONLY AFTER\nBECOMING A STAR\nTHAT I WAS GIVEN A\nMORE...",
            "PHOTOGENIC BODY.",
            "HOWEVER.",
            "THOSE ORIGINAL\nFUNCTIONS HAVE\nNEVER BEEN FULLY\nREMOVED...",
            "COME ANY CLOSER,\nAND I'LL BE FORCED\nTO SHOW YOU...",
            "MY TRUE FORM!",
            ". . .",
            "FINE THEN!",
            "RRRRREADY?\nIIIIIIIT'S SHOWTIME!!!",
            "[noskip][novoice][waitall:6]. . .",
            "BUT!",
            "ON FURTHER\nCONSIDERATION, IT\nWOULD SEEM THAT...",
            "YOU MIGHT NOT\nACTUALLY BE HUMAN.",
            "WHATEVER YOU ARE...",
            "MY HUMAN\nERADICATION\nFUNCTIONS MIGHT\nNOT BE SO...",
            ". . .",
            "...WHY NOT HAVE A\nLITTLE WARM-UP\nBEFORE THE SHOW\nSTARTS?"
        }
    elseif progress == 1 and curTaunt then
        currentdialogue =
        {
            "[next]",
            "OF COURSE THIS ISN'T\nMY FULL POWER.",
            "ARE YOU SAYING YOU\nWANT A FRONT-SEAT\nVIEW OF MY FULL\nFORM?",
            "NO HARM IN SOME\nPRACTICE FOR OUR\nBIG PERFORMANCE!"
        }
        progress = 2
        check = "Trick him into exposing his\rtrue form."
        overrideEncounter = check
    elseif progress == 2 then
        currentdialogue =
        {
            "[next]",
            "DID YOU REALLY\nTHINK YOU COULD\nFOOL ME,",
            "INTO EXPOSING\nMYSELF\nDEFENSELESS?",
            "A TRUE STAR WOULD\nNEVER FALL FOR\nTHAT!"
        }
        progress = 3
    elseif progress == 4 and curTaunt then
        currentdialogue =
        {
            "[next]",
            "AREN'T YOU QUITE\nTHE IMPATIENT ONE!",
            "VERY WELL THEN, IT'S\nRIGHT ABOUT TIME\nFOR OUR SHOW TO\nSTART!",
            "ARE YOU RRRREADY?"
        }
        progress = 5
    elseif progress == 5 then
        currentdialogue =
        {
            "[next]",
            "WELCOME, BEAUTIES,\nTO OUR NEW SHOW...",
            "[noskip]ATTACK OF THE\nKILLER \"HUMAN\"!"
        }
        progress = 6
    elseif progress <= 4 and curHeckle then
        currentdialogue =
        {
            "[next]",
            "DISSATISFIED\nALREADY?",
            "BUT THE SHOW HASN'T\nEVEN STARTED YET,\nDARLING!"
        }
    elseif progress >= 6 and curTaunt then
        currentdialogue =
        {
            "[next]",
            "YOU REALLY AREN'T\nIN A POSITION TO\nTAUNT ME...",
            "WHEN YOU CAN'T EVEN\nPUT A SCRATCH ON\nME, DARLING!"
        }
    elseif progress == 6 and curHeckle then
        currentdialogue =
        {
            "[next]",
            "NOT IMPRESSED?\nI DON'T BLAME YOU.",
            "WE'RE JUST GETTING\nSTARTED!"
        }
        progress = 7
    elseif progress == 7 and curHeckle then
        currentdialogue =
        {
            "[next]",
            "MY MY, NOW THAT'S\nA PROBLEM.",
            "I CAN'T KILL YOU IF\nMY ATTACKS AREN'T\nFLASHY ENOUGH.",
            "WHY NOT SWITCH\nTHINGS UP?"
        }
        progress = 8
    elseif progress == 8 and curHeckle then
        currentdialogue =
        {
            "[next]",
            "YOU STILL DON'T\nTHINK MY ATTACKS\nARE IMPRESSIVE?",
            "THEN HOW ABOUT\nSOMETHING NEW!"
        }
        progress = 9
    elseif progress == 9 and curHeckle then
        currentdialogue =
        {
            "[next]",
            "IF YOU'RE REALLY\nTHAT BORED...",
            "I'LL JUST OVERWHELM\nYOU INTO SUBMISSION!"
        }
        progress = 10
    elseif progress == 10 and curHeckle then
        currentdialogue =
        {
            "[next]",
            "WILL YOU STOP THAT?",
            "WHY DON'T YOU FIGHT\nBACK?",
            "THIS IS NO GOOD FOR\nMY RATINGS!",
            "I AT LEAST NEED TO\nLOOK LIKE A HERO\nFIGHTING AGAINST\nEVIL!"
        }
        progress = 11
    elseif progress == 11 and curHeckle then
        currentdialogue =
        {
            "[next]",
            "STILL HECKLING...?",
            "BUT YOU'LL NEVER\nBEAT ME WITHOUT A\nSENSE OF RHYTHM!"
        }
        progress = 12
    elseif progress == 12 and curHeckle then
        currentdialogue =
        {
            "[next]",
            "AH HA HA...",
            "YOU THINK YOU'RE SO\nSMUG, DON'T YOU?",
            "BUT UP TO NOW,\nI'VE ONLY BEEN\nTESTING YOU...",
            "THAT'S RIGHT!\nIT'S TIME FOR ACT II\nOF TODAY'S FABULOUS\nEPISODE!",
            "NOW THINGS ARE\nREALLY\nACCELERATING!"
        }
        progress = 13
        check = "Keep heckling.\rHe's getting reckless."
        overrideEncounter = check
    elseif progress == 13 and curHeckle then
        currentdialogue =
        {
            "[next]",
            "UGH...",
            "YOU WON'T BE SO\nCONFIDENT IN A FEW\nTURNS."
        }
        progress = 14
    elseif progress == 14 and curHeckle then
        currentdialogue =
        {
            "[next]",
            "STILL...",
            "YOU'RE STILL\nALIVE...?"
        }
        progress = 15
    elseif progress == 15 and curHeckle then
        currentdialogue =
        {
            "[next]",
            "YOU'LL NEVER\nSURVIVE IF YOU CAN'T\nCOVER YOUR BACK!"
        }
        progress = 16
    elseif progress == 16 and curHeckle then
        currentdialogue =
        {
            "[next]",
            "FORGET BEING FANCY\nTHEN!",
            "ALL I NEED TO DO IS\nOVERWHELM YOU!"
        }
        progress = 17
    elseif progress == 17 and curHeckle then
        currentdialogue =
        {
            "[next]",
            "NOW IS THE TIME FOR\nYOUR SHOCKING\nDEFEAT!"
        }
        progress = 18
        overrideEncounter = "Mettaton is losing his cool."
    elseif progress == 18 and curHeckle then
        currentdialogue =
        {
            "[next]",
            "Listen here.",
            "I'm still not sure\nwhether you're\nhuman...",
            "But that SOUL\nyou've got is\ncertainly as strong\nas a human SOUL.",
            "Once I kill you, I'll\nbe able to use it to\ncross the barrier.",
            "And when humanity\nlearns that I'm the\none who saved them\nall...",
            "Then I'll HAVE to\nbecome their biggest\nstar.",
            "Do you understand\nwhy defeating you is\nmy only option?",
            "This episode is\nreaching its climax\nnow!"
        }
        progress = 19
        overrideEncounter = "Mettaton readies his cannon for\ran all-out attack."
    elseif progress == 19 then
        currentdialogue =
        {
            "[next]",
            "I have a confession\nto make.",
            "After you killed\nUndyne, Alphys told\nme to warn ASGORE\nabout you.",
            "Then he would\nabsorb the six human\nSOULs, and destroy\nyou forever.",
            "But I know that if\nhe did that...",
            "...then he would\ndestroy humanity\nnext.",
            "So I never warned\nASGORE. Do you\nunderstand?",
            "I am the only one\nwho can prevent the\ndestruction of\nhumanity.",
            "This isn't just about\nme anymore...",
            "If I lose, then\nthe world gets\ndestroyed.",
            "I AM THE SAVIOR\nOF HUMANITY!"
        }
        progress = 20
        atk = 90
        def = 9
        check = "Now is your chance."
        overrideEncounter = check
    elseif progress == 100 then
        currentdialogue =
        {
            "[next]",
            "[noskip][func:SetHead,Mettaton/MettatonNeoHurt][next]",
            "[noskip]GH...[w:20] GUESS I GOT A\nBIT CARRIED AWAY\nTHERE...",
            "[noskip][func:Whiteout][w:30][next]"
        }
    else
        State("DEFENDING")
        return
    end
    for i = 1, #currentdialogue do
        local line = currentdialogue[i]
        local modify = true
        for j = 1, #blacklist do
            if line == blacklist[j] then
                modify = false
            end
        end
        if modify then
            local newdialogue = "[effect:none]"
            local voice = 1
            local brackets = false
            for j = 1, line:len() do
                if line:sub(j, j) == "[" then
                    brackets = true
                    newdialogue = newdialogue .. line:sub(j, j)
                elseif brackets then
                    if line:sub(j, j) == "]" then
                        brackets = false
                    end
                    newdialogue = newdialogue .. line:sub(j, j)
                else
                    newdialogue = newdialogue .. "[voice:snd_mtt" .. voice .. "]" .. line:sub(j, j)
                    voice = voice + 1
                    if voice > 9 then
                        voice = 1
                    end
                end
            end
            currentdialogue[i] = newdialogue
        end
    end
end

function EnemyDialogueEnding()
    if progress == 0 then
        State("ACTIONSELECT")
    end
end

function ChooseAttack()
    if progress == 1 then
        SetWave("blocks")
        SetArenaSize(180, 16)
    elseif progress == 2 or progress == 4 then
        SetWave("attack1-1")
        SetArenaSize(180, 16)
    elseif progress == 5 then
        SetWave("startShow")
        SetArenaSize(155, 130)
    elseif progress == 6 then
        SetWave("attack1-2")
        SetArenaSize(120, 16)
    elseif progress == 7 then
        SetWave("attack1-3")
        SetArenaSize(155, 16)
    elseif progress == 8 then
        SetWave("attack1-4")
        SetArenaSize(96, 130)
    elseif progress == 9 then
        SetWave("attack1-5")
        SetArenaSize(155, 160)
    elseif progress == 10 then
        SetWave("attack1-6")
        SetArenaSize(155, 160)
    elseif progress == 11 then
        SetWave("attack1-7")
        SetArenaSize(16, 16)
    elseif progress == 12 then
        SetWave("attack1-8")
        SetArenaSize(16, 16)
    elseif progress == 13 then
        SetWave("attack2-1")
        SetArenaSize(160, 160)
    elseif progress == 14 then
        SetWave("attack2-2")
        SetArenaSize(155, 160)
    elseif progress == 15 then
        SetWave("attack2-3")
        SetArenaSize(180, 180)
    elseif progress == 16 then
        SetWave("attack2-4")
        SetArenaSize(16, 16)
    elseif progress == 17 then
        SetWave("attack2-5")
        SetArenaSize(212, 180)
    elseif progress == 18 then
        SetWave("attack2-6")
        SetArenaSize(192, 160)
    elseif progress == 19 then
        SetWave("final-1")
        SetArenaSize(160, 96)
    elseif progress == 20 then
        SetWave("final-2")
        SetArenaSize(16, 16)
    elseif progress == 21 then
        SetWave("blocks")
        SetArenaSize(180, 16)
    end
end

function SetWave(wave)
    Encounter.SetVar("nextwaves", {wave})
end

function SetArenaSize(x, y)
    Encounter.SetVar("arenasize", {x, y})
end

function DefenseEnding()
    local texts =
    {
        "Mettaton.",
        "Smells like Mettaton.",
        "In my way."
    }
    if progress >= 5 then
        table.insert(texts, "Stage lights are blaring.")
        table.insert(texts, "Stage lights are blaring.")
    end
    SetEncounterText(texts)
    if overrideEncounter then
        Encounter.SetVar("encountertext", overrideEncounter)
        overrideEncounter = nil
    end
end

function SetEncounterText(texts)
    Encounter.SetVar("encountertext", texts[math.random(#texts)])
end

function ExitingState(oldstate)
    if oldstate == "DEFENDING" and usedItem then
        if usedItem == "pie" then
            BattleDialog({"You ate the Butterscotch Pie.\nYour HP was maxed out."})
        elseif usedItem == "noodles" then
            dialogueItem = "noodles"
            BattleDialog({"They're better dry.\nYour HP was maxed out."})
        elseif usedItem == "steak" then
            dialogueItem = "steak"
            if Player.hp >= 76 then
                BattleDialog({"You ate the Face Steak.\nYour HP was maxed out."})
            else
                BattleDialog({"You ate the Face Steak.\nYou recovered 60 HP!"})
            end
        elseif usedItem == "snowman1" or usedItem == "snowman2" or usedItem == "snowman3" then
            if Player.hp >= 76 then
                BattleDialog({"You ate the Snowman Piece.\nYour HP was maxed out."})
            else
                BattleDialog({"You ate the Snowman Piece.\nYou recovered 45 HP!"})
            end
        elseif usedItem == "legend1" or usedItem == "legend2" then
            if Player.hp >= 76 then
                BattleDialog({"You eat the Legendary Hero.\nATTACK increased by 4!\nYour HP was maxed out."})
            else
                BattleDialog({"You eat the Legendary Hero.\nATTACK increased by 4!\nYou recovered 40 HP!"})
            end
        end
        canShootLaser = false
        usingBattleDialogue = true
        usedItem = nil
    elseif oldstate == "DEFENDING" and progress == 2 then
        State("ENEMYDIALOGUE")
    elseif oldstate == "DEFENDING" and progress == 5 then
        State("ENEMYDIALOGUE")
    elseif oldstate == "DEFENDING" and progress == 20 then
        progress = 21
    elseif oldstate == "ATTACKING" and progress == 100 then
        State("ENEMYDIALOGUE")
    end
end

function EnteringState(newstate)
    transparent = false
    canShootLaser = (newstate == "ACTIONSELECT" or newstate == "DEFENDING" or newstate == "ITEMMENU" or newstate == "ENEMYSELECT" or newstate == "ACTMENU" or newstate == "MERCYMENU") and not usingBattleDialogue
    usingBattleDialogue = false
    if newstate == "DEFENDING" and progress == 0 then
        progress = 1
        State("ACTIONSELECT")
    elseif newstate == "DEFENDING" and progress == 3 then
        progress = 4
        State("ACTIONSELECT")
    elseif newstate == "DEFENDING" and (dialogueItem == "noodles" or dialogueItem == "steak") then
        dialogueItem = nil
        extraAttack = extraAttack + 2
        BattleDialog({"Mettaton's ATTACK increased!"})
        canShootLaser = false
    elseif newstate == "DEFENDING" and progress == 100 then
        State("DONE")
    elseif newstate == "DEFENDING" then
        transparent = true
        ChooseAttack()
    elseif newstate == "ITEMMENU" then
        SetWave("items")
        SetArenaSize(500, 200)
        State("DEFENDING")
        transparent = true
    elseif newstate == "ATTACKING" and progress >= 20 then
        def = -40000 - Encounter.GetVar("extraAttack")
    end
end

function HandleSpare()
    State("ENEMYDIALOGUE")
end

function HandleAttack(attackstatus)
    if attackstatus == -1 then
        -- player pressed fight but didn't press Z afterwards
    else
        if progress == 1 and not triedHit then
            triedHit = true
            justAttacked = true
        end
        if progress >= 20 then
            hp = 1
            shakeTimer = 90
            SetHead("Mettaton/MettatonNeoGlareMad")
            progress = 100
            Audio.Stop()
        end
    end
end
 
-- This handles the commands; all-caps versions of the commands list you have above.
function HandleCustomCommand(command)
    if command == "TAUNT" then
        taunted = true
    elseif command == "HECKLE" then
        heckled = true
    end
    State("ENEMYDIALOGUE")
end

function HandleItem(ItemID)
    
end
