library(testthat)

simpf <- function(a = 1, b, d, ...) return(5)
not_expected_error <- 'Function is called with arguments different from expected!'

test_that('It returns the specified value when called with the exact set of expected arguments on the nth time running of the function', {
  stub_of_simpf <- stub(simpf)
  stub_of_simpf$onCall(3)$withExactArgs(a = 1, b = 2, d = 3, c = 4)$returns(10)
  stub_func <- stub_of_simpf$build()

  expect_null(stub_func(1, 2, 3, c = 4))
  expect_null(stub_func(1, 2, 3, c = 4))
  expect_equal(stub_func(1, 2, 3, c = 4), 10)
})

test_that('It throws error with the specified message when called with the exact set of expected arguments on the nth time running of the function', {
  stub_of_simpf <- stub(simpf)
  err_msg <- 'error is good'
  stub_of_simpf$onCall(2)$withExactArgs(a = 1, b = 2, d = 3, c = 4)$throws(err_msg)
  stub_func <- stub_of_simpf$build()

  expect_null(stub_func(1, 2, 3, c = 4))
  expect_error(stub_func(1, 2, 3, c = 4), err_msg)
})

test_that('It returns the specified value when expected arguments are part of the function call on the nth time running of the function', {
  stub_of_simpf <- stub(simpf)
  stub_of_simpf$onCall(3)$withArgs(g = 'a')$returns(10)
  stub_func <- stub_of_simpf$build()

  expect_null(stub_func(1, 2, 3, g = 'a'))
  expect_null(stub_func(1, 2, 3, g = 'a'))
  expect_equal(stub_func(1, 2, 3, g = 'a'), 10)
})

test_that('It throws error with the specified message when expected arguments are part of the function call on the nth time running of the function', {
  stub_of_simpf <- stub(simpf)
  stub_of_simpf$onCall(3)$withArgs(g = 'a')$throws('error is nice')
  stub_func <- stub_of_simpf$build()

  expect_null(stub_func(1, 2, 3, g = 'a'))
  expect_null(stub_func(1, 2, 3, g = 'a'))
  expect_error(stub_func(1, 2, 3, g = 'a'), 'error is nice')
})

test_that('It does the right thing on the nth time running of the function', {
  stub_of_simpf <- stub(simpf)
  stub_of_simpf$onCall(3)$returns(10)
  stub_of_simpf$onCall(5)$throws('pqrst')
  stub_func <- stub_of_simpf$build()

  expect_null(stub_func(1, 2, 3))
  expect_null(stub_func(2, 3, 1))
  expect_equal(stub_func(3, 1, 2), 10)
  expect_null(stub_func(5, 6, 7))
  expect_error(stub_func(2, 3, 1), 'pqrst')
})
