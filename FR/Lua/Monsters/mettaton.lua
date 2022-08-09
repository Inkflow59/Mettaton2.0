commands = {"Surcharger", "Bloquer"}

sprite = "empty"
name = "Mettaton"
hp = 30000
atk = 30
def = 255
check = "Son corps repousse les\rattaques !."
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
    local curSurcharger = taunted
    local curBloquer = heckled
    taunted = false
    heckled = false
    if justAttacked then
        justAttacked = false
        currentdialogue = {"[next]", "BEL ESSAI, HUMAIN!", "MAIS DR.ALPHYS\nM'A FAIT POUR ETRE\nCOMPLETEMENT\nINVULNERABLE!"}
    elseif dialogueItem == "noodles" then
        currentdialogue =
        {
            "[next]",
            "C'EST ...\nLA NOURRITURE PREFEREE\nDE ALPHYS",
            "ALPHYS, JE SUIS DESOLE\nPOUR COMMENT JE TE\nTRAITAIS",
            "...J'ESPERE QUE\nJE POURRAIS ME\nRATTRAPER...."
        }
    elseif dialogueItem == "steak" then
        currentdialogue =
        {
            "[next]",
            "JE SUIS FLATTE QUE\nTU AIES ACHETE\nUNE SORTE DE\nSTEAK.",
            "MAIS BON,\nSI TU PENSES POUVOIR\nL'UTILISER CONTRE MOI!",
            "TU TE METS LE\nDOIGT DANS\nL'OEIL"
        }
    elseif progress == 0 then
        currentdialogue =
        {
            "[next]",
            "MY, MY.\nDONC TU ES ENFIN\nARRIVE.",
            "APRES NOTRE\nPREMIER RENCONTRE\nJ'AI REALISE",
            "QUELQUE CHOSE",
            "TU N'AS PAS JUSTE\nTUE LES MONSTRES.\nMAIS L'HUMANITE",
            "AUSSI",
            "TU VOIS, JE PEUX ETRE\nUNE STAR SANS\nAUDIENCE.",
            "MAIS...",
            "JE VEUX\nPROTEGER MES\nAMIS.",
            "ENFIN.\nCEUX QUI SONT\nTOUJOURS LA",
            "JE FERAIT TOUT\nMON POSSIBLE",
            "QUITTE A DONNER\nTOUT CE QUE\nJ'AI POUR",
            "Y ARRIVER!",
            "TON LOVE EST\nTRES ELEVE",
            "SOUS CETTE FORME\nJE N'AI AUCUNE\nCHANCE.",
            "ALORS POUR POUVOIR\nEN VENIR A BOUT\nDE TOI",
            "J'UTILISERAI\nMA FORME\nLA PLUS PUISSANTE",
            "MAIS\nPEU IMPORTE.",
            "UNE FOIS MA\nPLEINE PUISSANCE\nDELIVREE",
            "J'ACCEDERAI ENFIN\nA CE QUE TU ATTENDS\nLE PLUS",
            "MA VRAIE FORME!",
            ". . .",
            "BON, TRES BIEN!",
            "PREEEEEEET?",
            "CETTE FOIS\nCE SERA MON\nGRAND FINAL!",
            ". . .",
            "PREPARE-TOI",
            "COMME JE SUIS\nDU GENRE PLUTOT\nFAIR-PLAY",
            "JE VAIS TE\nLAISSER UN PEU\nDE REPIT",
            "LANCEMENT DU\nPROTOCOLE!",
            "FONCTIONS\nANNIHILATIRCES\nHUMAINES EN",
            "COURS DE\nCHARGEMENT!",
            "ET SI ON\nS'ECHAUFFERAIT\nPAS AVANT QUE",
            "LE GRAND\nSPECTACLE COMMENCE?"
        }
    elseif progress == 1 and curSurcharger then
        currentdialogue =
        {
            "[next]",
            "BIEN SUR,\nCE N'EST PAS MON VRAI POUVOIR.",
            "EST-CE QUE TU\nVEUX ETRE AU\nPREMIER RANG",
            "POUR VOIR\nMA FORME FINALE?"
        }
        progress = 2
        check = "Surchage-le pour voir sa\rforme finale!."
        overrideEncounter = check
    elseif progress == 2 then
        currentdialogue =
        {
            "[next]",
            "EST-CE QUE TU PENSES\nSINCEREMENT QUE TU PEUX\nM'AVOIR,",
            "EN M'EXPOSANT\nA LA SURCHARGE?",
            "JE NE TOMBERAI\nPAS POUR\nSI PEU!"
        }
        progress = 3
    elseif progress == 4 and curSurcharger then
        currentdialogue =
        {
            "[next]",
            "EST-CE QUE TU SERAIS\nIMPATIENT?",
            "TRES BIEN, C'EST L'HEURE\nD'AVERTIR TOUT LE MONDE,\nLE SPECTACLE...",
            "COMMEEEENCE!"
        }
        progress = 5
    elseif progress == 5 then
        currentdialogue =
        {
            "[next]",
            "BIENVENUES MES BEAUTES,\nDANS NOTRE NOUVEAU SPECTACLE...",
            "[noskip]ATTAQUE DU MEURTIER\n\"HUMAIN\"!"
        }
        progress = 6
    elseif progress <= 4 and curBloquer then
        currentdialogue =
        {
            "[next]",
            "DEJA DECU?",
            "MAIS LE SPECTACLE N'A\nQU'A PEINE\nCOMMENCE!"
        }
    elseif progress >= 6 and curSurcharger then
        currentdialogue =
        {
            "[next]",
            "TU N'ES PAS DANS\nLA POSITION DE ME\nSURCHARGER...",
            "QUAND TU NE PEUX MEME\nPAS ME FAIRE UNE\nEGRATINURE!"
        }
    elseif progress == 6 and curBloquer then
        currentdialogue =
        {
            "[next]",
            "PAS IMPRESSIONNE?\nJE NE TE BLAME\nPAS.",
            "ON VIENS JUSTE DE\nCOMMENCER!"
        }
        progress = 7
    elseif progress == 7 and curBloquer then
        currentdialogue =
        {
            "[next]",
            "MY MY, MAINTENANT\nC'EST UN PROBLEME.",
            "JE NE PEUX TE TUER\nSI TES ATTAQUES\nNE SONT PAS FLASHY!.",
            "POURQUOI NE PAS\nSWITCHER CA?"
        }
        progress = 8
    elseif progress == 8 and curBloquer then
        currentdialogue =
        {
            "[next]",
            "TU NE PENSES TOUJOURS\nPAS QUE MES ATTAQUES\nSONT IMPRESSIONANTES?",
            "ALORS QUE DIRAIS-TU\nD'ESSAYER QUELQUE CHOSE\nDE NOUVEAU?"
        }
        progress = 9
    elseif progress == 9 and curBloquer then
        currentdialogue =
        {
            "[next]",
            "SI TU ES SI\nENNUYE PAR MES ACTIONS",
            "JE VAIS TE PLONGER\nEN ENFER!"
        }
        progress = 10
    elseif progress == 10 and curBloquer then
        currentdialogue =
        {
            "[next]",
            "VAS-TU ARRETER CA?",
            "POURQUOI TU NE TE\nBATS PAS?",
            "CE N'EST PAS BON POUR\nMON AUDIMAT!",
            "ILS VEULENT QUE TU TE\nCOMPORTE COMME\nUN HEROS!"
        }
        progress = 11
    elseif progress == 11 and curBloquer then
        currentdialogue =
        {
            "[next]",
            "TOUJOURS A BLOQUER?",
            "MAIS TU NE POURRAS\nJAMAIS ME BATTRE SANS AVOIR\nLE SENS DU RYTHME!"
        }
        progress = 12
    elseif progress == 12 and curBloquer then
        currentdialogue =
        {
            "[next]",
            "AH HA HA...",
            "TU ES SI ARROGANT\nN'EST-CE PAS?",
            "MAIS BON, JUSQUE LA\nJE NE FAISAIS QUE\nTE TESTER...",
            "EN EFFET!\nIL EST L'HEURE DE\nL'ACTE II!",
            "MAINTENANT\nLES CHOSES\nS'ACCELERENT!"
        }
        progress = 13
        check = "Continue de l'Bloquer.\rTu vas pouvoir buter ce pretentieux!."
        overrideEncounter = check
    elseif progress == 13 and curBloquer then
        currentdialogue =
        {
            "[next]",
            "EUH...",
            "TU NE SERAS PAS SI\nCONFIANT DANS QUELQUES\nTOURS."
        }
        progress = 14
    elseif progress == 14 and curBloquer then
        currentdialogue =
        {
            "[next]",
            "TOUJOURS...",
            "TU ES TOUJOURS\nVIVANT...?"
        }
        progress = 15
    elseif progress == 15 and curBloquer then
        currentdialogue =
        {
            "[next]",
            "TU NE SURVIVERAS\nJAMAIS SI TU NE COUVRES\nPAS TES ARRIERES!"
        }
        progress = 16
    elseif progress == 16 and curBloquer then
        currentdialogue =
        {
            "[next]",
            "N'OUBLIE PAS\nD'ETRE DEFENSIF\nALORS!",
            "TOUT CE QUE J'AI\nFAIRE C'EST DE\nTE BLOQUER!"
        }
        progress = 17
    elseif progress == 17 and curBloquer then
        currentdialogue =
        {
            "[next]",
            "MAINTENANT\nC'EST L'HEURE DE\nTA MORT!"
        }
        progress = 18
        overrideEncounter = "Mettaton 2.0 devient faible."
    elseif progress == 18 and curBloquer then
        currentdialogue =
        {
            "[next]",
            "Ecoute-moi.",
            "Je ne suis pas \nsur que tu es\nhumain...",
            "Mais cette ame\nque tu as\nest plus forte qu'une",
            "Simple ame\nhumaine.",
            "Une fois morte\nje pourrais enfin \nouvrir la barriere.",
            "Et quand l'humanite\napprendra que je suis\nson sauveur...",
            "Alors je serais\nla plus grande star",
            "INTERNATIONALE!",
            "Comprends-tu\npourquoi te tuer est\navantageux pour moi?",
            "Cet episode atteint\nson zenith",
            "MAINTENANT!"
        }
        progress = 19
        overrideEncounter = "Mettaton prepare son canon\rpour une grande attaque."
    elseif progress == 19 then
        currentdialogue =
        {
            "[next]",
            "J'ai quelque-chose\na te dire.",
            "Apres que tu aie tue\nUndyne, Alphys m'a dit\nde te prevenir",
            "Asgore va te\ntuer",
            "Car il voudrait\nabsorber ton AME et nous\nliberer de cet endroit.",
            "Mais je sais que s'il\nfait ca...",
            "...alors il detruira\nl'humanite toute\nentiere.",
            "Alors je n'ai jamais\nprevenu ASGORE\nTu comprends?",
            "Je suis le seul\nqui peut arreter la\ndestruction de",
            "L'humanite",
            "C'est juste que tu n'as\npas a me tuer",
            "Si je perd \nle monde sera totalement\ndetruit.",
            "JE SUIS LE SAUVEUR\nDE L'HUMANITE!"
        }
        progress = 20
        atk = 90
        def = 9
        check = "C'est ta chance."
        overrideEncounter = check
    elseif progress == 100 then
        currentdialogue =
        {
            "[next]",
            "[noskip][func:SetHead,Mettaton/MettatonNeoHurt][next]",
            "[noskip]JE...[w:20] JE PENSE QUE JE\nME SUIS UN PEU\nEMPORTE...",
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
        "Ca sent le Mettaton.",
        "Sur mon chemin."
    }
    if progress >= 5 then
        table.insert(texts, "Les lumieres de la scene brillent.")
        table.insert(texts, "Les lumieres de la scene brillent.")
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
            BattleDialog({"Tu as mange la tarte au caramel.\nTes PVs sont au maximum."})
        elseif usedItem == "noodles" then
            dialogueItem = "noodles"
            BattleDialog({"Elles sont meilleures seches.\nTes PVs sont au maximum."})
        elseif usedItem == "steak" then
            dialogueItem = "steak"
            if Player.hp >= 76 then
                BattleDialog({"Tu as mange le Steak.\nTes PVs sont au maximum."})
            else
                BattleDialog({"Tu as mange le Steak.\nTu recuperes 60 PVs!"})
            end
        elseif usedItem == "snowman1" or usedItem == "snowman2" or usedItem == "snowman3" then
            if Player.hp >= 76 then
                BattleDialog({"Tu as mange le morceau de bonhomme de neige.\nTes PVs sont au maximum."})
            else
                BattleDialog({"Tu as mange le morceau de bonhomme de neige.\nTu recuperes 40 PVs!"})
            end
        elseif usedItem == "legend1" or usedItem == "legend2" then
            if Player.hp >= 76 then
                BattleDialog({"Tu as mange le Heros Legendaire.\nTon attaque augmente de 4!\nTes PVs sont au maximum."})
            else
                BattleDialog({"Tu as mange le Heros Legendaire.\nTon attaque augmente de 4!\nTu recuperes 40 PVs!"})
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
        BattleDialog({"L'attaque de Mettaton augmente!"})
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
    if command == "SURCHARGER" then
        taunted = true
    elseif command == "BLOQUER" then
        heckled = true
    end
    State("ENEMYDIALOGUE")
end

function HandleItem(ItemID)
    
end
