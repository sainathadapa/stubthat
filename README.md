-   [stubthat](#stubthat)
-   [Installation](#installation)
-   [Introduction](#introduction)
-   [Usage](#usage)
-   [Use cases](#use-cases)
-   [API](#api)
    -   [Check if the stub is called with specified arguments](#check-if-the-stub-is-called-with-specified-arguments)
        -   [`stub$expects(...)`](#stubexpects...)
        -   [`stub$strictlyExpects(...)`](#stubstrictlyexpects...)
        -   [`stub$onCall(#)$expects(...)`](#stuboncallexpects...)
        -   [`stub$onCall(#)$strictlyExpects(...)`](#stuboncallstrictlyexpects...)
    -   [Make the stub return a specified value](#make-the-stub-return-a-specified-value)
        -   [`stub$returns(...)`](#stubreturns...)
        -   [`stub$onCall(#)$returns(...)`](#stuboncallreturns...)
        -   [`stub$withArgs(...)$returns(...)`](#stubwithargs...returns...)
        -   [`stub$withExactArgs(...)$returns(...)`](#stubwithexactargs...returns...)
    -   [Make the stub throw an error with a specified message](#make-the-stub-throw-an-error-with-a-specified-message)
        -   [`stub$throws('')`](#stubthrows)
        -   [`stub$onCall(#)$throws('')`](#stuboncallthrows)
        -   [`stub$withArgs(...)$throws('')`](#stubwithargs...throws)
        -   [`stub$withExactArgs(...)$throws('')`](#stubwithexactargs...throws)
    -   [Get the number of times the stub has been called](#get-the-number-of-times-the-stub-has-been-called)
        -   [`stub$calledTimes()`](#stubcalledtimes)
    -   [Extra](#extra)
        -   [`stub$onCall(#)$expects(...)$returns(...)`](#stuboncallexpects...returns...)
        -   [`stub$onCall(#)$strictlyExpects(...)$returns(...)`](#stuboncallstrictlyexpects...returns...)
        -   [`stub$onCall(#)$expects(...)$throws('')`](#stuboncallexpects...throws)
        -   [`stub$onCall(#)$strictlyExpects(...)$throws('')`](#stuboncallstrictlyexpects...throws)
-   [License](#license)

<!-- README.md is generated from README.Rmd. Please edit that file -->
stubthat
========

[![Join the chat at https://gitter.im/sainathadapa/stubthat](https://badges.gitter.im/sainathadapa/stubthat.svg)](https://gitter.im/sainathadapa/stubthat?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[![Travis-CI Build Status](https://travis-ci.org/sainathadapa/stubthat.svg?branch=master)](https://travis-ci.org/sainathadapa/stubthat) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/sainathadapa/stubthat?branch=master&svg=true)](https://ci.appveyor.com/project/sainathadapa/stubthat) [![codecov.io](http://codecov.io/github/sainathadapa/stubthat/coverage.svg?branch=master)](http://codecov.io/github/sainathadapa/stubthat?branch=master) [![CRAN version](http://www.r-pkg.org/badges/version/stubthat)](http://www.r-pkg.org/pkg/stubthat) [![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/stubthat)](http://www.r-pkg.org/pkg/stubthat)

Installation
============

-   Install the latest released version from CRAN with

``` r
install.packages("stubthat")
```

-   Install the latest development version from github with

``` r
devtools::install_github("sainathadapa/stubthat", build_vignettes = TRUE)
```

Introduction
============

*stubthat* package provides stubs for use while unit testing in R. The API is highly inspired by the *[Sinon.js](http://sinonjs.org/)*. This package is meant to be used along with the *[testthat](https://cran.r-project.org/package=testthat)* package, specifically the *'with\_mock'* function. Please note that although this package was written with an intention to be used alongside *testthat*, this package doesn't depend on *testthat* or any other package.

To understand what a stub is and how they are used while unit testing, please take a look at this Stackoverflow question [What is a “Stub”?](http://stackoverflow.com/questions/463278/what-is-a-stub).

Usage
=====

There are three main steps for creating & using a stub of a function -

-   Invoke the *stub* function with the function that needs to be mocked

``` r
jedi_or_sith <- function(x) return('No one')
jedi_or_sith_stub <- stub(jedi_or_sith)
```

-   Define the behavior. This is explained in detail in the API section.

``` r
jedi_or_sith_stub$withArgs(x = 'Luke')$returns('Jedi')
```

-   Once the behavior is defined, you can use the stub by calling the `jedi_or_sith_stub$f` function.

``` r
jedi_or_sith('Luke')
#> [1] "No one"
jedi_or_sith_stub$f('Luke')
#> [1] "Jedi"
```

Use cases
=========

Stubs are generally used for testing purposes. Here is an example:

``` r
library('httr')

check_api_endpoint_status <- function(url) {
  response <- GET(url)
  response_status <- status_code(response)
  ifelse(response_status == 200, 'up', 'down')
}
```

This function *check\_api\_endpoint\_status* should make a *GET* request to the specified url and it should return *'up'* if the status code is *'200'*. Return *'down'* otherwise.

Using stubs, without accessing any external source, the function can be tested as shown below:

``` r
stub_of_get <- stub(GET)
stub_of_get$withArgs(url = 'good url')$returns('good response')
stub_of_get$withArgs(url = 'bad url')$returns('bad response')

stub_of_status_code <- stub(status_code)
stub_of_status_code$withArgs(x = 'good response')$returns(200)
stub_of_status_code$withArgs(x = 'bad response')$returns(400)

library('testthat')
with_mock(GET = stub_of_get$f, status_code = stub_of_status_code$f,
          expect_equal(check_api_endpoint_status('good url'), 'up'))
#> [1] "up"

with_mock(GET = stub_of_get$f, status_code = stub_of_status_code$f,
          expect_equal(check_api_endpoint_status('bad url'), 'down'))
#> [1] "down"
```

API
===

Check if the stub is called with specified arguments
----------------------------------------------------

### `stub$expects(...)`

Stub will check the incoming arguments for the specified set of arguments. Throws an error if there is a mismatch.

``` r
sum <- function(a, b = 1) return(a + b)
stub_of_identify <- stub(sum)

stub_of_identify$expects(a = 2)

stub_of_identify$f(2)
#> NULL
stub_of_identify$f(3)
#> Error in stub_of_identify$f(3): Following arguments are not matching: {'a'}
#> Argument: 'a':
#> 1/1 mismatches
#> [1] 2 - 3 == -1
```

### `stub$strictlyExpects(...)`

The set of specified arguments should be exactly matched with the set of incoming arguments.

``` r
sum <- function(a, b = 1) return(a + b)
stub_of_identify <- stub(sum)

stub_of_identify$strictlyExpects(a = 2)
stub_of_identify$f(2)
#> Error in stub_of_identify$f(2): Function was called with the following extra arguments: 'b'
```

The above call resulted in the error because the incoming set of arguments was `a = 2, b = 1`, but the defined set of expected arguments consisted only `a = 2`.

``` r
stub_of_identify$strictlyExpects(a = 2, b = 1)
stub_of_identify$f(2)
#> NULL
```

### `stub$onCall(#)$expects(...)`

The stub expects the specifed arguments on the *nth* call.

``` r
sum <- function(a, b = 1) return(a + b)
stub_of_identify <- stub(sum)

stub_of_identify$onCall(3)$expects(a = 2)

stub_of_identify$f(100)
#> NULL
stub_of_identify$f(100)
#> NULL
stub_of_identify$f(100)
#> Error in stub_of_identify$f(100): Following arguments are not matching: {'a'}
#> Argument: 'a':
#> 1/1 mismatches
#> [1] 2 - 100 == -98
```

### `stub$onCall(#)$strictlyExpects(...)`

The stub expects the **exact** set of specifed arguments on the *nth* call.

``` r
sum <- function(a, b = 1) return(a + b)
stub_of_identify <- stub(sum)

stub_of_identify$onCall(3)$strictlyExpects(a = 2, b = 2)

stub_of_identify$f(2)
#> NULL
stub_of_identify$f(2)
#> NULL
stub_of_identify$f(2)
#> Error in stub_of_identify$f(2): Following arguments are not matching: {'b'}
#> Argument: 'b':
#> 1/1 mismatches
#> [1] 2 - 1 == 1
```

Make the stub return a specified value
--------------------------------------

### `stub$returns(...)`

Unless otherwise specified, the stub always returns the specified value.

``` r
sum <- function(a, b = 1) return(a + b)
stub_of_identify <- stub(sum)

stub_of_identify$returns(0)

stub_of_identify$f(2)
#> [1] 0
```

### `stub$onCall(#)$returns(...)`

The stub returns the specified value on the *nth* call.

``` r
sum <- function(a, b = 1) return(a + b)
stub_of_identify <- stub(sum)

stub_of_identify$onCall(2)$returns(0)

stub_of_identify$f(2)
#> NULL
stub_of_identify$f(2)
#> [1] 0
```

### `stub$withArgs(...)$returns(...)`

The stub returns the specified value when it is called with the specified arguments.

``` r
sum <- function(a, b = 1) return(a + b)
stub_of_identify <- stub(sum)

stub_of_identify$withArgs(a = 2)$returns(0)

stub_of_identify$f(1)
#> NULL
stub_of_identify$f(2)
#> [1] 0
```

### `stub$withExactArgs(...)$returns(...)`

The stub returns the specified value when it is called with the **exact** set of specified arguments.

``` r
sum <- function(a, b = 1) return(a + b)
stub_of_identify <- stub(sum)

stub_of_identify$withExactArgs(a = 2)$returns(0) # won't work because value for b is not defined
stub_of_identify$withExactArgs(a = 2, b = 1)$returns(1)

stub_of_identify$f(1)
#> NULL
stub_of_identify$f(2)
#> [1] 1
```

Make the stub throw an error with a specified message
-----------------------------------------------------

### `stub$throws('')`

Unless otherwise specified, the stub throws an error with the specified message.

``` r
sum <- function(a, b = 1) return(a + b)
stub_of_identify <- stub(sum)

stub_of_identify$throws('some err msg')

stub_of_identify$f(2)
#> Error in output_func(do_this$behavior, do_this$return_val): some err msg
```

### `stub$onCall(#)$throws('')`

The stub throws an error on the *nth* call.

``` r
sum <- function(a, b = 1) return(a + b)
stub_of_identify <- stub(sum)

stub_of_identify$onCall(2)$throws('some err msg')

stub_of_identify$f(0)
#> NULL
stub_of_identify$f(0)
#> Error in output_func(do_this$behavior, do_this$return_val): some err msg
```

### `stub$withArgs(...)$throws('')`

The stub throws an error when it is called with the specified arguments.

``` r
sum <- function(a, b = 1) return(a + b)
stub_of_identify <- stub(sum)

stub_of_identify$withArgs(a = 2)$throws('some err msg')

stub_of_identify$f(1)
#> NULL
stub_of_identify$f(2)
#> Error in output_func(do_this$behavior, do_this$return_val): some err msg
```

### `stub$withExactArgs(...)$throws('')`

The stub returns the specified value when it is called with the **exact** set of specified arguments.

``` r
sum <- function(a, b = 1) return(a + b)
stub_of_identify <- stub(sum)

stub_of_identify$withExactArgs(a = 2)$throws('good') # won't work because value for b is not defined
stub_of_identify$withExactArgs(a = 2, b = 1)$throws('nice')

stub_of_identify$f(1)
#> NULL
stub_of_identify$f(2)
#> Error in output_func(do_this$behavior, do_this$return_val): nice
```

Get the number of times the stub has been called
------------------------------------------------

### `stub$calledTimes()`

Using this, one can obtain the number of times, the stub has been called.

``` r
sum <- function(a, b = 1) return(a + b)
stub_of_identify <- stub(sum)

ans <- stub_of_identify$f(3)
ans <- stub_of_identify$f(3)
stub_of_identify$calledTimes()
#> [1] 2
ans <- stub_of_identify$f(3)
stub_of_identify$calledTimes()
#> [1] 3
```

Extra
-----

Convenience functions to reduce repetition of code.

### `stub$onCall(#)$expects(...)$returns(...)`

On *nth* call, the stub will check for the specified arguments, and if satisfied, returns the specified value.

``` r
sum <- function(a, b = 1) return(a + b)
stub_of_identify <- stub(sum)

stub_of_identify$onCall(1)$expects(a = 1)$returns('good')
stub_of_identify$onCall(3)$expects(a = 3)$returns('nice')

stub_of_identify$f(3)
#> Error in stub_of_identify$f(3): Following arguments are not matching: {'a'}
#> Argument: 'a':
#> 1/1 mismatches
#> [1] 1 - 3 == -2
stub_of_identify$f(3)
#> NULL
stub_of_identify$f(3)
#> [1] "nice"
```

This is same as calling `stub$onCall(#)$expects(...)` and `stub$onCall(#)$returns(...)` separately.

``` r
sum <- function(a, b = 1) return(a + b)
stub_of_identify <- stub(sum)

stub_of_identify$onCall(1)$expects(a = 1)
stub_of_identify$onCall(1)$returns('good')
stub_of_identify$onCall(3)$returns('nice')
stub_of_identify$onCall(3)$expects(a = 3)

stub_of_identify$f(3)
#> Error in stub_of_identify$f(3): Following arguments are not matching: {'a'}
#> Argument: 'a':
#> 1/1 mismatches
#> [1] 1 - 3 == -2
stub_of_identify$f(3)
#> NULL
stub_of_identify$f(3)
#> [1] "nice"
```

### `stub$onCall(#)$strictlyExpects(...)$returns(...)`

On *nth* call, the stub will check for the **exact** set of specified arguments, and if satisfied, returns the specified value.

``` r
sum <- function(a, b = 1) return(a + b)
stub_of_identify <- stub(sum)

stub_of_identify$onCall(1)$strictlyExpects(a = 3)$returns('good')
stub_of_identify$onCall(3)$strictlyExpects(a = 3, b = 1)$returns('nice')

stub_of_identify$f(3)
#> Error in stub_of_identify$f(3): Function was called with the following extra arguments: 'b'
stub_of_identify$f(3)
#> NULL
stub_of_identify$f(3)
#> [1] "nice"
```

### `stub$onCall(#)$expects(...)$throws('')`

On *nth* call, the stub will check for the specified arguments, and if satisfied, throws an error with the specified message.

``` r
sum <- function(a, b = 1) return(a + b)
stub_of_identify <- stub(sum)

stub_of_identify$onCall(1)$expects(a = 1)$throws('good')
stub_of_identify$onCall(3)$expects(a = 3)$throws('nice')

stub_of_identify$f(3)
#> Error in stub_of_identify$f(3): Following arguments are not matching: {'a'}
#> Argument: 'a':
#> 1/1 mismatches
#> [1] 1 - 3 == -2
stub_of_identify$f(3)
#> NULL
stub_of_identify$f(3)
#> Error in output_func(do_this$behavior, do_this$return_val): nice
```

### `stub$onCall(#)$strictlyExpects(...)$throws('')`

On *nth* call, the stub will check for the **exact** set of specified arguments, and if satisfied, throws an error with the specified message.

``` r
sum <- function(a, b = 1) return(a + b)
stub_of_identify <- stub(sum)

stub_of_identify$onCall(1)$strictlyExpects(a = 3)$throws('good')
stub_of_identify$onCall(3)$strictlyExpects(a = 3, b = 1)$throws('nice')

stub_of_identify$f(3)
#> Error in stub_of_identify$f(3): Function was called with the following extra arguments: 'b'
stub_of_identify$f(3)
#> NULL
stub_of_identify$f(3)
#> Error in output_func(do_this$behavior, do_this$return_val): nice
```

License
=======

Released under [MIT License](https://cran.rstudio.com/web/licenses/MIT).
