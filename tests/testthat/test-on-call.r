library(stubthat)
library(testthat)

simpf <- function(a = 1, b, d, ...) return(5)

error1 <- 'Component.+b.+: Mean relative difference: 0.5'

error2 <- 'Component.+a.+: Modes: character, numeric
Component.+a.+: target is character, current is numeric
Component.+b.+: Modes: character, numeric
Component.+b.+: target is character, current is numeric
Component.+d.+: Modes: character, numeric
Component.+d.+: target is character, current is numeric'

test_that('simple onCalls: It does the right thing on the nth time running of the function', {
  stub_of_simpf <- stub(simpf)
  stub_of_simpf$onCall(3)$returns(10)
  stub_of_simpf$onCall(5)$throws('pqrst')
  stub_of_simpf$onCall(6)$expects(b = 2)
  stub_of_simpf$onCall(9)$strictlyExpects(a = 'a', b = 'b', d = 'd')
  stub_func <- stub_of_simpf$f

  expect_null(stub_func(1, 2, 3)) # 1
  expect_null(stub_func(2, 3, 1)) # 2
  expect_equal(stub_func(3, 1, 2), 10) # 3
  expect_null(stub_func(5, 6, 7)) # 4
  expect_error(stub_func(2, 3, 1), 'pqrst') # 5
  expect_error(stub_func(2, 3, 1), error1) # 6
  expect_null(stub_func(5, 6, 7)) # 7
  expect_null(stub_func(5, 6, 7)) # 8
  expect_error(stub_func(2, 3, 1), error2) # 9
})
