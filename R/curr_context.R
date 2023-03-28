curr_context <- function() {
  
  reporter <- testthat::get_reporter()
  context <- reporter$.context
  
  if (!is.null(context)) {
    return(context)
  }
  
  context <- curr_context_rstudio()
  
  context
  
}

curr_context_rstudio <- function() {
  
  if (!requireNamespace("rstudioapi") || 
      !rstudioapi::isAvailable()) {
    
    cli_abort(
      "Cannot check cache",
      .envir = caller_env()
    )
    
  }
  
  filename <- basename(rstudioapi::getActiveDocumentContext()$path)
  
  if (identical(filename, "")) {
    cli_abort(
      c(
        "Cannot check cache",
        i = "Tests should be executed from source, not from the console"
      ),
      .envir = caller_env()
    )
  }
  
  if (!grepl("^test[-_]", filename) || !grep("[.][rR]", filename)) {
    cli_abort(
      c(
        "The current file {.file {filename}} is not a unit test",
        i = "Unit test files should be R scripts starting with {.code test-}"
      ),
      .envir = caller_env()
    )
  }
  
  filename <- sub("^test[-_]", "", filename)
  filename <- sub("[.][Rr]$", "", filename)
  
  filename
  
}

