#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.

# Importing libraries
library(shiny)
library(shinythemes)
library(leaflet)
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
  title = tags$a(tags$img(src='https://bit.ly/3cSvLu7',
                          height='40', width='160')),
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
             icon = fa_i('fas fa-map-location-dot'))
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
                column(12, leafletOutput("mymap")),
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
              titlePanel(strong("Point of Interest in Melbourne")),
              hr(),
              leafletOutput("poi_viz", height = 850)
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
