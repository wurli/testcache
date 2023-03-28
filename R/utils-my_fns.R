my_fns <- function() {
  my_ns() |>
    as.list() |> 
    keep(is.function)
}

