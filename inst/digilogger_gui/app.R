#
# This is a Shiny web application. 
#

library(shiny)
library(digilogger)

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("digilogger"),
   
   pageWithSidebar(
     headerPanel("Data"),
     sidebarPanel(
       fileInput('datafile', 'Choose CSV File',
                 accept=c('text/csv', 'text/comma-separated-values,text/plain', '.csv'))
     ),
     mainPanel(
       shiny::tabsetPanel(
         shiny::tabPanel("Raw Data",
                         dataTableOutput('filetable')),
        shiny::tabPanel("summary",
                         tableOutput('summary')),
        shiny::tabPanel("Plot",
                         plotOutput('mplot')),
       shiny::tabPanel("Session information",
                       textOutput('sessioninformation'))
     )
     )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
   
  filedata <- reactive({
    inFile <- input$datafile
    if(is.null(inFile)) {
      # User has not uploaded a file yet
      NULL
    } else {
      vs.import(inFile$datapath)
    }
  })
  
  # Generate a table of the dataset
  output$filetable <- renderDataTable({
    filedata()
  })
  
  output$summary <- renderTable({
    summary(filedata())
  })
  
  output$mplot <- renderPlot({
    mplot()
  })
  
  output$sessioninformation <- renderPrint({
    sessionInfo()
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

