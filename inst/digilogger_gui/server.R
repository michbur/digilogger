library(shiny)
library(digilogger)
library(knitr)
library(DT)
library(dplyr)
library(ggplot2)
library(plotly)

options(shiny.maxRequestSize=10*1024^2)

options(DT.options = list(dom = "Brtip",
                          buttons = c("copy", "csv", "excel", "print"),
                          pageLength = 50
))

my_DT <- function(x)
  datatable(x, escape = FALSE, extensions = "Buttons", filter = "top", rownames = FALSE) %>% 
  formatStyle(1L:ncol(x), color = "black")

Sys.setlocale("LC_TIME", "C")

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
  
  output[["timeplot"]] <- renderPlotly({
    (ggplot(filedata(), aes(x = `Examination date`, y = Value, color = Biomarker)) +
       geom_point() +
       geom_line() +
       theme_bw(base_size = 15) +
       theme(legend.position = "bottom") +
       facet_wrap(~ ID, ncol = 1)) %>% 
      ggplotly()
  })
  
  coord <- reactiveValues(x = NULL, y = NULL)
  
  observeEvent(input[["plot_click"]], { 
    coord[["y"]] <- input[["plot_click"]][["y"]]
    coord[["x"]] <- input[["plot_click"]][["x"]]
  })
  
  
  output[["assessment_plot"]] <- renderPlot({
    p <- filter(filedata(), Biomarker == input[["selected_biomarker"]])  %>% 
      ggplot(aes(x = `Examination date`, y = Value, color = ID)) +
      geom_point() +
      geom_line() +
      theme_bw(base_size = 15) +
      theme(legend.position = "bottom") 

    if(!is.null(coord[["y"]]))  
      p <- p + geom_hline(yintercept = coord[["y"]])
    
    p
  })
  
  output[["assessment_dt"]] <- renderDataTable({

    ass_dt <- filter(filedata(), Biomarker == input[["selected_biomarker"]]) %>% 
      group_by(ID) %>% 
      filter(`Examination date` == max(`Examination date`)) %>% 
      filter(Value == max(Value)) %>% 
      select(ID, Name, Forename, Value) 
    
    if(!is.null(coord[["y"]]))  
      ass_dt <- mutate(ass_dt, Assessment = ifelse(Value > coord[["y"]], "sick", "healthy"))
    
    ass_dt
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
                 plotlyOutput("timeplot", height = 160 + 190*nlevels(filedata()[["ID"]]))),
        tabPanel("Assessment chart",
                 selectInput("selected_biomarker", 
                             label = "Select a biomarker:", 
                             choices = levels(filedata()[["Biomarker"]]), 
                             selected = "Wert von C0430"),
                 plotOutput("assessment_plot", click = "plot_click"),
                 dataTableOutput("assessment_dt")),
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
