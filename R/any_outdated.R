any_outdated <- function(x) {
  
  defs_curr <- my_fns() |> map(deparse)
  
  if (!all(names(x) %in% names(defs_curr))) {
    return(TRUE)
  }
  
  for (fun_name in names(x)) {
    
    if (!identical(x[[fun_name]], defs_curr[[fun_name]])) {
      return(TRUE)
    }
    
  }
  
  FALSE
  
}