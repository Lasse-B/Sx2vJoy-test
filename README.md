v1.2 build 5 test 4

Another approach to fix vJoyInterface.dll not loading for some users. This time around Sx2vJoy requests admin rights right from the start.

Sx_System is also included. Its purpose is to start Sx2vJoy with system rights, but it requires PsExec.exe present in the Sx2vJoy directory. PsExec.exe is part of the PsTools and can be found here: https://technet.microsoft.com/en-us/sysinternals/bb897553.aspx