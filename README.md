TESTED WITH vJoy VERSION 2.1.9.1

v1.2 build 9 unofficial 1
	Am noob, Credit to Lassie-B, for official distro visit https://github.com/Lasse-B/Sx2vJoy-test
- added button support for SpaceMouse Pro Wireless (50737, though I expect 50738 is identical and could easily be added too)
- aligned versioning to 1.2.9.1 across Sx2vJoy & Config GUI (am noob, pls halp)

TESTED WITH vJoy VERSION 2.1.6

v1.2 build 5 test 13
- added SpaceMouse Compact and SpaceMouse Enterprise support (axes only)

v1.2 build 5 test 11
- a couple of changes both to Sx2vJoy and the GUI to fix or at least help to track down the causes for crashes

v1.2 build 5 test 9
- added SpaceNavigator for Notebooks support


v1.2 build 5 test 8
- fixed controller PID not being entered in the log when logging button IDs


v1.2 build 5 test 7
- fixed startup issues when using Russian, French and likely a couple other keyboard input locales
- fixed error message when closing Sx2vJoy on controller and vJoy target device selection window


v1.2 build 5 test 6
- fixed crashes on Sx2vJoy startup on Win10
- fixed Sx2vJoy causing vJoy error message spam in Event Viewer\Windows Logs\System\
<br/>
<br/>
<br/>
<br/>
<br/>
3DConnexion's drivers and GUI are designed with professional CAD software in mind and don't work too well with games. As there is no GUI to fully customize 3DConnexion's joystick settings, you either have to manually change the configuration .XML files, or you can use Sx2vJoy and use your controller like you would any other joystick.

Here's how you get started:

1) Download and unzip Sx2vJoy

2) Download and install the open-source program vJoy:
http://vjoystick.sourceforge.net/site/index.php/download-a-install/72-download

3) Set up a vJoy stick to use the following axes setup and as many buttons as your 3DConnexion device has:
http://i.imgur.com/M8WItd1.png

4) Just run Sx2vJoy.exe








And here's how to use it:

1) Ctrl+Alt+S opens a setup dialog which walks you through setting up your 3DConnexion device in the game of your choice.

2) Ctrl+Alt+D opens an "audio feedback" setup dialog which helps you to set up your 3DConnexion device in the game of your choice. This is necessary for games that only run in true fullscreen mode as the tooltips shown during the "normal" setup mode only display when a game is running in windowed mode.

It works similarly to telephone computers. Each number you hear designates a step of the setup process:

	1 = ready to receive your axis input. Move the handle of your 3DConnexion device or quit the setup process
	2 = axis movement detected, you've got 5 seconds to click on the control in the game that you want to assign axis movement to
	3 = assign attempt complete, you should see the axis you moved in (1) has appeared in the control field you selected in (2)

	4 = setup mode ended


3) Ctrl+Alt+B enables logging mode for the button IDs. If your 3DConnexion device is not fully supported, knowing which button has which ID makes it possible to assign these buttons to vJoy buttons. Just press each button once, close the dialog by using Ctrl+Alt+B again, then post the content of Sx2vJoy.log here together with the vendor and product IDs of your controller.

4) To find out these two IDs, you can click on "Start" on the task bar and enter "dxdiag" (followed by hitting the "enter" button) in the input field. On the "Input" tab of the window that appears you'll see a couple of "DirectInput Devices". Scroll down until you see your "Space..." controller, then simply post Vendor and Product IDs here.

5) Right clicking the tray icon gives you a menu with the following items:

Open Joystick Properties leads you directly to Window's own Game Controller dialog in which you can see how vJoy and your 3DConnexion device work together.

About is for finding out what application that icon belongs to, the version number and the author.

Exit closes Sx2vJoy.
