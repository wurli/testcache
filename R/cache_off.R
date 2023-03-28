cache_off <- function() {
  env_poke(the, "cache_off", TRUE)
  invisible()
}

