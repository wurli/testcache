#' Run a test
#' 
#' This is a drop-in replacement for [testthat::test_that()], which first
#' checks a cache file to see if there have been any changes to the code
#' for the test, or any functions which it directly or indirectly calls. If
#' there haven't been any changes, the test is skipped.
#'
#' @param desc,code Passed to [testthat::test_that()]
#'
#' @return When run interactively, returns `invisible(TRUE)` if all tests pass, 
#'   otherwise throws an error.
#'   
#' @export
test_that <- function(desc, code) {
  
  context           <- curr_context()
  cache             <- cache_read(context, desc)[[1]]
  code              <- enexpr(code)
  pkg_funs          <- my_fns()
  pkg_funs_code     <- pkg_funs |> map(deparse)
  ...called_funs... <- NULL
  
  if (!is.null(cache)) {
    
    skip <- all(
      identical(cache$code, deparse(code)),
      !any_outdated(cache$called_functions),
      !cache$cache_off
    )
    
    if (skip) {
      
      return(testthat::test_that(desc, {
        expect_cache(
          failure = cache$results$fail,
          success = cache$results$ok,
          skip    = cache$results$skip,
          warning = cache$results$warn
        )
      }))
    
    }
    
  }
  
  mocked_funs <- pkg_funs |> 
    imap(function(fun, fun_name) {
      function(...) {
        ...called_funs... <<- union(...called_funs..., fun_name)
        fun(...)
      }
    })
  
  local_mock(!!!mocked_funs)
  
  
  cur_results <- function() {
    res <- testthat::get_reporter()$reporters[[1]]
    
    c(fail = res$ctxt_n_fail %||% 0L,
      ok   = res$ctxt_n_ok   %||% 0L,
      skip = res$ctxt_n_skip %||% 0L,
      warn = res$ctxt_n_warn %||% 0L)
  }
  
  pre_test_results <- cur_results()
  
  env <- parent.frame()
  env_bind_lazy(env, desc = desc, code = code)
  
  eval(
    bquote(testthat::test_that(.(desc), .(code))),
    env
  )
  
  cache_off <- the$cache_off
  env_poke(the, "cache_off", FALSE)
  
  post_test_results <- cur_results()
  
  res <- as.list(post_test_results - pre_test_results)
  
  write_cache <- all(unlist(res[c("fail", "skip", "warn")]) == 0)
  
  if (!write_cache) {
    cache_delete(context, desc)
  } else {
    cache <- list(
      desc = desc,
      code = deparse(code),
      cache_off = cache_off,
      results = res,
      called_functions = pkg_funs_code[...called_funs...] 
    )
    
    cache_write(cache, context)
  }
  
  invisible(...called_funs...)
  
}
