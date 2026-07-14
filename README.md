Hi there.
These codes have been developed to analyse FFN200 data acquired with a two-photon microscope in acute brain slices.
A more in-depth description can be obtained from the following published paper: 

Below is a simple description of each code:
1-2-3. Using FIJI and Python3, these codes will correct for the x,y,z drift acquired during the imaging. It will measure the Pearson Correlation of the image
       frame acquired at mid-point to the rest of the frames in the image.
4.     Using FIJI, the code will measure the fluorescent values per time-point of individual boutons
5.     Using Python3, the code will correct for bleaching, subtract the background values, and determine which boutons are destaining.
       It will generate a text file titled with the % of boutons destaining, and a wide range of figures to show the fluorescence over time 
       for each bouton, and the average of destaining and non-destaining boutons.

Sample data: this is a raw image used as a reference point to compare your own imaging and try the code.

Enjoy!
Patrick Cottilli
