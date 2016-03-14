library(testthat)

simpf <- function(a = 1, b, d, ...) return(5)
not_expected_error <- 'Function is called with arguments different from expected!'

test_that('Always returns specified value', {
  stub_of_simpf <- stub(simpf)
  stub_of_simpf$returns(10)
  stub_func <- stub_of_simpf$build()
  expect_equal(stub_func(1, 2, 3, 4), 10)
  expect_equal(stub_func(1, 3, 3, b = 4), 10)
  expect_equal(stub_func(1, a = 5, 3, 4), 10)
})

test_that('Always throws error with specified msg', {
  stub_of_simpf <- stub(simpf)
  throw_msg <- 'err msg xyz'
  stub_of_simpf$throws(throw_msg)
  stub_func <- stub_of_simpf$build()
  expect_error(stub_func(1, 2, 3, 4), throw_msg)
  expect_error(stub_func(1, 3, 3, b = 4), throw_msg)
  expect_error(stub_func(1, a = 5, 3, 4), throw_msg)
})

test_that('Always checks the function call with expected arguments (exact set) and returns null', {
  stub_of_simpf <- stub(simpf)
  stub_of_simpf$expects(a = 1, b = 2, d = 3, c = 4)
  stub_func <- stub_of_simpf$build()

  expect_null(stub_func(1, 2, 3, c = 4))
  expect_null(stub_func(c = 4, 2, a = 1, 3))

  expect_error(stub_func(2, 3, 3, c = 4), not_expected_error)
  expect_error(stub_func(2, 3, 3), not_expected_error)
  expect_error(stub_func(c = 4, a = 3, 1, 2), not_expected_error)
  expect_error(stub_func(a = 3, 1, 2), not_expected_error)
})

test_that('Always checks the function call with expected arguments (exact set) and returns the specified value', {
  stub_of_simpf <- stub(simpf)
  stub_of_simpf$expects(a = 1, b = 2, d = 3, c = 4)
  stub_of_simpf$returns('a')
  stub_func <- stub_of_simpf$build()

  expect_equal(stub_func(1, 2, 3, c = 4), 'a')
  expect_equal(stub_func(c = 4, 2, a = 1, 3), 'a')

  expect_error(stub_func(2, 3, 3, c = 4), not_expected_error)
  expect_error(stub_func(2, 3, 3), not_expected_error)
  expect_error(stub_func(c = 4, a = 3, 1, 2), not_expected_error)
})

test_that('Always checks the function call with expected arguments (exact set) and throws error with specified msg', {
  stub_of_simpf <- stub(simpf)
  stub_of_simpf$expects(a = 1, b = 2, d = 3, c = 4)
  stub_of_simpf$throws('err msg')
  stub_func <- stub_of_simpf$build()

  expect_error(stub_func(1, 2, 3, c = 4), 'err msg')
  expect_error(stub_func(c = 4, 2, a = 1, 3), 'err msg')

  expect_error(stub_func(2, 3, 3, c = 4), not_expected_error)
  expect_error(stub_func(2, 3, 3), not_expected_error)
  expect_error(stub_func(c = 4, a = 3, 1, 2), not_expected_error)
})
