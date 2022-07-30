#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Sx2vJoy.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Fileversion=1.2.6.0
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/so
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <GuiButton.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <GuiComboBox.au3>
#include <file.au3>
#include <array.au3>
#include <GuiComboBoxEx.au3>
#include <GdiPlus.au3>
#include <EditConstants.au3>
#include "Libraries\StringSize.au3"
#include "Libraries\Marquee.au3"

_GDIPlus_Startup()

Global $inisection = "default"
Global $version = "v1.2 build 9 unofficial 1"

$Form1 = GUICreate("Sx2vJoy Config GUI " & $version, 738, 758)
$width = 130
$height = 155
$spacebetween_x = 5
$spacebetween_y = 5
$spacefromborder_x = 8
$spacefromborder_y = 240

$PreLabelSpaceBetween = 22.25
$PreLabelOffset_X = 5
$PreLabelOffset_Y = 22

$PostLabelSpaceBetween = 22
$PostLabelOffset_X = 5
$PostLabelOffset_Y = 23

$InputSpaceBetween = 22
$InputOffset_X = 20
$InputOffset_Y = 20

$CheckboxSpaceBetween = 22
$CheckboxOffset_X = 20
$CheckboxOffset_Y = 22

$InfoOffset_X = 113
$InfoOffset_Y = 9
$InfoWidth = 13
$InfoHeight = 14

Global $aMarqueeBtn = ""
Global $aMarqueeAxs = ""

Dim $aButtonIDs2[0][2]

Dim $aDeviceButtons[10][4] = [["SpaceBall 5000 (USB)", 12, "0,1,2,3,4,5,6,7,8,9,10,11", "1,2,3,4,5,6,7,8,9,A,B,C"], ["SpaceExplorer", 15, "0,1,2,3,4,5,6,7,8,9,10,11,12,13,14", "1,2,T,L,R,F,ESC,ALT,SHIFT,CTRL,FIT,PANEL,+,-,2D"], ["SpaceMouse Plus (XT) USB", 11, "0,1,2,3,4,5,6,7,8,9,10", "1,2,3,4,5,6,7,8,*,Left,Right"], ["SpaceMouse Pro", 15, "0,1,2,4,5,8,12,13,14,15,22,23,24,25,26", "MENU,FIT,T,R,F,ROL,1,2,3,4,ESC,ALT,SHIFT,CTRL,ROT"], ["SpaceMouse Pro Wireless", 15, "0,1,2,4,5,8,12,13,14,15,22,23,24,25,26", "MENU,FIT,T,R,F,ROL,1,2,3,4,ESC,ALT,SHIFT,CTRL,ROT"], ["SpaceMouse Wireless", 2, "0,1", "Left, Right"], ["SpaceNavigator", 2, "0,1", "Left,Right"], ["SpaceNavigator for Notebooks", 2, "0,1", "Left,Right"], ["SpacePilot", 21, "0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20", "1,2,3,4,5,6,T,L,R,F,ESC,ALT,SHIFT,CTRL,FIT,PANEL,VOL+,VOL-,DOM,3D,CONFIG"], ["SpacePilot Pro", 21, "0,1,2,4,5,8,10,12,13,14,15,16,22,23,24,25,26,27,28,29,30", "MENU,FIT,T,R,F,ROL,ISO,1,2,3,4,5,ESC,ALT,SHIFT,CTRL,PAN/ZOOM,ROT,DOM,+,-"]]

Global $swapRotTrans = 0

Dim $aLabels[6] = ["x", "y", "z", "xR", "yR", "zR"]
Dim $aLabelsvJ[6] = ["x", "y", "z", "xR", "yR", "zR"]
Dim $aLabelsvJRev[6] = ["xR", "yR", "zR", "x", "y", "z"]

Dim $aHandlesIDsLUT[0][3]

Dim $aDeadzoneIDs[1][4]
Dim $aLinSensIDs[1][5]
Dim $aLogSensIDs[1][4]
Dim $aExponentIDs[1][4]
Dim $aGraphIDs[1][4]
Dim $aAxisRadio[9]

Dim $aIsThrottleIDs[1][4]
Dim $aThrottleStepsIDs[1][4]
Dim $aThrottleZeroIDs[1][4]

Dim $aInvertIDs[1][4]

Dim $aAxesIDs[1]
Dim $aButtonIDs[2]
Dim $aProfileIDs[9]

;----- PROFILES -----
Dim $start[1][2] = [[8, 8]]
_GUICtrlCreateGroupEx("Profiles ", $start[0][0], $start[0][1], 380, 207, 0xA9A9A9)
$aProfileIDs[0] = GUICtrlCreateButton("i", $start[0][0] + 365, $start[0][1] + 4, $InfoWidth, $InfoHeight)
$aProfiles = IniReadSectionNames(@ScriptDir & "\config.ini")
If Not IsArray($aProfiles) Then
	MsgBox(16, "Error", "No section names found in config.ini. Cannot continue.")
	Exit
EndIf
$search = _ArraySearch($aProfiles, "general", 1, 0, 0, 2)
_ArrayDelete($aProfiles, $search)
_ArrayInsert($aProfiles, 1, "default")
$aProfiles = _ArrayUnique($aProfiles, 0, 0, 0, 0)
_ArraySort($aProfiles, 0, 2)
$aProfiles[0] = UBound($aProfiles) - 1

GUICtrlCreateGroup("Currently Selected Profile:", $start[0][0] + 10, 25, 365, 150)
GUICtrlSetFont(-1, 9, 600)
$profileslist = ""

For $i = 1 To $aProfiles[0]
	$profileslist &= $aProfiles[$i] & "|"
Next
$profileslist = StringTrimRight($profileslist, 1)
$aProfileIDs[1] = GUICtrlCreateCombo("", $start[0][0] + 20, 45, 180, 20, $CBS_DROPDOWNLIST)
GUICtrlSetData($aProfileIDs[1], $profileslist)
_GUICtrlComboBox_SetCurSel($aProfileIDs[1], 0)

$aProfileIDs[2] = GUICtrlCreateButton("Delete Selected Profile...", $start[0][0] + 215, 46, 150, 20)

GUICtrlCreateLabel("Profile Activation Method", $start[0][0] + 20, 80, 120, 20)
$aProfileIDs[3] = GUICtrlCreateCombo("", $start[0][0] + 20, 95, 180, 20, $CBS_DROPDOWNLIST)
GUICtrlSetData($aProfileIDs[3], "Always Active|Off")
_GUICtrlComboBox_SetCurSel($aProfileIDs[3], 2)

$aProfileIDs[4] = GUICtrlCreateButton("Rename Selected Profile...", $start[0][0] + 215, 95, 150, 20)

GUICtrlCreateLabel("Choose Application", $start[0][0] + 20, 130, 120, 20)
$aProfileIDs[5] = GUICtrlCreateEdit("", $start[0][0] + 20, 145, 180, 20, 0x0800)
GUICtrlSetBkColor(-1, 0xFFFFFF)
$aProfileIDs[6] = GUICtrlCreateButton("Choose / Delete", $start[0][0] + 215, 145, 150, 20, 0x0800)

$aProfileIDs[7] = GUICtrlCreateButton("New Profile...", $start[0][0] + 35, 185, 150, 20)
GUICtrlCreateLabel("Show if Active:", $start[0][0] + 235, 188, 75, 20)
$aProfileIDs[8] = GUICtrlCreateCheckbox("", $start[0][0] + 320, 185, 20, 20)
;----- PROFILES -----

Dim $start[1][2] = [[412, 175]]
_GUICtrlCreateGroupEx("Assign Buttons", $start[0][0], $start[0][1], 315, 40, 0xA9A9A9)
$aButtonIDs[0] = GUICtrlCreateButton("i", $start[0][0] + 300, $start[0][1] + 4, $InfoWidth, $InfoHeight)
_GUICtrlButton_SetState($aButtonIDs[0], False)
$aButtonIDs[1] = GUICtrlCreateCombo("Choose Your Device...", $start[0][0] + 5, $start[0][1] + 15, 290, 10, $CBS_DROPDOWNLIST)
$controlcontent = ""
For $i = 0 To UBound($aDeviceButtons) - 1
	$controlcontent &= $aDeviceButtons[$i][0] & "|"
Next
$controlcontent = StringTrimRight($controlcontent, 1)
GUICtrlSetData($aButtonIDs[1], $controlcontent, "")

Dim $start[1][2] = [[412, 8]]
_GUICtrlCreateGroupEx("Assign Axes ", $start[0][0], $start[0][1], 315, 142, 0xA9A9A9)
$aAxesIDs[0] = GUICtrlCreateButton("i", $start[0][0] + 300, $start[0][1] + 4, $InfoWidth, $InfoHeight)
$aMarqueeAxs = _GUICtrlMarquee_Init()
_GUICtrlMarquee_SetScroll($aMarqueeAxs, -1, "slide", "left", 10000, 10)
_GUICtrlMarquee_SetDisplay($aMarqueeAxs, 0, "green", -1, 8.5, "Arial")
_GUICtrlMarquee_Create($aMarqueeAxs, "none", $start[0][0] + 60, $start[0][1] + 15, 235, 16)
_GUICtrlButton_SetState($aAxesIDs[0], False)
GUICtrlCreateLabel("Conflicts:", $start[0][0] + 5, $start[0][1] + 15, 42, 15)
GUICtrlCreateLabel("3DC Axis", $start[0][0] + 5, $start[0][1] + 45, 50, 15)
;GUICtrlCreateLabel("controls", $start[0][0] + 8, $start[0][1] + 65, 120, 15)
GUICtrlCreateLabel("vJoy Axis", $start[0][0] + 5, $start[0][1] + 89, 50, 15)
$xcorr = 0
Dim $aAxes[0]
$axes = IniRead(@ScriptDir & "\config.ini", $inisection, "axes order", 0)
$axes = StringStripWS($axes, 8)
$axes = StringReplace($axes, "xR", "Rx")
$axes = StringReplace($axes, "yR", "Ry")
$axes = StringReplace($axes, "zR", "Rz")
$aAxes = StringSplit($axes, ",", 2)
$found = 0
For $i = 0 To UBound($aAxes) - 1
	If $aAxes[$i] == "x" Then
		$found += 1
		ContinueLoop
	EndIf
	If $aAxes[$i] == "y" Then
		$found += 1
		ContinueLoop
	EndIf
	If $aAxes[$i] == "z" Then
		$found += 1
		ContinueLoop
	EndIf
	If $aAxes[$i] == "Rx" Then
		$found += 1
		ContinueLoop
	EndIf
	If $aAxes[$i] == "Ry" Then
		$found += 1
		ContinueLoop
	EndIf
	If $aAxes[$i] == "Rz" Then
		$found += 1
		ContinueLoop
	EndIf
Next
If $found <> 6 Then Dim $aAxes[6] = ["x", "y", "z", "Rx", "Ry", "Rz"]
Dim $aAxesLabelIDs[6]
For $i = 0 To 5
	ReDim $aAxesIDs[UBound($aAxesIDs) + 1]
	If $i > 2 Then $xcorr = -3
	$aAxesLabelIDs[$i] = GUICtrlCreateLabel($aLabelsvJ[$i], $i * 40 + $start[0][0] + 75 + $xcorr, $start[0][1] + 45, 15, 15)
	GUICtrlCreateLabel("¯", $i * 40 + $start[0][0] + 75, $start[0][1] + 65, 15, 15)
	GUICtrlSetFont(-1, 9, 400, "", "Symbol", 4)
	$aAxesIDs[$i + 1] = GUICtrlCreateCombo("", $i * 40 + $start[0][0] + 60, $start[0][1] + 85, 37, 10, $CBS_DROPDOWNLIST)
	GUICtrlSetData(-1, "x|y|z|Rx|Ry|Rz", $aAxes[$i])
Next
$swapaxesID = GUICtrlCreateCheckbox("swap translational && rotational axes labels", $start[0][0] + 50, $start[0][1] + 120, 215, 15)

Dim $gridPos[1][2] = [[0, 0]]
_GUICtrlCreateGroupEx("Output ", $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y, 280, 180, 0xA9A9A9)

