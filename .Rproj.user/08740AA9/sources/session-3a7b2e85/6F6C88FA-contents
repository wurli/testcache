cache_write <- function(x, context) {
  
  stopifnot(
    is.list(x),
    length(x) == 5L,
    all(c("desc", "code", "cache_off", "results", "called_functions") %in% names(x))
  )
  
  path <- file.path(cache_dir(), paste0(context, ".json"))
  base <- if (file.exists(path)) read_json(path) else list()
  
  discard <- map_lgl(base, ~ identical(x$desc, .$desc))
  
  to_write <- c(base[!discard], list(x))
  
  to_write <- to_write |> 
    map(function(el) {
      el[["desc"]] <- jsonlite::unbox(el[["desc"]])
      el
    }) 
  
  write_json(to_write, path)
  
  invisible(x)
  
}
