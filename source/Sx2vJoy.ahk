/*
 * * * Compile_AHK SETTINGS BEGIN * * *

[AHK2EXE]
Exe_File=%In_Dir%\Sx2vJoy.exe
No_UPX=1
Created_Date=1
Execution_Level=4
[VERSION]
Set_Version_Info=1
File_Version=1.2.5.10
Inc_File_Version=0
Product_Version=1.1.22.9
Set_AHK_Version=1
[ICONS]
Icon_1=%In_Dir%\Sx2vJoy.ico

* * * Compile_AHK SETTINGS END * * *
*/

; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Win 7 x86
; Author:         Mark Chong / Clive Galway
;
; Script Function:
;   Receives HID signals from 3DConnexion devices and chucks them into vJoy axes and buttons
;
; vJoy: http://vjoystick.sourceforge.net
; vJoy/AHK Lib: drop script into same folder as UJR
; AHKHID: https://github.com/jleb/AHKHID - drop this into same folder as script
; 
; original SpaceNavigator to PPJoy script by moatdd: http://www.3dconnexion.com/forum/viewtopic.php?t=4315#p33329
; vJoy integration and logarithmic acceleration by evilC: http://forums.frontier.co.uk/showpost.php?p=423584&postcount=27 & http://forums.frontier.co.uk/showpost.php?p=449012&postcount=37
; most of everything else by Lasse B.
;
; Special Thanks for providing button data:
; Rissen - SpaceMouse Pro
; CommanderHaggard - SpaceBall 5000 USB
; Asura - SpacePilot
; Cmdr Zok - SpaceExplorer
; Legendman - SpaceMouse Wireless
; MaraKan - SpacePilot Pro
; Shadys - SpaceMouse Plus (XT) USB

#NoTrayIcon
#singleinstance off

param1 := param2 := param3 := param4 := param5 := param6 := ""
loop, %0%
   param%A_Index% := %A_Index%

; param1 = keyword; param2 = vJoy ID; param3 = vendor ID; param4 = product ID; param5 = exe to restart; param6 = PID to monitor
if (param1 = "watchdog") and (param2 <> "") and (param3 <> "") and (param4 <> "") and (param5 <> "") and (param6 <> "")
   _watchdog(param2,param3,param4,param5,param6)

version := "1.2 build 5 test 11"

Menu, Tray, nostandard
Menu, Tray, add, Open Configuration GUI, gui
Menu, Tray, add
Menu, Tray, add, Open Joystick Properties, joy
Menu, Tray, add, About, about
Menu, Tray, add, Exit, AppQuit
Menu, Tray, icon

#Include %A_ScriptDir%\Libraries\AHKHID.ahk ; include the HID library
Process, Priority, , High
coordmode, tooltip, screen
#HotkeyInterval 1000
#MaxHotkeysPerInterval 1000

SpaceBallSwap := 0
if fileexist(A_Scriptdir "\swap.txt")
   SpaceBallSwap := 1


smoothing := 99.9 ; currently without effect

; ---------- out of neccessity ----------
if not fileexist(A_ScriptDir "\config.ini")
{
   msgbox,16,Sx2vJoy %version%,config.ini not found. Make sure it's in the same directory as Sx2vJoy.exe.`n`nExiting.
   ExitApp
}
DllCall("kernel32.dll\SetProcessShutdownParameters", UInt, 0x4FF, UInt, 0)
aDevices := object()
aDevices[1,0] := "9583,50738", aDevices[1,1] := "SpaceMouse Pro Wireless"
aDevices[2,0] := "9583,50737", aDevices[2,1] := "SpaceMouse Pro Wireless"
aDevices[3,0] := "9583,50735", aDevices[3,1] := "SpaceMouse Wireless"
aDevices[4,0] := "9583,50734", aDevices[4,1] := "SpaceMouse Wireless"
aDevices[5,0] := "1133,50731", aDevices[5,1] := "SpaceMouse Pro"
aDevices[6,0] := "1133,50729", aDevices[6,1] := "SpacePilot Pro"
aDevices[7,0] := "1133,50728", aDevices[7,1] := "SpaceNavigator for Notebooks"
aDevices[8,0] := "1133,50727", aDevices[8,1] := "SpaceExplorer"
aDevices[9,0] := "1133,50726", aDevices[9,1] := "SpaceNavigator"
aDevices[10,0] := "1133,50725", aDevices[10,1] := "SpacePilot"
aDevices[11,0] := "1133,50723", aDevices[11,1] := "SpaceTraveler"
aDevices[12,0] := "1133,50721", aDevices[12,1] := "SpaceBall 5000 USB"
aDevices[13,0] := "1133,50694", aDevices[13,1] := "SpaceMouse Classic USB"
aDevices[14,0] := "1133,50693", aDevices[14,1] := "CadMan"
aDevices[15,0] := "1133,50691", aDevices[15,1] := "SpaceMouse Plus (XT) USB" ; same IDs for two devices
aDevices[0,0] := 15

AHKHID_UseConstants()
3dcIndexes := _3DCDevices()
; ---------- out of neccessity ----------

; ---------- vJoy init ----------
axis_list_vjoy := Array("X","Y","Z","RX","RY","RZ")
axis_list_sx := Array("X","Y","Z","RX","RY","RZ")
HID_USAGE_X := 0x30, HID_USAGE_Y := 0x31, HID_USAGE_Z := 0x32, HID_USAGE_RX:= 0x33, HID_USAGE_RY:= 0x34, HID_USAGE_RZ:= 0x35
vjoyconfigdir := "", reconnectattempts := 0, used3DCcontroller := "", vjoy_id := "", function := "", vendorID := "", productID := ""
hDLL := LoadLibrary()
sticks := _vjoy_sticks()

if (param1 = "recover")
   ;msgbox recover`n`n%param1%`n%param2%`n%param3%`n%param4%

if (param1 = "recover") and (param2 <> "") and (param3 <> "") and (param4 <> "")
{
   vjoy_id := sxmodi2 := param2
   vendorID := param3
   function := "InputMsg" . vendorID
   productID := param4
}

if (vjoy_id = "") or (function = "") or (productID = "")
{
   result := _setupControls(sticks, 3dcIndexes)
   ;msgbox res`n`n%result%
   stringsplit, sxmodi, result, "`,"
   vjoy_id := sxmodi1
   function := "InputMsg" . sxmodi2
   vendorID := sxmodi2
   productID := sxmodi3
}
;msgbox vjoy_id %vjoy_id%`nfunction %function%
InitVJoy(vjoy_id) ; Whether the vjoy_id is connected and under the app's control
;msgbox, here
vJoyButtons := DllCall("vJoyInterface\GetVJDButtonNumber", "Int", vjoy_id)
_checkvJoyAxes()
VJOY_SetAxes(50, 50, 50, 50, 50, 50)
OnExit, AppQuit
; ---------- vJoy init ----------

; ---------- 3DConnexion init ----------
btnsSN := btnsSE := btnsSM := btnsSB := btnsSP := btnsSMW := btnsSPP := btnsSMP := btnsSNN := object()
PID := DllCall("GetCurrentProcessId")
;Gui, +LastFound ;Create GUI to receive messages
;hGui := WinExist()
Gui, New, +HwndhGUI, Sx2vJoy Helper Win %PID% ;Create GUI to receive messages
WM_INPUT := 0xFF
OnMessage(WM_INPUT, function)
sNavHID := AHKHID_Register(1, 8, hGui, RIDEV_INPUTSINK) ; 3DConnexion
; ---------- 3DConnexion init ----------

; ---------- other init ----------
DllCall("QueryPerformanceFrequency", "Int64*", __cps) ; A non interruptive sleep method is needed. This is part of it
__cps /= 1000
logstart := 0

axis_x := 1, axis_y := 2, axis_z := 3, axis_xR := 4, axis_yR := 5, axis_zR := 6, buttonlog := -1, setupmode := -1, setupmodeblind := -1, deadzone := 1
pitch := 2, curvature := 3, exponent := 4, is_throttle := 5, inc := 6, zro := 7, invert := 8, throttle_last_pos := 9, axis_suspended := 10
axis_suspend_condition := 11, axis_suspend_start := 12, wheelstate := 13, wheelstate_min = 14, wheelstate_max = 15, virt_axis_pos := 16, axis_move := 17, axis_prev := 18
currentProfile := "", MsgExe := "", oldMsgExe := "", oldActiveID, oldExe, displayaxesinput := -1, wdexename := ""

Controller_settings := object()
forcemode = 0, lastGUIprofile = "", showIfActive = 0

hotkey, ~^!vk41, label_displayaxesinput ; Ctrl+Alt+A
hotkey, ~^!vk53, label_setaxis ; Ctrl+Alt+S
hotkey, ~^!vk44, label_setaxisblind ; Ctrl+Alt+D
hotkey, ~^!vk42, label_buttonlog ; Ctrl+Alt+B
hotkey, ~wheeldown, label_down
hotkey, ~wheelup, label_up
hotkey, ~mbutton, label_zero
hotkey, ~wheeldown, off
hotkey, ~wheelup, off
hotkey, ~mbutton, off

; ---------- (auto) read config init ----------
gosub, config
;settimer, config, 250

MsgNo := DllCall("RegisterWindowMessage", Str,"SHCHANGENOTIFY")
OnMessage(MsgNo, "ShChangeNotify")

stringleft, Drive, A_ScriptDir, 1
VarSetCapacity($SHChangeNotifyEntry, 8, 0)
PIDL := PathGetPIDL(Drive ":")
NumPut(PIDL, $SHChangeNotifyEntry, 0)
NumPut(True, $SHChangeNotifyEntry, 4)
SHCNR_ID := DllCall("Shell32\SHChangeNotifyRegister", UInt,hGui, UInt,0x8000|0x1000|0x2|0x1, Int,0xC0581E0|0x7FFFFFFF|0x80000000, UInt,MsgNo, Int,1, UInt,&$SHChangeNotifyEntry)
; ---------- (auto) read config init ----------

;Gui +LastFound 
;hWnd := WinExist()
;DllCall("RegisterShellHookWindow", UInt, Hwnd)
DllCall("RegisterShellHookWindow", UInt, hGui)
MsgNum := DllCall("RegisterWindowMessage", Str,"SHELLHOOK")
OnMessage(MsgNum, "ShellMessage")
; ---------- other init ----------

; ---------- watchdog ----------
stringtrimright, scriptname, A_Scriptname, 4
;stringsplit, filename, A_ScriptName, "."
source := A_ScriptFullPath
PID := DllCall("GetCurrentProcessId")
dest := A_Temp . "\" . scriptname . " watchdog " . PID . ".exe"
filecopy, %source%, %dest%, 1
;msgbox, pause
stringsplit, wdexename, dest, "\"
wdexename := wdexename%wdexename0%

; param1 = keyword; param2 = vJoy ID; param3 = vendor ID; param4 = product ID; param5 = exe to restart; param6 = PID to monitor
Run *RunAs "%dest%" "watchdog" "%vjoy_id%" "%sxmodi2%" "%productID%" "%source%" "%PID%"
; ---------- watchdog ----------

3dcname := _3DCIDsToName()
trayTip, Sx2vJoy v%version%, %3dcname% connected to vJoy ID %vjoy_id%
menu, tray, tip, Sx2vJoy v%version%`n%3dcname% connected to vJoy ID %vjoy_id%

