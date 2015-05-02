#include-once

;#AutoIt3Wrapper_au3check_parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w- 7

; #INDEX# =======================================================================================================================
; Title .........: Marquee
; Description ...: This module contains functions to create and manage marquee controls
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_GUICtrlMarquee_Init       : Initialises a Marquee control
;_GUICtrlMarquee_SetScroll  : Sets movement parameters for Marquee
;_GUICtrlMarquee_SetDisplay : Sets display parameters for Marquee
;_GUICtrlMarquee_Create     : Creates Marquee
;_GUICtrlMarquee_Delete     : Deletes a marquee control
;_GUICtrlMarquee_Reset      : Resets a marquee control to current parameters
; ===============================================================================================================================

; #INTERNAL_USE_ONLY#============================================================================================================
;================================================================================================================================

; #INCLUDES# ====================================================================================================================

; #GLOBAL VARIABLES# ============================================================================================================
; Array to hold Marquee parameters
Global $aMarquee_Params[1][13] = [[0, 0, 0, "scroll", "left", 6, 85, 0, 0, 0, 12, "Tahoma", ""]]
; [0][0]  = Count                [n][0]  = ControlID
; [0][1]                        [n][1]  = Obj Ref
; [0][2]  = Def loop state        [n][2]  = Loop state
; [0][3]  = Def move state        [n][3]  = Move state
; [0][4]  = Def move dirn        [n][4]  = Move dirn
; [0][5]  = Def scroll speed    [n][5]  = Scroll speed
; [0][6]  = Def delay time        [n][6]  = Delay time
; [0][7]  = Def border state    [n][7]  = Border state
; [0][8]  = Def text colour        [n][8]  = Text colour
; [0][9]  = Def back colour        [n][9]  = Back colour
; [0][10] = Def font family        [n][10] = Font size
; [0][11] = Def font size        [n][11] = Font family
; [0][12]                        [n][12] = Text

; Get system text and background colours
Global $aMarquee_Colours_Ret = DllCall("User32.dll", "int", "GetSysColor", "int", 8)
$aMarquee_Params[0][8] = BitAND(BitShift(String(Binary($aMarquee_Colours_Ret[0])), 8), 0xFFFFFF)
$aMarquee_Colours_Ret = DllCall("User32.dll", "int", "GetSysColor", "int", 5)
$aMarquee_Params[0][9] = BitAND(BitShift(String(Binary($aMarquee_Colours_Ret[0])), 8), 0xFFFFFF)

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMarquee_Init
; Description ...: Initialises UDF prior to creating a Marquee control
; Syntax.........: _GUICtrlMarquee_Init()
; Parameters ....: None
; Return values .: Index of marquee to be passed to other _GUICtrlMarquee functions
; Author ........: Melba 23
; Related .......: Other _GUICtrlMarquee functions
; Link ..........;
; Example .......; Yes
; ===============================================================================================================================

Func _GUICtrlMarquee_Init()

    ; Add a new line to the array
    $aMarquee_Params[0][0] += 1
    ReDim $aMarquee_Params[$aMarquee_Params[0][0] + 1][13]
    ; Copy over the default values
    For $i = 2 To 12
        $aMarquee_Params[$aMarquee_Params[0][0]][$i] = $aMarquee_Params[0][$i]
    Next
    ; Return index of marquee in array
    Return $aMarquee_Params[0][0]

EndFunc   ;==>_GUICtrlMarquee_Init

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMarquee_SetScroll
; Description ...: Sets movement parameters for a Marquee
; Syntax.........: _GUICtrlMarquee_SetScroll($iIndex, [$iLoop, [$sMove, [$sDirection, [$iScroll, [$iDelay]]]]])
; Parameters ....: $iIndex       - Index of marquee returned by _GUICtrlMarquee_Init
;                  $iLoop        - [optional] Number of loops to repeat. (Default = infinite, -1 = leave unchanged)
;                                      Use "slide" movement to keep text visible after stopping
;                  $sMove        - [optional] Movement of text.  From  "scroll" (Default), "slide" and "alternate". (-1 = leave unchanged)
;                  $sDirection   - [optional] Direction of scrolling.  From "left" (Default), "right", "up" and "down". (-1 = leave unchanged)
;                  $iScroll      - [optional] Distance of each advance - controls speed of scrolling (Default = 6, -1 = leave unchanged)
;                                      Higher numbers increase speed, lower numbers give smoother animation.
;                  $iDelay       - [optional] Time in milliseconds between each advance (Default = 85, -1 = leave unchanged)
;                                      Higher numbers lower speed, lower numbers give smoother animation.
; Return values .: Success - Returns 1
;                  Failure - Returns 0 and sets @error to 1 - @extended set to index of parameter with error
; Author ........: Melba 23
; Related .......: Other _GUICtrlMarquee functions
; Link ..........;
; Example .......; Yes
; ===============================================================================================================================

