df <- tibble::tibble(x = 1)

test_that("multiplication works", {
  
  y <- df |>
    dplyr::mutate(y = x + 1) |>
    dplyr::pull(y)
  
  expect_equal(y, 2)
  
  expect_equal(1 + 1, 2)
  
  expect_snapshot(str(iris))
  expect_equal(dummy_function(1), 3)
  
})
