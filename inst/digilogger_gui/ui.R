library(shiny)
library(shinythemes)
library(DT)

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  theme = shinythemes::shinytheme("spacelab"),
  
  # Application title
  titlePanel("digilogger"),
  
  pageWithSidebar(
    headerPanel("Data"),
    sidebarPanel(
      tags$img(src='logo.png', height=300, width=500),
      fileInput('datafile', 'Choose CSV File',
                accept=c('text/csv', 'text/comma-separated-values,text/plain', '.csv'),
                multiple = TRUE),
      includeMarkdown("readme.md"),
      tags[["p"]](HTML("<h3><A HREF=\"javascript:history.go(0)\">Start a new analysis</A></h3>"))
    ),
    mainPanel(
      uiOutput("dynamic_tabset")
    )
  )
)