Func _GUICtrlMarquee_SetScroll($iIndex, $iLoop = Default, $sMove = Default, $sDirection = Default, $iScroll = Default, $iDelay = Default)

    ; Errorcheck and set parameters
    Switch $iIndex
        Case 1 To $aMarquee_Params[0][0]
            $iIndex = Int($iIndex)
        Case Else
            Return SetError(1, 1, 0)
    EndSwitch

    Switch $iLoop
        Case -1
            ; No change
        Case Default
            $aMarquee_Params[$iIndex][2] = $aMarquee_Params[0][2]
        Case Else
            If IsNumber($iLoop) Then
                $aMarquee_Params[$iIndex][2] = Int(Abs($iLoop))
            Else
                Return SetError(1, 2, 0)
            EndIf
    EndSwitch

    Switch $sMove
        Case -1
            ; No change
        Case "scroll", 'alternate', 'slide'
            $aMarquee_Params[$iIndex][3] = $sMove
        Case Default
            $aMarquee_Params[$iIndex][3] = $aMarquee_Params[0][3]
        Case Else
            Return SetError(1, 3, 0)
    EndSwitch

    Switch $sDirection
        Case -1
            ; No change
        Case 'left', 'right', 'up', 'down'
            $aMarquee_Params[$iIndex][4] = $sDirection
        Case Default
            $aMarquee_Params[$iIndex][4] = $aMarquee_Params[0][4]
        Case Else
            Return SetError(1, 4, 0)
    EndSwitch

    Switch $iScroll
        Case -1
            ; No change
        Case Default
            $aMarquee_Params[$iIndex][5] = $aMarquee_Params[0][5]
        Case Else
            If IsNumber($iScroll) Then
                $aMarquee_Params[$iIndex][5] = Int(Abs($iScroll))
            Else
                Return SetError(1, 5, 0)
            EndIf
    EndSwitch

    Switch $iDelay
        Case -1
            ; No change
        Case Default
            $aMarquee_Params[$iIndex][6] = $aMarquee_Params[0][6]
        Case Else
            If IsNumber($iDelay) Then
                $aMarquee_Params[$iIndex][6] = Int(Abs($iDelay))
            Else
                Return SetError(1, 6, 0)
            EndIf
    EndSwitch

    Return 1

