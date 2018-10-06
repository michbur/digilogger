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

# Define server logic required to draw a histogram
server <- function(input, output) {
   
  filedata <- reactive({
    inFile <- input$datafile
    if(is.null(inFile)) {
      # User has not uploaded a file yet
      NULL
    } else {
      do.call(rbind, lapply(input$datafile$datapath, vs.import))
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
  
  output$sessioninformation <- renderUI({
    HTML(knit2html(text = capture.output(pander::pander(sessionInfo())), fragment.only = TRUE))
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

