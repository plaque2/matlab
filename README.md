## Installation Guide
<br>


### Installation Mac OS X (tested on OS X 10.9 Mavericks)


* Unzip the file you have downloaded

* Before installation, open the "Security & Privacy" pane by clicking "Security & Privacy". Make sure that the "General" tab is selected. Click the icon labeled "Click the lock to make changes". Enter your username and password into the prompt that appears and click "Unlock". Under the section labeled "Allow applications downloaded from:", select Anywhere. On the prompt that appears, click "Allow From Anywhere". Exit System Preferences by clicking the red button in the upper left of the window.

* Run Plaque2_mcr for offline and Plaque2_web for online installation 
This should start the setup application. The wait time will vary depending on the machine you are using.
 
* Press next  


* Specify the path to install Plaque2.0 software to and press next. By default the application is installed into /Applications/Plaque2 folder


* Specify the path  to install MATLAB Runtime Compiler (MCR) which is required for Plaque2.0 installation(default path /Applications/MATLAB/MATLAB_Compiler_Runtime ). If you have chosen 
Plaque2_web installer MCR will start downloading automatically.


* Choose yes to agree to the Licence Agreement and press next


* Press Install to start the installation and wait for it to complete. 


* Press finish to close the installer

<br><br>
### Installation Windows (tested on 7, 8 and 8.1 64-bit systems)


* Unzip the file you have downloaded


* Run Plaque2_mcr for offline and Plaque2_web for online installation - the "User Account Control" will promt you to make changes to your computer - click "Yes". This should start the setup application. The wait time will vary depending on the machine you are using.
 
* Press next.


* Specify the path to install Plaque2.0 software to and press next. By default the application is installed into /Program Files/Plaque2 folder


* Specify the path  to install MATLAB Runtime Compiler (MCR) which is required for Plaque2.0 installation(default path C:\Program Files\MATLAB\MATLAB Compiler Runtime). If you have chosen Plaque2_web installer MCR will start downloading automatically.


* Choose yes to agree to the Licence Agreement and press next


* Press Install to start the installation and wait for it to complete. 


* Press finish to close the installer


<br><br>
### Installation Ubuntu (tested on 13.10 64-bit system)


* Unzip the file you have downloaded

* Open new terminal window and change the current folder to the folder where the downloaded files where unzipped isng the 'cd' bash command. Run  'sudo /Plaque2_mcr.install' for offline and 'sudo Plaque2_web.install' for online installation.This will require to type in the root password. The installation time will vary depending on the machine you are using.
 
* Press next.


* Specify the path to install Plaque2.0 software to and press next. By default the application is installed into /usr/Plaque2 folder


* Specify the path  to install MATLAB Runtime Compiler (MCR) which is required for Plaque2.0 installation(default path /usr/local/MATLAB/MATLAB_Compiler_Runtime). If you have chosen Plaque2_web installer MCR will start downloading automatically.


* Choose yes to agree to the Licence Agreement and press next


* Press Install to start the installation and wait for it to complete. 


* Press finish to close the installer

* Edit .profile file. By default you can use gedit software for that purpose with 'gedit .profile' command.

* Add the following lines to the end of this file. If MCR wasn't installed into the default folder replace 'usr/local/MATLAB/MATLAB_Compiler_Runtime' with the folder that 

#### MATLAB MCR
```
export LD_LIBRARY_PATH=/usr/local/MATLAB/MATLAB_Compiler_Runtime/v83/bin/glnxa64
export XAPPLRESDIR=/usr/local/MATLAB/MATLAB_Compiler_Runtime/v83/X11/app-defaults
```
```
export PATH=$PATH:$LD_LIBRARY_PATH
export PATH=$PATH:$XAPPLRESDIR
```
* Invoke following code in the terminal to make sure that Ubuntu bug doesn't re-write your variable:
```
    echo STARTUP=\"/usr/bin/env LD_LIBRARY_PATH=\${LD_LIBRARY_PATH} \${STARTUP}\" | sudo tee /etc/X11/Xsession. /90preserve_ld_library_path
```
*Restart the computer

* open terminal and change to the Plaque2 installation folder by default to /usr/Plaque2

* run 
```
sudo 'chmod -R 777 application/'
```

## Quick Guide using Sample Images Example


* Open Plaque2.app (Windows: Plaque2.exe, Linux: ./Plaque2 in terminal) from the installed path (default path OS X: /Applications/Plaque2/application/Plaque2.app, Windows: C:\Program Files\Plaque2\application, Linux: /usr/Plaque2).


* Wait for the software to load. The wait time will vary depending on the machine you are using. Software will load with already optimized parameters for sample images.


* Once the Plaque2.0 window appears you can test the workflow of Plaque2.0 on the embedded sample data in following steps for each of the modules:


* __Stitching__
  1. Activate the checkbox at the "Stitch" module in the upper left part of the window and press the button "Stitch" located to the right of the checkbox.
  2. Press "Test Settings" button located below the panel to the right of the "Stitch" button - a new window will open.
  3. In the new window press "Go To" button - the image from the selected well demonstrating the result of stitching will appear.


* __Mask__
  1. Activate the checkbox at the "Mask" module in the upper left part of the window and press the button "Mask" located to the right of the checkbox.
  2. In the panel to the right of the button select the image masking method, e.g. "Load Custom Mask" 
  3. Press "Test Settings" button located below the panel - a new window will open.
  4. In the new window press "Go To" button - the image from the selected well demonstrating the result of image masking will appear as semi-transparent red overlay on top of the original image.


* __Monolayer__
  1. Activate the checkbox at the "Monolayer" module in the upper left part of the window and press the button "Monolayer" located to the right of the checkbox.
  2. In the panel to the right of the button select the thresholding method, e.g. "Otsu Global Thresholding" 
  3. Press "Test Settings" button located below the panel - a new window will open.
  4. In the new window press "Go To" button - the image from the selected well demonstrating the result of pixel segmentation will appear as semi-transparent blue overlay on top of the original image.


* __Plaque__
  1. Activate the checkbox at the "Plaque" module in the upper left part of the window and press the button "Plaque" located to the right of the checkbox.
  2. In the dropdown (w1, w2 etc.) located in the upper right part of the panel to the right of the button select the wavelength of the plaque images - in our case w2 
  3. Press "Test Settings" button located below the panel - a new window will open.
  4. In the new window press "Go To" button - the image from the selected well demonstrating the result of plaque detection will appear as semi-transparent green overlay on top of the original image with red spots indicating detected "centers of mass" of the plaques.


<br>
<br>
<br>
***
####            Copyright (C) 2015 Artur Yakimovich and Vardan Andriasyan
<br>