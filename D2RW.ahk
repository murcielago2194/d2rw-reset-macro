;============================================================
;	INIT
;============================================================

#NoEnv
#SingleInstance Force
SendMode Input

;============================================================
;	DIR
;============================================================

SetWorkingDir %A_ScriptDir%
iniPath := A_ScriptDir "\data\settings.ini"

;========================================================================================
;	LISTS
;========================================================================================

fkeys := "F1|F2|F3|F4|F5|F6|F7|F8|F9|F10|F11|F12"
misckeys := "Insert|Delete|Home|End|PgUp|PgDn"
letters := "A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z"
numbers := "0|1|2|3|4|5|6|7|8|9"

keys := fkeys "|" misckeys "|" letters "|" numbers

cchars := "Amazon|Necromancer|Barbarian|Paladin|Sorceress"
lchars := cchars . "|Assassin|Druid"
wchars := lchars . "|Warlock"

versions := "Classic|LOD|Warlock"

;========================================================================================
;	LOAD SETTINGS.INI
;========================================================================================

IniRead, vMacro, %iniPath%, Hotkeys, macro,
IniRead, vShow,  %iniPath%, Hotkeys, show,
IniRead, vReset, %iniPath%, LiveSplit, reset,
IniRead, vStart, %iniPath%, LiveSplit, start,

IniRead, vName, %iniPath%, Settings, name,
IniRead, vHero, %iniPath%, Settings, hero,
IniRead, vVersion, %iniPath%, Settings, version,
IniRead, vHardcore, %iniPath%, Settings, hardcore,

IniRead, vInit, %iniPath%, Misc, init,
IniRead, vTab, %iniPath%, Misc, tab,

;========================================================================================
;	GUI
;========================================================================================

; Gui init 
Gui, +DPIScale
Gui, Font, s10, Segoe UI
Gui, Margin, 15, 15

; Tabs
Gui, Add, Tab2, vTabs w390 h270 +HwndhTab, Char|Hotkeys

; ---------------------------------------------

Gui, Tab, 1

; Character options label
Gui, Add, Progress, x30 y60 w360 h1 BackgroundBlack cBlue
Gui, Font, s11 Bold
Gui, Add, Text, x150 y65, Character Options
Gui, Font
Gui, Add, Progress, x30 y90 w360 h1 BackgroundBlack cBlue

; Name
Gui, Font, s10, Segoe UI, Normal
Gui, Add, Edit, x30 y110 w150 +HwndhName gValidateName Limit9, %vName%

; Version
Gui, Add, ListBox, x30 y158 r3 +HwndhVersion gVersionSelect, %versions%
GuiControl, Choose, %hVersion%, %vVersion%

; Hardcore
Gui, Add, CheckBox, x30 y237 w150 h25 +HwndhHardcore +0x1003, Hardcore
GuiControl,, %hHardcore%, %vHardcore%

; Characters
GuiControlGet, value,, %hVersion%

switch value
{	
	case "Classic": tempChars = %cchars%
	case "LOD": tempChars = %lchars%
	case "Warlock": tempChars = %wchars%
}
	
Gui, Add, ListBox, x240 y110 r8 Sort +HwndhChars, %tempChars%
GuiControl, ChooseString, %hChars%, %vHero%

; ---------------------------------------------

Gui, Tab, 2

; Macro hotkeys label
Gui, Add, Progress, x30 y60 w360 h1 BackgroundBlack cBlue
Gui, Font, s11 Bold
Gui, Add, Text, x160 y65, Macro Hotkeys
Gui, Font
Gui, Add, Progress, x30 y90 w360 h1 BackgroundBlack cBlue

; Hotkeys rows
Gui, Font, s10, Segoe UI, Normal
AddHotkeys("Show UI", "Show", 30, 110, vShow)
AddHotkeys("Reset Macro", "Macro", 30, 150, vMacro)
AddHotkeys("Split Reset", "Reset", 30, 190, vReset)
AddHotkeys("Split Start", "Start", 30, 230, vStart)

