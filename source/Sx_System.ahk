/*
 * * * Compile_AHK SETTINGS BEGIN * * *

[AHK2EXE]
Exe_File=%In_Dir%\Sx_System.exe
Created_Date=1
Execution_Level=4

* * * Compile_AHK SETTINGS END * * *
*/

PsExec := A_Scriptdir "\PsExec.exe"
Parameters := " -i -d -s -w " A_ScriptDir " " A_ScriptDir "\Sx2vJoy.exe"
RunCMD := PsExec Parameters

ifnotexist, %PsExec%
{   
   msgbox, Cannot run without PsExec.exe in the same folder.`n`nSee readme.md for link.
   ExitApp
}

Run, %RunCMD%, A_ScriptDir