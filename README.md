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
4. We will explore these parameters along with additional parameters to set threshold flow distances and sampling date range in the top panel.