$spacefromborder_x += 10
$spacefromborder_y += 20
Dim $gridPos[1][2] = [[0, 0]]
GUICtrlCreateGroup("Deadzone", $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y, $width, $height)
$aDeadzoneIDs[0][0] = GUICtrlCreateButton("i", $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x + $InfoOffset_X, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y + $InfoOffset_Y, $InfoWidth, $InfoHeight)
_GUICtrlButton_SetState($aDeadzoneIDs[0][0], False)
For $i = 0 To 5
	ReDim $aDeadzoneIDs[UBound($aDeadzoneIDs) + 1][4]
	ReDim $aHandlesIDsLUT[UBound($aHandlesIDsLUT) + 1][3]
	GUICtrlCreateLabel($aLabels[$i], $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x + $PreLabelOffset_X, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y + $PreLabelOffset_Y + ($i * $PreLabelSpaceBetween), 15, 15)
	GUICtrlCreateLabel("%", 0 * ($spacebetween_x + $width) + $spacefromborder_x + $PostLabelOffset_X + 75, 0 * ($spacebetween_y + $height) + $spacefromborder_y + $PostLabelOffset_Y + ($i * $PostLabelSpaceBetween), 15, 15)
	$aDeadzoneIDs[$i + 1][0] = GUICtrlCreateInput("0", $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x + $InputOffset_X, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y + $InputOffset_Y + ($i * $InputSpaceBetween), 40, 19)
	$aDeadzoneIDs[$i + 1][1] = GUICtrlCreateInput("0", $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x + $InputOffset_X + 48, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y + $InputOffset_Y + ($i * $InputSpaceBetween), 10, 19)
	$aDeadzoneIDs[$i + 1][2] = GUICtrlCreateUpdown($aDeadzoneIDs[$i + 1][1])
	$aDeadzoneIDs[$i + 1][3] = 0
	$aHandlesIDsLUT[UBound($aHandlesIDsLUT) - 1][0] = $aDeadzoneIDs[$i + 1][0]
	$aHandlesIDsLUT[UBound($aHandlesIDsLUT) - 1][1] = "deadzone"
Next

Dim $gridPos[1][2] = [[1, 0]]
GUICtrlCreateGroup("Invert", $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y, $width, $height)
$aInvertIDs[0][0] = GUICtrlCreateButton("i", $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x + $InfoOffset_X, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y + $InfoOffset_Y, $InfoWidth, $InfoHeight)
_GUICtrlButton_SetState($aInvertIDs[0][0], False)
For $i = 0 To 5
	ReDim $aInvertIDs[UBound($aInvertIDs) + 1][2]
	GUICtrlCreateLabel($aLabels[$i], $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x + $PreLabelOffset_X, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y + $PreLabelOffset_Y + ($i * $PreLabelSpaceBetween), 15, 15)
	GUICtrlCreateLabel("Toggle", $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x + $PostLabelOffset_X + 40, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y + $PostLabelOffset_Y + ($i * $PostLabelSpaceBetween), 45, 15)
	$aInvertIDs[$i + 1][0] = GUICtrlCreateCheckbox("", $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x + $CheckboxOffset_X + 5, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y + $CheckboxOffset_Y + ($i * $InputSpaceBetween), 15, 15)
Next



$spacefromborder_x += 25
$spacefromborder_y -= 20
Dim $gridPos[1][2] = [[2, 0]]
_GUICtrlCreateGroupEx("Throttle ", $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y, 415, 180, 0xA9A9A9)
$spacefromborder_x += 10
$spacefromborder_y += 20

Dim $gridPos[1][2] = [[2, 0]]
GUICtrlCreateGroup("Convert Axis", $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y, $width, $height)
$aIsThrottleIDs[0][0] = GUICtrlCreateButton("i", $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x + $InfoOffset_X, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y + $InfoOffset_Y, $InfoWidth, $InfoHeight)
_GUICtrlButton_SetState($aIsThrottleIDs[0][0], False)
For $i = 0 To 5
	ReDim $aIsThrottleIDs[UBound($aIsThrottleIDs) + 1][2]
	GUICtrlCreateLabel($aLabels[$i], $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x + $PreLabelOffset_X, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y + $PreLabelOffset_Y + ($i * $PreLabelSpaceBetween), 15, 15)
	$aIsThrottleIDs[$i + 1][0] = GUICtrlCreateCombo("", $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x + $CheckboxOffset_X + 0, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y + $CheckboxOffset_Y + ($i * $InputSpaceBetween) - 3, 93, 15, $CBS_DROPDOWNLIST)
	GUICtrlSetData($aIsThrottleIDs[$i + 1][0], "no (off)|3DC controller|mousewheel", $aIsThrottleIDs[$i + 1][0])
	_GUICtrlComboBox_SetCurSel($aIsThrottleIDs[$i + 1][0], 0)
Next

Dim $gridPos[1][2] = [[3, 0]]
GUICtrlCreateGroup("Increments (%)", $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y, $width, $height)
$aThrottleStepsIDs[0][0] = GUICtrlCreateButton("i", $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x + $InfoOffset_X, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y + $InfoOffset_Y, $InfoWidth, $InfoHeight)
_GUICtrlButton_SetState($aThrottleStepsIDs[0][0], False)
$incs = ""
For $i = 1 To 25
	$incs &= $i & "|"
Next
For $i = 0 To 5
	ReDim $aThrottleStepsIDs[UBound($aThrottleStepsIDs) + 1][2]
	GUICtrlCreateLabel($aLabels[$i], $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x + $PreLabelOffset_X, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y + $PreLabelOffset_Y + ($i * $PreLabelSpaceBetween), 15, 15)
	$aThrottleStepsIDs[$i + 1][0] = GUICtrlCreateCombo("", $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x + $CheckboxOffset_X + 0, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y + $CheckboxOffset_Y + ($i * $InputSpaceBetween) - 3, 93, 15, BitOR($CBS_DROPDOWNLIST, $GUI_SS_DEFAULT_COMBO))
	GUICtrlSetData($aThrottleStepsIDs[$i + 1][0], $incs, $aThrottleStepsIDs[$i + 1][0])
	_GUICtrlComboBox_SetCurSel($aThrottleStepsIDs[$i + 1][0], 4)
Next

Dim $gridPos[1][2] = [[4, 0]]
GUICtrlCreateGroup("Zero Throttle at %", $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y, $width, $height)
$aThrottleZeroIDs[0][0] = GUICtrlCreateButton("i", $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x + $InfoOffset_X, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y + $InfoOffset_Y, $InfoWidth, $InfoHeight)
_GUICtrlButton_SetState($aThrottleZeroIDs[0][0], False)
$zeropos = ""
For $i = 1 To 100
	$zeropos &= $i & "|"
Next
For $i = 0 To 5
	ReDim $aThrottleZeroIDs[UBound($aThrottleZeroIDs) + 1][2]
	GUICtrlCreateLabel($aLabels[$i], $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x + $PreLabelOffset_X, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y + $PreLabelOffset_Y + ($i * $PreLabelSpaceBetween), 15, 15)
	$aThrottleZeroIDs[$i + 1][0] = GUICtrlCreateCombo("", $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x + $CheckboxOffset_X + 0, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y + $CheckboxOffset_Y + ($i * $InputSpaceBetween) - 3, 93, 15, BitOR($CBS_DROPDOWNLIST, $GUI_SS_DEFAULT_COMBO))
	GUICtrlSetData($aThrottleZeroIDs[$i + 1][0], $zeropos, $aThrottleZeroIDs[$i + 1][0])
	_GUICtrlComboBox_SetCurSel($aThrottleZeroIDs[$i + 1][0], 49)
Next


Dim $start[1][2] = [[0, 365]]
$spacefromborder_x = 8
$spacefromborder_y = 125

Dim $gridPos[1][2] = [[0, 2]]
_GUICtrlCreateGroupEx("Output Acceleration", $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y, 720, 305, 0xA9A9A9)

$spacefromborder_x -= 125
$spacefromborder_y += 20
Dim $gridPos[1][2] = [[1, 2]]
GUICtrlCreateGroup("Pitch / Sensitivity", $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y, $width, $height)
$aLinSensIDs[0][0] = GUICtrlCreateButton("i", $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x + $InfoOffset_X, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y + $InfoOffset_Y, $InfoWidth, $InfoHeight)
_GUICtrlButton_SetState($aLinSensIDs[0][0], False)
For $i = 0 To 5
	ReDim $aLinSensIDs[UBound($aLinSensIDs) + 1][5]
	ReDim $aHandlesIDsLUT[UBound($aHandlesIDsLUT) + 1][3]
	GUICtrlCreateLabel($aLabels[$i], $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x + $PreLabelOffset_X, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y + $PreLabelOffset_Y + ($i * $PreLabelSpaceBetween), 15, 15)
	GUICtrlCreateLabel("Divider", $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x + $PostLabelOffset_Y + 58, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y + $PostLabelOffset_Y + ($i * $PostLabelSpaceBetween), 45, 15)
	$aLinSensIDs[$i + 1][0] = GUICtrlCreateInput(StringFormat("%#.3f", 0), $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x + $InputOffset_X, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y + $InputOffset_Y + ($i * $InputSpaceBetween), 40, 19)
	$aLinSensIDs[$i + 1][1] = GUICtrlCreateInput("0", $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x + $InputOffset_X + 48, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y + $InputOffset_Y + ($i * $InputSpaceBetween), 10, 19)
	$aLinSensIDs[$i + 1][2] = GUICtrlCreateUpdown($aLinSensIDs[$i + 1][1])
	$aLinSensIDs[$i + 1][3] = 0
	$aLinSensIDs[$i + 1][4] = 0
	$aHandlesIDsLUT[UBound($aHandlesIDsLUT) - 1][0] = $aLinSensIDs[$i + 1][0]
	$aHandlesIDsLUT[UBound($aHandlesIDsLUT) - 1][1] = "linsens"
Next

Dim $gridPos[1][2] = [[2, 2]]
GUICtrlCreateGroup("Curvature", $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y, $width, $height)
$aLogSensIDs[0][0] = GUICtrlCreateButton("i", $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x + $InfoOffset_X, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y + $InfoOffset_Y, $InfoWidth, $InfoHeight)
_GUICtrlButton_SetState($aLogSensIDs[0][0], False)
For $i = 0 To 5
	ReDim $aLogSensIDs[UBound($aLogSensIDs) + 1][4]
	ReDim $aHandlesIDsLUT[UBound($aHandlesIDsLUT) + 1][3]
	GUICtrlCreateLabel($aLabels[$i], $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x + $PreLabelOffset_X, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y + $PreLabelOffset_Y + ($i * $PreLabelSpaceBetween), 15, 15)
	GUICtrlCreateLabel("%", $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x + $PostLabelOffset_X + 75, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y + $PostLabelOffset_Y + ($i * $PostLabelSpaceBetween), 45, 15)
	$aLogSensIDs[$i + 1][0] = GUICtrlCreateInput("0", $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x + $InputOffset_X, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y + $InputOffset_Y + ($i * $InputSpaceBetween), 40, 19)
	$aLogSensIDs[$i + 1][1] = GUICtrlCreateInput("0", $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x + $InputOffset_X + 48, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y + $InputOffset_Y + ($i * $InputSpaceBetween), 10, 19)
	$aLogSensIDs[$i + 1][2] = GUICtrlCreateUpdown($aLogSensIDs[$i + 1][1])
	$aLogSensIDs[$i + 1][3] = 0
	$aHandlesIDsLUT[UBound($aHandlesIDsLUT) - 1][0] = $aLogSensIDs[$i + 1][0]
	$aHandlesIDsLUT[UBound($aHandlesIDsLUT) - 1][1] = "logsens"
Next

Dim $gridPos[1][2] = [[3, 2]]
GUICtrlCreateGroup("Exponent", $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y, $width, $height)
$aExponentIDs[0][0] = GUICtrlCreateButton("i", $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x + $InfoOffset_X, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y + $InfoOffset_Y, $InfoWidth, $InfoHeight)
_GUICtrlButton_SetState($aExponentIDs[0][0], False)
For $i = 0 To 5
	ReDim $aExponentIDs[UBound($aExponentIDs) + 1][4]
	ReDim $aHandlesIDsLUT[UBound($aHandlesIDsLUT) + 1][3]
	GUICtrlCreateLabel($aLabels[$i], $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x + $PreLabelOffset_X, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y + $PreLabelOffset_Y + ($i * $PreLabelSpaceBetween), 15, 15)
	GUICtrlCreateLabel("Odd Integer", $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x + $PostLabelOffset_X + 60, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y + $PostLabelOffset_Y + ($i * $PostLabelSpaceBetween), 60, 15)
	$aExponentIDs[$i + 1][0] = GUICtrlCreateInput("0", $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x + $InputOffset_X, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y + $InputOffset_Y + ($i * $InputSpaceBetween), 25, 19)
	$aExponentIDs[$i + 1][1] = GUICtrlCreateInput("0", $gridPos[0][0] * ($spacebetween_x + $width) + $spacefromborder_x + $InputOffset_X + 33, $gridPos[0][1] * ($spacebetween_y + $height) + $spacefromborder_y + $InputOffset_Y + ($i * $InputSpaceBetween), 10, 19)
	$aExponentIDs[$i + 1][2] = GUICtrlCreateUpdown($aExponentIDs[$i + 1][1])
	$aExponentIDs[$i + 1][3] = 0
	$aHandlesIDsLUT[UBound($aHandlesIDsLUT) - 1][0] = $aExponentIDs[$i + 1][0]
	$aHandlesIDsLUT[UBound($aHandlesIDsLUT) - 1][1] = "exponent"
