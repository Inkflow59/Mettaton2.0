-- A basic monster script skeleton you can copy and modify for your own creations.
comments = {"Smells like the work\rof an enemy stand.", "Poseur is posing like his\rlife depends on it.", "Poseur's limbs shouldn't be\rmoving in this way."}
commands = {"Talk", "Beg"}
randomdialogue = {"Random\nDialogue\n1.", "Random\nDialogue\n2.", "Random\nDialogue\n3."}

sprite = "poseur" --Always PNG. Extension is added automatically.
name = "Mettaton NEO 2.0"
hp = 9999999
atk = 100
def = 100
check = "This time, one hit will never be sufficient."
dialogbubble = "right" -- See documentation for what bubbles you have available.
canspare = false
cancheck = true
talkcount = 0

-- Happens after the slash animation but before 
function HandleAttack(attackstatus)
    if attackstatus == -1 then
function EndLife ()
    Kill()
end
end
-- This handles the commands; all-caps versions of the commands list you have above.
function HandleCustomCommand(command)
    if command == "Talk" then
        if talkcount == 0 then
            talkcount = talkcount + 1
            BattleDialog {("You say that his show sucks !")}
            currentdialogue = ("Shut up, dirty monster !")
        elseif talkcount == 1 then
            talkcount == talkcount + 1
            BattleDialog{("He doesn't want to speak anymore !")}
            currentdialog = ("You killed everyone, except me !")
        end
    end
end
