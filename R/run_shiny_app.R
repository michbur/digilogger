#' Run a built-in Shiny App.
#'
#' @details This app allows you to upload a single data file and to explore it via several tabs,
#' one with the summary of measures, one with settings and one with plots.
#' The app can e.g. be used after one day of field work to quickly check files.
#'
#' @examples
#' \dontrun{
#' run_shiny_app()
#' }
#' @export
run_shiny_app <- function() {
  if (!requireNamespace("shiny", quietly = TRUE)) {
    message("run_shiny_app needs the shiny package, \n
              Install it via install.packages('shiny')")
    return(NULL)
  }

    # nocov start
    app_dir <- system.file("shiny-examples",
                          "digiloger_gui", package = "digilogger")
    if (app_dir == "") {
        stop("Could not find example directory. Try re-installing `digilogger`.",
             call. = FALSE)
    }

    shiny::runApp(app_dir, display.mode = "normal")
}
# nocov end
