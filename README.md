# GeoNet

GeoNet, is a interactive web application leveraging statistical inference and RShiny to detect spill event impacts on water quality. Designed for geoscience researchers, GeoNet adeptly manages vast, spatio-temporal datasets, with each polluter location comprising thousands of samples. I amde the user interface intuitive to empower users to adjust parameters in real-time, offering insight into data sensitivity and facilitating novel discoveries.

In this ReadMe, I gave a guided tutorial to use the GeoNet app through a sample spill event in Pine Creek, Lycoming. 

## Tech Stack
R, RShiny

## Steps to use the GeoNet App
1. Clone the github repository at https://github.com/amalag-19/GeoNet_App and run the R Shiny application GeoNet in RStudio. You should see a window as follows.

<img width="800" alt="image" src="https://github.com/amalag-19/GeoNet_App/assets/10363788/5f9ad54d-c6d8-4c00-885f-fb64e9ff1a4f">

2. GeoNet has three main parts,
   1) Main plot window,
   2) Sidebar panel and
   3) Top panel.
   These are labelled in the following figure.
<img width="800" alt="image" src="https://github.com/amalag-19/GeoNet_App/assets/10363788/163f4d97-01f9-4129-bd3e-cd01b25ea5aa">


3. Besides this, there is a collapse sidebar feature at the top to allow you to use this app conveniently on mobile. The top panel has an option to select the analyte that you want to explore. This could be one of the seven analytes viz. Chloride, Sodium, Bromide, Barium, Magnesium and Strontium. Let's start with the default analyte “Chloride”. Now take a look at the sidebar panel. It has several input options to specify the location and date of the spill event, set the overlay of river streams and enter the zoom level.
4. We will now explore these parameters along with additional parameters to set threshold flow distances and sampling date range in the top panel.
   1) Sidebar panel:
      
      (a) Location parameters: These parameters allow you to enter the coordinates of the spill event that you are interested to explore as longitude and latitude. If you don’t know the exact coordinates of the spill event, you may enter the approximate coordinates. The app will automatically search the nearest spill event in Pennsylvania with respect to these coordinates.
         - Enter the longitude: Here you can enter the longitude in degrees. It must be lie in the range -80.6 to -74.6. The default value is -77.3.
         - Enter the latitude: Here you can enter the longitude in degrees. It must be lie in the range -39.6 to 42.8. The default value is 41.3.
         Let us start by exploring the spill event in Pine Creek at Lycoming county. Enter the exact coordinates for this spill event with longitude as -77.32039 and latitude as 41.30454 as shown in the following figure –
         <img width="319" alt="image" src="https://github.com/amalag-19/GeoNet_App/assets/10363788/6e2c6307-cb42-4c78-ad84-39da0c310051">
      
      (b) Choose the spill date: This parameter allows you to choose the date of the spill event as shown in the figure below. If you don’t know the exact date of the spill event, you may enter an approximate date. The app will automatically search the closest spill event in Pennsylvania with respect to this date. The default date is set as Jan 1, 2012. Click on the date tab and choose the exact date for the Pine Creek spill event as Jan 6, 2012.
         <img width="454" alt="image" src="https://github.com/amalag-19/GeoNet_App/assets/10363788/d300890e-5575-4eda-b1ed-2fcbae354b8b">
      
      (c) Set the river overlay (in km): The river stream network is dense and it may take some time for the app to visualize this network on the interactive map. The river overlay parameter allows you to set the distance in km from the spill location up to which the river stream network must be plotted. The pre-set is set to 15 km which takes only 20 seconds to update. The maximum value possible is 50 km. However if you set this to 50 km, it will take more than 1 minute and 30 seconds to visualize the network. Let us keep this parameter at the default value of 15 km for now.
      (d) Enter zoom level: You may change the zoom level to explore specific regions over the interactive map. If you move the mouse pointer over the map, it will change into a hand icon. To zoom in a specific region of interest, simply click on it over the map, hold and drag it to the center. The pre-set value is 11 and it ranges from 6 to 14. You can also set the zoom level by clicking over the ‘+’ and ‘-’ located over the top left of the interactive map. Keep the default value for now.



