test_that("mapping class is preserved when adding uneval objects", {
  p <- ggplot2::ggplot(mtcars) + ggplot2::aes(wt, mpg)
  expect_identical(class(p$mapping), "uneval")
})
