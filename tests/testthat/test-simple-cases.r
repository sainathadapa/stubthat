library(stubthat)
library(testthat)

simpf <- function(a = 1, b, d, ...) return(5)

test_that('returns: Always returns specified value', {
  stub_of_simpf <- stub(simpf)
  stub_of_simpf$returns(10)
  stub_func <- stub_of_simpf$f
  expect_equal(stub_func(1, 2, 3, 4), 10)
  expect_equal(stub_func(1, 3, 3, b = 4), 10)
  expect_equal(stub_func(1, a = 5, 3, 4), 10)
})

test_that('throws: Always throws error with specified msg', {
  stub_of_simpf <- stub(simpf)
  throw_msg <- 'err msg xyz'
  stub_of_simpf$throws(throw_msg)
  stub_func <- stub_of_simpf$f
  expect_error(stub_func(1, 2, 3, 4), throw_msg)
  expect_error(stub_func(1, 3, 3, b = 4), throw_msg)
  expect_error(stub_func(1, a = 5, 3, 4), throw_msg)
})

test_that('strictlyExpects: Always checks the function call with expected arguments (exact set)', {
  stub_of_simpf <- stub(simpf)
  stub_of_simpf$strictlyExpects(a = 1, b = 2, d = 3, c = 4)
  stub_func <- stub_of_simpf$f
  
  expect_null(stub_func(1, 2, 3, c = 4))
  expect_null(stub_func(c = 4, 2, a = 1, 3))
  
  expect_error(stub_func(2, 3, 3, c = 4),
               "Component.+a.+: Mean relative difference: 1\nComponent.+b.+: Mean relative difference: 0.5")
  expect_error(stub_func(2, 3, 3), "Function wasn't called with the following expected arguments: c")
  expect_error(stub_func(c = 4, a = 3, 1, 2),
               'Component.+a.+: Mean relative difference: 2\nComponent.+b.+: Mean relative difference: 0.5\nComponent.+d.+: Mean relative difference: 0.3333333')
  expect_error(stub_func(a = 3, 1, 2, c = 5, e = 'f'), 'Function was called with the following extra arguments: e')
})

test_that('strictlyExpects & returns: Always checks the function call with expected arguments (exact set) and returns the specified value', {
  stub_of_simpf <- stub(simpf)
  stub_of_simpf$strictlyExpects(a = 1, b = 2, d = 3, c = 4)
  stub_of_simpf$returns('a')
  stub_func <- stub_of_simpf$f
  
  expect_equal(stub_func(1, 2, 3, c = 4), 'a')
  expect_equal(stub_func(c = 4, 2, a = 1, 3), 'a')
  
  expect_error(stub_func(2, 3, 3, c = 4),
               'Component.+a.+: Mean relative difference: 1\nComponent.+b.+: Mean relative difference: 0.5')
  expect_error(stub_func(2, 3, 3), "Function wasn't called with the following expected arguments: c")
  expect_error(stub_func(c = 4, a = 3, 1, 2),
               'Component.+a.+: Mean relative difference: 2\nComponent.+b.+: Mean relative difference: 0.5\nComponent.+d.+: Mean relative difference: 0.3333333')
})

test_that('strictlyExpects & throws: Always checks the function call with expected arguments (exact set) and throws error with specified msg', {
  stub_of_simpf <- stub(simpf)
  stub_of_simpf$strictlyExpects(a = 1, b = 2, d = 3, c = 4)
  stub_of_simpf$throws('err msg')
  stub_func <- stub_of_simpf$f
  
  expect_error(stub_func(1, 2, 3, c = 4), 'err msg')
  expect_error(stub_func(c = 4, 2, a = 1, 3), 'err msg')
  
  expect_error(stub_func(2, 3, 3, c = 4),
               "Component.+a.+: Mean relative difference: 1\nComponent.+b.+: Mean relative difference: 0.5")
  expect_error(stub_func(2, 3, 3), "Function wasn't called with the following expected arguments: c")
  expect_error(stub_func(c = 4, a = 3, 1, 2),
               'Component.+a.+: Mean relative difference: 2\nComponent.+b.+: Mean relative difference: 0.5\nComponent.+d.+: Mean relative difference: 0.3333333')
})

test_that('expects: Always checks if the expected arguments are part of the function call', {
  stub_of_simpf <- stub(simpf)
  stub_of_simpf$expects(b = 2)
  stub_func <- stub_of_simpf$f
  
  expect_null(stub_func(1, 2, 3, c = 4))
  expect_null(stub_func(c = 'b', 2, a = 1, list(a = 1)))
  
  expect_error(stub_func(2, 3, 3, c = 4), 'Component.+b.+: Mean relative difference: 0.5')
  expect_error(stub_func(2, 3, 3), 'Component.+b.+: Mean relative difference: 0.5')
  expect_error(stub_func(c = 4, a = 3, 1, 2), 'Component.+b.+: Mean relative difference: 0.5')
  expect_error(stub_func(a = 3, 1, 2), 'Component.+b.+: Mean relative difference: 0.5')
})

test_that('expects & returns: Always checks for expected arguments and returns the specified value', {
  stub_of_simpf <- stub(simpf)
  stub_of_simpf$expects(c = list(a = '1'))
  stub_of_simpf$returns('a')
  stub_func <- stub_of_simpf$f
  
  expect_equal(stub_func(1, 2, 3, c = list(a = '1')), 'a')
  expect_equal(stub_func(c = list(a = '1'), 2, a = 1, 3), 'a')
  
  expect_error(stub_func(2, 3, 3, c = 4), 'Component.+c.+: Modes: list, numeric
Component.+c.+: names for target but not for current
Component.+c.+: Component 1: Modes: character, numeric
Component.+c.+: Component 1: target is character, current is numeric')
  expect_error(stub_func(2, 3, 3), "Function wasn't called with the following expected arguments: c")
  expect_error(stub_func(c = 4, a = 3, 1, 2), 'Component.+c.+: Modes: list, numeric
Component.+c.+: names for target but not for current
Component.+c.+: Component 1: Modes: character, numeric
Component.+c.+: Component 1: target is character, current is numeric')
})

test_that('expects & throws: Always checks for expected arguments and throws error with specified msg', {
  stub_of_simpf <- stub(simpf)
  stub_of_simpf$expects(c = 'p')
  stub_of_simpf$throws('err msg')
  stub_func <- stub_of_simpf$f
  
  expect_error(stub_func(1, 2, 3, c = 'p'), 'err msg')
  expect_error(stub_func(c = 'p', list(1, 2, 3), a = 1, 3), 'err msg')
  
  expect_error(stub_func(2, 3, 3, c = 4), 'Component.+c.+: Modes: character, numeric
Component.+c.+: target is character, current is numeric')
  expect_error(stub_func(2, 3, 3), "Function wasn't called with the following expected arguments: c")
  expect_error(stub_func(c = 4, a = 3, 1, 2), 'Component.+c.+: Modes: character, numeric
Component.+c.+: target is character, current is numeric')
})