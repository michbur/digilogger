library(shiny)
library(digilogger)
library(knitr)
library(DT)

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
