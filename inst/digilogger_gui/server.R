library(shiny)
library(digilogger)
library(knitr)
library(DT)

options(shiny.maxRequestSize=10*1024^2)

options(DT.options = list(dom = "Brtip",
                          buttons = c("copy", "csv", "excel", "print"),
                          pageLength = 50
))

my_DT <- function(x)
  formatStyle(datatable(x, escape = FALSE, extensions = "Buttons", filter = "top", rownames = FALSE), 1L:ncol(x), color = "black")

server <- function(input, output) {
  
  filedata <- reactive({
    inFile <- input$datafile
    if(is.null(inFile)) {
      # User has not uploaded a file yet
      NULL
    } else {
      do.call(rbind, lapply(input[["datafile"]][["datapath"]], vs.import))
    }
  })
  
  # Generate a table of the dataset
  output$filetable <- renderDataTable({
    if(is.null(filedata())) {
      NULL
    } else {
      my_DT(filedata())
    }
  })
  
  output$sessioninformation <- renderUI({
    HTML(knit2html(text = capture.output(pander::pander(sessionInfo())), fragment.only = TRUE))
  })
}
