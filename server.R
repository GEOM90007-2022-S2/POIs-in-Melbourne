# server
# You can run the application by clicking 'Run App' above.
# But PLEASE follow the instructions given in README.md
# And install all the required packages via "Package Install Commands.Rmd"

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

global <- getOption("highcharter.global")
global$useUTC <- FALSE
global$timezoneOffset <- -300
options(highcharter.global = global)

shinyServer(function(input, output, session) {
  values = reactiveValues()
  
  ############################## Update Theme ##############################
  output$myTheme = renderUI({
    if (input$displaymode == 'lightMode'){
      lightTheme
    } else{
      darkTheme
    }
  })
  
  ############################## Map Outputs ##############################
  
  # Output Graph of Map
  output$mymap <- renderLeaflet({
    if (input$displaymode == 'lightMode'){
      map.provider = providers$CartoDB.Voyager
    } else{
      map.provider = providers$CartoDB.DarkMatter
    }
    leaflet() %>% setView(lat= -37.840935, lng = 144.946457, zoom = 11) %>%
      addProviderTiles(map.provider,
                       options = providerTileOptions(noWrap = TRUE))
  })
  
  
  
  # Output Graph of POI
  output$poi_viz <- renderLeaflet({
    if (input$displaymode == 'lightMode'){
      map.provider = providers$CartoDB.Voyager
    } else{
      map.provider = providers$CartoDB.DarkMatter
    }
    leaflet() %>%
      setView(lat= -37.8080, lng = 144.946457, zoom = 13.5) %>%
      addProviderTiles(map.provider,
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
      addScaleBar(position = "bottomright") %>%
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
  
  ############################## Weather Outputs ##############################
  
  output$cur_temp <- renderValueBox(
    valueBox(
      value = tags$p(paste(round(current_weather$main$temp), "??C"), style = "font-size: 85%;"), 
      subtitle = paste("Feels like", round(current_weather$main$feels_like), "??C"),
      icon = fa_i("fas fa-temperature-three-quarters"), 
      color = "light-blue"
    )
  )
  
  output$rainfall_1hr <- renderValueBox(
    valueBox(
      value = tags$p(paste(rain_measure, "mm"), style = "font-size: 85%;"), 
      subtitle = "Rainfall in Last Hour",
      icon = fa_i("fas fa-droplet"), color = "blue"
    )
  )
  
  output$current_condition <- renderValueBox(
    valueBox(
      value = tags$p(str_to_title(current_weather$weather$description), 
                     style = "font-size: 85%;"), 
      subtitle = "Current Condition",
      icon = fa_i("fas fa-circle-info"), color = "teal"
    )
  )
  
  output$sunset <- renderValueBox(
    valueBox(
      value = tags$p(substr(
        as_datetime(current_weather$sys$sunset, 
                    tz = "Australia/Sydney"), 12, 16), style = "font-size: 85%;"), 
      subtitle = "Expected Sunset Time",
      icon = tags$i(class = "fas fa-sun"), color = "orange"
    )
  )
  
  output$weather_forecast <- renderHighchart({
    if (input$displaymode == "lightMode"){
      hc_theme = hc_theme_smpl()
    } else{
      hc_theme = hc_theme_db()
    }
    forecast_df$tmstmp <- datetime_to_timestamp(forecast_df$tmstmp)
    
    forecast_df %>%
      hchart("spline", hcaes(x = tmstmp, y = temp)) %>%
      hc_xAxis(type = "datetime",
               tickInterval = 24 * 3600 * 1000,
               dateTimeLabelFormats = list(day='%d %b %Y'), 
               labels = list(enabled = TRUE, format = '{value:%Y-%m-%d}'),
               title = list(text = "Datetime")) %>%
      hc_yAxis(title = list(text = "Forecast Temperature"), 
               labels = list(format = "{value} ??C")) %>%
      hc_title(text = "Forecast Temperature of Next 5 Days") %>%
      hc_subtitle(text = 'Source: <a href="https://home.openweathermap.org" 
                  target="_blank">OpenWeather</a>') %>%
      hc_tooltip(pointFormat = "<br/>Forecast Temperature: <b>{point.temp} ??C</b>
                 <br/>Feels Like: <b>{point.fl_temp} ??C</b>") %>%
      hc_plotOptions(series = list(animation = list(duration = 3000))) %>%
      hc_colors("#E6CC00") %>%
      hc_add_theme(hc_theme)
  })
  
  output$humidity_forecast <- renderHighchart({
    if (input$displaymode == "lightMode"){
      hc_theme = hc_theme_smpl()
    } else{
      hc_theme = hc_theme_db()
    }
    forecast_df$tmstmp <- datetime_to_timestamp(forecast_df$tmstmp)
    
    forecast_df %>%
      hchart("spline", hcaes(x = tmstmp, y = humidity)) %>%
      hc_xAxis(type = "datetime",
               tickInterval = 24 * 3600 * 1000,
               dateTimeLabelFormats = list(day='%d %b %Y'), 
               labels = list(enabled = TRUE, format = '{value:%Y-%m-%d}'),
               title = list(text = "Datetime")) %>%
      hc_yAxis(title = list(text = "Forecast Humidity"), 
               labels = list(format = "{value}%")) %>%
      hc_title(text = "Forecast Humidity of Next 5 Days") %>%
      hc_subtitle(text = 'Source: <a href="https://home.openweathermap.org" 
                  target="_blank">OpenWeather</a>') %>%
      hc_tooltip(pointFormat = "<br/>Forecast Humidity: <b>{point.humidity}%</b>") %>%
      hc_plotOptions(series = list(animation = list(duration = 3000))) %>%
      hc_colors("#03A9F4") %>%
      hc_add_theme(hc_theme)
  })
  
  output$weather_radial <- renderHighchart({
    if (input$displaymode == "lightMode"){
      hc_theme = hc_theme_smpl()
    } else{
      hc_theme = hc_theme_db()
    }
    minmax_temp %>%
      hchart(type = "columnrange",
             hcaes(x = date, low = min_temp, high = max_temp, color = mean_temp), 
             showInLegend = FALSE) %>% 
      hc_chart(polar = TRUE) %>%  
      hc_xAxis(title = list(text = ""), gridLineWidth = 1,
               labels = list(format = "{value: %b}")) %>% 
      hc_yAxis(max = 30, min = 0, labels = list(format = "{value} ??C"), 
               showFirstLabel = FALSE) %>%
      hc_tooltip(headerFormat = as.character(tags$small("{point.x:%d %B}")),
                 pointFormat = "<br/>Average Maximum: <b>{point.max_temp} ??C</b>
                 <br/>Average Minimum: <b>{point.min_temp} ??C</b>") %>%
      hc_title(text = "Average Temperature For the Past 5 Years") %>%
      hc_subtitle(text = 'Source: <a href="http://www.bom.gov.au/climate
                  /averages/tables/cw_086282.shtml" target="_blank">Bureau of Meteorology</a>') %>%
      hc_add_theme(hc_theme)
  })
  
  output$rainfall_average <- renderHighchart({
    if (input$displaymode == "lightMode"){
      hc_theme = hc_theme_smpl()
    } else{
      hc_theme = hc_theme_db()
    }
    col <- c("#87CEEB", "#00688B")
    
    highchart() %>%
      hc_title(text = "Average Monthly Rainfall and Days of Rain For the Past 5 Years") %>%
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
      hc_colors(col) %>%
      hc_add_theme(hc_theme)
  })
  
  output$sunshine <- renderHighchart({
    if (input$displaymode == "lightMode"){
      hc_theme = hc_theme_smpl()
    } else{
      hc_theme = hc_theme_db()
    }
    sunshine_duration %>%
      hchart(name = "Sunshine Duration", 'areaspline', 
             hcaes(x = month, y = duration), showInLegend = TRUE) %>%
      hc_title(text = "Average Sunshine Duration for each Month") %>%
      hc_subtitle(text = 'Source: <a href="http://www.bom.gov.au/climate
                  /averages/tables/cw_086282.shtml" target="_blank">Bureau of Meteorology</a>') %>%
      hc_chart(zoomType = "x") %>%
      hc_xAxis(title = list(text = "Month")) %>%
      hc_yAxis(title = list(text = "Duration (Hours)")) %>%
      hc_plotOptions(series = list(animation = list(duration = 3000))) %>%
      hc_colors("#FFFF00") %>%
      hc_tooltip(pointFormat = "Average Daily Sunshine Duration: <b>{point.duration} hours</b>") %>%
      hc_add_theme(hc_theme)
  })
  
  ############################## Tour Page Outputs ##############################
  
  output$arrival <- renderHighchart({
    if (input$displaymode == "lightMode"){
      hc_theme = hc_theme_smpl()
    } else{
      hc_theme = hc_theme_db()
    }
    vic_arrival %>%
      hchart("spline", hcaes(x = time, y = visitor_arrival)) %>%
      hc_tooltip(headerFormat = as.character(tags$small("{point.x:%B %Y}")),
                 pointFormat = "<br/>Oversea Visitors Arrival: <b>{point.visitor_arrival}k</b>") %>%
      hc_chart(zoomType = "x") %>%
      hc_title(text = "Victoria Oversea Visitor Arrivals") %>%
      hc_subtitle(text = 'Source: <a href="https://www.abs.gov.au/statistics
                  /industry/tourism-and-transport/overseas-arrivals-and-departures
                  -australia/latest-release" target="_blank">Bureau of Statistics</a>') %>%
      hc_plotOptions(series = list(animation = list(duration = 3000))) %>%
      hc_yAxis(title = list(text = "Oversea Visitor Arrivals (Thousands)")) %>%
      hc_xAxis(title = list(text = "Time"), 
               plotLines = list(list(label = list(text = "WHO Declares Pandemic"),
                                     color = "#FF0000", width = 2, value = datetime_to_timestamp(my("Mar 2020"))))) %>%
      hc_colors("#6495ED") %>%
      hc_add_theme(hc_theme)
  })

  ############################## Traffic Page Outputs ###########################
  output$trafficMap = renderLeaflet({
    if (input$displaymode == 'lightMode'){
      map.provider = providers$CartoDB.Voyager
    } else{
      map.provider = providers$CartoDB.DarkMatter
    }
    tdata = traffic_2022_data %>% group_by(Sensor_Name, latitude, longitude) %>% summarise()
    tdata$popup <- paste0('<b>', tdata$Sensor_Name, '</b><br/>',
                              'Location: ', tdata$latitude, ', ', tdata$longitude)
    leaflet(options = leafletOptions(zoomControl = FALSE)) %>%
      setView(lat= -37.8080, lng = 144.9567, zoom = 13.5) %>%
      addProviderTiles(map.provider,
                       options = providerTileOptions(noWrap = TRUE)) %>%
      addMarkers(data = tdata, ~longitude, ~latitude, popup=~popup, icon = sensorIcon)
  })
  
  observe({
    event = input$trafficMap_marker_click
    if (is.null(event))
      return()
    
    isolate({
      sensorNameSelected = filter(traffic_2022_data, abs(longitude - event$lng) < 0.0001 & abs(latitude - event$lat) < 0.0001)[1,1]
      updateSelectInput(session, 'pdsensor', selected=sensorNameSelected)
    })
  })
  
  
  
  output$traffic_day_hour = renderHighchart({
    if (input$displaymode == "lightMode"){
      hc_theme = hc_theme_smpl()
    } else{
      hc_theme = hc_theme_db()
    }
    day_of_week_order = c('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')
    sensorSelected = input$pdsensor
    tgdata = filter(traffic_2022_data, Sensor_Name == sensorSelected)
    tgdata = tgdata %>% 
            group_by(Day, Time) %>% 
            dplyr::summarize(hourly_counts_mean = round(mean(Hourly_Counts, na.rm=TRUE))) %>%
            arrange(match(Day, day_of_week_order))
    
    tgdata %>%
      hchart("heatmap", hcaes(x=Day,y=Time,value=hourly_counts_mean)) %>%
      hc_title(text = paste("Average Pedestrian Counts @ ", sensorSelected)) %>%
      hc_yAxis(title = list(text = "Time"), categories = c(0:23)) %>%
      hc_xAxis(title = list(text = "Day of Week"), categories = day_of_week_order) %>%
      hc_tooltip(headerFormat = paste("<b>", sensorSelected, "</b>"),
                 pointFormat = "<br/><b>Average Pedestrian Counts @ {point.Time}00: {point.hourly_counts_mean} persons</b>") %>%
      hc_plotOptions(series = list(borderRadius = 4, animation = list(duration = 3000))) %>%
      hc_add_theme(hc_theme)
  })
  
})

  

