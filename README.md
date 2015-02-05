## About 

Developed in 1950s, plaque assay started the era of the quantitative virology, allowing precise tittering and subsequent purification of infectious units from inoculae of various etiologies. However more than a means to titer viruses, *plaque assay* delivers phenotypes bearing information about the life cycle and spreading mechanism of viruses. Recent advance in automated high-throughput imaging and sCMOS camera technologies together with state-of-the-art image analysis algorithms can help harnessing this information. Here we present **Plaque2.0** – an assay framework bridging high-throughput high resolution midrange magnification imaging accompanied by image analysis software aimed at enabling researchers to maximize information they obtain from their plaque assays.
<br>
For more information visit the Plaque 2.0 website at: http://plaque2.github.io/

## Quick Guide using Sample Images Example


* Open and run plaque2GUIpc.m GUI in Matlab  (Mac: plaque2GUIpc.m, Ubuntu: plaque2GUIubuntu.m) 

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