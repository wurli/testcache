write_json <- function(x, path) {
  
  x |> 
    jsonlite::toJSON() |> 
    jsonlite::prettify() |> 
    brio::writeLines(path)
  
  invisible(x)
  
}