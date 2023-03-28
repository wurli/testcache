expect_cache <- function(success = 0L, failure = 0L, error = 0L, skip = 0L, warning = 0L) {
  
  exp <- structure(
    list(
      message = "",
      srcref = NULL,
      trace = NULL,
      expectations = list(
        success = success,
        failure = failure,
        error = error,
        skip = skip,
        warning = warning
      )
    ),
    class = c(
      .subclass = NULL,
      "expectation_cache",
      "expectation",
      "condition"
    )
  )
  
  withRestarts(
    signalCondition(exp),
    continue_test = function(e) NULL
  )
}

expectation_cache <- function(exp) {
  stopifnot(testthat::is.expectation(exp))
  type <- gsub("^expectation_", "", class(exp)[[1]])
  type == "cache"
}