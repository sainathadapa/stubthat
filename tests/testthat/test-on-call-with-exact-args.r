library(testthat)

simpf <- function(a = 1, b, d, ...) return(5)
not_expected_error <- 'Function is called with arguments different from expected!'

test_that('withExactArgs: It returns the specified value when called with the exact set of expected arguments on the nth time running of the function', {
  stub_of_simpf <- stub(simpf)
  stub_of_simpf$onCall(3)$withExactArgs(a = 1, b = 2, d = 3, c = 4)$returns(10)
  stub_func <- stub_of_simpf$build()

  expect_null(stub_func(1, 2, 3, c = 4))
  expect_null(stub_func(1, 2, 3, c = 4))
  expect_equal(stub_func(1, 2, 3, c = 4), 10)
})

test_that('withExactArgs: It throws error with the specified message when called with the exact set of expected arguments on the nth time running of the function', {
  stub_of_simpf <- stub(simpf)
  err_msg <- 'error is good'
  stub_of_simpf$onCall(2)$withExactArgs(a = 1, b = 2, d = 3, c = 4)$throws(err_msg)
  stub_func <- stub_of_simpf$build()

  expect_null(stub_func(1, 2, 3, c = 4))
  expect_error(stub_func(1, 2, 3, c = 4), err_msg)
})