EndFunc   ;==>_GUICtrlMarquee_SetScroll

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMarquee_SetDisplay
; Description ...: Sets display parameters for subsequent _GUICtrlCreateMarquee calls
; Syntax.........: _GUICtrlMarquee_SetDisplay($iIndex, [$iBorder, [$vTxtCol, [$vBkCol, [$iPoint, [$sFont]]]])
; Parameters ....: $iIndex  - Index of marquee returned by _GUICtrlMarquee_Init
;                  $iBorder - [optional] 0 = None (Default), 1 = 1 pixel, 2 = 2 pixel, 3 = 3 pixel (-1 = no change)
;                  $vTxtCol - [optional] Colour for text (Default = system colour, -1 = no change)
;                  $vBkCol  - [optional] Colour for Marquee (Default = system colour, -1 = no change)
;                             Colour can be passed as RGB value or as one of the following strings:
;                                'black', 'gray', 'white', 'silver', 'maroon', 'red', 'purple', 'fuchsia',
;                                'green', 'lime', 'olive', 'yellow', 'navy', 'blue', 'teal', 'aqua'
;                  $iPoint  - [optional] Font size (Default = 12, -1 = unchanged)
;                  $sFont   - [optional] Font to use (Default = Tahoma, "" = unchanged)
; Return values .: Success - Returns 0
;                  Failure - Returns 0 and sets @error to 1 - @extended set to index of parameter with error
; Author ........: Melba 23
; Related .......: Other _GUICtrlMarquee functions
; Link ..........;
; Example .......; Yes
; ===============================================================================================================================

Func _GUICtrlMarquee_SetDisplay($iIndex, $iBorder = Default, $vTxtCol = Default, $vBkCol = Default, $iPoint = Default, $sFont = Default)

    ; Errorcheck and set parameters
    Switch $iIndex
        Case 1 To $aMarquee_Params[0][0]
            $iIndex = Int($iIndex)
        Case Else
            Return SetError(1, 1, 0)
    EndSwitch

    Switch $iBorder
        Case -1
            ; No change
        Case Default
            $aMarquee_Params[$iIndex][7] = $aMarquee_Params[0][7]
        Case 0 To 3
            $aMarquee_Params[$iIndex][7] = Int($iBorder)
        Case Else
            Return SetError(1, 2, 0)
    EndSwitch

    Switch $vTxtCol
        Case -1
            ; No change
        Case Default
            $aMarquee_Params[$iIndex][8] = $aMarquee_Params[0][8]
        Case Else
            If Number($vTxtCol) Then
                $aMarquee_Params[$iIndex][8] = Int(Number($vTxtCol))
            Else
                $aMarquee_Params[$iIndex][8] = $vTxtCol
            EndIf
    EndSwitch

    Switch $vBkCol
        Case -1
            ; No change
        Case Default
            $aMarquee_Params[$iIndex][9] = $aMarquee_Params[0][9]
        Case Else
            If Number($vBkCol) Then
                $aMarquee_Params[$iIndex][9] = Int(Number($vBkCol))
            Else
                $aMarquee_Params[$iIndex][9] = $vBkCol
            EndIf
    EndSwitch

    Switch $iPoint
        Case -1
            ; No change
        Case Default
            $aMarquee_Params[$iIndex][10] = $aMarquee_Params[0][10]
        Case Else
            If IsNumber($iPoint) Then
                $aMarquee_Params[$iIndex][10] = Int(Abs($iPoint / .75))
            Else
                Return SetError(1, 5, 0)
            EndIf
    EndSwitch

    Switch $sFont
        Case ""
            ; No change
        Case Default
            $aMarquee_Params[$iIndex][11] = $aMarquee_Params[0][11]
        Case Else
            If IsString($sFont) Then
                $aMarquee_Params[$iIndex][11] = $sFont
            Else
                Return SetError(1, 5, 0)
            EndIf
    EndSwitch

    Return 1

EndFunc   ;==>_GUICtrlMarquee_SetDisplay

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMarquee_Create
; Description ...: Creates a marquee control
; Syntax.........: _GUICtrlMarquee_Create($iIndex, $sText, $iLeft, $iTop, $iWidth, $iHeight, [$sTipText])
; Parameters ....: $iIndex  - Index of marquee returned by _GUICtrlMarquee_Init
;                  $sText   - The text (or HTML markup) the marquee should display.
;                  $iLeft   - The left side of the control.
;                  $iTop    - The top of the control.
;                  $iWidth  - The width of the control.
;                  $iHeight - The height of the control.
;                  $sTipTxt - [optional] Tip text displayed when mouse hovers over the control.
; Return values .: Success - Returns 1
;                  Failure - Returns 0 and sets @error as follows
;                                    1 = Invalid index
;                                    2 = Index already used
;                                    3 = Failed to create object
;                                    4 = Failed to embed object
; Author ........: james3mg, trancexx and jscript "FROM BRAZIL"
; Modified.......: Melba23
; Remarks .......: This function attempts to embed an 'ActiveX Control' or a 'Document Object' inside the GUI.
;                  The GUI functions GUICtrlRead and GUICtrlSet have no effect on this control. The object can only be
;                  controlled using other _GUICtrlMarquee functions
; Related .......: Other _GUICtrlMarquee functions
; Link ..........;
; Example .......; Yes
; ===============================================================================================================================

Func _GUICtrlMarquee_Create($iIndex, $sText, $iLeft, $iTop, $iWidth, $iHeight, $sTipText = "")

    ; Errorcheck index
    Switch $iIndex
        Case 1 To $aMarquee_Params[0][0]
            $iIndex = Int($iIndex)
        Case Else
            Return SetError(1, 0, 0)
    EndSwitch

    ; Check not previously created
    If $aMarquee_Params[$iIndex][1] <> "" Then
        Return SetError(2, 0, 0)
    EndIf

    ; Store text
    $aMarquee_Params[$iIndex][12] = $sText

    ; Create marquee
    Local $oShell = ObjCreate("Shell.Explorer.2")
    If Not IsObj($oShell) Then
        Return SetError(3, 0, 0)
    Else
        $aMarquee_Params[$iIndex][1] = $oShell
    EndIf
    $aMarquee_Params[$iIndex][0] = GUICtrlCreateObj($oShell, $iLeft, $iTop, $iWidth, $iHeight)
    If $aMarquee_Params[$iIndex][0] = 0 Then
        Return SetError(4, 0, 0)
    EndIf

    ; Wait for marquee to be created
    $oShell.navigate("about:blank")
    While $oShell.busy
        Sleep(100)
    WEnd

    ; Add marquee content
    With $oShell.document
        .write('<style>marquee{cursor: default}></style>')
        .write('<body onselectstart="return false" oncontextmenu="return false" onclick="return false" ondragstart="return false" ondragover="return false">')
        .writeln('<marquee width=100% height=100%')
        .writeln("loop=" & $aMarquee_Params[$iIndex][2])
        .writeln("behavior=" & $aMarquee_Params[$iIndex][3])
        .writeln("direction=" & $aMarquee_Params[$iIndex][4])
        .writeln("scrollamount=" & $aMarquee_Params[$iIndex][5])
        .writeln("scrolldelay=" & $aMarquee_Params[$iIndex][6])
        .write(">")
        .write($sText)
        .body.title = $sTipText
        .body.topmargin = 0
        .body.leftmargin = 0
        .body.scroll = "no"
        .body.style.borderWidth = $aMarquee_Params[$iIndex][7]
        .body.style.color = $aMarquee_Params[$iIndex][8]
        .body.bgcolor = $aMarquee_Params[$iIndex][9]
        .body.style.fontSize = $aMarquee_Params[$iIndex][10]
        .body.style.fontFamily = $aMarquee_Params[$iIndex][11]
    EndWith

    Return 1

EndFunc   ;==>_GUICtrlMarquee_Create

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMarquee_Delete
; Description ...: Deletes a marquee control
; Syntax.........: _GUICtrlMarquee_Delete($iIndex)
; Parameters ....: $iIndex - Index of marquee returned by _GUICtrlMarquee_Init
; Return values .: Success - Returns 1
;                  Failure - Returns 0 and sets @error to 1
; Author ........: Melba23
; Remarks .......:
; Related .......: Other _GUICtrlMarquee functions
; Link ..........;
; Example .......; Yes
; ===============================================================================================================================

Func _GUICtrlMarquee_Delete($iIndex)

    ; Errorcheck index
    Switch $iIndex
        Case 1 To $aMarquee_Params[0][0]
            $iIndex = Int($iIndex)
        Case Else
            Return SetError(1, 0, 0)
    EndSwitch

    ; Remove that entry from the array
    GUICtrlDelete($aMarquee_Params[$iIndex][0])
    For $i = $iIndex To $aMarquee_Params[0][0] - 1
        For $j = 0 To UBound($aMarquee_Params, 2) - 1
            $aMarquee_Params[$i][$j] = $aMarquee_Params[$i + 1][$j]
        Next
    Next
    ReDim $aMarquee_Params[$aMarquee_Params[0][0]][13]
    $aMarquee_Params[0][0] -= 1

    ; Redraw the other marquees
    For $i = 1 To $aMarquee_Params[0][0]
        _GUICtrlMarquee_Reset($i)
    Next

EndFunc   ;==>_GUICtrlMarquee_Delete

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMarquee_Reset
; Description ...: Resets a marquee control to current parameters
; Syntax.........: _GUICtrlMarquee_Reset($iIndex, $sText)
; Parameters ....: $iIndex - Index of marquee returned by _GUICtrlMarquee_Init
;                  $sText  - The text (or HTML markup) the marquee should display (Default leaves text unchanged)
; Return values .: Success - Returns 1
;                  Failure - Returns 0 and sets @error as follows
;                                    1 = Invalid index
;                                    2 = Invalid object reference
; Author ........: rover
; Modified.......: Melba23
; Remarks .......:
; Related .......: Other _GUICtrlMarquee functions
; Link ..........;
; Example .......; Yes
; ===============================================================================================================================

Func _GUICtrlMarquee_Reset($iIndex, $sText = Default)

    ; Errorcheck index
    Switch $iIndex
        Case 1 To $aMarquee_Params[0][0]
            $iIndex = Int($iIndex)
        Case Else
            Return SetError(1, 0, 0)
    EndSwitch

    ; Retrieve object reference
    $oShell = $aMarquee_Params[$iIndex][1]
    If Not IsObj($oShell) Then
        Return SetError(2, 0, 0)
    EndIf

    If $sText <> Default Then
        $aMarquee_Params[$iIndex][12] = $sText
    EndIf

    $oShell.document.body.innerHTML = '<body onselectstart="return false" oncontextmenu="return false" onclick="return false" ' & _
        'ondragstart="return false" ondragover="return false"> ' & _
        '<marquee width=100% height=100% ' & "loop=" & $aMarquee_Params[$iIndex][2] & _
        " behavior=" & $aMarquee_Params[$iIndex][3] & _
        " direction=" & $aMarquee_Params[$iIndex][4] & _
        " scrollamount=" & $aMarquee_Params[$iIndex][5] & _
        " scrolldelay=" & $aMarquee_Params[$iIndex][6] & _
        ">" & $aMarquee_Params[$iIndex][12]
    With $oShell.document
        .body.style.borderWidth = $aMarquee_Params[$iIndex][7]
        .body.style.color = $aMarquee_Params[$iIndex][8]
        .body.bgcolor = $aMarquee_Params[$iIndex][9]
        .body.style.fontSize = $aMarquee_Params[$iIndex][10]
        .body.style.fontFamily = $aMarquee_Params[$iIndex][11]
    EndWith

    Return 1

EndFunc   ;==>_GUICtrlMarquee_SetText