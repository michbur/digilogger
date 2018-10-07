library(shiny)
library(digilogger)
library(knitr)
library(DT)
library(dplyr)
library(ggplot2)

options(shiny.maxRequestSize=10*1024^2)

options(DT.options = list(dom = "Brtip",
                          buttons = c("copy", "csv", "excel", "print"),
                          pageLength = 50
))

my_DT <- function(x)
  datatable(x, escape = FALSE, extensions = "Buttons", filter = "top", rownames = FALSE) %>% 
  formatStyle(1L:ncol(x), color = "black")

server <- function(input, output) {
  
  filedata <- reactive({
    if(is.null(input[["datafile"]])) {
      # User has not uploaded a file yet
      NULL
    } else {
      dat <- lapply(input[["datafile"]][["datapath"]], vs.import)
      
      # find unique md5 sums
      unique_files <- !duplicated(sapply(dat, function(i) as.character(unique(i[["md5sum"]]))))
      
      do.call(rbind, dat[unique_files])
    }
  })
  
  # Generate a table of the dataset
  output[["filetable"]] <- renderDataTable({
    my_DT(filedata())
  })
  
  output[["timeplot"]] <- renderPlot({
    ggplot(filedata(), aes(x = `Examination date`, y = Value, color = ID)) +
      geom_point() +
      geom_line() +
      theme_bw(base_size = 15) +
      theme(legend.position = "bottom")
  })
  
  output[["sessioninformation"]] <- renderUI({
    capture.output(pander::pander(sessionInfo())) %>% 
      knit2html(text = ., fragment.only = TRUE) %>% 
      HTML()
  })
  
  output[["dynamic_tabset"]] <- renderUI({
    if(is.null(filedata())) {
      tabsetPanel(
        tabPanel("About",
                 includeMarkdown("about.md")),
        tabPanel("Session information",
                 uiOutput('sessioninformation'))
      )
    } else {
      tabsetPanel(
        tabPanel("Raw Data",
                 dataTableOutput('filetable'),
                 includeMarkdown("raw_data_readme.md")),
        tabPanel("Patient chart",
                 plotOutput("timeplot")),
        tabPanel("About",
                 includeMarkdown("about.md")),
        tabPanel("Session information",
                 uiOutput('sessioninformation'))
      )
    }
  })
  
}
