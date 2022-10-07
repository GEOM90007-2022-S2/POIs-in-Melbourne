#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.

# Importing libraries
library(shiny)
library(shinythemes)
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
             icon = fa_i('fas fa-house'))
  )
)

body <- dashboardBody(
  customTheme
)

# Putting the UI together
ui <- dashboardPage(
  title = "Visiting Melbourne",
  header, 
  sidebar, 
  body
)