return

; ==================================================================================
; HID INPUT VID = 1133 (046D)
; ==================================================================================
InputMsg1133(wParam, lParam) {
   Local devh, iKey, sLabel, pointer := ""
   
   devh := AHKHID_GetInputInfo(lParam, II_DEVHANDLE)
   
   if (devh == -1) 
      return
   
   if (AHKHID_GetDevInfo(devh, DI_DEVTYPE, True)) = RIM_TYPEHID
      and (AHKHID_GetDevInfo(devh, DI_HID_VENDORID, True) = 1133)
      and (AHKHID_GetDevInfo(devh, DI_HID_PRODUCTID, True) == productID) {
      iKey := AHKHID_GetInputData(lParam, uData)
      
      if (iKey <> -1) {
       
         msg := NumGet(uData, 0, "UChar")
         
         ;axes
         if (SpaceBallSwap = 1) {
            if (msg = 1)
               msg := 2
            else if (msg = 2)
               msg := 1
         }
         
         if (msg == 1) { ; translational axes
            ((setupmode = 1) and (setupmodeblind = -1)) ? _setup(1, NumGet(uData, 1, "Short"), NumGet(uData, 3, "Short"), NumGet(uData, 5, "Short"))
            ((setupmode = -1) and (setupmodeblind = 1)) ? _setupblind(1, NumGet(uData, 1, "Short"), NumGet(uData, 3, "Short"), NumGet(uData, 5, "Short"))
            if ((setupmode = -1) and (setupmodeblind = -1)) {
               SN_xVal_virt := NumGet(uData, 1, "Short")
               SN_yVal_virt := NumGet(uData, 3, "Short")
               SN_zVal_virt := NumGet(uData, 5, "Short")
               ;x_tmp := NumGet(uData, 1, "Short")
               ;y_tmp := NumGet(uData, 3, "Short")
               ;z_tmp := NumGet(uData, 5, "Short")
               ;SN_xVal_virt := _process_axis("x", x_tmp)
               ;SN_yVal_virt := _process_axis("y", y_tmp)
               ;SN_zVal_virt := _process_axis("z", z_tmp)
            }
         }
         
         if (msg == 2) { ; rotational axes
            ((setupmode = 1) and (setupmodeblind = -1)) ? _setup(2, NumGet(uData, 1, "Short"), NumGet(uData, 3, "Short"), NumGet(uData, 5, "Short"))
            ((setupmode = -1) and (setupmodeblind = 1)) ? _setupblind(2, NumGet(uData, 1, "Short"), NumGet(uData, 3, "Short"), NumGet(uData, 5, "Short"))
            if ((setupmode = -1) and (setupmodeblind = -1)) {
               SN_xRVal_virt := NumGet(uData, 1, "Short")
               SN_yRVal_virt := NumGet(uData, 3, "Short")
               SN_zRVal_virt := NumGet(uData, 5, "Short")
               ;xR_tmp := NumGet(uData, 1, "Short")
               ;yR_tmp := NumGet(uData, 3, "Short")
               ;zR_tmp := NumGet(uData, 5, "Short")
               ;SN_xRVal_virt := _process_axis("xR", xR_tmp)
               ;SN_yRVal_virt := _process_axis("yR", yR_tmp)
               ;SN_zRVal_virt := _process_axis("zR", zR_tmp)
            }
         }
         
         ;buttons
         if (msg == 3)
         {
            PID := AHKHID_GetDevInfo(devh, DI_HID_PRODUCTID, True)
            byte0 := NumGet(uData, 1, "Int")
            _buttonsPerPID(PID, byte0)
         }
         if (displayaxesinput = 1)
            tooltip, x:%x_tmp%`ny:%y_tmp%`nz:%z_tmp%`nxR:%xR_tmp%`nyR:%yR_tmp%`nzR:%zR_tmp%, 0, 0
         VJOY_SetAxes(SN_xVal_virt, SN_yVal_virt, SN_zVal_virt, SN_xRVal_virt, SN_yRVal_virt, SN_zRVal_virt)
      }
   }
}

; ==================================================================================
; HID INPUT VID = 9583 (256F)
; ==================================================================================
InputMsg9583(wParam, lParam) {
   Local devh, iKey, sLabel, pointer := ""
   
   devh := AHKHID_GetInputInfo(lParam, II_DEVHANDLE)
   
   if (devh == -1) 
      return
   
   if (AHKHID_GetDevInfo(devh, DI_DEVTYPE, True)) = RIM_TYPEHID
      and (AHKHID_GetDevInfo(devh, DI_HID_VENDORID, True) = 9583)
      and (AHKHID_GetDevInfo(devh, DI_HID_PRODUCTID, True) == productID) {
      iKey := AHKHID_GetInputData(lParam, uData)
      
      if (iKey <> -1) {
         msg := NumGet(uData, 0, "UChar")
         
         ;axes
         if (msg == 1) {
            ((setupmode = 1) and (setupmodeblind = -1)) ? _setup(3, NumGet(uData, 1, "Short"), NumGet(uData, 3, "Short"), NumGet(uData, 5, "Short"), NumGet(uData, 7, "Short"), NumGet(uData, 9, "Short"), NumGet(uData, 11, "Short"))
            ((setupmode = -1) and (setupmodeblind = 1)) ? _setupblind(3, NumGet(uData, 1, "Short"), NumGet(uData, 3, "Short"), NumGet(uData, 5, "Short"), NumGet(uData, 7, "Short"), NumGet(uData, 9, "Short"), NumGet(uData, 11, "Short"))
            if ((setupmode = -1) and (setupmodeblind = -1)) {
               SN_xVal_virt := NumGet(uData, 1, "Short")
               SN_yVal_virt := NumGet(uData, 3, "Short")
               SN_zVal_virt := NumGet(uData, 5, "Short")
               SN_xRVal_virt := NumGet(uData, 7, "Short")
               SN_yRVal_virt := NumGet(uData, 9, "Short")
               SN_zRVal_virt := NumGet(uData, 11, "Short")
               
               ;x_tmp := NumGet(uData, 1, "Short")
               ;y_tmp := NumGet(uData, 3, "Short")
               ;z_tmp := NumGet(uData, 5, "Short")
               ;xR_tmp := NumGet(uData, 7, "Short")
               ;yR_tmp := NumGet(uData, 9, "Short")
               ;zR_tmp := NumGet(uData, 11, "Short")
               
               ;SN_xVal_virt := _process_axis("x", x_tmp)
               ;SN_yVal_virt := _process_axis("y", y_tmp)
               ;SN_zVal_virt := _process_axis("z", z_tmp)
               ;SN_xRVal_virt := _process_axis("xR", xR_tmp)
               ;SN_yRVal_virt := _process_axis("yR", yR_tmp)
               ;SN_zRVal_virt := _process_axis("zR", zR_tmp)
            }
         }
         
         ;buttons
         if (msg == 3)
         {
            PID := AHKHID_GetDevInfo(devh, DI_HID_PRODUCTID, True)
            byte0 := NumGet(uData, 1, "Int")
            _buttonsPerPID(PID, byte0)
         }
         if (displayaxesinput = 1)
            tooltip, x:%x_tmp%`ny:%y_tmp%`nz:%z_tmp%`nxR:%xR_tmp%`nyR:%yR_tmp%`nzR:%zR_tmp%, 0, 0
         VJOY_SetAxes(SN_xVal_virt, SN_yVal_virt, SN_zVal_virt, SN_xRVal_virt, SN_yRVal_virt, SN_zRVal_virt)
      }
   }
}

_buttonsPerPID(PID, byte0) {
   global buttonlog, vJoyButtons, vjoy_id, btnsSN, btnsSM, btnsSE, btnsSB, btnsSP, btnsSMW, btnsSPP, btnsSMP, btnsSNN
   
   (PID = 50691) ? pointer := "btnsSMP" ; SpaceMouse Plus (XT) USB
   (PID = 50721) ? pointer := "btnsSB"  ; SpaceBall 5000 (USB)
   (PID = 50725) ? pointer := "btnsSP"  ; SpacePilot (non-Pro)
   (PID = 50726) ? pointer := "btnsSN"  ; SpaceNavigator
   (PID = 50727) ? pointer := "btnsSE"  ; SpaceExplorer
   (PID = 50728) ? pointer := "btnsSNN" ; SpaceNavigator for Notebooks
   (PID = 50729) ? pointer := "btnsSPP" ; SpacePilot Pro
   (PID = 50731) ? pointer := "btnsSM"  ; SpaceMouse Pro
   (PID = 50734) ? pointer := "btnsSMW" ; SpaceMouse Wireless
   (PID = 50735) ? pointer := "btnsSMW" ; SpaceMouse Wireless
   
   ;printarray(%pointer%)
   
   if (buttonlog = 1)
      _logButton(byte0, PID)
   else
   {
      loops := %pointer%[0,0]
      loop, %loops%
      {
         state := (byte0 & %pointer%[A_Index,0]) ? true : false
         if (state <> %pointer%[A_Index,4])
         {
            %pointer%[A_Index,4] := state
            (%pointer%[A_Index,1] = "k") ? Kbd_SetBtn(state,pointer,A_Index)
            (%pointer%[A_Index,1] = "j") ? (%pointer%[A_Index,2] <= vJoyButtons) ? DllCall("vJoyInterface\SetBtn", "Int", state, "UInt", vjoy_id, "UChar", %pointer%[A_Index,2])
         }
      }
   }
}

_3DCDevices() {
   global version, aDevices
   
   devices := _getRAWdevices()
   if (devices = -1)
   {
      msgbox,16,Sx2vJoy %version%,No HID devices detected, not just no 3DConnexion devices. Something is very wrong here.`n`nExiting.
      exitapp
   }
   3dcIndex := ""
   loop, parse, devices, `n, `r
   {
      set := A_LoopField
      
      loops := aDevices[0,0]
      loop, %loops%
      {
         check := aDevices[A_Index,0]
         if (set = check)
         {
            3dcIndex .= A_Index "|"
            break
         }
      }
   }
   stringtrimright, 3dcIndex, 3dcIndex, 1
   if (3dcIndex = "")
   {
      msgbox,16,Sx2vJoy %version%,No 3DConnexion devices detected, cannot continue.`n`nExiting.
      exitapp
   }
   return 3dcIndex
}

