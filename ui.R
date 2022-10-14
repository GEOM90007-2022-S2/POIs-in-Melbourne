#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.

# Importing libraries
library(shiny)
library(shinythemes)
library(leaflet)
library(plotly)
library(ggplot2)
library(dplyr)
library(owmr)
library(rgdal)
library(lubridate)
library(mapboxapi)
library(fontawesome)
library(shinyWidgets)
library(shinydashboard)
library(igraph)
library(highcharter)
library(dashboardthemes)
source('helper.R')

# Define UI for application that draws a histogram
header <- dashboardHeader(
  # Define the header and insert image as title
  title = tags$a(tags$img(src='https://bit.ly/3rFI94P',
                          height='55', width='160')),
  titleWidth = 250
)

sidebar <- dashboardSidebar(
  width = 250,
  sidebarMenu(
    # Tab for different visualisation
    menuItem("Home",
             tabName = "home",
             selected = T,
             icon = icon('thumbs-up')),
    menuItem("Places to Visit",
             tabName = "poi",
             icon = icon('map-location-dot')),
    menuItem("Melbourne Weather",
             tabName = "weather",
             icon = icon('sun')),
    menuItem("Pedestrian Volume Monitor",
             tabName = "traffic",
             icon = icon("users")),
    menuItem("Tourism Industry Recovery",
             tabName = "tour",
             icon = icon('plane')),
    menuItem("Setting",
             tabName = "setting",
             icon = icon("gear"),
             radioButtons("displaymode", "Display Mode", choices = c('Light Mode' = 'lightMode', 'Dark Mode' = 'darkMode'), selected="lightMode")
             )
  )
)

body <- dashboardBody(
  uiOutput("myTheme"),
  tabItems(
    # Structure for home tab
    tabItem("home",
            fluidPage(
              fluidRow(
                includeHTML("home.html"),
                tags$head(
                  tags$link(rel = "stylesheet", 
                            type = "text/css", 
                            href = "plugins/font-awesome-4.7.0/css/font-awesome.min.css")
                )
              ),
              hr(),
              fluidRow(
                column(12, leafletOutput("mymap"))
              ),
              hr(),
              h5('Maps are created using ',
                 a('Leaflet',
                   href="https://rstudio.github.io/leaflet/")
              ),
              h5('Charts are created using ', 
                 a("Highcharter", 
                   href="https://jkunst.com/highcharter/"), 
                 '(a R wrapper for Highcharts)')
            )
    ),
    tabItem("poi",
            fluidPage(
              titlePanel(strong("Attractions & Things to Do in Melbourne")),
              hr(),
              h5("Melbourne frequently tops the list of the world's most livable cities.
                 You'll never run out of things to do in Melbourne. Explore the city's 
                 diverse galleries and shops; stroll through lush gardens; cruise along 
                 the Yarra River; or hop aboard a heritage tram to discover Melbourne's magic.
                 Browse the map to find your next destination!",
                 style = "color: #808080;font-size:15px;"),
              hr(),
              leafletOutput("poi_viz", height = 850),
              hr(),
              h5('Maps are created using ',
                 a('Leaflet',
                   href="https://rstudio.github.io/leaflet/")
              )
            )
    ),
    tabItem("weather",
            fluidPage(
              titlePanel(strong("Weather in Melbourne")),
              hr(),
              h5("Melbourne enjoys warm summers, glorious springs, mild autumns and crisp winters.
                 However, it is best for visitors to best prepared for their trip in Melbourne!",
                 style = "color: #808080;font-size:15px;"),
              hr(),
              h5(strong(paste("Current Weather Overview of", 
                              substr(as_datetime(current_weather$dt, tz = "Australia/Sydney"), 1, 10))),
                 style = "font-size:16px;"),
              
              # Value box
              fluidRow(
                column(3, valueBoxOutput("cur_temp", width = 14)),
                column(3, valueBoxOutput("rainfall_1hr", width = 14)),
                column(3, valueBoxOutput("current_condition", width = 14)),
                column(3, valueBoxOutput("sunset", width = 14))
              ),
              hr(),
              # Add Interaction Bar
              #fluidRow(
              #  column(width=12,
                       # Selection between Years
                       # selectInput('weatherYear','Start Year', choices = c(unique(maxTemp_data$Year)), multiple = F,selected = '2022'),
                       # # Selection between Months
                       # selectInput('weatherMonth','Start Month', choices = c(unique(maxTemp_data$Month)),multiple = F, selected = '10'),
                       # # Selection between Days 
                       # selectInput('weatherDay','Start Day', choices = c(unique(maxTemp_data$Day)), multiple = F, selected = '9'),
                       # Selection between Date
              #         dateRangeInput(
              #           inputId = "dates",
              #           label = h3("Date range"),
              #           start = format(Sys.time(), "%Y-%m-%d"),
              #           end = format(Sys.time() + days(10), "%Y-%m-%d"),
              #           min = "2013-01-01",
              #           max = "2023-12-31"),
              #)
              #highchartOutput('weather_plot'),
              #hr(),
              fluidRow(
                column(6, highchartOutput("weather_forecast", height = 300)),
                column(6, highchartOutput("humidity_forecast", height = 300))
              ),
              hr(),
              h4(strong("Melbourne Historical Weather Observations")),
              hr(),
              fluidRow(
                column(2),
                column(8, highchartOutput("weather_radial", height = 500)),
                column(2)
              ),
              hr(),
              fluidRow(
                column(6, highchartOutput("rainfall_average")),
                column(6, highchartOutput("sunshine"))
              ),
              hr(),
              h5('Live Weather Data Source: ', 
                 a("OpenWeather",
                   href="https://openweathermap.org")),
              h5('Historic Weather Data Source: ', 
                 a("Bureau of Meteorology",
                   href="http://www.bom.gov.au")),
              h5('Charts are created using ', 
                 a("Highcharter", 
                   href="https://jkunst.com/highcharter/"), 
                 '(a R wrapper for Highcharts)')
              )
            ),
    tabItem("tour",
            fluidPage(
              titlePanel(strong("Tourism Industry is Slowly Recovering")),
              hr(),
              highchartOutput("arrival"),
              hr(),
              h5('Charts are created using ', 
                 a("Highcharter", 
                   href="https://jkunst.com/highcharter/"), 
                 '(a R wrapper for Highcharts)')
            )
        ),
    tabItem("traffic",
            titlePanel(strong("Pedestrian Volume Monitor")),
            hr(),
            h5("This Pedestrian Volume Monitor helps to understand how people use different city locations at different times of day to better inform decision-making and plan for the future.",
               style = "color: #808080;font-size:15px;"),
            hr(),
            leafletOutput("trafficMap", height = 500),
            hr(),
            selectInput("pdsensor", "Select Sensor Place", choices = c(sort(unique(traffic_2022_data$Sensor_Name))), multiple=F, selected="231 Bourke St"),
            highchartOutput("traffic_day_hour", height = 450)
      )
    )
)

# Putting the UI together
ui <- dashboardPage(
  title = "Visiting Melbourne",
  header, 
  sidebar, 
  body
)
