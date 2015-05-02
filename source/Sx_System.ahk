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

Run, %RunCMD%, A_ScriptDir