_getRAWdevices() {
   global RIM_TYPEHID, DI_HID_VENDORID, DI_HID_PRODUCTID
   DllCall("GetRawInputDeviceList", "Ptr", 0, "UInt*", iCount, "UInt", A_PtrSize * 2)
   VarSetCapacity(uHIDList, iCount * (A_PtrSize * 2))

   DllCall("GetRawInputDeviceList", "Ptr", &uHIDList, "UInt*", iCount, "UInt", A_PtrSize * 2)
   devicelist := ""
   
   Loop %iCount% {
      h := NumGet(uHIDList, (A_Index - 1) * (A_PtrSize * 2))
      DllCall("GetRawInputDeviceInfo", "Ptr", h, "UInt", 0x2000000b, "Ptr", 0, "UInt*", iLength)
      Type := NumGet(uHIDList, (A_Index - 1) * A_PtrSize * 2 + 4)
      if (Type = RIM_TYPEHID)
      {
         VarSetCapacity(uInfo, iLength)   
         NumPut(iLength, uInfo, 0)
         DllCall("GetRawInputDeviceInfo", "Ptr", h, "UInt", 0x2000000b, "Ptr", &uInfo, "UInt*", iLength)
         vid := NumGet(uInfo, DI_HID_VENDORID)
         pid := NumGet(uInfo, DI_HID_PRODUCTID)
         if (vid <> "") and (pid <> "")
            devicelist .= vid . "," . pid . "`n"
      }
   }
   if (devicelist <> "")
      return %devicelist%
   return -1
}

Kbd_SetBtn(state,pointer,index) {
   global btnsSN, btnsSM, btnsSE, btnsSB, btnsSP, btnsSMW, btnsSPP, btnsSMP, btnsSNN

   down := %pointer%[index,2]
   up := %pointer%[index,3]
   
   if (state = 1)
      sendinput {blind}%down%
   if (state = 0)
      sendinput {blind}%up%
}

VJOY_SetAxes(SNavX, SNavY, SNavZ, SNavRX, SNavRY, SNavRZ) {
   global vjoy_id, axis_list_vjoy, axis_list_sx, version, reconnectattempts, axis_prev, smoothing, Controller_settings, axis_x, axis_y, axis_z, axis_xR, axis_yR, axis_zR
   loop, 6
   {
      ax_vj := axis_list_vjoy[A_Index]
      ax_sx := axis_list_sx[A_Index]
      axval := _process_axis(ax_sx, SNav%ax_vj%)
   
      /*
      axval := (Controller_settings[axis_%ax_vj%,axis_prev] * smoothing + axval * (100-smoothing)) / 100
      if (ax_sx = "X")
      {
         test := Controller_settings[axis_%ax_vj%,axis_prev]
         tooltip, %axval%`n%test%, 0, 0
         ;msgbox, %axval%`n%test%
      }
      */
		
      ret := DllCall("vJoyInterface\SetAxis", "Int", 327.68 * axval, "UInt", vjoy_id, "UInt", HID_USAGE_%ax_sx%)
      if (!ret) {
         reconnectattempts++
         _filewritelog("error.log", "connection to vJoy lost, trying to reconnect")
         _reconnect()
         if (reconnectattempts > 3)
         {
            axis_val := 327.68 * SNav%ax_sx%
            usage := HID_USAGE_%ax_sx%
            _filewritelog("error.log", "restoring connection to vJoy failed")
            msgbox,16,Sx2vJoy %version%,VJOY_SetAxes`n`naxis: %ax_sx%`nusage: %usage%`naxis value: %axis_val%`nErrorLevel: %ErrorLevel%`nReturned: %ret%`n`nExiting.
            exitapp
         }
      }
      else
         reconnectattempts := 0
      
      ;Controller_settings[axis_%ax_sx%,axis_prev] := axval
   }
}

_logButton(btnID, device) {
   global logstart
   if (logstart = 1) {
      logstart := 0
      fileappend, %device%`n, Sx2vJoy.log
   }
   
   if (btnID > 0) {
      btnID := round(log(btnID) / log(2))
      fileappend, %btnID%`n, Sx2vJoy.log
   }
}

_timerinit() {
   global __PerformanceFrequency
   if not (__PerformanceFrequency > 0)
      DllCall("QueryPerformanceFrequency", "Int64*", __PerformanceFrequency)
   DllCall("QueryPerformanceCounter", "Int64*", counter)
   return counter
}

_process_axis(axis, axis_phys) {
   global axis_x, axis_y, axis_z, axis_xR, axis_yR, axis_zR, deadzone, pitch, curvature, is_throttle, invert, throttle_last_pos, Controller_settings, exponent
   
   if (axis = "RX")
      axis := "XR"
   if (axis = "RY")
      axis := "YR"
   if (axis = "RZ")
      axis := "ZR"
   
   ;invert
   Controller_settings[axis_%axis%,invert] = 0 ? axis_phys *= -1
   axis_phys += 350
   
   if (Controller_settings[axis_%axis%,is_throttle] = 0)
   {
      ;deadzone
      dz := 350 / 100 * Controller_settings[axis_%axis%,deadzone]
      virt_percent := 50
      virt_percent := (axis_phys < (350-dz)) ? 50 / (350-dz) * (axis_phys-dz*0) : virt_percent
      virt_percent := (axis_phys > (350+dz)) ? 50 / (350-dz) * (axis_phys-dz*2) : virt_percent
		
      ;pitch
      virt_percent := 50 + (50-virt_percent) * Controller_settings[axis_%axis%,pitch]
      (virt_percent > 100) ? virt_percent := 100
      (virt_percent < 0) ? virt_percent := 0
        
      ;logarithmic sensitivity
      virt_percent := ((virt_percent - 50) * 2) / 100
      virt_percent := (Controller_settings[axis_%axis%,curvature] * virt_percent + (1 - Controller_settings[axis_%axis%,curvature]) * virt_percent ** Controller_settings[axis_x,exponent]) * 50 + 50
   }
   else
   {
      _process_throttle(axis, axis_phys, Controller_settings[axis_%axis%,is_throttle])
      virt_percent := Controller_settings[axis_%axis%,throttle_last_pos]
   }
   return virt_percent
}

_process_throttle(axis, axis_phys, method) {
   global axis_x, axis_y, axis_z, axis_xR, axis_yR, axis_zR, deadzone, linear_sensitivity, logarithmic_sensitivity, invert, __cps, inc, zro, version, reconnectattempts
   global throttle_last_pos, Controller_settings, axis_suspended, axis_suspend_condition, axis_suspend_start, wheelstate, wheelstate_max, wheelstate_min, vjoy_id, axis_list_vjoy
   
   ; throttle deadzone
   dz := 350 / 100 * Controller_settings[axis_%axis%, deadzone]
   phys_percent := 50
   phys_percent := (axis_phys < (350-dz)) ? 50 / (350-dz) * (axis_phys-dz*0) : phys_percent ; range (0 to 350-deadzone) has no deadzone
   phys_percent := (axis_phys > (350+dz)) ? 50 / (350-dz) * (axis_phys-dz*2) : phys_percent ; range (0 to 700) on the other hand has two
   
   if (method = 1)
   {
      now := _TimerInit()
      Controller_settings[axis_%axis%,axis_suspended] := now >= (Controller_settings[axis_%axis%,axis_suspend_start] + __cps * 1000) ? 0 : Controller_settings[axis_%axis%,axis_suspended]
      
      speed_mult := (phys_percent - 50) * 0.07
      (speed_mult < 0) ? speed_mult *= -1
      
      if (Controller_settings[axis_%axis%,axis_suspended] = 0)
      {
         (phys_percent > 50) ? Controller_settings[axis_%axis%,throttle_last_pos] += speed_mult
         (phys_percent < 50) ? Controller_settings[axis_%axis%,throttle_last_pos] -= speed_mult
         (Controller_settings[axis_%axis%,throttle_last_pos] < 0) ? Controller_settings[axis_%axis%,throttle_last_pos] := 0
         (Controller_settings[axis_%axis%,throttle_last_pos] > 100) ? Controller_settings[axis_%axis%,throttle_last_pos] := 100
      }
         
      if ((Controller_settings[axis_%axis%,throttle_last_pos] < (Controller_settings[axis_%axis%,zro] - 2)) or (Controller_settings[axis_%axis%,throttle_last_pos] > (Controller_settings[axis_%axis%,zro] +2)) and (Controller_settings[axis_%axis%,axis_suspend_condition] = 0))
         Controller_settings[axis_%axis%,axis_suspend_condition] := 1
         
      if ((Controller_settings[axis_%axis%,throttle_last_pos] >= (Controller_settings[axis_%axis%,zro] - 2)) and (Controller_settings[axis_%axis%,throttle_last_pos] <= (Controller_settings[axis_%axis%,zro] + 2)) and (Controller_settings[axis_%axis%,axis_suspend_condition] = 1))
      {
         Controller_settings[axis_%axis%,axis_suspended] := 1
         Controller_settings[axis_%axis%,axis_suspend_condition] := 0
         Controller_settings[axis_%axis%,axis_suspend_start] := _timerinit()
      }
   }
   
   if (method = 2)
   {
      inv := Controller_settings[axis_%axis%,invert] = 0 ? 1 : -1 ; invert
      
      Controller_settings[wheelstate] := Controller_settings[wheelstate] <= Controller_settings[axis_%axis%,wheelstate_min] ? Controller_settings[axis_%axis%,wheelstate_min] : Controller_settings[wheelstate]
      Controller_settings[wheelstate] := Controller_settings[wheelstate] >= Controller_settings[axis_%axis%,wheelstate_max] ? Controller_settings[axis_%axis%,wheelstate_max] : Controller_settings[wheelstate]
      
      state := Controller_settings[wheelstate] * inv
      axis_virt := Controller_settings[axis_%axis%,zro] + state * Controller_settings[axis_%axis%,inc]
      
      ax := axis = "x" ? axis_list_vjoy[1] : ax
      ax := axis = "y" ? axis_list_vjoy[2] : ax
      ax := axis = "z" ? axis_list_vjoy[3] : ax
      ax := axis = "xR" ? axis_list_vjoy[4] : ax
      ax := axis = "yR" ? axis_list_vjoy[5] : ax
      ax := axis = "zR" ? axis_list_vjoy[6] : ax
      
      axis_virt := axis_virt < 0 ? 0 : axis_virt
      axis_virt := axis_virt > 100 ? 100 : axis_virt
      
      Controller_settings[axis_%axis%,throttle_last_pos] := axis_virt
      ret := DllCall("vJoyInterface\SetAxis", "Int", 327.68 * axis_virt, "UInt", vjoy_id, "UInt", HID_USAGE_%ax%)
      if (!ret) {
         reconnectattempts++
         _filewritelog("error.log", "connection to vJoy lost, trying to reconnect")
         _reconnect()
         if (reconnectattempts > 3)
         {
            axis_val := 327.68 * axis_virt
            usage := HID_USAGE_%ax%
            _filewritelog("error.log", "restoring connection to vJoy failed")
            msgbox,16,Sx2vJoy %version%,_Process_Throttle`n`naxis: %ax%`nusage: %usage%`naxis value: %axis_val%`nErrorLevel: %ErrorLevel%`nReturned: %ret%`n`nExiting.
            exitapp
         }
      }
      else
         reconnectattempts := 0
   }
}

