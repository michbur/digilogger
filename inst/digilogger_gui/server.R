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
      duplicates <- duplicated(sapply(dat, function(i) as.character(unique(i[["md5sum"]]))))
      
      res <- do.call(rbind, dat[!duplicates])
      
      attr(res, "duplicates") <- duplicates
      names(attr(res, "duplicates")) <- input[["datafile"]][["name"]]
      
      res
    }
  })
  
  # Generate a table of the dataset
  output[["filetable"]] <- renderDataTable({
    my_DT(filedata())
  })
  
  output[["timeplot"]] <- renderPlot({
    ggplot(filedata(), aes(x = `Examination date`, y = Value, color = Biomarker)) +
      geom_point() +
      geom_line() +
      theme_bw(base_size = 15) +
      theme(legend.position = "bottom") +
      facet_wrap(~ ID, ncol = 1)
  })
  
  output[["sessioninformation"]] <- renderUI({
    capture.output(pander::pander(sessionInfo())) %>% 
      knit2html(text = ., fragment.only = TRUE) %>% 
      HTML()
  })
  
  output[["files"]] <- renderDataTable({
    filedata()[, c("ID", 
                   "Name",
                   "Forename", 
                   "Birthday", 
                   "Sex", 
                   "Examination date", 
                   "Examination time", 
                   "Profile",
                   "Project", 
                   "LOT", 
                   "md5sum",
                   "File")]
  })
  
  output[["duplicated_files"]] <- renderUI({
    file_text <- if(any(attr(filedata(), "duplicates"))) {
      strong(paste0("Detected duplicated files: ", paste0(names(which(attr(filedata(), "duplicates"))), collapse = ", "), 
                    ". File(s) removed from the further analysis."))
    } else {
      p("No duplicated files detected.")
    }
    
    p(file_text)
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
                 plotOutput("timeplot", height = 130 + 150*nlevels(filedata()[["ID"]]))),
        tabPanel("Files",
                 uiOutput("duplicated_files"),
                 dataTableOutput('files'),
                 includeMarkdown("files.md")),
        tabPanel("About digilogger",
                 includeMarkdown("about.md")),
        tabPanel("Session information",
                 uiOutput('sessioninformation'))
      )
    }
  })
  
}
