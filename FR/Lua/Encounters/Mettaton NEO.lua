music = "mus_mettatonbattle"
encountertext = "Mettaton bloque le chemin !"

pie = true
noodles = true
steak = true
snowman1 = true
snowman2 = true
snowman3 = true
legend1 = true
legend2 = true
extraAttack = 0

easyMode = false

enemies = { "mettaton" }

--screen size: 640 x 480

function EnteringState(newstate, oldstate)
    enemies[1].Call("ExitingState", oldstate)
    enemies[1].Call("EnteringState", newstate)
end

function Update()
    enemies[1].Call("UpdateAnimation")
    enemies[1].Call("UpdateMusic")
    enemies[1].Call("CheckLaser")
end

function EncounterStarting()
    enemies[1].Call("EncounterStarting")
end

function EnemyDialogueStarting()
    enemies[1].Call("EnemyDialogueStarting")
end

function EnemyDialogueEnding()
    enemies[1].Call("EnemyDialogueEnding")
end

function DefenseEnding()
    enemies[1].Call("DefenseEnding")
end

function HandleSpare()
    enemies[1].Call("HandleSpare")
end

function HandleItem(ItemID)
    enemies[1].Call("HandleItem", ItemID)
end