MoveAxis(ax) {
   global axis_list_vjoy, vjoy_id, ;HID_USAGE
   start := 16384
   if strlen(ax) = 2
      ax := "R" . substr(ax, 1, 1)
   loop
   {
      ;VJoy_SetAxis(start, vjoy_id, HID_USAGE_%ax%)
      DllCall("vJoyInterface\SetAxis", "Int", start, "UInt", vjoy_id, "UInt", HID_USAGE_%ax%)
      start -= 150
      if start <= 0
      {
         ;VJoy_SetAxis(16384, vjoy_id, HID_USAGE_%ax%)
         DllCall("vJoyInterface\SetAxis", "Int", 16384, "UInt", vjoy_id, "UInt", HID_USAGE_%ax%)
         break
      }
      sleep, 10
   }
}

_readAxesOrder(profile) {
   global axis_list_vjoy
   tempaxes := ""
   iniread, axes, config.ini, %profile%, axes order, "x,y,z,xR,yR,zR"
   stringreplace, axes, axes, %A_Space%,,All
   stringupper, axes, axes
   
   loop, parse, axes, `,
   {
      if (A_LoopField <> "X") and (A_LoopField <> "Y") and (A_LoopField <> "Z") and (A_LoopField <> "XR") and (A_LoopField <> "YR") and (A_LoopField <> "ZR")
      {
         msgbox,16,Sx2vJoy %version%,The values for the axes in config.ini contained something Sx2vJoy cannot work with.`n`nMake sure only x, y, z, xR, yR, zR are listed.`n`nExiting.
         ExitApp
      }
      
      tempaxis := A_LoopField
      if (tempaxis = "XR")
         tempaxis := "RX"
      if (tempaxis = "YR")
         tempaxis := "RY"
      if (tempaxis = "ZR")
         tempaxis := "RZ"
      
      tempaxes .= tempaxis . ","
   }
   
   stringtrimright, tempaxes, tempaxes, 1
      
   loop, parse, tempaxes, `,
      axis_list_vjoy[A_Index] := A_LoopField
   ;printarray(axis_list_vjoy)
}

_readBtnConfig(profile) {
   global btnsSB, btnsSE, btnsSM, btnsSN, btnsSP, btnsSMW, btnsSPP, btnsSMP, btnsSNN
   btnsSB := _BtnConfig2Array(profile, "SpaceBall 5000 (USB)")
   btnsSE := _BtnConfig2Array(profile, "SpaceExplorer")
   btnsSM := _BtnConfig2Array(profile, "SpaceMouse Pro")
   btnsSN := _BtnConfig2Array(profile, "SpaceNavigator")
   btnsSNN := _BtnConfig2Array(profile, "SpaceNavigator for Notebooks")
   btnsSP := _BtnConfig2Array(profile, "SpacePilot")
   btnsSMW := _BtnConfig2Array(profile, "SpaceMouse Wireless")
   btnsSPP := _BtnConfig2Array(profile, "SpacePilot Pro")
   btnsSMP := _BtnConfig2Array(profile, "SpaceMouse Plus (XT) USB")
   ;printarray(btnsSMP) ; comment out
}