Next

Dim $start[1][2] = [[18, 630]]

GUICtrlCreateGroup("Graph", $start[0][0], $start[0][1], 400, 115)
$aAxisRadio[0] = GUICtrlCreateButton("i", $start[0][0] + 383, $start[0][1] + 9, $InfoWidth, $InfoHeight)

$start[0][0] += 130
$start[0][1] += 35
GUICtrlCreateLabel("Display(ing) Graph for Axis", $start[0][0], $start[0][1], 200, 20)

$start[0][0] -= 40
$start[0][1] += 20
GUIStartGroup()
For $i = 1 To 6
	$aAxisRadio[$i] = GUICtrlCreateRadio(" ", $start[0][0] + (($i - 1) * 40), $start[0][1], 13, 15)
	$start_x = $start[0][0]
	If StringLen($aLabelsvJ[$i - 1]) = 1 Then $start_x += 3
	GUICtrlCreateLabel($aLabelsvJ[$i - 1], $start_x + (($i - 1) * 40), $start[0][1] + 20, 20, 20)
Next
GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group (wtf?!)

For $i = 0 To UBound($aHandlesIDsLUT) - 1
	$aHandlesIDsLUT[$i][2] = GetClassNameNN_FromControlID($Form1, "", $aHandlesIDsLUT[$i][0])
Next

Global $graph_x = 430
Global $graph_y = 455

GUISetState(@SW_SHOW)

$hGraphics = _GDIPlus_GraphicsCreateFromHWND($Form1)
$hBitmap = _GDIPlus_BitmapCreateFromGraphics(290, 290, $hGraphics)
$hBackbuffer = _GDIPlus_ImageGetGraphicsContext($hBitmap)
_GDIPlus_GraphicsSetSmoothingMode($hBackbuffer, 2)
_GDIPlus_GraphicsClear($hBackbuffer, 0xFFFFFFFF)
$hPen1 = _GDIPlus_PenCreate(0xFFD3D3D3, 1)
$hPen2 = _GDIPlus_PenCreate(0xFF00D000, 1)

_PrepFrame()

OnAutoItExitRegister("_CleanExit")

_readconfig()

While 1
	Sleep(10)
	$focusID = ""
	$category = ""

	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $aProfileIDs[0]
			_infobox("profiles")
		Case $aDeadzoneIDs[0][0]
			_infobox("deadzone")
		Case $aLinSensIDs[0][0]
			_infobox("linsens")
		Case $aLogSensIDs[0][0]
			_infobox("logsens")
		Case $aIsThrottleIDs[0][0]
			_infobox("converttothrottle")
		Case $aThrottleStepsIDs[0][0]
			_infobox("throttlesteps")
		Case $aThrottleZeroIDs[0][0]
			_infobox("throttlezero")
		Case $aExponentIDs[0][0]
			_infobox("exponent")
		Case $aInvertIDs[0][0]
			_infobox("invert")
		Case $aAxesIDs[0]
			_infobox("assign")
		Case $aButtonIDs[0]
			_infobox("devsel")
		Case $aButtonIDs[1]
			If Not StringInStr(StringLower(GUICtrlRead($aButtonIDs[1])), "choose your device") Then
				$index = _ArraySearch($aDeviceButtons, GUICtrlRead($aButtonIDs[1]), 0, 0, 0, 2, 1, -1)
				_buttonGUI(GUICtrlRead($aButtonIDs[1]), $aDeviceButtons[$index][2], $aDeviceButtons[$index][3], GUICtrlRead($aProfileIDs[1]))
			EndIf

		Case $aProfileIDs[1]
			_readconfig()
			_actProfile()

		Case $aProfileIDs[2]
			_delProfile()
			_readconfig()
			_actProfile()

		Case $aProfileIDs[3]
			If GUICtrlRead($aProfileIDs[3]) = "for specific application" And Not (StringLen(GUICtrlRead($aProfileIDs[5])) > 0) Then
				$chooseApp = _chooseApp()
				If Not ($chooseApp = -1) Then GUICtrlSetData($aProfileIDs[5], $chooseApp)
			EndIf
			_actProfile()

		Case $aProfileIDs[4]
			_renProfile(GUICtrlRead($aProfileIDs[1]))

		Case $aProfileIDs[6]
			If GUICtrlRead($aProfileIDs[5]) = "" Then
				$chooseApp = _chooseApp()
				If Not ($chooseApp = -1) Then
					GUICtrlSetData($aProfileIDs[5], $chooseApp)
					_GUICtrlComboBox_SetCurSel($aProfileIDs[3], _GUICtrlComboBox_FindStringExact($aProfileIDs[3], "Off"))
				EndIf
			Else
				GUICtrlSetData($aProfileIDs[5], "")
				If Not (IniRead(@ScriptDir & "\config.ini", GUICtrlRead($aProfileIDs[1]), "executable", -1) = -1) Then IniWrite(@ScriptDir & "\config.ini", GUICtrlRead($aProfileIDs[1]), "executable", "")
				If Not (IniRead(@ScriptDir & "\config.ini", GUICtrlRead($aProfileIDs[1]), "force", -1) = -1) Then IniWrite(@ScriptDir & "\config.ini", GUICtrlRead($aProfileIDs[1]), "force", "")
			EndIf
			_actProfile()

		Case $aProfileIDs[7]
			If Not (_newProfile() = -1) Then
				_readconfig(1)
			EndIf
			_actProfile()

		Case $aProfileIDs[8]
			_showifactive()

		Case $aAxisRadio[0]
			_infobox("graph")
	EndSwitch

	_focusID($focusID, $category)
	For $i = 1 To 6
		Switch $nMsg
			Case $aDeadzoneIDs[$i][2]
				_deadzoneHandler("mouse")
			Case $aLinSensIDs[$i][2]
				_linsensHandler("mouse", $i)
				_DrawFrame(Number(GUICtrlRead($aLogSensIDs[$i][0])), Number(GUICtrlRead($aExponentIDs[$i][0])), GUICtrlRead($aLinSensIDs[$i][0]), $i)
			Case $aLogSensIDs[$i][2]
				_curvatureHandler("mouse", $i)
			Case $aExponentIDs[$i][2]
				_exponentHandler("mouse", $i)
			Case $aIsThrottleIDs[$i][0]
				_isThrottleHandler($i)
			Case $aThrottleStepsIDs[$i][0]
				_ThrottleSteps($i)
			Case $aThrottleZeroIDs[$i][0]
				_ThrottleZero($i)
			Case $aInvertIDs[$i][0]
				_invertHandler($i)
			Case $aAxesIDs[$i]
				_axesHandler()
			Case $aAxisRadio[$i]
				_DrawFrame(Number(GUICtrlRead($aLogSensIDs[$i][0])), Number(GUICtrlRead($aExponentIDs[$i][0])), GUICtrlRead($aLinSensIDs[$i][0]), $i)
		EndSwitch

		Switch $focusID
			Case $aDeadzoneIDs[$i][0]
				_deadzoneHandler("keyboard")
			Case $aLinSensIDs[$i][0]
				_linsensHandler("keyboard", $i)
				_DrawFrame(Number(GUICtrlRead($aLogSensIDs[$i][0])), Number(GUICtrlRead($aExponentIDs[$i][0])), GUICtrlRead($aLinSensIDs[$i][0]), $i)
			Case $aLogSensIDs[$i][0]
				_curvatureHandler("keyboard", $i)
				_DrawFrame(Number(GUICtrlRead($aLogSensIDs[$i][0])), Number(GUICtrlRead($aExponentIDs[$i][0])), GUICtrlRead($aLinSensIDs[$i][0]), $i)
			Case $aExponentIDs[$i][0]
				_exponentHandler("keyboard", $i)
				_DrawFrame(Number(GUICtrlRead($aLogSensIDs[$i][0])), Number(GUICtrlRead($aExponentIDs[$i][0])), GUICtrlRead($aLinSensIDs[$i][0]), $i)
		EndSwitch
	Next
WEnd

Func _actProfile()
	Local $ActivationMethod = StringLower(GUICtrlRead($aProfileIDs[3])), $Profile = GUICtrlRead($aProfileIDs[1]), $Application = GUICtrlRead($aProfileIDs[5]), $aProfiles, $search

	If $ActivationMethod = "as (last) set in GUI" Then
		If Not (IniRead(@ScriptDir & "\config.ini", "general", "forcemode", -1) = 1) Then IniWrite(@ScriptDir & "\config.ini", "general", "forcemode", " " & 1)
		If Not (IniRead(@ScriptDir & "\config.ini", "general", "last GUI profile", -1) = $Profile) Then IniWrite(@ScriptDir & "\config.ini", "general", "last GUI profile", " " & $Profile)
	Else
		If Not (IniRead(@ScriptDir & "\config.ini", "general", "forcemode", -1) = 0) Then IniWrite(@ScriptDir & "\config.ini", "general", "forcemode", " " & 0)
		If Not (IniRead(@ScriptDir & "\config.ini", "general", "last GUI profile", -1) = -1) Then IniWrite(@ScriptDir & "\config.ini", "general", "last GUI profile", "")
	EndIf

	If $ActivationMethod = "for specific application" Then
		If Not (IniRead(@ScriptDir & "\config.ini", $Profile, "force", -1) = 2) Then IniWrite(@ScriptDir & "\config.ini", $Profile, "force", " " & 2)
		If Not (IniRead(@ScriptDir & "\config.ini", $Profile, "last GUI profile", -1) = $Application) Then IniWrite(@ScriptDir & "\config.ini", $Profile, "executable", " " & $Application)
	EndIf

	If $ActivationMethod = "always active" Then
		$aProfiles = IniReadSectionNames(@ScriptDir & "\config.ini")
		$search = _ArraySearch($aProfiles, "general", 1, 0, 0, 2)
		_ArrayDelete($aProfiles, $search)
		$aProfiles[0] = UBound($aProfiles) - 1
		For $i = 1 To $aProfiles[0]
			If Not (IniRead(@ScriptDir & "\config.ini", $aProfiles[$i], "force", -1) = 0) Then IniWrite(@ScriptDir & "\config.ini", $aProfiles[$i], "force", " " & 0)
		Next
		If Not (IniRead(@ScriptDir & "\config.ini", $Profile, "force", -1) = 1) Then IniWrite(@ScriptDir & "\config.ini", $Profile, "force", " " & 1)
	EndIf

	If $ActivationMethod = "off" Then
		If Not (IniRead(@ScriptDir & "\config.ini", $Profile, "force", -1) = 0) Then IniWrite(@ScriptDir & "\config.ini", $Profile, "force", " " & 0)
	EndIf

	If $ActivationMethod = "none (default profile)" Then
		$aProfiles = IniReadSectionNames(@ScriptDir & "\config.ini")
		$search = _ArraySearch($aProfiles, "general", 1, 0, 0, 2)
		_ArrayDelete($aProfiles, $search)
		$aProfiles[0] = UBound($aProfiles) - 1
		For $i = 1 To $aProfiles[0]
			If Not (IniRead(@ScriptDir & "\config.ini", $aProfiles[$i], "force", -1) = 0) Then IniWrite(@ScriptDir & "\config.ini", $aProfiles[$i], "force", " " & 0)
		Next
		If Not (IniRead(@ScriptDir & "\config.ini", "default", "force", -1) = 1) Then IniWrite(@ScriptDir & "\config.ini", "default", "force", " " & 1)
	EndIf
EndFunc   ;==>_actProfile

Func _showifactive()
	Local $state = GUICtrlRead($aProfileIDs[8])
	If $state = 1 Then IniWrite(@ScriptDir & "\config.ini", "general", "show if active", " " & 1)
	If $state = 4 Then IniWrite(@ScriptDir & "\config.ini", "general", "show if active", " " & 0)
EndFunc   ;==>_showifactive

