#########################################################################################################
## Loading required libraries
library(geosphere)
library(leaflet)
library(plotly)
library(dplyr)

#########################################################################################################
## Defining the file path
file_path_generator<-function(analyte){
  file_path <- paste0(getwd(),"/",analyte,"_spill_whole/")
  return(file_path)
}

spill_data_processed <- read.csv(file = "Spill_data_processed.csv",stringsAsFactors = F)
spill_data_processed$Date <- as.Date(spill_data_processed$Date,format ="%m/%d/%y")

#########################################################################################################
## Writing a function that can plot leaflet map of any polluter location given the latitude, longitude and date together with the base river network overlay
polluter_leaflet_mapper <- function(lon, lat, date, river_overlay_dist, file_path){
  # # ## input parameters
  # lon <- -76.96336
  # lat <- 41.69899
  # date <- as.Date(x = "3/22/10", format = "%m/%d/%y")
  # # 
  # river_overlay_dist <- 15
  
  ## Creating a box around the polluter node lon lat given
  min_lon <- lon - 0.5
  max_lon <- lon + 0.5
  min_lat <- lat - 0.5
  max_lat <- lat + 0.5
  
  ## Loading the df_node_latlong
  load(file = paste0(file_path,"common_files_modified/df_node_latlong_modified.RData"))
  ## Loading the stream_list
  load(file = paste0(file_path,"common_files_modified/stream_list_modified.RData"))
  ## Loading the total_edgelist_character
  load(file = paste0(file_path,"common_files_modified/total_edgelist_character_modified.RData"))
  ## Loading the anpoll_edgelist
  load(file=paste0(file_path,"anpoll_files/anpoll_edgelist.RData"))
  ## Loading df_polluter_processed
  load(file=paste0(file_path,"polluter_files/df_polluter_processed.RData"))
  ## Loading df_polluter_processed_appended_volume
  load(file=paste0(file_path,"polluter_files/df_polluter_processed_appended_volume.RData"))
  
  ## Setting the row ids to NULL
  row.names(df_polluter_processed) <- NULL
  
  ## Calculating the distance of given latlong with the latlong of all polluters
  dist_vec <- distm(x = t(as.matrix(c(lon,lat))),y = as.matrix(df_polluter_processed[,c("lon_mapped","lat_mapped")]))
  
  ## Getting the polluters which are closest to given latlong
  polluter_IDs <- which(dist_vec == min(dist_vec))
  date_diff_old <- Inf
  if(length(polluter_IDs) > 1){
    for (j in 1:length(polluter_IDs)){
      date_diff_new <- abs(date - df_polluter_processed[polluter_IDs[j],"date"])
      #print(df_polluter_processed[polluter_IDs[j],"date"])
      if(date_diff_new < date_diff_old){
        polluter_ID_selected <- polluter_IDs[j]
      }
      date_diff_old <- date_diff_new
    }
  }else{
    polluter_ID_selected <- polluter_IDs
  }
  
  ## Getting the polluter node ID
  polluter_node_ID <- df_polluter_processed[polluter_ID_selected, "nodeID"]
  polluter_lon <- df_polluter_processed[polluter_ID_selected, "lon_mapped"]
  polluter_lat <- df_polluter_processed[polluter_ID_selected, "lat_mapped"]
  
  ## Getting the county and water body
  polluter_county <- df_polluter_processed_appended_volume[polluter_ID_selected,"County"]
  polluter_volume <- df_polluter_processed_appended_volume[polluter_ID_selected,"Volume_Spill"]
  #polluter_water_body <- df_polluter_processed_appended_volume[polluter_ID_selected,"County"]
  
  df_polluter_processed_appended_volume %>% filter(County=="Tioga")
  
  
  ## Getting the projected nodeIDs
  ## Loading the projected_nodeIDs_list
  #load(file=paste0(file_path,"polluter_files/projected_nodeIDs_list.RData"))
  #projected_nodeIDs<-projected_nodeIDs_list[[which(names(projected_nodeIDs_list)==polluter_node_ID)[1]]]
  
  ## Getting the dist_vec which gives distance to all nodes in the base network
  dist_vec <- distm(x = as.matrix(df_polluter_processed[polluter_ID_selected,c("lon","lat")]),y = as.matrix(df_node_latlong_modified[,c("lon","lat")]))
  
  ## Getting the vector of node IDs within 20 km
  node_IDs_vec <- c(polluter_node_ID, df_node_latlong_modified$nodeID[which(dist_vec <= (river_overlay_dist*1000))])
  
  ## Getting the stream ids that span over the nodes within 50 km
  stream_subset_ids <- sort(unique(c(which(total_edgelist_character_modified[,1] %in% node_IDs_vec),which(total_edgelist_character_modified[,2] %in% node_IDs_vec))))
  
  ## Extracting the stream paths corresponding to these stream ids
  stream_sub_list <- stream_list_modified[stream_subset_ids]
  
  ## Loading the base map
  load(file = paste0(file_path,"base_map.RData"))
  ## River overlay map
  river_overlay_map <- leaflet(data = data.frame("lon" = polluter_lon,"lat" = polluter_lat)) %>% addTiles()
  #river_overlay_map<-leaflet(data = data.frame("lon"=polluter_lon,"lat"=polluter_lat))
  ## Loop to create river overlay map
  #print(length(stream_sub_list))
  for (j in 1:length(stream_sub_list)){
    river_overlay_map <- river_overlay_map %>% addPolylines(lng = stream_sub_list[[j]][,1], lat = stream_sub_list[[j]][,2], weight = 2)
  }
  river_overlay_map <- river_overlay_map %>% fitBounds(~min_lon, ~min_lat, ~max_lon, ~max_lat) %>% addCircleMarkers(lng = df_polluter_processed[polluter_ID_selected,"lon_mapped"],lat = df_polluter_processed[polluter_ID_selected,"lat_mapped"], radius = 6,color = "black",layerId = "polluter",stroke = F, fillOpacity = 0.7)#%>% addCircleMarkers(data = df_node_latlong_modified[df_node_latlong_modified$nodeID%in%projected_nodeIDs,], lng = ~lon, lat = ~lat,radius = 4,color = "green",stroke = T)
  ## Loading the spill map
  #load(file=paste0(file_path,"spill_maps/map_",polluter_ID_selected,".RData"))
  return(list("map" = river_overlay_map, "polluter_node_ID" = polluter_node_ID, "polluter_lon_mapped" = polluter_lon, "polluter_lat_mapped" = polluter_lat, "polluter_county" = polluter_county, "polluter_volume" = polluter_volume))
}

