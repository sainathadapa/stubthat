library(stubthat)
library(testthat)

if (!require('mockr')) {
  install.packages('mockr')
}

sub <- base::sub
file_path_sans_ext <- tools::file_path_sans_ext
test_environment <- environment()

test_that('Testing "returns" case using with_mock', {
  stub_builder <- stub(sub)
  stub_builder$returns('hang on')
  sub_stub <- stub_builder$f
  
  file_path_sans_ext_tester <- function(x) with_mock(sub = sub_stub, file_path_sans_ext(x), .env = test_environment)
  
  expect_equal(object = file_path_sans_ext_tester('test5'),
               expected = 'hang on')
})

test_that('Testing "throws" case using with_mock', {
  stub_builder <- stub(sub)
  stub_builder$throws('kkkkkkkkkk')
  sub_stub <- stub_builder$f
  
  file_path_sans_ext_tester <- function(x) with_mock(sub = sub_stub, file_path_sans_ext(x), .env = test_environment)
  
  expect_error(file_path_sans_ext_tester('dsfsd'),  'kkkkkkkkkk')
  expect_error(file_path_sans_ext_tester('gfgxgx'), 'kkkkkkkkkk')
})

test_that('Testing "expects" case using with_mock', {
  stub_builder <- stub(sub)
  stub_builder$strictlyExpects(pattern = "([^.]+)\\.[[:alnum:]]+$", replacement = '\\1', x = 'goo.goo',
                               ignore.case = FALSE, perl = FALSE, fixed = FALSE, useBytes = FALSE)
  sub_stub <- stub_builder$f
  
  file_path_sans_ext_tester <- function(x) with_mock(sub = sub_stub, file_path_sans_ext(x), .env = test_environment)
  
  expect_error(file_path_sans_ext_tester('dsfsd'))
  expect_silent(file_path_sans_ext_tester('goo.goo'))
})

test_that('Testing non-simple cases using with_mock', {
  stub_builder <- stub(sub)
  
  stub_builder$onCall(1)$returns('yay!')
  
  stub_builder$onCall(2)$strictlyExpects(
    pattern = "([^.]+)\\.[[:alnum:]]+$", replacement = '\\1', x = 'test2',
    ignore.case = FALSE, perl = FALSE, fixed = FALSE, useBytes = FALSE)$returns(10)
  
  stub_builder$onCall(3)$strictlyExpects(
    pattern = "([^.]+)\\.[[:alnum:]]+$", replacement = '\\1', x = 'test3',
    ignore.case = FALSE, perl = FALSE, fixed = FALSE, useBytes = FALSE)$throws('err msg')
  
  stub_builder$onCall(4)$expects(x = 'test4')$returns('test4-res')
  
  stub_builder$withExactArgs(
    pattern = "[.](gz|bz2|xz)$", replacement = '', x = 'test5',
    ignore.case = FALSE, perl = FALSE, fixed = FALSE, useBytes = FALSE)$throws('test5-res')
  
  stub_builder$withArgs(x = 'test67')$returns('test67-res')
  
  stub_builder$withArgs(x = 'test67-res')$returns('test67-res-res')
  
  sub_stub <- stub_builder$f
  
  file_path_sans_ext_tester <- function(x, compression = FALSE) {
    with_mock(sub = sub_stub, file_path_sans_ext(x, compression = compression), .env = test_environment) 
  }
  
  expect_equal(file_path_sans_ext_tester('dsfsdfs.gfg'), 'yay!')
  
  expect_equal(file_path_sans_ext_tester('test2'), 10)
  
  expect_error(file_path_sans_ext_tester('test3'), 'err msg')
  
  expect_equal(file_path_sans_ext_tester('test4'), 'test4-res')
  
  expect_error(file_path_sans_ext_tester('test5', compression = TRUE), 'test5-res')
  
  expect_equal(file_path_sans_ext_tester('test67'), 'test67-res')
  
  expect_equal(file_path_sans_ext_tester('test67', compression = TRUE), 'test67-res-res')
  
})
