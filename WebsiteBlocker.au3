#include <MsgBoxConstants.au3>
#Include "HotKey.au3"
#include <Timers.au3>

;~ HotKeySet("^!t", "ToggleBlocking")
HotKeySet("{ESC}", "Terminate")

Global Const $VK_T = 0x54

_HotKey_Assign(BitOR($CK_WIN, $CK_ALT, $VK_T), 'ToggleBlocking')

While 1
    Sleep(100)
WEnd

Func ToggleBlocking()
    MsgBox($MB_SYSTEMMODAL, "here", "here")
    _Timer_SetTimer($hGUI, 1000, "_UpdateStatusBarClock")
EndFunc

Func Terminate()
    Exit
EndFunc