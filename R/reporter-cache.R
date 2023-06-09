#' Test reporter: interactive progress bar of errors.
#'
#' @description
#' `CacheReporter` is a version of [testthat::ProgressReporter] that also 
#' displays information about the number of cached tests. When loaded,
#' {testcache} sets this to be the default reporter by setting
#' `options(testthat.default_reporter = CacheReporter)`
#'
#' @export
#' @family reporters
CacheReporter <- R6::R6Class("CacheReporter",
  inherit = testthat::ProgressReporter,
  public = list(
    
    n_cache = 0L,
    ctxt_n_cache = 0L,
    
    start_context = function(context) {
      self$ctxt_n_cache <- 0L
      super$start_context(context)
    },
    
    show_header = function() {
      self$cat_line(
        colourise(cli::symbol$tick, "success"), " | ",
        colourise("F", "failure"), " ",
        colourise("W", "warning"), " ",
        colourise("S", "skip"), " ",
        colourise(" OK", "success"),
        " | ", colourise("CACHE", "cache"),
        " | ", "Context"
      )
    },
    
    show_status = function(complete = FALSE, time = 0, pad = FALSE) {
      
      # Fairly yucky hack concatenating the number of cached expectations and
      # the test filename ('context'). But doing this way means we don't have 
      # to copy the whole source code for testthat::ProgressReporter$show_status
      old_name <- self$ctxt_name
      self$ctxt_name <- paste0(
        colourise(
          sprintf("%-5s", paste0(
            self$ctxt_n_cache, "/",
            sum(self$ctxt_n_ok, self$ctxt_n_fail, self$ctxt_n_warn, self$ctxt_n_skip)
          )), 
          "cache"
        ), 
        " | ", self$ctxt_name
      )
      
      super$show_status(complete, time, pad)
      
      self$ctxt_name <- old_name
      
    },
    
    
    add_result = function(context, test, result) {
      
      if (!expectation_cache(result)) {
        return(super$add_result(context, test, result))
      }
      
      result <- result$expectations
      
      self$ctxt_n       <- self$ctxt_n + 1L
      
      self$n_cache      <- self$n_cache      + sum(unlist(result))
      self$ctxt_n_cache <- self$ctxt_n_cache + sum(unlist(result))
      
      self$n_fail       <- self$n_fail       + result$failure
      self$ctxt_n_fail  <- self$ctxt_n_fail  + result$failure
      self$n_skip       <- self$n_skip       + result$skip
      self$ctxt_n_skip  <- self$ctxt_n_skip  + result$skip
      self$n_warn       <- self$n_warn       + result$warn
      self$ctxt_n_warn  <- self$ctxt_n_warn  + result$warn
      self$n_ok         <- self$n_ok         + result$success
      self$ctxt_n_ok    <- self$ctxt_n_ok    + result$success
      
      self$show_status()
      
    },
    
    end_reporter = function() {
      self$cat_line()
      
      colour_if <- function(n, type) {
        colourise(n, if (n == 0) "success" else type)
      }
      
      self$rule(cli::style_bold("Results"), line = 2)
      time <- proc.time() - self$start_time
      if (time[[3]] > self$min_time) {
        self$cat_line("Duration: ", sprintf("%.1f s", time[[3]]), col = "cyan")
        self$cat_line()
      }
      
      if (self$n_skip > 0) {
        self$rule("Skipped tests ", line = 1)
        self$cat_line(skip_bullets(self$skips$as_list()))
        self$cat_line()
      }
      
      status <- summary_line(self$n_fail, self$n_warn, self$n_skip, self$n_cache, self$n_ok)
      self$cat_line(status)
      
      if (self$is_full()) {
        self$rule("Terminated early", line = 2)
      }
      
      if (!self$show_praise || stats::runif(1) > 0.1) {
        return()
      }
      
      self$cat_line()
      if (self$n_fail == 0) {
        self$cat_line(colourise(praise(), "success"))
      } else {
        self$cat_line(colourise(encourage(), "error"))
      }
    }
  )
)

spinner <- function(frames, i) {
  frames[((i - 1) %% length(frames)) + 1]
}

strpad <- function(x, width = cli::console_width()) {
  n <- pmax(0, width - cli::ansi_nchar(x))
  paste0(x, strrep(" ", n))
}

praise <- function() {
  plain <- c(
    "You rock!",
    "You are a coding rockstar!",
    "Keep up the good work.",
    "Woot!",
    "Way to go!",
    "Nice code.",
    praise::praise("Your tests are ${adjective}!"),
    praise::praise("${EXCLAMATION} - ${adjective} code.")
  )
  utf8 <- c(
    "\U0001f600", # smile
    "\U0001f973", # party face
    "\U0001f638", # cat grin
    paste0(strrep("\U0001f389\U0001f38a", 5), "\U0001f389"),
    "\U0001f485 Your tests are beautiful \U0001f485",
    "\U0001f947 Your tests deserve a gold medal \U0001f947",
    "\U0001f308 Your tests are over the rainbow \U0001f308",
    "\U0001f9ff Your tests look perfect \U0001f9ff",
    "\U0001f3af Your tests hit the mark \U0001f3af",
    "\U0001f41d Your tests are the bee's knees \U0001f41d",
    "\U0001f4a3 Your tests are da bomb \U0001f4a3",
    "\U0001f525 Your tests are lit \U0001f525"
  )
  
  x <- if (cli::is_utf8_output()) c(plain, utf8) else plain
  sample(x, 1)
}

encourage <- function() {
  x <- c("Keep trying!", "Don't worry, you'll get it.", "No one is perfect!", 
         "No one gets it right on their first try", "Frustration is a natural part of programming :)", 
         "I believe in you!")
  sample(x, 1)
}

colourise <- function(text, 
                      as = c("success", "cache", "skip", "warning", "failure", "error")) {
  if (has_colour()) {
    unclass((make_ansi_style(testcache_style(as)))(text))
  } else {
    text
  }
}

has_colour <- function() {
  isTRUE(getOption("testthat.use_colours", TRUE)) && cli::num_ansi_colors() > 1L
}

testcache_style <- function(type = c("success", "cache", "skip", "warning", "failure", "error")) {
  type <- match.arg(type)
  c(success = "green", cache = "pink", skip = "blue", warning = "magenta", 
    failure = "orange", error = "orange")[[type]]
}

summary_line <- function(n_fail, n_warn, n_skip, n_cache, n_pass) {
  colourise_if <- function(text, colour, cond) {
    if (cond) colourise(text, colour) else text
  }
  
  # Ordered from most important to least important
  paste0(
    "[ ",
    colourise_if("FAIL",  "failure", n_fail  > 0), " ", n_fail,  " | ",
    colourise_if("WARN",  "warn",    n_warn  > 0), " ", n_warn,  " | ",
    colourise_if("SKIP",  "skip",    n_skip  > 0), " ", n_skip,  " | ",
    colourise_if("PASS",  "success", n_fail == 0), " ", n_pass,  " | ",
    colourise_if("CACHE", "cache", n_cache > 0), " ", n_cache,
    " ]"
  )
}

skip_bullets <- function(skips) {
  skips <- unlist(skips)
  skips <- gsub("Reason: ", "", skips)
  skips <- gsub(":?\n(\n|.)+", "", skips) # only show first line
  
  tbl <- table(skips)
  paste0(cli::symbol$bullet, " ", names(tbl), " (", tbl, ")")
}