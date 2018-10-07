#' Import of Data from the VideoScan System
#'
#' vs.import() is a function to import a file from the VideoScan system.
#' The \code{\link[utils]{read.csv}} is used internally.
#'
#'
#' @param file is the file that contains.
#' @return The output of the vs.import() function is a data.frame
#' @author Stefan Roediger, Michal Burdukiewicz 
#' @keywords import data
#' @examples
#'
#' # Import a csv file from the VideoScan systems
#' file <- "/home/tux/Work/paper/digilogger/inst/Projekt009383-19-09-2018_FranziD_Chip119_CRP_50_nI_Block.csv"
#' vs.import(file)
#'
#' @export

vs.import <- function(file) {

  # Read csv file via readLines() to fetch all needed data later on.
  file.readLines <- readLines(file)

  res.md5sum <- tools::md5sum(file)
  
  res.date <- as.Date(strsplit(gsub('"', "", file.readLines[3]), ";")[[1]][2])
  res.time <- strsplit(gsub('"', "", file.readLines[3]), ";")[[1]][3]

  # Split all data blocks by the semicolons.
  res.readLine <- strsplit(file.readLines, ";")

  # Assign the project name to the object project.name.
  project.name <- res.readLine[[1]][2]
  names(project.name) <- "project name"

  # Assign the profile name to the object profile.name.
  profile.name <- res.readLine[[2]][2]
  names(profile.name) <- "profile name"

  LOT <- res.readLine[[4]]

  # Define the columns that contain the measured data.
  values <- c(
    "Mittelwerte", "Standardabweichungen",
    "Ereignisanzahlen", "Wellinformationen"
  )
  
  
  

  # Determine the positions of "Mittelwerte", "Standardabweichungen",
  # "Ereignisanzahlen", "Wellinformationen"
  res.values <- lapply(values, function(i) last(grep(i, x = file.readLines)))

#   names(res.values) <- values

  # Aggregate the needed data as list and removing quotation marks
  res.values.aggr <- lapply(res.values, function(i) {
    gsub('"', "", res.readLine[[i + 2]])
  })

  names(res.values.aggr) <- values

  # Length of entries in Wellinformationen
  res.length.Wellinformationen <- length(res.values.aggr[["Wellinformationen"]])

  # Names of targets according to the Wellinformationen
  targets <- res.values.aggr[["Wellinformationen"]]


  end.targets <- which(targets %in% c("Beadanzahl", "Rohdatendatei"))

  patient.information <- res.values.aggr[["Wellinformationen"]][4L:8]
#   names(patient.information) <- c("ID", "surname", "forename", "birthday", "sex")

  number.of.targets <- as.numeric(targets[11]) - 3

  res.data.tmp <- suppressWarnings(do.call(cbind, lapply(1L:3, function(i) {
    as.numeric(gsub(",", ".", res.values.aggr[[i]], fixed = TRUE))
  })))

  target.names <- targets[-c(1L:11, which(targets %in% tail(targets, 3)))]

  res.data <- data.frame(
    ID = rep(patient.information[1], number.of.targets),
    name = rep(patient.information[2], number.of.targets),
    forename = rep(patient.information[3], number.of.targets),
    birthday = rep(patient.information[4], number.of.targets),
    sex = rep(patient.information[5], number.of.targets),
    examination.date = rep(res.date, number.of.targets),
    examination.time = rep(res.time, number.of.targets),
    target.names,
    res.data.tmp[-c(1:5, (end.targets[2] - 8):end.targets[2]), ],
    rep(profile.name, number.of.targets),
    rep(project.name, number.of.targets),
    LOT = rep(LOT[1], number.of.targets),
    md5sum = rep(res.md5sum, number.of.targets)[[1]]
  )

  # Give all columns English names
  colnames(res.data) <- c(
    "ID",
    "Name",
    "Forename",
    "Birthday",
    "Sex",
    "Examination date",
    "Examination time",
    "Biomarker",
    "Value", "Standard deviation", "Events",
    "Profile",
    "Project",
    "LOT",
    "md5sum"
  )

  # Change pseudo Zero to NA
  res.data[res.data[, "Events"] == 0, "Standard deviation"] <- NA

  res.data
}
