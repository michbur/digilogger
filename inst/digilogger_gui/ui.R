library(shiny)
library(shinythemes)
library(DT)

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("digilogger"),
  
  pageWithSidebar(
    headerPanel("Data"),
    sidebarPanel(
      fileInput('datafile', 'Choose CSV File',
                accept=c('text/csv', 'text/comma-separated-values,text/plain', '.csv'),
                multiple = TRUE),
      includeMarkdown("readme.md")
    ),
    mainPanel(
      shiny::tabsetPanel(
        shiny::tabPanel("Raw Data",
                        dataTableOutput('filetable'),
                        includeMarkdown("raw_data_readme.md")),
        shiny::tabPanel("summary",
                        tableOutput('summary')),
        shiny::tabPanel("Plot",
                        plotOutput('mplot')),
        shiny::tabPanel("Session information",
                        uiOutput('sessioninformation')),
        shiny::tabPanel("About",
                        includeMarkdown("about.md"))
      )
    )
  )
)
