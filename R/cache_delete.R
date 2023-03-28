cache_delete <- function(context, desc = NULL) {
  
  path <- file.path(cache_dir(), paste0(context, ".json"))
  
  if (!file.exists(path)) {
    return(NULL)
  }
  
  if (is.null(desc)) {
    unlink(path)
    return(NULL)
  }
  
  cache <- get_json(path)
  
  new <- cache |> 
    keep(~ !identical(.[["desc"]], desc))
  
  write_json(new, path)
  
  NULL
}