Gui, Tab

; ---------------------------------------------

; Start button
Gui, Add, Button, xm w390 h30 gSaveExit vStart Default, Save and Start macro

; Render
Gui, Show,, D2RW - Reset Macro

; First launch
if (vInit == 0) 
{
	GuiControl, Choose, Tabs, 2	
	Gui, Tab, 2
	Gui, Font, cRed Bold
	Gui, Add, Text, x100 y260, CONFIG CHARACTER ON FIRST TAB
	Gui, Font
	Gui, Tab
} 
else 
{
	GuiControl, ChooseString, %hTab%, %vTab%
}

GuiControl, Focus, Start

return

;========================================================================================
;	VALIDATE NAME
;========================================================================================

ValidateName:

	; Remove non-letter chars from name
	GuiControlGet, text,, %hName%	
	text := RegExReplace(text, "[^A-Za-z]")	
	GuiControl,, %hName%, %text%
	;ControlSend,, ^{End}, ahk_id %hName%
	GuiControl, Focus, %hName%
	SendInput, ^{End}

return

;========================================================================================
;	VERSION SELECT
;========================================================================================

VersionSelect:

	; Get version
	GuiControlGet, value,, %hVersion%
			
	; Choose character list
	switch value
    {	
        case "Classic": tempChars = %cchars%
        case "LOD": tempChars = %lchars%
        case "Warlock": tempChars = %wchars%
    }
	
	; Reload characters
	GuiControl,, %hChars%, |
	GuiControl,, %hChars%, %tempChars%

return

;========================================================================================
;	ADD HOTKEYS
;========================================================================================

AddHotkeys(label, id, x, y, value) 
{	
	global

	; Label
    Gui, Add, Text, x%x% y%y% w200, %label%
		
	; Control
	opts := "x" x+110 " y" y " w50 +HwndhControl" id (InStr(value, "^") ? " Checked" : "")
    Gui, Add, CheckBox, %opts%, Ctrl
	
	; Shift
	opts := "x" x+160 " y" y " w50 +HwndhShift" id (InStr(value, "+") ? " Checked" : "")	
	Gui, Add, CheckBox, %opts%, Shift
	
	; Alt
	opts := "x" x+215 " y" y " w50 +HwndhAlt" id (InStr(value, "!") ? " Checked" : "")	
    Gui, Add, CheckBox, %opts%, Alt
	
	; Key
	opts := "x" x+265 " y" y-2 " w90 +HwndhKey" id 
    Gui, Add, DropDownList, %opts%, %keys%
		
	; Remove brackets from key and convert to uppercase
	value := RegExReplace(value, "[\^\+\!\{\}]")
	isLetter := RegExMatch(value, "^[A-Za-z]$")
	value := (isLetter)? ToUpper(value) : value
	
	; Set key dropdown list by index
	hotkeyId = hKey%id%	
	index := GetIndex(keys, value)	
	GuiControl, Choose, % %hotkeyId%, %index%
}

;========================================================================================
;	SAVE & EXIT
;========================================================================================

SaveExit:

	; Save char and hotkeys
	charSaved := SaveCharacter()
	hotkeySaved := SaveHotkeys()
	
	if (charSaved && hotkeySaved)
	{
		; Save active tab
		GuiControlGet, activeTab,, %hTab%
		IniWrite, %activeTab%, %iniPath%, Misc, tab

		; Save inited state
		IniWrite, 1, %iniPath%, Misc, init
		
		; Run reset macro
		Run, data\D2RW-Reset-Macro.ahk
		
		ExitApp
	}
	
return

;========================================================================================
;	SAVE CHARACTER
;========================================================================================

