test_that("multiplication works", {
  
  expect_snapshot(str(iris))
  expect_equal(dummy_function(1), 3)
  
})
