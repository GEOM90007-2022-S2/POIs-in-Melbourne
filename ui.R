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
  titleWidth = 280
)

sidebar <- dashboardSidebar(
  width = 280,
  sidebarMenu(
    # Tab for different visualisation
    menuItem("Home",
             tabName = "home",
             selected = T,
             icon = fa_i('fas fa-house')),
    menuItem("Point of Interest",
             tabName = "poi",
             icon = fa_i('fas fa-map-location-dot')),
    menuItem("Melbourne Weather",
             tabName = "weather",
             icon = fa_i('fas fa-sun'))
  )
)

body <- dashboardBody(
  customTheme,
  tabItems(
    # Structure for home tab
    tabItem("home",
            fluidPage(
              # Title for home tab
              titlePanel(strong("Get Set To Discover Melbourne")),
              hr(),
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
              # Add Interaction Bar
              fluidRow(
                column(width=3,
                       # Selection between Years
                       # selectInput('weatherYear','Start Year', choices = c(unique(maxTemp_data$Year)), multiple = F,selected = '2022'),
                       # # Selection between Months
                       # selectInput('weatherMonth','Start Month', choices = c(unique(maxTemp_data$Month)),multiple = F, selected = '10'),
                       # # Selection between Days 
                       # selectInput('weatherDay','Start Day', choices = c(unique(maxTemp_data$Day)), multiple = F, selected = '9'),
                       # Selection between Date
                       dateRangeInput(
                         inputId = "dates",
                         label = h3("Date range"),
                         start = "2022-10-03",
                         end = "2022-10-09",
                         min = "2013-01-01",
                         max = "2022-10-09"),
                column(width = 10, plotlyOutput('weather.plot', width = 800)
                )
              )
            ),
            hr(),
            fluidRow(
              column(2),
              column(8, highchartOutput("weather_radial", height = 500)),
              column(2)
            ),
            hr(),
            highchartOutput("rainfall_average"),
            hr(),
            highchartOutput("sunshine")
            )
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
