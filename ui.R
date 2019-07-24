
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(shinythemes)
library(leaflet)
library(shinydashboard)
library(plotly)
library(DT)

###############################################################################################
header <- dashboardHeader(title="GeoNet",titleWidth = 270)

sidebar <- dashboardSidebar(
  width = 300,
  sidebarMenu(id = "main",
              menuItem(text = "Overview", 
                       tabName = "document", 
                       icon = icon("dashboard"),
                       selected = FALSE,startExpanded = FALSE),
              menuItem(text = "Tutorial", 
                       tabName = "tutorial", 
                       icon = icon("road")),
              menuItem(text = "Tabular Summary", 
                       tabName = "summary", 
                       icon = icon("star"),
                       selected = F),
              menuItem("GeoNet",
                       icon = icon('th'),
                       tabName = "geonet",
                       badgeLabel = "App",
                       badgeColor = "blue",
                       selected = TRUE,
                       startExpanded = TRUE),
                       menuSubItem(icon = NULL,tabName = "sub_lon",numericInput(inputId = 'lon',label = "Enter the longitude:", min = -80.6, max = -74.6, value = -76.96336,step = 0.1)),
                       menuSubItem(icon = NULL,tabName = "sub_lat",numericInput(inputId = 'lat',label = "Enter the latitude:", min = 39.6, max=42.8, value = 41.69899,step = 0.1)),
                       menuSubItem(icon = NULL,tabName = "sub_date",dateInput(inputId = "date_PP", label = HTML("Choose the spill date:"), min = NULL, max = NULL, value = as.Date("2010-03-22"), format = "yyyy-mm-dd")),
              menuSubItem(icon = NULL, tabName = "sub_river_overlay", sliderInput("river_overlay_dist", label ="Set the River Overlay (in km):", min = 0, max = 50, value = 15)),
              menuSubItem(icon = NULL,tabName = "sub_zoom",numericInput(inputId = "zoom", label = "Enter zoom level:", min=6, max=14, value=11))
  )
              
)

