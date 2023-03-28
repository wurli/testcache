
test_that("dummy() works", {
  
  cache_off()
  
  expect_equal(dummy(1), 2)
  expect_equal(2, 1 + 1)
  
})

test_that("Another snapshot", {
  
  expect_equal(dummy(1), 2)
  
})
