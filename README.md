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
         <img width="350" alt="image" src="https://github.com/amalag-19/GeoNet_App/assets/10363788/6e2c6307-cb42-4c78-ad84-39da0c310051">
      
      (b) Choose the spill date: This parameter allows you to choose the date of the spill event as shown in the figure below. If you don’t know the exact date of the spill event, you may enter an approximate date. The app will automatically search the closest spill event in Pennsylvania with respect to this date. The default date is set as Jan 1, 2012. Click on the date tab and choose the exact date for the Pine Creek spill event as Jan 6, 2012.
      
         <img width="500" alt="image" src="https://github.com/amalag-19/GeoNet_App/assets/10363788/d300890e-5575-4eda-b1ed-2fcbae354b8b">
      
      (c) Set the river overlay (in km): The river stream network is dense and it may take some time for the app to visualize this network on the interactive map. The river overlay parameter allows you to set the distance in km from the spill location up to which the river stream network must be plotted. The pre-set is set to 15 km which takes only 20 seconds to update. The maximum value possible is 50 km. However if you set this to 50 km, it will take more than 1 minute and 30 seconds to visualize the network. Let us keep this parameter at the default value of 15 km for now.
      
      (d) Enter zoom level: You may change the zoom level to explore specific regions over the interactive map. If you move the mouse pointer over the map, it will change into a hand icon. To zoom in a specific region of interest, simply click on it over the map, hold and drag it to the center. The pre-set value is 11 and it ranges from 6 to 14. You can also set the zoom level by clicking over the ‘+’ and ‘-’ located over the top left of the interactive map. Keep the default value for now.

   3) Main plot window:
      
      (a) Finally after setting all these parameters, click on the Update View button in the main plot window and wait for around 20 seconds for the app to update the 3-layered plot. After the view is updated, the located spill is plotted as a black disc on the interactive map as shown in following figure.
      
      <img width="550" alt="image" src="https://github.com/amalag-19/GeoNet_App/assets/10363788/158e062e-50ea-4c29-ba0c-2c79bfba1729">
   
      The green discs point to the sampling locations of the selected analyte (which is Chloride here) upstream to the selected spill or on unaffected streams that are flowing in the main stream eventually. The red discs point to the sampling locations downstream to the selected spill. 

      (b) Click the black disc in the center and go through the information in the pop-up. Note that the average concentration value downstream (6522.83 ppb) is significantly higher than upstream (4454.18 ppb) (Figure 4.15). This is also reflected in the one sided t test and Wilcoxon test p values. Both are 0 (less 86 than the significance level of 0.05) indicating that both mean and median of Chloride concentrations are significantly higher downstream compared to Upstream/Unaffected streams.

      <img width="550" alt="image" src="https://github.com/amalag-19/GeoNet_App/assets/10363788/a57d6d2a-e975-4a2f-87b7-6e5966491641">

      (c) Now click over one of the sampling locations represented by the green disc. You can observe the sampling location coordinates in the form of longitude and latitude and the average concentration values over time. If you repeat this procedure for few other sampling locations over Upstream/Unaffected streams and Downstream, you will notice the average concentration values over red discs are almost always higher than the green discs.

      (d) Density Plot: Now click the density plot tab. This should create a density plot as shown in the following figure. Notice that that the concentration value peaks are significantly shifted towards larger values on x axis for downstream compared to upstream. This essentially tells us that higher concentration values occur more often downstream compared to Upstream/Unaffected. Note that this reinforces our conclusion of Wilcoxon test visually.

      <img width="550" alt="image" src="https://github.com/amalag-19/GeoNet_App/assets/10363788/4dcee725-58be-45d7-8d6f-18a735f2206a">


   4) Top panel:
      
      (a) Additional parameters: Hover over the tab “Select the Threshold Flow Distances and Sampling Date Range” in the top panel. Click on the ‘+’ to expand the box as shown in the following figure –
      
         <img width="547" alt="image" src="https://github.com/amalag-19/GeoNet_App/assets/10363788/a1c0e4ab-8313-4eca-bb53-d9955ff0ee8d">

      (b) After the box is expanded, you can select the threshold flow distances and sampling date ranges as shown in the following figure.
      
         <img width="550" alt="image" src="https://github.com/amalag-19/GeoNet_App/assets/10363788/e4b0cafa-341b-4a13-a77e-2b40fdf97a6d">

         (i) Threshold Flow Distances in km: These parameters allow you to aggregate the sampling locations of Chloride only up to a certain distance in km from the spill location going along the river flow. The selected sampling locations are shown as green and red discs on the interactive map.
            - Upstream/Unaffected: This slider allows you to change the upper bound of the distance of Upstream/Unaffected sampling locations from the spill location along the river flow. The pre-set value is 10 km.
            - Downstream: This slider allows you to change both the lower and upper bounds of the distance of Downstream sampling locations from the spill location along the river flow. These are pre-set to 0 km and 50 km. This covers all observations upto 50 km downstream to the spill. Set the range as 10 km - 50 km to consider only those locations that are far from the spill location. You may observe that the red discs nearest to the black disc disappear from the plot. If you click on the black disc again, you will observe that the average concentration downstream is now 8179.63 ppb. The t-test and Wilcoxon test pvalues are still 0. This suggests that the polluting event significantly affects the downstream concentrations even in waters far away from the polluting location.
      
         (ii) Sampling Date Range: These parameters allow you to aggregate the sampling concentrations of Chloride only within a certain time period. Considering the downstream observations just after the spill and otherwise may help us to differentiate between natural causes of increase in concentrations and the spill effect.


      



