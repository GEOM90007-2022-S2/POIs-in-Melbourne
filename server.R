# Importing libraries
library(shiny)
library(stringr)
library(shinythemes)
library(fontawesome)
library(shinydashboard)
library(igraph)
library(highcharter)
library(dplyr)
library(tidyr)
library(dashboardthemes)
source('helper.R')

# Set a global theme highcharter plot
options(highcharter.theme = hc_theme_hcrt())

shinyServer(function(input, output) {
  
  # Output Graph of Map
  output$mymap <- renderLeaflet({
    leaflet() %>% setView(lat= -37.840935, lng = 144.946457, zoom = 11) %>%
      addProviderTiles(providers$CartoDB.Voyager,
                       options = providerTileOptions(noWrap = TRUE))
  })
  
  
  # Output Graph of POI
  output$poi_viz <- renderLeaflet({
    leaflet() %>%
      setView(lat= -37.8080, lng = 144.946457, zoom = 13.5) %>%
      addProviderTiles(providers$CartoDB.Voyager,
                       options = providerTileOptions(noWrap = TRUE)) %>%
      
      # Add marker for different categories of location
      addMarkers(data = landmark_data, ~long, ~lat, icon = landmarkIcon,
                 label = landmarkLabels, group = "<img src='landmark.png' height='16' width='16'> Landmark") %>%
      addMarkers(data = gallery_data, ~long, ~lat, icon = museumIcon,
                 label = galleryLabels, group = "<img src='museum.png' height='16' width='16'> Gallery/Museum/Library") %>%
      addMarkers(data = church_data, ~long, ~lat, icon = churchIcon,
                 label = churchLabels, group = "<img src='church.png' height='16' width='16'> Place of Worship") %>%
      addMarkers(data = retail_data, ~long, ~lat, icon = retailIcon,
                 label = retailLabels, group = "<img src='retail.png' height='16' width='16'> Retail") %>%
      addMarkers(data = leisure_data, ~long, ~lat, icon = leisureIcon,
                 label = leisureLabels, group = "<img src='leisure.png' height='16' width='16'> Leisure and Recreation") %>%
      addMarkers(data = visitorcenter_data, ~long, ~lat, icon = visitorcentreIcon,
                 label = visitorcenterLabels, group = "<img src='information.png' height='16' width='16'> Visitor Information Booth<hr><strong>Utilities</strong>") %>%
      addMarkers(data = wifi_data, ~Longitude, ~Latitude, 
                 icon = wifiIcon, group = "<img src='wifi.png' height='16' width='16'> Public Wifi Location") %>%
      addMarkers(data = city_circle, ~long, ~lat, icon = tramIcon,
                 label = ~NAME, group = "<img src='tram.png' height='16' width='16'> City Circle Tourist Tram") %>%
      addMarkers(data = toilet_data, ~lon, ~lat, icon = toiletIcon,
                 label = ~name, group = "<img src='toilet.png' height='16' width='16'> Public Toilet") %>%
      addMarkers(data = fountain_data, ~lon, ~lat, icon = fountainIcon,
                 label = ~Description, group = "<img src='fountain.png' height='16' width='16'> Drinking Fountain") %>%
      addPolylines(data = tram_track, group = "<img src='track.png' height='16' width='16'> Tram Route",
                   opacity = 0.5) %>%
      # Add layer control for user filter
      addLayersControl(
        overlayGroups = c("<img src='landmark.png' height='16' width='16'> Landmark",
                          "<img src='museum.png' height='16' width='16'> Gallery/Museum/Library",
                          "<img src='church.png' height='16' width='16'> Place of Worship",
                          "<img src='retail.png' height='16' width='16'> Retail",
                          "<img src='leisure.png' height='16' width='16'> Leisure and Recreation",
                          "<img src='information.png' height='16' width='16'> Visitor Information Booth<hr><strong>Utilities</strong>",
                          "<img src='wifi.png' height='16' width='16'> Public Wifi Location",
                          "<img src='fountain.png' height='16' width='16'> Drinking Fountain",
                          "<img src='toilet.png' height='16' width='16'> Public Toilet",
                          "<img src='tram.png' height='16' width='16'> City Circle Tourist Tram",
                          "<img src='track.png' height='16' width='16'> Tram Route"),
        options = layersControlOptions(collapsed = FALSE)
      ) %>%
      # Hide groups to keep the interface clean
      hideGroup("<img src='wifi.png' height='16' width='16'> Public Wifi Location") %>%
      hideGroup("<img src='tram.png' height='16' width='16'> City Circle Tourist Tram") %>%
      hideGroup("<img src='track.png' height='16' width='16'> Tram Route") %>%
      hideGroup("<img src='fountain.png' height='16' width='16'> Drinking Fountain") %>%
      hideGroup("<img src='toilet.png' height='16' width='16'> Public Toilet")
  })
  
  
  # Output Graph of weather
  output$weather_plot <- renderHighchart({
    
    # Process Data
    maxTemp_data$Quality_max <- maxTemp_data$Quality
    minTemp_data$Quality_min <- minTemp_data$Quality
    temp.data <- maxTemp_data %>% left_join(minTemp_data, by = 'Date') %>% filter(input$dates[1]<=Date & Date<=input$dates[2])
    temp.data$maxTemp = temp.data$Maximum.temperature..Degree.C.
    temp.data$minTemp = temp.data$Minimum.temperature..Degree.C.
    rainfall <- rainfall_data %>% filter(input$dates[1]<=Date & Date<=input$dates[2])
  
    col <- c("#eb8787", "#87CEEB")
    highchart() %>%
      hc_title(text = "Daily Maximum & Minimum Temperature") %>%
      hc_add_series(temp.data, name = "Maximum Temperature", "spline", 
                    hcaes(x = Date, y = maxTemp)) %>%
      hc_add_series(temp.data, name = "Minimum Temperature", "spline", 
                    hcaes(x = Date, y = minTemp)) %>%
      hc_tooltip(headerFormat = as.character(tags$small(""))) %>%
      hc_xAxis(dateTimeLabelFormats = list(day = '%d %b %y'), type = "datetime") %>%
      hc_tooltip(shared = TRUE) %>%
      hc_colors(col)
      
              
  })
  
  output$weather_radial <- renderHighchart({
    minmax_temp %>%
      hchart(type = "columnrange", 
             hcaes(x = date, low = min_temp, high = max_temp, color = mean_temp), 
             showInLegend = FALSE) %>% 
      hc_chart(polar = TRUE, height = 500) %>%  
      hc_xAxis(title = list(text = ""), gridLineWidth = 1,
        labels = list(format = "{value: %b}")) %>% 
      hc_yAxis(max = 30, min = 0, labels = list(format = "{value} ºC"), 
               showFirstLabel = FALSE) %>%
      hc_tooltip(headerFormat = as.character(tags$small("{point.x:%d %B}")),
                 pointFormat = "<br/>Average Maximum: <b>{point.max_temp} ºC</b>
                 <br/>Average Minimum: <b>{point.min_temp} ºC</b>") %>%
      hc_title(text = "Average Temperature For the Past 5 Years") %>%
      hc_subtitle(text = 'Source: <a href="http://www.bom.gov.au/climate
                  /averages/tables/cw_086282.shtml" target="_blank">Bureau of Meteorology</a>')
  })
  
  output$rainfall_average <- renderHighchart({
    col <- c("#87CEEB", "#00688B")
    
    highchart() %>%
      hc_title(text = "Average Monthly Rainfall and Rain Days For the Past 5 Years") %>%
      hc_subtitle(text = 'Source: <a href="http://www.bom.gov.au/climate
                  /averages/tables/cw_086282.shtml" target="_blank">Bureau of Meteorology</a>') %>%
      hc_chart(zoomType = "x") %>%
      hc_yAxis_multiples(list(title = list(text = "Average Rain Days"), showLastLabel = TRUE, opposite = FALSE),
                         list(title = list(text = "Average Rainfall (mm)"), opposite = TRUE)) %>%
      hc_xAxis(title = list(text = "Month"), categories = month.abb) %>%
      hc_add_series(rainfall, name = "Average Rain Days", "column", 
                    hcaes(x = month, y = average_rain_days),
                    tooltip = list(pointFormat = "Average Days of Rain: <b>{point.average_rain_days}</b>")) %>%
      hc_plotOptions(series = list(borderRadius = 4, animation = list(duration = 3000))) %>%
      hc_add_series(rainfall, name = "Average Rainfall", "spline", 
                    hcaes(x = month, y = precipitation), yAxis = 1,
                    tooltip = list(pointFormat = "<br/>Average Rainfall: <b>{point.precipitation} mm</b>")) %>%
      hc_tooltip(shared = TRUE) %>%
      hc_colors(col)
  })
  
  output$sunshine <- renderHighchart({
    sunshine_duration %>%
      hchart('areaspline', hcaes(x = month, y = duration)) %>%
      hc_title(text = "Average Daily Sunshine Duration for each Month") %>%
      hc_subtitle(text = 'Source: <a href="http://www.bom.gov.au/climate
                  /averages/tables/cw_086282.shtml" target="_blank">Bureau of Meteorology</a>') %>%
      hc_chart(zoomType = "x") %>%
      hc_xAxis(title = list(text = "Month")) %>%
      hc_yAxis(title = list(text = "Duration (Hours)")) %>%
      hc_colors("#FFFF00") %>%
      hc_tooltip(pointFormat = "Average Daily Sunshine Duration: <b>{point.duration} hours</b>")
  })
})