#########################################################################################################
## Writing a function to collect all from_node_IDs within the threshold flow distance with respect to given node ID
from_nodeIDs_crawler<-function(nodeID,upstream_threshold_dist_km,file_path){
  ## Loading the common edgelist total_edgelist_character_modified
  load(file = paste0(file_path,"common_files_modified/total_edgelist_character_modified.RData"))
  ## Loading the analyte-polluter network edgelist "anpoll_edgelist"
  load(file = paste0(file_path,"anpoll_files/anpoll_edgelist.RData"))
  ## Loading the "flow_dist_from_list"
  load(file = paste0(file_path,"inference/flow_dist_from_list.RData"))
  ## Collecting all from nodes that point to the polluter_nodeID
  from_edgelist_ids_total<-which(anpoll_edgelist[,2]==nodeID)
  ## Intializing from_counter_flag that becomes 1 if we could find atleast one node within the specified threshold flow distance
  from_counter_flag<-0
  ## Intializing the vector of from_nodeIDs
  from_nodeIDs<-c()
  ## If loop to check if there is atleast one node that is directed towards the specified polluter
  if(length(from_edgelist_ids_total)>0){
    ## Extracting all nodeIDs that are directed towards polluter_node_ID
    from_nodeIDs_total<-anpoll_edgelist[from_edgelist_ids_total,1]
    ## Computing the flow distance indicator vector to indicate which of these nodeIDs are within the specified threshold flow distance
    flow_dist_indicator_vec<-(flow_dist_from_list[[which(names(flow_dist_from_list)==nodeID)[1]]])<=(rep(upstream_threshold_dist_km,length(flow_dist_from_list[[which(names(flow_dist_from_list)==nodeID)[1]]])))
    ## Indexes within the "from_nodeIDs_total" vector which correspond to those nodeIDs that are within the specified threshold flow distance
    flow_dist_within_ids<-which(flow_dist_indicator_vec)
    ## Extracting the from_nodeIDs corresponding to the nodes within the specified threshold flow distance and from_edgelist_ids corresponding to row IDs in the "anpoll_edgelist" that are within specified threshold flow distance. Also updating "from_counter_flag"
    if(length(flow_dist_within_ids)>0){
      from_nodeIDs<-from_nodeIDs_total[flow_dist_within_ids]
      from_counter_flag<-1
    }else{
      from_counter_flag<-0
    }
  }
  return(list(from_nodeIDs, from_counter_flag))
}

