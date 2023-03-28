cache_dir <- function() {
  
  wd <- getwd()
  
  maybe_create <- function(dir) {
    if (!dir.exists(dir)) {
      cli_alert_info("Creating {.pkg testcache} cache directory {.file {dir}}")
      dir.create(dir, recursive = TRUE)
    }
    dir
  }
  
  if (identical(basename(wd), "testthat")) {
    path <- file.path(wd, "_testcache")
    return(maybe_create(path))
  } 
  
  rproj_file <- list.files(wd, "\\.Rproj$")
  wd_is_proj <- length(rproj_file) > 0
  
  if (wd_is_proj) {
    path <- file.path(wd, "tests", "testthat", "_testcache")
    return(maybe_create(path))
  }
  
  cli_abort(c(
    "{.code tests} directory not found"
  ))
  
}