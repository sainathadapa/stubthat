<!-- README.md is generated from README.Rmd. Please edit that file -->
stubthat
========

[![Travis-CI Build Status](https://travis-ci.org/sainathadapa/stubthat.svg?branch=master)](https://travis-ci.org/sainathadapa/stubthat) [![codecov.io](http://codecov.io/github/sainathadapa/stubthat/coverage.svg?branch=master)](http://codecov.io/github/sainathadapa/stubthat?branch=master) [![CRAN version](http://www.r-pkg.org/badges/version/stubthat)](http://www.r-pkg.org/pkg/stubthat) [![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/stubthat)](http://www.r-pkg.org/pkg/stubthat)

Introduction
============

stubthat package provides stubs for use while unit testing in R. The API is highly inspired by the [Sinon.js](http://sinonjs.org/). This package is meant to be used along with the [testthat](https://cran.r-project.org/web/packages/testthat/index.html) package, specifically the 'with\_mock' function.

Usage
=====

There are three main steps to the create a stub of a function -

-   Invoke the *stub* function with the function that needs to be mocked

``` r
jedi_or_sith <- function(x) return('No one')
jedi_or_sith_stub <- stub(jedi_or_sith)
```

-   Define the behavior. This is explained in detail in the next section.

``` r
jedi_or_sith_stub$withArgs(x = 'Luke')$returns('Jedi')
```

-   Build the stub.

``` r
jedi_or_sith_stub <- jedi_or_sith_stub$build()
```

Once the stub is built, you can use the returned function.

``` r
jedi_or_sith('Luke')
#> [1] "No one"
jedi_or_sith_stub('Luke')
#> [1] "Jedi"
```

Stubs are generally used while testing. Here is an example:

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
stub_of_get <- stub_of_get$build()

stub_of_status_code <- stub(status_code)
stub_of_status_code$withArgs(x = 'good response')$returns(200)
stub_of_status_code$withArgs(x = 'bad response')$returns(400)
stub_of_status_code <- stub_of_status_code$build()

library('testthat')
with_mock(GET = stub_of_get, status_code = stub_of_status_code,
          expect_equal(check_api_endpoint_status('good url'), 'up'))
#> As expected: check_api_endpoint_status("good url") equals "up"

with_mock(GET = stub_of_get, status_code = stub_of_status_code,
          expect_equal(check_api_endpoint_status('bad url'), 'down'))
#> As expected: check_api_endpoint_status("bad url") equals "down"
```

Behaviors
=========

Simple
------

`stub$returns(data.frame(x = 1, y = 2))`

This will always return the specified object irrespective of the inputs.

`stub$throws('there is an error')`

This will always throw an error with the specified message irrespective of the inputs.

`stub$expects(a = 1, b = 2, d = 3, c = 4)`

This will check the incoming arguments for the specified set of arguments. Throws an error if there is a mismatch. Returns null if matched.

withExactArgs
-------------

`stub$withExactArgs(a = 1, b = 2, d = 3, c = 4)$returns(10)`

If the function is called with the **exact** set of expected arguments, then the specified object will be returned.

`stub$withExactArgs(a = 1, b = 2, d = 3, c = 4)$throws('err_msg')`

If the function is called with the **exact** set of expected arguments, then an error is thrown with the specified message.

with Args
---------

`stub$withArgs(a = 1, d = 3)$returns(10)`

If the expected arguments are **part** of the function call, then the specified object will be returned.

`stub$withArgs(a = 1, d = 3)$throws('err msg')`

If the expected arguments are **part** of the function call, then an error is thrown with the specified message.

onCall
------

`stub$onCall(2)$returns(10)`

When the function is called the nth time, the specified object will be returned.

`stub$onCall(2)$throws('err_msg')`

When the function is called the nth time, an error is thrown with the specified message.

*onCall* can be used along with *withExactArgs* and *withArgs*.

    stub$onCall(3)$withExactArgs(a = 1, b = 2, d = 3, c = 4)$returns(10)
    stub$onCall(2)$withExactArgs(a = 1, b = 2, d = 3, c = 4)$throws('err_msg')
    stub$onCall(3)$withArgs(a = 1, d = 3)$returns(10)
    stub$onCall(3)$withArgs(a = 1, d = 3)$throws('err msg')

Caveats
=======

All arguments must be named.

`stub_builder$withArgs(1)$return(T)` won't work.

`stub_builder$withArgs(x = 1)$return(T)` will work.