Func _chooseApp()
	Local $exists = 1, $profilenametemp

	Local $profilename = FileOpenDialog("Choose Executable Of The Process To Monitor", "", "Executables (*.exe)", 1)
	If $profilename = "" Then
		MsgBox(48, "Info", 'Nothing selected.')
		Return -1
	EndIf
	$aExename = StringSplit($profilename, "\")
	If Not IsArray($aExename) Then Return -1
	If Not (IniRead(@ScriptDir & "\config.ini", GUICtrlRead($aProfileIDs[1]), "executable", -1) = $aExename[$aExename[0]]) Then IniWrite(@ScriptDir & "\config.ini", GUICtrlRead($aProfileIDs[1]), "executable", " " & $aExename[$aExename[0]])
	Return $aExename[$aExename[0]]
EndFunc   ;==>_chooseApp

Func _renProfile($oldprofile)
	Local $profilename = InputBox("Sx2vJoy", "Enter a new name for this Profile"), $exists = 1

	Local $aTempProfiles = IniReadSectionNames(@ScriptDir & "\config.ini")
	$profilenametemp = $profilename
	While 1
		$search = _ArraySearch($aTempProfiles, $profilenametemp, 1, 0, 0, 2)
		If ($search <> -1) Then
			$exists += 1
			$profilenametemp = $profilename & " " & $exists
		Else
			ExitLoop
		EndIf
	WEnd

	$aArray = StringRegExp(FileRead(@ScriptDir & '\config.ini'), '(?s)(?i)\[' & $oldprofile & ']\s*(.*?)\s*(\n\[|$)', 3)
	$split = StringSplit($aArray[0], @LF)
	Local $newsection = @CRLF & @CRLF & "[" & $profilename & "]" & @CRLF
	For $i = 1 To $split[0]
		$newsection &= $split[$i] & @LF
	Next
	IniDelete(@ScriptDir & "\config.ini", $oldprofile)
	$hFile = FileOpen(@ScriptDir & "\config.ini", 1)
	FileWrite($hFile, $newsection)
	FileClose($hFile)

	$profilename = $profilenametemp
	_GUICtrlComboBox_DeleteString($aProfileIDs[1], _GUICtrlComboBox_FindStringExact($aProfileIDs[1], $oldprofile))
	_GUICtrlComboBox_InsertString($aProfileIDs[1], $profilename, 1)
	_GUICtrlComboBox_SetCurSel($aProfileIDs[1], _GUICtrlComboBox_FindStringExact($aProfileIDs[1], $profilename))
	_cleanup()
EndFunc   ;==>_renProfile

Func _newProfile()
	;Local $split = StringSplit($profilename, "\")
	Local $profilename = InputBox("Sx2vJoy", "Enter a Name for the Profile"), $exists = 1

	If StringStripWS($profilename, 8) = "" Then
		MsgBox(64, "Sx2vJoy", "You need to enter a profile name to create a new profile.")
		Return -1
	EndIf

	Local $aTempProfiles = IniReadSectionNames(@ScriptDir & "\config.ini")
	$profilenametemp = $profilename
	While 1
		$search = _ArraySearch($aTempProfiles, $profilenametemp, 1, 0, 0, 2)
		If ($search <> -1) Then
			$exists += 1
			$profilenametemp = $profilename & " " & $exists
		Else
			ExitLoop
		EndIf
	WEnd
	$profilename = $profilenametemp

	$aArray = StringRegExp(FileRead(@ScriptDir & '\config.ini'), '(?s)(?i)\[' & "default" & ']\s*(.*?)\s*(\n\[|$)', 3)
	$split = StringSplit($aArray[0], @LF)
	_ArrayInsert($split, 1, "executable = " & @CR, 0)
	;_ArrayInsert($split, 2, "force = ", 0)
	$defaultsection = @CRLF & @CRLF & "[" & $profilename & "]" & @CRLF
	For $i = 1 To $split[0]
		$defaultsection &= $split[$i] & @LF
	Next
	$hFile = FileOpen(@ScriptDir & "\config.ini", 1)
	FileWrite($hFile, $defaultsection)
	FileClose($hFile)

	_GUICtrlComboBox_InsertString($aProfileIDs[1], $profilename, 1)
	_GUICtrlComboBox_SetCurSel($aProfileIDs[1], _GUICtrlComboBox_FindStringExact($aProfileIDs[1], $profilename))
	_cleanup()
EndFunc   ;==>_newProfile

Func _delProfile()
	$profilename = GUICtrlRead($aProfileIDs[1])
	If $profilename = "default" Then
		MsgBox(48, "Delete Profile", "You cannot delete the default profile.")
		Return
	EndIf

	$return = MsgBox(52, "Delete Profile", "Do you really want to delete the profile named" & @CRLF & @CRLF & $profilename)
	If $return = 6 Then
		IniDelete(@ScriptDir & "\config.ini", $profilename)
	EndIf
	$index = _GUICtrlComboBox_FindStringExact($aProfileIDs[1], $profilename)
	_GUICtrlComboBox_DeleteString($aProfileIDs[1], $index)
	_GUICtrlComboBox_SetCurSel($aProfileIDs[1], 0)
	_cleanup()
EndFunc   ;==>_delProfile

Func _buttonGUI($sDeviceName, $sButtonIDs, $sButtonNames, $Profile)
	Local $aButtonIDsTmp = StringSplit($sButtonIDs, ",")
	Local $aButtonNamesTmp = StringSplit($sButtonNames, ",")
	Local $aButtonIDs[$aButtonIDsTmp[0] + 1][7]
	$aButtonIDs[0][0] = $aButtonIDsTmp[0]
	Local $aButtonResult[$aButtonIDsTmp[0] + 1][4]
	$aButtonResult[0][0] = $aButtonIDsTmp[0]
	Local $return

	Local $winheight = $aButtonIDs[0][0] * 25

	Local $btngui = GUICreate("Sx2vJoy " & $version & " " & $sDeviceName & " Button Configurator", 695, $winheight + 15, -1, -1, -1, -1, $Form1)

	Local $x_space_border = 5
	Local $y_space_border = 20
	Local $x_space_between = 10
	Local $y_space_between = 10

	Local $btncfg = GUICtrlCreateButton("i", 680 - 15, 2, 13, 14)

	Local $height = 25

	Local $vjoyfill = ""
	For $i = 1 To 128
		$vjoyfill &= $i & "|"
	Next

	Local $idfill = ""
	For $i = 1 To $aButtonIDsTmp[0]
		$idfill &= $aButtonIDsTmp[$i] & "|"
	Next

	For $i2 = 1 To $aButtonIDs[0][0]
		$h = $height * ($i2 - 1)

		Local $width = $x_space_border
		GUICtrlCreateLabel($i2 & ":", $width, $h + $y_space_border, 15, 15)

		$width += 20
		GUICtrlCreateLabel("use 3DC button", $width, $h + $y_space_border, 74, 15)

		$width += 80
		$aButtonIDs[$i2][0] = GUICtrlCreateInput($aButtonNamesTmp[$i2], $width + ($x_space_between * 1), $h + $y_space_border - 3, 65, 20, 0x0800)

		$width += 65
		GUICtrlCreateLabel("to push", $width + ($x_space_between * 2), $h + $y_space_border, 45, 15)

		$width += 40
		$aButtonIDs[$i2][1] = GUICtrlCreateCombo("", $width + ($x_space_between * 3), $h + $y_space_border - 3, 70, 15, 0x0003)
		GUICtrlSetData(-1, "keyboard|vJoy")

		$width += 75
		GUICtrlCreateLabel("button(s)", $width + ($x_space_between * 4), $h + $y_space_border, 45, 15)

		$width += 45
		$aButtonIDs[$i2][2] = GUICtrlCreateCombo("", $width + ($x_space_between * 5), $h + $y_space_border - 3, 255, 15, BitOR($CBS_DROPDOWNLIST, $WS_VSCROLL))
		ControlDisable($btngui, "", $aButtonIDs[$i2][2])

		$width += 200
		$aButtonIDs[$i2][3] = GUICtrlCreateButton("Clear", 55 + $width + ($x_space_between * 6), $h + $y_space_border - 2, 40, 18)

		$aButtonIDs[$i2][4] = $aButtonIDsTmp[$i2]
	Next

	Local $aIni[1] = [0]
	Local $btntmp = ""
	Local $end
	For $i = 1 To $aButtonIDsTmp[0]
		ReDim $aIni[UBound($aIni) + 1]
		Local $tmp = IniRead(@ScriptDir & "\config.ini", $Profile, $sDeviceName & " ID" & $aButtonIDsTmp[$i], "")
		If Not (StringLeft($tmp, 1) = "j") And Not (StringLeft($tmp, 1) = "k") Then ContinueLoop
		Local $splt = StringSplit($tmp, ",")
		If IsArray($splt) Then
			ControlEnable($btngui, "", $aButtonIDs[$i][2])

			If $splt[1] = "j" Then
				$end = $splt[0]
				$btntmp = ""
				For $i2 = 2 To $end
					$test = $splt[$i2]
					$btntmp &= $splt[$i2]
				Next
				_GUICtrlComboBox_SetCurSel($aButtonIDs[$i][1], 1)
				GUICtrlSetData($aButtonIDs[$i][2], $vjoyfill)
				_GUICtrlComboBox_SetCurSel($aButtonIDs[$i][2], _GUICtrlComboBox_FindStringExact($aButtonIDs[$i][2], $btntmp))
			EndIf

			If $splt[1] = "k" Then
				$end = $splt[0]
				$btntmp = ""
				For $i2 = 2 To $end
					$test = $splt[$i2]
					$btntmp &= "<" & $splt[$i2] & ">"
				Next
				_GUICtrlComboBox_SetCurSel($aButtonIDs[$i][1], 0)
				GUICtrlSetData($aButtonIDs[$i][2], "choose...")
				GUICtrlSetData($aButtonIDs[$i][2], $btntmp)
				_GUICtrlComboBox_SetCurSel($aButtonIDs[$i][2], _GUICtrlComboBox_FindStringExact($aButtonIDs[$i][2], $btntmp))
			EndIf
		EndIf
	Next

	GUISetState(@SW_SHOW, $btngui)

	While 1
		$2nMsg = GUIGetMsg()

		Switch $2nMsg
			Case $GUI_EVENT_CLOSE
				;_arraydisplay($aButtonIDs)
				For $i = 1 To $aButtonIDs[0][0]
					$fin = GUICtrlRead($aButtonIDs[$i][2])
					If StringLen($fin) > 0 Then
						$fin = StringReplace($fin, "<", "")
						$fin = StringReplace($fin, ">", ",")
						If GUICtrlRead($aButtonIDs[$i][1]) = "keyboard" Then $fin = "k," & $fin
						If GUICtrlRead($aButtonIDs[$i][1]) = "vJoy" Then $fin = "j," & $fin
						If StringRight($fin, 1) = "," Then $fin = StringTrimRight($fin, 1)
					EndIf
					IniWrite(@ScriptDir & "\config.ini", $Profile, $sDeviceName & " ID" & $aButtonIDs[$i][4], " " & $fin)
				Next
				ExitLoop
			Case $btncfg
				_infobox("btncfg")
		EndSwitch

		For $i = 1 To $aButtonIDs[0][0]
			Switch $2nMsg
				Case $aButtonIDs[$i][1]
					If StringInStr(GUICtrlRead($aButtonIDs[$i][1]), "keyboard") Then
						ControlEnable($btngui, "", $aButtonIDs[$i][2])
						_GUICtrlComboBox_ResetContent($aButtonIDs[$i][2])
						GUICtrlSetData($aButtonIDs[$i][2], "choose...")
						_GUICtrlComboBox_SetCurSel($aButtonIDs[$i][2], 0)
						$return = _inputbox($sDeviceName)
						If IsArray($return) Then
							$aButtonIDs[$i][5] = $return[0][0]
							$aButtonIDs[$i][6] = "k," & $return[0][1]
							GUICtrlSetData($aButtonIDs[$i][2], $return[0][0])
							_GUICtrlComboBox_SetCurSel($aButtonIDs[$i][2], _GUICtrlComboBox_SelectString($aButtonIDs[$i][2], $return[0][0]))
						Else
							_GUICtrlComboBox_ResetContent($aButtonIDs[$i][2])
							ControlDisable($btngui, "", $aButtonIDs[$i][2])
							_GUICtrlComboBox_ResetContent($aButtonIDs[$i][1])
							GUICtrlSetData($aButtonIDs[$i][1], "keyboard|vJoy")
						EndIf
					EndIf
					If StringInStr(GUICtrlRead($aButtonIDs[$i][1]), "vJoy") Then
						ControlEnable($btngui, "", $aButtonIDs[$i][2])
						_GUICtrlComboBox_ResetContent($aButtonIDs[$i][2])
						GUICtrlSetData($aButtonIDs[$i][2], $vjoyfill)
						_GUICtrlComboBox_SetCurSel($aButtonIDs[$i][2], 0)
						_GUICtrlComboBox_ShowDropDown($aButtonIDs[$i][2], True)
						ControlFocus($btngui, "", $aButtonIDs[$i][2])
					EndIf

				Case $aButtonIDs[$i][3]
					_GUICtrlComboBox_ResetContent($aButtonIDs[$i][2])
					ControlDisable($btngui, "", $aButtonIDs[$i][2])
					_GUICtrlComboBox_ResetContent($aButtonIDs[$i][1])
					GUICtrlSetData($aButtonIDs[$i][1], "keyboard|vJoy")

				Case $aButtonIDs[$i][2]
					If StringInStr(GUICtrlRead($aButtonIDs[$i][2]), "choose...") And StringInStr(GUICtrlRead($aButtonIDs[$i][1]), "keyboard") Then
						$return = _inputbox($sDeviceName)
						If IsArray($return) Then
							$aButtonIDs[$i][5] = $return[0][0]
							$aButtonIDs[$i][6] = "k," & $return[0][1]
							GUICtrlSetData($aButtonIDs[$i][2], $return[0][0])
							_GUICtrlComboBox_SetCurSel($aButtonIDs[$i][2], _GUICtrlComboBox_SelectString($aButtonIDs[$i][2], $return[0][0]))
						Else
							_GUICtrlComboBox_ResetContent($aButtonIDs[$i][2])
							ControlDisable($btngui, "", $aButtonIDs[$i][2])
							_GUICtrlComboBox_ResetContent($aButtonIDs[$i][1])
						EndIf
					EndIf
					If StringInStr(GUICtrlRead($aButtonIDs[$i][1]), "vJoy") Then
						$aButtonIDs[$i][5] = GUICtrlRead($aButtonIDs[$i][2])
						$aButtonIDs[$i][6] = "j," & GUICtrlRead($aButtonIDs[$i][2])
					EndIf
			EndSwitch
		Next

	WEnd
	GUIDelete($btngui)
EndFunc   ;==>_buttonGUI

Func _inputbox($device, $btnID = 0)
	Local $aIDs[12][2]
	Local $Gui = GUICreate("Set Keyboard Input", 325, 284, -1, -1);, BitOR(-1, 0x00020000), 0x00000008)

	GUICtrlCreateLabel("This is the only menu where you have to select OK to save changes!", 5, 5, 300, 40)
	GUICtrlSetFont(-1, 9, 500)
	Local $inputboxInfo = GUICtrlCreateButton("i", 310, 4, 13, 14)

	Local $height = 45
	GUICtrlCreateGroup("Modifier Buttons", 5, $height, 315, 70)
	GUICtrlSetState(-1, 256)
	Local $inputboxModBtns = GUICtrlCreateButton("i", 310 - 5, $height + 8, 13, 14)
	$aIDs[0][0] = GUICtrlCreateCheckbox("Ctrl left", 10, $height + 20, 60, 15)
	$aIDs[1][0] = GUICtrlCreateCheckbox("Ctrl right", 10, $height + 45, 60, 15)
	$aIDs[2][0] = GUICtrlCreateCheckbox("Win left", 90, $height + 20, 60, 15)
	$aIDs[3][0] = GUICtrlCreateCheckbox("Win right", 90, $height + 45, 60, 15)
	$aIDs[4][0] = GUICtrlCreateCheckbox("Alt left", 170, $height + 20, 60, 15)
	$aIDs[5][0] = GUICtrlCreateCheckbox("Alt right", 170, $height + 45, 60, 15)
	$aIDs[6][0] = GUICtrlCreateCheckbox("Shift left", 250, $height + 20, 55, 15)
	$aIDs[7][0] = GUICtrlCreateCheckbox("Shift right", 250, $height + 45, 60, 15)

	$height += 75
	GUICtrlCreateGroup("Normal Buttons", 5, $height, 315, 45)
	Local $inputboxNormBtns = GUICtrlCreateButton("i", 310 - 5, $height + 8, 13, 14)
	$aIDs[8][0] = GUICtrlCreateInput("", 10, $height + 20, 85, 17)
	;GUICtrlSetLimit(-1, 1)
	$aIDs[9][0] = GUICtrlCreateCheckbox("is on numbers block?", 105, $height + 20, 120, 15)
	ControlDisable($Gui, "", $aIDs[9][0])

	$height += 50
	GUICtrlCreateGroup("Special Buttons", 5, $height, 315, 50)
	Local $inputboxSpcBtns = GUICtrlCreateButton("i", 310 - 5, $height + 8, 13, 14)
	$aIDs[10][0] = GUICtrlCreateCombo("", 10, $height + 20, 85, 17, BitOR(0x0003, 0x00200000))
	GUICtrlSetData($aIDs[10][0], "||ESC|F1|F2|F3|F4|F5|F6|F7|F8|F9|F10|F11|F12|PrintScreen|ScrollLock|Break|Backspace|Insert|Home|PgUp|NumLock|Tab|Enter|Delete|End|PgDn|CapsLock|Space|Up|Left|Down|Right", "")
	$aIDs[11][0] = GUICtrlCreateCheckbox("is on numbers block?", 105, $height + 20, 120, 15)
	ControlDisable($Gui, "", $aIDs[11][0])

	For $i = 0 To UBound($aIDs) - 1
		$aIDs[$i][1] = GetClassNameNN_FromControlID($Gui, "", $aIDs[$i][0])
	Next

	$height += 70
	Local $ok = GUICtrlCreateButton("OK", 75, $height, 75, 20)
	Local $cancel = GUICtrlCreateButton("Cancel", 175, $height, 75, 20)

	GUISetState(@SW_SHOW, $Gui)

	While 1
		If StringLen(GUICtrlRead($aIDs[8][0])) > 1 Then
			GUICtrlSetData($aIDs[8][0], StringRight(GUICtrlRead($aIDs[8][0]), 1))
		EndIf

		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				GUIDelete($Gui)
				Return -1
			Case $cancel
				GUIDelete($Gui)
				Return -1
			Case $ok
				$eval = _evalInputbox($aIDs)
				GUIDelete($Gui)
				Return $eval
			Case $inputboxInfo
				_infobox("buttonssetup")
			Case $inputboxModBtns
				_infobox("modbtns")
			Case $inputboxNormBtns
				_infobox("normbtns")
			Case $inputboxSpcBtns
				_infobox("spcbtns")
		EndSwitch

		$focus = _focusIDKeyb($aIDs, $Gui)
		Switch $focus
			Case $aIDs[8][0] ; normal buttons
				If StringLen(GUICtrlRead($aIDs[8][0])) <> 0 Then
					_GUICtrlComboBox_SetCurSel($aIDs[10][0], -1)
					GUICtrlSetState($aIDs[11][0], 4)
					ControlDisable($Gui, "", $aIDs[11][0])
					$numblock = _possNumBlock(GUICtrlRead($aIDs[8][0]))
					If $numblock = 1 Then
						ControlEnable($Gui, "", $aIDs[9][0])
					Else
						GUICtrlSetState($aIDs[9][0], 4)
						ControlDisable($Gui, "", $aIDs[9][0])
					EndIf
				Else
					GUICtrlSetState($aIDs[9][0], 4)
					ControlDisable($Gui, "", $aIDs[9][0])
				EndIf

			Case $aIDs[10][0]
				If _GUICtrlComboBox_GetDroppedState($aIDs[10][0]) = False And StringLen(GUICtrlRead($aIDs[10][0])) <> 0 Then
					GUICtrlSetData($aIDs[8][0], "")
					GUICtrlSetState($aIDs[9][0], 4)
					ControlDisable($Gui, "", $aIDs[9][0])
					$numblock = _possNumBlock(GUICtrlRead($aIDs[10][0]))
					If $numblock = 1 Then
						ControlEnable($Gui, "", $aIDs[11][0])
					Else
						GUICtrlSetState($aIDs[11][0], 4)
						ControlDisable($Gui, "", $aIDs[11][0])
					EndIf
				Else
					GUICtrlSetState($aIDs[11][0], 4)
					ControlDisable($Gui, "", $aIDs[11][0])
				EndIf
		EndSwitch
	WEnd
EndFunc   ;==>_inputbox

Func _evalInputbox($aIDs)
	Local $string[1][2] = [["", ""]]
	Local $string1 = ""
	Local $string2 = ""

	;ctrl
	$string1 = ""
	$string2 = ""
	If (GUICtrlRead($aIDs[0][0]) = 1) Then
		$string1 = "<LCtrl>"
		$string2 = "LCtrl,"
	EndIf

	If (GUICtrlRead($aIDs[1][0]) = 1) Then
		$string1 = "<RCtrl>"
		$string2 = "RCtrl,"
	EndIf

	If (GUICtrlRead($aIDs[0][0]) = 1) And (GUICtrlRead($aIDs[1][0]) = 1) Then
		$string1 = "<Ctrl>"
		$string2 = "Ctrl,"
	EndIf
	$string[0][0] &= $string1
	$string[0][1] &= $string2
	;ctrl

	;win
	$string1 = ""
	$string2 = ""
	If (GUICtrlRead($aIDs[2][0]) = 1) Then
		$string1 = "<LWin>"
		$string2 = "LWin,"
	EndIf

	If (GUICtrlRead($aIDs[3][0]) = 1) Then
		$string1 = "<RWin>"
		$string2 = "RWin,"
	EndIf

	If (GUICtrlRead($aIDs[2][0]) = 1) And (GUICtrlRead($aIDs[3][0]) = 1) Then
		$string1 = "<Win>"
		$string2 = "Win,"
	EndIf
	$string[0][0] &= $string1
	$string[0][1] &= $string2
	;win

	;alt
	$string1 = ""
	$string2 = ""
	If (GUICtrlRead($aIDs[4][0]) = 1) Then
		$string1 = "<LAlt>"
		$string2 = "LAlt,"
	EndIf

	If (GUICtrlRead($aIDs[5][0]) = 1) Then
		$string1 = "<RAlt>"
		$string2 = "RAlt,"
	EndIf

	If (GUICtrlRead($aIDs[4][0]) = 1) And (GUICtrlRead($aIDs[5][0]) = 1) Then
		$string1 = "<Alt>"
		$string2 = "Alt,"
	EndIf
	$string[0][0] &= $string1
	$string[0][1] &= $string2
	;alt

	;shift
	$string1 = ""
	$string2 = ""
	If (GUICtrlRead($aIDs[6][0]) = 1) Then
		$string1 = "<LShift>"
		$string2 = "LShift,"
	EndIf

	If (GUICtrlRead($aIDs[7][0]) = 1) Then
		$string1 = "<RShift>"
		$string2 = "RShift,"
	EndIf

	If (GUICtrlRead($aIDs[6][0]) = 1) And (GUICtrlRead($aIDs[7][0]) = 1) Then
		$string1 = "<Shift>"
		$string2 = "Shift,"
	EndIf
	$string[0][0] &= $string1
	$string[0][1] &= $string2
	;shift

	;normal
	$string1 = ""
	$string2 = ""
	If Not (GUICtrlRead($aIDs[8][0]) = "") Then
		$string1 = "<" & StringUpper(GUICtrlRead($aIDs[8][0])) & ">"
		$string2 = StringUpper(GUICtrlRead($aIDs[8][0])) & ","
		If (GUICtrlRead($aIDs[9][0]) = 1) Then
			$string1 = StringTrimLeft($string1, 1)
			$string1 = "<" & "Numpad" & $string1
			$string2 = "Numpad" & $string2
		EndIf
	EndIf
	$string[0][0] &= $string1
	$string[0][1] &= $string2
	;normal

	;special
	$string1 = ""
	$string2 = ""
	If Not (GUICtrlRead($aIDs[10][0]) = "") Then
		$string1 = "<" & GUICtrlRead($aIDs[10][0]) & ">"
		$string2 = GUICtrlRead($aIDs[10][0]) & ","
		If (GUICtrlRead($aIDs[11][0]) = 1) Then
			$string1 = StringTrimLeft($string1, 1)
			$string1 = "<" & "Numpad" & $string1
			$string2 = "Numpad" & $string2
		EndIf
	EndIf
	$string[0][0] &= $string1
	$string[0][1] &= $string2
	;special

	$string[0][1] = StringTrimRight($string[0][1], 1)
	;_ArrayDisplay($string)
	Return $string
EndFunc   ;==>_evalInputbox

Func _possNumBlock($input)
	Local $aNumblock[26] = ["/", "*", "-", "+", "Enter", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ",", "Home", "PgUp", "End", "PgDn", "Insert", "Delete", "Up", "Left", "Down", "Right"]
	For $i = 0 To UBound($aNumblock) - 1
		If $input = $aNumblock[$i] Then Return (1)
	Next
	Return 0
EndFunc   ;==>_possNumBlock

Func _axesHandler()
	Local $sAxes = "", $sConflictMsg = "", $sMulti = ""
	Dim $aAllAxes[0][2], $aAllAxes2[0][2], $aConflicts[0][2], $aMulti

	For $i = 1 To 6
		ReDim $aAllAxes[UBound($aAllAxes) + 1][2]
		$aAllAxes[UBound($aAllAxes) - 1][0] = GUICtrlRead($aAxesIDs[$i])
	Next
	$aAllAxes2 = _ArrayUnique($aAllAxes, 0, 0, 0, 0)
	For $i = 0 To UBound($aAllAxes2) - 1
		$aMulti = _ArrayFindAll($aAllAxes, $aAllAxes2[$i])
		If UBound($aMulti) >= 2 Then
			Local $sMulti = ""
			ReDim $aConflicts[UBound($aConflicts) + 1][2]
			$aConflicts[UBound($aConflicts) - 1][0] = $aAllAxes2[$i]
			For $i2 = 0 To UBound($aMulti) - 1
				If $i2 = UBound($aMulti) - 1 Then
					$sMulti = StringTrimRight($sMulti, 2)
					$sMulti &= " and " & $aMulti[$i2] + 1
					$sMulti = StringReplace($sMulti, "1", "x")
					$sMulti = StringReplace($sMulti, "2", "y")
					$sMulti = StringReplace($sMulti, "3", "z")
					$sMulti = StringReplace($sMulti, "4", "Rx")
					$sMulti = StringReplace($sMulti, "5", "Ry")
					$sMulti = StringReplace($sMulti, "6", "Rz")
					ExitLoop
				Else
					$sMulti &= $aMulti[$i2] + 1 & ", "
				EndIf
			Next
			$aConflicts[UBound($aConflicts) - 1][1] = $sMulti
		EndIf
	Next
	;_arraydisplay($aConflicts)
	If UBound($aConflicts) <> 0 Then
		For $i = 0 To UBound($aConflicts) - 1
			$sConflictMsg &= "3DC axes " & $aConflicts[$i][1] & " assigned to vJoy Axis " & $aConflicts[$i][0] & " // "
		Next
		$sConflictMsg = StringTrimRight($sConflictMsg, 4)
		_marqueeAxs($sConflictMsg, "red")
	Else
		_marqueeAxs("none", "green")

		For $i = 4 To 6
			$sAxes &= GUICtrlRead($aAxesIDs[$i]) & ","
		Next
		For $i = 1 To 3
			$sAxes &= GUICtrlRead($aAxesIDs[$i]) & ","
		Next

		;For $i = 1 To 6
		;	$sAxes &= GUICtrlRead($aAxesIDs[$i]) & ","
		;Next

		$sAxes = StringTrimRight($sAxes, 1)
		$sAxes = StringReplace($sAxes, "Rx", "xR")
		$sAxes = StringReplace($sAxes, "Ry", "yR")
		$sAxes = StringReplace($sAxes, "Rz", "zR")
		IniWrite(@ScriptDir & "\config.ini", GUICtrlRead($aProfileIDs[1]), "axes order", " " & $sAxes)
	EndIf
EndFunc   ;==>_axesHandler

Func _marqueeAxs($message, $color)
	_GUICtrlMarquee_SetDisplay($aMarqueeAxs, 0, $color, -1, 8.5, "Arial")
	If $color = "green" Then
		_GUICtrlMarquee_SetScroll($aMarqueeAxs, -1, "slide", "left", 10000, 10)
	Else
		_GUICtrlMarquee_SetScroll($aMarqueeAxs, -1, "scroll", "left", 2, 50)
	EndIf
	_GUICtrlMarquee_Reset($aMarqueeAxs, $message)
EndFunc   ;==>_marqueeAxs

Func _isThrottleHandler($param)
	If GUICtrlRead($aIsThrottleIDs[$param][0]) = "no (off)" And Not (IniRead(@ScriptDir & "\config.ini", GUICtrlRead($aProfileIDs[1]), "axis " & $aLabels[$param - 1] & " is throttle", -1) = 0) Then IniWrite(@ScriptDir & "\config.ini", GUICtrlRead($aProfileIDs[1]), "axis " & $aLabels[$param - 1] & " is throttle", " 0")
	If GUICtrlRead($aIsThrottleIDs[$param][0]) = "3DC controller" And Not (IniRead(@ScriptDir & "\config.ini", GUICtrlRead($aProfileIDs[1]), "axis " & $aLabels[$param - 1] & " is throttle", -1) = 1) Then IniWrite(@ScriptDir & "\config.ini", GUICtrlRead($aProfileIDs[1]), "axis " & $aLabels[$param - 1] & " is throttle", " 1")
	If GUICtrlRead($aIsThrottleIDs[$param][0]) = "mousewheel" And Not (IniRead(@ScriptDir & "\config.ini", GUICtrlRead($aProfileIDs[1]), "axis " & $aLabels[$param - 1] & " is throttle", -1) = 2) Then IniWrite(@ScriptDir & "\config.ini", GUICtrlRead($aProfileIDs[1]), "axis " & $aLabels[$param - 1] & " is throttle", " 2")
EndFunc   ;==>_isThrottleHandler

Func _ThrottleSteps($param)
	If Not (IniRead(@ScriptDir & "\config.ini", GUICtrlRead($aProfileIDs[1]), "axis " & $aLabels[$param - 1] & " increments", -1) = GUICtrlRead($aThrottleStepsIDs[$i][0])) Then IniWrite(@ScriptDir & "\config.ini", GUICtrlRead($aProfileIDs[1]), "axis " & $aLabels[$param - 1] & " increments", " " & GUICtrlRead($aThrottleStepsIDs[$i][0]))
EndFunc   ;==>_ThrottleSteps

Func _ThrottleZero($param)
	If Not (IniRead(@ScriptDir & "\config.ini", GUICtrlRead($aProfileIDs[1]), "axis " & $aLabels[$param - 1] & " zero", -1) = GUICtrlRead($aThrottleZeroIDs[$i][0])) Then IniWrite(@ScriptDir & "\config.ini", GUICtrlRead($aProfileIDs[1]), "axis " & $aLabels[$param - 1] & " zero", " " & GUICtrlRead($aThrottleZeroIDs[$i][0]))
EndFunc   ;==>_ThrottleZero

Func _invertHandler($param)
	Local $checkbox = 0
	If GUICtrlRead($aInvertIDs[$param][0]) = 1 Then $checkbox = 1
	IniWrite(@ScriptDir & "\config.ini", GUICtrlRead($aProfileIDs[1]), "axis " & $aLabels[$param - 1] & " invert", " " & $checkbox)
EndFunc   ;==>_invertHandler

Func _infobox($parameter)
	Local $msg = ""
	Switch $parameter
		Case "profiles"
			$section = "Profiles"
			$msg = $section & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 1, "") & @CRLF & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 2, "") & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 3, "") & @CRLF & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 4, "") & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 5, "") & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 6, "") & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 7, "") & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 8, "") & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 9, "") & @CRLF & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 10, "") & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 11, "") & @CRLF & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 12, "") & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 13, "") & @CRLF & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 14, "") & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 15, "") & @CRLF & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 16, "") & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 17, "") & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 18, "")
		Case "deadzone"
			$section = "Deadzone (%)"
			$msg = $section & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 1, "") & @CRLF & @TAB & IniRead(@ScriptDir & "\infobox.ini", $section, 2, "") & @CRLF & @TAB & IniRead(@ScriptDir & "\infobox.ini", $section, 3, "") & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 4, "")
		Case "linsens"
			$section = "Pitch"
			$msg = $section & " of the graph (divider)" & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 1, "") & @CRLF & @TAB & IniRead(@ScriptDir & "\infobox.ini", $section, 2, "") & @CRLF & @TAB & IniRead(@ScriptDir & "\infobox.ini", $section, 3, "") & @CRLF & @TAB & IniRead(@ScriptDir & "\infobox.ini", $section, 4, "") & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 5, "") & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 6, "")
		Case "logsens"
			$section = "Curvature (%)"
			$msg = $section & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 1, "") & @CRLF & @TAB & IniRead(@ScriptDir & "\infobox.ini", $section, 2, "") & @CRLF & @TAB & IniRead(@ScriptDir & "\infobox.ini", $section, 3, "") & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 4, "") & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 5, "") & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 6, "")
		Case "converttothrottle"
			$section = "Convert Axis"
			$msg = $section & " (choose from dropdown menu)" & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 1, "") & @CRLF & @TAB & IniRead(@ScriptDir & "\infobox.ini", $section, 2, "") & @CRLF & @TAB & IniRead(@ScriptDir & "\infobox.ini", $section, 3, "") & @CRLF & @TAB & IniRead(@ScriptDir & "\infobox.ini", $section, 4, "") & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 5, "") & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 6, "") & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 7, "") & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 8, "")
		Case "throttlesteps"
			$section = "Increments (%)"
			$msg = $section & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 1, "") & @CRLF & @TAB & IniRead(@ScriptDir & "\infobox.ini", $section, 2, "") & @CRLF & @TAB & IniRead(@ScriptDir & "\infobox.ini", $section, 3, "") & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 4, "")
		Case "throttlezero"
			$section = "Zero Throttle at %"
			$msg = $section & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 1, "") & @CRLF & @TAB & IniRead(@ScriptDir & "\infobox.ini", $section, 2, "") & @CRLF & @TAB & IniRead(@ScriptDir & "\infobox.ini", $section, 3, "") & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 4, "")
		Case "exponent"
			$section = "Exponent"
			$msg = $section & " (odd integer)" & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 1, "") & @CRLF & @TAB & IniRead(@ScriptDir & "\infobox.ini", $section, 2, "") & @CRLF & @TAB & IniRead(@ScriptDir & "\infobox.ini", $section, 3, "") & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 4, "") & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 5, "") & @CRLF & @TAB & IniRead(@ScriptDir & "\infobox.ini", $section, 6, "") & @CRLF & @TAB & IniRead(@ScriptDir & "\infobox.ini", $section, 7, "") & @CRLF & @TAB & IniRead(@ScriptDir & "\infobox.ini", $section, 8, "")
		Case "invert"
			$section = "Invert"
			$msg = $section & " (ticked/unticked)" & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 1, "") & @CRLF & @TAB & IniRead(@ScriptDir & "\infobox.ini", $section, 2, "") & @CRLF & @TAB & IniRead(@ScriptDir & "\infobox.ini", $section, 3, "") & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 4, "")
		Case "assign"
			$section = "Assign Axes"
			$msg = $section & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 1, "") & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 2, "")
		Case "devsel"
			$section = "Assign Buttons"
			$msg = $section & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 1, "")
		Case "graph"
			$section = "Graph"
			$msg = $section & @CRLF & @CRLF & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 1, "") & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 2, "") & @CRLF & @CRLF & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 3, "") & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 4, "")
		Case "buttonssetup"
			$section = "Set Keyboard Input"
			$msg = $section & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 1, "")
		Case "modbtns"
			$section = "Modifier Buttons"
			$msg = $section & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 1, "")
		Case "normbtns"
			$section = "Normal Buttons"
			$msg = $section & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 1, "") & @CRLF & @CRLF & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 2, "") & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 3, "")
		Case "spcbtns"
			$section = "Special Buttons"
			$msg = $section & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 1, "") & @CRLF & @CRLF & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 2, "") & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 3, "")
		Case "btncfg"
			$section = "Button Configurator"
			$msg = $section & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 1, "") & @CRLF & @CRLF & IniRead(@ScriptDir & "\infobox.ini", $section, 2, "")
	EndSwitch
	If $msg <> "" Then
		MsgBox(64, "Sx2vJoy Config GUI Info", $msg)
	EndIf