SaveCharacter()
{
	global 	
	
	; Character
	GuiControlGet, hero,, %hChars%
	
	if (!hero)
	{
		MsgBox Select the character!
		return false
	}

	; Name	
	GuiControlGet, name,, %hName%
	
	if (!name)
	{
		MsgBox Invalid Name!
		return false
	}
	
	; Version
	GuiControlGet, value,, %hVersion%
	version := GetIndex(versions, value)	

	; Hardcore
	GuiControlGet, hardcore,, %hHardcore%
	
	; Save character data
	IniWrite, %hero%, %iniPath%, Settings, hero
	IniWrite, %name%, %iniPath%, Settings, name	
	IniWrite, %version%, %iniPath%, Settings, version	
	IniWrite, %hardcore%, %iniPath%, Settings, hardcore	
	
	return true
}

;========================================================================================
;	SAVE HOTKEYS
;========================================================================================

SaveHotkeys()
{
	; Build hotkeys	(brackets needed true/false)
	showHK := GetHotkey("Show", false)
    macroHK := GetHotkey("Macro", false)
    resetHK := GetHotkey("Reset", true)
    startHK := GetHotkey("Start", true)
	
	; Hotkey conflict check
	_showHK := RegExReplace(showHK, "[\{\}]")
	_macroHK := RegExReplace(macroHK, "[\{\}]")
	_resetHK := RegExReplace(resetHK, "[\{\}]")
	_startHK := RegExReplace(startHK, "[\{\}]")
	
	; Hotkey missing
	if !(_showHK && _macroHK && _resetHK && _startHK)
	{
		MsgBox Hotkey Missing!
		return false
	}
	
	; Hotkey conflict
	if (_showHK = _macroHK || _showHK = _resetHK || _showHK = _startHK 
	|| _macroHK = _resetHK || _macroHK = _startHK || _resetHK = _startHK)
	{
		MsgBox Hotkey Conflict!
		return false
	}

	; Save hotkeys
    IniWrite, %showHK%, %iniPath%, Hotkeys, show
	IniWrite, %macroHK%, %iniPath%, Hotkeys, macro
    IniWrite, %resetHK%, %iniPath%, LiveSplit, reset
    IniWrite, %startHK%, %iniPath%, LiveSplit, start
	
	return true
}

;========================================================================================
;	GET HOTKEY
;========================================================================================

GetHotkey(name, bracketsNeeded) 
{
	global 	
	out := ""
	
	; Control
	id = hControl%name%  
	GuiControlGet, state,, % %id%	
	out .= (state == 1) ? "^" : ""
	
	; Shift
	id = hShift%name%  
	GuiControlGet, state,, % %id%		
	out .= (state ==1 ) ? "+" : ""
	
	; Alt
	id = hAlt%name%  
	GuiControlGet, state,, % %id%	
	out .= (state == 1) ? "!" : ""	
		
    ; Key
	id = hKey%name%  
	GuiControlGet, value,, % %id%	
	
	isLetter := GetIndex(letters, value) > 0
	isFunctionKey := GetIndex(fkeys, value) > 0
	isMiscKey := GetIndex(misckeys, value) > 0
	
	needBrackets := bracketsNeeded && (isFunctionKey || isMiscKey)
	
	; Lower key / brackets
	value := (isLetter)? ToLower(value) : value
	out .= (needBrackets) ? "{" value "}" : value

    return out
}

;========================================================================================
;	GET LIST INDEX BY VALUE
;========================================================================================

GetIndex(arrayIn, valueIn)
{
	array := StrSplit(arrayIn, "|")
	
	for index, value in array
	{
		if (value == valueIn)
		{
			return index
		}
	}
	
}

;========================================================================================
;	MISC
;========================================================================================

ToLower(value)
{
	StringLower, value, value
	return value
}

ToUpper(value)
{
	StringUpper, value, value
	return value
}

;========================================================================================
;	CLOSE
;========================================================================================

GuiEscape:
GuiClose:
ExitApp