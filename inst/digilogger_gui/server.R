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
                 uiOutput('sessioninformation')),
        tabPanel("Technology",
                 h1("VideoScan"),
                 h2("VideoScan"),
                 tags$article('In our laboratory a microfluidic microbead chip system 
                 for VideoScan technology was adopted. Eight carboxylated microbeads, 
                 differing in size and fluorescence, were coated with targets like unconjugated 
                 and fluorescence labeled probes (EUB338, Vimentin-Atto647N), 
                 as well as unconjugated antibodies (anti CRP IgG). 
                 After the immobilization of the microbeads on a commerical chip (flex.flow slide) 
                 the specific assay components were consecutively pumped through capillaries to the 
                 flow cell. Finally, the assay performance of the flow cell was measured using VideoScan technology.

                Microfluidic chips
                 (flex.flow, bi.FLOW GmbH) were prepared by microbead immobilization
                 on an adhesive tape in flow cell and also by filling reagent
                 reservoirs with relevant assay components. During assay the
                 components are pumped through capillaries. After incubation and
                 washing steps the microbeads in the flow cell were measured using the
                 VideoScan technology. The surface fluorescence intensity is reported
                 as referenced mean fluorescence intensity (refMFI).'),
                 tags$img(src='vs.png', height=500, width=800),
                 h2("Multiplex assay"),
                 tags$article('5a-c represents the scheme of combined assay performance. 
                              All microbead population expose the expected results from 
                              single assays. There is an increase of fluorescence signal 
                              of CO424 and CO425 0 to 2.3 (hybridization assay - EUB338), 
                              a decrease of fluorescence signal of CO426 and CO427 1.6 to 
                              1.0 (hybridization assay – Vimentin-BHQ2), no change of 
                              fluorescence signal for CO428 and CO429 0 to 0 (negative 
                              control) and also an increase of fluorescence 
                              signal for CO430 to CO431 0 to 3.0 (ELISA – CRP).'),
                 tags$img(src='data.png', height=500, width=800))
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
