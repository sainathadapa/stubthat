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

test_that('strictlyExpects: It returns the specified value when called with the exact set of expected arguments on the nth time running of the function', {
  stub_of_simpf <- stub(simpf)
  stub_of_simpf$onCall(3)$strictlyExpects(a = 1, b = 2, d = 3, c = 4)$returns(10)
  stub_func <- stub_of_simpf$build()
  
  expect_null(stub_func(1, 2, 3, c = 4))
  expect_null(stub_func(1, 2, 3, c = 4))
  expect_equal(stub_func(1, 2, 3, c = 4), 10)
})

test_that('strictlyExpects: It throws error when not called with the exact set of expected arguments on the nth call', {
  stub_of_simpf <- stub(simpf)
  stub_of_simpf$onCall(3)$strictlyExpects(a = 1, b = 2, d = 3, c = 4)$returns(10)
  stub_func <- stub_of_simpf$build()
  
  expect_null(stub_func(1, 2, 3, c = 4))
  expect_null(stub_func(1, 2, 3, c = 4))
  expect_error(stub_func(1, 2, 3, c = 5), not_expected_error)
})

test_that('withExactArgs: It throws error with the specified message when called with the exact set of expected arguments on the nth time running of the function', {
  stub_of_simpf <- stub(simpf)
  err_msg <- 'error is good'
  stub_of_simpf$onCall(2)$withExactArgs(a = 1, b = 2, d = 3, c = 4)$throws(err_msg)
  stub_func <- stub_of_simpf$build()

  expect_null(stub_func(1, 2, 3, c = 4))
  expect_error(stub_func(1, 2, 3, c = 4), err_msg)
})

test_that('strictlyExpects: It throws error with the specified message when called with the exact set of expected arguments on the nth time running of the function', {
  stub_of_simpf <- stub(simpf)
  err_msg <- 'error is good'
  stub_of_simpf$onCall(2)$strictlyExpects(a = 1, b = 2, d = 3, c = 4)$throws(err_msg)
  stub_func <- stub_of_simpf$build()
  
  expect_null(stub_func(1, 2, 3, c = 4))
  expect_error(stub_func(1, 2, 3, c = 4), err_msg)
})

test_that('strictlyExpects: It throws error when not called with the exact set of expected arguments on the nth call', {
  stub_of_simpf <- stub(simpf)
  err_msg <- 'error is good'
  stub_of_simpf$onCall(2)$strictlyExpects(a = 1, b = 2, d = 3, c = 4)$throws(err_msg)
  stub_func <- stub_of_simpf$build()
  
  expect_null(stub_func(1, 2, 3, c = 4))
  expect_error(stub_func(1, 2, 3, c = 5), not_expected_error)
})

test_that('withArgs: It returns the specified value when expected arguments are part of the function call on the nth time running of the function', {
  stub_of_simpf <- stub(simpf)
  stub_of_simpf$onCall(3)$withArgs(g = 'a')$returns(10)
  stub_func <- stub_of_simpf$build()

  expect_null(stub_func(1, 2, 3, g = 'a'))
  expect_null(stub_func(1, 2, 3, g = 'a'))
  expect_equal(stub_func(1, 2, 3, g = 'a'), 10)
})

test_that('expects: It returns the specified value when expected arguments are part of the function call on the nth time running of the function', {
  stub_of_simpf <- stub(simpf)
  stub_of_simpf$onCall(3)$expects(g = 'a')$returns(10)
  stub_func <- stub_of_simpf$build()
  
  expect_null(stub_func(1, 2, 3, g = 'a'))
  expect_null(stub_func(1, 2, 3, g = 'a'))
  expect_equal(stub_func(1, 2, 3, g = 'a'), 10)
})

test_that('expects: It throws error when expected arguments are not part of the function call on the nth call', {
  stub_of_simpf <- stub(simpf)
  stub_of_simpf$onCall(3)$expects(g = 'a')$returns(10)
  stub_func <- stub_of_simpf$build()
  
  expect_null(stub_func(1, 2, 3, g = 'a'))
  expect_null(stub_func(1, 2, 3, g = 'a'))
  expect_error(stub_func(1, 2, 3, g = 'b'), not_expected_error)
})

test_that('withArgs: It throws error with the specified message when expected arguments are part of the function call on the nth time running of the function', {
  stub_of_simpf <- stub(simpf)
  stub_of_simpf$onCall(3)$withArgs(g = 'a')$throws('error is nice')
  stub_func <- stub_of_simpf$build()

  expect_null(stub_func(1, 2, 3, g = 'a'))
  expect_null(stub_func(1, 2, 3, g = 'a'))
  expect_error(stub_func(1, 2, 3, g = 'a'), 'error is nice')
})

test_that('expects: It throws error with the specified message when expected arguments are part of the function call on the nth time running of the function', {
  stub_of_simpf <- stub(simpf)
  stub_of_simpf$onCall(3)$expects(g = 'a')$throws('error is nice')
  stub_func <- stub_of_simpf$build()
  
  expect_null(stub_func(1, 2, 3, g = 'a'))
  expect_null(stub_func(1, 2, 3, g = 'a'))
  expect_error(stub_func(1, 2, 3, g = 'a'), 'error is nice')
})

test_that('expects: It throws error when expected arguments are not part of the function call on the nth call', {
  stub_of_simpf <- stub(simpf)
  stub_of_simpf$onCall(3)$expects(g = 'a')$throws('error is nice')
  stub_func <- stub_of_simpf$build()
  
  expect_null(stub_func(1, 2, 3, g = 'a'))
  expect_null(stub_func(1, 2, 3, g = 'a'))
  expect_error(stub_func(1, 2, 3, g = 'b'), not_expected_error)
})

test_that('simple onCalls: It does the right thing on the nth time running of the function', {
  stub_of_simpf <- stub(simpf)
  stub_of_simpf$onCall(3)$returns(10)
  stub_of_simpf$onCall(5)$throws('pqrst')
  stub_of_simpf$onCall(6)$expects(b = 2)
  stub_of_simpf$onCall(9)$strictlyExpects(a = 'a', b = 'b', d = 'd')
  stub_func <- stub_of_simpf$build()

  expect_null(stub_func(1, 2, 3)) # 1
  expect_null(stub_func(2, 3, 1)) # 2
  expect_equal(stub_func(3, 1, 2), 10) # 3
  expect_null(stub_func(5, 6, 7)) # 4
  expect_error(stub_func(2, 3, 1), 'pqrst') # 5
  expect_error(stub_func(2, 3, 1), not_expected_error) # 6
  expect_null(stub_func(5, 6, 7)) # 7
  expect_null(stub_func(5, 6, 7)) # 8
  expect_error(stub_func(2, 3, 1), not_expected_error) # 9
})
