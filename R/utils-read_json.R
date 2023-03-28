read_json <- function(x) {
  jsonlite::read_json(
    x, 
    simplifyVector = TRUE, 
    simplifyMatrix = FALSE,
    simplifyDataFrame = FALSE
  )
}

# Version of read_json() memoised per call
get_json <- function(x) {
  
  out <- the$cache_vals[[x]]
  if (!is.null(out)) {
    return(out)
  }
  
  out <- read_json(x)
  
  the$cache_vals[[x]] <- out
  
  withr::defer(
    the$cache_vals[[x]] <- NULL,
    sys.frame(1)
  )
  
  out
  
}