EndFunc   ;==>_infobox

Func _deadzoneHandler($method)
	Local $num0, $num1
	For $i = 1 To 6
		$num0 = Number(GUICtrlRead($aDeadzoneIDs[$i][0]))
		$num1 = Number(GUICtrlRead($aDeadzoneIDs[$i][1]))

		If $num0 <> $num1 Then
			If $method = "keyboard" Then
				If $num0 < 0 Then
					$num0 = 0
					GUICtrlSetData($aDeadzoneIDs[$i][0], $num0)
				EndIf
				If $num0 > 100 Then
					$num0 = 100
					GUICtrlSetData($aDeadzoneIDs[$i][0], $num0)
				EndIf
				GUICtrlSetData($aDeadzoneIDs[$i][1], $num0)
				IniWrite(@ScriptDir & "\config.ini", GUICtrlRead($aProfileIDs[1]), "axis " & $aLabels[$i - 1] & " deadzone", " " & Number(GUICtrlRead($aDeadzoneIDs[$i][0])))
			EndIf

			If $method = "mouse" Then
				If $num1 < 0 Then
					$num1 = 0
					GUICtrlSetData($aDeadzoneIDs[$i][1], $num1)
				EndIf
				If $num1 > 100 Then
					$num1 = 100
					GUICtrlSetData($aDeadzoneIDs[$i][1], $num1)
				EndIf
				GUICtrlSetData($aDeadzoneIDs[$i][0], $num1)
				IniWrite(@ScriptDir & "\config.ini", GUICtrlRead($aProfileIDs[1]), "axis " & $aLabels[$i - 1] & " deadzone", " " & Number(GUICtrlRead($aDeadzoneIDs[$i][0])))
			EndIf
		EndIf
	Next
