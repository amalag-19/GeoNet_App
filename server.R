
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(leaflet)
library(DT)

shinyServer(function(input, output) {
  #Requiring packages to plot
  withProgress(message = 'Loading map and required functions (~ 2 seconds)', style = 'notification', value = 0.1, {
    Sys.sleep(0.5)
    incProgress(0.4)
  source("shinyfunc.R")
    incProgress(0.5)
    Sys.sleep(0.5)
    setProgress(1)
  })
  require(grid)
  # Generating Plots
  
  localWindow <- reactive({
    c(input$lon,input$lat)
  })
  
  addLegendCustom <- function(map, colors, labels, sizes, layerId,opacity = 0.5){
    colorAdditions <- paste0(colors, "; width:", sizes, "px; height:", sizes, "px")
    labelAdditions <- paste0("<div style='display: inline-block;height: ", sizes, "px;margin-top: 4px;line-height: ", sizes, "px;'>", labels, "</div>")
    return(addLegend(map, colors = colorAdditions, labels = labelAdditions,layerId = layerId, opacity = opacity))
  }
  
  output$map <- renderLeaflet({
    
    # Use leaflet() here, and only include aspects of the map that
    # won't need to change dynamically (at least, not unless the
    # entire map is being torn down and recreated).
    if(input$go){
      isolate({
        # Create a Progress object
        progress <- shiny::Progress$new()
        # Make sure it closes when we exit this reactive, even if there's an error
        on.exit(progress$close())
        progress$set(message = "Updating 3-layered river network plot", value = 0.4)
        file_path <<- file_path_generator(analyte = input$analyte)
        polluter_list <- polluter_leaflet_mapper(lon = input$lon, lat = input$lat, date = input$date_PP, river_overlay_dist = input$river_overlay_dist, file_path = file_path)
        progress$inc(0.3, message = "Completed layer 2")
        river_overlay_map <<- polluter_list[['map']]
        polluter_node_ID <<- polluter_list[['polluter_node_ID']]
        polluter_lon <<- polluter_list[['polluter_lon_mapped']]
        polluter_lat <<- polluter_list[['polluter_lat_mapped']]
        polluter_county <<- polluter_list[['polluter_county']]
        polluter_volume <<- polluter_list[['polluter_volume']]
        
        map_test_list <- analyte_mapper_polluter_tester(river_overlay_map = river_overlay_map, polluter_node_ID = polluter_node_ID, polluter_projected_dist_km = input$thres_polluter_projected, upstream_threshold_dist_km = input$thres_upstream, downstream_threshold_lower_dist_km = input$thres_downstream[1], downstream_threshold_upper_dist_km = input$thres_downstream[2], spill_date = input$date_PP, upstream_date_range = input$date_upstream, downstream_date_range = input$date_downstream, file_path = file_path)
        
        progress$inc(0.3, message = "Completed layer 3")
        river_overlay_map <- map_test_list[["map"]]
        summary_upstream <<- map_test_list[["summary_upstream"]]
        summary_downstream <<- map_test_list[["summary_downstream"]]
        summary_total <<- map_test_list[["summary_total"]]
        dens_plot_1 <<- map_test_list[["density_plot_1"]]
        dens_plot_2 <<- map_test_list[["density_plot_2"]]
        dens_plot_3 <<- map_test_list[["density_plot_3"]]
        dens_plot <<- subplot(map_test_list[["density_plot_1"]], map_test_list[["density_plot_2"]], map_test_list[["density_plot_3"]], nrows = 3)
        df_analyte_nodeID_aggregated <<- map_test_list[[6]]
        #print(input$main)
        #river_overlay_map %>% addLegend("bottomleft", colors =c("#000000","green","red"), labels=c("Spill Location","Analyte Sampling Location Upstream","Analyte Sampling Location Downstream"), title="",layerId="colorLegend",opacity = 1)%>%setView(lat = polluter_lat,lng = polluter_lon,zoom = input$zoom)
        analyte_labels <- data.frame("label"=c("Cl","Na","Br","Ba","Mg","Sr"),"name"=c("Chloride","Sodium","Bromide","Barium","Magnesium","Strontium"))
        river_overlay_map %>% addLegend("bottomleft", colors =c("#000000","green","red"), labels=paste0("<div style='display: inline-block;'>", c("Spill Location ", paste0(analyte_labels[which(analyte_labels$label == input$analyte),"name"]," Sampling Location Upstream/Unaffected"),paste0(analyte_labels[which(analyte_labels$label==input$analyte),"name"]," Sampling Location Downstream")), "</div>"), title="",layerId="colorLegend",opacity = 1)%>%setView(lat = polluter_lat,lng = polluter_lon,zoom = input$zoom)
      })
    }else{
      file_path<<-file_path_generator(analyte = input$analyte)
      ## Loading the base map
      load(file = paste0(file_path,"base_map.RData"))
      base_map
    }
     # incProgress(0.5)
      #Sys.sleep(1)
     # setProgress(1)
  })
  
  output$dens_map <- renderPlotly({
    input$go
    ## Plotting scree plot for spatial clustering by K-means
    isolate({
      # Create a Progress object
      progress <- shiny::Progress$new()
      # Make sure it closes when we exit this reactive, even if there's an error
      on.exit(progress$close())
      progress$set(message = "Creating the density plot", value = 0.4)
      map_test_list <- analyte_mapper_polluter_tester(river_overlay_map = river_overlay_map,polluter_node_ID = polluter_node_ID, polluter_projected_dist_km = input$thres_polluter_projected, upstream_threshold_dist_km = input$thres_upstream,downstream_threshold_lower_dist_km = input$thres_downstream[1],downstream_threshold_upper_dist_km = input$thres_downstream[2], spill_date = input$date_PP,upstream_date_range = input$date_upstream, downstream_date_range = input$date_downstream, file_path = file_path)
      
      progress$inc(0.3, message = "Completed density plot")
      
      dens_plot <<- subplot(map_test_list[["density_plot_1"]], map_test_list[["density_plot_2"]], map_test_list[["density_plot_3"]], nrows = 3)
    })
  })
  
  output$table_summary <- renderDataTable({
    input$go2
    isolate({
      file_path_table<<-file_path_generator(analyte = input$analyte2)
      if(input$down_close_far=="near"){
        load(file = paste0(file_path_table,"inference/df_polluter_test_",input$statistic,"_10.RData"))
      }else if(input$down_close_far=="far"){
        load(file = paste0(file_path_table,"inference/df_polluter_test_",input$statistic,"_50.RData"))
      }
      eval(expr = parse(text = paste0("df_polluter_test_",input$statistic)))
    })
  })
  
  observe({
    #print(polluter_lat)
    leafletProxy("map") %>% setView(lng = input$lon, lat = input$lat, zoom = input$zoom)
  })
  
  observe({
    leafletProxy("map") %>% clearPopups()
    event <- input$map_marker_click
    #print(event$id)
    #print(event$lng)
    if (is.null(event))
      return()
    else if(grepl("polluter", event$id)){
      isolate({
        #map_test_list<-analyte_mapper_polluter_tester(river_overlay_map = river_overlay_map,polluter_node_ID = polluter_node_ID,upstream_threshold_dist_km = input$thres_upstream,downstream_threshold_lower_dist_km = input$thres_downstream[1],downstream_threshold_upper_dist_km = input$thres_downstream[2],spill_date = input$date_PP,file_path = file_path)
        #dens_plot<<-map_test_list[[3]]
        #df_analyte_nodeID_aggregated<<-map_test_list[[4]]
        leafletProxy("map") %>% addPopups(lng = event$lng, lat = event$lat, paste("County:", polluter_county, "<br/>", "Volume:", polluter_volume, "gal", "<br/>", "Longitude =", round(event$lng,5), "<br/>", "Latitude =", round(event$lat,5), "<br/>", "Average concentration upstream/unaffected =",if(is.numeric(summary_total[1])) round(summary_total[1],2) else summary_total[1], "ppb", "<br/>","Average concentration downstream =", if(is.numeric(summary_total[2])) round(summary_total[2],2) else summary_total[2], "ppb", "<br/>","Median concentration upstream/unaffected =",if(is.numeric(summary_total[3])) round(summary_total[3],2) else summary_total[3], "ppb", "<br/>","Median concentration downstream =", if(is.numeric(summary_total[4])) round(summary_total[4],2) else summary_total[4], "ppb", "<br/>","Upstream temporal Wilcoxon test p value:",if(is.numeric(summary_upstream[2])) round(summary_upstream[2],2) else summary_upstream[2],"<br/>","Downstream temporal Wilcoxon test p value:",if(is.numeric(summary_downstream[2])) round(summary_downstream[2],2) else summary_downstream[2], "<br/>", "Upstream vs. Downstream Spatial Wilcoxon test p value:",if(is.numeric(summary_total[8])) round(summary_total[8],2) else summary_total[8]))
      })
    }else if(grepl("analyte", event$id)){
      isolate(leafletProxy("map") %>% addPopups(lng=event$lng, lat=event$lat,popup = paste("Longitude =",round(event$lng,5),"<br/>","Latitude =",round(event$lat,5),"<br/>","Concentration (in ppb) =",round(df_analyte_nodeID_aggregated[which(df_analyte_nodeID_aggregated$layer==event$id),"conc"],2),"<br/>","(averaged over time)")))
      #print(df_analyte_nodeID_aggregated[which(df_analyte_nodeID_aggregated$layer==event$id),"nodeID"])
    }
  })
})
