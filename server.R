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
      addCircleMarkers(data = poi_data, ~long, ~lat, 
                       label = ~feature_name, radius = 1, group = "Point of Interest") %>%
      addMarkers(data = wifi_data, ~Longitude, ~Latitude, 
                 icon = wifiIcon, group = "Public Wifi Location") %>%
      addMarkers(data = city_circle, ~long, ~lat, icon = tramIcon,
                 label = ~NAME, group = "City Circle Tourist Tram") %>%
      addLayersControl(
        overlayGroups = c("Point of Interest", "Public Wifi Location",
                          "City Circle Tourist Tram"),
        options = layersControlOptions(collapsed = FALSE)
      ) %>%
      hideGroup("Public Wifi Location") %>%
      hideGroup("City Circle Tourist Tram")
  })
})
