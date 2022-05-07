# stubthat 1.2.2
- update to work with mockr 0.2.0

# stubthat 1.2.1
- Removed instances of automatic installation of suggested packages

# stubthat 1.2.0
- Updated an example in README to use `mockr::with_mock` instead of `testthat::with_mock`
- Added a note about `with_mock` in Vignette and README
- mockr package is added to 'SUGGESTS'
- Updated few tests to use `mockr::with_mock` instead of `testthat::with_mock`
- Changed vignette template to `prettydoc::html_pretty`

# stubthat 1.1.0
- Improved error messages when arguments don't match
- Fixed bugs related to arguments with no/blank names

# stubthat 1.0.0
- `stub$onCall(#)$withArgs(...)` is now `stub$onCall(#)$expects(...)`. Previously the stub didn't throw an error if the specified arguments are not present on the nth call. Now it does.
- `stub$onCall(#)$withExactArgs(...)` is now `stub$onCall(#)$strictlyExpects(...)`. Similar change in functionality as above. The stub now throws an error if any specified argument is found to be missing or if there is a mismatch in values.
- `stub$expects(...)` in the previous version used to check for the exact set of arguments. In the latest version, it checks if the expected arguments are **part** of the function call (**not exact** set).
- `stub$strictlyExpects(...)` will check for the exact set of specified arguments. No specied argument should be missing. And no unspecified argument should be present in the function call.
- `stub$calledTimes()` can be used to get the number of times the stub was called.
- No need for `stub$build()` step anymore. Mock is directly available from `stub$f`

# stubthat 0.1.0
- Initial CRAN release