###############################################################################################
tab_documentation<-tabItem(tabName = "document",
                           h3("About"),
                           tags$ul(
                             tags$li("The application GeoNet is an easy to use and interactive web application to detect statistically significant polluting spill events based on measured concentrations of different analytes upstream and downstream.")
                             ),
                           h3("How GeoNet works"),
                           tags$ul(
                             tags$li("The app has a top panel to select the analyte, the user is interested in. This could be one of the six analytes viz. Chloride, Sodium, Bromide, Magnesium, Barium and Strontium. The default value is “Chloride”. The sidebar panel has several input options (labels highlighted in red) as follows:"),
                             tags$ol(
                               tags$li("Location parameters: These parameters allow the app to search for the nearest spill spatially in Pennsylvania. The located spill is plotted as a black disc on the interactive map."),
                               tags$ol(type="a",
                                 tags$li("Choosing the longitude: The longitude can be entered in degrees. It ranges from -80.6 to -74.6."),
                                 tags$li("Choosing the latitude: The latitude can be entered in degrees. It ranges from 39.6 to 42.8.")),
                               tags$li("Threshold flow distance parameters: These parameters allow the app to aggregate the sampling locations of the specified analyte only upto a certain distance from the spill location going along the river flow. The distances are specified in km. The selected sampling locations are shown as red discs on the interactive map.
"),
                               tags$ol(type="a",
                                       tags$li("Upstream: The lower bound is pre-set to 0 km which means the app would always take into account observations that are closest to the spill upstream. The upper bound is pre-set to the maximum value of 50 km. This value could be changed by the user to consider sampling locations only upto a certain flow distance less than 50 km.
"),
                                       tags$li("Downstream: In this case, the app allows to change both the lower and upper bounds. These are pre-set to 0 km and 10 km. This covers all observations closest to the spill downstream. The user could set the range as 10km-50km to consider only those locations that are far from the spill location.")),
                               tags$li("River overlay: This parameter corresponds to the distance from the spill upto which the river stream network must be plotted. The distance is again specified in km. Overlaying the stream network is time expensive and hence the pre-set is set to a small value of 10km. The maximum value possible is 50km. Note that for larger distances, it may take considerably more time to load the interactive map."),
                               tags$li("Choose the Date: This parameter allows the user to search for the nearest spill temporally. Note that this temporal search takes place over the spills that are already spatially closest to the location parameters chosen in the first step."),
                               tags$li("Choose zoom level: This parameter allows the user to zoom in over the interactive map. The pre-set value is 11 and it ranges from 6 to 14.  The user can also set the zoom level by clicking over the “+” and “-” located over the top left of the interactive map.")
                             ),
                             tags$li("Besides this, the user can observe the density plot by clicking over the density plot tab in the main window. This can give an idea of the relative differences in distribution of concentration values upstream vs. downstream.")
                             ),
                           h3("Acknowledgements"),
                           tags$ul(
                             tags$li("Author (alphabetical order):  Amal Agarwal, Susan Brantley, Tao Wen, Lingzhou Xue"),
                             tags$li("Maintainer:  Amal Agarwal, Lingzhou Xue"),
                             tags$li("PA Surface Water Dataset:  Alison Herman, Xianzeng Niu"),
                             tags$li("Libraries Used: shiny, shinydashboard, leaflet, plotly, network, igraph, mapdata, intergraph, sna, maps, GGally, MASS, foreach, doParallel, data.table"),
                             tags$li("Computing Resources: ~336 remote cluster computing hours at Advanced CyberInfrastructure at the Institute for CyberScience (ICS-ACI), Pennstate"),
                             tags$li("Hosted by: R Shiny Server at the Eberly College of Science, Pennstate")
                             )
)

###############################################################################################
tab_tutorial<-tabItem(tabName = "tutorial",
                           h3("Guided tutorial to explore GeoNet through Pine Creek example"),
                          tags$ul(
                            tags$li("As a demo example, the default values for location and date parameters are pre-set to observe the spill event in Pine creek at Lycoming county that occurred on Jan 6, 2012."),
                           tags$ol(
                             tags$li("Click the black disc in the center and note the average of concentration values downstream (~9.3ppm) is significantly higher than upstream (~6.5ppm). This is also reflected in the one sided t test and Wilcoxon test p values. Both are 0 (less than the significance level of 0.05) indicating that both mean and median of concentrations are significantly higher downstream compared to upstream."),
                             tags$li("Click over one of the sampling locations represented by the red disc. Can you observe the location of the sampling location in the form of longitude and latitude coordinates and average of the concentration values over time?"),
                             tags$li("Click the density plot tab and observe that the concentration value peak is significantly shifted towards larger values for downstream compared to upstream. What do you conclude from this plot? (Hint: This plot matches the conclusion from step 1)"),
                             tags$li("Change the upper bound of downstream threshold flow distance from 10 km to 50 km and lower bound from 0 km to 10 km. Repeat steps 1-3 and document your observations and conclusions. Notice the change in average concentration values between comparing upstream vs downstream close (0-10km) and upstream vs. downstream far (10-50km)."),
                             tags$li("Zoom out by setting the zoom level to 10. Set the river overlay to 30 km. Now move the map so that downstream sampling locations are roughly around the center. Zoom in back to level 11 and click over each of these red discs. How does the concentration (averaged over time) vary as you observe different sampling locations?"),
                             tags$li("Change the analyte to Sodium and repeat steps 1-5. What do you observe? How do you compare these results wih Chloride?")
                           ))
)

###############################################################################################
analyte_box <- fluidRow(
  column(width= 12, align="center",radioButtons(inputId = 'analyte', label = "Select the analyte:",choices = list("Chloride" = "Cl", "Bromide" = "Br", "Barium" = "Ba", "Magnesium" = "Mg", "Sodium" = "Na"), selected = "Cl",inline = T))
)

update_button <- actionButton(inputId = 'go',label = h4("Update View"),width = "125px",style="color: #fff; background-color: #337ab7; border-color: #2e6da4; margin: 0 auto")

update_button_row<-fluidRow(
  column(width= 12, icon("refresh"), update_button, align="center", style='padding:0px;')
)

dist_time_inputs <- fluidRow(
  column(width= 12,style='padding:5px;'),
  box(HTML("<div class= test_class>Threshold Flow Distances in km</div>"), status = "primary", solidHeader = TRUE, width = 12,
      column(width= 4,sliderInput("thres_polluter_projected", label = "Polluter to Intersections:", min = 0, max = 45, value = 30),align="center",style='padding:10px;'),
      column(width= 4,sliderInput("thres_upstream", label = "Upstream/Unaffected:", min = 0, max = 5, value = 10),align="center",style='padding:10px;'),
      column(width= 4,sliderInput("thres_downstream", label = "Downstream:", min = 0,max = 50, value = c(0, 50)),align="center",style='padding:10px;'),
      HTML("<div class= test_class>Sampling Date Range</div>"),
      column(width= 6,dateRangeInput(inputId = "date_upstream", label = HTML("Upstream/Unaffected:"), min=NULL, max=NULL, start = as.Date("1900-01-06"), end = as.Date("2018-01-06"), format = "yyyy-mm-dd"),align="center", style = 'padding:10px;'),
      column(width= 6,dateRangeInput(inputId = "date_downstream", label = HTML("Downstream:"), min=NULL, max=NULL, start = as.Date("1900-01-06"), end = as.Date("2018-01-06"), format = "yyyy-mm-dd"),align="center",style='padding:10px;'), collapsible = T, collapsed = T, title = "Set the Threshold Flow Distances and Sampling Date Range")
)

tab_plots <- tabsetPanel(type = "tabs",  tabPanel("Interactive Map", leafletOutput("map")), tabPanel("Density Plot", plotlyOutput("dens_map")))

#tab_plots <- tabBox(tabPanel("Interactive Map", leafletOutput("map")), tabPanel("Density Plot", plotlyOutput("dens_map")), width = 13)

tab_geonet <- tabItem(tabName = "geonet", h2("Pennsylvania Surface Water Analysis"), analyte_box, dist_time_inputs, tab_plots, update_button_row)

###############################################################################################
analyte_box2 <- fluidRow(
  column(width= 12, align="center", radioButtons(inputId = 'analyte2', label="Select the analyte:",choices = list("Chloride" = "Cl","Sodium" = "Na","Bromide" = "Br","Barium" = "Ba","Magnesium" = "Mg", "Strontium" = "Sr"), selected = "Cl", inline = T))
)

table_inputs <- fluidRow(
  column(width= 6,align="center",box(width=13,status = "primary",solidHeader = TRUE,radioButtons(inputId = 'down_close_far',label = "Compare upstream vs.",choices = list("Downstream Close (0-10km)" = "near","Downstream Far (10-50km)" = "far"), selected = "near"))),
  column(width= 6,align="center",box(width=13,status = "primary",solidHeader = TRUE,radioButtons(inputId = 'statistic',label = "Choose the summary statistic",choices = list("Mean" = "mean","Median" = "median"), selected = "mean")))
)

update_table <- fluidRow(
  column(width= 12,align="center",icon("refresh"),actionButton(inputId = 'go2',label = h4("Update Table"),width = "125px",style="color: #fff; background-color: #337ab7; border-color: #2e6da4; margin: 0 auto")))

table_box <- box(status = "primary",solidHeader = TRUE,width = 13,dataTableOutput('table_summary'))

tab_summary <- tabItem(tabName = "summary", h2("Tabular Summary"), analyte_box2, table_inputs, table_box, update_table)

###############################################################################################
body<- dashboardBody(tabItems(tab_documentation,tab_tutorial,tab_summary,tab_geonet),
  tags$head(tags$style(HTML('
      /* logo (dark grey) */
.skin-blue .main-header .logo {
                            background-color: #236EAF;
                            font-family: "Arial";
                            color: #FFFFFF;
                            }
                            
                            /* logo when hovered */
                            .skin-blue .main-header .logo:hover {
                            background-color: #000000;
                            }
                            
                            /* navbar (rest of the header) (dark grey) */
                            .skin-blue .main-header .navbar {
                            background-color: #236EAF;
                            }
                            
                            /* main sidebar (dark grey)*/
                            .skin-blue .main-sidebar {
                            background-color: #EEEEEE;
                            color: #EEEEEE;
                            }
                            
                            /* active selected tab in the sidebarmenu */
                            .skin-blue .main-sidebar .sidebar .sidebar-menu .active a{
                            background-color: #EEEEEE;
                            color: #000000;
                            font-weight: bold;
                            }
                            
                            /* other links in the sidebarmenu 
                            .skin-blue .main-sidebar .sidebar .sidebar-menu a{
                            background-color: #EEEEEE;
                            color: #EEEEEE;
                            font-weight: bold;
                            }*/
                            
                            /* other links in the sidebarmenu (background is light grey) */
                            .skin-blue .main-sidebar .sidebar .sidebar-menu a{
                            background-color: #EEEEEE;
                            font-family: "Arial";
                            color: #000000;
                            }
                            
                            /* other links in the sidebarmenu when hovered */
                            .skin-blue .main-sidebar .sidebar .sidebar-menu a:hover{
                            background-color: #000000;
                            color: #FFFFFF;
                            font-weight: bold;
                            }
                            
                            body, label, input, button, select {
                            font-family: "Arial";
                            }
                            
                            .content-wrapper,.right-side {
                            background-color: #ffffff;
                            }
                            
                            /* toggle button  */
                            .skin-blue .main-header .navbar .sidebar-toggle{
                            color: #FFFFFF;
                            }
                            
                            /* toggle button when hovered  */
                            .skin-blue .main-header .navbar .sidebar-toggle:hover{
                            background-color: #000000;
                            }
                            
                            .nav-tabs {
                            background-color: #EEEEEE;
                            border-color:#000000;
                            }

                            .nav-tabs-custom>.nav-tabs>li>a:hover {
                            background-color: #000000;
                            color: #FFFFFF;
                            border-radius: 0;
                            }

                            .nav-tabs-custom>.tab-content {
                            background: #FFFFFF;
                            padding: 3px;
                            border-bottom-right-radius: 1px;
                            border-bottom-left-radius: 1px;
                            border-color: #000000;
                            }
                            
                            .nav-tabs-custom .nav-tabs li.active a {
                            background-color: #F7800A;
                            border-color: #236EAF;
                            }

                            .nav-tabs-custom .nav-tabs li.active:hover a{
                            background-color: #000000;
                            color: #FFFFFF;
                            border-color: #236EAF;
                            }
                            
                            .nav-tabs-custom .nav-tabs li.active {
                            border-top-color: #236EAF;
                            }

                            .leaflet .legend i{
                            border-radius: 50%;
                            width: 10px;
                            height: 10px;
                            margin-top: 4px;
                            }
                            .test_class{color:#000000; text-align: center; font-weight: bold;}

                            .box.box-solid.box-primary>.box-header {
                            color:#000000;
                            background:#EEEEEE;
                            font-weight: bold;
                            }

                            .box.box-solid.box-primary>.box-header:hover {
                            color:#FFFFFF;
                            background:#000000;
                            font-weight: bold;
                            }
                            
                            .box.box-solid.box-primary{
                            border-bottom-color:#666666;
                            border-left-color:#666666;
                            border-right-color:#666666;
                            border-top-color:#666666;
                            background-color:#FFFFFF;
                            }

                            .box.box-solid.box-primary>.box-header .btn, .box.box-solid.box-primary                               >.box-header a {
                            color: #000000;
                            }
                            .box.box-solid.box-primary>.box-header .btn:hover {
                            color: #FFFFFF;
                            }
                            
                            .box.box-solid.box-primary>.box-header:hover a {
                            color: #FFFFFF;
                            }

                            .skin-blue .wrapper {
                             background-color: #EEEEEE;
                            }
                            
  ')))
)

shinyUI(dashboardPage(header,sidebar,body))