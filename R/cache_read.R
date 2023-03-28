cache_read <- function(context, desc = NULL) {
  
  path <- file.path(cache_dir(), paste0(context, ".json"))
  
  if (!file.exists(path)) {
    return(NULL)
  }
  
  cache <- get_json(path)
  
  if (is.null(desc)) {
    return(cache)
  }
  
  out <- cache |> 
    keep(~ identical(.[["desc"]], desc))
  
  if (length(out) == 0L) {
    return(NULL)
  }
  
  out
  
}
