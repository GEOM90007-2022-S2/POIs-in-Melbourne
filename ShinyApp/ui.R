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
                column(4, div(tags$img(src = 'melbourne_image1.png', height = '320px',
                                       width = '500px', alt = 'something went wrong',
                                       deleteFile = FALSE), style = 'text-align: center:')),
                column(2),
                column(6, br(), br(), br(), br(), br(),
                              h4('A perfect blend of rich cultural history and new age trends is 
                              waiting for you in Melbourne. As the sun goes down, the city comes 
                              to life with a vibrant dining scene as well as events and exhibitions. 
                              Explore its bustling laneways, trendy neighbourhoods and sophisticated 
                              foodie scene to get a taste of what Melbourne is all about.',
                              style = "color: #808080;font-size:17px;", align = 'right'))
              ),
              hr(),
              fluidRow(
                column(12, leafletOutput("mymap")),
                #column(5, br(), br(), br(), br(), br(),
                #          h4('In this visualisation kiosk, we aim to help you to get the best
                #             out of Melbourne!',
                #          style = "color: #808080;font-size:17px;", align = 'left')),
                #column(1),
                #column(5, div(tags$img(src = 'melbourne_image2.png', height = '320px',
                #                       width = '560px', alt = 'something went wrong',
                #                       deleteFile = FALSE), style = 'text-align: left:'))
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
              leafletOutput("poi_viz", height = 800)
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