EndFunc   ;==>_deadzoneHandler

Func _linsensHandler($method, $i)
	Local $redraw = 1, $old, $new, $num1
	If $method = "mouse" Then
		$old = $aLinSensIDs[$i][4]
		$new = $aLinSensIDs[$i][3]
		$num1 = Number(GUICtrlRead($aLinSensIDs[$i][1]))
		GUICtrlSetData($aLinSensIDs[$i][1], 0)
		$aLinSensIDs[$i][3] += $num1 * 0.001
		If $aLinSensIDs[$i][3] < 0 Then $aLinSensIDs[$i][3] = 0
		If $aLinSensIDs[$i][3] > 100 Then $aLinSensIDs[$i][3] = 100
		GUICtrlSetData($aLinSensIDs[$i][0], (StringFormat("%#.3f", $aLinSensIDs[$i][3])))
		;If ($new <> $old) Then
		;$aLinSensIDs[$i][4] = $aLinSensIDs[$i][3]
		IniWrite(@ScriptDir & "\config.ini", GUICtrlRead($aProfileIDs[1]), "axis " & $aLabels[$i - 1] & " pitch", " " & GUICtrlRead($aLinSensIDs[$i][0]))
		;EndIf
	EndIf

	If $method = "keyboard" Then
		$old = $aLinSensIDs[$i][4]
		$new = $aLinSensIDs[$i][3]
		$num0 = Number(GUICtrlRead($aLinSensIDs[$i][0]))
		If $num0 < 0 Then
			$num0 = 0
			$redraw = 0
			GUICtrlSetData($aLinSensIDs[$i][0], $num0)
			$aLinSensIDs[$i][3] = $num0
		EndIf
		If $num0 > 100 Then
			$num0 = 100
			$redraw = 0
			GUICtrlSetData($aLinSensIDs[$i][0], $num0)
			$aLinSensIDs[$i][3] = $num0
		EndIf
		$aLinSensIDs[$i][3] = Number(GUICtrlRead($aLinSensIDs[$i][0]))
		If ($new <> $old) Then
			$aLinSensIDs[$i][3] = StringFormat("%#.3f", $aLinSensIDs[$i][3])
			$aLinSensIDs[$i][4] = $aLinSensIDs[$i][3]
			GUICtrlSetData($aLinSensIDs[$i][0], (StringFormat("%#.3f", $aLinSensIDs[$i][3])))
			IniWrite(@ScriptDir & "\config.ini", GUICtrlRead($aProfileIDs[1]), "axis " & $aLabels[$i - 1] & " pitch", " " & GUICtrlRead($aLinSensIDs[$i][0]))
			If $redraw = 1 Then _DrawFrame(Number(GUICtrlRead($aLogSensIDs[$i][0])), Number(GUICtrlRead($aExponentIDs[$i][0])), GUICtrlRead($aLinSensIDs[$i][0]), $i)
		EndIf
	EndIf
