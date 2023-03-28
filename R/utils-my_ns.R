my_ns <- function() {
  asNamespace(unname(desc::desc()$get("Package")))
}