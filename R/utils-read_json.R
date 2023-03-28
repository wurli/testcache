read_json <- function(x) {
  jsonlite::read_json(
    x, 
    simplifyVector = TRUE, 
    simplifyMatrix = FALSE,
    simplifyDataFrame = FALSE
  )
}