_BtnConfig2Array(profile, device) {
   aBtns := object()
   idcount := ""
   data := _IniReadSection("config.ini", profile)
   regexdevice := device
   stringreplace, regexdevice, regexdevice, (, \(
   stringreplace, regexdevice, regexdevice, ), \)
   Loop, parse, data, `n, `r
   {
      test := A_LoopField
      RegExMatch(A_LoopField , "i)^" . regexdevice . " id(\d{1,2}).*=.*", match)
      if (match <> "")
      {
         action := ""
         action2 := ""
         newstr := regexreplace(match, "\s", "")
         stringsplit, out, newstr, "="
         if not (strlen(out2) >= 2)
            continue
         id_ := match1
         val := out2
         
         ;msgbox, %id_%`n%val%
         
         if (substr(val, 1, 1) <> "j") and (substr(val, 1, 1) <> "k") and (substr(val, 1, 1) <> "")
         {
            msgbox,16,Sx2vJoy %version%,Error.`n`n'%val%' is not a valid joystick button instruction.`n`nCannot continue.`n`nExiting.
            ExitApp
         }

         if (substr(val, 1, 1) = "j") ; if joystick
         {
            StringReplace, val, val, %A_Space%,,All
            action := substr(val, 3)
            if not _isnum(action)
            {
               msgbox,16,Sx2vJoy %version%,Error.`n`n'%action%' is not a valid joystick button for the %device%.`n`nCannot continue.`n`nExiting.
               ExitApp
            }
            idcount++
            aBtns[0,0] := idcount
            aBtns[idcount,0] := 2**id_
            aBtns[idcount,1] := substr(val, 1, 1)
            aBtns[idcount,2] := action
            aBtns[idcount,3] := action2
         }
         
         if (substr(val, 1, 1) = "k") ; if keyboard
         {
            ret := _convertKeybInput(substr(val, 3))
            action := ret[1]
            action2 := ret[2]
            idcount++
            aBtns[0,0] := idcount
            aBtns[idcount,0] := 2**id_
            aBtns[idcount,1] := substr(val, 1, 1)
            aBtns[idcount,2] := action
            aBtns[idcount,3] := action2
            aBtns[idcount,4] := 0
         }
      }
   }
   ;printarray(abtns)
   return aBtns
}

_convertKeybInput(keyb) {
   press := ""
   release := ""
   stringsplit, split, keyb, `,
   Loop, %split0%
   {
      btn := split%a_index%
      press = %press%{%btn% down}
      release = {%btn% up}%release%
   }
   ret := object()
   ret[1] := press
   ret[2] := release
   return ret
}

_isNum(num) {
   if num is digit
      return 1
   return 0
}

_calcID(byref input_id) {
   output := ""
   loop, parse, input_id, `,
   {
      output .= 2** (A_LoopField) . ","
   }
   stringtrimright, output, output, 1
   input_id := output
}

_readGeneral() {
   global forcemode, lastGUIprofile, showIfActive
   iniread, forcemode, config.ini, general, forcemode
   iniread, lastGUIprofile, config.ini, general, last GUI profile
   iniread, showIfActive, config.ini, general, show if active
}

_readAxesConfig(profile) {
   global Controller_settings, axis_x, axis_y, axis_z, axis_xR, axis_yR, axis_zR, deadzone, pitch, curvature, is_throttle, inc, zro, invert, exponent
   global throttle_last_pos, axis_suspended, axis_suspend_condition, axis_suspend_start, wheelstate, wheelstate_min, wheelstate_max, virt_axis_pos, axis_move

   iniread, value, config.ini, %profile%, axis x deadzone, 10
   Controller_settings[axis_x, deadzone] := value
   iniread, value, config.ini, %profile%, axis y deadzone, 10
   Controller_settings[axis_y, deadzone] := value
   iniread, value, config.ini, %profile%, axis z deadzone, 10
   Controller_settings[axis_z, deadzone] := value
   iniread, value, config.ini, %profile%, axis xR deadzone, 10
   Controller_settings[axis_xR,deadzone] := value
   iniread, value, config.ini, %profile%, axis yR deadzone, 10
   Controller_settings[axis_yR,deadzone] := value
   iniread, value, config.ini, %profile%, axis zR deadzone, 10
   Controller_settings[axis_zR,deadzone] := value
   iniread, value, config.ini, %profile%, axis x pitch, 1
   Controller_settings[axis_x, pitch] := value
   iniread, value, config.ini, %profile%, axis y pitch, 1
   Controller_settings[axis_y, pitch] := value
   iniread, value, config.ini, %profile%, axis z pitch, 1
   Controller_settings[axis_z, pitch] := value
   iniread, value, config.ini, %profile%, axis xR pitch, 1
   Controller_settings[axis_xR,pitch] := value
   iniread, value, config.ini, %profile%, axis yR pitch, 1
   Controller_settings[axis_yR,pitch] := value
   iniread, value, config.ini, %profile%, axis zR pitch, 1
   Controller_settings[axis_zR,pitch] := value
   iniread, value, config.ini, %profile%, axis x curvature, 1
   Controller_settings[axis_x, curvature] := _logSens(value)
   iniread, value, config.ini, %profile%, axis y curvature, 1
   Controller_settings[axis_y, curvature] := _logSens(value)
   iniread, value, config.ini, %profile%, axis z curvature, 1
   Controller_settings[axis_z, curvature] := _logSens(value)
   iniread, value, config.ini, %profile%, axis xR curvature, 1
   Controller_settings[axis_xR,curvature] := _logSens(value)
   iniread, value, config.ini, %profile%, axis yR curvature, 1
   Controller_settings[axis_yR,curvature] := _logSens(value)
   iniread, value, config.ini, %profile%, axis zR curvature, 1
   Controller_settings[axis_zR,curvature] := _logSens(value)
   iniread, value, config.ini, %profile%, axis x is throttle, 0
   Controller_settings[axis_x, is_throttle] := value
   iniread, value, config.ini, %profile%, axis y is throttle, 0
   Controller_settings[axis_y, is_throttle] := value
   iniread, value, config.ini, %profile%, axis z is throttle, 0
   Controller_settings[axis_z, is_throttle] := value
   iniread, value, config.ini, %profile%, axis xR is throttle, 0
   Controller_settings[axis_xR,is_throttle] := value
   iniread, value, config.ini, %profile%, axis yR is throttle, 0
   Controller_settings[axis_yR,is_throttle] := value
   iniread, value, config.ini, %profile%, axis zR is throttle, 0
   Controller_settings[axis_zR,is_throttle] := value
   iniread, value, config.ini, %profile%, axis x increments, 5
   Controller_settings[axis_x, inc] := value
   iniread, value, config.ini, %profile%, axis y increments, 5
   Controller_settings[axis_y, inc] := value
   iniread, value, config.ini, %profile%, axis z increments, 5
   Controller_settings[axis_z, inc] := value
   iniread, value, config.ini, %profile%, axis xR increments, 5
   Controller_settings[axis_xR,inc] := value
   iniread, value, config.ini, %profile%, axis yR increments, 5
   Controller_settings[axis_yR,inc] := value
   iniread, value, config.ini, %profile%, axis zR increments, 5
   Controller_settings[axis_zR,inc] := value
   iniread, value, config.ini, %profile%, axis x zero, 50
   Controller_settings[axis_x, zro] := value
   iniread, value, config.ini, %profile%, axis y zero, 50
   Controller_settings[axis_y, zro] := value
   iniread, value, config.ini, %profile%, axis z zero, 50
   Controller_settings[axis_z, zro] := value
   iniread, value, config.ini, %profile%, axis xR zero, 50
   Controller_settings[axis_xR,zro] := value
   iniread, value, config.ini, %profile%, axis yR zero, 50
   Controller_settings[axis_yR,zro] := value
   iniread, value, config.ini, %profile%, axis zR zero, 50
   Controller_settings[axis_zR,zro] := value
   iniread, value, config.ini, %profile%, axis x invert, 0
   Controller_settings[axis_x, invert] := value
   iniread, value, config.ini, %profile%, axis y invert, 0
   Controller_settings[axis_y, invert] := value
   iniread, value, config.ini, %profile%, axis z invert, 0
   Controller_settings[axis_z, invert] := value
   iniread, value, config.ini, %profile%, axis xR invert, 0
   Controller_settings[axis_xR,invert] := value
   iniread, value, config.ini, %profile%, axis yR invert, 0
   Controller_settings[axis_yR,invert] := value
   iniread, value, config.ini, %profile%, axis zR invert, 0
   Controller_settings[axis_zR,invert] := value
   iniread, value, config.ini, %profile%, axis x exponent, 0
   Controller_settings[axis_x,exponent] := value
   iniread, value, config.ini, %profile%, axis y exponent, 0
   Controller_settings[axis_y,exponent] := value
   iniread, value, config.ini, %profile%, axis z exponent, 0
   Controller_settings[axis_z,exponent] := value
   iniread, value, config.ini, %profile%, axis xR exponent, 0
   Controller_settings[axis_xR,exponent] := value
   iniread, value, config.ini, %profile%, axis yR exponent, 0
   Controller_settings[axis_yR,exponent] := value
   iniread, value, config.ini, %profile%, axis zR exponent, 0
   Controller_settings[axis_zR,exponent] := value
   
   value := ""
   Controller_settings[wheelstate] := 0

   loop, 6
   {
      Controller_settings[A_Index,throttle_last_pos] := 0 
      Controller_settings[A_Index,axis_suspended] := 0
      Controller_settings[A_Index,axis_suspend_condition] := 0
      Controller_settings[A_Index,axis_timer] := 0
      Controller_settings[A_Index,axis_move] := 0
      
      Controller_settings[A_Index,18] := 50
   }
   
   if (Controller_settings[axis_x, is_throttle] = 2) or (Controller_settings[axis_y, is_throttle] = 2) or (Controller_settings[axis_z, is_throttle] = 2) or (Controller_settings[axis_xR, is_throttle] = 2) or (Controller_settings[axis_yR, is_throttle] = 2) or (Controller_settings[axis_zR, is_throttle] = 2)
   {
      hotkey, ~wheeldown, on
      hotkey, ~wheelup, on
      hotkey, ~mbutton, on
   }
   else
   {
      hotkey, ~wheeldown, off
      hotkey, ~wheelup, off
      hotkey, ~mbutton, off
   }
   
   ; we have to jump through a couple of hoops to reach 0% and 100% thrust while retaining the ability to get back to zero position exactly, wherever that may be, just by scrolling the mousewheel
   loop, 6
   {
      Controller_settings[A_Index,wheelstate_max] := ceil((100 - Controller_settings[A_Index,zro]) / Controller_settings[A_Index,inc])
      Controller_settings[A_Index,wheelstate_min] := floor((0 - Controller_settings[A_Index,zro]) / Controller_settings[A_Index,inc])
      Controller_settings[A_Index,invert] <> 0 ? Controller_settings[A_Index,zro] := 100 - Controller_settings[A_Index,zro]
   }
   
   ;printarray(Controller_settings)
}

FileGetTime(fn, time="M", tC=4, tA=12, tM=20){
  If VarSetCapacity(s,342,0) && DllCall("FindClose", UInt,DllCall("FindFirstFile", str,fn, UInt,&s))
  && DllCall("FileTimeToLocalFileTime", UInt, &s+t%time%, UInt, _:=&s+318)
  && DllCall("FileTimeToSystemTime", UInt, _+0, UInt, _+=8){
   Loop 7
     out .= (n:=NumGet(_+0, A_Index*2-2, "UShort")) < 10 ? 0 n : n
   Return SubStr(out, 1, 6) SubStr(out, 9) SubStr("00" NumGet(_+0, 14, "UShort"), -2)
}}

_logSens(value) {
   if (value = 0)
      return 1
   value := ((value - 100) * -1) / 100
   return value
}

/*
InitVJoy(vjoy_id) {
   global version
   if (vjoy_id <> 0) and (vjoy_id <> "")
      _VJoy_Close()
   
   vjoy_status := DllCall("vJoyInterface\GetVJDStatus", "UInt", vjoy_id)
   
   if (vjoy_status = 0) {
      msgbox,48,Sx2vJoy %version%,Sx2vJoy already has control of vJoy ID %vjoy_id%.
   ;} else if (vjoy_status = 1) { ; this is what we ideally have, so no need to bug the user about it
   ;   msgbox,,Sx2vJoy %version%,No feeder already has control of vJoy ID %vjoy_id%.
   } else if (vjoy_status = 2) {
      msgbox,48,Sx2vJoy %version%,Another feeder already has control of vJoy ID %vjoy_id%.
   }  else if (vjoy_status >= 3) {
      msgbox,48,Sx2vJoy %version%,vJoy device ID %vjoy_id% does not exist or driver is down.
   }  else if (vjoy_status >= 4) {
      msgbox,48,Sx2vJoy %version%,Unknown. Sorry.
   }
   if (vjoy_status <= 1) {
      DllCall("vJoyInterface\AcquireVJD", "UInt", vjoy_id)
      DllCall("vJoyInterface\ResetVJD", "UInt", vjoy_id)
      return 1
   }
}
*/

InitVJoy(vjoy_id) {
	global version
   
	if (vjoy_id <> 0) and (vjoy_id <> "") {
		;DllCall("vJoyInterface\vJoyEnabled") ; for some strange reason this is necessary on some systems so GetVJDStatus doesn't crash every other call
		vjoy_status := DllCall("vJoyInterface\GetVJDStatus", "UInt", vjoy_id)
		
		; 0 = owned by this feeder
		; 1 = free
		; 2 = owned by another feeder
		; 3 = missing
		; 4 = unknown error
		
		if (vjoy_status <> 1) {
			msgbox,48,Sx2vJoy %version%,Sx2vJoy already has control of vJoy ID %vjoy_id%.
			;} else if (vjoy_status = 1) { ; this is what we ideally have, so no need to bug the user about it
			;   msgbox,,Sx2vJoy %version%,No feeder already has control of vJoy ID %vjoy_id%.
			} else if (vjoy_status = 2) {
			msgbox,48,Sx2vJoy %version%,Another feeder already has control of vJoy ID %vjoy_id%.
			}  else if (vjoy_status >= 3) {
			msgbox,48,Sx2vJoy %version%,vJoy device ID %vjoy_id% does not exist or driver is down.
			}  else if (vjoy_status >= 4) {
			msgbox,48,Sx2vJoy %version%,Unknown. Sorry.
            exitapp
		}
		DllCall("vJoyInterface\AcquireVJD", "UInt", vjoy_id)
        return 1
	}
}

LoadLibrary() {
   global version, dllpath, vjoyconfigdir
   bitpath := (A_PtrSize = 8) ? "x64" : "x86"
   regview := (A_Is64bitOS = 1) ? "64" : "32"
   setregview %regview%
   regread, vjoypath, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{8E31F76F-74C3-47F1-9550-E041EEDC5FBB}_is1\, InstallLocation
   regread, ver, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{8E31F76F-74C3-47F1-9550-E041EEDC5FBB}_is1\, DisplayVersion
   if (vjoypath = "")
      _vJoyInfo(1)
   if (A_Is64bitOS = 1)
      vjoyconfigdir = %vjoypath%x64
   if (A_Is64bitOS = 0)
      vjoyconfigdir = %vjoypath%x86
   dllpath = %vjoypath%%bitpath%\vJoyInterface.dll
   ifnotexist, %dllpath%
      _vJoyInfo(2)
   
   dllver_tmp := FileGetVersionInfo_AW(dllpath, "ProductVersion")
   
   dllver := 0
   if instr(dllver_tmp, "amd64") > 0
      dllver := "x64"
   if instr(dllver_tmp, "x86") > 0
      dllver := "x86"
   if (dllver = 0)
   {
      dllver_tmp := FileGetVersionInfo_AW(dllpath, "FileDescription")
      if instr(dllver_tmp, "X64") > 0
         dllver := "x64"
      if instr(dllver_tmp, "X32") > 0
         dllver := "x86"
   }
   
   filegetsize, dllsize, %dllpath%
   
   hDLL := DLLCall("LoadLibrary", "Str", dllpath, "Ptr")
   lasterr := A_LastError
   err := ErrorLevel
   if (!hDLL)
   {
      errmsg = Sx2vJoy %version%`r`n`r`nCouldn't load vJoyInterface.dll from path %dllpath%`r`n`r`nLoadLibrary error: %err%`r`nLast system error: %lasterr%`r`nSx2vJoy bit architecture: %bitpath%`r`nOS: %A_OSVersion%`r`nOS bit version: x%regview%`nvJoy version: %ver%`r`nvJoyInterface.dll bit version: %dllver%`r`nvJoyInterface.dll size: %dllsize%
      msgbox,20,,%errmsg%`n`nCopy error message to clipboard before exiting?
      IfMsgBox, Yes
         clipboard = %errmsg%
      ExitApp
   }

   VarSetCapacity(Dll_Ver_tmp, 16, 0)
   VarSetCapacity(Drv_Ver_tmp, 16, 0)
   DriverMatch := DllCall("vJoyInterface\DriverMatch", "UInt*", Dll_Ver_tmp, "UInt*", Drv_Ver_tmp)
   Dll_Ver := numget(Dll_Ver_tmp)
   Drv_Ver := numget(Drv_Ver_tmp)
   
   if (DriverMatch <> 1) {
      msgbox,16,Sx2vJoy %version%,vJoy driver version does not match vJoyInterface.dll version.`n`nExiting.
      ExitApp
   }
   
   return hDLL
}

_setup(mode, x, y, z, xR=0, yR=0, zR=0) {
   VJOY_SetAxes(50, 50, 50, 50, 50, 50)
   axis := ""
   
   (mode = 1) and ((x >= (350/2)) or (x <= (-350/2))) ? axis := "x"
   (mode = 1) and ((y >= (350/2)) or (y <= (-350/2))) ? axis := "y"
   (mode = 1) and ((z >= (350/2)) or (z <= (-350/2))) ? axis := "z"
   
   (mode = 2) and ((x >= (350/2)) or (x <= (-350/2))) ? axis := "xR"
   (mode = 2) and ((y >= (350/2)) or (y <= (-350/2))) ? axis := "yR"
   (mode = 2) and ((z >= (350/2)) or (z <= (-350/2))) ? axis := "zR"
   
   (mode = 3) and ((x >= (350/2)) or (x <= (-350/2))) ? axis := "x"
   (mode = 3) and ((y >= (350/2)) or (y <= (-350/2))) ? axis := "y"
   (mode = 3) and ((z >= (350/2)) or (z <= (-350/2))) ? axis := "z"
   (mode = 3) and ((xR >= (350/2)) or (xR <= (-350/2))) ? axis := "xR"
   (mode = 3) and ((yR >= (350/2)) or (yR <= (-350/2))) ? axis := "yR"
   (mode = 3) and ((zR >= (350/2)) or (zR <= (-350/2))) ? axis := "zR"
   
   if (axis = "")
      return
   
   sleep, 1000

   loop, 6
   {
      remain := 6 - A_Index
      if (remain = 0)
         break
      msg := "Axis recognized:   "%remain%
      msg2 := "`n`n1) Let your controller go now.`n2) Select which function to assign axis movement to.`n`n"
      msg3 := " seconds until movement"
      
      SplashImage, "", B W375 C0 x0 y0 fs12, %msg% %axis% %msg2%%remain% %msg3%
      sleep, 1000
   }
   
   SplashImage, "", B W375 C0 x0 y0 fs12, Moving...
   sleep,500
   moveaxis(axis)
   SplashImage, "", B W375 C0 x0 y0 fs12, Done.
   sleep,2500
   msg := "1) Move axis on your controller.`n2) Wait for the moved axis to appear in this tooltip.`n3) Let go of your controller. Hands off completely.`n4) In the game's controls configuration menu`, select which function to assign axis movement to.`n`nPress Ctrl+Alt+S again to exit setup mode."
   SplashImage, "", B W375 C0 x0 y0 fs12, %msg%
}

_setupblind(mode, x, y, z, xR=0, yR=0, zR=0) {
   VJOY_SetAxes(50, 50, 50, 50, 50, 50)
   axis := ""
   (mode = 1) and ((x >= (350/2)) or (x <= (-350/2))) ? axis := "x"
   (mode = 1) and ((y >= (350/2)) or (y <= (-350/2))) ? axis := "y"
   (mode = 1) and ((z >= (350/2)) or (z <= (-350/2))) ? axis := "z"
   
   (mode = 2) and ((x >= (350/2)) or (x <= (-350/2))) ? axis := "xR"
   (mode = 2) and ((y >= (350/2)) or (y <= (-350/2))) ? axis := "yR"
   (mode = 2) and ((z >= (350/2)) or (z <= (-350/2))) ? axis := "zR"
   
   (mode = 3) and ((x >= (350/2)) or (x <= (-350/2))) ? axis := "x"
   (mode = 3) and ((y >= (350/2)) or (y <= (-350/2))) ? axis := "y"
   (mode = 3) and ((z >= (350/2)) or (z <= (-350/2))) ? axis := "z"
   (mode = 3) and ((xR >= (350/2)) or (xR <= (-350/2))) ? axis := "xR"
   (mode = 3) and ((yR >= (350/2)) or (yR <= (-350/2))) ? axis := "yR"
   (mode = 3) and ((zR >= (350/2)) or (zR <= (-350/2))) ? axis := "zR"
   
   if (axis = "")
      return
   
   ComObjCreate("SAPI.SpVoice").Speak("2")
   sleep, 5000
   
   moveaxis(axis)
   
   sleep, 500
   
   ComObjCreate("SAPI.SpVoice").Speak("3")
   sleep, 500
   ComObjCreate("SAPI.SpVoice").Speak("1")
}

_vjoy_sticks() {
   global version, hDLL
   sticks := ""
   
   loop, 16
   {
      ;DllCall("vJoyInterface\vJoyEnabled") ; for some strange reason this is necessary on some systems so GetVJDStatus doesn't crash every other call
      vjoy_num := DllCall("vJoyInterface\GetVJDStatus", "UInt", A_Index)
      if (vjoy_num = 1)
      {
         sticks .= A_Index . "|"
      }
   }
   if (substr(sticks, 0, 1) = "|")
   {
      stringtrimright, sticks, sticks, 1
      return sticks
   }
   msgbox,16,Sx2vJoy %version%,No vJoy sticks found`, or another instance of Sx2vJoy is already running.`nCannot continue.`n`nExiting.
   ExitApp
}

_setupControls(vJoys, 3dcIndexes) {
   global version, aDevices, vJoy_device, 3DC_device, used3DCcontroller
   num_vJoys := ""
   num_3DCs := ""
   
   stringsplit, count_vjoys, vJoys, "|"
   stringsplit, count_3DCs, 3dcIndexes, "|"
   
   if (count_vjoys0 = 1) and (count_3DCs0 = 1)
      return vJoys "," aDevices[3dcIndexes,0]
   
   ;msgbox setupControls`n`n%vJoys%`n%3dcIndexes%
   
   target_device := vJoys[1]

   
   gui, name:new,Hwndhwnd_sx,Sx2vJoy %version%
   gui, name:add, text,w169 h15, Select your 3DConnexion controller:
   gui, name:add, text, x10 y40 w160 h50, Select the vJoy target device:
   
   vJoy_list := ""
   loop %count_vjoys0%
   {
      vJoy_list .= (A_Index <> count_vjoys0) ? count_vjoys%A_Index% . "|" : count_vjoys%A_Index%
      
      if (count_vjoys0 = 1)
         vJoy_list .= (A_Index = count_vjoys0) ? "||" : "" ; preselect last vJoy target device
      else
      {
         ;vJoy_list .= (A_Index = 1) ? "|" : "" ; preselect first vJoy target device
         vJoy_list .= (A_Index = count_vjoys0) ? "||" : "" ; preselect last vJoy target device
      }
   }
      
   3DC_list := ""
   3DC_list_idx := ""
   loop %count_3DCs0%
   {
      3DC_list .= (A_Index <> count_3DCs0) ? aDevices[count_3DCs%A_Index%,1] . "|" : aDevices[count_3DCs%A_Index%,1]
      3DC_list_idx .= count_3DCs%A_Index% . "|"
      if (count_3DCs0 = 1)
         3DC_list .= (A_Index = count_3DCs0) ? "||" : "" ; preselect last 3DConnexion device
      else
      {
         3DC_list .= (A_Index = 1) ? "|" : "" ; preselect first 3DConnexion device
         ;3DC_list .= (A_Index = count_3DCs0) ? "||" : "" ; preselect last 3DConnexion device
      }
   }
   
   gui, name:add, dropdownlist, x185 y2 w180 v3DC_device AltSubmit, %3DC_list%
   gui, name:add, dropdownlist, x185 y37 w180 vvJoy_device, %vJoy_list%
   gui, name:add, button, x145 y70 w80 Default gnamebtn, OK
   gui, name:show, AutoSize Center
   
   Loop
   {
      sleep, 10
      winget, out, list, ahk_id %hwnd_sx%
      if (out = 0)
         break
   }
   
   idx := 3DC_device
   stringsplit, idxsplit, 3DC_list_idx, "|"
   used3DCcontroller := aDevices[idxsplit%idx%,0]
   return vJoy_device "," used3DCcontroller
   
   namebtn:
   gui, submit, nohide
   gui, destroy
   return
   
   nameGuiClose:
   nameGuiEscape:
   ExitApp
   return
}

PrintArray(Array, Display=1, Level=0)
	{
		Global PrintArray
				
		Loop, % 4 + (Level*8)
		Tabs .= A_Space
		
		Output := "Array`r`n" . SubStr(Tabs, 5) . "(" 
		
		For Key, Value in Array
		  {
				If (IsObject(Value))
				  {
            Level++
						Value := PrintArray(Value, 0, Level)
						Level--
					}
				
				Output .= "`r`n" . Tabs . "[" . Key . "] => " . Value
			}
		
		Output .= "`r`n" . SubStr(Tabs, 5) . ")"
		
		
		If (!Display)
	  Return Output
	  
		Gui, PrintArray:+MaximizeBox +Resize
		Gui, PrintArray:Font, s9, Courier New
	  Gui, PrintArray:Add, Edit, x12 y10 w450 h350 vPrintArray ReadOnly HScroll, %Output%
    Gui, PrintArray:Show, w476 h374, PrintArray
	  Gui, PrintArray:+LastFound
	  ControlSend, , {Right}
	  WinWaitClose
    Return Output

	  PrintArrayGuiSize:
    Anchor("PrintArray", "wh")
    Return

    PrintArrayGuiClose:
    Gui, PrintArray:Destroy
    Return
	}

/*
	Function: Anchor
		Defines how controls should be automatically positioned relative to the new dimensions of a window when resized.

	Parameters:
		cl - a control HWND, associated variable name or ClassNN to operate on
		a - (optional) one or more of the anchors: 'x', 'y', 'w' (width) and 'h' (height),
			optionally followed by a relative factor, e.g. "x h0.5"
		r - (optional) true to redraw controls, recommended for GroupBox and Button types

	Examples:
> "xy" ; bounds a control to the bottom-left edge of the window
> "w0.5" ; any change in the width of the window will resize the width of the control on a 2:1 ratio
> "h" ; similar to above but directrly proportional to height

	Remarks:
		To assume the current window size for the new bounds of a control (i.e. resetting) simply omit the second and third parameters.
		However if the control had been created with DllCall() and has its own parent window,
			the container AutoHotkey created GUI must be made default with the +LastFound option prior to the call.
		For a complete example see anchor-example.ahk.

	License:
		- Version 4.60a <http://www.autohotkey.net/~Titan/#anchor>
		- Simplified BSD License <http://www.autohotkey.net/~Titan/license.txt>
*/
Anchor(i, a = "", r = false) {
	static c, cs = 12, cx = 255, cl = 0, g, gs = 8, gl = 0, gpi, gw, gh, z = 0, k = 0xffff
	If z = 0
		VarSetCapacity(g, gs * 99, 0), VarSetCapacity(c, cs * cx, 0), z := true
	If (!WinExist("ahk_id" . i)) {
		GuiControlGet, t, Hwnd, %i%
		If ErrorLevel = 0
			i := t
		Else ControlGet, i, Hwnd, , %i%
	}
	VarSetCapacity(gi, 68, 0), DllCall("GetWindowInfo", "UInt", gp := DllCall("GetParent", "UInt", i), "UInt", &gi)
		, giw := NumGet(gi, 28, "Int") - NumGet(gi, 20, "Int"), gih := NumGet(gi, 32, "Int") - NumGet(gi, 24, "Int")
	If (gp != gpi) {
		gpi := gp
		Loop, %gl%
			If (NumGet(g, cb := gs * (A_Index - 1)) == gp) {
				gw := NumGet(g, cb + 4, "Short"), gh := NumGet(g, cb + 6, "Short"), gf := 1
				Break
			}
		If (!gf)
			NumPut(gp, g, gl), NumPut(gw := giw, g, gl + 4, "Short"), NumPut(gh := gih, g, gl + 6, "Short"), gl += gs
	}
	ControlGetPos, dx, dy, dw, dh, , ahk_id %i%
	Loop, %cl%
		If (NumGet(c, cb := cs * (A_Index - 1)) == i) {
			If a =
			{
				cf = 1
				Break
			}
			giw -= gw, gih -= gh, as := 1, dx := NumGet(c, cb + 4, "Short"), dy := NumGet(c, cb + 6, "Short")
				, cw := dw, dw := NumGet(c, cb + 8, "Short"), ch := dh, dh := NumGet(c, cb + 10, "Short")
			Loop, Parse, a, xywh
				If A_Index > 1
					av := SubStr(a, as, 1), as += 1 + StrLen(A_LoopField)
						, d%av% += (InStr("yh", av) ? gih : giw) * (A_LoopField + 0 ? A_LoopField : 1)
			DllCall("SetWindowPos", "UInt", i, "Int", 0, "Int", dx, "Int", dy
				, "Int", InStr(a, "w") ? dw : cw, "Int", InStr(a, "h") ? dh : ch, "Int", 4)
			If r != 0
				DllCall("RedrawWindow", "UInt", i, "UInt", 0, "UInt", 0, "UInt", 0x0101) ; RDW_UPDATENOW | RDW_INVALIDATE
			Return
		}
	If cf != 1
		cb := cl, cl += cs
	bx := NumGet(gi, 48), by := NumGet(gi, 16, "Int") - NumGet(gi, 8, "Int") - gih - NumGet(gi, 52)
	If cf = 1
		dw -= giw - gw, dh -= gih - gh
	NumPut(i, c, cb), NumPut(dx - bx, c, cb + 4, "Short"), NumPut(dy - by, c, cb + 6, "Short")
		, NumPut(dw, c, cb + 8, "Short"), NumPut(dh, c, cb + 10, "Short")
	Return, true
}

_IniReadSection(iniFile, Section) {
   FileRead, DAT, %iniFile%
   StringReplace, DAT, DAT, `r`n, `n, All
   sStr:="[" Section "]", sPos:=InStr(DAT,sStr)+(L:=StrLen(sStr)), End:=StrLen(DAT)-sPos
   rStr := SubStr( DAT, sPos, ((E:=InStr(DAT,"`n[",0,sPos)) ? E-sPos : End) )
   Return RegExReplace( rStr, "^\n*(.*[^\n])\n*$", "$1", "m" )
}

_configMain(parameter) {
   global currentProfile, forcemode, lastGUIprofile, MsgExe, lastConfigCheck, showIfActive, oldMsgExe, oldExe
   sleep, 500
   currentProfile := "default"
   _readGeneral()
   if (forcemode = 1) and not (lastGUIprofile = "") ; use profile as (last) set in GUI
      currentProfile := lastGUIprofile
   else
   {
      Loop, Read, config.ini
      {
         RegExMatch(A_LoopReadLine , "^\[(.+)]", match)
         If (match1)
         {
            iniread, tempForce, config.ini, %match1%, force
            iniread, tempExtbl, config.ini, %match1%, executable
            if (tempForce = 1) ; use "always active" profile
            {
               currentProfile := match1
            }
            if (tempForce = 2) and not (tempExtbl = "") and not (tempExtbl = " ") ; switch between "specific application" profiles
            {
               if (tempExtbl = oldExe)
               {
                  currentProfile := match1
               }
            }
         }
      }
   }
   
   if (showIfActive = 1) 
   {
      TrayTip
      TrayTip, Sx2vJoy, Profile: %currentProfile%`nProcess: %oldExe%, 5
   }
      
   _readAxesConfig(currentProfile)
   _readBtnConfig(currentProfile)
   _readAxesOrder(currentProfile)
   lastConfigCheck := A_Now . A_MSec
}

ShellMessage(wParam, lParam) {
   _activeWinCheck()
}

_activeWinCheck() {
   global oldExe
   WinGet, currentActiveID, ID, A
   WinGet, currentExe, ProcessName, ahk_id %currentActiveID%
   if not (oldExe = currentExe)
   {
      oldExe := currentExe
      _configMain(1)
   }
}

_vJoy_Close() {
   global vjoy_id
   DllCall("vJoyInterface\ResetVJD", "UInt", vjoy_id)
   DllCall("vJoyInterface\RelinquishVJD", "UInt", vjoy_id)
}

;By Laszlo, adapted by TheGood
;http://www.autohotkey.com/forum/viewtopic.php?p=377086#377086
Bin2Hex(addr,len) {
   Static fun, ptr 
   If (fun = "") {
      If A_IsUnicode
         If (A_PtrSize = 8)
            h=4533c94c8bd14585c07e63458bd86690440fb60248ffc2418bc9410fb6c0c0e8043c090fb6c00f97c14180e00f66f7d96683e1076603c8410fb6c06683c1304180f8096641890a418bc90f97c166f7d94983c2046683e1076603c86683c13049ffcb6641894afe75a76645890ac366448909c3
         Else h=558B6C241085ED7E5F568B74240C578B7C24148A078AC8C0E90447BA090000003AD11BD2F7DA66F7DA0FB6C96683E2076603D16683C230668916240FB2093AD01BC9F7D966F7D96683E1070FB6D06603CA6683C13066894E0283C6044D75B433C05F6689065E5DC38B54240833C966890A5DC3
      Else h=558B6C241085ED7E45568B74240C578B7C24148A078AC8C0E9044780F9090F97C2F6DA80E20702D1240F80C2303C090F97C1F6D980E10702C880C1308816884E0183C6024D75CC5FC606005E5DC38B542408C602005DC3
      VarSetCapacity(fun, StrLen(h) // 2)
      Loop % StrLen(h) // 2
         NumPut("0x" . SubStr(h, 2 * A_Index - 1, 2), fun, A_Index - 1, "Char")
      ptr := A_PtrSize ? "Ptr" : "UInt"
      DllCall("VirtualProtect", ptr, &fun, ptr, VarSetCapacity(fun), "UInt", 0x40, "UInt*", 0)
   }
   VarSetCapacity(hex, A_IsUnicode ? 4 * len + 2 : 2 * len + 1)
   DllCall(&fun, ptr, &hex, ptr, addr, "UInt", len, "CDecl")
   VarSetCapacity(hex, -1) ; update StrLen
   Return hex
}

_vJoyInfo(from) {
   global version
   if (from = 1)
      msgbox, 52,Sx2vJoy %version%,vJoy does not appear to be installed.`n`nvJoy is an open source virtual joystick software required by Sx2vJoy to make it possible to translate input commands from your 3DConnexion controller into joystick movements.`n`nDo you want me to point you to the vJoy download site now?
   
   if (from = 2)
      msgbox, 52,Sx2vJoy %version%,An older version of vJoy appears to be installed, one that Sx2vJoy cannot work with anymore.`n`nDo you want me to point you to the vJoy download site now?
   
   ifmsgbox no
      msgbox, 48,Sx2vJoy %version%, Please remember that Sx2vJoy cannot continue without a current version of vJoy.`n`nExiting.
      
   ifmsgbox yes
   {
      run "http://vjoystick.sourceforge.net/site/index.php/download-a-install/72-download"
      msgbox, 48,Sx2vJoy %version%, Download and install vJoy with all settings enabled, then restart Sx2vJoy.`n`n Exiting (for now).
   }
   exitapp
}

_checkvJoyAxes() {
   global vjoy_id, vjoyconfigdir
   
   if (_vJoyAxisState() = 0)
   {   
      msgbox, 52,Sx2vJoy %version%, The vJoy stick with ID %vjoy_id% does not have an axis configuration that Sx2vJoy can work with.`n`nShall Sx2vJoy attempt to fix this? You'll see a command prompt window opening and closing and hear the device disconnected and connected sounds.
      ifmsgbox no
      {
         msgbox, 48,Sx2vJoy %version%, Cannot work with a misconfigured vJoy stick.`n`nExiting.
         ExitApp
      }
      ifmsgbox yes
      {
         run %vjoyconfigdir%\vjoyconfig.exe %vjoy_id% -f -a x y z rx ry rz -b 26
         sleep, 2000
         if (_vJoyAxisState() = 0)
         {
            msgbox, 48,Sx2vJoy %version%, The attempt to reconfigure the vJoy stick with ID %vjoy_id% has failed. Please fix it manually.`n`nRequired axes:`nX`nY`nZ`nRx`nRy`nRz
            ExitApp
         }
         Run *RunAs "%A_ScriptFullPath%"
         ExitApp
      }
   }
}

_vJoyAxisState() {
   global vjoy_id, HID_USAGE_X, HID_USAGE_Y, HID_USAGE_Z, HID_USAGE_RX, HID_USAGE_RY, HID_USAGE_RZ
   testX := DllCall("vJoyInterface\GetVJDAxisExist", "UInt", vjoy_id, "UInt", HID_USAGE_X)
   testY := DllCall("vJoyInterface\GetVJDAxisExist", "UInt", vjoy_id, "UInt", HID_USAGE_Y)
   testZ := DllCall("vJoyInterface\GetVJDAxisExist", "UInt", vjoy_id, "UInt", HID_USAGE_Z)
   testRX := DllCall("vJoyInterface\GetVJDAxisExist", "UInt", vjoy_id, "UInt", HID_USAGE_RX)
   testRY := DllCall("vJoyInterface\GetVJDAxisExist", "UInt", vjoy_id, "UInt", HID_USAGE_RY)
   testRZ := DllCall("vJoyInterface\GetVJDAxisExist", "UInt", vjoy_id, "UInt", HID_USAGE_RZ)
   
   if (testX = 0) or (testY = 0) or (testZ = 0) or (testRX = 0) or (testRY = 0) or (testRZ = 0)
      return 0
   return 1
}

_reconnect() {
   global vjoy_id, reconnect
   _vJoy_Close()
   InitVJoy(vjoy_id)
   _checkvJoyAxes()
}

; param1 = keyword; param2 = vJoy ID; param3 = vendor ID; param4 = product ID; param5 = exe to restart; param6 = PID to monitor
_watchdog(vj_id, 3dc_vid, 3dc_pid, source, PID) {
   DllCall("kernel32.dll\SetProcessShutdownParameters", UInt, 0x4FE, UInt, 0)
   stringsplit, monitor, source, "\"
   monitor := monitor%monitor0%
   OnExit, AppQuitWD
   Loop
   {
      regread, crashui, HKCU, SOFTWARE\Microsoft\Windows\Windows Error Reporting\, DontShowUI
      if (crashui = 0)
         regwrite, REG_DWORD, HKCU, SOFTWARE\Microsoft\Windows\Windows Error Reporting\, DontShowUI, 1
      
      process, exist, %PID%
      if not errorlevel
      {
         Run *RunAs "%source%" "recover" %vj_id% %3dc_vid% %3dc_pid%
         stringsplit, logdir_tmp, source, "\"
         logdir := ""
         loops := logdir_tmp0 - 1
         loop, %loops%
            logdir .= logdir_tmp%A_Index% . "\"
         logfile = %logdir%restart.log
         name := logdir_tmp%logdir_tmp0%
         stringtrimright, name, name, 4
         content = %A_Year%-%A_Mon%-%A_MDay% %A_Hour%:%A_Min%:%A_Sec%`trestarted %name%
         fileappend, %content%, %logfile%
         _WDselfDelete()
         exitapp
      }
      sleep, 100
   }
}