EndFunc   ;==>_linsensHandler

Func _curvatureHandler($method, $i)
	Local $redraw = 1, $num0 = Number(GUICtrlRead($aLogSensIDs[$i][0])), $num1 = Number(GUICtrlRead($aLogSensIDs[$i][1]))

	If $num0 <> $num1 Then
		If $method = "keyboard" Then
			If $num0 < 0 Then
				$num0 = 0
				$redraw = 0
				GUICtrlSetData($aLogSensIDs[$i][0], $num0)
			EndIf
			If $num0 > 100 Then
				$num0 = 100
				$redraw = 0
				GUICtrlSetData($aLogSensIDs[$i][0], $num0)
			EndIf
			GUICtrlSetData($aLogSensIDs[$i][1], $num0)
			IniWrite(@ScriptDir & "\config.ini", GUICtrlRead($aProfileIDs[1]), "axis " & $aLabels[$i - 1] & " curvature", " " & Number(GUICtrlRead($aLogSensIDs[$i][0])))
			If $redraw = 1 Then _DrawFrame(Number(GUICtrlRead($aLogSensIDs[$i][0])), Number(GUICtrlRead($aExponentIDs[$i][0])), GUICtrlRead($aLinSensIDs[$i][0]), $i)
		EndIf

		If $method = "mouse" Then
			If $num1 < 0 Then
				$num1 = 0
				$redraw = 0
				GUICtrlSetData($aLogSensIDs[$i][1], $num1)
			EndIf
			If $num1 > 100 Then
				$num1 = 100
				$redraw = 0
				GUICtrlSetData($aLogSensIDs[$i][1], $num1)
			EndIf
			GUICtrlSetData($aLogSensIDs[$i][0], $num1)
			IniWrite(@ScriptDir & "\config.ini", GUICtrlRead($aProfileIDs[1]), "axis " & $aLabels[$i - 1] & " curvature", " " & Number(GUICtrlRead($aLogSensIDs[$i][0])))
			If $redraw = 1 Then _DrawFrame(Number(GUICtrlRead($aLogSensIDs[$i][0])), Number(GUICtrlRead($aExponentIDs[$i][0])), GUICtrlRead($aLinSensIDs[$i][0]), $i)
		EndIf
	EndIf
EndFunc   ;==>_curvatureHandler

Func _exponentHandler($method, $i)
	Local $redraw = 1, $num0 = Number(GUICtrlRead($aExponentIDs[$i][0])), $num1 = Number(GUICtrlRead($aExponentIDs[$i][1]))

	If $num0 <> $num1 Then
		If $method = "keyboard" Then
			If $num0 < 1 Then
				$num0 = 1
				$redraw = 0
				GUICtrlSetData($aExponentIDs[$i][0], $num0)
			EndIf
			If $num0 > 65 Then
				$num0 = 65
				$redraw = 0
				GUICtrlSetData($aExponentIDs[$i][0], $num0)
			EndIf
			GUICtrlSetData($aExponentIDs[$i][1], $num0)
			If BitAND(Number(GUICtrlRead($aExponentIDs[$i][0])), 1) = 1 Then IniWrite(@ScriptDir & "\config.ini", GUICtrlRead($aProfileIDs[1]), "axis " & $aLabels[$i - 1] & " exponent", " " & Number(GUICtrlRead($aExponentIDs[$i][0])))
			If $redraw = 1 Then _DrawFrame(Number(GUICtrlRead($aLogSensIDs[$i][0])), Number(GUICtrlRead($aExponentIDs[$i][0])), GUICtrlRead($aLinSensIDs[$i][0]), $i)
		EndIf

		If $method = "mouse" Then
			If $num1 < 1 Then
				$num1 = 1
				$redraw = 0
				GUICtrlSetData($aExponentIDs[$i][1], $num1)
			EndIf
			If $num1 > 65 Then
				$num1 = 65
				$redraw = 0
				GUICtrlSetData($aExponentIDs[$i][1], $num1)
			EndIf
			GUICtrlSetData($aExponentIDs[$i][0], $num1)
			If BitAND(Number(GUICtrlRead($aExponentIDs[$i][0])), 1) = 1 Then IniWrite(@ScriptDir & "\config.ini", GUICtrlRead($aProfileIDs[1]), "axis " & $aLabels[$i - 1] & " exponent", " " & Number(GUICtrlRead($aExponentIDs[$i][0])))
			If $redraw = 1 Then _DrawFrame(Number(GUICtrlRead($aLogSensIDs[$i][0])), Number(GUICtrlRead($aExponentIDs[$i][0])), GUICtrlRead($aLinSensIDs[$i][0]), $i)
		EndIf
	EndIf
EndFunc   ;==>_exponentHandler

Func GetClassNameNN_FromControlID($wndTitle, $winText, $id)
	; Derive the Window Class for the given Control ID
	Local $hWnd = ControlGetHandle($wndTitle, $winText, $id)
	Local $ClassName = _WinAPI_GetClassName($hWnd)

	; Get an array of classes associated with the same window
	Local $ClassList = StringSplit(WinGetClassList($wndTitle, $winText), @LF)
	Local $ClassCount = 0

	; Walk the array.
	For $i = 1 To $ClassList[0]
		If $ClassList[$i] = $ClassName Then
			; If we encounter the same classname, increment the class count
			$ClassCount += 1

			; Obtain the Control ID using the ClassNameNN syntax
			$Test_ClassNameNN = $ClassName & $ClassCount
			$Test_hWnd = ControlGetHandle($wndTitle, $winText, $Test_ClassNameNN)
			$Test_ID = GetControlID($Test_hWnd)

			; Test if the ID's are the same
			If $id = $Test_ID Then Return $Test_ClassNameNN
		EndIf
	Next
EndFunc   ;==>GetClassNameNN_FromControlID

Func GetControlID($hWnd)
	Local $id = DllCall('user32.dll', 'int', 'GetDlgCtrlID', 'hwnd', $hWnd)
	If IsArray($id) Then Return $id[0]
	Return 0
EndFunc   ;==>GetControlID

Func _focusID(ByRef $focusID, ByRef $category)
	$focusID = -1
	$category = -1
	$focus = ControlGetFocus($Form1)
	For $i = 0 To UBound($aHandlesIDsLUT) - 1
		If $focus = $aHandlesIDsLUT[$i][2] Then
			$focusID = $aHandlesIDsLUT[$i][0]
			$category = $aHandlesIDsLUT[$i][1]
			Return
		EndIf
	Next
EndFunc   ;==>_focusID

Func _focusIDKeyb($aIDs, $Gui)
	Local $focus = ControlGetFocus($Gui)
	For $i = 0 To UBound($aIDs) - 1
		If $focus = $aIDs[$i][1] Then
			$focus = $aIDs[$i][0]
			Return $focus
		EndIf
	Next
	$focus = -1
EndFunc   ;==>_focusIDKeyb

Func _PrepFrame($w = 290, $h = 290)
	_GDIPlus_GraphicsDrawLine($hBackbuffer, 0, $h / 2, $w, $h / 2, $hPen1)
	_GDIPlus_GraphicsDrawLine($hBackbuffer, $w / 2, 0, $w / 2, $h, $hPen1)
	_GDIPlus_GraphicsDrawRect($hBackbuffer, 0, 0, $w - 1, $h - 1)
	_GDIPlus_GraphicsDrawImageRect($hGraphics, $hBitmap, $graph_x, $graph_y, $w, $h)
EndFunc   ;==>_PrepFrame

Func _DrawFrame($curv = 100, $exp = 3, $multi = 1, $axis = 1, $w = 290, $h = 290)
	Local $percent1 = $curv / 100
	Local $percent2 = 1 - $percent1
	Local $sEquation = $percent2 & "*(x*" & $multi & ")+" & $percent1 & "*(x*" & $multi & ")^" & $exp
	Dim $aPoints[$w * $h][2]
	Local $function = StringReplace($sEquation, "x", "$i")

	For $i = 1 To 6
		If $i = $axis Then
			If Not (GUICtrlGetState($aAxisRadio[$i]) = 1) Then GUICtrlSetState($aAxisRadio[$i], 1)
		Else
			If Not (GUICtrlGetState($aAxisRadio[$i]) = 4) Then GUICtrlSetState($aAxisRadio[$i], 4)
		EndIf
	Next

	Local $count = 0
	For $i = -1 To 1 Step 0.002
		$x_1 = ($i * $w / 1 + $w) / 2
		$y_1 = $h / 2 - Execute($function) * $w / 2
		If ($y_1 > 0) And ($y_1 < ($h - 1)) And ($x_1 > 0) And ($x_1 < ($w - 1)) Then
			$count += 1
			$aPoints[$count][0] = $x_1
			$aPoints[$count][1] = $y_1
		EndIf
	Next
	ReDim $aPoints[$count + 1][2]
	$aPoints[0][0] = UBound($aPoints) - 1

	_GDIPlus_GraphicsClear($hBackbuffer, 0xFFFFFFFF)
	_GDIPlus_GraphicsDrawLine($hBackbuffer, 0, $h / 2, $w, $h / 2, $hPen1)
	_GDIPlus_GraphicsDrawLine($hBackbuffer, $w / 2, 0, $w / 2, $h, $hPen1)
	_GDIPlus_GraphicsDrawCurve($hBackbuffer, $aPoints, $hPen2)
	_GDIPlus_GraphicsDrawRect($hBackbuffer, 0, 0, $w - 1, $h - 1)
	_GDIPlus_GraphicsDrawImageRect($hGraphics, $hBitmap, $graph_x, $graph_y, $w, $h)
EndFunc   ;==>_DrawFrame

Func _CleanExit()
	_GDIPlus_PenDispose($hPen1)
	_GDIPlus_PenDispose($hPen2)
	_GDIPlus_GraphicsDispose($hGraphics)
	_GDIPlus_BitmapDispose($hBackbuffer)
	_GDIPlus_BitmapDispose($hBitmap)
	_GDIPlus_Shutdown()
	Exit
EndFunc   ;==>_CleanExit

