# CALCIUM IMAGING CELL IDENTIFICATION PIPELINE DOCUMENTATION 

### STEP 1: Enter Filenames 
- go to the load_drgs function in the +utils folder and enter the filenames
for your folders of interest. 
- you will need to use windows formatting for the file path names. Just go
into windows file explorer and double click the path in the text box when
you have clicked on the file you want 
- you can call the function and load your by changing the argument in load_drgs

 ### STEP 2: Load Dataset 
- right click on uitls.load_drgs to add file directories for your dataset and put it under the dataset number you wish
  to use
- run code section with appropriate dataset number in first argument
- if this is your first time running the dataset, put 'plot' into the second argument to verify that the functional images and z-stack appear to be
  properly aligned

### STEP 3: Create / load id_vect 
- either create a new id_vect where all cells are listed as "uncertain" by running code section titled "DEFAULT ID_VECT"
- or load id_vect that you have previously created 

### STEP 4: Change settings based on dataset / load figure positions 
- if you notice that the red and green images are flipped in the zstack,
change the **colororder** argument in the **SETTINGS** between 'rgb' and 'grb'  
- enter the correct number of planes in the dataset in the **nplanes** variable
- if you have previously saved your figure positions, load the **figs** structure here 

### STEP 5: Save progress / figure positions  
- MATLAB has a non-zero chance of crashing every time you close a figure, so you should save your results for the id_vect for every plane
    - additionally it is good to have a record of the id's you are categorizing for every plane in the editor
 
- you will also need to save the figure positions and have a permanently saved structure on your local path for the next time you use it
  - to do this, run prompt.main_menu, resize the figures as you want them
  - then press "W" to lock figure positions in command window
  - next press "E" to save the figures to the structure **figs**
  - save **figs** to your computer, and load next time 




