#
# This is a Shiny web application. 
#

library(shiny)
library(digilogger)
library(knitr)

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
        shiny::tabPanel("Files",
                        dataTableOutput('files'),
                        includeMarkdown("files.md")),
        shiny::tabPanel("Duplicates",
                        dataTableOutput('duplicates')),
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
      # User has not uploaded a file(s) yet
      NULL
    } else {
      do.call(rbind, lapply(input$datafile$datapath, vs.import))
    }
  })
  
  # Generate a table of the dataset
  output$filetable <- renderDataTable({
    filedata()[, c("ID", 
             "Name",
             "Forename", 
             "Birthday", 
             "Sex", 
             "Examination date", 
             "Examination time", 
             "Biomarker", 
             "Value", 
             "Standard deviation", 
             "Events"
             )]
  })
  
  output$summary <- renderTable({
    summary(filedata())
  })
  
  output$files <- renderDataTable({
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
  
  output$duplicates <-renderDataTable({
    dat <-filedata()
    df <- data.frame(ID = dat$ID, Project = dat$Project, md5sum = dat$md5sum, File = dat$File)
    unique.files <- unique(df$File)
    
    res.files <- do.call(rbind, lapply(1:length(unique.files), function(i){
      index <- df$File == unique.files[i]
      unique.md5sum <- unique(df[index, "md5sum"])
      data.frame(File = unique.files[i], md5sum = unique.md5sum)
    }))
    
    res.files <- data.frame(res.files, 
                            Unique = as.character(ifelse(summary(res.files$md5sum) == 1, 
                                                         "True", "potential dublication")))
    res.files
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