Func _GUICtrlCreateGroupEx($sText, $iLeft, $iTop, $iWidth, $iHeight, $bColor = 0xC0C0C0, $OutlineColor = 0xFFFFFF)
	Local $aLabel[6] = [5], $aLabelInner[6] = [5]
	Local $aStringSize = _StringSize($sText)
	$aLabel[1] = GUICtrlCreateLabel('', $iLeft + 1, $iTop + 1, 1, $iHeight) ; Left Line.
	$aLabelInner[1] = GUICtrlCreateLabel('', $iLeft + 2, $iTop + 1, 1, $iHeight) ; Inner/Outer Left Line.
	$aLabel[2] = GUICtrlCreateLabel('', $iLeft + 1, $iTop + 1, 10, 1) ; Top Left Line.
	$aLabelInner[2] = GUICtrlCreateLabel('', $iLeft + 2, $iTop + 2, 10 - 1, 1) ; Top Inner/Outer Left Line.
	GUICtrlCreateLabel(' ' & $sText, $iLeft + 7, $iTop - 6, $aStringSize[2] - 3, 15)
	$aLabel[3] = GUICtrlCreateLabel('', $iLeft + $aStringSize[2] + 4, $iTop + 1, $iWidth - $aStringSize[2] - 3, 1) ; Top Right Line.
	$aLabelInner[3] = GUICtrlCreateLabel('', $iLeft + $aStringSize[2] + 4, $iTop + 2, $iWidth - $aStringSize[2] - 3, 1) ; Top Inner/Outer Right Line.
	$aLabel[4] = GUICtrlCreateLabel('', $iLeft + $iWidth + 1, $iTop + 1, 1, $iHeight) ; Right Line.
	$aLabelInner[4] = GUICtrlCreateLabel('', $iLeft + $iWidth + 2, $iTop + 1, 1, $iHeight + 1) ; Right Inner/Outer Line.
	$aLabel[5] = GUICtrlCreateLabel('', $iLeft + 1, $iTop + $iHeight + 1, $iWidth + 1, 1) ; Bottom Line.
	$aLabelInner[5] = GUICtrlCreateLabel('', $iLeft + 1, $iTop + $iHeight + 2, $iWidth + 2, 1) ; Bottom Inner/Outer Line.
	For $i = 1 To $aLabel[0]
		GUICtrlSetBkColor($aLabel[$i], $bColor)
		GUICtrlSetBkColor($aLabelInner[$i], $OutlineColor)
	Next
EndFunc   ;==>_GUICtrlCreateGroupEx

Func _readconfig($new = 0)
	Local $Profile = StringLower(GUICtrlRead($aProfileIDs[1])), $force = IniRead(@ScriptDir & "\config.ini", $Profile, "force", 0), $idx = "", $executable = "", $asGUI = 0

	If GUICtrlRead($aProfileIDs[3]) = "as (last) set in GUI" Then $asGUI = 1

	If $Profile = "default" Then
		ControlDisable($Form1, "", $aProfileIDs[2]) ; disable "rename profile"
		_GUICtrlComboBox_ResetContent($aProfileIDs[3]) ; blank "profile activation method"
		GUICtrlSetData($aProfileIDs[3], "none (default profile)|as (last) set in GUI|always active"); insert default profile specific methods into "profile activation method"
		If $asGUI = 0 Then
			_GUICtrlComboBox_SetCurSel($aProfileIDs[3], 1) ; set "profile activation method" selection to "off"
		Else
			_GUICtrlComboBox_SetCurSel($aProfileIDs[3], 0) ; set "profile activation method" selection to "as GUI"
		EndIf
		GUICtrlSetData($aProfileIDs[5], "") ; blank "choose application" edit
		ControlDisable($Form1, "", $aProfileIDs[6]) ; disable "choose..." button
		ControlDisable($Form1, "", $aProfileIDs[4]) ; disable "delete selected profile..." button
	Else
		ControlEnable($Form1, "", $aProfileIDs[2]) ; enable "rename profile"
		_GUICtrlComboBox_ResetContent($aProfileIDs[3]) ; blank "profile activation method"
		GUICtrlSetData($aProfileIDs[3], "none (default profile)|as (last) set in GUI|always active|for specific application|off") ; insert non-default profile specific methods into "profile activation method"
		If $asGUI = 0 Then
			_GUICtrlComboBox_SetCurSel($aProfileIDs[3], 1) ; set "profile activation method" selection to "off"
		Else
			_GUICtrlComboBox_SetCurSel($aProfileIDs[3], 0) ; set "profile activation method" selection to "as GUI"
		EndIf
		ControlEnable($Form1, "", $aProfileIDs[6]) ; enable "choose..." button
		ControlEnable($Form1, "", $aProfileIDs[4]) ; enable "delete selected profile..." button
	EndIf

	If $asGUI = 0 Then
		If $force = 0 Then $idx = _GUICtrlComboBox_FindStringExact($aProfileIDs[3], "off")
		If $force = 1 Then
			If $Profile = "default" Then
				$idx = _GUICtrlComboBox_FindStringExact($aProfileIDs[3], "none (default profile)")
			Else
				$idx = _GUICtrlComboBox_FindStringExact($aProfileIDs[3], "always active")
			EndIf
		EndIf
		If $force = 2 Then $idx = _GUICtrlComboBox_FindStringExact($aProfileIDs[3], "for specific application")
		If Not ($idx == "") Then
			_GUICtrlComboBox_SetCurSel($aProfileIDs[3], $idx)
		EndIf
	EndIf

	$executable = IniRead(@ScriptDir & "\config.ini", $Profile, "executable", "")
	If $executable = "" Then
		GUICtrlSetData($aProfileIDs[5], "")
	Else
		GUICtrlSetData($aProfileIDs[5], $executable)
	EndIf

	If IniRead(@ScriptDir & "\config.ini", "general", "show if active", 0) = 1 Then
		GUICtrlSetState($aProfileIDs[8], 1)
	Else
		GUICtrlSetState($aProfileIDs[8], 4)
	EndIf

	For $i = 0 To 5
		GUICtrlSetData($aDeadzoneIDs[$i + 1][0], IniRead(@ScriptDir & "\config.ini", $Profile, "axis " & $aLabels[$i] & " deadzone", 20))
		GUICtrlSetData($aDeadzoneIDs[$i + 1][1], IniRead(@ScriptDir & "\config.ini", $Profile, "axis " & $aLabels[$i] & " deadzone", 20))

		If IniRead(@ScriptDir & "\config.ini", $Profile, "axis " & $aLabels[$i] & " invert", 0) = 1 Then
			GUICtrlSetState($aInvertIDs[$i + 1][0], 1)
		Else
			GUICtrlSetState($aInvertIDs[$i + 1][0], 4)
		EndIf

		If IniRead(@ScriptDir & "\config.ini", $Profile, "axis " & $aLabels[$i] & " is throttle", 0) = 0 Then _GUICtrlComboBox_SetCurSel($aIsThrottleIDs[$i + 1][0], _GUICtrlComboBox_FindStringExact($aIsThrottleIDs[$i + 1][0], "no (off)"))
		If IniRead(@ScriptDir & "\config.ini", $Profile, "axis " & $aLabels[$i] & " is throttle", 0) = 1 Then _GUICtrlComboBox_SetCurSel($aIsThrottleIDs[$i + 1][0], _GUICtrlComboBox_FindStringExact($aIsThrottleIDs[$i + 1][0], "3DC controller"))
		If IniRead(@ScriptDir & "\config.ini", $Profile, "axis " & $aLabels[$i] & " is throttle", 0) = 2 Then _GUICtrlComboBox_SetCurSel($aIsThrottleIDs[$i + 1][0], _GUICtrlComboBox_FindStringExact($aIsThrottleIDs[$i + 1][0], "mousewheel"))
		_GUICtrlComboBox_SetCurSel($aThrottleStepsIDs[$i + 1][0], _GUICtrlComboBox_FindStringExact($aThrottleStepsIDs[$i + 1][0], IniRead(@ScriptDir & "\config.ini", $Profile, "axis " & $aLabels[$i] & " increments", 0)))
		_GUICtrlComboBox_SetCurSel($aThrottleZeroIDs[$i + 1][0], _GUICtrlComboBox_FindStringExact($aThrottleZeroIDs[$i + 1][0], IniRead(@ScriptDir & "\config.ini", $Profile, "axis " & $aLabels[$i] & " zero", 0)))

		GUICtrlSetData($aLinSensIDs[$i + 1][0], StringFormat("%#.3f", IniRead(@ScriptDir & "\config.ini", $Profile, "axis " & $aLabels[$i] & " pitch", 1)))
		$aLinSensIDs[$i + 1][3] = Number(GUICtrlRead($aLinSensIDs[$i + 1][0]))
		$aLinSensIDs[$i + 1][4] = Number(GUICtrlRead($aLinSensIDs[$i + 1][0]))

		GUICtrlSetData($aLogSensIDs[$i + 1][0], IniRead(@ScriptDir & "\config.ini", $Profile, "axis " & $aLabels[$i] & " curvature", 0))
		GUICtrlSetData($aLogSensIDs[$i + 1][1], IniRead(@ScriptDir & "\config.ini", $Profile, "axis " & $aLabels[$i] & " curvature", 0))

		GUICtrlSetData($aExponentIDs[$i + 1][0], IniRead(@ScriptDir & "\config.ini", $Profile, "axis " & $aLabels[$i] & " exponent", 3))
		GUICtrlSetData($aExponentIDs[$i + 1][1], IniRead(@ScriptDir & "\config.ini", $Profile, "axis " & $aLabels[$i] & " exponent", 3))
	Next

	$axesOrder = IniRead(@ScriptDir & "\config.ini", $Profile, "axes order", 0)
	If Not ($axesOrder == 0) Then
		$split = StringSplit($axesOrder, ",")
		If IsArray($split) Then

			$x = _ArraySearch($split, "x")
			$y = _ArraySearch($split, "y")
			$z = _ArraySearch($split, "z")
			$xR = _ArraySearch($split, "xR")
			$yR = _ArraySearch($split, "yR")
			$zR = _ArraySearch($split, "zR")
			If Not ($x = -1) And Not ($y = -1) And Not ($z = -1) And Not ($xR = -1) And Not ($yR = -1) And Not ($zR = -1) Then
				If $swapRotTrans = 0 Then

					For $i = 1 To 6
						GUICtrlSetData($aAxesLabelIDs[$i - 1], $aLabelsvJ[$i - 1])
						If $split[$i] = "xR" Then $split[$i] = "Rx"
						If $split[$i] = "yR" Then $split[$i] = "Ry"
						If $split[$i] = "zR" Then $split[$i] = "Rz"
						_GUICtrlComboBox_SetCurSel($aAxesIDs[$i], _GUICtrlComboBox_FindStringExact($aAxesIDs[$i], $split[$i]))
					Next
				Else
					For $i = 4 To 6
						GUICtrlSetData($aAxesLabelIDs[$i - 4], $aLabelsvJ[$i - 1])
						If $split[$i] = "xR" Then $split[$i] = "Rx"
						If $split[$i] = "yR" Then $split[$i] = "Ry"
						If $split[$i] = "zR" Then $split[$i] = "Rz"
						_GUICtrlComboBox_SetCurSel($aAxesIDs[$i - 3], _GUICtrlComboBox_FindStringExact($aAxesIDs[$i - 3], $split[$i]))
					Next
					For $i = 1 To 3
						GUICtrlSetData($aAxesLabelIDs[$i + 2], $aLabelsvJ[$i - 1])
						If $split[$i] = "xR" Then $split[$i] = "Rx"
						If $split[$i] = "yR" Then $split[$i] = "Ry"
						If $split[$i] = "zR" Then $split[$i] = "Rz"
						_GUICtrlComboBox_SetCurSel($aAxesIDs[$i + 3], _GUICtrlComboBox_FindStringExact($aAxesIDs[$i + 3], $split[$i]))
					Next
				EndIf
			EndIf
		EndIf
	EndIf

	If $new = 0 Then
		For $i = 1 To 6
			$index = GUICtrlRead($aAxisRadio[$i])
			If $index = 1 Then
				_DrawFrame(Number(GUICtrlRead($aLogSensIDs[$i][0])), Number(GUICtrlRead($aExponentIDs[$i][0])), GUICtrlRead($aLinSensIDs[$i][0]), $i)
				ExitLoop
			EndIf
		Next
	Else
		_GDIPlus_GraphicsClear($hBackbuffer, 0xFFFFFFFF)
		_PrepFrame()
	EndIf
EndFunc   ;==>_readconfig

Func _cleanup()
	; Writing new sections to the .ini and deleting old sections from it often leaves unwanted empty lines.
	; The following code makes sure there's at most one empty line between lines.
	Local $hFile = FileOpen(@ScriptDir & "\config.ini", 0)
	Local $content = FileRead($hFile)
	FileClose($hFile)
	While 1
		$content = StringReplace($content, @CR & @CR & @CR, @CR & @CR)
		If @extended = 0 Then ExitLoop
	WEnd
	While 1
		$content = StringReplace($content, @LF & @LF & @LF, @LF & @LF)
		If @extended = 0 Then ExitLoop
	WEnd
	While 1
		$content = StringReplace($content, @CRLF & @CRLF & @CRLF, @CRLF & @CRLF)
		If @extended = 0 Then ExitLoop
	WEnd
	Local $hFile = FileOpen(@ScriptDir & "\config.ini", 2)
	FileWrite($hFile, $content)
	FileClose($hFile)
EndFunc   ;==>_cleanup
