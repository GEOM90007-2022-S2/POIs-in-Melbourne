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
  
  output$mymap <- renderLeaflet({
    leaflet() %>% setView(lat= -37.840935, lng = 144.946457, zoom = 11) %>%
      addProviderTiles(providers$CartoDB.Voyager,
                       options = providerTileOptions(noWrap = TRUE))
  })
  
  output$poi_viz <- renderLeaflet({
    leaflet() %>%
      setView(lat= -37.8080, lng = 144.946457, zoom = 13.5) %>%
      addProviderTiles(providers$CartoDB.Voyager,
                       options = providerTileOptions(noWrap = TRUE)) %>%
      addMarkers(data = landmark_data, ~long, ~lat, icon = landmarkIcon,
                 label = ~feature_name, group = "<img src='landmark.png' height='16' width='16'> Landmark") %>%
      addMarkers(data = gallery_data, ~long, ~lat, icon = museumIcon,
                 label = ~feature_name, group = "<img src='museum.png' height='16' width='16'> Gallery/Museum/Library") %>%
      addMarkers(data = church_data, ~long, ~lat, icon = churchIcon,
                 label = ~feature_name, group = "<img src='church.png' height='16' width='16'> Place of Worship") %>%
      addMarkers(data = retail_data, ~long, ~lat, icon = retailIcon,
                 label = ~feature_name, group = "<img src='retail.png' height='16' width='16'> Retail") %>%
      addMarkers(data = leisure_data, ~long, ~lat, icon = leisureIcon,
                 label = ~feature_name, group = "<img src='leisure.png' height='16' width='16'> Leisure and Recreation") %>%
      addMarkers(data = visitorcenter_data, ~long, ~lat, icon = visitorcentreIcon,
                 label = ~feature_name, group = "<img src='information.png' height='16' width='16'> Visitor Information Booth") %>%
      addMarkers(data = wifi_data, ~Longitude, ~Latitude, 
                 icon = wifiIcon, group = "<img src='wifi.png' height='16' width='16'> Public Wifi Location") %>%
      addMarkers(data = city_circle, ~long, ~lat, icon = tramIcon,
                 label = ~NAME, group = "<img src='tram.png' height='16' width='16'> City Circle Tourist Tram") %>%
      addLayersControl(
        overlayGroups = c("<img src='landmark.png' height='16' width='16'> Landmark",
                          "<img src='museum.png' height='16' width='16'> Gallery/Museum/Library",
                          "<img src='church.png' height='16' width='16'> Place of Worship",
                          "<img src='retail.png' height='16' width='16'> Retail",
                          "<img src='leisure.png' height='16' width='16'> Leisure and Recreation",
                          "<img src='information.png' height='16' width='16'> Visitor Information Booth",
                          "<img src='wifi.png' height='16' width='16'> Public Wifi Location",
                          "<img src='tram.png' height='16' width='16'> City Circle Tourist Tram"),
        options = layersControlOptions(collapsed = FALSE)
      ) %>%
      hideGroup("<img src='wifi.png' height='16' width='16'> Public Wifi Location") %>%
      hideGroup("<img src='tram.png' height='16' width='16'> City Circle Tourist Tram")
  })
})
