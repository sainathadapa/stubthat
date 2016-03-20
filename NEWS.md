# stubthat 0.1.0.9000
- `stub$onCall(...)$withArgs(..)` is now `stub$onCall(...)$expects(..)`. Previously the stub didn't throw an error if the specified arguments are not present on the nth call. Now it does.
- `stub$onCall(...)$withExactArgs(..)` is now `stub$onCall(...)$strictlyExpects(..)`. Same reason as above.
- `stub$expects(...)` is now `stub$strictlyExpects(...)`.
- New `stub$expects(...)` checks if the expected arguments are **part** of the function call (not **exact** set).
- New `stub$calledTimes()` to get the number of times the function was called.
- No need for `stub$build()` anymore. Mock is directly available from `stub$f`


# stubthat 0.1.0
- Initial CRAN release
