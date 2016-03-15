library(testthat)

simpf <- function(a = 1, b, d, ...) return(5)
not_expected_error <- 'Function is called with arguments different from expected!'

test_that('withArgs: It returns the specified value when expected arguments are part of the function call on the nth time running of the function', {
  stub_of_simpf <- stub(simpf)
  stub_of_simpf$onCall(3)$withArgs(g = 'a')$returns(10)
  stub_func <- stub_of_simpf$build()

  expect_null(stub_func(1, 2, 3, g = 'a'))
  expect_null(stub_func(1, 2, 3, g = 'a'))
  expect_equal(stub_func(1, 2, 3, g = 'a'), 10)
})

test_that('withArgs: It throws error with the specified message when expected arguments are part of the function call on the nth time running of the function', {
  stub_of_simpf <- stub(simpf)
  stub_of_simpf$onCall(3)$withArgs(g = 'a')$throws('error is nice')
  stub_func <- stub_of_simpf$build()

  expect_null(stub_func(1, 2, 3, g = 'a'))
  expect_null(stub_func(1, 2, 3, g = 'a'))
  expect_error(stub_func(1, 2, 3, g = 'a'), 'error is nice')
})
