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
  
  output[["sessioninformation"]] <- renderUI({
    HTML(knit2html(text = capture.output(pander::pander(sessionInfo())), fragment.only = TRUE))
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
        tabPanel("About",
                 includeMarkdown("about.md")),
        tabPanel("Session information",
                 uiOutput('sessioninformation'))
      )
    }
  })
  
}