_WDselfDelete() {
   wddel = %A_ScriptDir%\wddel.cmd
   pidself := DllCall("GetCurrentProcessId")
   content = :loop`ntasklist | find " %pidself% " > nul`nif not errorlevel 1 (`n`ttimeout /t 1 > nul`n`tgoto :loop`n)`ndel "%A_ScriptFullPath%"`ndel "%wddel%"
   fileappend, %content%, %wddel%
   Run, %COMSPEC% /c %wddel%,,hide 
}

_3DCIDsToName() {
   global aDevices, vendorID, productID
   string := vendorID . "," . productID
   loops := aDevices[0,0]
   Loop, %loops%
   {
      if (aDevices[A_Index,0] = string)
         return aDevices[A_Index,1]
   }
}

ShChangeNotify(wParam, lParam, msg, hwnd) {
   hLock := DllCall("Shell32\SHChangeNotification_Lock", UInt,wParam, UInt,lParam, UIntP,pppidl, UIntP,plEvent)
   if (plEvent = 0x00002000)
   {
      Val1 := PIDLGetPath(NumGet(pppidl+0))
      stringright, cfg, Val1, 10
      if (cfg = "config.ini")
         _configMain(0)
   }
   DllCall("Shell32\SHChangeNotification_Unlock", UInt,hLock)
}

PathGetPIDL(sPath) {
   Return DllCall("Shell32\ILCreateFromPath"(A_IsUnicode ? "W":"A"), Str,sPath, UInt)
}

PIDLGetPath(PIDL) {
   VarSetCapacity(sPath, 520, 0)
   DllCall("Shell32\SHGetPathFromIDList"(A_IsUnicode ? "W":"A"), UInt,PIDL, Str,sPath)
   Return sPath
}

FileGetVersionInfo_AW( peFile="", StringFileInfo="", Delimiter="|") {    ; Written by SKAN
   ; www.autohotkey.com/forum/viewtopic.php?t=64128          CD:24-Nov-2008 / LM:28-May-2010
   Static CS, HexVal, Sps="                        ", DLL="Version\"
   
   If ( CS = "" )
      CS := A_IsUnicode ? "W" : "A", HexVal := "msvcrt\s" (A_IsUnicode ? "w": "" ) "printf"
   
   If ! FSz := DllCall( DLL "GetFileVersionInfoSize" CS , Str,peFile, UInt,0 )
      Return "", DllCall( "SetLastError", UInt,1 )
   
   VarSetCapacity( FVI, FSz, 0 ), VarSetCapacity( Trans,8 * ( A_IsUnicode ? 2 : 1 ) )
   DllCall( DLL "GetFileVersionInfo" CS, Str,peFile, Int,0, UInt,FSz, UInt,&FVI )
   
   If ! DllCall( DLL "VerQueryValue" CS, UInt,&FVI, Str,"\VarFileInfo\Translation", UIntP,Translation, UInt,0 )
      Return "", DllCall( "SetLastError", UInt,2 )
   
   If ! DllCall( HexVal, Str,Trans, Str,"%08X", UInt,NumGet(Translation+0) )
      Return "", DllCall( "SetLastError", UInt,3 )
   
   Loop, Parse, StringFileInfo, %Delimiter%
   {
      subBlock := "\StringFileInfo\" SubStr(Trans,-3) SubStr(Trans,1,4) "\" A_LoopField
      If ! DllCall( DLL "VerQueryValue" CS, UInt,&FVI, Str,SubBlock, UIntP,InfoPtr, UInt,0 )
         Continue
      Value := DllCall( "MulDiv", UInt,InfoPtr, Int,1, Int,1, "Str"  )
      Info  .= Value ? ( ( InStr( StringFileInfo,Delimiter ) ? SubStr( A_LoopField Sps,1,24 )
      .  A_Tab : "" ) . Value . Delimiter ) : ""
   }
   StringTrimRight, Info, Info, 1
   Return Info
}

_fileWriteLog(sLogPath, sLogMsg) {
	sDateNow := A_YEAR . "-" . A_MON . "-" . A_MDAY
	sTimeNow := A_HOUR . ":" . A_MIN . ":" . A_SEC
	sMsg := sDateNow . " " . sTimeNow . " : " . sLogMsg

	FileRead, out, %sLogPath%
	if (errorlevel = 0)
		sMsg = %sMsg%`r`n%out%

	file := FileOpen(sLogPath, 1)
	File.Write(sMsg)
	File.Close()
}

; ------------------------------------------------------------------------------
; Function .....: FileVerInfo
; Description ..: Return Version Information for the selected file
; Parameters ...: sFile      - Path to the file
; ..............: sVerString - Pipe-separated list of the properties to retrieve
; ..............:              If empty, all properties will be retrieved
; Return .......: String with properties on success, 0 on error
; AHK Version ..: AutoHotkey 1.0.48.5
; Author .......: Cyruz - http://ciroprincipe.info
; License ......: WTFPL - http://www.wtfpl.net/txt/copying/
; Changelog ....: Nov. 17, 2012 - ver 0.1 - First revision
; ------------------------------------------------------------------------------
FileVerInfo(sFile, sVerString="") {
    
    sVerString := (sVerString) ? sVerString : "Comments|CompanyName|FileDescription|FileVersion|InternalName|LegalCopyright|LegalTrademarks|OriginalFilename|ProductName|ProductVersion|PrivateBuild|SpecialBuild"

    If (! nSize := DllCall( "Version.dll\GetFileVersionInfoSizeA"
                          ,  Str,  sFile
                          ,  UInt, 0 ))
        Return 0

    VarSetCapacity(cBuf, nSize)
    If (! DllCall( "Version.dll\GetFileVersionInfoA"
                 ,  Str,  sFile
                 ,  UInt, 0
                 ,  UInt, nSize
                 ,  UInt, &cBuf ))
        Return 0

    If (! DllCall( "Version.dll\VerQueryValueA"
                 ,  UInt,  &cBuf
                 ,  Str,   "\\VarFileInfo\\Translation"
                 ,  UIntP, pAddrVerBuf
                 ,  UIntP, nVerBufSize ))
        Return 0
        
    VarSetCapacity(sLangCodePg, 8)
    DllCall( "msvcrt\sprintf"
           ,  Str,   sLangCodePg
           ,  Str,   "%04X%04X"
           ,  Short, NumGet(pAddrVerBuf+0, 0, "Short")
           ,  Short, NumGet(pAddrVerBuf+0, 2, "Short") )

    StringSplit, sVerString, sVerString, |    
    Loop, %sVerString0%
    {
        DllCall( "Version.dll\VerQueryValueA"
               ,  UChar, &cBuf
               ,  Str,   "\\StringFileInfo\\" . sLangCodePg . "\\" . sVerString%A_Index%
               ,  UIntP, pAddrVerBuf
               ,  UIntP, nVerBufSize )

        VarSetCapacity(cVerBuf, nVerBufSize)
        DllCall( "Kernel32.dll\lstrcpyn"
               ,  Str,  cVerBuf
               ,  UInt, pAddrVerBuf
               ,  Int,  nVerBufSize )
        
        RetString .= sVerString%A_Index% . "|" . cVerBuf . "|"
    }

    Return SubStr(RetString, 1, -1)
}

AppQuit:
OnExit
trayTip, Sx2vJoy v%version%, Closing...
;regwrite, REG_DWORD, HKCU, SOFTWARE\Microsoft\Windows\Windows Error Reporting\, DontShowUI, 0
AHKHID_Register(1,8,0,RIDEV_REMOVE)
DllCall("Shell32\SHChangeNotifyDeregister", UInt,SHCNR_ID)
if (vjoy_id <> 0) and (vjoy_id <> "")
   _VJoy_Close()
process, close, %wdexename%
process, waitclose, %wdexename%, 10
if (hDLL <> "")
   DLLCall("FreeLibrary", "Ptr", hDLL)
filedelete, %dest%
ExitApp
return

AppQuitWD:
_WDselfDelete()
ExitApp
return

joy:
run joy.cpl
return

gui:
SxGUI := A_ScriptDir . "\Sx2vJoy Config GUI.exe"
ifnotexist, %SxGUI%
   msgbox,48,Sx2vJoy %version%,Sx2vJoy Config GUI not found.
else
   run, "%SxGUI%"
return

config:
filetime := filegettime("config.ini")
;_activeWinCheck()
if (filetime > lastConfigCheck)
   _configMain(0)
return

label_down:
Controller_settings[wheelstate] -= 1
axis := 0
axis := Controller_settings[axis_x, is_throttle] = 2 ? "x" : axis
axis := Controller_settings[axis_y, is_throttle] = 2 ? "y" : axis
axis := Controller_settings[axis_z, is_throttle] = 2 ? "z" : axis
axis := Controller_settings[axis_xR, is_throttle] = 2 ? "xR" : axis
axis := Controller_settings[axis_yR, is_throttle] = 2 ? "yR" : axis
axis := Controller_settings[axis_zR, is_throttle] = 2 ? "zR" : axis

if (axis <> 0)
   _process_throttle(axis, 0, 2)
return

label_up:
Controller_settings[wheelstate] += 1
axis := 0
axis := Controller_settings[axis_x, is_throttle] = 2 ? "x" : axis
axis := Controller_settings[axis_y, is_throttle] = 2 ? "y" : axis
axis := Controller_settings[axis_z, is_throttle] = 2 ? "z" : axis
axis := Controller_settings[axis_xR, is_throttle] = 2 ? "xR" : axis
axis := Controller_settings[axis_yR, is_throttle] = 2 ? "yR" : axis
axis := Controller_settings[axis_zR, is_throttle] = 2 ? "zR" : axis

if (axis <> 0)
   _process_throttle(axis, 0, 2)
return

label_zero:
Controller_settings[wheelstate] := 0
axis := 0
axis := Controller_settings[axis_x, is_throttle] = 2 ? "x" : axis
axis := Controller_settings[axis_y, is_throttle] = 2 ? "y" : axis
axis := Controller_settings[axis_z, is_throttle] = 2 ? "z" : axis
axis := Controller_settings[axis_xR, is_throttle] = 2 ? "xR" : axis
axis := Controller_settings[axis_yR, is_throttle] = 2 ? "yR" : axis
axis := Controller_settings[axis_zR, is_throttle] = 2 ? "zR" : axis

if (axis <> 0)
   _process_throttle(axis, 0, 2)
return

label_displayaxesinput:
displayaxesinput *= -1
tooltip
return

label_setaxis:
setupmode *= -1
if (setupmode = 1) {
   msg := "1) Move axis on your controller.`n2) Wait for the moved axis to appear in this tooltip.`n3) Let go of your controller. Hands off completely.`n4) In the game's controls configuration menu`, select which function to assign axis movement to.`n`nPress Ctrl+Alt+S again to exit setup mode."
   SplashImage, "", B W375 C0 x0 y0 fs12, %msg%
}
else {
   SplashImage, off
}
return

label_setaxisblind:
setupmodeblind *= -1
if (setupmodeblind = 1) {
   ComObjCreate("SAPI.SpVoice").Speak("1")
}
else {
   ComObjCreate("SAPI.SpVoice").Speak("4")
}
return

label_buttonlog:
buttonlog *= -1
if (buttonlog = 1) {
   filedelete, Sx2vJoy.log
   logstart := 1
   msg := "1) Press all of the buttons on your 3DConnexion device`, one after the other.`n2) Press hotkey again to exit logging mode.`n3) See Sx2vJoy.log for details."
   SplashImage, "", B W550 C0 x0 y0 fs12, %msg%
}
else {
   logstart := 0
   SplashImage, off
}
return

about:
3dcname := _3DCIDsToName()
msgbox,64,Sx2vJoy, Sx2vJoy v%version% by Lasse B.`n`n%3dcname% connected to vJoy ID %vjoy_id%
return