#########################################################################################################
## Writing a function to get density plot for a particular set of two sampled observations
density_plot_gen <- function(from_obs, to_obs, from_description, to_description, plot_title){
  ## Density plots
  df_dens <- data.frame("obs" = c(from_obs, to_obs), "stream_direction" = c(rep("upstream", length(from_obs)), rep("downstream", length(to_obs))))
  fit_from <- density(from_obs)
  fit_to <- density(to_obs)
  ## Modified the fit_from dataframe considering only positive concentrations
  fit_from_modified <- data.frame("x" = rep(NA_real_, length(which(fit_from$x >= 0))), "y" = rep(NA_real_, length(which(fit_from$x >= 0))))
  fit_from_modified$x <- fit_from$x[which(fit_from$x >= 0)]
  fit_from_modified$y <- fit_from$y[which(fit_from$x >= 0)]
  
  ## Modified the fit_to dataframe considering only positive concentrations
  fit_to_modified <- data.frame("x" = rep(NA_real_, length(which(fit_to$x >= 0))), "y" = rep(NA_real_, length(which(fit_to$x >= 0))))
  fit_to_modified$x <- fit_to$x[which(fit_to$x >= 0)]
  fit_to_modified$y <- fit_to$y[which(fit_to$x >= 0)]
  
  dens_plot <- plot_ly() %>% add_lines(x = fit_from_modified$x, y = fit_from_modified$y, name = from_description) %>% add_lines(x = fit_to_modified$x, y = fit_to_modified$y,name = to_description) %>% layout(title = plot_title, xaxis = list(title = "Concentration (in ppb)", showline = TRUE, showgrid = TRUE), yaxis = list(title = "Density", showline = F, showgrid = TRUE))
  return(dens_plot)
}

