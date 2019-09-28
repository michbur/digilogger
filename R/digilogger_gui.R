#' Run digilogger GUI
#'
#' @details This app allows you to upload a single data file and to explore it via several tabs,
#' one with the summary of measures, one with settings and one with plots.
#' The app can e.g. be used after one day of field work to quickly check files.
#'
#' @importFrom shiny runApp
#' @examples
#' \dontrun{
#' digilogger_gui()
#' }
#' @export
digilogger_gui <- function() {
  runApp(system.file("digilogger_gui", package = "digilogger"))
}

