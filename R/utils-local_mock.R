# Similar to `mockr::local_mock()` but doesn't create a mask environment.
# This is because when function a() calls function b(), while a() may
# be mocked, it will still call b() from the original environment, not
# the masked one. Mocking functions in the original environment is a bit 
# riskier, but more effective.
local_mock <- function(..., .env = my_ns()) {
  
  mocked_funs <- list2(...)
  originals <- mget(names(mocked_funs), .env)
  
  locked_bindings <- imap(mocked_funs, function(fun, name) {
    locked <- bindingIsLocked(name, .env)
    if (locked) unlockBinding(name, .env)
    locked
  })
  
  env_bind(.env, !!!mocked_funs)
  
  withr::defer(
    {
      env_bind(.env, !!!originals)
      imap(locked_bindings, function(is_locked, name) {
        if (is_locked) lockBinding(name, .env)
      })
    },
    envir = parent.frame()
  )
  
  invisible()
}