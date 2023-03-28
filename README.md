
<!-- README.md is generated from README.qmd. Please edit that file -->

# Method

`testcache::test_that()` is a drop-in replacement for
`testthat::test_that()`:

- The first time a test with caching gets run, it creates a file in
  `tests/testthat/_cache/` to indicate which functions get called,
  directly or indirectly, during the test. It also saves some
  information about the test itself, such as the description, code used
  and results.

- When the test is called subsequently, if it hasn’t changed it doesn’t
  get run - instead, it is simulated so the results are still shown. A
  test is considered to have not changed if the `code` argument to
  `test_that()` is the same, *and* none of the functions which are
  directly or indirectly called by the test have changed.

- Information about caching is displayed in the normal testthat
  messaging by use of a custom reporter `CacheReporter`, which is set as
  the default reporter using the global option
  `testthat.default_reporter`