#########################################################################################################
## Writing a function that can analyte sampling locations upstream and downstream and give the test results given the threhold flow distances and spill date
analyte_mapper_polluter_tester <- function(river_overlay_map, polluter_node_ID, polluter_projected_dist_km, upstream_threshold_dist_km, downstream_threshold_lower_dist_km, downstream_threshold_upper_dist_km, spill_date, upstream_date_range, downstream_date_range, file_path){
  ## Loading the analyte-polluter network edgelist "anpoll_edgelist"
  load(file = paste0(file_path,"anpoll_files/anpoll_edgelist.RData"))
  ## Loading the "flow_dist_from_list"
  load(file = paste0(file_path,"inference/flow_dist_from_list.RData"))
  ## Loading the "flow_dist_to_list"
  load(file = paste0(file_path,"inference/flow_dist_to_list.RData"))
  ## Loading the projected node IDs list
  load(file = paste0(file_path,"polluter_files/projected_nodeIDs_list.RData"))
  ## Loading the distances of polluters to projected nodes
  load(file = paste0(file_path,"polluter_files/flow_dist_polluter_projected_list.RData"))
  
  ####################################################
  ## Collecting all to nodes that are directed from the polluter_nodeID
  to_edgelist_ids_total <- which(anpoll_edgelist[,1] == polluter_node_ID)
  ## Intializing to_counter_flag that becomes 1 if we could find atleast one node within the specified threshold flow distance
  to_counter_flag <- 0
  if(length(to_edgelist_ids_total) > 0){
    ## Extracting all nodeIDs that are directed from the polluter_node_ID
    to_nodeIDs_total <- anpoll_edgelist[to_edgelist_ids_total,2]
    ## Computing the flow distance indicator vector to indicate which of these nodeIDs are within the specified threshold flow distance
    flow_dist_indicator_vec <- ((flow_dist_to_list[[which(names(flow_dist_to_list)==polluter_node_ID)]])<=(rep(downstream_threshold_upper_dist_km,length(flow_dist_to_list[[which(names(flow_dist_to_list)==polluter_node_ID)]]))))&((flow_dist_to_list[[which(names(flow_dist_to_list)==polluter_node_ID)]])>(rep(downstream_threshold_lower_dist_km,length(flow_dist_to_list[[which(names(flow_dist_to_list)==polluter_node_ID)]]))))
    ## Indexes within the "to_nodeIDs_total" vector which correspond to those nodeIDs that are within the specified threshold flow distance
    flow_dist_within_ids <- which(flow_dist_indicator_vec)
    ## Extracting the to_nodeIDs corresponding to the nodes within the specified threshold flow distance and to_edgelist_ids corresponding to row IDs in the "anpoll_edgelist" that are within specified threshold flow distance. Also updating "to_counter_flag"
    if(length(flow_dist_within_ids) > 0){
      to_nodeIDs <- to_nodeIDs_total[flow_dist_within_ids]
      to_edgelist_ids <- to_edgelist_ids_total[flow_dist_within_ids]
      to_counter_flag <- 1
    }else{
      to_counter_flag <- 0
    }
  }
  if(to_counter_flag == 1){
    to_nodeIDs <- unique(to_nodeIDs)
  }
  
  ####################################################
  ## Collecting all from nodes that point to the polluter_nodeID and corresponding projected node_IDs
  projected_nodeIDs_total <- projected_nodeIDs_list[[which(names(projected_nodeIDs_list)==polluter_node_ID)[1]]]
  
  ## Subsetting the projected node IDs based on the distances of polluter to projected
  projected_vec_ids <- which(flow_dist_polluter_projected_list[[which(names(projected_nodeIDs_list) == polluter_node_ID)[1]]] <= rep(polluter_projected_dist_km,length(projected_nodeIDs_total)))
  projected_nodeIDs_subset <- projected_nodeIDs_total[projected_vec_ids]
  
  ## Initializing the vector of from_nodeIDs containing upstream sampling nodes for the polluter node and it's projected nodes
  from_nodeIDs <- c()
  ## Intializing the from_counter_flag to know later whether there is atleast one upstream node
  from_count <- 0
  
  ## Getting the upstream nodes for polluter node ID 
  from_nodeIDs_polluter_list <- from_nodeIDs_crawler(nodeID = polluter_node_ID,upstream_threshold_dist_km = upstream_threshold_dist_km, file_path = file_path)
  from_nodeIDs <- c(from_nodeIDs,from_nodeIDs_polluter_list[[1]])
  from_count <- from_count+from_nodeIDs_polluter_list[[2]]
  
  ## Getting the upstream nodes for projected node IDs
  for(i in 1:length(projected_nodeIDs_subset)){
    from_nodeIDs_projected_list<-from_nodeIDs_crawler(nodeID = projected_nodeIDs_subset[i],upstream_threshold_dist_km = upstream_threshold_dist_km, file_path = file_path)
    if(length(to_edgelist_ids_total)>0){
      from_nodeIDs_subset<-setdiff(from_nodeIDs_projected_list[[1]],to_nodeIDs_total)
    }else{
      from_nodeIDs_subset<-from_nodeIDs_projected_list[[1]]
    }
    from_nodeIDs<-c(from_nodeIDs,from_nodeIDs_subset)
    from_count<-from_count+from_nodeIDs_projected_list[[2]]
  }
  if(length(from_nodeIDs)>0){
    from_nodeIDs<-unique(from_nodeIDs)
  }
  
  ####################################################
  ## Collecting all from and to observations within the time interval specified
  
  ## Loading the dataframe "df_node_latlong_anpoll.RData"
  load(file = paste0(file_path,"anpoll_files/df_node_latlong_anpoll.RData"))
  ## Loading the  "listID_nodeID_matrix"
  load(file = paste0(file_path,"analyte_files/listID_nodeID_matrix.RData"))
  ## Loading the  "list_analyte_time"
  load(file = paste0(file_path,"analyte_files/list_analyte_time.RData"))
  
  ## Initializing the from observation vectors upstream of given polluter node ID
  from_obs_total <- c()
  from_obs_before_spill <- c()
  from_obs_after_spill <- c()
  
  ## Initializing the to observation vectors upstream of given polluter node ID
  to_obs_total <- c()
  to_obs_before_spill <- c()
  to_obs_after_spill <- c()
  
  ## Loop to collect all from obervations within the time interval specified
  if(from_count >= 1){
    for (i in 1:length(from_nodeIDs)){
      analyte_indicator<- c("analyte")%in%(df_node_latlong_anpoll[which(df_node_latlong_anpoll$nodeID==from_nodeIDs[i]),"anpoll_indicator"])
      if(analyte_indicator){
        listID_i <- which(listID_nodeID_matrix[,2]==from_nodeIDs[i])
        ## Getting all upstream observations
        row_ids_date_interval_total<-which(between((list_analyte_time[[listID_i]]$date), upstream_date_range[1], upstream_date_range[2]))
        if(length(row_ids_date_interval_total) > 0){
          from_obs_total <- c(from_obs_total,list_analyte_time[[listID_i]]$conc[row_ids_date_interval_total])
        }
        ## Getting upstream observations before the spill date
        row_ids_date_interval_before_spill<-which(between((list_analyte_time[[listID_i]]$date), upstream_date_range[1], spill_date))
        if(length(row_ids_date_interval_before_spill)>0){
          from_obs_before_spill<-c(from_obs_before_spill,list_analyte_time[[listID_i]]$conc[row_ids_date_interval_before_spill])
        }
        ## Getting upstream observations till one year after the spill date
        spill_date_POSIX<-as.POSIXlt(spill_date)
        spill_date_POSIX$year<-spill_date_POSIX$year+1
        spill_date_after1year<-as.Date(spill_date_POSIX)
        row_ids_date_interval_after_spill<-which(between((list_analyte_time[[listID_i]]$date), spill_date, spill_date_after1year))
        if(length(row_ids_date_interval_after_spill)>0){
          from_obs_after_spill<-c(from_obs_after_spill,list_analyte_time[[listID_i]]$conc[row_ids_date_interval_after_spill])
        }
      }
    }
  }
  
  ## Loop to collect all to obervations within the time interval specified
  if(to_counter_flag == 1){
    for (i in 1:length(to_nodeIDs)){
      analyte_indicator<-c("analyte")%in%(df_node_latlong_anpoll[which(df_node_latlong_anpoll$nodeID==to_nodeIDs[i]),"anpoll_indicator"])
      if(analyte_indicator){
        listID_i<-which(listID_nodeID_matrix[,2]==to_nodeIDs[i])
        ## Getting all downstream observations with after one year spill date condition
        spill_date_POSIX<-as.POSIXlt(spill_date)
        spill_date_POSIX$year<-spill_date_POSIX$year+1
        spill_date_after1year<-as.Date(spill_date_POSIX)
        row_ids_date_interval_total<-which((between((list_analyte_time[[listID_i]]$date), downstream_date_range[1], downstream_date_range[2]))&(between((list_analyte_time[[listID_i]]$date), spill_date, spill_date_after1year)))
        if(length(row_ids_date_interval_total)>0){
          to_obs_total<-c(to_obs_total,list_analyte_time[[listID_i]]$conc[row_ids_date_interval_total])
        }
        ## Getting all downstream observations before the spill date
        row_ids_date_interval_before_spill<-which(between((list_analyte_time[[listID_i]]$date), downstream_date_range[1], spill_date))
        if(length(row_ids_date_interval_before_spill)>0){
          to_obs_before_spill<-c(to_obs_before_spill,list_analyte_time[[listID_i]]$conc[row_ids_date_interval_before_spill])
        }
        ## Getting downstream observations till one year after the spill date
        spill_date_POSIX<-as.POSIXlt(spill_date)
        spill_date_POSIX$year<-spill_date_POSIX$year+1
        spill_date_after1year<-as.Date(spill_date_POSIX)
        row_ids_date_interval_after_spill <- which(between((list_analyte_time[[listID_i]]$date), spill_date, spill_date_after1year))
        if(length(row_ids_date_interval_after_spill)>0){
          to_obs_after_spill<-c(to_obs_after_spill,list_analyte_time[[listID_i]]$conc[row_ids_date_interval_after_spill])
        }
      }
    }
  }
  
  ####################################################
  if(c("analyte") %in% (df_node_latlong_anpoll[which(df_node_latlong_anpoll$nodeID == polluter_node_ID), "anpoll_indicator"])){
    #polluter_use_flag<-0
    listID <- which(listID_nodeID_matrix[,2]==polluter_node_ID)
    ## Getting all downstream observations with after one year spill date condition
    spill_date_POSIX <- as.POSIXlt(spill_date)
    spill_date_POSIX$year <- spill_date_POSIX$year+1
    spill_date_after1year <- as.Date(spill_date_POSIX)
    row_ids_date_interval_total <- which((between((list_analyte_time[[listID]]$date), downstream_date_range[1], downstream_date_range[2])) & ((between((list_analyte_time[[listID]]$date), spill_date, spill_date_after1year))))
    if(length(row_ids_date_interval_total) > 0){
      to_obs_total <- c(to_obs_total,list_analyte_time[[listID]]$conc[row_ids_date_interval_total])
      #polluter_use_flag<-1
    }
    ## Getting all downstream observations before the spill date
    row_ids_date_interval_before_spill<-which(between((list_analyte_time[[listID]]$date), downstream_date_range[1], spill_date))
    if(length(row_ids_date_interval_before_spill) > 0){
      to_obs_before_spill <- c(to_obs_before_spill,list_analyte_time[[listID]]$conc[row_ids_date_interval_before_spill])
    }
    ## Getting downstream observations till one year after the spill date
    spill_date_POSIX <- as.POSIXlt(spill_date)
    spill_date_POSIX$year <- spill_date_POSIX$year + 1
    spill_date_after1year <- as.Date(spill_date_POSIX)
    row_ids_date_interval_after_spill <- which(between((list_analyte_time[[listID]]$date), spill_date, spill_date_after1year))
    if(length(row_ids_date_interval_after_spill) > 0){
      to_obs_after_spill <- c(to_obs_after_spill,list_analyte_time[[listID]]$conc[row_ids_date_interval_after_spill])
    }
  }
  
  ########################################################################################################
  ## First temporal test before vs. after spill date for upstream 
  if(length(from_obs_before_spill) == 0){
    from_mean_before_spill <- NA
    from_median_before_spill <- NA
  }else{
    from_mean_before_spill <- mean(from_obs_before_spill)
    from_median_before_spill <- median(from_obs_before_spill)
  }
  from_n_before_spill <- length(from_obs_before_spill)
  
  ####################################################
  if(length(from_obs_after_spill) == 0){
    from_mean_after_spill <- NA
    from_median_after_spill <- NA
  }else{
    from_mean_after_spill <- mean(from_obs_after_spill)
    from_median_after_spill <- median(from_obs_after_spill)
  }
  from_n_after_spill <- length(from_obs_after_spill)
  ####################################################
  if((from_n_before_spill > 0) & (from_n_after_spill > 0)){
    mean_diff <- from_mean_after_spill - from_mean_before_spill
    if((from_n_before_spill > 1) & (from_n_after_spill > 1)){
      if(class(try(t.test(x = from_obs_before_spill, y = from_obs_after_spill,alternative = "less")$p.value))=="try-error"){
        p_value_t.test_1sided_upstream <- t.test(x = c((from_obs_before_spill[1] + 0.01), from_obs_before_spill[-1]), y = c((from_obs_after_spill[1] + 0.01), from_obs_after_spill[-1]), alternative = "less")$p.value
      }else{
        p_value_t.test_1sided_upstream <- t.test(x = from_obs_before_spill, y = from_obs_after_spill, alternative = "less")$p.value
      }
      #p_value_wilcox.test_2sided<-wilcox.test(x = from_obs_total,y = to_obs_total)$p.value
      if(class(try(wilcox.test(x = from_obs_before_spill, y = from_obs_after_spill,alternative = "less")$p.value)) == "try-error"){
        p_value_wilcox.test_1sided_upstream <- wilcox.test(x = c((from_obs_before_spill[1] + 0.01), from_obs_before_spill[-1]), y = c((from_obs_after_spill[1] + 0.01), from_obs_after_spill[-1]), alternative = "less")$p.value
      }else{
        p_value_wilcox.test_1sided_upstream <- wilcox.test(x = from_obs_before_spill, y = from_obs_after_spill,alternative = "less")$p.value
      }
      density_plot_1 <- density_plot_gen(from_obs = from_obs_before_spill, to_obs = from_obs_after_spill, from_description = 'Upstream before event', to_description = 'Upstream till 1 yr. after', plot_title = "Comparing Upstream before event vs. <br> till 1 year after concentrations")
      test_pass_upstream <- 1
    }else{
      p_value_t.test_1sided_upstream <- NA
      #p_value_wilcox.test_2sided<-NA
      p_value_wilcox.test_1sided_upstream <- NA
      test_pass_upstream <- 0
    }
  }else{
    p_value_t.test_1sided_upstream <- NA
    #p_value_wilcox.test_2sided<-NA
    p_value_wilcox.test_1sided_upstream <- NA
    test_pass_upstream <- 0
  }
  summary_upstream <- c(p_value_t.test_1sided_upstream, p_value_wilcox.test_1sided_upstream, test_pass_upstream)
  
  ########################################################################################################
  ## Second temporal test before vs. after spill date for downstream 
  if(length(to_obs_before_spill) == 0){
    to_mean_before_spill <- NA
    to_median_before_spill <- NA
  }else{
    to_mean_before_spill <- mean(to_obs_before_spill)
    to_median_before_spill <- median(to_obs_before_spill)
  }
  to_n_before_spill <- length(to_obs_before_spill)
  
  ####################################################
  if(length(to_obs_after_spill) == 0){
    to_mean_after_spill <- NA
    to_median_after_spill <- NA
  }else{
    to_mean_after_spill <- mean(to_obs_after_spill)
    to_median_after_spill <- median(to_obs_after_spill)
  }
  to_n_after_spill <- length(to_obs_after_spill)
  ####################################################
  if((to_n_before_spill > 0) & (to_n_after_spill > 0)){
    mean_diff <- to_mean_after_spill - to_mean_before_spill
    if((to_n_before_spill > 1) & (to_n_after_spill > 1)){
      if(class(try(t.test(x = to_obs_before_spill,y = to_obs_after_spill,alternative = "less")$p.value)) == "try-error"){
        p_value_t.test_1sided_downstream <- t.test(x = c((to_obs_before_spill[1] + 0.01), to_obs_before_spill[-1]), y = c((to_obs_after_spill[1] + 0.01), to_obs_after_spill[-1]), alternative = "less")$p.value
      }else{
        p_value_t.test_1sided_downstream <- t.test(x = to_obs_before_spill,y = to_obs_after_spill,alternative = "less")$p.value
      }
      
      #p_value_wilcox.test_2sided<-wilcox.test(x = from_obs_total,y = to_obs_total)$p.value
      if(class(try(wilcox.test(x = to_obs_before_spill,y = to_obs_after_spill,alternative = "less")$p.value)) == "try-error"){
        p_value_wilcox.test_1sided_downstream <- wilcox.test(x = c((to_obs_before_spill[1] + 0.01), to_obs_before_spill[-1]), y = c((to_obs_after_spill[1] + 0.01), to_obs_after_spill[-1]), alternative = "less")$p.value
      }else{
        p_value_wilcox.test_1sided_downstream <- wilcox.test(x = to_obs_before_spill, y = to_obs_after_spill, alternative = "less")$p.value
      }
      density_plot_2 <- density_plot_gen(from_obs = to_obs_before_spill, to_obs = to_obs_after_spill, from_description = 'Downstream before event', to_description = 'Downstream till 1 yr. after', plot_title = "Comparing downstream before event vs. <br> till 1 year after concentrations")
      test_pass_downstream <- 1
    }else{
      p_value_t.test_1sided_downstream <- NA
      #p_value_wilcox.test_2sided<-NA
      p_value_wilcox.test_1sided_downstream <- NA
      test_pass_downstream <- 0
    }
  }else{
    p_value_t.test_1sided_downstream <- NA
    #p_value_wilcox.test_2sided<-NA
    p_value_wilcox.test_1sided_downstream <- NA
    test_pass_downstream <- 0
  }
  summary_downstream <- c(p_value_t.test_1sided_downstream, p_value_wilcox.test_1sided_downstream, test_pass_downstream)
  
  ########################################################################################################
  ## Third spatio-temporal test for before and after spill date upstream observations vs after spill date downstream observations.
  if(length(from_obs_total) == 0){
    from_mean_total <- NA
    from_median_total <- NA
  }else{
    from_mean_total <- mean(from_obs_total)
    from_median_total <- median(from_obs_total)
  }
  from_n_total <- length(from_obs_total)
  
  ####################################################
  if(length(to_obs_total) == 0){
    to_mean_total <- NA
    to_median_total <- NA
  }else{
    to_mean_total <- mean(to_obs_total)
    to_median_total <- median(to_obs_total)
  }
  to_n_total <- length(to_obs_total)
  ####################################################
  if((from_n_total > 0) & (to_n_after_spill > 0)){
    mean_diff <- to_mean_after_spill - from_mean_total
    if((from_n_total > 1) & (to_n_after_spill > 1)){
      if(class(try(t.test(x = from_obs_total, y = to_obs_after_spill,alternative = "less")$p.value, silent = T)) == "try-error"){
        p_value_t.test_1sided_total <- t.test(x = c(from_obs_total[1] + 0.01, from_obs_total[-1]), y = c(to_obs_after_spill[1] + 0.01, to_obs_after_spill[-1]), alternative = "less")$p.value
      }else{
        p_value_t.test_1sided_total <- t.test(x = from_obs_total, y = to_obs_after_spill, alternative = "less")$p.value
      }
      #p_value_wilcox.test_2sided<-wilcox.test(x = from_obs_total,y = to_obs_total)$p.value
      if(class(try(wilcox.test(x = from_obs_total, y = to_obs_after_spill, alternative = "less")$p.value)) == "try-error"){
        p_value_wilcox.test_1sided_total <- wilcox.test(x = c((from_obs_total[1] + 0.01), from_obs_total[-1]), y = c((to_obs_after_spill[1] + 0.01), to_obs_after_spill[-1]), alternative = "less")$p.value
      }else{
        p_value_wilcox.test_1sided_total <- wilcox.test(x = from_obs_total, y = to_obs_after_spill, alternative = "less")$p.value
      }
      
      density_plot_3 <- density_plot_gen(from_obs = from_obs_total, to_obs = to_obs_after_spill, from_description = 'Upstream/Unaffected', to_description = 'Downstream till 1 yr. after', plot_title = "Comparing Upstream/Unaffected and Downstream <br> till 1 yr. after concentrations")
      test_pass_total <- 1
    }else{
      p_value_t.test_1sided_total <- NA
      #p_value_wilcox.test_2sided<-NA
      p_value_wilcox.test_1sided_total <- NA
      test_pass_total <- 0
    }
  }else{
    p_value_t.test_1sided_total <- NA
    #p_value_wilcox.test_2sided<-NA
    p_value_wilcox.test_1sided_total <- NA
    test_pass_total <- 0
  }
  summary_total <- c(from_mean_total, to_mean_total, from_median_total, to_median_total, from_n_total, to_n_total, p_value_t.test_1sided_total, p_value_wilcox.test_1sided_total, test_pass_total)
  
  ####################################################
  ## Loading the df_anpoll_processed
  load(file = paste0(file_path,"analyte_files/df_analyte_nodeID_aggregated.RData"))
  
  ## Adding the analyte layer for leaflet marker click
  df_analyte_nodeID_aggregated$layer <- NA
  for (i in 1:nrow(df_analyte_nodeID_aggregated)){
    df_analyte_nodeID_aggregated$layer[i] <- paste0("analyte_",i)
  }
  
  ## Adding the analyte locations
  if(from_count >= 1){
    df_analyte_from_node_IDs <- df_analyte_nodeID_aggregated[which(df_analyte_nodeID_aggregated$nodeID%in%from_nodeIDs),]
    river_overlay_map <- river_overlay_map %>% addCircleMarkers(data = df_analyte_from_node_IDs, lng = ~lon_mapped, lat = ~lat_mapped,radius = 6,color = "green",layerId = ~layer,stroke = F,fillOpacity = 0.7)
  }
  if(to_counter_flag == 1){
    df_analyte_to_node_IDs <- df_analyte_nodeID_aggregated[which(df_analyte_nodeID_aggregated$nodeID%in%to_nodeIDs),]
    river_overlay_map <- river_overlay_map %>% addCircleMarkers(data = df_analyte_to_node_IDs, lng = ~lon_mapped, lat = ~lat_mapped, radius = 6, color = "red",layerId = ~layer, stroke = F, fillOpacity = 0.7)
  }
  
  return(list("map" = river_overlay_map, "summary_upstream" = summary_upstream, "summary_downstream" = summary_downstream, "summary_total" = summary_total, "density_plot_1" = density_plot_1, "density_plot_2" = density_plot_2, "density_plot_3" = density_plot_3, df_analyte_nodeID_aggregated))
}

#########################################################################################################
