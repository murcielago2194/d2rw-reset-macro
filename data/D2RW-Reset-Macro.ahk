;============================================================
;    INIT
;============================================================

#SingleInstance Force

CoordMode, Mouse, Client
CoordMode, ToolTip, Screen

SetWorkingDir %A_ScriptDir%
iniPath := A_ScriptDir "\settings.ini"

;============================================================
;    DELAYS
;============================================================

deleteDelay := 5050
delay := 250

;============================================================
;    LOAD SETTINGS.INI
;============================================================

; Char settings
IniRead, name, %iniPath%, Settings, name
IniRead, hero, %iniPath%, Settings, hero
IniRead, delete, %iniPath%, Settings, delete
IniRead, version, %iniPath%, Settings, version
IniRead, hardcore, %iniPath%, Settings, hardcore

; LiveSplit
IniRead, liveSplitResetHotkey, %iniPath%, LiveSplit, reset
IniRead, liveSplitStartHotkey, %iniPath%, LiveSplit, start

; Reset marco hotkey
IniRead, macroHotkey, %iniPath%, Hotkeys, macro
Hotkey, %macroHotkey%, Reset

; Show UI hotkey
IniRead, showHotkey, %iniPath%, Hotkeys, show
Hotkey, %showHotkey%, Show

return

;============================================================
;    SHOW UI
;============================================================

Show:
	Run, ..\D2RW.ahk

return

;============================================================
;    RESET
;============================================================

Reset:

	; ----- Check if D2R is running -------------------------------------------
	
	if !WinActive("ahk_exe D2R.exe")
	{
        return
	}

    ; ----- Character position -----------------------------------------------

    rect := WindowGetRect("Diablo II: Resurrected") 
    
    heroXAmazon := rect.width * 0.175
    heroXAssassin := rect.width * 0.263
    heroXNecromancer := rect.width * 0.352
    heroXBarbarian := rect.width * 0.444
    heroXPaladin := rect.width * 0.552
    heroXSorceress := rect.width * 0.642
    heroXWarlock := rect.width * 0.725
    heroXDruid := rect.width * 0.859   
    
    heroX := heroX%hero%
    heroY := rect.height * 0.503

    ; ----- LiveSplit - Reset -------------------------------------------------
    
    Send %liveSplitResetHotkey% 
    BlockInput, On

    ; ----- Save & Exit -------------------------------------------------------
    
    Send {Esc}
    MouseClick, left, rect.width * 0.5, rect.height * 0.438
    wait()

    ; ----- Delete character --------------------------------------------------
    
    if (delete)
    {
        Sleep, %delay%
        MouseMove, rect.width * 0.866, rect.height * 0.937
		MouseClick
        MouseMove, rect.width * 0.427, rect.height * 0.538
		Sleep, %delay%
        Send {LButton Down}
        Sleep, %deleteDelay%
        Send {LButton Up}
		Sleep, %delay%
    }

    ; ----- Create new character ----------------------------------------------
    
    MouseClick, left, rect.width * 0.891, rect.height * 0.868
    wait()

    ; ----- Select hero class -------------------------------------------------
    
    MouseClick, left, %heroX%, %heroY%

    ; ----- Character name ----------------------------------------------------
    
    if (!delete)
    {
        Loop, 5 
        {
            letters := "bcdfghjklmnpqrstvwxz"
            random, rand, 1, % strlen(letters)
            randomLetter := strsplit(letters) 
            Send, % randomLetter[rand]
        }
        
        Send _%name%
    } 
    else
    {
       Send %Name%
    }

    ; ----- Versions select (Classic/LoD/Warlock) -----------------------------
    
    if (version < 3)
    {
        MouseClick, left, rect.width * 0.850, rect.height * 0.855
        Sleep, %delay%
    
        if (version == 1)
        {
            MouseClick, left, rect.width * 0.850, rect.height * 0.790
        }
        
        if (version == 2)
        {
            MouseClick, left, rect.width * 0.850, rect.height * 0.812
        }
        
        Sleep, %delay%
    }

    ; ----- Create (SC/HC) ----------------------------------------------------
    
    if (hardcore)
    {
        MouseClick, left, rect.width * 0.500, rect.height * 0.881
        MouseClick, left, rect.width * 0.914, rect.height * 0.920
        Sleep, %delay%
        MouseClick, left, rect.width * 0.428, rect.height * 0.536
    } 
    else 
    {
        MouseClick, left, rect.width * 0.914, rect.height * 0.920
    }
   
    ; ----- Move mouse to center ----------------------------------------------
    
    MouseMove, (rect.width/2), (rect.height/2)

    ; ----- LiveSplit - Start -------------------------------------------------

    BlockInput Off    
    Send %liveSplitStartHotkey%
    
return

;============================================================
;    GET CLIENT SIZE
;============================================================

WindowGetRect(windowTitle*) 
{
    if (hwnd := WinExist(windowTitle*)) 
    {
        VarSetCapacity(rect, 16, 0)
        DllCall("GetClientRect", "Ptr", hwnd, "Ptr", &rect)
        return {width: NumGet(rect, 8, "Int"), height: NumGet(rect, 12, "Int")}
    }
}

;============================================================
;    WAITING
;============================================================

wait()
{
    Sleep, 1000
    
    Start:    
    ImageSearch, FoundX, FoundY, 100, 100, 200, 200, black.png    
    
    if (!ErrorLevel)
    {        
        goto, start
    } 
    
    return
}